-- 🛠️ CORRECTION BACKEND CAMPUSCONNECT (V5 - CLEAN RLS & RECURSION FIX)

BEGIN;

-- ==============================================================================
-- 1. NETTOYAGE AGRESSIF DES POLICIERS (RLS)
-- ==============================================================================

-- On utilise un bloc anonyme pour supprimer TOUTES les politiques sur 'profiles'
-- afin d'éliminer celles qui causent la récursion (ex: une politique qui lit 'profiles' pour vérifier les droits)
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT policyname FROM pg_policies WHERE tablename = 'profiles' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.profiles', r.policyname);
    END LOOP;
END $$;


-- ==============================================================================
-- 2. NETTOYAGE DES ANCIENS TRIGGERS
-- ==============================================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user_setup() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;


-- ==============================================================================
-- 3. TRIGGER ROBUSTE (Target: table 'profiles', Column: department_id)
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_role text;
  v_nom text;
  v_telephone text;
  v_dept_id bigint;
  v_service_id uuid;
  v_niveau text;
BEGIN
  v_role := new.raw_user_meta_data->>'role';
  v_nom := new.raw_user_meta_data->>'nom';
  v_telephone := new.raw_user_meta_data->>'telephone';
  v_niveau := new.raw_user_meta_data->>'niveau';

  -- Gestion Department ID (BigInt)
  BEGIN
    v_dept_id := (new.raw_user_meta_data->>'department_id')::bigint;
  EXCEPTION WHEN OTHERS THEN
    v_dept_id := NULL;
  END;

  -- Gestion Service ID (UUID)
  BEGIN
    v_service_id := (new.raw_user_meta_data->>'service_id')::uuid;
  EXCEPTION WHEN OTHERS THEN
    v_service_id := NULL;
  END;

  -- RÈGLES MÉTIER
  IF v_role = 'Enseignant' OR v_role = 'Administratif' THEN
    v_dept_id := NULL; 
  END IF;

  -- INSERTION SÉCURISÉE DANS 'PROFILES'
  INSERT INTO public.profiles (
    id, 
    email, 
    role, 
    nom, 
    telephone, 
    department_id, 
    service_id, 
    niveau,
    created_at
  )
  VALUES (
    new.id, 
    new.email, 
    v_role, 
    v_nom, 
    v_telephone, 
    v_dept_id, 
    v_service_id, 
    v_niveau,
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    nom = EXCLUDED.nom,
    telephone = EXCLUDED.telephone,
    department_id = EXCLUDED.department_id,
    service_id = EXCLUDED.service_id,
    niveau = EXCLUDED.niveau,
    updated_at = NOW();

  RETURN new;
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'Erreur dans handle_new_user pour % : %', new.id, SQLERRM;
  RETURN new;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ==============================================================================
-- 4. SÉCURITÉ (RLS) SIMPLE ET SANS RÉCURSION
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Lecture publique (pas de restriction, donc pas de récursion possible)
CREATE POLICY "Public profiles read access" 
ON public.profiles FOR SELECT 
USING (true);

-- Insertion pour l'utilisateur lui-même (nécessaire pour le client Dart .upsert())
CREATE POLICY "Users can insert their own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Mise à jour pour l'utilisateur lui-même
CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

COMMIT;
