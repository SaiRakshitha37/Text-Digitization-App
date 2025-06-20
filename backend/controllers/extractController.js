// controllers/extractController.js
const Text = require('../models/Text');
const tesseract = require('tesseract.js');

const extractText = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const imagePath = req.file.path;

    const { data: { text } } = await tesseract.recognize(imagePath, 'eng');

    const savedText = new Text({
      user: req.user.id,
      content: text,
      date: new Date()
    });

    await savedText.save();

    res.status(200).json({ message: 'Text extracted and saved successfully', text });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Text extraction failed' });
  }
};

module.exports = extractText; // ✅ Do NOT use curly braces
