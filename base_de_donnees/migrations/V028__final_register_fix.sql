-- 🛠️ CORRECTION COMPLÈTE ET DÉFINITIVE DE L'INSCRIPTION
-- 🎯 OBJECTIF : Harmoniser la base de données avec le code Flutter (SupabaseAuthService)
-- ⚠️ À EXÉCUTER DANS L'ÉDITEUR SQL SUPABASE (Copier/Coller et Run)

BEGIN;

-- ==============================================================================
-- 1. NETTOYAGE DES ANCIENS MÉCANISMES (Triggers & Fonctions)
-- ==============================================================================
-- Le code Flutter crée maintenant le profil manuellement. 
-- Il faut donc SUPPRIMER tout automatisme backend qui pourrait entrer en conflit.

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_user_setup() CASCADE;

-- ==============================================================================
-- 2. ADAPTATION DE LA STRUCTURE (Tables)
-- ==============================================================================
-- S'assurer que les champs optionnels sont bien acceptés (NULL)
-- Cela évite les erreurs si jamais un champ manque lors de l'inscription

ALTER TABLE public.profiles 
  ALTER COLUMN faculty_id DROP NOT NULL,
  ALTER COLUMN department_id DROP NOT NULL,
  ALTER COLUMN service_id DROP NOT NULL,
  ALTER COLUMN filiere_id DROP NOT NULL,
  ALTER COLUMN telephone DROP NOT NULL;

-- S'assurer que le champ 'role' existe et est text (au cas où)
-- ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role text;

-- ==============================================================================
-- 3. GESTION DES PERMISSIONS (RLS)
-- ==============================================================================
-- On remet à plat les politiques pour être SÛR que l'app peut écrire.

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3.1. Supprimer TOUTES les anciennes politiques pour partir propre
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT policyname FROM pg_policies WHERE tablename = 'profiles' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.profiles', r.policyname);
    END LOOP;
END $$;

-- 3.2. Lecture pour tous (nécessaire pour afficher les profils, login, etc.)
CREATE POLICY "Public profiles read access" 
ON public.profiles FOR SELECT 
USING (true);

-- 3.3. CRÉATION (INSERT) pour soi-même
-- C'est CETTE politique qui permet à 'SupabaseAuthService.registerWithEmailAndPassword' 
-- de créer le profil après le signUp.
CREATE POLICY "Users can insert their own profile" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- 3.4. MODIFICATION (UPDATE) pour soi-même
-- Permet à l'utilisateur de modifier ses infos plus tard (ou upsert)
CREATE POLICY "Users can update their own profile" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- Allow service_role to do everything (admin access via dashboard etc)
-- (Implicitly true normally but explicit policies don't hurt if we added a restrict all)

-- ==============================================================================
-- 4. CONFIRMATION
-- ==============================================================================

COMMIT;
