#!/bin/bash

# ChatCenter Docker Setup Script
# This script helps you set up the ChatCenter application with Docker

set -e

echo "================================================"
echo "  ChatCenter Docker Setup"
echo "================================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ .env file created. Please edit it with your configuration:"
        echo "   nano .env"
        echo ""
        echo "⚠️  IMPORTANT: Update these values in .env:"
        echo "   - DB_PASSWORD"
        echo "   - DB_ROOT_PASSWORD"
        echo "   - API_KEY"
        echo "   - META_API_TOKEN (if using WhatsApp)"
        echo ""
        read -p "Press Enter after editing .env to continue..."
    else
        echo "❌ .env.example not found. Cannot create .env file."
        exit 1
    fi
else
    echo "✅ .env file exists"
fi

echo ""
echo "================================================"
echo "  Building and starting containers..."
echo "================================================"
echo ""

# Build and start containers
docker-compose up -d --build

echo ""
echo "================================================"
echo "  Waiting for services to be ready..."
echo "================================================"
echo ""

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Check if containers are running
if docker-compose ps | grep -q "Up"; then
    echo ""
    echo "================================================"
    echo "  ✅ Setup Complete!"
    echo "================================================"
    echo ""
    echo "Your ChatCenter application is now running:"
    echo ""
    echo "  🌐 Application:  http://localhost"
    echo "  📊 API:          http://localhost/api"
    echo ""
    echo "To access phpMyAdmin (for database management):"
    echo "  docker-compose --profile tools up -d"
    echo "  📊 phpMyAdmin:   http://localhost:8080"
    echo ""
    echo "Useful commands:"
    echo "  View logs:       docker-compose logs -f"
    echo "  Stop services:   docker-compose down"
    echo "  Restart:         docker-compose restart"
    echo "  Rebuild:         docker-compose up -d --build"
    echo ""
else
    echo ""
    echo "❌ Some containers failed to start. Check logs:"
    echo "   docker-compose logs"
    exit 1
fi
