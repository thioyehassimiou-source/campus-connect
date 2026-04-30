-- ==============================================================================
-- 📅 CREATION DE LA TABLE SCHEDULES (Emploi du temps)
-- ==============================================================================

-- 1. Création de la table
CREATE TABLE IF NOT EXISTS public.schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    subject TEXT NOT NULL,
    teacher TEXT NOT NULL,
    teacher_id UUID REFERENCES auth.users(id),
    room TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    day INTEGER NOT NULL, -- 0=Lundi, ..., 6=Dimanche (Correspond à DayOfWeek.index)
    type TEXT DEFAULT 'CM', -- CM, TD, TP, Projet, Exam
    color TEXT DEFAULT '#1F77D2',
    status INTEGER DEFAULT 0, -- 0=Scheduled, 1=Cancelled, 2=Moved, 3=Pending, 4=Rejected
    notes TEXT,
    
    -- Filtres Académiques (Pour afficher le bon emploi du temps au bon étudiant)
    department_id BIGINT REFERENCES public.departments(id),
    filiere_id BIGINT,
    niveau TEXT, -- Ex: 'L1', 'L2', 'L3', 'M1', 'M2'
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Sécurité (RLS)
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;

-- Lecture : Tout utilisateur connecté peut voir les emplois du temps
-- (On pourrait affiner pour ne voir que SON département, mais open pour la V1)
CREATE POLICY "Enable read access for authenticated users" 
ON public.schedules FOR SELECT 
TO authenticated 
USING (true);

-- Écriture : Seuls les admins (ou enseignants pour leurs cours) peuvent modifier
-- Pour la V1, on autorise tout user authentifié à insérer (pour faciliter les tests)
-- À RESTREINDRE EN PROD !
CREATE POLICY "Enable insert for authenticated users" 
ON public.schedules FOR INSERT 
TO authenticated 
WITH CHECK (true);

-- 3. Données de Test (Même mock que le code Dart, mais en SQL)
-- On insert des cours pour la semaine courante (ajustez les dates si besoin)

INSERT INTO public.schedules (subject, teacher, room, start_time, end_time, day, color, status, notes, niveau)
VALUES 
-- Lundi
('Mathématiques Appliquées', 'Dr. Ahmed Sow', 'Salle A101', NOW() + INTERVAL '1 day' + INTERVAL '8 hours', NOW() + INTERVAL '1 day' + INTERVAL '9 hours 30 minutes', 0, '#1F77D2', 0, NULL, 'L1'),
('Programmation Dart', 'Prof. Fatou Ndiaye', 'Labo B205', NOW() + INTERVAL '1 day' + INTERVAL '10 hours', NOW() + INTERVAL '1 day' + INTERVAL '12 hours', 0, '#FF6B35', 0, NULL, 'L1'),

-- Mardi
('Bases de Données', 'Dr. Jean Dupont', 'Salle A205', NOW() + INTERVAL '2 day' + INTERVAL '9 hours', NOW() + INTERVAL '2 day' + INTERVAL '10 hours 30 minutes', 1, '#9B59B6', 0, NULL, 'L1'),

-- Mercredi
('Architecture Logicielle', 'Prof. Sall Ousmane', 'Salle A102', NOW() + INTERVAL '3 day' + INTERVAL '8 hours 30 minutes', NOW() + INTERVAL '3 day' + INTERVAL '10 hours', 2, '#E74C3C', 0, NULL, 'L1'),

-- Jeudi
('Séminaire Sécurité', 'Dr. Moussa Kone', 'Amphi D002', NOW() + INTERVAL '4 day' + INTERVAL '9 hours', NOW() + INTERVAL '4 day' + INTERVAL '11 hours', 3, '#E74C3C', 0, NULL, 'L1'),

-- Vendredi
('Systèmes d''exploitation', 'Dr. Ahmed Sow', 'Salle A303', NOW() + INTERVAL '5 day' + INTERVAL '8 hours', NOW() + INTERVAL '5 day' + INTERVAL '9 hours 30 minutes', 4, '#9B59B6', 0, NULL, 'L1');
