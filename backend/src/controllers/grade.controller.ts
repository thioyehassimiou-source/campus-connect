import { Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';
import { AuthRequest } from '../middlewares/auth.middleware';

// GET /grades/my (Étudiant)
export const getMyGrades = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const grades = await prisma.grades.findMany({
      where: { student_id: user.id },
      include: { courses: true },
      orderBy: { created_at: 'desc' },
    });
    sendSuccess(res, grades);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des notes');
  }
};

// GET /grades/teacher (Enseignant)
export const getTeacherGrades = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const grades = await prisma.grades.findMany({
      where: { teacher_id: user.id },
      include: { courses: true, users_grades_student_idTousers: { include: { profiles: true } } },
      orderBy: { created_at: 'desc' },
    });
    sendSuccess(res, grades);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des notes prof');
  }
};

// POST /grades (Prof)
export const addGrade = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const { student_id, course_id, grade, comment, semester } = req.body;

    const newGrade = await prisma.grades.create({
      data: {
        student_id,
        course_id,
        teacher_id: user.id,
        grade: Number(grade),
        comment,
        semester: semester || 'S1',
      },
    });

    sendSuccess(res, newGrade, 'Note ajoutée avec succès', 201);
  } catch (error) {
    console.error('AddGrade error:', error);
    sendError(res, 'Erreur lors de l\'ajout de la note');
  }
};
