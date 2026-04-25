const express = require('express');
const mongoose = require('mongoose');
const session = require('express-session');
const path = require('path');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();

// Connect to MongoDB
const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/taskmanager';
mongoose.connect(mongoURI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.log('MongoDB Connection Error: ', err));

// EJS setup
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Session setup
app.use(session({
  secret: process.env.SESSION_SECRET || 'autoheal_super_secret',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false } // Set to true if using HTTPS in production
}));

// Global variable for templates
app.use((req, res, next) => {
  res.locals.userId = req.session.userId || null;
  next();
});

// Routes
const authRoutes = require('./routes/auth');
const taskRoutes = require('./routes/tasks');
const healthRoutes = require('./routes/health');

app.use('/', authRoutes);
app.use('/tasks', taskRoutes);
app.use('/health', healthRoutes);

// Home Route
app.get('/', (req, res) => {
  if (req.session.userId) {
    res.redirect('/tasks/dashboard');
  } else {
    res.redirect('/login');
  }
});

// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
