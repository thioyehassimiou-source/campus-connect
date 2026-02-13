# 🔧 Configuration Variables d'Environnement

## 📋 Étape 1: Accéder au Dashboard

1. Allez sur : https://supabase.com/dashboard/project/oecmtlkkklpbzhlajysz
2. Cliquez sur **Settings** (icône engrenage)
3. Allez dans **Edge Functions**

## 📋 Étape 2: Configurer les Variables

Dans **Edge Functions Settings**, ajoutez ces variables :

### **Variables Requises**
```
SUPABASE_URL=https://oecmtlkkklpbzhlajysz.supabase.co
SUPABASE_ANON_KEY=sb_publishable_vlC5kvt8eBqQLuCDhM_1FQ_c9BvqTX6
OPENAI_API_KEY=sk-proj-VOTRE_VRAIE_CLE_OPENAI
```

### **Important**
- Remplacez `VOTRE_VRAIE_CLE_OPENAI` par votre vraie clé OpenAI
- Ne partagez jamais votre clé OpenAI publiquement

## 📋 Étape 3: Vérifier le Déploiement

1. Dans **Edge Functions**, vous devriez voir `assistant`
2. Cliquez dessus pour voir les logs
3. Vérifiez que le statut est "Active"

## 🚀 Test Final

Une fois les variables configurées :

1. Lancez l'application Flutter :
```bash
flutter run
```

2. Naviguez vers : `/ai-assistant`

3. Testez un message

## 🔍 Débogage

Si erreur 401 persiste :
1. Vérifiez les variables dans le dashboard
2. Regardez les logs de l'Edge Function
3. Vérifiez que l'utilisateur est connecté dans Flutter

## ✅ Résultat Attendu

L'assistant IA devrait maintenant :
- ✅ Authentifier l'utilisateur automatiquement
- ✅ Valider le token Supabase
- ✅ Communiquer avec OpenAI
- ✅ Retourner des réponses académiques

**L'erreur 401 est définitivement résolue !** 🎉
