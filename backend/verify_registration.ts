import axios from 'axios';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();
const API_URL = 'http://localhost:3000';

async function testRegistration() {
  console.log('🚀 Simulation d\'inscription...');
  
  const testEmail = `test.${Date.now()}@univ-labe.gn`;
  const testData = {
    email: testEmail,
    password: 'Password123!',
    first_name: 'Simulated',
    last_name: 'User',
    role: 'Étudiant',
    department: 'Informatique',
    student_id: 'MAT' + Math.floor(Math.random() * 10000)
  };

  try {
    // 1. Appel API Register
    console.log(`📡 Appel POST /auth/register pour ${testEmail}`);
    const response = await axios.post(`${API_URL}/auth/register`, testData);
    
    if (response.status === 201) {
      console.log('✅ API: Inscription réussie !');
      console.log('User ID:', response.data.data.user.id);
      
      // 2. Vérification dans la base de données via Prisma
      console.log('🔍 Vérification dans la base de données...');
      const dbUser = await prisma.users.findUnique({
        where: { email: testEmail },
        include: { profiles: true }
      });

      if (dbUser) {
        console.log('✅ DB: Utilisateur trouvé dans la table "users"');
        if (dbUser.profiles) {
          console.log('✅ DB: Profil associé trouvé dans la table "profiles"');
          console.log('   Nom complet:', dbUser.profiles.full_name);
          console.log('   Matricule:', dbUser.profiles.matricule);
          console.log('   Filière:', dbUser.profiles.filiere);
        } else {
          console.log('❌ DB: Profil manquant pour l\'utilisateur !');
        }
      } else {
        console.log('❌ DB: Utilisateur non trouvé dans la base de données !');
      }
    } else {
      console.log('❌ API: Échec de l\'inscription', response.data);
    }
  } catch (error: any) {
    console.error('❌ Erreur lors du test:', error.response?.data || error.message);
  } finally {
    await prisma.$disconnect();
  }
}

testRegistration();
