import { Response } from 'express';
import prisma from '../lib/prisma';
import { sendSuccess, sendError } from '../utils/response.util';
import { AuthRequest } from '../middlewares/auth.middleware';

// GET /assignments/student
export const getStudentAssignments = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const assignments = await prisma.assignments.findMany({
      where: {
        courses: {
          enrollments: {
            some: { student_id: user.id }
          }
        }
      },
      include: { courses: true },
      orderBy: { due_date: 'asc' },
    });
    sendSuccess(res, assignments);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des devoirs');
  }
};

// GET /assignments/teacher
export const getTeacherAssignments = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const assignments = await prisma.assignments.findMany({
      where: { courses: { teacher_id: user.id } },
      include: { courses: true },
      orderBy: { due_date: 'asc' },
    });
    sendSuccess(res, assignments);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des devoirs prof');
  }
};

// POST /assignments
export const createAssignment = async (req: AuthRequest, res: Response) => {
  try {
    const { title, description, due_date, course, priority, type } = req.body;

    const assignment = await prisma.assignments.create({
      data: {
        title,
        description,
        due_date: new Date(due_date),
        course_id: course,
        priority: priority || 'medium',
        type: type || 'Devoir',
      },
    });

    sendSuccess(res, assignment, 'Devoir créé avec succès', 201);
  } catch (error) {
    sendError(res, 'Erreur lors de la création du devoir');
  }
};

// POST /assignments/:id/submit
export const submitAssignment = async (req: AuthRequest, res: Response) => {
  try {
    const user = req.user!;
    const { id } = req.params as Record<string, string>;
    const { content } = req.body;

    const submission = await prisma.submissions.create({
      data: {
        assignment_id: id,
        student_id: user.id,
        content,
        submitted_at: new Date(),
        status: 'Soumis',
      },
    });

    sendSuccess(res, submission, 'Devoir soumis avec succès', 201);
  } catch (error) {
    sendError(res, 'Erreur lors de la soumission');
  }
};

// GET /assignments/:id/submissions
export const getAssignmentSubmissions = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = req.params as Record<string, string>;
    const submissions = await prisma.submissions.findMany({
      where: { assignment_id: id },
      include: { users_submissions_student_idTousers: { include: { profiles: true } } },
    });
    sendSuccess(res, submissions);
  } catch (error) {
    sendError(res, 'Erreur lors de la récupération des soumissions');
  }
};
