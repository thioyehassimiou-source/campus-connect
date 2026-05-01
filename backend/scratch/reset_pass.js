
const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');

const pool = new Pool({ connectionString: 'postgresql://postgres:campusconnect@localhost:5432/campusconnect' });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function reset() {
  try {
    const hash = await bcrypt.hash('password123', 12);
    const user = await prisma.users.update({
      where: { email: 'thioye1@gmail.com' },
      data: { password_hash: hash }
    });
    console.log('✅ Mot de passe mis à jour pour:', user.email);
    console.log('Nouveau mot de passe: password123');
  } catch (e) {
    console.error('Erreur:', e.message);
  } finally {
    await prisma.$disconnect();
    await pool.end();
  }
}
reset();
