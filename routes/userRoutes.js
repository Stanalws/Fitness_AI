import { Router } from 'express';
import {
  registerSendCode,
  registerConfirmCode,
  registerResendCode,
  loginUser,
  resetPasswordSendCode,
  resetPasswordConfirmCode,
  resetPasswordUpdate,
  getUserProfile,
  updateUserNameController,
  updateUserProfileCombined,
  updateUserGoalController,
  updateUserTrackerController,
  deleteSendCode,
  deleteConfirmCode
} from '../controllers/userController.js';
import { auth } from '../helpers/auth.js';

const router = Router();

router.post('/register', registerSendCode);
router.post('/resend', registerResendCode);
router.post('/confirm', registerConfirmCode);
router.post('/login', loginUser);
router.post('/reset-password', resetPasswordSendCode);
router.post('/reset-password/confirm-code', resetPasswordConfirmCode);
router.post('/reset-password/update', resetPasswordUpdate);
router.get('/profile', auth, getUserProfile);
router.patch('/profile/update-name', auth, updateUserNameController);
router.patch('/profile/update', auth, updateUserProfileCombined);
router.patch('/profile/update-goal', auth, updateUserGoalController);
router.patch('/profile/update-tracker', auth, updateUserTrackerController);
router.post('/delete/send', deleteSendCode);
router.post('/delete/confirm', deleteConfirmCode);

export default router;