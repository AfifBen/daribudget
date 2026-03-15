const express = require('express');
const db = require('../db');
const router = express.Router();

router.get('/', async (req, res) => {
  const { household_id, month } = req.query;
  try {
    const { rows } = await db.query(
      'SELECT * FROM budgets WHERE household_id=$1 AND month=$2',
      [household_id, month]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post('/', async (req, res) => {
  const { household_id, category_id, amount, month } = req.body;
  try {
    const { rows } = await db.query(
      'INSERT INTO budgets (household_id,category_id,amount,month) VALUES ($1,$2,$3,$4) RETURNING *',
      [household_id, category_id, amount, month]
    );
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
