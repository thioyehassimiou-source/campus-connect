-- ==============================================================================
-- 📅 CALENDRIER ACADÉMIQUE (ÉVÉNEMENTS & VACANCES)
-- ==============================================================================

-- 1. TABLE DU CALENDRIER
CREATE TABLE IF NOT EXISTS public.academic_calendar (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    date_debut TIMESTAMPTZ NOT NULL,
    date_fin TIMESTAMPTZ, -- Si NULL, événement d'une journée
    type TEXT NOT NULL DEFAULT 'Académique', -- 'Académique', 'Examen', 'Vacances', 'Événement', 'Soutenance', 'Réunion'
    priority TEXT DEFAULT 'Moyenne', -- 'Basse', 'Moyenne', 'Élevée'
    color TEXT DEFAULT '#2563EB', -- Format HEX
    is_recurring BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- SECURITY (RLS)
ALTER TABLE public.academic_calendar ENABLE ROW LEVEL SECURITY;

-- Politiques CALENDAR
CREATE POLICY "Lecture publique du calendrier" 
ON public.academic_calendar FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Admins peuvent gérer le calendrier" 
ON public.academic_calendar FOR ALL 
TO authenticated 
USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('Admin', 'Directeur'))
);

-- DATA SAMPLE (2025)
INSERT INTO public.academic_calendar (title, description, date_debut, date_fin, type, priority, color)
VALUES 
('Début des cours', 'Reprise des cours pour le semestre 1', '2025-01-06 08:00:00+00', NULL, 'Académique', 'Élevée', '#2563EB'),
('Journée d''intégration', 'Accueil des nouveaux étudiants', '2025-01-10 09:00:00+00', NULL, 'Événement', 'Moyenne', '#10B981'),
('Premier partiel', 'Examen partiel de mi-semestre', '2025-02-15 08:00:00+00', NULL, 'Examen', 'Élevée', '#EF4444'),
('Vacances de printemps', 'Congés de printemps', '2025-02-20 00:00:00+00', '2025-03-03 23:59:59+00', 'Vacances', 'Moyenne', '#F59E0B'),
('Soutenance de projets', 'Présentation des projets de fin de semestre', '2025-03-20 08:30:00+00', NULL, 'Soutenance', 'Élevée', '#8B5CF6'),
('Examen final', 'Examen de fin de semestre', '2025-04-10 08:00:00+00', NULL, 'Examen', 'Élevée', '#EF4444'),
('Conseil de classe', 'Réunion du conseil de classe', '2025-04-20 14:00:00+00', NULL, 'Réunion', 'Moyenne', '#06B6D4');
