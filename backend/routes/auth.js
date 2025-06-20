// const express = require('express');
// const bcrypt = require('bcryptjs');
// const jwt = require('jsonwebtoken');
// const User = require('../models/User');
// const router = express.Router();

// const SECRET = 'your_jwt_secret'; // Store in .env in production

// router.post('/register', async (req, res) => {
//   const { email, password } = req.body;
//   const hashed = await bcrypt.hash(password, 10);
//   try {
//     const newUser = new User({ email, password: hashed });
//     await newUser.save();
//     res.status(200).json({ message: 'User registered' });
//   } catch (err) {
//     res.status(400).json({ error: 'Email already exists' });
//   }
// });

// router.post('/login', async (req, res) => {
//   const { email, password } = req.body;
//   const user = await User.findOne({ email });
//   if (!user) return res.status(401).json({ error: 'Invalid credentials' });

//   const match = await bcrypt.compare(password, user.password);
//   if (!match) return res.status(401).json({ error: 'Invalid credentials' });

//   const token = jwt.sign({ userId: user._id }, SECRET, { expiresIn: '1h' });
//   res.status(200).json({ token });
// });

// module.exports = router;

// const express = require('express');
// const bcrypt = require('bcryptjs');
// const jwt = require('jsonwebtoken');
// const User = require('../models/User');
// const router = express.Router();

// const SECRET = 'your_jwt_secret'; // use dotenv in production

// // Register user (normal or Google)
// router.post('/register', async (req, res) => {
//   const { email, password, name, googleSignIn } = req.body;

//   try {
//     // Check if user already exists
//     const existingUser = await User.findOne({ email });
//     if (existingUser) {
//       return res.status(400).json({ error: 'Email already exists' });
//     }

//     // Hash password if not from Google
//     const hashedPassword = googleSignIn ? '' : await bcrypt.hash(password, 10);

//     // Create user
//     const newUser = new User({
//       email,
//       name,
//       password: hashedPassword,
//       googleSignIn
//     });

//     await newUser.save();
//     res.status(201).json({ message: 'User registered successfully' });
//   } catch (err) {
//     console.error('Registration error:', err);
//     res.status(500).json({ error: 'Server error', details: err.message });
//   }
// });

// // Login user
// router.post('/login', async (req, res) => {
//   const { email, password } = req.body;

//   try {
//     const user = await User.findOne({ email });
//     if (!user) return res.status(401).json({ error: 'Invalid credentials' });

//     if (user.googleSignIn) {
//       return res.status(400).json({ error: 'Use Google Sign-In instead' });
//     }

//     const match = await bcrypt.compare(password, user.password);
//     if (!match) return res.status(401).json({ error: 'Invalid credentials' });

//     const token = jwt.sign({ userId: user._id }, SECRET, { expiresIn: '1h' });
//     res.status(200).json({ token });
//   } catch (err) {
//     console.error('Login error:', err);
//     res.status(500).json({ error: 'Server error' });
//   }
// });

// module.exports = router;

const express = require('express');
const router = express.Router();
const User = require('../models/User');

router.post('/register', async (req, res) => {
  const { email, name, password } = req.body;

  try {
    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ message: 'User already exists' });

    const newUser = new User({ email, name, password, googleSignIn: false });
    await newUser.save();

    res.status(201).json({ message: 'User registered', userId: newUser._id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Registration error' });
  }
});

module.exports = router;
