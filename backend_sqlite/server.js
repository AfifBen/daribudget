const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const Database = require('better-sqlite3');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;
const db = new Database(process.env.SQLITE_PATH || 'daribudget.db');

app.use(cors({ origin: '*', credentials: true }));
app.use(express.json());

// Init schema
const schema = `
CREATE TABLE IF NOT EXISTS expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER,
  amount REAL,
  note TEXT,
  spent_at TEXT
);
CREATE TABLE IF NOT EXISTS budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER,
  amount REAL,
  month TEXT
);
CREATE TABLE IF NOT EXISTS shopping_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT,
  category TEXT,
  done INTEGER DEFAULT 0
);
`;

db.exec(schema);

app.get('/api/health', (req,res) => res.json({ status: 'ok' }));

app.get('/api/expenses', (req,res) => {
  const rows = db.prepare('SELECT * FROM expenses ORDER BY spent_at DESC').all();
  res.json({ success:true, data: rows });
});
app.post('/api/expenses', (req,res) => {
  const { category_id, amount, note, spent_at } = req.body;
  const stmt = db.prepare('INSERT INTO expenses (category_id,amount,note,spent_at) VALUES (?,?,?,?)');
  const info = stmt.run(category_id, amount, note, spent_at);
  const row = db.prepare('SELECT * FROM expenses WHERE id=?').get(info.lastInsertRowid);
  res.json({ success:true, data: row });
});

app.get('/api/budgets', (req,res) => {
  const rows = db.prepare('SELECT * FROM budgets').all();
  res.json({ success:true, data: rows });
});
app.post('/api/budgets', (req,res) => {
  const { category_id, amount, month } = req.body;
  const stmt = db.prepare('INSERT INTO budgets (category_id,amount,month) VALUES (?,?,?)');
  const info = stmt.run(category_id, amount, month);
  const row = db.prepare('SELECT * FROM budgets WHERE id=?').get(info.lastInsertRowid);
  res.json({ success:true, data: row });
});

app.get('/api/shopping', (req,res) => {
  const rows = db.prepare('SELECT * FROM shopping_items').all();
  res.json({ success:true, data: rows });
});
app.post('/api/shopping', (req,res) => {
  const { name, category } = req.body;
  const stmt = db.prepare('INSERT INTO shopping_items (name,category) VALUES (?,?)');
  const info = stmt.run(name, category);
  const row = db.prepare('SELECT * FROM shopping_items WHERE id=?').get(info.lastInsertRowid);
  res.json({ success:true, data: row });
});

app.listen(PORT, ()=> console.log('SQLite backend on', PORT));
