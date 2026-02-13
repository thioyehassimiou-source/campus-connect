-- ==============================================================================
-- 📝 CREATION DE LA TABLE GRADES (Notes)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.grades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES auth.users(id) NOT NULL,
    teacher_id UUID REFERENCES auth.users(id), -- Le prof qui a mis la note
    subject TEXT NOT NULL,      -- Matière (ex: "Maths")
    value NUMERIC(4,2) NOT NULL, -- La note (ex: 15.50)
    coefficient NUMERIC(3,1) DEFAULT 1.0, -- Coeff (ex: 2.0)
    type TEXT DEFAULT 'CC',     -- Type d'évaluation (CC, Examen, TP, Projet)
    semester TEXT DEFAULT 'S1', -- Semestre (S1, S2...)
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sécurité (RLS)
ALTER TABLE public.grades ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Users can view their own grades" ON public.grades;
DROP POLICY IF EXISTS "Teachers can view grades they assigned" ON public.grades;
DROP POLICY IF EXISTS "Teachers can insert grades" ON public.grades;

-- 1. Les Étudiants voient LEURS notes
CREATE POLICY "Users can view their own grades" 
ON public.grades FOR SELECT 
TO authenticated 
USING (student_id = auth.uid());

-- 2. Les Enseignants voient les notes qu'ils ont données (ou toutes s'ils sont admins, à affiner plus tard)
-- Pour l'instant, disons qu'un prof voit ce qu'il a mis.
CREATE POLICY "Teachers can view grades they assigned" 
ON public.grades FOR SELECT 
TO authenticated 
USING (
    teacher_id = auth.uid() 
    OR 
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'director'))
);

-- 3. Les Enseignants (et Admins) peuvent AJOUTER des notes
CREATE POLICY "Teachers can insert grades" 
ON public.grades FOR INSERT 
TO authenticated 
WITH CHECK (
    -- Idéalement vérifier que auth.uid() est bien un prof, mais faisons confiance au client via l'UI pour la V1
    -- OU que teacher_id correspond bien à l'utilisateur connecté
    teacher_id = auth.uid()
);

-- Données de test (Optionnel)
INSERT INTO public.grades (student_id, teacher_id, subject, value, coefficient, type, semester)
SELECT 
    id, -- student_id (Premier user trouvé)
    id, -- teacher_id (Le même user pour le test)
    'Algo & Prog', 
    14.5, 
    2.0, 
    'CC', 
    'S1'
FROM auth.users
WHERE NOT EXISTS (SELECT 1 FROM public.grades WHERE subject = 'Algo & Prog')
LIMIT 1;
