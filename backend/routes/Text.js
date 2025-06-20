// models/Text.js
// const mongoose = require('mongoose');

// const textSchema = new mongoose.Schema({
//   user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
//   content: String,
//   date: Date,
// });

// module.exports = mongoose.model('Text', textSchema);

const express = require('express');
const router = express.Router();
const Text = require('../models/Text');

// Save text (unchanged)
router.post('/saveText', async (req, res) => {
  const { name,userId, content } = req.body;
  try {
    const newText = new Text({ user: userId, content });
    await newText.save();
    res.status(200).json({ success: true, text: newText });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Failed to save text', error: err });
  }
});

// Get saved (non-deleted) texts
router.get('/getSavedTexts/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const texts = await Text.find({ user: userId, isDeleted: false }).sort({ date: -1 });
    res.status(200).json(texts);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch texts' });
  }
});

// ✅ Soft delete a text
router.post('/deleteText', async (req, res) => {
  const { userId, textId } = req.body;
  try {
    await Text.updateOne(
      { _id: textId, user: userId },
      { $set: { isDeleted: true, deletedAt: new Date() } }
    );
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Delete failed' });
  }
});

// ✅ Get deleted texts
router.get('/deleted-texts/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const deletedDocs = await Text.find({ user: userId, isDeleted: true }).sort({ deletedAt: -1 });
    res.json(deletedDocs);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch deleted documents' });
  }
});

module.exports = router;
