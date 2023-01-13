#!/bin/bash

# Check if ssh-keygen command is available
if ! [ -x "$(command -v ssh-keygen)" ]; then
    echo "Error: ssh-keygen command not found. Please install it first."
    exit 1
fi

# Prompt for GitHub username
read -p "Enter your GitHub username: " username

# Generate a new SSH key pair
ssh-keygen -t rsa -b 4096 -C "$username@github"

# Add the key to the ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Display the public key
echo "Public key:"
cat ~/.ssh/id_rsa.pub

# Prompt for GitHub account email
read -p "Enter the email associated with your GitHub account: " email

# Add the public key to GitHub
curl -u "$username:$password" --data '{"title":"'"$HOSTNAME"'","key":"'"$(cat ~/.ssh/id_rsa.pub)"'"}' https://api.github.com/user/keys

# Test the connection to GitHub
ssh -T git@github.com

echo "Successfully connected to GitHub as $username"

