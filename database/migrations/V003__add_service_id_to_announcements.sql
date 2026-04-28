-- ==============================================================================
-- 📢 AJOUT DU LIEN ENTRE ANNONCES ET SERVICES
-- ==============================================================================

-- 1. Ajouter la colonne service_id à la table announcements
ALTER TABLE public.announcements 
ADD COLUMN IF NOT EXISTS service_id UUID REFERENCES public.services(id);

-- 2. Mettre à jour les politiques RLS pour permettre aux membres d'un service de publier
-- On suppose que le profil utilisateur a un champ 'service_id' (ajouté précédemment)

DROP POLICY IF EXISTS "Service members can insert announcements" ON public.announcements;
CREATE POLICY "Service members can insert announcements" ON public.announcements
    FOR INSERT To authenticated 
    WITH CHECK (
        -- L'utilisateur doit être membre du service pour lequel il publie
        (service_id IS NOT NULL AND service_id = (SELECT service_id FROM public.profiles WHERE id = auth.uid()))
        OR
        -- OU c'est un admin/enseignant (cas général existant)
        (public.get_user_role() IN ('Enseignant', 'Administrateur') AND service_id IS NULL)
    );

-- 3. Politique de lecture : tout le monde peut voir les annonces de service
DROP POLICY IF EXISTS "Public announcements including services" ON public.announcements;
CREATE POLICY "Public announcements including services" ON public.announcements
    FOR SELECT TO authenticated
    USING (true);
