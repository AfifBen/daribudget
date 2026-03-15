const express = require('express');
const db = require('../db');
const router = express.Router();

router.get('/', async (req, res) => {
  const { household_id } = req.query;
  try {
    const { rows } = await db.query('SELECT * FROM shopping_items WHERE household_id=$1 ORDER BY created_at DESC', [household_id]);
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.post('/', async (req, res) => {
  const { household_id, name, category } = req.body;
  try {
    const { rows } = await db.query(
      'INSERT INTO shopping_items (household_id,name,category) VALUES ($1,$2,$3) RETURNING *',
      [household_id, name, category || null]
    );
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { done } = req.body;
  try {
    const { rows } = await db.query('UPDATE shopping_items SET done=$1 WHERE id=$2 RETURNING *', [done, id]);
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await db.query('DELETE FROM shopping_items WHERE id=$1', [id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
