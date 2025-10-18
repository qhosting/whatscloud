# EasyPanel Deployment Guide

This guide explains how to deploy ChatCenter on EasyPanel with dynamic domain configuration.

## Overview

The application has been configured to dynamically use the domain provided by EasyPanel through environment variables. This means you can deploy the application without hardcoding any domain names - everything is configured at runtime.

## Environment Variables

### Required Variables

The following environment variables must be configured in EasyPanel:

#### Domain Configuration
- **APP_DOMAIN**: Your application domain (e.g., `chatcenter.yourdomain.com`)
- **APP_URL**: Full application URL (e.g., `https://chatcenter.yourdomain.com`)
  - *Note: APP_URL is optional. If not provided, it will be derived from APP_DOMAIN*

#### Database Configuration
- **DB_HOST**: Database host (default: `db`)
- **DB_DATABASE**: Database name (default: `chatcenter`)
- **DB_USER**: Database user
- **DB_PASSWORD**: Database password
- **DB_PORT**: Database port (default: `3306`)
- **DB_ROOT_PASSWORD**: MySQL root password (for initial setup)

#### Application Configuration
- **API_KEY**: API key for authentication (generate a secure random string)
- **APP_ENV**: Environment (`production`, `staging`, or `development`)
- **APP_DEBUG**: Debug mode (`true` or `false`) - should be `false` in production

#### Optional: Meta/WhatsApp API Configuration
- **META_API_TOKEN**: Meta API token for WhatsApp Business API
- **META_PHONE_NUMBER_ID**: WhatsApp Phone Number ID
- **META_BUSINESS_ID**: WhatsApp Business Account ID
- **META_WEBHOOK_TOKEN**: Webhook verification token

#### Optional: OpenAI Configuration
- **OPENAI_API_KEY**: OpenAI API key for AI features
- **OPENAI_MODEL**: AI model to use (default: `gpt-3.5-turbo`)

## How It Works

### 1. Docker Entrypoint Script

The `docker-entrypoint.sh` script runs when the container starts and:

1. Reads the `APP_DOMAIN` or `APP_URL` environment variable
2. Configures Apache's `ServerName` with the correct domain
3. Creates a `config.env.php` file with all environment variables
4. Sets proper file permissions
5. Starts Apache

### 2. Application Configuration

The PHP application files have been updated to:

- Read database credentials from environment variables
- Read API keys from environment variables
- Use the configured domain for URL generation
- Connect to the database using environment-provided host and port

### 3. Apache Configuration

Apache is automatically configured with the correct `ServerName` based on your domain, ensuring:

- Proper request handling
- Correct redirect behavior
- No "ServerName not set" warnings

## Deployment Steps on EasyPanel

### Step 1: Create a New Service

1. Log in to your EasyPanel dashboard
2. Create a new service or application
3. Choose "Docker" as the deployment method

### Step 2: Configure the Repository

1. Connect your GitHub repository: `qhosting/whatscloud`
2. Set the branch (usually `main` or `master`)
3. EasyPanel will detect the `Dockerfile` automatically

### Step 3: Set Environment Variables

In EasyPanel's environment variables section, add the following:

```env
# Domain Configuration
APP_DOMAIN=your-app.yourdomain.com
APP_URL=https://your-app.yourdomain.com

# Database Configuration
DB_HOST=db
DB_DATABASE=chatcenter
DB_USER=chatcenter_user
DB_PASSWORD=your_secure_password_here
DB_ROOT_PASSWORD=your_secure_root_password_here

# Application Configuration
API_KEY=your_secure_api_key_here
APP_ENV=production
APP_DEBUG=false

# Optional: WhatsApp API Configuration
META_API_TOKEN=your_token_here
META_PHONE_NUMBER_ID=your_phone_id_here
META_BUSINESS_ID=your_business_id_here
META_WEBHOOK_TOKEN=your_webhook_token_here

# Optional: OpenAI Configuration
OPENAI_API_KEY=your_openai_key_here
OPENAI_MODEL=gpt-3.5-turbo
```

### Step 4: Configure Database Service

EasyPanel may require you to set up a MySQL database service:

1. Add a MySQL service to your project
2. Use the same database credentials in your environment variables
3. Ensure the database service name matches `DB_HOST` (usually `db`)

### Step 5: Deploy

1. Click "Deploy" or "Build & Deploy"
2. EasyPanel will build the Docker image and start the container
3. The entrypoint script will configure everything automatically

### Step 6: Access Your Application

1. Open your browser and navigate to your domain
2. The application should be accessible at `https://your-app.yourdomain.com`

## Verification

After deployment, you can verify the configuration by checking:

1. **Apache Configuration**: The container logs should show:
   ```
   ✓ Using APP_DOMAIN: your-app.yourdomain.com
   ✓ Apache ServerName set to: your-app.yourdomain.com
   ✓ PHP environment configuration created
   ```

2. **Database Connection**: The application should connect to the database without errors

3. **Domain Resolution**: The application should respond correctly at your configured domain

## Troubleshooting

### Issue: Application not accessible

**Solution**: 
- Check that your domain DNS is pointing to EasyPanel's IP
- Verify that the EasyPanel proxy/ingress is configured correctly
- Check the container logs for any errors

### Issue: Database connection errors

**Solution**:
- Verify database credentials are correct
- Ensure the database service is running
- Check that `DB_HOST` matches your database service name
- Verify network connectivity between services

### Issue: Environment variables not working

**Solution**:
- Rebuild the container after adding/changing environment variables
- Check EasyPanel's environment variable configuration
- Verify the variables are being passed to the container (check container logs)

### Issue: Apache ServerName warnings

**Solution**:
- Ensure `APP_DOMAIN` is set correctly
- Rebuild the container to apply changes
- Check the entrypoint script logs

## Local Development

For local development with the new configuration:

1. Copy `.env.example` to `.env`
2. Update the environment variables in `.env`
3. Run with Docker Compose:
   ```bash
   docker-compose up -d
   ```

The application will use the environment variables from your `.env` file.

## Security Best Practices

1. **Use Strong Passwords**: Generate secure random passwords for database and API keys
2. **Disable Debug Mode**: Set `APP_DEBUG=false` in production
3. **Use HTTPS**: Configure SSL/TLS certificates in EasyPanel
4. **Secure API Keys**: Never commit API keys to version control
5. **Regular Updates**: Keep dependencies and Docker images up to date
6. **Rotate Credentials**: Regularly rotate passwords and API keys

## Support

For issues or questions:
- Check the container logs in EasyPanel
- Review the entrypoint script output for configuration details
- Consult the main README.md for application-specific documentation

---

**Last Updated**: October 2025  
**Version**: 1.0.0
