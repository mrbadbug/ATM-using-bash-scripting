#!/bin/bash

DB_NAME="atm.db"
HASH_PYTHON_SCRIPT="hash_pin.py"  # Python script to hash the PIN

# Function to check if user exists and PIN matches
authenticate() {
    local account_number=$1
    local pin=$2
    local hashed_pin=$(python3 $HASH_PYTHON_SCRIPT "$pin")

    # Query the database to check if the account and PIN match
    result=$(sqlite3 $DB_NAME "SELECT pin FROM users WHERE account_number = '$account_number'")

    if [ "$result" == "$hashed_pin" ]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Function to get balance
get_balance() {
    local account_number=$1
    sqlite3 $DB_NAME "SELECT balance FROM users WHERE account_number = '$account_number'"
}

# Function to update balance
update_balance() {
    local account_number=$1
    local amount=$2
    local transaction_type=$3

    # Update user balance and insert transaction
    sqlite3 $DB_NAME "UPDATE users SET balance = balance + $amount WHERE account_number = '$account_number'"
    sqlite3 $DB_NAME "INSERT INTO transactions (account_number, type, amount) VALUES ('$account_number', '$transaction_type', $amount)"
}

# Function to withdraw money
withdraw() {
    local account_number=$1
    local amount=$2
    balance=$(get_balance "$account_number")

    if (( $(echo "$amount > $balance" | bc -l) )); then
        echo "Insufficient funds."
    else
        update_balance "$account_number" "-$amount" "withdrawal"
        echo "Withdrawal successful. New balance: $(get_balance "$account_number")"
    fi
}

# Function to deposit money
deposit() {
    local account_number=$1
    local amount=$2
    update_balance "$account_number" "$amount" "deposit"
    echo "Deposit successful. New balance: $(get_balance "$account_number")"
}

# Function to create new user
create_user() {
    echo "Enter new account number: "
    read account_number
    echo "Enter new PIN: "
    read -s pin
    hashed_pin=$(python3 $HASH_PYTHON_SCRIPT "$pin")

    # Create a new account with initial balance of $100
    sqlite3 $DB_NAME "INSERT INTO users (account_number, pin, balance) VALUES ('$account_number', '$hashed_pin', 100.0)"
    echo "Account created successfully! Initial balance: $100"
}

# Main function to handle ATM menu
main() {
    echo "Welcome to the ATM!"
    echo "Do you have an account? (yes/no)"
    read choice

    if [ "$choice" == "no" ]; then
        create_user
        return
    fi

    echo "Enter account number: "
    read account_number
    echo "Enter PIN: "
    read -s pin

    if authenticate "$account_number" "$pin"; then
        while true; do
            echo "1. Check Balance"
            echo "2. Deposit Money"
            echo "3. Withdraw Money"
            echo "4. Exit"
            echo "Select an option: "
            read option

            case $option in
                1)
                    echo "Current Balance: $(get_balance "$account_number")"
                    ;;
                2)
                    echo "Enter amount to deposit: "
                    read amount
                    deposit "$account_number" "$amount"
                    ;;
                3)
                    echo "Enter amount to withdraw: "
                    read amount
                    withdraw "$account_number" "$amount"
                    ;;
                4)
                    echo "Thank you for using the ATM!"
                    break
                    ;;
                *)
                    echo "Invalid option, try again."
                    ;;
            esac
        done
    else
        echo "Invalid credentials."
    fi
}

main

