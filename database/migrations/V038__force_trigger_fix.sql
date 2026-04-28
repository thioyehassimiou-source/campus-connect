-- 🛡️ SOLUTION RLS 42501 : TRIGGER SERVER-SIDE OBLIGATOIRE
-- 🎯 Diagnostic : L'erreur 42501 prouve que le client Flutter n'a pas le droit d'écrire dans 'profiles'.
-- 💡 Solution : On déplace l'écriture du CLIENT vers le SERVEUR (Trigger).
--    Le trigger s'exécute en tant que "SuperAdmin" (SECURITY DEFINER), contournant RLS.

BEGIN;

-- 1. NETTOYAGE (On repart sur une base saine)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- 2. CRÉATION DE LA FONCTION TRIGGER (Bypass RLS grâce à SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public -- ⚠️ CRITIQUE : Force l'exécution en tant qu'admin
AS $$
DECLARE
  v_role text;
  v_first_name text;
  v_last_name text;
  v_full_name text;
  v_telephone text;
  v_niveau text;
  v_faculty_id bigint;
  v_dept_id bigint;
  v_service_id uuid;
  v_filiere_id bigint;
BEGIN
  -- Récupération sécurisée des métadonnées envoyées par Flutter
  v_role := COALESCE(new.raw_user_meta_data->>'role', 'Étudiant');
  v_first_name := new.raw_user_meta_data->>'first_name';
  v_last_name := new.raw_user_meta_data->>'last_name';
  v_telephone := new.raw_user_meta_data->>'telephone';
  v_niveau := new.raw_user_meta_data->>'niveau';

  -- Gestion du Nom Complet
  IF v_first_name IS NOT NULL AND v_last_name IS NOT NULL THEN
    v_full_name := v_first_name || ' ' || v_last_name;
  ELSE
    v_full_name := COALESCE(new.raw_user_meta_data->>'nom', 'Utilisateur');
  END IF;

  -- Cast Sécurisé des IDs (évite les erreurs de type qui bloquent l'auth)
  BEGIN v_faculty_id := (new.raw_user_meta_data->>'faculty_id')::bigint; EXCEPTION WHEN OTHERS THEN v_faculty_id := NULL; END;
  BEGIN v_dept_id := (new.raw_user_meta_data->>'department_id')::bigint; EXCEPTION WHEN OTHERS THEN v_dept_id := NULL; END;
  BEGIN v_filiere_id := (new.raw_user_meta_data->>'filiere_id')::bigint; EXCEPTION WHEN OTHERS THEN v_filiere_id := NULL; END;
  BEGIN v_service_id := (new.raw_user_meta_data->>'service_id')::uuid; EXCEPTION WHEN OTHERS THEN v_service_id := NULL; END;

  -- Règles Métier (Nettoyage des données incohérentes)
  IF v_role = 'Enseignant' THEN v_dept_id := NULL; END IF;
  IF v_role = 'Administratif' THEN v_dept_id := NULL; END IF;

  -- INSERTION (C'est ici que la magie opère : pas de check RLS pour le trigger)
  INSERT INTO public.profiles (
    id, email, role, nom, telephone, faculty_id, department_id, service_id, filiere_id, niveau, created_at, updated_at
  )
  VALUES (
    new.id, new.email, v_role, v_full_name, v_telephone, v_faculty_id, v_dept_id, v_service_id, v_filiere_id, v_niveau, NOW(), NOW()
  )
  ON CONFLICT (id) DO UPDATE SET -- Sécurité anti-doublon
    role = EXCLUDED.role,
    nom = EXCLUDED.nom,
    updated_at = NOW();

  RETURN new;
END;
$$;

-- 3. ACTIVATION DU TRIGGER
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. GESTION DES RLS (Pour la suite : lecture/modif par l'user connecté)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Supprimer les anciennes policies foireuses
DROP POLICY IF EXISTS "Public profiles read access" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;

-- Policy 1: Tout le monde peut LIRE (nécessaire pour afficher infos)
CREATE POLICY "Public profiles read access" 
ON public.profiles FOR SELECT 
USING (true);

-- Policy 2: Seul l'utilisateur peut MODIFIER son propre profil
CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- ⚠️ NOTE IMPORTANTE :
-- On ne crée PAS de policy "INSERT" car c'est désormais le Trigger (SuperAdmin) qui s'en charge.
-- Cela élimine 100% du risque d'erreur RLS 42501 à l'inscription.

COMMIT;
