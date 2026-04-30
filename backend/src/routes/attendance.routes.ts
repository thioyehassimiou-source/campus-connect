import { Router } from 'express';
import { getStudentAttendance, getAttendanceForDate, upsertAttendance } from '../controllers/attendance.controller';
import { authenticate, requireRole } from '../middlewares/auth.middleware';

const router = Router();

router.get('/student', authenticate, getStudentAttendance);
router.get('/course/:courseId', authenticate, requireRole('Enseignant', 'Admin'), getAttendanceForDate);
router.post('/upsert', authenticate, requireRole('Enseignant', 'Admin'), upsertAttendance);

export default router;
