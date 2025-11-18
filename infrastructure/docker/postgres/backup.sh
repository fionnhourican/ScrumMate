#!/bin/bash
# Database backup script for PostgreSQL container

set -e

# Configuration
DB_NAME=${POSTGRES_DB:-scrummate}
DB_USER=${POSTGRES_USER:-scrummate}
BACKUP_DIR="/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_backup_${TIMESTAMP}.sql"

# Create backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

# Create backup
echo "Creating backup of database ${DB_NAME}..."
pg_dump -U ${DB_USER} -h localhost ${DB_NAME} > ${BACKUP_FILE}

# Compress backup
gzip ${BACKUP_FILE}

echo "Backup created: ${BACKUP_FILE}.gz"

# Clean up old backups (keep last 7 days)
find ${BACKUP_DIR} -name "${DB_NAME}_backup_*.sql.gz" -mtime +7 -delete

echo "Backup completed successfully"
