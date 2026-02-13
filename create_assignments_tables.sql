-- ==============================================================================
-- 📝 GESTION DES DEVOIRS (ASSIGNMENTS & SUBMISSIONS)
-- ==============================================================================

-- 1. TABLE DES DEVOIRS (ASSIGNMENTS)
CREATE TABLE IF NOT EXISTS public.assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    course TEXT NOT NULL, -- Matière
    teacher_id UUID REFERENCES auth.users(id),
    teacher_name TEXT DEFAULT 'Professeur',
    due_date TIMESTAMPTZ NOT NULL,
    priority TEXT DEFAULT 'medium', -- 'low', 'medium', 'high'
    type TEXT DEFAULT 'Devoir', -- 'Devoir', 'Projet', 'TP'
    max_grade NUMERIC DEFAULT 20.0,
    attachments TEXT[] DEFAULT '{}', -- Liste URL fichiers jointes (V2)
    max_submissions INTEGER DEFAULT 45, -- Pour info statique ou limite
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABLE DES SOUMISSIONS (SUBMISSIONS)
CREATE TABLE IF NOT EXISTS public.submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    assignment_id UUID REFERENCES public.assignments(id) ON DELETE CASCADE,
    student_id UUID REFERENCES auth.users(id),
    content TEXT, -- Texte ou URL vers le travail rendu
    status TEXT DEFAULT 'submitted', -- 'submitted', 'graded', 'pending'
    grade NUMERIC, -- Note attribuée par le prof
    feedback TEXT, -- Commentaire du prof
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(assignment_id, student_id) -- Un étudiant ne rend qu'un travail par devoir
);

-- SECURITY (RLS)
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;

-- Politiques ASSIGNMENTS
CREATE POLICY "Lecture publique des devoirs" 
ON public.assignments FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Enseignants gèrent leurs devoirs" 
ON public.assignments FOR ALL 
TO authenticated 
USING (
    teacher_id = auth.uid() 
    OR 
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('Admin', 'Directeur'))
);

-- Politiques SUBMISSIONS
CREATE POLICY "Étudiants voient leurs soumissions" 
ON public.submissions FOR SELECT 
TO authenticated 
USING (student_id = auth.uid());

CREATE POLICY "Enseignants voient toutes les soumissions" 
ON public.submissions FOR SELECT 
TO authenticated 
USING (
    EXISTS (
        SELECT 1 FROM public.assignments 
        WHERE id = public.submissions.assignment_id 
        AND teacher_id = auth.uid()
    )
    OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('Admin', 'Directeur'))
);

CREATE POLICY "Étudiants soumettent leur travail" 
ON public.submissions FOR INSERT 
TO authenticated 
WITH CHECK (student_id = auth.uid());

CREATE POLICY "Enseignants notent les travaux" 
ON public.submissions FOR UPDATE 
TO authenticated 
USING (
    EXISTS (
        SELECT 1 FROM public.assignments 
        WHERE id = public.submissions.assignment_id 
        AND teacher_id = auth.uid()
    )
);

-- DATA SAMPLE
INSERT INTO public.assignments (title, description, course, due_date, priority, type)
VALUES 
('Analyse des algorithmes tri', 'Comparez la complexité du Tri Fusion et du QuickSort.', 'Algorithmique', '2025-02-15 23:59:59+00', 'high', 'TP'),
('Projet Flutter Mobile', 'Application de gestion de tâches avec Supabase.', 'Développement Mobile', '2025-03-01 23:59:59+00', 'medium', 'Projet'),
('Dissertation : Philo Moderne', 'L''impact de l''IA sur la conscience humaine.', 'Philosophie', '2025-02-20 18:00:00+00', 'medium', 'Devoir');
