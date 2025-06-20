// routes/extract.js
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const authMiddleware = require('../middleware/authMiddleware');
const extractText = require('../controllers/extractController'); // ✅ No destructuring

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage });

router.post('/extract', authMiddleware, upload.single('image'), extractText); // ✅ This must be a function

module.exports = router;
