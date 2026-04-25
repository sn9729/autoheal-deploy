const express = require('express');
const router = express.Router();
const Task = require('../models/Task');
const authMiddleware = require('../middleware/authMiddleware');

// Protect all task routes
router.use(authMiddleware);

// GET Dashboard (View tasks)
router.get('/dashboard', async (req, res) => {
  try {
    const { search, priority, status } = req.query;
    
    // Build query object
    const query = { user: req.session.userId };
    
    if (search) {
      query.title = { $regex: search, $options: 'i' };
    }
    
    if (priority && priority !== 'all') {
      query.priority = priority;
    }
    
    if (status && status !== 'all') {
      query.completed = status === 'completed';
    }

    // Fetch filtered tasks, sorting incomplete first, then by due date
    const tasks = await Task.find(query).sort({ completed: 1, dueDate: 1, createdAt: -1 });

    // Fetch ALL tasks for analytics (ignoring filters)
    const allTasks = await Task.find({ user: req.session.userId });
    
    const stats = {
      total: allTasks.length,
      completed: allTasks.filter(t => t.completed).length,
      pending: allTasks.filter(t => !t.completed).length,
      highPriorityPending: allTasks.filter(t => t.priority === 'high' && !t.completed).length
    };
    stats.progress = stats.total === 0 ? 0 : Math.round((stats.completed / stats.total) * 100);

    res.render('dashboard', { 
      tasks, 
      stats, 
      filters: { search: search || '', priority: priority || 'all', status: status || 'all' }
    });
  } catch (err) {
    console.error(err);
    res.status(500).send('Server Error');
  }
});

// GET Add Task form
router.get('/add', (req, res) => {
  res.render('addTask');
});

// POST Add Task
router.post('/add', async (req, res) => {
  const { title, description, dueDate, priority } = req.body;
  try {
    const newTask = new Task({
      title,
      description,
      dueDate: dueDate || null,
      priority,
      user: req.session.userId
    });
    await newTask.save();
    res.redirect('/tasks/dashboard');
  } catch (err) {
    console.error(err);
    res.status(500).send('Server Error');
  }
});

// GET Edit Task form
router.get('/edit/:id', async (req, res) => {
  try {
    const task = await Task.findOne({ _id: req.params.id, user: req.session.userId });
    if (!task) return res.redirect('/tasks/dashboard');
    res.render('editTask', { task });
  } catch (err) {
    console.error(err);
    res.status(500).send('Server Error');
  }
});

// POST Edit Task
router.post('/edit/:id', async (req, res) => {
  const { title, description, dueDate, priority, completed } = req.body;
  const isCompleted = completed === 'on' || completed === 'true';

  try {
    await Task.findOneAndUpdate(
      { _id: req.params.id, user: req.session.userId },
      { title, description, dueDate: dueDate || null, priority, completed: isCompleted }
    );
    res.redirect('/tasks/dashboard');
  } catch (err) {
    console.error(err);
    res.status(500).send('Server Error');
  }
});

// POST Toggle Complete
router.post('/toggle/:id', async (req, res) => {
  try {
    const task = await Task.findOne({ _id: req.params.id, user: req.session.userId });
    if (task) {
      task.completed = !task.completed;
      await task.save();
    }
    res.redirect('/tasks/dashboard');
  } catch (err) {
    console.error(err);
    res.status(500).send('Server Error');
  }
});

// POST Delete Task
router.post('/delete/:id', async (req, res) => {
  try {
    await Task.findOneAndDelete({ _id: req.params.id, user: req.session.userId });
    res.redirect('/tasks/dashboard');
  } catch (err) {
    console.error(err);
    res.status(500).send('Server Error');
  }
});

module.exports = router;
