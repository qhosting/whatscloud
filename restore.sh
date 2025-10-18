#!/bin/bash

# ChatCenter Database Restore Script
# This script restores a MySQL database from backup

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

echo "================================================"
echo "  ChatCenter Database Restore"
echo "================================================"
echo ""

# Check if backup file is provided
if [ -z "$1" ]; then
    echo "Usage: ./restore.sh <backup_file>"
    echo ""
    echo "Available backups:"
    ls -lh ./backups/*.sql.gz 2>/dev/null || echo "  No backups found"
    echo ""
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Check if database container is running
if ! docker-compose ps | grep -q "chatcenter_db.*Up"; then
    echo "❌ Database container is not running!"
    echo "   Start it with: docker-compose up -d"
    exit 1
fi

echo "⚠️  WARNING: This will REPLACE all data in the database!"
echo "   Database: ${DB_DATABASE}"
echo "   Backup:   ${BACKUP_FILE}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Restore cancelled"
    exit 0
fi

echo ""
echo "📦 Restoring database from backup..."
echo ""

# Decompress if needed and restore
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo "🗜️  Decompressing backup..."
    gunzip -c "$BACKUP_FILE" | docker-compose exec -T db mysql \
        -u root \
        -p"${DB_ROOT_PASSWORD}" \
        "${DB_DATABASE}"
else
    docker-compose exec -T db mysql \
        -u root \
        -p"${DB_ROOT_PASSWORD}" \
        "${DB_DATABASE}" < "$BACKUP_FILE"
fi

echo ""
echo "✅ Database restored successfully!"
echo ""
echo "================================================"
