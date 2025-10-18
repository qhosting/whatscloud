# 🚀 ChatCenter - Complete Deployment Guide

This comprehensive guide covers deploying ChatCenter with Docker, including database setup, security best practices, and cloud deployment options.

## 📦 What's Included

The Docker setup includes:

1. **Dockerfile** - PHP 8.1 with Apache and all required extensions
2. **docker-compose.yml** - Multi-container setup with:
   - PHP/Apache application container
   - MySQL 8.0 database container (separate, persistent)
   - phpMyAdmin container (optional, for database management)
   - Persistent volumes for database and uploads
   - Private network for inter-container communication
3. **Environment Configuration** - `.env.example` with all required variables
4. **Helper Scripts**:
   - `setup.sh` - Automated setup and deployment
   - `backup.sh` - Database backup automation
   - `restore.sh` - Database restoration
5. **Updated Application** - `connection.php` now uses environment variables

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Host Server                          │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           Docker Network (chatcenter_network)          │ │
│  │                                                          │ │
│  │  ┌──────────────────┐      ┌────────────────────────┐ │ │
│  │  │   App Container  │──────│  Database Container    │ │ │
│  │  │  (PHP + Apache)  │      │      (MySQL 8.0)       │ │ │
│  │  │  Port: 80        │      │      Port: 3306        │ │ │
│  │  └──────────────────┘      └────────────────────────┘ │ │
│  │           │                          │                  │ │
│  │           │                          │                  │ │
│  │    ┌──────▼────┐            ┌───────▼────────┐        │ │
│  │    │  App Logs │            │  Database Data │        │ │
│  │    │  Volume   │            │     Volume     │        │ │
│  │    └───────────┘            └────────────────┘        │ │
│  └──────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌────────────────┐                                         │
│  │   Backups      │  (Optional, managed by scripts)        │
│  │   Directory    │                                         │
│  └────────────────┘                                         │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Deployment Methods

### Method 1: Quick Setup (Recommended for first-time users)

```bash
# 1. Clone or extract the project
cd chatcenter

# 2. Run the automated setup
./setup.sh

# 3. Follow the prompts to configure .env
# 4. Access your application at http://localhost
```

### Method 2: Manual Setup

```bash
# 1. Create environment configuration
cp .env.example .env
nano .env  # Edit with your settings

# 2. Build and start containers
docker-compose up -d --build

# 3. Check status
docker-compose ps

# 4. View logs
docker-compose logs -f
```

### Method 3: Development Setup (with phpMyAdmin)

```bash
# Start with database management tools
docker-compose --profile tools up -d --build

# Access phpMyAdmin at http://localhost:8080
```

## 🔐 Security Configuration

### Essential Security Steps

1. **Change Default Credentials** (CRITICAL)
   ```env
   # In .env file
   DB_PASSWORD=YourSecurePassword123!@#
   DB_ROOT_PASSWORD=AnotherSecurePassword456!@#
   API_KEY=your-randomly-generated-api-key-here
   ```

2. **Generate Secure API Key**
   ```bash
   # Generate a secure random API key
   openssl rand -hex 32
   ```

3. **Disable Debug Mode in Production**
   ```env
   APP_ENV=production
   APP_DEBUG=false
   ```

4. **Restrict Database Access**
   ```yaml
   # In docker-compose.yml, remove port exposure for production:
   # Comment out or remove:
   # ports:
   #   - "3306:3306"
   ```

5. **Regular Updates**
   ```bash
   # Pull latest images
   docker-compose pull
   
   # Rebuild containers
   docker-compose up -d --build
   ```

## 💾 Database Management

### Initial Setup

The database will be automatically initialized from `chatcenter.sql` on first startup. This happens only once when the database volume is created.

### Backup Strategy

**Manual Backup:**
```bash
./backup.sh
```

**Automated Backup (Cron):**
```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * cd /path/to/chatcenter && ./backup.sh >> /var/log/chatcenter-backup.log 2>&1
```

**Backup Retention:**
Edit `backup.sh` and uncomment the cleanup section to keep only recent backups.

### Restore Database

```bash
# List available backups
ls -lh ./backups/

# Restore from a specific backup
./restore.sh ./backups/chatcenter_backup_20251018_120000.sql.gz
```

### Direct Database Access

**Using phpMyAdmin:**
```bash
# Start with phpMyAdmin enabled
docker-compose --profile tools up -d

# Access at http://localhost:8080
# Login with DB_USER and DB_PASSWORD from .env
```

**Using MySQL CLI:**
```bash
# Connect to database container
docker-compose exec db mysql -u chatcenter_user -p

# Or from host (if port is exposed)
mysql -h localhost -P 3306 -u chatcenter_user -p
```

## 🌐 Cloud Deployment Options

### Option 1: EasyPanel (Recommended)

**Prerequisites:**
- EasyPanel account
- GitHub repository
- Domain name (optional but recommended)

**Steps:**

1. **Prepare Repository:**
   ```bash
   # Initialize git if not already done
   git init
   git add .
   git commit -m "Initial commit with Docker setup"
   
   # Push to GitHub
   git remote add origin https://github.com/yourusername/whatscloud.git
   git push -u origin main
   ```

2. **Configure EasyPanel:**
   - Log into EasyPanel dashboard
   - Create new project: "whatscloud"
   - Select "Docker Compose" deployment type
   - Connect your GitHub repository
   - Set branch to deploy (main/master)

3. **Set Environment Variables:**
   Copy all variables from `.env.example` into EasyPanel's environment configuration:
   - Go to Project Settings → Environment Variables
   - Add each variable with appropriate values
   - **IMPORTANT:** Set secure passwords and API keys

