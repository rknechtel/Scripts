#!/usr/bin/env python3

# -----------------------------------------------------------------------------
# Script Name: genpassword.py
# Description: Will generate a random password
# Author: Richard Knechtel
# Date: 04/07/2026
#
# Parameters:
# pComplexity
# pLength
#
# pComplexity:
# There are three levels of complexity:
#  1 = Uppercase letters and lowercase letters
#  2 = 1 plus numbers
#  3 = 2 plus special characters
# Default is 3
#
# pLength:
# determines the amount of characters in the resultant password.
# Default is 10
#
# Examples Calling this Script:
#
# Calling the script without parameters:
# python3 genpassword.py
# Example Output:
# {I5u3^!bXv
#
# Complexity 1, length 15:
# python3 genpassword.py 1 15
# Example Output:
# WGXtMchibgYkEJB
#
# Complexity 3, length 20:
# python3 genpassword.py 3 20
# Example Output:
# ?5*dOR1$H09xc4g]]NDY
#
# -----------------------------------------------------------------------------

import secrets
import string
import sys


LETTERS = string.ascii_letters
LETTERS_DIGITS = string.ascii_letters + string.digits
LETTERS_DIGITS_SPECIAL = string.ascii_letters + string.digits + string.punctuation

CHAR_SETS = {
    1: LETTERS,
    2: LETTERS_DIGITS,
    3: LETTERS_DIGITS_SPECIAL,
}


def generate_password(complexity: int = 3, length: int = 10) -> str:
    char_set = CHAR_SETS.get(complexity, LETTERS_DIGITS_SPECIAL)
    return "".join(secrets.choice(char_set) for _ in range(length))


def main():
    complexity = 3
    length = 10

    if len(sys.argv) >= 2:
        try:
            complexity = int(sys.argv[1])
        except ValueError:
            print(f"Error: complexity must be an integer (1, 2, or 3), got '{sys.argv[1]}'", file=sys.stderr)
            sys.exit(1)

    if len(sys.argv) >= 3:
        try:
            length = int(sys.argv[2])
        except ValueError:
            print(f"Error: length must be an integer, got '{sys.argv[2]}'", file=sys.stderr)
            sys.exit(1)

    print(generate_password(complexity, length))


if __name__ == "__main__":
    main()
