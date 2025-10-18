<?php
/**
 * ChatCenter - Root Redirect
 * 
 * This file serves as a fallback redirect to the CMS interface.
 * The main application is served from the /cms directory via Apache configuration.
 */

// Redirect to the CMS interface
header("Location: /cms/");
exit();
