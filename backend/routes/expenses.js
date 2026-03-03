const express = require('express');
const db = require('../db');
const router = express.Router();

// List expenses
router.get('/', async (req, res) => {
  const { household_id, month } = req.query;
  try {
    const params = [];
    let where = '';
    if (household_id) {
      params.push(household_id);
      where += ` WHERE household_id = $${params.length}`;
    }
    if (month) {
      params.push(month);
      where += (where ? ' AND' : ' WHERE') + ` to_char(spent_at, 'YYYY-MM') = $${params.length}`;
    }
    const { rows } = await db.query(`SELECT * FROM expenses${where} ORDER BY spent_at DESC`, params);
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Create expense
router.post('/', async (req, res) => {
  const { household_id, category_id, amount, note, spent_at } = req.body;
  try {
    const { rows } = await db.query(
      `INSERT INTO expenses (household_id, category_id, amount, note, spent_at)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [household_id, category_id, amount, note || null, spent_at]
    );
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Update expense
router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { category_id, amount, note, spent_at } = req.body;
  try {
    const { rows } = await db.query(
      `UPDATE expenses SET category_id=$1, amount=$2, note=$3, spent_at=$4 WHERE id=$5 RETURNING *`,
      [category_id, amount, note || null, spent_at, id]
    );
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// Delete expense
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await db.query('DELETE FROM expenses WHERE id=$1', [id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
