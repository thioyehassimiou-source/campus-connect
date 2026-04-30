import { Router } from 'express';
import { getFaculties, getDepartments, getFilieres } from '../controllers/university.controller';

const router = Router();

router.get('/faculties', getFaculties);
router.get('/faculties/:facultyId/departments', getDepartments);
router.get('/departments/:departmentId/filieres', getFilieres);

export default router;
