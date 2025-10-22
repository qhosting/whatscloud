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

### 3. Start the Application

```bash
# Build and start all services
docker-compose up -d --build

# View logs
docker-compose logs -f

# Check status
docker-compose ps
```

This single set of commands works for both development and production. See "Deployment Workflows" for more details.

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

This project uses a standard Docker Compose setup that is optimized for both development and production.

- `docker-compose.yml`: Contains the base configuration for the application, suitable for production.
- `docker-compose.override.yml`: Contains development-only settings, such as mounting the local code for live reloading. This file is **not meant for production** and should not be copied to your production server.

### Development Environment

When you run `docker-compose up` on your local machine, Docker Compose automatically merges `docker-compose.yml` and `docker-compose.override.yml`, giving you a development-ready environment with your code mounted.

```bash
# Start in development mode (with live reload)
docker-compose up -d --build

# To include phpMyAdmin:
docker-compose --profile tools up -d
```

### Production Environment

For production, you simply deploy the `docker-compose.yml` file without the `override` file. This ensures that the application runs using the code built into the Docker image, which is faster and more secure.

See the [Production Deployment](#production-deployment) section for more details.

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

## 🔍 Troubleshooting

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app
docker-compose logs -f db
```

### Reset Everything

```bash
# Stop and remove containers, networks, and volumes
docker-compose down -v

# Remove images
docker-compose down --rmi all
```

## 🔒 Production Deployment

Deploying to production is straightforward. Ensure that only the `docker-compose.yml` file is on your server, along with your `.env` file. **Do not copy `docker-compose.override.yml` to production.**

### Running in Production

```bash
# Pull the latest changes from your repository
git pull

# Build and start the services
docker-compose up -d --build

# Stop the services
docker-compose down
```

### Security Checklist

- [ ] Ensure `docker-compose.override.yml` is not on the production server.
- [ ] Change all default passwords and API keys in `.env`.
- [ ] Set `APP_DEBUG=false` in `.env`.
- [ ] Enable HTTPS with a reverse proxy.
- [ ] Disable phpMyAdmin or restrict access.
- [ ] Configure firewall rules and regular backups.

### Using HTTPS with Reverse Proxy

It's recommended to use a reverse proxy like **Nginx** or **Traefik** for HTTPS.

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

## 🌐 EasyPanel Deployment

When deploying with EasyPanel or a similar service:
1. Connect your GitHub repository.
2. EasyPanel will detect `docker-compose.yml`.
3. Add your environment variables from your `.env` file into the EasyPanel dashboard.
4. Deploy.

The service will use the `docker-compose.yml` file, which is suitable for production.

## 🆘 Support

For issues, questions, or contributions:

- **GitHub Issues:** https://github.com/yourusername/whatscloud/issues
- **Documentation:** Check the `api/Documentación-APIRESTFul.pdf` file

## 📝 License

[Add your license information here]

## 🤝 Contributing

Contributions are welcome! Please read the contributing guidelines before submitting pull requests.

---

**Made with ❤️ for WhatsApp Business automation**
