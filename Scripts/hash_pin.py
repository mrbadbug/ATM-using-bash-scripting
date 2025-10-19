# hash_pin.py
import hashlib
import sys

def hash_pin(pin):
    return hashlib.sha256(pin.encode()).hexdigest()

if __name__ == "__main__":
    pin = sys.argv[1]  # Get the PIN from the command-line argument
    print(hash_pin(pin))  # Print the hashed PIN



