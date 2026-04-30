import { Router } from 'express';
import { getAnnouncements, createAnnouncement, deleteAnnouncement } from '../controllers/announcement.controller';
import { authenticate, requireRole } from '../middlewares/auth.middleware';

const router = Router();

router.get('/', authenticate, getAnnouncements);
router.post('/', authenticate, requireRole('Enseignant', 'Admin'), createAnnouncement);
router.delete('/:id', authenticate, requireRole('Admin'), deleteAnnouncement);

export default router;
