import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const count = await prisma.filieres.count();
  console.log(`Nombre de filières: ${count}`);

  if (count === 0) {
    console.log('Insertion de filières de test...');
    await prisma.filieres.createMany({
      data: [
        { nom: 'Informatique', description: 'Génie Logiciel et Systèmes' },
        { nom: 'Mathématiques', description: 'Mathématiques Appliquées' },
        { nom: 'Physique', description: 'Physique Fondamentale' },
        { nom: 'Droit', description: 'Droit Public et Privé' },
        { nom: 'Économie', description: 'Gestion et Économie' },
      ],
    });
    console.log('Filières insérées !');
  }

  const serviceCount = await prisma.services.count();
  console.log(`Nombre de services: ${serviceCount}`);
  if (serviceCount === 0) {
    console.log('Insertion de services de test...');
    await prisma.services.createMany({
      data: [
        { name: 'Scolarité', description: 'Gestion des inscriptions' },
        { name: 'Ressources Humaines', description: 'Gestion du personnel' },
        { name: 'Bibliothèque', description: 'Gestion des ouvrages' },
      ],
    });
    console.log('Services insérés !');
  }
}

main()
  .catch((e) => console.error(e))
  .finally(async () => await prisma.$disconnect());
