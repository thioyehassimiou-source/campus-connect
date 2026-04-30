# 🎯 GUIDE D'EXÉCUTION - Nettoyage Monorepo CampusConnect

## ⚠️ LECTURE OBLIGATOIRE AVANT D'EXÉCUTER

Ce document contient les **commandes exactes** pour restructurer votre dépôt CampusConnect de manière sûre et reproductible.

---

## 📋 PRÉREQUIS

```bash
# 1. Vous êtes dans le répertoire racine du projet
pwd
# → /home/thioye/CampusConnect/mobile

# 2. Git est propre (pas de changements non-committés)
git status
# → nothing to commit, working tree clean

# 3. Vous êtes sur la branche main
git branch
# → * main

# 4. Vous avez les derniers changements
git pull origin main
```

**Si l'une de ces conditions n'est pas remplie, voir le chapitre "RÉSOUDRE PROBLÈMES COMMUNS" en fin**

---

## 🚀 EXÉCUTION PAS À PAS

### OPTION A: SCRIPT AUTOMATISÉ (Recommandé)

#### Étape 1: Mode Dry-Run (SANS RISQUE)
```bash
cd /home/thioye/CampusConnect/mobile

# Exécuter en mode dry-run pour voir ce qui va se passer
bash cleanup_monorepo.sh --dry-run
```

**Sortie attendue:**
```
ℹ Répertoire correct identifié
✓ Vérifications git réussies
ℹ Création d'un backup local...
ℹ [DRY_RUN] Backup aurait créé: campusconnect.backup.1745347200.tar.gz
...
```

✅ Si tout semble bon → **Étape 2**

❌ Si erreurs → **voir "RÉSOUDRE PROBLÈMES COMMUNS"**

---

#### Étape 2: Exécution Réelle
```bash
# Lancer le script sans flag dry-run
bash cleanup_monorepo.sh
```

**Sortie attendue:**
```
═══════════════════════════════════════════════════════
  PHASE 0: VÉRIFICATIONS PRÉALABLES
═══════════════════════════════════════════════════════
ℹ Répertoire correct identifié
...
✓ Backup créé: campusconnect.backup.1745347200.tar.gz
✓ Branche créée: refactor/monorepo-cleanup-20260428
✓ Dossier .archive/ créé
✓ auth/ archivé
...
✓ Changements committés
✓ VALIDATION COMPLÈTE
```

---

#### Étape 3: Valider Résultats Locaux
```bash
# Vérifier la branche de travail
git branch
# → * refactor/monorepo-cleanup-20260428
#     main

# Voir les changements commitées
git log --oneline -5
# → abc1234 refactor(monorepo): cleanup and restructure...
# → b8e1026 test(admin): add dashboard widget tests
# ...

# Vérifier structure
tree -L 2 -I '.dart_tool|.git|build|node_modules' | head -40

# Vérifier aucun fichier n'a disparu critiquement
ls -la lib/main.dart backend/bin/server.dart
```

---

#### Étape 4: Push vers GitHub
```bash
# Pousser la branche
git push -u origin refactor/monorepo-cleanup-20260428

# Afficher l'URL pour créer PR
echo "Créer PR: https://github.com/[votre-repo]/compare/main...refactor/monorepo-cleanup-20260428"
```

---

#### Étape 5: Créer Pull Request sur GitHub

1. Aller sur: https://github.com/thioye/CampusConnect/pulls
2. Cliquer "New Pull Request"
3. Sélectionner:
   - **base**: `main`
   - **compare**: `refactor/monorepo-cleanup-20260428`
4. Titre: "refactor: cleanup monorepo structure"
5. Description:
   ```markdown
   ## Description
   Restructuration architecturale du monorepo selon standards senior.
   
   ## Changements
   - ✅ Suppression frontends dupliqués (frontend/, professional/)
   - ✅ Archivage module legacy (auth/ → .archive/)
   - ✅ Réorganisation migrations DB (*.sql → database/migrations/)
   - ✅ Archivage artefacts design (stitch → docs/design-reference/)
   - ✅ Nettoyage artefacts build
   
   ## Tests locaux
   - flutter pub get ✓
   - flutter analyze ✓
   - Structure validée ✓
   
   Fixes: #XXX (remplacer par numéro issue si existe)
   ```
6. Cliquer "Create Pull Request"

---

#### Étape 6: Merge sur Main (après review)
```bash
# Sur GitHub: click "Squash and merge" (ou "Merge commit")
# Ou en local:

git checkout main
git pull origin main

# Vérifier changements
git log --oneline -3
```

---

### OPTION B: COMMANDES MANUELLES (Pour contrôle total)

Si vous préférez exécuter étape par étape:

