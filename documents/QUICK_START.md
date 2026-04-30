# 🎯 COMMANDES MINIMALES - Nettoyage CampusConnect

## Pour les impatients: 3 options

### OPTION ULTRA-RAPIDE (Script tout-en-un)
```bash
cd /home/thioye/CampusConnect/mobile
bash cleanup_monorepo.sh --dry-run    # Test d'abord
bash cleanup_monorepo.sh               # Puis réel
git push -u origin refactor/monorepo-cleanup-$(date +%Y%m%d)
```

---

### OPTION MANUELLE MINIMALE (30 secondes par commande)
```bash
cd /home/thioye/CampusConnect/mobile

# 1. Préparer
git status && git log -1 --oneline
git checkout -b refactor/monorepo-cleanup-$(date +%Y%m%d)

# 2. Archive + Supprime
mkdir -p .archive && git mv auth/ .archive/auth_module_legacy
git rm -r frontend/ professional/

# 3. Database
mkdir -p database/migrations
ls -1 *.sql | sort | nl | while read n f; do 
  git mv "$f" "database/migrations/V$(printf '%03d' $n)__${f}"
done

# 4. Design
mkdir -p docs/design-reference && git mv stitch_tableau_de_bord_tudiant/ docs/design-reference/stitch_exports

# 5. Clean
rm -rf build/ && echo "build/" >> .gitignore

# 6. Commit & Push
git add -A
git commit -m "refactor: cleanup monorepo structure"
git push -u origin $(git branch --show-current)
```

---

### OPTION ÉTAPE-PAR-ÉTAPE (Maximum de contrôle)

#### 1️⃣ Vérifications
```bash
cd /home/thioye/CampusConnect/mobile
git status                    # Doit être clean
git log -1 --oneline         # Voir dernier commit
flutter --version            # Vérifier Flutter
```

#### 2️⃣ Backup
```bash
tar -czf backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  --exclude='.git' --exclude='.dart_tool' --exclude='build' .
ls -lh backup-*.tar.gz
```

#### 3️⃣ Créer branche
```bash
git checkout -b refactor/monorepo-cleanup
```

#### 4️⃣ Archiver legacy (auth/)
```bash
mkdir -p .archive
git mv auth/ .archive/auth_module_legacy
cat > .archive/README.md << 'EOF'
# Archive Legacy

- auth_module_legacy/ → code historique (dupliqué dans /lib/features/auth/)
EOF
git add .archive/
git commit -m "archive: move legacy auth to .archive/"
```

#### 5️⃣ Supprimer zombis
```bash
git rm -r frontend/
git commit -m "remove: delete duplicate frontend/"

git rm -r professional/
git commit -m "remove: delete zombi professional/ (namespace conflict)"
```

#### 6️⃣ Réorganiser SQL
```bash
mkdir -p database/migrations database/schemas database/seeds

# Renommer tous les *.sql avec versioning
ls -1 *.sql | sort | nl | while read NUM FILE; do
  VERSION=$(printf "%03d" "$NUM")
  NEW_NAME="database/migrations/V${VERSION}__${FILE}"
  git mv "$FILE" "$NEW_NAME"
done

# Créer README
cat > database/migrations/README.md << 'EOF'
# Database Migrations

Format: VXxx__description.sql
Appliqués dans l'ordre alphabétique.
Jamais modifier une migration déjà appliquée.
EOF

git add -A
git commit -m "refactor: organize SQL migrations to database/migrations/ with versioning"
```

#### 7️⃣ Archiver Stitch
```bash
mkdir -p docs/design-reference
git mv stitch_tableau_de_bord_tudiant/ docs/design-reference/stitch_exports
git commit -m "docs: move stitch design exports to docs/design-reference/"
```

#### 8️⃣ Nettoyer build
```bash
rm -rf build/
echo "build/" >> .gitignore
git add -A
git commit -m "chore: remove build artifacts and update .gitignore"
```

#### 9️⃣ Pousser
```bash
git push -u origin refactor/monorepo-cleanup
git log --oneline -5
```

