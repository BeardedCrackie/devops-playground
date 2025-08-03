#!/bin/bash

# Replace placeholders in env.template.js with environment variable values
envsubst < /usr/share/nginx/html/env.template.js > /usr/share/nginx/html/env.js

# Start Nginx
exec "$@"