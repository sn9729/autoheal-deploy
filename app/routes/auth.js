const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const User = require('../models/User');

// GET Login Page
router.get('/login', (req, res) => {
  if (req.session.userId) return res.redirect('/tasks/dashboard');
  res.render('login', { error: null });
});

// POST Login Action
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (!user) {
      return res.render('login', { error: 'Invalid credentials' });
    }
    
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.render('login', { error: 'Invalid credentials' });
    }

    req.session.userId = user._id;
    res.redirect('/tasks/dashboard');
  } catch (err) {
    console.error(err);
    res.render('login', { error: 'Server error during login' });
  }
});

// GET Register Page
router.get('/register', (req, res) => {
  if (req.session.userId) return res.redirect('/tasks/dashboard');
  res.render('register', { error: null });
});

// POST Register Action
router.post('/register', async (req, res) => {
  const { name, email, password } = req.body;
  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.render('register', { error: 'Email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      name,
      email,
      password: hashedPassword
    });

    await user.save();
    
    req.session.userId = user._id;
    res.redirect('/tasks/dashboard');
  } catch (err) {
    console.error(err);
    res.render('register', { error: 'Server error during registration' });
  }
});

// GET Logout
router.get('/logout', (req, res) => {
  req.session.destroy(err => {
    if (err) console.error(err);
    res.redirect('/login');
  });
});

module.exports = router;
