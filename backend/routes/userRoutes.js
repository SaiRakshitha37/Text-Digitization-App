// const express = require('express');
// const router = express.Router();
// const User = require('../models/User');

// router.post('/saveUser', async (req, res) => {
//   const { email, name, password, googleSignIn } = req.body;

//   try {
//     let user = await User.findOne({ email });
//     if (user) {
//       return res.status(200).json({ message: 'User already exists' });
//     }

//     user = new User({ email, name, password, googleSignIn });
//     await user.save();
//     res.status(200).json({ message: 'User saved successfully' });
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ message: 'Server error' });
//   }
// });

// module.exports = router;

// const express = require('express');
// const router = express.Router();
// const User = require('../models/User');

// // POST /api/users/saveUser
// router.post('/saveUser', async (req, res) => {
//   const { email, name, password, googleSignIn } = req.body;

//   try {
//     let user = await User.findOne({ email });
//     if (user) {
//       return res.status(200).json({ message: 'User already exists' });
//     }

//     user = new User({ email, name, password, googleSignIn });
//     await user.save();

//     res.status(200).json({ message: 'User saved successfully' });
//   } catch (err) {
//     console.error('User save error:', err);
//     res.status(500).json({ message: 'Server error' });
//   }
// });

// module.exports = router;

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { registerUser } = require("../controllers/userController");
router.post("/register", registerUser);


// POST /api/users/saveUser
router.post('/saveUser', async (req, res) => {
  console.log('Received user save request:', req.body);

  const { email, name, password, googleSignIn } = req.body;

  try {
    let user = await User.findOne({ email });
    if (user) {
      console.log('User already exists:', email);
      return res.status(200).json({ message: 'User already exists' });
    }

    user = new User({ email, name, password, googleSignIn });
    await user.save();

    console.log('User saved successfully:', user);
    res.status(200).json({ message: 'User saved successfully' });
  } catch (err) {
    console.error('User save error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
