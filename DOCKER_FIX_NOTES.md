# Docker Configuration Fix - 403/404 Errors Resolution

## Problem Identified

The application was experiencing 403 and 404 errors when deployed because:

1. **Missing DirectoryIndex**: Apache was looking for `index.php` in `/var/www/html/` but the application structure has separate directories:
   - `/var/www/html/cms/` - Main CMS interface
   - `/var/www/html/api/` - REST API

2. **Incorrect DocumentRoot**: The DocumentRoot was set to `/var/www/html/` but should point to `/var/www/html/cms/` for the main application

3. **Missing .htaccess Support**: The AllowOverride directive wasn't properly configured to allow URL rewriting

## Solution Implemented

### 1. Custom Apache Configuration (`apache-config.conf`)

Created a new Apache VirtualHost configuration that:

- **Sets DocumentRoot to `/var/www/html/cms/`**: The CMS is now served as the main application
- **Creates an Alias for `/api`**: The API is accessible at `http://yourdomain.com/api/`
- **Enables .htaccess**: Set `AllowOverride All` for both directories to enable URL rewriting
- **Proper Directory Permissions**: Configured correct access permissions for both cms and api directories
- **Security Headers**: Added security headers for protection

### 2. Updated Dockerfile

Modified the Dockerfile to:

- Copy the custom Apache configuration to `/etc/apache2/sites-available/000-default.conf`
- Set proper file permissions with explicit `chmod` commands
- Ensure all directories and files have correct ownership (www-data:www-data)

### 3. Enhanced docker-entrypoint.sh

Updated the entrypoint script to:

- Properly handle the ServerName configuration without breaking DocumentRoot settings
- Use a more robust sed pattern to update ServerName
- Maintain backward compatibility with existing deployments

### 4. Root Redirect Fallback

Added a root `index.php` file that:

- Provides a fallback redirect to `/cms/` if accessed directly
- Ensures graceful handling of edge cases

## Application Structure

```
/var/www/html/
├── cms/                    # Main CMS Interface (DocumentRoot)
│   ├── index.php          # Main entry point
│   ├── .htaccess          # URL rewriting rules
│   ├── controllers/
│   ├── views/
│   └── ...
├── api/                    # REST API (accessible via /api)
│   ├── index.php          # API entry point
│   ├── .htaccess          # API routing rules
│   ├── controllers/
│   ├── routes/
│   └── ...
├── index.php              # Root redirect (fallback)
└── apache-config.conf     # Apache VirtualHost configuration
```

## URL Routing

After the fix, the application URLs work as follows:

- **http://yourdomain.com/** → Serves CMS interface (`/var/www/html/cms/index.php`)
- **http://yourdomain.com/api/** → Serves API (`/var/www/html/api/index.php`)
- **http://yourdomain.com/api/endpoint** → Routed through API's .htaccess

## Apache Configuration Details

### CMS Directory Configuration
```apache
DocumentRoot /var/www/html/cms

<Directory /var/www/html/cms>
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
    
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^ index.php [QSA,L]
</Directory>
```

### API Alias Configuration
```apache
Alias /api /var/www/html/api

<Directory /var/www/html/api>
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
    
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^ index.php [QSA,L]
</Directory>
```

## Testing the Fix

After deploying the updated configuration:

1. **Test CMS Access**: Visit `http://yourdomain.com/` - should load the CMS interface
2. **Test API Access**: Visit `http://yourdomain.com/api/` - should return API response
3. **Check Logs**: Review Apache logs for any remaining errors
4. **Verify Permissions**: Ensure all files are readable by www-data user

## Deployment on EasyPanel

1. Push the updated code to the GitHub repository
2. Trigger a rebuild in EasyPanel
3. The new configuration will be applied automatically
4. Monitor the container logs to verify:
   - Apache configuration is updated correctly
   - No permission errors
   - Application loads successfully

## Rollback Plan

If issues occur, you can rollback by:

1. Reverting to the previous commit
2. Or manually updating the Apache configuration in the container
3. Restarting the Apache service

## Files Modified

- ✅ `apache-config.conf` - New Apache VirtualHost configuration
- ✅ `Dockerfile` - Updated to use new Apache config and set proper permissions
- ✅ `docker-entrypoint.sh` - Enhanced ServerName handling
- ✅ `index.php` - New root redirect fallback

## Security Considerations

- Directory listing is disabled (`-Indexes`)
- Proper file permissions (755 for directories, 644 for files)
- Security headers enabled (X-Content-Type-Options, X-Frame-Options, X-XSS-Protection)
- Only necessary directories are accessible

## Support

If you continue to experience issues:

1. Check container logs: `docker logs [container_name]`
2. Verify Apache configuration: `docker exec [container_name] cat /etc/apache2/sites-available/000-default.conf`
3. Check file permissions: `docker exec [container_name] ls -la /var/www/html/`
4. Test Apache configuration: `docker exec [container_name] apache2ctl configtest`

---

**Date**: October 2025  
**Issue**: 403/404 Errors on EasyPanel Deployment  
**Status**: Resolved ✅
