import { Router } from 'express';
import { getSchedules, createSchedule, updateScheduleStatus } from '../controllers/schedule.controller';
import { authenticate, requireRole } from '../middlewares/auth.middleware';

const router = Router();

router.get('/', authenticate, getSchedules);
router.post('/', authenticate, createSchedule);
router.patch('/:id/status', authenticate, requireRole('Admin'), updateScheduleStatus);

export default router;
