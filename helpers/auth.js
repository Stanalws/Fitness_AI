// backend/helpers/auth.js
import jwt from 'jsonwebtoken';
export const JWT_SECRET = process.env.JWT_SECRET || 'verySecretKey';

// промежуточка: проверяет "Authorization: Bearer <token>"
export const auth = (req, res, next) => {
  const header = req.headers.authorization || '';
  const [, token] = header.split(' ');
  if (!token) return res.status(401).json({ error: 'Token required' });

  try {
    req.user = jwt.verify(token, JWT_SECRET);   // кладём payload в req.user
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
};
