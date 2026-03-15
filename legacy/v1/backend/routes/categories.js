const express = require('express');
const db = require('../db');
const router = express.Router();

router.get('/', async (req, res) => {
  const { household_id } = req.query;
  try {
    const { rows } = await db.query('SELECT * FROM categories WHERE household_id=$1', [household_id]);
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post('/', async (req, res) => {
  const { household_id, name, color } = req.body;
  try {
    const { rows } = await db.query(
      'INSERT INTO categories (household_id,name,color) VALUES ($1,$2,$3) RETURNING *',
      [household_id, name, color || null]
    );
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
