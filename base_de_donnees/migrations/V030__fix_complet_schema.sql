-- 1. Table des Calendriers Académiques
CREATE TABLE IF NOT EXISTS public.academic_calendar (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    type TEXT NOT NULL DEFAULT 'event', -- event, holiday, exam
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Table des Devoirs (Assignments)
CREATE TABLE IF NOT EXISTS public.assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    course TEXT NOT NULL,
    description TEXT NOT NULL,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    priority TEXT NOT NULL DEFAULT 'medium',
    type TEXT NOT NULL DEFAULT 'Devoir',
    teacher_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    teacher_name TEXT NOT NULL,
    attachments JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Table des Soumissions (Submissions)
CREATE TABLE IF NOT EXISTS public.submissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    assignment_id UUID REFERENCES public.assignments(id) ON DELETE CASCADE,
    student_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'submitted', -- submitted, graded
    grade DOUBLE PRECISION,
    feedback TEXT,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(assignment_id, student_id)
);

-- 4. Extensions de la table Profiles
-- Note: On utilise 'nom' comme colonne principale de nom pour la compatibilité
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='competences') THEN
        ALTER TABLE public.profiles ADD COLUMN competences JSONB DEFAULT '[]'::jsonb;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='profiles' AND column_name='office_hours') THEN
        ALTER TABLE public.profiles ADD COLUMN office_hours JSONB DEFAULT '{}'::jsonb;
    END IF;
END $$;

-- 5. RLS Policies
ALTER TABLE public.academic_calendar ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;

-- Politiques Calendrier
DROP POLICY IF EXISTS "Tout le monde peut voir le calendrier" ON public.academic_calendar;
CREATE POLICY "Tout le monde peut voir le calendrier" ON public.academic_calendar FOR SELECT USING (true);

-- Politiques Devoirs
DROP POLICY IF EXISTS "Tout le monde peut voir les devoirs" ON public.assignments;
CREATE POLICY "Tout le monde peut voir les devoirs" ON public.assignments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Les enseignants peuvent gérer leurs devoirs" ON public.assignments;
CREATE POLICY "Les enseignants peuvent gérer leurs devoirs" ON public.assignments 
FOR ALL USING (auth.uid() = teacher_id);

-- Politiques Soumissions
DROP POLICY IF EXISTS "Les étudiants voient leurs soumissions" ON public.submissions;
CREATE POLICY "Les étudiants voient leurs soumissions" ON public.submissions 
FOR SELECT USING (auth.uid() = student_id);

DROP POLICY IF EXISTS "Les enseignants voient toutes les soumissions" ON public.submissions;
CREATE POLICY "Les enseignants voient toutes les soumissions" ON public.submissions 
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.assignments 
        WHERE assignments.id = submissions.assignment_id 
        AND assignments.teacher_id = auth.uid()
    )
);

DROP POLICY IF EXISTS "Les étudiants peuvent soumettre" ON public.submissions;
CREATE POLICY "Les étudiants peuvent soumettre" ON public.submissions 
FOR INSERT WITH CHECK (auth.uid() = student_id);
