import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const prisma = new PrismaClient();
const JWT_SECRET = 'campusconnect_secret_key_change_in_production';
const JWT_EXPIRES_IN = '7d';

async function main() {
  // Create Teacher
  const teacherEmail = 'teacher@test.com';
  let teacher = await prisma.users.findUnique({ where: { email: teacherEmail } });
  if (!teacher) {
    const hashedPassword = await bcrypt.hash('password123', 10);
    teacher = await prisma.users.create({
      data: {
        email: teacherEmail,
        password_hash: hashedPassword,
        role: 'Professeur',
        profiles: {
          create: {
            full_name: 'Dr. Test Teacher',
            role: 'Professeur'
          }
        }
      }
    });
  }

  // Create Student
  const studentEmail = 'student@test.com';
  let student = await prisma.users.findUnique({ where: { email: studentEmail } });
  if (!student) {
    const hashedPassword = await bcrypt.hash('password123', 10);
    student = await prisma.users.create({
      data: {
        email: studentEmail,
        password_hash: hashedPassword,
        role: 'Étudiant',
        profiles: {
          create: {
            full_name: 'Test Student',
            role: 'Étudiant'
          }
        }
      }
    });
  }

  const teacherToken = jwt.sign({ id: teacher.id, email: teacher.email, role: teacher.role }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN } as any);
  const studentToken = jwt.sign({ id: student.id, email: student.email, role: student.role }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN } as any);

  console.log('--- TEST DATA ---');
  console.log(`TEACHER_ID="${teacher.id}"`);
  console.log(`TEACHER_TOKEN="${teacherToken}"`);
  console.log(`STUDENT_ID="${student.id}"`);
  console.log(`STUDENT_TOKEN="${studentToken}"`);
  console.log('-----------------');
}

main().catch(console.error).finally(() => prisma.$disconnect());
