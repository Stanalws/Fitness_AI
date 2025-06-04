import { Router } from 'express';
import { auth } from '../helpers/auth.js';
import {
  createWorkoutController,
  getCurrentWorkoutController,
  completeWorkoutController,
} from '../controllers/workoutController.js';
import { getWorkoutHistoryController } from '../controllers/workoutController.js';

const router = Router();

router.post('/', auth, createWorkoutController);
router.get('/current', auth, getCurrentWorkoutController);
router.get('/history', auth, getWorkoutHistoryController);
router.post('/complete', auth, completeWorkoutController);

export default router;
