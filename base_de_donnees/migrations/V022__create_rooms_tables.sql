-- ==============================================================================
-- 🏫 GESTION DES INFRASTRUCTURES (SALLES & RÉSERVATIONS)
-- ==============================================================================

-- 1. TABLE DES SALLES
CREATE TABLE IF NOT EXISTS public.rooms (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nom TEXT NOT NULL UNIQUE,
    bloc TEXT NOT NULL, -- Ex: 'Bloc A', 'Bloc B', 'Laboratoires'
    capacite INTEGER DEFAULT 30,
    type TEXT DEFAULT 'Cours', -- 'Cours', 'Laboratoire', 'Amphithéâtre', 'Bureau'
    equipements TEXT[], -- ['Wi-Fi', 'Vidéoprojecteur', 'Climatisation']
    statut TEXT DEFAULT 'Disponible', -- 'Disponible', 'Maintenance', 'Occupé'
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TABLE DES RÉSERVATIONS
CREATE TABLE IF NOT EXISTS public.room_bookings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_id UUID REFERENCES public.rooms(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) NOT NULL,
    user_name TEXT, -- Cache pour éviter des joins complexes
    motif TEXT NOT NULL,
    date_evenement DATE NOT NULL,
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    statut TEXT DEFAULT 'En attente', -- 'En attente', 'Approuvé', 'Rejeté'
    commentaire_admin TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- SECURITY (RLS)
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_bookings ENABLE ROW LEVEL SECURITY;

-- Politiques ROOMS
CREATE POLICY "Lecture publique des salles" 
ON public.rooms FOR SELECT 
TO authenticated 
USING (true);

CREATE POLICY "Admins peuvent gérer les salles" 
ON public.rooms FOR ALL 
TO authenticated 
USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('Admin', 'Directeur'))
);

-- Politiques BOOKINGS
CREATE POLICY "Utilisateurs voient leurs réservations" 
ON public.room_bookings FOR SELECT 
TO authenticated 
USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('Admin', 'Directeur')));

CREATE POLICY "Enseignants et Admins peuvent réserver" 
ON public.room_bookings FOR INSERT 
TO authenticated 
WITH CHECK (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('Enseignant', 'Admin', 'Directeur'))
);

-- DATA SAMPLE
INSERT INTO public.rooms (nom, bloc, capacite, type, equipements)
VALUES 
('A101', 'Bloc A', 50, 'Cours', ARRAY['Vidéoprojecteur', 'Tableau Blanc']),
('A102', 'Bloc A', 45, 'Cours', ARRAY['Vidéoprojecteur']),
('B205', 'Bloc B', 30, 'Laboratoire', ARRAY['Ordinateurs', 'Wi-Fi']),
('C301', 'Bloc C', 150, 'Amphithéâtre', ARRAY['Sono', 'Vidéoprojecteur', 'Climatisation']),
('L_INFO_1', 'Laboratoires', 25, 'Laboratoire', ARRAY['Ordinateurs', 'Wi-Fi', 'Climatisation']);
