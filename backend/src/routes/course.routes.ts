import { Router } from 'express';
import { getCourses, createCourse, updateCourse, deleteCourse } from '../controllers/course.controller';
import { authenticate, requireRole } from '../middlewares/auth.middleware';

const router = Router();

router.get('/', authenticate, getCourses);
router.post('/', authenticate, requireRole('Enseignant', 'Admin'), createCourse);
router.patch('/:id', authenticate, requireRole('Enseignant', 'Admin'), updateCourse);
router.delete('/:id', authenticate, requireRole('Enseignant', 'Admin'), deleteCourse);

export default router;
