import { getDb } from '../dbClient.js';
import bcrypt from 'bcryptjs';

export async function addPendingCode(email, name, password, code) {
  const db = getDb();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
  await db.collection('pending_codes').updateOne(
    { email },
    { $set: { email, name, password, code, createdAt: new Date(), expiresAt } },
    { upsert: true }
  );
}

export async function findPendingCode(email) {
  const db = getDb();
  return db.collection('pending_codes').findOne({ email });
}

export async function deletePendingCode(email) {
  const db = getDb();
  await db.collection('pending_codes').deleteOne({ email });
}

export async function insertUser(email, name, rawPassword) {
  const db = getDb();
  const hash = await bcrypt.hash(rawPassword, 10);
  await db.collection('users').insertOne({
    email,
    name,
    password: hash,
    createdAt: new Date(),
    goal: null,
    lastHeartRate: null,
    lastSteps: null
  });
}

export async function findUserByEmail(email) {
  const db = getDb();
  return db.collection('users').findOne({ email });
}

export async function findUserById(id) {
  const db = getDb();
  return db.collection('users').findOne({ _id: new (await import('mongodb')).ObjectId(id) });
}

export async function addResetCode(email, code) {
  const db = getDb();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
  await db.collection('reset_codes').updateOne(
    { email },
    { $set: { email, code, createdAt: new Date(), expiresAt } },
    { upsert: true }
  );
}

export async function findResetCode(email) {
  const db = getDb();
  return db.collection('reset_codes').findOne({ email });
}

export async function deleteResetCode(email) {
  const db = getDb();
  await db.collection('reset_codes').deleteOne({ email });
}

export async function updateUserPasswordByEmail(email, newPasswordRaw) {
  const db = getDb();
  const hash = await bcrypt.hash(newPasswordRaw, 10);
  await db.collection('users').updateOne(
    { email },
    { $set: { password: hash } }
  );
}

export async function updateUserName(userId, newName) {
  const db = getDb();
  await db.collection('users').updateOne(
    { _id: new (await import('mongodb')).ObjectId(userId) },
    { $set: { name: newName } }
  );
}

export async function updateUserGoal(userId, newGoal) {
  const db = getDb();
  await db.collection('users').updateOne(
    { _id: new (await import('mongodb')).ObjectId(userId) },
    { $set: { goal: newGoal ?? null } }
  );
}

export async function updateUserTracker(userId, lastHeartRate, lastSteps) {
  const db = getDb();
  await db.collection('users').updateOne(
    { _id: new (await import('mongodb')).ObjectId(userId) },
    { $set: { lastHeartRate: lastHeartRate ?? null, lastSteps: lastSteps ?? null } }
  );
}

export async function addDeleteCode(email, code) {
  const db = getDb();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000);
  await db.collection('delete_codes').updateOne(
    { email },
    { $set: { email, code, createdAt: new Date(), expiresAt } },
    { upsert: true }
  );
}

export async function findDeleteCode(email) {
  const db = getDb();
  return db.collection('delete_codes').findOne({ email });
}

export async function deleteDeleteCode(email) {
  const db = getDb();
  await db.collection('delete_codes').deleteOne({ email });
}

export async function deleteUserByEmail(email) {
  const db = getDb();
  await db.collection('users').deleteOne({ email });
}