#### Étape 1: Préparation
```bash
cd /home/thioye/CampusConnect/mobile

# Vérifier status
git status
git log -1 --oneline

# Créer backup
tar -czf campusconnect.backup.$(date +%s).tar.gz \
  --exclude='.git' --exclude='.dart_tool' --exclude='build' .

# Créer branche de travail
git checkout -b refactor/monorepo-cleanup
```

---

#### Étape 2: Archiver Legacy
```bash
# Créer dossier archive
mkdir -p .archive

# Archiver auth/
git mv auth/ .archive/auth_module_legacy

# Créer README
cat > .archive/README.md << 'EOF'
# Archive des Composants Legacy

Ce dossier contient du code historique conservé pour référence.

## Contenus
- `auth_module_legacy/`: Module auth précédent
  - **Raison archivage**: Dupliqué avec `/lib/features/auth/`
  - **Valeur**: Code de référence uniquement
  - **Statut**: NE PAS utiliser - source of truth = /lib/features/auth/

## Restauration
```bash
git checkout archive/auth-module -- auth/
```
EOF

# Committer
git add -A
git commit -m "archive: move legacy auth module to .archive/"
```

---

#### Étape 3: Supprimer Code Mort
```bash
# Supprimer frontend/
git rm -r frontend/
git commit -m "remove: delete duplicate frontend/ - superseded by /lib/"

# Supprimer professional/
git rm -r professional/
git commit -m "remove: delete zombi professional/ - namespace conflict with /lib/"
```

---

#### Étape 4: Réorganiser Database
```bash
# Créer structure
mkdir -p database/migrations
mkdir -p database/schemas
mkdir -p database/seeds

# Lister SQL
ls -1 *.sql | sort

# Renommer avec versioning (exemple pour les 3 premiers)
# À adapter selon votre situation réelle:

mv "create_academic_calendar_table.sql" "database/migrations/V001__create_academic_calendar_table.sql"
mv "create_academic_tables.sql" "database/migrations/V002__create_academic_tables.sql"
mv "create_announcements_table.sql" "database/migrations/V003__create_announcements_table.sql"
# ... continuer pour tous les fichiers

# OU utiliser ce one-liner pour tous:
ls -1 *.sql | sort | nl | while read num file; do
  VERSION=$(printf "%03d" "$num")
  git mv "$file" "database/migrations/V${VERSION}__${file}"
done

# Créer README
cat > database/migrations/README.md << 'EOF'
# Database Migrations

Migrations versionnées et ordonnées.

## Convention
- Format: `VXxx__description.sql`
- Exemple: `V001__initial_schema.sql`

## Procédure
1. Idempotentes (safe to rerun)
2. Jamais modifier migrations appliquées
3. Nouveau fix = NOUVELLE migration

## Outils
- Flyway / Liquibase / Supabase CLI
EOF

# Committer
git add -A
git commit -m "refactor: organize SQL migrations into versioned database/migrations/"
```

---

#### Étape 5: Archiver Stitch
```bash
mkdir -p docs/design-reference
git mv stitch_tableau_de_bord_tudiant/ docs/design-reference/stitch_exports

git add -A
git commit -m "docs: move stitch design exports to docs/design-reference/"
```

---

#### Étape 6: Nettoyer Artefacts
```bash
# Supprimer build/
rm -rf build/

# Mettre à jour .gitignore
echo "build/" >> .gitignore

# Committer
git add -A
git commit -m "chore: remove build artifacts and update .gitignore"
```

---

#### Étape 7: Pousser et Merger
```bash
# Pousser branche
git push -u origin refactor/monorepo-cleanup

# Créer PR sur GitHub (voir étapes OPTION A)

# Après merge sur main:
git checkout main
git pull origin main
```

---

## ✅ VÉRIFICATIONS POST-EXÉCUTION

Après que la PR soit mergée sur `main`, vérifier:

```bash
# 1. Git est propre
git status
# → nothing to commit, working tree clean

# 2. Structure correcte
ls -la | grep -E "lib|backend|database|docs|supabase"
# → lib/
# → backend/
# → database/
# → docs/
# → supabase/

# 3. Code mort supprimé
[ ! -d "frontend/" ] && echo "✓ frontend/ supprimé"
[ ! -d "professional/" ] && echo "✓ professional/ supprimé"
[ -d ".archive/" ] && echo "✓ .archive/ créé"

# 4. Flutter fonctionne
flutter clean
flutter pub get
flutter analyze
# → No issues found!

# 5. Backend compile
cd backend/
dart pub get
dart analyze
cd ..

# 6. Visualiser structure finale
tree -L 2 -I '.dart_tool|.git|build|node_modules' --charset ascii
```

