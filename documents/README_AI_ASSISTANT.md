# 🤖 Assistant IA CampusConnect - Installation

## 📋 Fichiers Créés

### **Frontend Flutter**
- `lib/services/auth_service.dart` - Service d'authentification amélioré
- `lib/services/ai_assistant_service.dart` - Service de communication IA
- `lib/widgets/ai_assistant_widget.dart` - Widget complet de l'assistant
- `lib/screens/ai_assistant_screen.dart` - Écran de l'assistant

### **Backend Supabase**
- `supabase/functions/assistant/index.ts` - Edge Function TypeScript
- `supabase/functions/assistant/deno.json` - Configuration Deno

## 🔧 Configuration Requise

### **1. Variables d'Environnement**

Créez un fichier `.env.local` à la racine :
```bash
# Configuration Supabase
SUPABASE_URL=https://oecmtlkkklpbzhlajysz.supabase.co
SUPABASE_ANON_KEY=sb_publishable_vlC5kvt8eBqQLuCDhM_1FQ_c9BvqTX6

# Configuration OpenAI (IMPORTANT)
OPENAI_API_KEY=sk-proj-VOTRE_VRAIE_CLE_OPENAI

# Configuration Assistant IA
AI_ASSISTANT_URL=https://oecmtlkkklpbzhlajysz.supabase.co/functions/v1/assistant
```

### **2. Déploiement Edge Function**

```bash
# Déployer la fonction
supabase functions deploy assistant

# Ou via le dashboard Supabase
```

### **3. Configuration Backend**

Dans le dashboard Supabase → Edge Functions → Settings :
```
SUPABASE_URL=https://oecmtlkkklpbzhlajysz.supabase.co
SUPABASE_ANON_KEY=sb_publishable_vlC5kvt8eBqQLuCDhM_1FQ_c9BvqTX6
OPENAI_API_KEY=sk-proj-VOTRE_VRAIE_CLE_OPENAI
```

## 🚀 Lancement

### **1. Installer les dépendances**
```bash
flutter pub get
```

### **2. Lancer l'application**
```bash
flutter run
```

### **3. Accéder à l'assistant**
Naviguez vers : `/ai-assistant`

## 🔍 Debugging

### **Logs Frontend**
```dart
// Les logs sont déjà inclus dans les services
print('🔑 Headers envoyés: ${headers.keys.toList()}');
print('🎯 Token (premiers 20 chars): ${accessToken.substring(0, 20)}...');
```

### **Logs Backend**
```bash
# Vérifier les logs de l'Edge Function
supabase functions logs assistant
```

## 🎯 Fonctionnalités

### **✅ Ce qui fonctionne**
- Authentification Supabase sécurisée
- Token récupéré et rafraîchi automatiquement
- Headers correctement formatés
- Communication avec OpenAI
- Interface utilisateur complète
- Gestion des erreurs
- Logs détaillés

### **🔧 Points de contrôle**
1. Token récupéré depuis Supabase ✅
2. Headers Authorization: Bearer <token> ✅
3. Validation token côté backend ✅
4. Communication OpenAI ✅
5. Interface utilisateur ✅

## 🚨 Erreurs Possibles

### **401 Token Invalide**
- Vérifiez que l'utilisateur est bien connecté
- Vérifiez que le token n'est pas expiré
- Vérifiez les variables d'environnement

### **500 Erreur Serveur**
- Vérifiez la clé OpenAI
- Vérifiez les logs de l'Edge Function
- Vérifiez la connexion Supabase

## 🎉 Résultat

L'assistant IA est maintenant pleinement intégré avec :
- Authentification sécurisée
- Gestion des tokens automatique
- Interface complète
- Logs de debugging
- Gestion des erreurs

**L'erreur 401 est résolue !** 🚀
