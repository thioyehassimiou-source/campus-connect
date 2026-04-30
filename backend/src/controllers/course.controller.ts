import { Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';
import { AuthRequest } from '../middlewares/auth.middleware';

// GET /courses
export const getCourses = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    
    let where: any = {};
    if (user.role === 'Enseignant') {
      where.teacher_id = user.id;
    }

    const courses = await prisma.courses.findMany({
      where,
      orderBy: { created_at: 'desc' },
    });

    sendSuccess(res, courses);
  } catch (error) {
    console.error('GetCourses error:', error);
    sendError(res, 'Erreur lors de la récupération des cours');
  }
};

// POST /courses
export const createCourse = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const { title, level, color, description, scope, departmentId, facultyId } = req.body;

    const course = await prisma.courses.create({
      data: {
        title,
        level: level || 'L1',
        color: color || '#2563EB',
        description,
        teacher_id: user.id,
        status: 'Actif',
        scope: scope || 'license',
        department_id: departmentId,
        faculty_id: facultyId,
      },
    });

    sendSuccess(res, course, 'Cours créé avec succès', 201);
  } catch (error) {
    sendError(res, 'Erreur lors de la création du cours');
  }
};

// PATCH /courses/:id
export const updateCourse = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params as Record<string, string>;
    const data = req.body;

    const course = await prisma.courses.update({
      where: { id },
      data,
    });

    sendSuccess(res, course, 'Cours mis à jour');
  } catch (error) {
    sendError(res, 'Erreur lors de la mise à jour du cours');
  }
};

// DELETE /courses/:id
export const deleteCourse = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params as Record<string, string>;
    await prisma.courses.delete({ where: { id } });
    sendSuccess(res, null, 'Cours supprimé');
  } catch (error) {
    sendError(res, 'Erreur lors de la suppression du cours');
  }
};
