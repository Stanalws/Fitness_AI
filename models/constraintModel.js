import { getDb } from '../dbClient.js';

export async function getAllConstraints() {
  const db = getDb();
  return db.collection('contraindications').find().toArray();
}
