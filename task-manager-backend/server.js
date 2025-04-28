const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Kết nối MongoDB
mongoose.connect('mongodb://localhost:27017/task-manager', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log('MongoDB connected'))
.catch(err => console.error('MongoDB connection error:', err));

// Mô hình User
const userSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    username: { type: String, required: true },
});
const User = mongoose.model('User', userSchema);

// Mô hình Task
const taskSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: String,
    completed: { type: Boolean, default: false },
    userId: { type: String, required: true },
    dueDate: Date,
    status: { type: String, default: 'To do' },
    priority: { type: Number, default: 1 },
    assignedTo: String,
    createdBy: { type: String, required: true },
    category: String,
    attachments: [String],
});
const Task = mongoose.model('Task', taskSchema);

// Route đăng ký
app.post('/api/auth/register', async (req, res) => {
    try {
        const { email, password, username } = req.body;
        if (!email || !password || !username) {
            return res.status(400).json({ error: 'Email, password, and username are required' });
        }
        const user = new User({ email, password, username });
        await user.save();
        res.status(201).json({ user: { _id: user._id, email: user.email, username: user.username } });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Route đăng nhập
app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }
        const user = await User.findOne({ email, password });
        if (user) {
            res.status(200).json({ user: { _id: user._id, email: user.email, username: user.username } });
        } else {
            res.status(401).json({ error: 'Invalid credentials' });
        }
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Route lấy danh sách tác vụ
app.get('/api/tasks/:userId', async (req, res) => {
    try {
        const tasks = await Task.find({ userId: req.params.userId });
        res.status(200).json(tasks);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Route thêm tác vụ
app.post('/api/tasks', async (req, res) => {
    try {
        const { title, description, completed, dueDate, status, priority, assignedTo, category, attachments, userId } = req.body;
        if (!title || !userId) {
            return res.status(400).json({ error: 'Title and userId are required' });
        }
        const task = new Task({
            title,
            description,
            completed: completed || false,
            userId,
            createdBy: userId,
            dueDate,
            status: status || 'To do',
            priority: priority || 1,
            assignedTo,
            category,
            attachments: attachments || [],
        });
        await task.save();
        res.status(201).json(task);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Route cập nhật tác vụ
app.put('/api/tasks/:taskId', async (req, res) => {
    try {
        const { userId } = req.body;
        const task = await Task.findById(req.params.taskId);
        if (!task) {
            return res.status(404).json({ error: 'Task not found' });
        }
        if (task.userId !== userId) {
            return res.status(403).json({ error: 'Unauthorized: You can only update your own tasks' });
        }
        const updatedTask = await Task.findByIdAndUpdate(req.params.taskId, req.body, { new: true });
        res.status(200).json(updatedTask);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// Route xóa tác vụ
app.delete('/api/tasks/:taskId', async (req, res) => {
    try {
        const { userId } = req.body;
        const task = await Task.findById(req.params.taskId);
        if (!task) {
            return res.status(404).json({ error: 'Task not found' });
        }
        if (task.userId !== userId) {
            return res.status(403).json({ error: 'Unauthorized: You can only delete your own tasks' });
        }
        await Task.findByIdAndDelete(req.params.taskId);
        res.status(200).json({});
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));