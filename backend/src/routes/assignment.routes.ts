import { Router } from 'express';
import { 
  getStudentAssignments, 
  getTeacherAssignments, 
  createAssignment, 
  submitAssignment, 
  getAssignmentSubmissions 
} from '../controllers/assignment.controller';
import { authenticate, requireRole } from '../middlewares/auth.middleware';

const router = Router();

router.get('/student', authenticate, getStudentAssignments);
router.get('/teacher', authenticate, requireRole('Enseignant', 'Admin'), getTeacherAssignments);
router.post('/', authenticate, requireRole('Enseignant', 'Admin'), createAssignment);
router.post('/:id/submit', authenticate, requireRole('Étudiant'), submitAssignment);
router.get('/:id/submissions', authenticate, requireRole('Enseignant', 'Admin'), getAssignmentSubmissions);

export default router;