#### 🔟 Créer PR
```
1. Aller sur: https://github.com/thioye/CampusConnect/pulls
2. Cliquer "New Pull Request"
3. Base: main, Compare: refactor/monorepo-cleanup
4. Titre: "refactor: cleanup monorepo structure"
5. Description: [voir EXECUTION_GUIDE.md]
6. Cliquer "Create Pull Request"
```

---

## ✅ VALIDATION POST-EXÉCUTION

```bash
# Structure correcte?
ls -d lib backend database docs supabase 2>&1 | sort
# Résultat attendu: lib backend database docs supabase (sauf 1 absent = ok)

# Code mort supprimé?
[ ! -d "frontend/" ] && [ ! -d "professional/" ] && echo "✓ OK"

# Flutter compile?
flutter clean && flutter pub get && flutter analyze

# Backend?
cd backend && dart pub get && dart analyze

# Commit OK?
git log --oneline -3
```

---

## 📊 RÉSUMÉ AVANT/APRÈS

### AVANT (Chaos)
```
.
├── lib/ (2.0 MB) ← PRIMARY
├── frontend/ (52 KB) ← DEAD
├── professional/ (128 KB) ← POISON
├── auth/ (384 KB) ← DUPLICATE
├── backend/ ← OK mais pas Node.js
├── *.sql (50 files) ← LOOSE AT ROOT
├── stitch_tableau_de_bord_tudiant/ ← DESIGN ARTIFACT
└── build/ ← COMPILATION ARTIFACT
```

### APRÈS (Propre)
```
.
├── .archive/
│   └── auth_module_legacy/
├── lib/ ← UNIQUE FRONTEND
├── backend/ ← SOLE API
├── database/
│   ├── migrations/ (VXxx__*.sql)
│   ├── schemas/
│   └── seeds/
├── docs/
│   ├── ARCHITECTURE.md
│   ├── ARCHITECTURE_ANALYSIS.md
│   ├── EXECUTION_GUIDE.md
│   └── design-reference/stitch_exports/
├── supabase/functions/ ← EDGE FUNCTIONS
└── [platforms: android/, ios/, web/, etc.]
```

---

## 🔥 ONE-LINER COMPLET (À VOS RISQUES)

```bash
cd /home/thioye/CampusConnect/mobile && \
git checkout -b refactor/cleanup && \
mkdir -p .archive && git mv auth/ .archive/auth_module_legacy && \
git rm -r frontend/ professional/ && \
mkdir -p database/migrations && \
ls -1 *.sql | sort | nl | while read n f; do git mv "$f" "database/migrations/V$(printf '%03d' $n)__${f}"; done && \
mkdir -p docs/design-reference && git mv stitch_tableau_de_bord_tudiant/ docs/design-reference/stitch_exports && \
rm -rf build/ && echo "build/" >> .gitignore && \
git add -A && \
git commit -m "refactor: cleanup monorepo - single source of truth for each component" && \
git push -u origin refactor/cleanup && \
echo "✓ DONE - Create PR now" && \
git log --oneline -3
```

---

## 🚨 EMERGENCY ABORT

```bash
# Si ça s'est mal passé AVANT commit:
git reset --hard HEAD

# Si ça s'est mal passé APRÈS commit:
git revert HEAD

# Si le monde brûle:
tar -xzf backup-*.tar.gz
```

---

## 📖 DOCUMENTATION CRÉÉE

Trois fichiers ont été créés pour vous:

1. **ARCHITECTURE_ANALYSIS.md** ← Diagnostic complet (vous lisez ça)
2. **EXECUTION_GUIDE.md** ← Guide détaillé pas-à-pas  
3. **cleanup_monorepo.sh** ← Script automatisé

---

## ⏱️ TEMPS

- Script automatisé: **4 minutes**
- Manuel pas-à-pas: **15 minutes**
- Review + merge: **15 minutes**
- **TOTAL**: **~30 minutes**

---

**Choisissez votre approche et lancez! 🚀**
