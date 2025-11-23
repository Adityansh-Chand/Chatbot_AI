const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

app.use(cors()); // Allow requests from our Flutter app
app.use(express.json());

// Mock Database
const employeeData = {
    "123": {
        casual_leave_balance: 5,
        sick_leave_balance: 8,
        annual_leave_balance: 12
    },
    "456": {
        casual_leave_balance: 2,
        sick_leave_balance: 0,
        annual_leave_balance: 20
    }
};

// Define the GET endpoint
app.get('/leave-balance', (req, res) => {
    const employeeId = req.query.employee_id;
    console.log(`Received request for employee: ${employeeId}`);

    if (employeeData[employeeId]) {
        // Simulate database delay
        setTimeout(() => {
            res.json(employeeData[employeeId]);
        }, 500);
    } else {
        res.status(404).json({ error: "Employee not found" });
    }
});

// Start the server
app.listen(port, () => {
    console.log(`HR Backend API running at http://localhost:${port}`);
});