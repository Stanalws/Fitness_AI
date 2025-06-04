import {
  addPendingCode,
  findPendingCode,
  deletePendingCode,
  insertUser,
  findUserByEmail,
  findUserById,
  addResetCode,
  findResetCode,
  deleteResetCode,
  updateUserPasswordByEmail,
  updateUserName,
  updateUserGoal,
  updateUserTracker,
  addDeleteCode,
  findDeleteCode,
  deleteDeleteCode,
  deleteUserByEmail
} from '../models/userModel.js';
import nodemailer from 'nodemailer';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { auth, JWT_SECRET } from '../helpers/auth.js';

const transporter = nodemailer.createTransport({
  host: 'smtp.mail.ru',
  port: 465,
  secure: true,
  auth: {
    user: 'dstenyushkin@internet.ru',
    pass: '7trd7zCHdf1N0tfYjrby'
  }
});

const isValidEmail = (e) => /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(e);
const generateCode = (len = 6) => Array.from({ length: len }, () => Math.floor(Math.random() * 10)).join('');

export async function registerSendCode(req, res) {
  const { email, name, password } = req.body;
  if (!email || !name || !password) {
    return res.status(400).json({ error: 'Необходимо указать email, имя и пароль' });
  }
  if (!isValidEmail(email)) {
    return res.status(400).json({ error: 'Неверный email' });
  }
  try {
    if (await findUserByEmail(email)) {
      return res.status(400).json({ error: 'Данный Email уже зарегистрирован' });
    }
    const code = generateCode();
    await addPendingCode(email, name, password, code);
    await transporter.sendMail({
      from: '"Fitness AI" <dstenyushkin@internet.ru>',
      to: email,
      subject: 'Код подтверждения для регистрации',
      html: `
        <h2>Здравствуйте, <b>${name}</b>!</h2>
        <p>Введите этот код для подтверждения регистрации:</p>
        <pre style="font-size:24px; letter-spacing:4px;">${code}</pre>
        <p>Код действителен 10 минут.</p>
        <hr><p>Команда Fitness AI</p>`
    });
    res.json({ message: 'Код подтверждения отправлен' });
  } catch (e) {
    console.error('Register error:', e);
    res.status(500).json({ error: 'Ошибка регистрации' });
  }
}

export async function registerConfirmCode(req, res) {
  const { email, code } = req.body;
  if (!email || !code) {
    return res.status(400).json({ error: 'Необходимо указать email и код' });
  }
  try {
    const pending = await findPendingCode(email);
    if (!pending) {
      return res.status(400).json({ error: 'Срок действия кода истёк' });
    }
    if (pending.code !== code) {
      return res.status(400).json({ error: 'Неверный код' });
    }
    await insertUser(pending.email, pending.name, pending.password);
    await deletePendingCode(email);
    await transporter.sendMail({
      from: '"Fitness AI" <dstenyushkin@internet.ru>',
      to: email,
      subject: 'Добро пожаловать в Fitness AI',
      html: `
        <h2>Здравствуйте, <b>${pending.name}</b>!</h2>
        <p>Аккаунт успешно зарегистрирован.</p>
        <hr><p>Команда Fitness AI</p>`
    });
    res.json({ message: 'Пользователь успешно зарегистрирован' });
  } catch (e) {
    console.error('Confirm registration error:', e);
    res.status(500).json({ error: 'Не удалось подтвердить код' });
  }
}

export async function registerResendCode(req, res) {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ error: 'Необходимо указать email' });
  }
  try {
    const pending = await findPendingCode(email);
    if (!pending) {
      return res.status(400).json({ error: 'Код для данного email не найден' });
    }
    const code = generateCode();
    await addPendingCode(email, pending.name, pending.password, code);
    await transporter.sendMail({
      from: '"Fitness AI" <dstenyushkin@internet.ru>',
      to: email,
      subject: 'Новый код подтверждения регистрации',
      html: `
        <h2>Здравствуйте, <b>${pending.name}</b>!</h2>
        <p>Вот ваш новый код:</p>
        <pre style="font-size:24px; letter-spacing:4px;">${code}</pre>
        <p>Код действителен 10 минут.</p>
        <hr><p>Команда Fitness AI</p>`
    });
    res.json({ message: 'Новый код отправлен' });
  } catch (e) {
    console.error('Resend register mail error:', e);
    res.status(500).json({ error: 'Не удалось отправить новый код' });
  }
}

