import { Client, Pool } from 'pg';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { resolve4 } from 'dns/promises';
import { v5 as uuidv5 } from 'uuid';
import dotenv from 'dotenv';

dotenv.config();

const localPool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(localPool);
const prisma = new PrismaClient({ adapter });

const NAMESPACE = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'; // Namespace standard

function isUuid(id: string | null | undefined): boolean {
  if (!id) return false;
  const regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  return regex.test(id);
}

function toUuid(id: string): string {
  if (isUuid(id)) return id;
  return uuidv5(id.toString(), NAMESPACE);
}

async function resolveToIPv4(url: string): Promise<string> {
  const parsed = new URL(url);
  const hostname = parsed.hostname;
  try {
    const [ipv4] = await resolve4(hostname);
    parsed.hostname = ipv4!;
    console.log(`🌐 Résolution IPv4: ${hostname} → ${ipv4}`);
    return parsed.toString();
  } catch {
    console.warn('⚠️  Impossible de résoudre en IPv4, tentative avec l\'URL originale...');
    return url;
  }
}

function normalizeRole(role: string): string {
  const r = (role || '').toLowerCase().trim();
  if (r === 'enseignant' || r === 'teacher' || r === 'professeur' || r === 'prof') return 'Enseignant';
  if (r === 'admin' || r === 'administrateur' || r === 'administrator' || r === 'administratif') return 'Admin';
  return 'Étudiant'; 
}

