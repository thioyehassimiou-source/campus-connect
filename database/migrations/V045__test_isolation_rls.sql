-- 🧪 DIAGNOSTIC DE L'ISOLATION ACADÉMIQUE (RLS)
-- Ce script simule différents profils pour vérifier ce qu'ils voient.

-- 1. CRÉATION DE DONNÉES DE TEST SI NÉCESSAIRE (Optionnel)
-- Vous pouvez insérer des données avec différents périmètres pour tester.
-- INSERT INTO public.announcements (title, content, category, scope, department_id) 
-- VALUES ('Annonce Informatique', 'Contenu...', 'Académique', 'department', 1); -- Supposons Dept 1 = Informatique

-- 2. SIMULATION D'UN ÉTUDIANT (DÉPARTEMENT 1, L1)
-- Copiez-collez ce bloc complet dans l'éditeur SQL Supabase
DO $$
BEGIN
    -- Simuler l'ID d'un utilisateur imaginaire (ou remplacez par un vrai ID de auth.users)
    SET LOCAL "request.jwt.claims" = '{"sub": "00000000-0000-0000-0000-000000000001"}';
    
    -- On doit s'assurer qu'un profil existe pour cet ID dans la simu
    -- Ici, on va juste faire un SELECT et observer le résultat filtré.
    -- NOTE: En vrai SQL Editor, RLS s'applique si vous n'êtes pas superuser.
    -- Pour tester REELLEMENT le RLS, il faut utiliser un utilisateur non-admin.
END $$;

### 1. Test via l'Application (Le plus concret)
1. **Compte A (Enseignant Dept Informatique)** : Connectez-vous et créez une annonce pour "Ma Licence" (L1 Informatique).
2. **Compte B (Étudiant Dept Informatique L1)** : Connectez-vous. Il **doit** voir l'annonce.
3. **Compte C (Étudiant Dept Droit L1)** : Connectez-vous. Il **ne doit pas** voir l'annonce du Compte A.
4. **Action Interdite** : Tentez de créer une annonce avec un compte Étudiant (le bouton "Ajouter" devrait soit être masqué, soit l'action devrait échouer au niveau de Supabase).

-- Voir les emplois du temps
SELECT subject, department_id, niveau 
FROM public.schedules;

-- Voir les cours
SELECT name, department_id 
FROM public.courses;

-- NOTE : Pour tester vraiment les performances des politiques :
-- EXPLAIN ANALYZE SELECT * FROM public.announcements;