export async function loginUser(req, res) {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Необходимо указать email и пароль' });
  }
  try {
    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(401).json({ error: 'Пользователь не найден' });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Неверный пароль' });
    }
    const token = jwt.sign({ id: user._id.toString(), email: user.email }, JWT_SECRET, {
      expiresIn: '7d'
    });
    res.json({ token });
  } catch (e) {
    console.error('Login error:', e);
    res.status(500).json({ error: 'Ошибка авторизации' });
  }
}

export async function resetPasswordSendCode(req, res) {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ error: 'Необходимо указать email' });
  }
  try {
    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(400).json({ error: 'Пользователь не найден' });
    }
    const code = generateCode();
    await addResetCode(email, code);
    await transporter.sendMail({
      from: '"Fitness AI" <dstenyushkin@internet.ru>',
      to: email,
      subject: 'Код для сброса пароля',
      html: `
        <h2>Ваш новый код</h2>
        <p>Введите этот код для сброса пароля:</p>
        <pre style="font-size:24px; letter-spacing:4px;">${code}</pre>
        <p>Код действителен 10 минут.</p>
        <hr><p>Команда Fitness AI</p>`
    });
    res.json({ message: 'Код для сброса пароля отправлен' });
  } catch (e) {
    console.error('Reset send error:', e);
    res.status(500).json({ error: 'Не удалось отправить код' });
  }
}


export async function resetPasswordConfirmCode(req, res) {
  const { email, code } = req.body;
  if (!email || !code) {
    return res.status(400).json({ error: 'Укажите email и код' });
  }
  try {
    const rec = await findResetCode(email);
    if (!rec) {
      return res.status(400).json({ error: 'Срок действия кода истёк' });
    }
    if (rec.code !== code) {
      return res.status(400).json({ error: 'Неверный код' });
    }
    await deleteResetCode(email);
    res.json({ success: true });
  } catch (e) {
    console.error('Reset confirm error:', e);
    res.status(500).json({ error: 'Ошибка при подтверждении кода' });
  }
}

export async function resetPasswordUpdate(req, res) {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Укажите email и новый пароль' });
  }
  try {
    await updateUserPasswordByEmail(email, password);
    await transporter.sendMail({
      from: '"Fitness AI" <dstenyushkin@internet.ru>',
      to: email,
      subject: 'Пароль сброшен',
      html: `
        <h2>Пароль изменён</h2>
        <p>Ваш пароль успешно обновлён.</p>
        <hr><p>Команда Fitness AI</p>`
    });
    res.json({ message: 'Пароль обновлён' });
  } catch (err) {
    console.error('Reset update error:', err);
    res.status(500).json({ error: 'Не удалось обновить пароль' });
  }
}

export async function getUserProfile(req, res) {
  try {
    const user = await findUserById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: 'Пользователь не найден' });
    }
    res.json({
      _id: user._id,
      email: user.email,
      name: user.name,
      goal: user.goal,
      lastHeartRate: user.lastHeartRate,
      lastSteps: user.lastSteps
    });
  } catch (err) {
    console.error('Get profile error:', err);
    res.status(500).json({ error: 'Ошибка сервера при получении профиля' });
  }
}

export async function updateUserNameController(req, res) {
  const { name } = req.body;
  if (!name) {
    return res.status(400).json({ error: 'Необходимо указать новое имя' });
  }
  try {
    await updateUserName(req.user.id, name);
    res.json({ message: 'Имя измеено' });
  } catch (err) {
    console.error('update-name error:', err);
    res.status(500).json({ error: 'Ошибка изменения имени' });
  }
}


