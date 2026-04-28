-- 🛠️ SCRIPT DE RÉPARATION FINALE DU SCHEMA
-- 🎯 Objectifs : Fixer les colonnes manquantes, les relations et la compatibilité des noms.

BEGIN;

-- 1. RÉPARATION DES ANNONCES (Vérifier que les colonnes de scope sont là)
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS scope TEXT DEFAULT 'university';
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS department_id INTEGER REFERENCES public.departments(id);
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS niveau TEXT;
ALTER TABLE public.announcements ADD COLUMN IF NOT EXISTS faculty_id INTEGER REFERENCES public.faculties(id);

-- 2. COMPATIBILITÉ DES PROFILS ( full_name vs nom )
-- La table profiles utilise 'nom', mais le code s'attend parfois à 'full_name'
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
UPDATE public.profiles SET full_name = nom WHERE full_name IS NULL;

-- 3. RÉPARATION DES PRÉSENCES (ATTENDANCE)
-- On nettoie d'abord les données orphelines (étudiants dans attendance qui n'ont pas de profil)
-- Sinon la contrainte de clé étrangère échouera.
DELETE FROM public.attendance 
WHERE student_id NOT IN (SELECT id FROM public.profiles);

-- Pour que le join 'profiles(...)' fonctionne, il faut une FK directe vers public.profiles
ALTER TABLE public.attendance DROP CONSTRAINT IF EXISTS attendance_student_id_fkey;
ALTER TABLE public.attendance 
  ADD CONSTRAINT attendance_student_id_fkey 
  FOREIGN KEY (student_id) REFERENCES public.profiles(id)
  ON DELETE CASCADE;

-- 4. VÉRIFICATION GÉNÉRALE DES AUTRES TABLES (Scope Isolation)
DO $$ 
DECLARE
    cur_table TEXT;
    tables_to_fix TEXT[] := ARRAY['schedules', 'courses', 'grades', 'academic_calendar'];
BEGIN
    FOREACH cur_table IN ARRAY tables_to_fix LOOP
        IF to_regclass(format('public.%I', cur_table)) IS NOT NULL THEN
            EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS scope TEXT DEFAULT %L', cur_table, 'university');
            EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS department_id INTEGER REFERENCES public.departments(id)', cur_table);
            EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS niveau TEXT', cur_table);
            EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS faculty_id INTEGER REFERENCES public.faculties(id)', cur_table);
            EXECUTE format('UPDATE public.%I SET scope = %L WHERE scope IS NULL', cur_table, 'university');
        END IF;
    END LOOP;
END $$;

-- 5. RELOAD SCHEMA CACHE HACK
COMMENT ON TABLE public.announcements IS 'Table for university announcements with academic scope isolation';
COMMENT ON TABLE public.attendance IS 'Table for student attendance records';

COMMIT;