4. **Configure Domain:**
   - Add your domain in EasyPanel
   - EasyPanel automatically provisions SSL certificate (Let's Encrypt)
   - Update DNS records to point to EasyPanel server

5. **Deploy:**
   - Click "Deploy" button
   - Monitor deployment logs
   - Wait for all containers to start (database takes ~30 seconds)

6. **Verify Deployment:**
   - Access your domain
   - Check application loads correctly
   - Test API endpoints
   - Verify database connectivity

**EasyPanel Benefits:**
- Automatic SSL/TLS certificates
- Built-in monitoring and logs
- Easy rollback to previous deployments
- Automated container management
- No need to manage reverse proxy

### Option 2: DigitalOcean Droplet

**Prerequisites:**
- DigitalOcean account
- SSH access to droplet

**Steps:**

1. **Create Droplet:**
   - Choose Ubuntu 22.04 LTS
   - Minimum: 2GB RAM, 1 vCPU, 50GB SSD
   - Recommended: 4GB RAM, 2 vCPU, 80GB SSD

2. **Connect via SSH:**
   ```bash
   ssh root@your_droplet_ip
   ```

3. **Install Docker:**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   ```

4. **Install Docker Compose:**
   ```bash
   apt-get update
   apt-get install docker-compose-plugin
   ```

5. **Deploy Application:**
   ```bash
   # Clone repository
   git clone https://github.com/yourusername/whatscloud.git
   cd whatscloud
   
   # Configure environment
   cp .env.example .env
   nano .env  # Edit with production values
   
   # Deploy
   ./setup.sh
   ```

6. **Configure Firewall:**
   ```bash
   ufw allow 22/tcp   # SSH
   ufw allow 80/tcp   # HTTP
   ufw allow 443/tcp  # HTTPS
   ufw enable
   ```

7. **Set Up Reverse Proxy (Nginx) for HTTPS:**
   ```bash
   apt-get install nginx certbot python3-certbot-nginx
   
   # Create nginx config
   nano /etc/nginx/sites-available/chatcenter
   ```

   **Nginx Configuration:**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       location / {
           proxy_pass http://localhost:80;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

   ```bash
   # Enable site
   ln -s /etc/nginx/sites-available/chatcenter /etc/nginx/sites-enabled/
   nginx -t
   systemctl restart nginx
   
   # Get SSL certificate
   certbot --nginx -d your-domain.com
   ```

### Option 3: AWS ECS (Advanced)

For AWS deployment, consider using Amazon ECS with Fargate:

1. Push Docker image to ECR
2. Create ECS task definition
3. Set up RDS for MySQL database
4. Configure load balancer
5. Set environment variables in task definition

### Option 4: Google Cloud Run (Serverless)

For serverless deployment:

1. Build and push image to GCR
2. Create Cloud SQL MySQL instance
3. Deploy to Cloud Run with database connection
4. Configure environment variables

## 🔧 Maintenance

### Updating the Application

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose up -d --build

# View logs for any issues
docker-compose logs -f
```

### Monitoring

**Check Container Status:**
```bash
docker-compose ps
docker stats
```

**View Logs:**
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app
docker-compose logs -f db
```

**Database Health:**
```bash
# Check database is responding
docker-compose exec db mysqladmin ping -h localhost -p
```

### Troubleshooting

**Container won't start:**
```bash
# Check logs
docker-compose logs app
docker-compose logs db

# Rebuild from scratch
docker-compose down -v  # ⚠️ WARNING: Deletes data!
docker-compose up -d --build
```

**Database connection errors:**
```bash
# Verify environment variables are set
docker-compose exec app env | grep DB_

# Test database connectivity
docker-compose exec app php -r "
\$host = getenv('DB_HOST');
\$db = getenv('DB_DATABASE');
\$user = getenv('DB_USER');
\$pass = getenv('DB_PASSWORD');
echo \"Connecting to: \$host / \$db as \$user\n\";
try {
    \$pdo = new PDO(\"mysql:host=\$host;dbname=\$db\", \$user, \$pass);
    echo \"✅ Connection successful!\n\";
} catch (PDOException \$e) {
    echo \"❌ Connection failed: \" . \$e->getMessage() . \"\n\";
}
"
```

**Permission issues:**
```bash
docker-compose exec app chown -R www-data:www-data /var/www/html
docker-compose exec app chmod -R 755 /var/www/html
```

## 📊 Performance Optimization

### Database Optimization

Add to docker-compose.yml under db service:
```yaml
command: --max-connections=200 --innodb-buffer-pool-size=512M
```

### Application Optimization

1. **Enable PHP OPcache:** Already enabled in Dockerfile
2. **Increase PHP limits:** Edit Dockerfile:
   ```dockerfile
   RUN echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/uploads.ini
   ```

3. **Use CDN for static assets:** Configure in application

### Container Resource Limits

Add to docker-compose.yml:
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 512M
```

## ✅ Deployment Checklist

Before going live:

- [ ] All passwords changed from defaults
- [ ] API keys generated and secured
- [ ] APP_DEBUG=false in production
- [ ] SSL/TLS certificate configured
- [ ] Firewall configured
- [ ] Database backups automated
- [ ] Monitoring set up
- [ ] Logs rotation configured
- [ ] Domain DNS configured
- [ ] WhatsApp/Meta API credentials configured
- [ ] Test all core functionality
- [ ] Load testing performed
- [ ] Backup and restore tested

## 🆘 Support & Resources

- **Documentation:** See README.md
- **API Documentation:** `api/Documentación-APIRESTFul.pdf`
- **System Analysis:** Check analysis report for architecture details
- **GitHub Issues:** Report bugs and request features
- **Docker Documentation:** https://docs.docker.com

## 📝 License

[Add your license information here]

---

**Ready to deploy?** Start with `./setup.sh` and follow the prompts!