export async function updateUserProfileCombined(req, res) {
  const { name, goal, lastHeartRate, lastSteps } = req.body;
  try {
    await getUserProfile(req, res);
    await updateUserName(req.user.id, name);
    await updateUserGoal(req.user.id, goal ?? null);
    await updateUserTracker(req.user.id, lastHeartRate, lastSteps);
    const updated = await findUserById(req.user.id);
    res.json({
      _id: updated._id,
      email: updated.email,
      name: updated.name,
      goal: updated.goal,
      lastHeartRate: updated.lastHeartRate,
      lastSteps: updated.lastSteps
    });
  } catch (err) {
    console.error('Update-profile error:', err);
    res.status(500).json({ error: 'Ошибка обновления профиля' });
  }
}

export async function updateUserGoalController(req, res) {
  const { goal } = req.body;
  if (!goal) {
    return res.status(400).json({ error: 'Необходимо выбрать цель' });
  }
  try {
    await updateUserGoal(req.user.id, goal);
    res.json({ message: 'Цель изменена' });
  } catch (err) {
    console.error('Update-goal error:', err);
    res.status(500).json({ error: 'Ошибка обновления цели' });
  }
}

export async function updateUserTrackerController(req, res) {
  const { heartRate, steps } = req.body;
  try {
    await updateUserTracker(req.user.id, heartRate, steps);
    res.json({ message: 'Данные трекера сохранены' });
  } catch (err) {
    console.error('Update-tracker error:', err);
    res.status(500).json({ error: 'Ошибка сервера сохранения данных трекера' });
  }
}

export async function deleteSendCode(req, res) {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ error: 'Необходимо указать email' });
  }
  try {
    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(400).json({ error: 'Пользователь не найден' });
    }
    const code = generateCode();
    await addDeleteCode(email, code);
    await transporter.sendMail({
      from: '"Fitness AI" <dstenyushkin@internet.ru>',
      to: email,
      subject: 'Код для удаления аккаунта',
      html: `
        <h2>Новый код для удаления аккаунта</h2>
        <p>Введите этот код для подтверждения удаления:</p>
        <pre style="font-size:24px; letter-spacing:4px;">${code}</pre>
        <p>Код действителен 10 минут.</p>
        <hr><p>Команда Fitness AI</p>`
    });
    res.json({ message: 'Код для удаления аккаунта отправлен' });
  } catch (err) {
    console.error('Delete-send-code mail error:', err);
    res.status(500).json({ error: 'Не удалось отправить код для удаления' });
  }
}


export async function deleteConfirmCode(req, res) {
  const { email, code } = req.body;
  if (!email || !code) {
    return res.status(400).json({ error: 'Укажите email и код' });
  }
  try {
    const user = await findUserByEmail(email);
    if (!user) {
      return res.status(400).json({ error: 'Пользователь не найден' });
    }
    const rec = await findDeleteCode(email);
    if (!rec) {
      return res.status(400).json({ error: 'Срок действия кода истёк' });
    }
    if (rec.code !== code) {
      return res.status(400).json({ error: 'Неверный код' });
    }
    await deleteDeleteCode(email);
    await deleteUserByEmail(email);
    await transporter.sendMail({
      from: '"Fitness AI" <dstenyushkin@internet.ru>',
      to: email,
      subject: 'Ваш аккаунт удалён',
      html: `
        <h2>Ваш аккаунт удалён</h2>
        <p>Ваш аккаунт ${email} был успешно удалён из системы Fitness AI.</p>
        <hr><p>С уважением, команда Fitness AI</p>`
    });
    res.json({ message: 'Аккаунт удалён' });
  } catch (err) {
    console.error('Delete-account error:', err);
    res.status(500).json({ error: 'Ошибка удаления аккаунта' });
  }
}
