import { Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';
import { AuthRequest } from '../middlewares/auth.middleware';

// GET /attendance/student
export const getStudentAttendance = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const attendance = await prisma.attendance.findMany({
      where: { student_id: user.id },
      include: { courses: true },
      orderBy: { date: 'desc' },
    });
    sendSuccess(res, attendance);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des présences');
  }
};

// GET /attendance/course/:courseId
export const getAttendanceForDate = async (req: AuthRequest, res: Response) => {
  try {
    const { courseId } = req.params as Record<string, string>;
    const { date } = req.query as Record<string, string>;

    const attendance = await prisma.attendance.findMany({
      where: {
        course_id: courseId,
        date: date ? new Date(date as string) : undefined,
      },
      include: { users_attendance_student_idTousers: { include: { profiles: true } } },
    });

    sendSuccess(res, attendance);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des présences pour ce cours');
  }
};

// POST /attendance/upsert
export const upsertAttendance = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const records = req.body; // Expecting Array<{ student_id, course, status, date }>

    if (!Array.isArray(records)) {
      return sendError(res, 'Format invalide, tableau attendu', 400);
    }

    // Process records
    const operations = records.map((record) => {
      return prisma.attendance.upsert({
        where: {
          // This assumes a unique constraint on [student_id, course_id, date]
          // If not exist, we use a fallback or manual check
          id: record.id || '00000000-0000-0000-0000-000000000000', 
        },
        update: {
          status: record.status,
          comment: record.comment,
        },
        create: {
          student_id: record.student_id,
          course_id: record.course,
          teacher_id: user.id,
          date: new Date(record.date),
          status: record.status,
          comment: record.comment,
        },
      });
    });

    // In a real scenario, we should handle unique constraints properly.
    // For now, let's use a simpler approach if we don't have a composite unique key.
    
    for (const record of records) {
        // Simple manual upsert logic if composite unique is missing
        const existing = await prisma.attendance.findFirst({
            where: {
                student_id: record.student_id,
                course_id: record.course,
                date: new Date(record.date)
            }
        });

        if (existing) {
            await prisma.attendance.update({
                where: { id: existing.id },
                data: { status: record.status }
            });
        } else {
            await prisma.attendance.create({
                data: {
                    student_id: record.student_id,
                    course_id: record.course,
                    teacher_id: user.id,
                    date: new Date(record.date),
                    status: record.status
                }
            });
        }
    }

    sendSuccess(res, null, 'Présences enregistrées avec succès');
  } catch (error) {
    console.error('UpsertAttendance error:', error);
    sendError(res, 'Erreur lors de l\'enregistrement des présences');
  }
};
