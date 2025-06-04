import { Router } from 'express';
import { listConstraints } from '../controllers/constraintController.js';

const router = Router();
router.get('/', listConstraints);

export default router;