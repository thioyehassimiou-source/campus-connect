# ✅ PRE-CLEANUP CHECKLIST

## ⚠️ À VÉRIFIER AVANT DE LANCER

### Git & Repo State
- [ ] Vous êtes dans `/home/thioye/CampusConnect/mobile`
- [ ] `git status` → "nothing to commit, working tree clean"
- [ ] `git log -1 --oneline` → Dernier commit cohérent
- [ ] Vous êtes sur branche `main`
- [ ] `git pull origin main` → Tous les derniers changements

### Environment
- [ ] `flutter --version` → 3.40+ (vous avez 3.41.3 ✓)
- [ ] `dart pub get` → Succès dans `/backend/`
- [ ] Espace disque: `df -h` → Au moins 1 GB libre

### Backup
- [ ] Vous avez sauvegardes externes (USB, cloud)
- [ ] `ls *.tar.gz` → Aucun backup ancien à confondre

### Team Communication
- [ ] Équipe informée (pas de push concurrent)
- [ ] Aucune branche feature en cours de rebase
- [ ] CI/CD peut être temporairement pausé

---

# ✅ PENDANT EXÉCUTION

## Étapes Critiques
- [ ] Script passe le mode `--dry-run` sans erreurs
- [ ] Messages succes (✓) affichés pour chaque phase
- [ ] Aucun "Permission denied"
- [ ] Aucun "Untracked files" bloquants

## Git Operations
- [ ] Commits ont messages explicites
- [ ] Aucun commit vide ("No changes")
- [ ] `git log` montre croissance du repo

---

# ✅ POST-CLEANUP VALIDATION

## Structure
```bash
[ ] lib/ existe et contient main.dart
[ ] backend/ existe et contient pubspec.yaml
[ ] database/migrations/ existe avec *.sql
[ ] docs/ existe avec design-reference/
[ ] supabase/functions/ existe
[ ] .archive/ existe avec auth_module_legacy/
[ ] frontend/ n'existe PLUS
[ ] professional/ n'existe PLUS
[ ] build/ n'existe PLUS
```

## Code Compilation
```bash
[ ] flutter clean → succès
[ ] flutter pub get → succès
[ ] flutter analyze → "No issues found"
[ ] cd backend && dart pub get → succès
[ ] cd backend && dart analyze → succès (ou warnings acceptables)
```

## Git Integrity
```bash
[ ] git status → "nothing to commit, working tree clean"
[ ] git log -3 → Montre commits cleanup
[ ] git branch → Branche refactor visible
[ ] git remote -v → Origin correctly set
```

## SQL Migrations
```bash
[ ] ls database/migrations/*.sql → V001__, V002__, V003__, etc.
[ ] grep -l "CREATE TABLE" database/migrations/V001__* → Exist
[ ] grep -l "CREATE TABLE" database/migrations/*.sql | wc -l → [count] tables
```

## Documentation
```bash
[ ] cat ARCHITECTURE_ANALYSIS.md | head -5 → Shows content
[ ] cat EXECUTION_GUIDE.md | head -5 → Shows content
[ ] cat QUICK_START.md | head -5 → Shows content
[ ] .archive/README.md exists
[ ] database/migrations/README.md exists
```

---

# ✅ PUSH TO GITHUB

## Before Push
```bash
[ ] git push --dry-run -u origin refactor/monorepo-cleanup → Succès (output shows "Would...")
```

## After Push
```bash
[ ] GitHub affiche branche 'refactor/monorepo-cleanup'
[ ] Commits visibles sur GitHub
[ ] "Compare & pull request" bouton disponible
```

## Pull Request
```bash
[ ] Titre: "refactor: cleanup monorepo structure"
[ ] Description remplie avec changements listés
[ ] Assign to yourself
[ ] Add label: "architecture" ou "cleanup"
[ ] Demander review à tech lead
```

## Merge
```bash
[ ] Review approuvé (1+ approval)
[ ] CI/CD passe (tous les checks verts)
[ ] Conflicts: None (ou résolus)
[ ] Click "Squash and merge" ou "Create merge commit"
[ ] DELETE branche after merge
```

## Après Merge
```bash
[ ] git checkout main
[ ] git pull origin main
[ ] git branch -d refactor/monorepo-cleanup (local)
[ ] git push origin --delete refactor/monorepo-cleanup (remote)
[ ] Visualiser structure finale
```

---

# 🚨 EMERGENCY SITUATIONS

## "Je viens de commencer et ça va mal"

### Avant commit:
```bash
[ ] git reset --hard HEAD
[ ] Vérifier: git log -1 --oneline (ancienne commit)
```

### Après commit mais pas push:
```bash
[ ] git revert HEAD  (crée undo commit)
[ ] ou: git reset --soft HEAD~1  (undo commit, garde changes)
```

### Après push:
```bash
[ ] NE PAS force push si autres ont commencé
[ ] Créer revert commit: git revert [commit_id]
[ ] Push le revert
[ ] Discuter en équipe
```

---

# 🎓 POST-CLEANUP TRAINING

Après succès merge, former équipe:

- [ ] Nouvelle structure expliquée
- [ ] `/lib/` = unique frontend
- [ ] `/backend/` = unique backend
- [ ] `/database/migrations/` = versioned DB
- [ ] Workflow: Qui modifie quoi où?
- [ ] `.archive/` = ne pas utiliser sauf référence

---

# 📊 SIGN-OFF CHECKLIST

## Tech Lead Must Verify
- [ ] Pas de code critique supprimé
- [ ] Tous les tests passent
- [ ] Structure conforme architecture décidée
- [ ] Documentation mise à jour

## PM/Product Must Verify
- [ ] Aucune feature prod bloquée
- [ ] Timeline respectée (30 min exec)
- [ ] No user impact

## DevOps Must Verify
- [ ] CI/CD pipelines toujours fonctionnels
- [ ] Database migrations applicables
- [ ] Deployment process clear

---

**Imprimer cette checklist et cocher pendant exécution! ✅**

`Date exécution: ___________`
`Qui exécute: ___________`
`Approuvé par: ___________`
`Signé: ___________`
