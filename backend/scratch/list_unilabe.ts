import dotenv from 'dotenv';
dotenv.config();
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const facs = await prisma.faculties.findMany({
    include: {
      departments: true
    }
  });

  console.log('--- STRUCTURE RÉELLE DE L\'UNIVERSITÉ DE LABÉ (DB) ---');
  facs.forEach(f => {
    console.log(`\n🏫 ${f.name}`);
    if (f.departments.length === 0) console.log('   (Aucun département trouvé)');
    f.departments.forEach(d => {
      console.log(`   - ${d.name}`);
    });
  });
}

main().finally(() => prisma.$disconnect());
