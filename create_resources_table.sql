-- ==============================================================================
-- 📚 CRÉATION DE LA TABLE RESOURCES (Documents Pédagogiques)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.resources (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    url TEXT NOT NULL,           -- URL public du fichier (Supabase Storage)
    type TEXT DEFAULT 'PDF',     -- 'PDF', 'DOC', 'PPT', 'XLS', 'LINK'
    subject TEXT NOT NULL,       -- Matière (ex: 'Mathématiques')
    author_id UUID REFERENCES auth.users(id),
    author_name TEXT,            -- Cache du nom de l'auteur
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sécurité (RLS)
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;

-- 1. Tout le monde peut LIRE les documents
DROP POLICY IF EXISTS "Lecture publique des ressources" ON public.resources;
CREATE POLICY "Lecture publique des ressources" 
ON public.resources FOR SELECT 
TO authenticated 
USING (true);

-- 2. Seuls les Enseignants et Admins peuvent AJOUTER des documents
DROP POLICY IF EXISTS "Staff peut ajouter des ressources" ON public.resources;
CREATE POLICY "Staff peut ajouter des ressources" 
ON public.resources FOR INSERT 
TO authenticated 
WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('teacher', 'admin', 'director'))
);

-- 3. Seul l'auteur ou l'admin peut SUPPRIMER
DROP POLICY IF EXISTS "Auteur peut supprimer ses ressources" ON public.resources;
CREATE POLICY "Auteur peut supprimer ses ressources" 
ON public.resources FOR DELETE 
TO authenticated 
USING (
    auth.uid() = author_id OR 
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'director'))
);

-- NOTE : N'oubliez pas de créer un bucket nommé 'resources' dans Supabase Storage 
-- et de le rendre public (ou d'ajouter des politiques de stockage).
