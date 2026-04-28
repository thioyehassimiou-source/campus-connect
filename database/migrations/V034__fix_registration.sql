-- 🛠️ CORRECTION DÉFINITIVE INSCRIPTION CAMPUSCONNECT (V_FINAL)
-- 🎯 OBJECTIF : Réparer "Database error saving new user" sans toucher au code Flutter
-- ⚠️ À EXÉCUTER DANS L'ÉDITEUR SQL SUPABASE

BEGIN;

-- ==============================================================================
-- 1. ADAPTATION DES CONTRAINTES (Le coeur du fix)
-- ==============================================================================
-- 💡 POURQUOI : Le `signUp` Flutter envoie `role`, `nom`, `prenom` mais PAS `faculty_id`.
-- Si `faculty_id` est NOT NULL, le trigger plante instantanément.
-- On rend ces champs NULLABLE pour permettre la création initiale (étape 1),
-- le client Flutter fait un `upsert` juste après pour les remplir (étape 2).

ALTER TABLE public.profiles 
  ALTER COLUMN faculty_id DROP NOT NULL,
  ALTER COLUMN department_id DROP NOT NULL,
  ALTER COLUMN service_id DROP NOT NULL,
  ALTER COLUMN filiere_id DROP NOT NULL,
  ALTER COLUMN telephone DROP NOT NULL;

-- ==============================================================================
-- 2. NETTOYAGE (RLS & Triggers foireux)
-- ==============================================================================

-- Suppression des anciennes politiques qui pourraient causer des récursions
DROP POLICY IF EXISTS "Public profiles read access" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
-- Suppression des potentiels doublons ou anciennes versions
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

-- ==============================================================================
-- 3. TRIGGER ROBUSTE & TOLÉRANT
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_role text;
  v_first_name text;
  v_last_name text;
  v_full_name text;
  v_telephone text;
  v_niveau text;
  -- Variables pour IDs (avec gestion NULL safe)
  v_faculty_id bigint;
  v_dept_id bigint;
  v_service_id uuid;
  v_filiere_id bigint;
BEGIN
  -- Extraction sécurisée des métadonnées (évite les crashs si clé manquante)
  v_role := COALESCE(new.raw_user_meta_data->>'role', 'Étudiant');
  v_first_name := new.raw_user_meta_data->>'first_name';
  v_last_name := new.raw_user_meta_data->>'last_name';
  v_telephone := new.raw_user_meta_data->>'telephone';
  v_niveau := new.raw_user_meta_data->>'niveau';

  -- Construction du nom complet si nom/prenom séparés (format du nouveau formulaire)
  IF v_first_name IS NOT NULL AND v_last_name IS NOT NULL THEN
    v_full_name := v_first_name || ' ' || v_last_name;
  ELSE
    v_full_name := COALESCE(new.raw_user_meta_data->>'nom', 'Utilisateur');
  END IF;

  -- Cast sécurisé des IDs (BigInt vs UUID)
  BEGIN
    v_faculty_id := (new.raw_user_meta_data->>'faculty_id')::bigint;
  EXCEPTION WHEN OTHERS THEN v_faculty_id := NULL; END;

  BEGIN
    v_dept_id := (new.raw_user_meta_data->>'department_id')::bigint;
  EXCEPTION WHEN OTHERS THEN v_dept_id := NULL; END;
  
  BEGIN
    v_filiere_id := (new.raw_user_meta_data->>'filiere_id')::bigint;
  EXCEPTION WHEN OTHERS THEN v_filiere_id := NULL; END;

  BEGIN
    v_service_id := (new.raw_user_meta_data->>'service_id')::uuid;
  EXCEPTION WHEN OTHERS THEN v_service_id := NULL; END;

  -- 🛡️ RÈGLES MÉTIER STRICTES (Validation côté serveur)
  -- Un enseignant n'a PAS de département (spécifique business logic Labé)
  IF v_role = 'Enseignant' THEN
    v_dept_id := NULL;
  END IF;

  -- Un administratif a un service (mais ici on autorise NULL temporairement pour le Step 1)
  IF v_role = 'Administratif' THEN
    v_dept_id := NULL; 
  END IF;

  -- Insertion dans PROFILES
  INSERT INTO public.profiles (
    id, 
    email, 
    role, 
    nom, 
    telephone, 
    faculty_id,
    department_id, 
    service_id, 
    filiere_id,
    niveau,
    created_at,
    updated_at
  )
  VALUES (
    new.id, 
    new.email, 
    v_role, 
    v_full_name, 
    v_telephone, 
    v_faculty_id,
    v_dept_id, 
    v_service_id,
    v_filiere_id, 
    v_niveau,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    nom = EXCLUDED.nom,
    updated_at = NOW();

  RETURN new;
EXCEPTION WHEN OTHERS THEN
  -- Log l'erreur mais NE BLOQUE PAS l'inscription auth (auth.users)
  -- Cela permet à ensureProfileExists() du client de rattraper le coup si le trigger échoue
  RAISE WARNING 'Trigger handle_new_user failed: %', SQLERRM;
  RETURN new;
END;
$$;

-- Réactivation du Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- 4. SÉCURITÉ (RLS) SIMPLE & EFFICACE
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ✅ PUBLIC: Tout le monde peut voir les profils (nécessaire pour l'annuaire, etc.)
CREATE POLICY "Public read access" 
ON public.profiles FOR SELECT 
USING (true);

-- ✅ SELF: L'utilisateur peut MODIFIER son propre profil
-- CRITIQUE pour l'étape 2 de l'inscription (upsert depuis le client)
CREATE POLICY "Users can update own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- ✅ SELF: L'utilisateur peut CRÉER son propre profil 
-- (Au cas où le trigger échoue silencieusement, le client retry)
CREATE POLICY "Users can insert own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

COMMIT;
