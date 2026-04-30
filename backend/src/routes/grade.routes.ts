import { Router } from 'express';
import { getMyGrades, getTeacherGrades, addGrade } from '../controllers/grade.controller';
import { authenticate, requireRole } from '../middlewares/auth.middleware';

const router = Router();

router.get('/my', authenticate, getMyGrades);
router.get('/teacher', authenticate, requireRole('Enseignant', 'Admin'), getTeacherGrades);
router.post('/', authenticate, requireRole('Enseignant', 'Admin'), addGrade);

export default router;
