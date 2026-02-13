#!/bin/bash

# Script de test local de la Edge Function
# Ce script simule un appel à la fonction avec un JWT factice

echo "🧪 Test de la Edge Function assistant-groq"
echo ""

# Créer un JWT factice (format valide mais signature invalide)
FAKE_JWT="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRlc3RAdW5pdi1sYWJlLmVkdS5nbiIsInN1YiI6IjEyMzQ1Njc4OTAifQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

echo "📤 Envoi d'une requête test..."
curl -X POST http://localhost:54321/functions/v1/assistant-groq \
  -H "Authorization: Bearer $FAKE_JWT" \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Bonjour, test de connexion"}' \
  --verbose

echo ""
echo "✅ Test terminé"
