#!/bin/bash

# Set variables
LXC_NAME="chatterbox-tts"
LXC_TEMPLATE="images:debian/12"
LXC_MEM="1024"
LXC_DISK="5G"
LXC_NET="bridge=vmbr0"
LXC_IP="dhcp"  # Change to static IP if preferred

# Create the LXC container
echo "[*] Creating LXC container named $LXC_NAME..."
pct create 999 --ostemplate $LXC_TEMPLATE --hostname $LXC_NAME --memory $LXC_MEM --rootfs local:$LXC_DISK --net0 name=eth0,${LXC_NET},ip=${LXC_IP} --features nesting=1

# Start the container
echo "[*] Starting container..."
pct start 999
sleep 5

# Install Docker inside the container
echo "[*] Installing Docker in container..."
pct exec 999 -- bash -c "apt update && apt install -y curl apt-transport-https ca-certificates gnupg && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list && apt update && apt install -y docker-ce docker-ce-cli containerd.io"

# Run Chatterbox TTS container
echo "[*] Pulling and starting Chatterbox TTS container..."
pct exec 999 -- docker run -d --name chatterbox-tts -p 5005:5005 ghcr.io/travisvn/chatterbox-tts-api:latest

# Enable autostart for the container
echo "[*] Enabling autostart for container..."
pct set 999 -onboot 1

echo "[✓] Done! Chatterbox TTS should now be running at http://<LXC-IP>:5005"
