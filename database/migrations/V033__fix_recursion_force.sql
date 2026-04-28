-- 🧨 NETTOYAGE TOTAL RLS & FIX RÉCURSION (V2 - AGRESSIF)
-- ⚠️ Ce script supprime TOUTES les polices existantes sur 'profiles' pour éliminer la récursion
-- ⚠️ Exécutez ce script dans l'éditeur SQL Supabase

BEGIN;

-- ==============================================================================
-- 1. PURGE RADICALE DES POLITIQUES (Le coupable est ici)
-- ==============================================================================
-- On utilise un bloc DO pour looper sur toutes les policies et les supprimer, 
-- quel que soit leur nom (ce que le script précédent a raté).

DO $$ 
DECLARE 
    pol record; 
BEGIN 
    FOR pol IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'profiles' 
        AND schemaname = 'public' 
    LOOP 
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.profiles', pol.policyname); 
    END LOOP; 
END $$;

-- ==============================================================================
-- 2. RE-APPLIQUER LES SÉCURISATIONS DE BASES (Déjà validées)
-- ==============================================================================

-- Désactive/Réactive RLS pour être sûr
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ✅ PUBLIC: Tout le monde peut voir les profils (Lecture seule) -> Pas de récursion possible
CREATE POLICY "fix_public_read_access" 
ON public.profiles FOR SELECT 
USING (true);

-- ✅ SELF: L'utilisateur peut MODIFIER son propre profil
CREATE POLICY "fix_self_update_access" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- ✅ SELF: L'utilisateur peut CRÉER son propre profil
CREATE POLICY "fix_self_insert_access" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- ==============================================================================
-- 3. RAPPEL DES CORRECTIONS DE CONTRAINTES & TRIGGER (Au cas où)
-- ==============================================================================

-- S'assurer que les colonnes sont bien NULLABLE (important pour l'étape 1 de l'inscription)
ALTER TABLE public.profiles 
  ALTER COLUMN faculty_id DROP NOT NULL,
  ALTER COLUMN department_id DROP NOT NULL,
  ALTER COLUMN service_id DROP NOT NULL,
  ALTER COLUMN filiere_id DROP NOT NULL,
  ALTER COLUMN telephone DROP NOT NULL;

-- On recrée/écrase le trigger pour être sûr d'avoir la bonne version
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
  v_faculty_id bigint;
  v_dept_id bigint;
  v_service_id uuid;
  v_filiere_id bigint;
BEGIN
  -- Safe extraction
  v_role := COALESCE(new.raw_user_meta_data->>'role', 'Étudiant');
  v_first_name := new.raw_user_meta_data->>'first_name';
  v_last_name := new.raw_user_meta_data->>'last_name';
  v_telephone := new.raw_user_meta_data->>'telephone';
  v_niveau := new.raw_user_meta_data->>'niveau';

  -- Full Name Logic
  IF v_first_name IS NOT NULL AND v_last_name IS NOT NULL THEN
    v_full_name := v_first_name || ' ' || v_last_name;
  ELSE
    v_full_name := COALESCE(new.raw_user_meta_data->>'nom', 'Utilisateur');
  END IF;

  -- Safe Casts
  BEGIN v_faculty_id := (new.raw_user_meta_data->>'faculty_id')::bigint; EXCEPTION WHEN OTHERS THEN v_faculty_id := NULL; END;
  BEGIN v_dept_id := (new.raw_user_meta_data->>'department_id')::bigint; EXCEPTION WHEN OTHERS THEN v_dept_id := NULL; END;
  BEGIN v_filiere_id := (new.raw_user_meta_data->>'filiere_id')::bigint; EXCEPTION WHEN OTHERS THEN v_filiere_id := NULL; END;
  BEGIN v_service_id := (new.raw_user_meta_data->>'service_id')::uuid; EXCEPTION WHEN OTHERS THEN v_service_id := NULL; END;

  -- Logic Labé
  IF v_role = 'Enseignant' OR v_role = 'Administratif' THEN
    v_dept_id := NULL;
  END IF;

  INSERT INTO public.profiles (
    id, email, role, nom, telephone, faculty_id, department_id, service_id, filiere_id, niveau, created_at, updated_at
  )
  VALUES (
    new.id, new.email, v_role, v_full_name, v_telephone, v_faculty_id, v_dept_id, v_service_id, v_filiere_id, v_niveau, NOW(), NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    nom = EXCLUDED.nom,
    updated_at = NOW();

  RETURN new;
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'Trigger warning: %', SQLERRM;
  RETURN new;
END;
$$;

COMMIT;
