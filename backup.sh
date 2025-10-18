#!/bin/bash

# ChatCenter Database Backup Script
# This script creates a backup of the MySQL database

set -e

# Configuration
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="chatcenter_backup_${DATE}.sql"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

echo "================================================"
echo "  ChatCenter Database Backup"
echo "================================================"
echo ""

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if database container is running
if ! docker-compose ps | grep -q "chatcenter_db.*Up"; then
    echo "❌ Database container is not running!"
    echo "   Start it with: docker-compose up -d"
    exit 1
fi

echo "📦 Creating backup: $FILENAME"
echo ""

# Create backup
docker-compose exec -T db mysqldump \
    -u root \
    -p"${DB_ROOT_PASSWORD}" \
    "${DB_DATABASE}" > "${BACKUP_DIR}/${FILENAME}"

# Compress backup
echo "🗜️  Compressing backup..."
gzip "${BACKUP_DIR}/${FILENAME}"

COMPRESSED_FILE="${FILENAME}.gz"
FILE_SIZE=$(du -h "${BACKUP_DIR}/${COMPRESSED_FILE}" | cut -f1)

echo ""
echo "✅ Backup completed successfully!"
echo "   File: ${BACKUP_DIR}/${COMPRESSED_FILE}"
echo "   Size: ${FILE_SIZE}"
echo ""

# Optional: Keep only last N backups (uncomment to enable)
# KEEP_BACKUPS=7
# echo "🧹 Cleaning old backups (keeping last ${KEEP_BACKUPS})..."
# cd "$BACKUP_DIR"
# ls -t chatcenter_backup_*.sql.gz | tail -n +$((KEEP_BACKUPS + 1)) | xargs -r rm
# echo "✅ Old backups cleaned"

echo "================================================"
echo ""
