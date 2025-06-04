import { MongoClient } from 'mongodb';

let _db = null;

export async function connectDb() {
  if (_db) return _db;
  const client = await MongoClient.connect('mongodb://127.0.0.1:27017', {
    useUnifiedTopology: true
  });
  _db = client.db('fitness_ai');
  return _db;
}

export function getDb() {
  if (!_db) throw new Error('Database not initialized. Call connectDb first.');
  return _db;
}
