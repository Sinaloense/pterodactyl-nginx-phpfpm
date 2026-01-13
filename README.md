# pterodactyl-nginx-phpfpm
Dockerfile and Egg to run Nginx and PHP-FPM inside a Pterodactyl server.

This repository provides what is needed to run Nginx as part of a Pterodactyl server, useful for hosting web applications or acting as a reverse proxy for services managed by the panel.

## Repository contents

- Dockerfile — Image with Nginx, PHP-FPM, and required scripts.
- entrypoint.sh — Startup script.
- egg-nginx--p-h-p--f-p-m.json — Egg to use in Pterodactyl.
- logrotate.d — Log rotation configuration for Nginx.

## Features

- Nginx integration directly from a Pterodactyl-managed server.
- Automatic Composer installations when starting your server.
- Integrated `set_real_ip_from`.
- Integrated `limit_req`.
- Automatic log rotation.
- Nginx version: nginx/1.22.1.
- Supported PHP versions: 8.3.29, 8.4.16, 8.5.1.

## Requirements

- Pterodactyl installed.

## Installation

- Upload `egg-nginx--p-h-p--f-p-m.json` to your Pterodactyl panel.
- Upload the file  
  [pterodactyl-nginx](https://github.com/Sinaloense/pterodactyl-nginx/blob/main/logrotate.d/pterodactyl-nginx)  
  to the `/etc/logrotate.d/` directory on your main host.
- Upload the file  
  [pterodactyl-phpfpm](https://github.com/Sinaloense/pterodactyl-phpfpm/blob/main/logrotate.d/pterodactyl-phpfpm)  
  to the `/etc/logrotate.d/` directory on your main host.

## Recommended to be used together with

- [Pterodactyl Cloudflared.](https://github.com/Sinaloense/pterodactyl-cloudflared)
