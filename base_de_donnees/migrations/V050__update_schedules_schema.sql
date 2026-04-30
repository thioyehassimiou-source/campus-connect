-- 🛠️ MISE À JOUR DU SCHÉMA DES EMPLOIS DU TEMPS (CORRIGÉ V2)
-- Ajout des colonnes 'type' et 'teacher_id'.
-- Correction de la gestion du type de la colonne 'status' (TEXT vs INTEGER).

BEGIN;

-- 1. Ajout de la colonne 'type'
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'schedules' AND column_name = 'type') THEN
        ALTER TABLE public.schedules ADD COLUMN type TEXT DEFAULT 'CM';
    END IF;
END $$;

-- 2. Ajout de la colonne 'teacher_id'
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'schedules' AND column_name = 'teacher_id') THEN
        ALTER TABLE public.schedules ADD COLUMN teacher_id UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- 3. Mise à jour des politiques de sécurité (RLS)
-- Suppression des anciennes politiques
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.schedules;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.schedules;
DROP POLICY IF EXISTS "Enable update for teachers" ON public.schedules;
DROP POLICY IF EXISTS "Enable update" ON public.schedules;

-- Re-création des politiques avec CAST SAFE (::text) pour éviter l'erreur "operator does not exist: text = integer"

-- LECTURE : Tout le monde peut voir les cours validés, 
-- les enseignants voient leurs propals.
-- On vérifie status par rapport à '0' (string) ou 'validated' pour être sûr.
CREATE POLICY "Enable read access for authenticated users" 
ON public.schedules FOR SELECT 
TO authenticated 
USING (
    status::text IN ('0', 'validated') -- Validé (gère int et text)
    OR 
    teacher_id = auth.uid() -- Mes propres propositions
    OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'director')) -- Les Admins voient tout
);

-- INSERTION : Les utilisateurs authentifiés peuvent proposer des cours
CREATE POLICY "Enable insert for authenticated users" 
ON public.schedules FOR INSERT 
TO authenticated 
WITH CHECK (true);

-- MISE À JOUR : Admins/Directeurs peuvent changer le statut. 
-- Les enseignants peuvent modifier leurs propals si "En attente" (3).
CREATE POLICY "Enable update" 
ON public.schedules FOR UPDATE
TO authenticated 
USING (
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'director'))
    OR
    (teacher_id = auth.uid() AND status::text IN ('3', 'pending')) -- Modification seulement si en attente
);

COMMIT;
