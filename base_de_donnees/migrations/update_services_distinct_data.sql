-- ==============================================================================
-- 🛠️ MISE À JOUR DES DONNÉES DE SERVICES (DONNÉES RÉELLES UNIV LABÉ)
-- ==============================================================================

-- 1. Rectorat
UPDATE public.services 
SET 
    localisation = 'Campus Hafia, Bâtiment Administratif',
    horaires = 'Lun-Jeu: 9h00 - 17h00, Ven-Sam: 9h00 - 12h00',
    email = 'contact@univ-labe.edu.gn',
    telephone = '+224 629 00 58 07',
    site_web = 'https://univ-labe.edu.gn'
WHERE nom = 'Rectorat';

-- 2. Vice-rectorats
UPDATE public.services 
SET 
    localisation = 'Campus Hafia, Aile Académique',
    horaires = 'Lun-Jeu: 9h00 - 16h30, Ven: 9h00 - 12h00',
    email = 'vr-etudes@univ-labe.edu.gn'
WHERE nom = 'Vice-rectorats';

-- 3. Secrétariat général
UPDATE public.services 
SET 
    localisation = 'Campus Hafia, Administration Centrale',
    horaires = 'Lun-Jeu: 8h30 - 17h00',
    email = 'sg@univ-labe.edu.gn',
    telephone = '+224 629 00 58 07'
WHERE nom = 'Secrétariat général';

-- 4. Service de la scolarité
UPDATE public.services 
SET 
    localisation = 'Campus Hafia, Bloc Pédagogique',
    horaires = 'Lun-Jeu: 9h00 - 16h00; Ven: 9h00 - 12h00',
    email = 'scolarite@univ-labe.edu.gn',
    description = 'Gestion des inscriptions, cartes d''étudiants, relevés de notes et diplômes.'
WHERE nom = 'Service de la scolarité' OR nom = 'Scolarité';

-- 5. Centre médical universitaire
UPDATE public.services 
SET 
    localisation = 'Campus Hafia, Près des résidences',
    horaires = '24h/24, 7j/7 (Urgences)',
    email = 'infirmerie@univ-labe.edu.gn',
    description = 'Consultations médicales et soins de premiers secours pour étudiants et personnel.'
WHERE nom = 'Centre médical universitaire' OR nom LIKE '%Sant%';

-- 6. Bibliothèque Universitaire
UPDATE public.services 
SET 
    localisation = 'Campus Hafia, Bâtiment Central',
    horaires = 'Lun-Sam: 8h00 - 18h00',
    email = 'bibliotheque@univ-labe.edu.gn',
    site_web = 'https://univ-labe.edu.gn/bibliotheque'
WHERE nom = 'Bibliothèque Universitaire';

-- 7. Service Informatique (CRI)
UPDATE public.services 
SET 
    localisation = 'Campus Hafia, Bloc Informatique',
    horaires = 'Lun-Ven: 9h00 - 17h00',
    email = 'informatique@univ-labe.edu.gn'
WHERE nom = 'Service Informatique / IT' OR nom LIKE '%Informatique%';

-- Annonces "officielles" basées sur le contexte réel
-- CORRECTION : Utilisation de catégories valides ('Administratif', 'Académique', 'Vie Étudiante', 'Toutes')
DO $$
DECLARE
    v_rectorat_id UUID;
    v_scolarite_id UUID;
BEGIN
    SELECT id INTO v_rectorat_id FROM public.services WHERE nom = 'Rectorat';
    SELECT id INTO v_scolarite_id FROM public.services WHERE nom = 'Service de la scolarité';

    IF v_rectorat_id IS NOT NULL THEN
        INSERT INTO public.announcements (title, content, category, priority, service_id, author)
        VALUES 
        ('Bienvenue sur CampusConnect', 'L''Université de Labé est fière de lancer sa nouvelle plateforme numérique pour faciliter la vie étudiante.', 'Administratif', 'Haute', v_rectorat_id, 'Le Recteur');
    END IF;

    IF v_scolarite_id IS NOT NULL THEN
        INSERT INTO public.announcements (title, content, category, priority, service_id, author)
        VALUES 
        ('Réinscriptions Année 2024-2025', 'Les réinscriptions sont ouvertes au service de scolarité du Hafia. Date limite : 30 Octobre.', 'Administratif', 'Moyenne', v_scolarite_id, 'Chef Scolarité');
    END IF;
END $$;