async function migrate() {
  const supabaseDbUrl = process.env.SUPABASE_DB_URL;
  
  if (!supabaseDbUrl || supabaseDbUrl.includes('[YOUR-PASSWORD]')) {
    console.error('❌ ERREUR: Vous devez définir SUPABASE_DB_URL dans .env');
    process.exit(1);
  }

  const resolvedUrl = await resolveToIPv4(supabaseDbUrl);
  const sbClient = new Client({ connectionString: resolvedUrl, ssl: { rejectUnauthorized: false } });
  
  try {
    console.log('🔄 Connexion à Supabase...');
    await sbClient.connect();
    console.log('✅ Connecté à Supabase.');

    // 1. FACULTÉS
    console.log('\n📦 Migration des Facultés...');
    const facultiesCheck = await sbClient.query(`SELECT to_regclass('public.faculties') as exists;`);
    if (facultiesCheck.rows[0].exists) {
      const { rows: faculties } = await sbClient.query('SELECT * FROM public.faculties');
      for (const f of faculties) {
        await prisma.faculties.upsert({
          where: { id: f.id },
          update: { name: f.name, description: f.description },
          create: { id: f.id, name: f.name, description: f.description }
        });
      }
      console.log(`✅ ${faculties.length} facultés migrées.`);
    }

    // 2. DÉPARTEMENTS
    console.log('\n📦 Migration des Départements...');
    const departmentsCheck = await sbClient.query(`SELECT to_regclass('public.departments') as exists;`);
    if (departmentsCheck.rows[0].exists) {
      const { rows: departments } = await sbClient.query('SELECT * FROM public.departments');
      for (const d of departments) {
        await prisma.departments.upsert({
          where: { id: d.id },
          update: { name: d.name, description: d.description, faculty_id: d.faculty_id },
          create: { id: d.id, name: d.name, description: d.description, faculty_id: d.faculty_id }
        });
      }
      console.log(`✅ ${departments.length} départements migrés.`);
    }

    // 3. UTILISATEURS (auth.users)
    console.log('\n📦 Migration des Utilisateurs...');
    const { rows: authUsers } = await sbClient.query('SELECT * FROM auth.users');
    let usersCount = 0;
    for (const su of authUsers) {
      await prisma.users.upsert({
        where: { id: su.id },
        update: {
          email: su.email,
          password_hash: su.encrypted_password || 'migrated_no_password',
          role: normalizeRole(su.raw_user_meta_data?.role),
          created_at: su.created_at,
          updated_at: su.updated_at,
        },
        create: {
          id: su.id,
          email: su.email,
          password_hash: su.encrypted_password || 'migrated_no_password',
          role: normalizeRole(su.raw_user_meta_data?.role),
          created_at: su.created_at,
          updated_at: su.updated_at,
        }
      });
      usersCount++;
    }
    console.log(`✅ ${usersCount} utilisateurs migrés.`);

    // 4. SERVICES
    console.log('\n📦 Migration des Services...');
    const servicesCheck = await sbClient.query(`SELECT to_regclass('public.services') as exists;`);
    if (servicesCheck.rows[0].exists) {
      const { rows: services } = await sbClient.query('SELECT * FROM public.services');
      for (const s of services) {
        await prisma.services.upsert({
          where: { name: s.name },
          update: {
            id: s.id, description: s.description, icon: s.icon ?? null, category: s.category,
            faculty_id: s.faculty_id ? parseInt(s.faculty_id) : null, contact: s.contact, 
            telephone: s.telephone, email: s.email, localisation: s.localisation, 
            horaires: s.horaires, site_web: s.site_web, parent_id: s.parent_id, 
            metadata: s.metadata, is_active: s.is_active, created_at: s.created_at, updated_at: s.updated_at
          },
          create: {
            id: s.id, name: s.name, description: s.description, icon: s.icon ?? null, category: s.category,
            faculty_id: s.faculty_id ? parseInt(s.faculty_id) : null, contact: s.contact, 
            telephone: s.telephone, email: s.email, localisation: s.localisation, 
            horaires: s.horaires, site_web: s.site_web, parent_id: s.parent_id, 
            metadata: s.metadata, is_active: s.is_active, created_at: s.created_at, updated_at: s.updated_at
          }
        });
      }
      console.log(`✅ ${services.length} services migrés.`);
    }

    // 5. PROFILS
    console.log('\n📦 Migration des Profils...');
    const profileCheck = await sbClient.query(`SELECT to_regclass('public.profiles') as exists;`);
    if (profileCheck.rows[0].exists) {
      const { rows: profiles } = await sbClient.query('SELECT * FROM public.profiles');
      let profilesCount = 0;
      for (const p of profiles) {
        const userExists = await prisma.users.findUnique({ where: { id: p.id } });
        if (!userExists) continue;
        await prisma.profiles.upsert({
          where: { id: p.id },
          update: {
            full_name: p.full_name, nom: p.nom, email: p.email, avatar_url: p.avatar_url,
            role: normalizeRole(p.role || userExists.role), filiere: p.filiere, niveau: p.niveau,
            matricule: p.matricule, phone: p.phone, telephone: p.telephone, bio: p.bio,
            date_naissance: p.date_naissance, faculty_id: p.faculty_id ? parseInt(p.faculty_id) : null,
            department_id: p.department_id ? parseInt(p.department_id) : null, service_id: p.service_id, 
            status: p.status, is_verified: p.is_verified, 
            moyenne: p.moyenne ? parseFloat(p.moyenne) : 0, 
            credits_valides: p.credits_valides ? parseInt(p.credits_valides) : 0,
            classement: p.classement, linkedin: p.linkedin, github: p.github, twitter: p.twitter,
            competences: p.competences || [], interets: p.interets || [], office: p.office,
            specialization: p.specialization, office_hours: p.office_hours || {},
            publications: p.publications || [], social_links: p.social_links || {},
            is_active: p.is_active, last_login_at: p.last_login_at, student_id: p.student_id,
            department: p.department, created_at: p.created_at, updated_at: p.updated_at
          },
          create: {
            id: p.id, full_name: p.full_name, nom: p.nom, email: p.email, avatar_url: p.avatar_url,
            role: normalizeRole(p.role || userExists.role), filiere: p.filiere, niveau: p.niveau,
            matricule: p.matricule, phone: p.phone, telephone: p.telephone, bio: p.bio,
            date_naissance: p.date_naissance, faculty_id: p.faculty_id ? parseInt(p.faculty_id) : null,
            department_id: p.department_id ? parseInt(p.department_id) : null, service_id: p.service_id, 
            status: p.status, is_verified: p.is_verified, 
            moyenne: p.moyenne ? parseFloat(p.moyenne) : 0, 
            credits_valides: p.credits_valides ? parseInt(p.credits_valides) : 0,
            classement: p.classement, linkedin: p.linkedin, github: p.github, twitter: p.twitter,
            competences: p.competences || [], interets: p.interets || [], office: p.office,
            specialization: p.specialization, office_hours: p.office_hours || {},
            publications: p.publications || [], social_links: p.social_links || {},
            is_active: p.is_active, last_login_at: p.last_login_at, student_id: p.student_id,
            department: p.department, created_at: p.created_at, updated_at: p.updated_at
          }
        });
        profilesCount++;
      }
      console.log(`✅ ${profilesCount} profils migrés.`);
    }

    // 6. ANNONCES
    console.log('\n📦 Migration des Annonces...');
    const announcementsCheck = await sbClient.query(`SELECT to_regclass('public.announcements') as exists;`);
    if (announcementsCheck.rows[0].exists) {
      const { rows: announcements } = await sbClient.query('SELECT * FROM public.announcements');
      for (const a of announcements) {
        const annId = toUuid(a.id.toString());
        
        // Vérification auteur
        let authorId = isUuid(a.author_id) ? a.author_id : null;
        if (authorId) {
          const user = await prisma.users.findUnique({ where: { id: authorId } });
          if (!user) authorId = null;
        }

        // Vérification service_id
        const serviceId = isUuid(a.service_id) ? a.service_id : null;

        await prisma.announcements.upsert({
          where: { id: annId },
          update: {
            title: a.title, content: a.content, category: a.category, priority: a.priority,
            author_id: authorId, author_name: a.author_name, service_id: serviceId,
            scope: a.scope, filiere: a.filiere, niveau: a.niveau, faculty_id: a.faculty_id,
            department_id: a.department_id, is_pinned: a.is_pinned, 
            created_at: a.created_at, updated_at: a.updated_at
          },
          create: {
            id: annId, title: a.title, content: a.content, category: a.category, priority: a.priority,
            author_id: authorId, author_name: a.author_name, service_id: serviceId,
            scope: a.scope, filiere: a.filiere, niveau: a.niveau, faculty_id: a.faculty_id,
            department_id: a.department_id, is_pinned: a.is_pinned, 
            created_at: a.created_at, updated_at: a.updated_at
          }
        });
      }
      console.log(`✅ ${announcements.length} annonces migrées.`);
    }

    // 7. CONVERSATIONS
    console.log('\n📦 Migration des Conversations...');
    const conversationsCheck = await sbClient.query(`SELECT to_regclass('public.conversations') as exists;`);
    if (conversationsCheck.rows[0].exists) {
      const { rows: convs } = await sbClient.query('SELECT * FROM public.conversations');
      for (const c of convs) {
        await prisma.conversations.upsert({
          where: { id: c.id },
          update: {
            name: c.name, is_group: c.is_group, last_message: c.last_message,
            last_message_time: c.last_message_time, last_message_sender_id: c.last_message_sender_id,
            is_last_message_read: c.is_last_message_read, created_at: c.created_at, updated_at: c.updated_at
          },
          create: {
            id: c.id, name: c.name, is_group: c.is_group, last_message: c.last_message,
            last_message_time: c.last_message_time, last_message_sender_id: c.last_message_sender_id,
            is_last_message_read: c.is_last_message_read, created_at: c.created_at, updated_at: c.updated_at
          }
        });
      }
      console.log(`✅ ${convs.length} conversations migrées.`);
    }

    // 8. MESSAGES
    console.log('\n📦 Migration des Messages...');
    const messagesCheck = await sbClient.query(`SELECT to_regclass('public.messages') as exists;`);
    if (messagesCheck.rows[0].exists) {
      const { rows: msgs } = await sbClient.query('SELECT * FROM public.messages');
      for (const m of msgs) {
        // Vérification conversation et expéditeur
        const conv = await prisma.conversations.findUnique({ where: { id: m.conversation_id } });
        const sender = await prisma.users.findUnique({ where: { id: m.sender_id } });
        if (!conv || !sender) continue;

        await prisma.messages.upsert({
          where: { id: m.id },
          update: {
            conversation_id: m.conversation_id, sender_id: m.sender_id, content: m.content,
            reply_to_id: m.reply_to_id, is_read: m.is_read, read_at: m.read_at,
            type: m.type, created_at: m.created_at
          },
          create: {
            id: m.id, conversation_id: m.conversation_id, sender_id: m.sender_id, content: m.content,
            reply_to_id: m.reply_to_id, is_read: m.is_read, read_at: m.read_at,
            type: m.type, created_at: m.created_at
          }
        });
      }
      console.log(`✅ ${msgs.length} messages migrés.`);
    }

    // 9. ROOMS
    console.log('\n📦 Migration des Salles...');
    const roomsCheck = await sbClient.query(`SELECT to_regclass('public.rooms') as exists;`);
    if (roomsCheck.rows[0].exists) {
      const { rows: rooms } = await sbClient.query('SELECT * FROM public.rooms');
      for (const r of rooms) {
        await prisma.rooms.upsert({
          where: { id: r.id },
          update: {
            name: r.name || `Salle ${r.id}`, capacity: r.capacity, building: r.building,
            floor: r.floor, is_available: r.is_available, created_at: r.created_at
          },
          create: {
            id: r.id, name: r.name || `Salle ${r.id}`, capacity: r.capacity, building: r.building,
            floor: r.floor, is_available: r.is_available, created_at: r.created_at
          }
        });
      }
      console.log(`✅ ${rooms.length} salles migrées.`);
    }

    // 10. RESOURCES
    console.log('\n📦 Migration des Ressources...');
    const resourcesCheck = await sbClient.query(`SELECT to_regclass('public.resources') as exists;`);
    if (resourcesCheck.rows[0].exists) {
      const { rows: resources } = await sbClient.query('SELECT * FROM public.resources');
      for (const res of resources) {
        await prisma.resources.upsert({
          where: { id: res.id },
          update: {
            title: res.title, description: res.description, url: res.url,
            type: res.type, course_id: res.course_id, teacher_id: res.teacher_id,
            author_name: res.author_name, scope: res.scope, 
            department_id: res.department_id, faculty_id: res.faculty_id,
            niveau: res.niveau, created_at: res.created_at
          },
          create: {
            id: res.id, title: res.title, description: res.description, url: res.url,
            type: res.type, course_id: res.course_id, teacher_id: res.teacher_id,
            author_name: res.author_name, scope: res.scope, 
            department_id: res.department_id, faculty_id: res.faculty_id,
            niveau: res.niveau, created_at: res.created_at
          }
        });
      }
      console.log(`✅ ${resources.length} ressources migrées.`);
    }

    console.log('\n🎉 Migration complète terminée avec succès !');

  } catch (error) {
    console.error('❌ Erreur lors de la migration:', error);
  } finally {
    await sbClient.end();
    await prisma.$disconnect();
    await localPool.end();
  }
}

migrate();
