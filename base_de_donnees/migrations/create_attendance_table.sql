-- ==============================================================================
-- 📅 CREATION DE LA TABLE ATTENDANCE (Assiduité)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.attendance (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES auth.users(id) NOT NULL,
    teacher_id UUID REFERENCES auth.users(id),
    course TEXT NOT NULL,       -- Nom du cours ou ID
    status TEXT NOT NULL,       -- 'present', 'absent', 'late'
    date TIMESTAMPTZ DEFAULT NOW(),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sécurité (RLS)
ALTER TABLE public.attendance ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Étudiants peuvent voir leur propre présence" ON public.attendance;
DROP POLICY IF EXISTS "Enseignants peuvent voir les présences" ON public.attendance;
DROP POLICY IF EXISTS "Enseignants peuvent insérer des présences" ON public.attendance;

-- 1. Les Étudiants voient LEUR historique
CREATE POLICY "Étudiants peuvent voir leur propre présence" 
ON public.attendance FOR SELECT 
TO authenticated 
USING (student_id = auth.uid());

-- 2. Les Enseignants et Admins voient tout (pour statistiques et contrôle)
CREATE POLICY "Enseignants peuvent voir les présences" 
ON public.attendance FOR SELECT 
TO authenticated 
USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin', 'director'))
);

-- 3. Les Enseignants peuvent AJOUTER des présences
CREATE POLICY "Enseignants peuvent insérer des présences" 
ON public.attendance FOR INSERT 
TO authenticated 
WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin', 'director'))
);

-- Données de test (Optionnel)
INSERT INTO public.attendance (student_id, teacher_id, course, status)
SELECT 
    id, -- student_id (Premier user trouvé)
    id, -- teacher_id
    'Mathématiques', 
    'present'
FROM auth.users
WHERE NOT EXISTS (SELECT 1 FROM public.attendance WHERE course = 'Mathématiques')
LIMIT 1;