**Résultat attendu:**
```
.
├── .archive/
│   ├── README.md
│   └── auth_module_legacy/
├── .github/
├── database/
│   ├── migrations/
│   │   ├── README.md
│   │   ├── V001__create_academic_calendar_table.sql
│   │   ├── V002__create_academic_tables.sql
│   │   └── ...
│   ├── schemas/
│   └── seeds/
├── docs/
│   ├── ARCHITECTURE.md
│   ├── design-reference/
│   │   └── stitch_exports/
│   └── ...
├── lib/
│   ├── main.dart
│   ├── core/
│   ├── features/
│   └── shared/
├── backend/
│   ├── pubspec.yaml
│   ├── lib/
│   └── bin/
├── supabase/
│   └── functions/
├── android/
├── ios/
├── web/
├── linux/
├── macos/
├── windows/
└── README.md
```

---

## 🚨 RÉSOUDRE PROBLÈMES COMMUNS

### Problème 1: "Git working directory is not clean"

**Cause**: Vous avez des changements non-committés

**Solution**:
```bash
# Option A: Committer vos changements
git add -A
git commit -m "wip: current work"

# Option B: Stasher temporairement
git stash
bash cleanup_monorepo.sh
git stash pop
```

---

### Problème 2: "You are not on main branch"

**Cause**: Vous êtes sur une autre branche

**Solution**:
```bash
git checkout main
git pull origin main
bash cleanup_monorepo.sh
```

---

### Problème 3: Le script échoue à supprimer un fichier

**Cause**: Le fichier n'est pas tracké par git

**Solution**:
```bash
# Vérifier status
git status

# Si le fichier est "Untracked":
rm -rf [nom_fichier]

# Relancer script
bash cleanup_monorepo.sh
```

---

### Problème 4: "Permission denied" sur cleanup_monorepo.sh

**Solution**:
```bash
chmod +x cleanup_monorepo.sh
bash cleanup_monorepo.sh
```

---

### Problème 5: Vous avez lancé le script et voulez l'annuler

**Solution**:
```bash
# AVANT de committer:
git reset --hard HEAD

# Ou restaurer depuis backup:
tar -xzf campusconnect.backup.[timestamp].tar.gz

# Puis recommencer
git checkout main
git pull origin main
bash cleanup_monorepo.sh
```

---

### Problème 6: "merge conflict" après push

**Solution**:
```bash
# Sync avec main
git fetch origin main
git merge origin/main

# Résoudre conflicts (voir git status)
# Puis pousser de nouveau
git push origin refactor/monorepo-cleanup
```

---

## 📊 TEMPS D'EXÉCUTION ESTIMÉ

| Phase | Temps |
|-------|-------|
| Préparation + vérifications | 5 min |
| Exécution script | 2 min |
| Validation locale | 5 min |
| Push + PR création | 5 min |
| Review + merge | 15 min |
| **TOTAL** | **~32 min** |

---

## 🔄 ROLLBACK D'URGENCE

Si quelque chose s'est mal passé après merge sur main:

```bash
# Option 1: Revert le commit
git revert HEAD

# Option 2: Restore depuis backup
tar -xzf campusconnect.backup.[timestamp].tar.gz

# Option 3: Reset à commit antérieur (DANGEREUX)
git reset --hard [commit_id_before_refactor]
git push origin main --force-with-lease
```

---

## 💡 PROCHAINES ÉTAPES APRÈS NETTOYAGE

1. **Créer documentation architecture**:
   ```bash
   cat > docs/ARCHITECTURE.md << 'EOF'
   # Architecture CampusConnect
   
   ## Structure
   - /lib/ → Frontend Flutter
   - /backend/ → API Dart Shelf
   - /database/ → Migrations versionnées
   - /supabase/ → Edge Functions
   
   ## Tech Stack
   - Frontend: Flutter 3.41.3
   - Backend: Dart Shelf
   - DB: PostgreSQL (Supabase)
   
   ## Commandes utiles
   ```
   
2. **Configurer CI/CD**:
   - `.github/workflows/test.yml` pour tests
   - `.github/workflows/deploy.yml` pour déploiement

3. **Documenter décisions architecturales** (ADR):
   - `docs/adr/0001_use_riverpod.md`
   - `docs/adr/0002_dart_vs_nodejs.md`

4. **Mettre en place migrations version DB**:
   - Utiliser Flyway ou Supabase CLI
   - Chaque feature = nouvelle migration

---

## 📞 SUPPORT

Si vous rencontrez des problèmes:

1. Vérifier le log complet du script
2. Consulter la section "RÉSOUDRE PROBLÈMES COMMUNS"
3. Vérifier avec: `git log --oneline -20`
4. En dernier recours: restaurer depuis backup

---

**Guide créé**: 28 avril 2026  
**Version**: 1.0  
**Auteur**: Architecte Senior - CampusConnect
