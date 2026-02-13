-- Create a function to check user role for cleaner RLS policies
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Update RLS policies for automatic scope filtering
-- This script provides a generic template for the data tables.

DO $$ 
DECLARE
    cur_t_name TEXT;
    tables_to_secure TEXT[] := ARRAY['announcements', 'schedules', 'courses', 'grades', 'academic_calendar'];
BEGIN
    FOREACH cur_t_name IN ARRAY tables_to_secure LOOP
        
        -- Robust Existence Check
        IF to_regclass(format('public.%I', cur_t_name)) IS NOT NULL THEN
            -- 1. Remove existing public select policies if they exist (to replace with scope-aware ones)
            
            -- 2. Add Scope-Aware Policy for SELECT
            EXECUTE format('
                DO $policy$ BEGIN
                    DROP POLICY IF EXISTS "Automatic scope isolation for %I" ON public.%I;
                    CREATE POLICY "Automatic scope isolation for %I" ON public.%I
                    FOR SELECT USING (
                        public.get_user_role() = %L -- Admins see everything
                        OR
                        scope = %L -- University wide
                        OR
                        (scope = %L AND (faculty_id::INTEGER) = (SELECT faculty_id::INTEGER FROM public.profiles WHERE id = auth.uid())) -- Faculty scope
                        OR
                        (scope = %L AND (department_id::INTEGER) = (SELECT department_id::INTEGER FROM public.profiles WHERE id = auth.uid())) -- Department scope
                        OR
                        (scope = %L -- License scope
                         AND (department_id::INTEGER) = (SELECT department_id::INTEGER FROM public.profiles WHERE id = auth.uid())
                         AND (niveau::TEXT) = (SELECT niveau::TEXT FROM public.profiles WHERE id = auth.uid()))
                        OR
                        -- Teachers see their assignments
                        (public.get_user_role() = %L AND (
                            EXISTS (
                                SELECT 1 FROM public.teacher_assignments ta
                                WHERE ta.teacher_id = auth.uid()
                                AND (ta.department_id::INTEGER = public.%I.department_id::INTEGER OR ta.department_id IS NULL)
                                AND (ta.niveau::TEXT = public.%I.niveau::TEXT OR ta.niveau IS NULL OR public.%I.niveau IS NULL)
                            )
                        ))
                    );
                EXCEPTION WHEN duplicate_object THEN NULL;
                END $policy$;
            ', cur_t_name, cur_t_name, cur_t_name, cur_t_name, 'Administrateur', 'university', 'faculty', 'department', 'license', 'Enseignant', cur_t_name, cur_t_name, cur_t_name);
        END IF;
    END LOOP;
END $$;
