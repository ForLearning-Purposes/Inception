#!/bin/bash

echo "🔧 Starting Docker daemon..."

# Start service
sudo service docker start

# Wait until daemon responds
echo "⏳ Waiting for Docker daemon..."
while ! docker info >/dev/null 2>&1; do
    sleep 1
done

echo "✅ Docker daemon is running."

# Use docker compose (NEW syntax)
echo "🚀 Starting docker compose..."
docker compose -f ./srcs/docker-compose.yml up -d

echo "🌟 All services are up and running!"
