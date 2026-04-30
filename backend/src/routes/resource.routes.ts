import { Router } from 'express';
import { getResources, createResource } from '../controllers/resource.controller';
import { authenticate, requireRole } from '../middlewares/auth.middleware';

const router = Router();

router.get('/', authenticate, getResources);
router.post('/', authenticate, requireRole('Enseignant', 'Admin'), createResource);

export default router;
