#!/bin/bash

DB_NAME="atm.db"

# Create database and users table
sqlite3 $DB_NAME <<EOF
CREATE TABLE IF NOT EXISTS users (
    account_number TEXT PRIMARY KEY,
    pin TEXT NOT NULL,
    balance REAL NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_number TEXT NOT NULL,
    type TEXT NOT NULL,
    amount REAL NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF

echo "Database setup complete."

