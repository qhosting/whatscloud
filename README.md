# 🚀 ChatCenter - Docker Deployment Guide

ChatCenter is a comprehensive chatbot management system integrated with WhatsApp Business API. This guide will help you deploy the application using Docker with a separate MySQL database container.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment Workflows](#deployment-workflows)
- [Database Management](#database-management)
- [Troubleshooting](#troubleshooting)
- [Production Deployment](#production-deployment)
- [EasyPanel Deployment](#easypanel-deployment)

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Docker** (version 20.10 or higher)
- **Docker Compose** (version 2.0 or higher)
- At least 2GB of free disk space
- A domain name (for production deployment)

### Installing Docker

**Ubuntu/Debian:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

**Install Docker Compose:**
```bash
sudo apt-get update
sudo apt-get install docker-compose-plugin
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/whatscloud.git
cd whatscloud
```

### 2. Configure Environment Variables

Copy the example environment file and customize it:

```bash
cp .env.example .env
nano .env  # or use your preferred editor
```

**⚠️ IMPORTANT:** Change the following values in `.env`:
- `DB_PASSWORD` - Set a strong database password
- `DB_ROOT_PASSWORD` - Set a strong root password
- `API_KEY` - Generate a secure API key
- `META_API_TOKEN` - Your WhatsApp Business API token
- Other Meta/WhatsApp credentials

### 3. Start the Application (Development)

This command starts the application in development mode with live code reloading. It uses both `docker-compose.yml` and `docker-compose.override.yml`.

```bash
# Build and start all services for development
docker-compose up -d --build

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

For production deployment, see the [Production Deployment](#production-deployment) section.

### 4. Access the Application

- **Application:** http://localhost (or your server IP)
- **phpMyAdmin:** http://localhost:8080 (if enabled with `--profile tools`)
- **API Endpoint:** http://localhost/api

### 5. Initialize the Database

The database will be automatically initialized with the `chatcenter.sql` file when the MySQL container starts for the first time.

## ⚙️ Configuration

### Environment Variables

All configuration is done through environment variables in the `.env` file:

#### Database Settings
```env
DB_HOST=db              # Database container hostname
DB_DATABASE=chatcenter  # Database name
DB_USER=chatcenter_user # Database username
DB_PASSWORD=SecurePass123!  # Database password
DB_PORT=3306           # MySQL port
```

#### Application Settings
```env
APP_PORT=80            # Host port for the application
APP_ENV=production     # Environment (development/production)
APP_DEBUG=false        # Debug mode (true/false)
API_KEY=your_api_key_here  # API authentication key
```

#### WhatsApp/Meta API Settings
```env
META_API_TOKEN=your_token
META_PHONE_NUMBER_ID=your_phone_id
META_BUSINESS_ID=your_business_id
```

#### OpenAI Settings (Optional)
```env
OPENAI_API_KEY=your_openai_key
OPENAI_MODEL=gpt-3.5-turbo
```

## 🐳 Deployment Workflows

This project now uses multiple Docker Compose files for different environments:
- `docker-compose.yml`: Base configuration for all environments.
- `docker-compose.override.yml`: Development-specific settings (e.g., volume mounts for live reloading). This is loaded automatically by default.
- `docker-compose.prod.yml`: Production-ready configuration.

### Development Environment

To run the application locally for development, simply use the standard `docker-compose` commands. This will automatically include the `override` file.

```bash
# Start in development mode (with live reload)
docker-compose up -d --build

# To include phpMyAdmin:
docker-compose --profile tools up -d
```

### Rebuild After Changes

```bash
# Rebuild the application container
docker-compose up -d --build

# Rebuild specific service
docker-compose up -d --build app
```

### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ WARNING: This will delete database data!)
docker-compose down -v
```

## 💾 Database Management

### Accessing the Database

**Option 1: Using phpMyAdmin**
```bash
# Start with phpMyAdmin enabled
docker-compose --profile tools up -d

# Access at http://localhost:8080
```

**Option 2: Using MySQL CLI**
```bash
# Connect to MySQL container
docker-compose exec db mysql -u chatcenter_user -p
```

**Option 3: From host machine**
```bash
# MySQL is exposed on port 3306
mysql -h localhost -P 3306 -u chatcenter_user -p
```

### Database Backup

```bash
# Create backup
docker-compose exec db mysqldump -u root -p chatcenter > backup_$(date +%Y%m%d).sql

# Restore from backup
docker-compose exec -T db mysql -u root -p chatcenter < backup_20251018.sql
```

### Data Persistence

The database data is stored in a Docker volume named `chatcenter_db_data`, which persists across container restarts and removals. To completely remove the data:

```bash
docker-compose down -v  # ⚠️ WARNING: Deletes all data!
```

## 🔍 Troubleshooting

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app
docker-compose logs -f db
```

### Container Status

```bash
# Check running containers
docker-compose ps

# Check resource usage
docker stats
```

### Database Connection Issues

1. **Check if database is ready:**
```bash
docker-compose exec db mysqladmin ping -h localhost -p
```

2. **Verify environment variables:**
```bash
docker-compose exec app env | grep DB_
```

3. **Test connection from app container:**
```bash
docker-compose exec app php -r "echo 'DB: ' . getenv('DB_DATABASE') . PHP_EOL;"
```

### Reset Everything

```bash
# Stop and remove containers, networks, and volumes
docker-compose down -v

# Remove images
docker-compose down --rmi all

# Start fresh
docker-compose up -d --build
```

### Permission Issues

If you encounter permission issues with uploads or logs:

```bash
docker-compose exec app chown -R www-data:www-data /var/www/html
docker-compose exec app chmod -R 755 /var/w
ww/html
```

## 🔒 Production Deployment

For production, it is crucial to use the production-specific configuration file, which ensures that the code is built into the image and not mounted from a local directory.

### Running in Production

```bash
# Build and start the services using the production configuration
docker-compose -f docker-compose.prod.yml up -d --build

# Stop the services
docker-compose -f docker-compose.prod.yml down
```

### Security Checklist

- [ ] Change all default passwords and API keys
- [ ] Set `APP_DEBUG=false` in `.env`
- [ ] Use strong, unique passwords (16+ characters)
- [ ] Enable HTTPS with SSL/TLS certificates
- [ ] Disable phpMyAdmin or restrict access
- [ ] Configure firewall rules
- [ ] Regular database backups
- [ ] Keep Docker images updated
- [ ] Monitor logs for suspicious activity

### Using HTTPS with Reverse Proxy

It's recommended to use a reverse proxy like **Nginx** or **Traefik** for HTTPS:

**Example nginx configuration:**
```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Automated Backups

Create a backup script (`backup.sh`):

```bash
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
FILENAME="chatcenter_backup_${DATE}.sql"

docker-compose exec -T db mysqldump -u root -p${DB_ROOT_PASSWORD} chatcenter > "${BACKUP_DIR}/${FILENAME}"

# Keep only last 7 days of backups
find ${BACKUP_DIR} -name "chatcenter_backup_*.sql" -mtime +7 -delete
```

Add to crontab:
```bash
0 2 * * * /path/to/backup.sh  # Daily backup at 2 AM
```

## 🌐 EasyPanel Deployment

EasyPanel provides a simple interface for deploying Docker applications.

### Steps for EasyPanel:

1. **Push to GitHub:**
```bash
git remote add origin https://github.com/yourusername/whatscloud.git
git push -u origin main
```

2. **In EasyPanel Dashboard:**
   - Create a new project: "whatscloud"
   - Choose "Docker Compose" deployment
   - Connect your GitHub repository
   - EasyPanel will automatically detect `docker-compose.yml`

3. **Configure Environment Variables:**
   - Go to project settings
   - Add all variables from `.env.example`
   - Save and deploy

4. **Set up Domain:**
   - Add your domain in EasyPanel
   - Configure SSL certificate (automatic with Let's Encrypt)
   - Point your domain's DNS to EasyPanel server

5. **Deploy:**
   - Click "Deploy" button
   - Monitor deployment logs
   - Access your application at your domain

### EasyPanel-specific Notes:

- EasyPanel handles SSL certificates automatically
- No need to expose ports manually (handled by EasyPanel)
- Use EasyPanel's built-in monitoring tools
- Database backups can be configured in EasyPanel settings

## 📊 Monitoring

### Check Application Health

```bash
# Check if services are running
docker-compose ps

# View resource usage
docker stats

# Check disk usage
docker system df
```

### Application Logs

```bash
# Real-time logs
docker-compose logs -f app

# Last 100 lines
docker-compose logs --tail=100 app

# Logs since timestamp
docker-compose logs --since 2025-10-18T00:00:00 app
```

## 🆘 Support

For issues, questions, or contributions:

- **GitHub Issues:** https://github.com/yourusername/whatscloud/issues
- **Documentation:** Check the `api/Documentación-APIRESTFul.pdf` file
- **Analysis Report:** See `chatcenter_analysis.pdf` for system architecture

## 📝 License

[Add your license information here]

## 🤝 Contributing

Contributions are welcome! Please read the contributing guidelines before submitting pull requests.

---

**Made with ❤️ for WhatsApp Business automation**
