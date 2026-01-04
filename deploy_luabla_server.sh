#!/bin/bash

# --- SERVER SETUP ---
USER="server"
SERVER_IP="192.168.1.9" # I have to make sure this is fixed ip, not dynamic
TARGET_DIR="/home/$USER"

echo "🚀 Synchronizing files..."
rsync -avz --delete \
    --exclude='.git/' --exclude='venv/' --exclude='__pycache__/' \
    ~/Desktop/Development/Projects/Luabla/LuablaServer $USER@$SERVER_IP:$TARGET_DIR

echo "🛠️ Remote environment setup..."
ssh $USER@$SERVER_IP << EOF
    # Install Python and Pip if they don´t exist
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv

    # Create venv if not exists
    if [ ! -d "$TARGET_DIR/venv" ]; then
        python3 -m venv $TARGET_DIR/LuablaServer/venv
    fi

    # Install/Update server dependencies
    source $TARGET_DIR/LuablaServer/venv/bin/activate
    pip3 install --upgrade pip
    pip3 install -r $TARGET_DIR/LuablaServer/requirements.txt

    # Migrate Django DB
    python3 $TARGET_DIR/LuablaServer/manage.py migrate
    
    # Activate venv
    source $TARGET_DIR/LuablaServer/venv/bin/activate

    # Run server
    python3 $TARGET_DIR/LuablaServer/manage.py runserver 8600
EOF


echo "🏁 Completed deployment."
