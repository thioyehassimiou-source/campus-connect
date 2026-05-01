import dotenv from 'dotenv';
dotenv.config();

import prisma from '../src/lib/prisma';

async function audit() {
  const tables = [
    'users', 'profiles', 'faculties', 'departments', 'courses', 
    'schedules', 'announcements', 'grades', 'attendance', 
    'assignments', 'resources', 'conversations', 'messages', 'services'
  ];

  console.log('--- AUDIT DES DONNÉES MIGRÉES ---');
  for (const table of tables) {
    try {
      const count = await (prisma as any)[table].count();
      console.log(`${table.padEnd(20)}: ${count} enregistrements`);
    } catch (e: any) {
      console.log(`${table.padEnd(20)}: [ERREUR] ${e.message.split('\n')[0]}`);
    }
  }
}

audit().finally(() => prisma.$disconnect());
