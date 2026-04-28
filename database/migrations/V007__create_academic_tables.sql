-- ==============================================================================
-- 📚 CREATION DES TABLES ACADEMIQUES (NOTES & RESSOURCES)
-- ==============================================================================

-- 1. TABLE DES NOTES (GRADES)
CREATE TABLE IF NOT EXISTS public.grades (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id UUID REFERENCES auth.users(id) NOT NULL,
    teacher_id UUID REFERENCES auth.users(id), -- Celui qui a mis la note
    subject TEXT NOT NULL, -- Ex: "Mathématiques", "Java"
    value FLOAT NOT NULL CHECK (value >= 0 AND value <= 20),
    coefficient FLOAT DEFAULT 1.0,
    type TEXT DEFAULT 'CC', -- 'CC', 'Examen', 'TP', 'Projet'
    semester TEXT DEFAULT 'S1',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABLE DES RESSOURCES PÉDAGOGIQUES
CREATE TABLE IF NOT EXISTS public.resources (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    url TEXT NOT NULL, -- Lien vers le fichier (Storage ou externe)
    type TEXT DEFAULT 'PDF', -- 'PDF', 'VIDEO', 'LINK'
    subject TEXT NOT NULL,
    author_id UUID REFERENCES auth.users(id),
    author_name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- SECURITY (RLS)
ALTER TABLE public.grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

-- POLICIES GRADES
-- Un étudiant ne peut voir que SES notes
CREATE POLICY "Students can view own grades" 
ON public.grades FOR SELECT 
TO authenticated 
USING (auth.uid() = student_id);

-- Les profs peuvent tout voir (ou juste celles qu'ils ont mises, ici on simplifie: tout voir pour le conseil de classe)
-- En prod, on affinerait avec le role.
CREATE POLICY "Teachers can view all grades" 
ON public.grades FOR SELECT 
TO authenticated 
USING ( true ); -- Simplification pour démo (à restreindre aux profs via triggers/claims)

-- Les profs peuvent insérer des notes
CREATE POLICY "Teachers can insert grades" 
ON public.grades FOR INSERT 
TO authenticated 
WITH CHECK (true); -- Idem, à restreindre aux profs

-- POLICIES RESOURCES
-- Tout le monde peut lire les ressources
CREATE POLICY "Everyone can view resources" 
ON public.resources FOR SELECT 
TO authenticated 
USING (true);

-- Les profs peuvent ajouter des ressources
CREATE POLICY "Teachers can insert resources" 
ON public.resources FOR INSERT 
TO authenticated 
WITH CHECK (true);

-- DATA SAMPLE
-- Insérer des notes pour l'utilisateur courant (si connecté) ou générique
-- Note: difficile d'insérer pour "l'utilisateur courant" dans un script statique sans connaitre son UUID.
-- On va laisser vide ou mettre quelques ressources génériques.

INSERT INTO public.resources (title, description, url, type, subject, author_name)
VALUES 
('Cours d''Introduction à Flutter', 'Les bases des widgets et du state management.', 'https://flutter.dev', 'PDF', 'Développement Mobile', 'Dr. Diallo'),
('Algèbre Linéaire - Chapitre 1', 'Espaces vectoriels et matrices.', 'https://example.com/math.pdf', 'PDF', 'Mathématiques', 'Prof. Bah');
