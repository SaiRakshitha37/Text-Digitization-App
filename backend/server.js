require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const Tesseract = require('tesseract.js');
const fs = require('fs').promises;
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const upload = multer({ dest: 'uploads/' });

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Schema and Model for extracted texts
const textSchema = new mongoose.Schema({
  name: String,
  content: String,
  dateTime: Date,
});
const TextModel = mongoose.model('Text', textSchema);

// MongoDB Schema and Model for users
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  lastLogin: { type: Date }, // Added to track last login
});
const UserModel = mongoose.model('User', userSchema);

// Registration endpoint
app.post('/api/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;

    const existingUser = await UserModel.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new UserModel({
      email,
      password: hashedPassword,
      name,
    });
    await newUser.save();

    res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Registration failed', details: error.message });
  }
});

// Login endpoint
app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await UserModel.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid email or password' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid email or password' });
    }

    // Update user details in MongoDB (e.g., last login timestamp)
    user.lastLogin = new Date();
    await user.save();

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
    res.status(200).json({ token });
  } catch (error) {
    res.status(500).json({ message: 'Login failed', details: error.message });
  }
});

// Text extraction route
app.post('/api/extract-text', upload.single('image'), async (req, res) => {
  let imagePath;
  try {
    imagePath = req.file.path;
    console.log('Processing image: ' + imagePath);

    const result = await Tesseract.recognize(
      imagePath,
      'eng',
      { logger: m => console.log(m) }
    );
    console.log('OCR Result: ' + result.data.text);

    const newText = new TextModel({
      name: `Document ${await TextModel.countDocuments() + 1}`,
      content: result.data.text,
      dateTime: new Date(),
    });
    await newText.save();

    res.json({ extractedText: result.data.text });

    await fs.unlink(imagePath).catch(err => console.error('Error deleting file:', err));
  } catch (error) {
    console.error('OCR Error:', error);
    res.status(500).json({ error: 'OCR processing failed', details: error.message });

    if (imagePath) {
      await fs.unlink(imagePath).catch(err => console.error('Error deleting file in catch:', err));
    }
  }
});

// Get saved extracted texts
app.get('/api/getSavedTexts', async (req, res) => {
  try {
    const texts = await TextModel.find().sort({ dateTime: -1 });
    res.json(texts);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch texts' });
  }
});

// Connect to MongoDB and start server
const MONGO_URI = process.env.MONGO_URI;
mongoose.connect(MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.error('MongoDB connection error:', err));

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
// --------------------------------------------------------------------------------------
