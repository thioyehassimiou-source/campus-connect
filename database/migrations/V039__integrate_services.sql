-- ==============================================================================
-- 🏛️ INTEGRATION DE L'ORGANISATION INSTITUTIONNELLE
-- ==============================================================================

-- 1. Mettre à jour la table services avec de nouvelles métadonnées
ALTER TABLE public.services 
ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'OTHER', -- GOUVERNANCE, ADMIN, SUPPORT, ACADEMIC, OTHER
ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES public.services(id),
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- 2. Insérer/Mettre à jour les entités de référence (Gouvernance)
-- Ces entités ne sont pas opérationnelles dans l'app (is_active = FALSE ou juste informatif)
INSERT INTO public.services (nom, description, category, is_active) VALUES
('Rectorat', 'Organe exécutif supérieur de l''université', 'GOUVERNANCE', TRUE),
('Vice-rectorats', 'Coordination des activités académiques et de recherche', 'GOUVERNANCE', TRUE),
('Secrétariat général', 'Gestion administrative centrale', 'GOUVERNANCE', TRUE),
('Conseil de l''université', 'Instance de délibération', 'GOUVERNANCE', FALSE) -- Pas d'action directe
ON CONFLICT (nom) DO UPDATE SET 
    category = EXCLUDED.category,
    is_active = EXCLUDED.is_active;

-- Récupérer les IDs pour le chaînage (optionnel, ici on fait simple)

-- 3. Insérer les Services Administratifs Centraux
INSERT INTO public.services (nom, description, category, is_active) VALUES
('Service de la scolarité', 'Gestion centrale des dossiers étudiants', 'ADMIN', TRUE),
('Direction des affaires administratives et financières', 'DAAF - Gestion financière', 'ADMIN', TRUE),
('Agence comptable', 'Comptabilité et paiements', 'ADMIN', TRUE),
('Contrôle financier', 'Audit et vérification', 'ADMIN', TRUE),
('Direction des ressources humaines', 'DRH - Gestion du personnel', 'ADMIN', TRUE),
('Centre des œuvres universitaires', 'CNOU - Social, bourses, restauration', 'ADMIN', TRUE),
('Service technique et maintenance', 'Entretien des infrastructures', 'ADMIN', TRUE),
('Service d''ordre', 'Sécurité du campus', 'ADMIN', TRUE),
('Centre médical universitaire', 'Soins et santé étudiante', 'ADMIN', TRUE)
ON CONFLICT (nom) DO UPDATE SET category = 'ADMIN';

-- 4. Insérer les Services d''Appui Académique
INSERT INTO public.services (nom, description, category, is_active) VALUES
('Bibliothèque Universitaire', 'Documentation et recherche', 'SUPPORT', TRUE), -- Déjà existant, sera mis à jour
('Centre informatique', 'CRI - Infrastructure numérique', 'SUPPORT', TRUE),
('Laboratoires et ateliers', 'Travaux pratiques et recherche', 'SUPPORT', TRUE),
('Éditions universitaires', 'Publications et presses', 'SUPPORT', TRUE)
ON CONFLICT (nom) DO UPDATE SET category = 'SUPPORT';

-- 5. Insérer les Services Académiques Rattachés
-- Note: Les Facultés et Départements sont souvent gérés ailleurs (table campus_blocs ou logic académique),
-- mais ici on les référence comme "Services" pour les permissions.
INSERT INTO public.services (nom, description, category, is_active) VALUES
('Service de la recherche', 'Coordination des activités scientifiques', 'ACADEMIC', TRUE),
('Coopération et relations extérieures', 'Partenariats internationaux', 'ACADEMIC', TRUE),
('Études avancées / post-graduation', 'Masters et Doctorats', 'ACADEMIC', TRUE)
ON CONFLICT (nom) DO UPDATE SET category = 'ACADEMIC';

-- 6. Mise à jour des autres services existants pour avoir une catégorie par défaut
UPDATE public.services SET category = 'OTHER' WHERE category IS NULL;

-- 7. Vérification des permissions (RLS)
-- S'assurer que les nouvelles colonnes sont lisibles
DROP POLICY IF EXISTS "Lecture publique des services" ON public.services;
CREATE POLICY "Lecture publique des services" 
ON public.services FOR SELECT 
TO authenticated 
USING (true);
