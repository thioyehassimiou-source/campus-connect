-- Add scope columns to major data tables for isolation
-- Tables: announcements, schedules, courses, grades, academic_events

DO $$ 
DECLARE
    cur_table_name TEXT;
    tables_to_update TEXT[] := ARRAY['announcements', 'schedules', 'courses', 'grades', 'academic_calendar'];
BEGIN
    FOREACH cur_table_name IN ARRAY tables_to_update LOOP
        -- More robust existence check using to_regclass
        IF to_regclass(format('public.%I', cur_table_name)) IS NOT NULL THEN
            
            -- Add scope column
            IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = cur_table_name AND column_name = 'scope') THEN
                EXECUTE format('ALTER TABLE public.%I ADD COLUMN scope TEXT DEFAULT %L', cur_table_name, 'university');
            END IF;

            -- Add or convert department_id column
            IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = cur_table_name AND column_name = 'department_id' AND data_type = 'uuid') THEN
                -- If it was accidentally created as UUID, convert it
                EXECUTE format('ALTER TABLE public.%I ALTER COLUMN department_id TYPE INTEGER USING NULL', cur_table_name);
            ELSIF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = cur_table_name AND column_name = 'department_id') THEN
                EXECUTE format('ALTER TABLE public.%I ADD COLUMN department_id INTEGER REFERENCES public.departments(id)', cur_table_name);
            END IF;

            -- Add niveau column
            IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = cur_table_name AND column_name = 'niveau') THEN
                EXECUTE format('ALTER TABLE public.%I ADD COLUMN niveau TEXT', cur_table_name);
            END IF;

            -- Add or convert faculty_id column
            IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = cur_table_name AND column_name = 'faculty_id' AND data_type = 'uuid') THEN
                -- If it was accidentally created as UUID, convert it
                EXECUTE format('ALTER TABLE public.%I ALTER COLUMN faculty_id TYPE INTEGER USING NULL', cur_table_name);
            ELSIF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = 'public' AND table_name = cur_table_name AND column_name = 'faculty_id') THEN
                EXECUTE format('ALTER TABLE public.%I ADD COLUMN faculty_id INTEGER REFERENCES public.faculties(id)', cur_table_name);
            END IF;

            -- Update existing data to be 'university' scope (visible by all)
            EXECUTE format('UPDATE public.%I SET scope = %L WHERE scope IS NULL', cur_table_name, 'university');

        END IF;
    END LOOP;
END $$;

