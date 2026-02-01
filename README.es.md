# pterodactyl-nginx-phpfpm
Dockerfile y Egg para correr Nginx y PHP-FPM dentro de un servidor Pterodactyl.

Este repositorio provee lo necesario para correr Nginx como parte de un servidor Pterodactyl, útil para alojar aplicaciones web o como proxy inverso para tus servicios gestionados por el panel.

## Contenido del repositorio:

- `Dockerfile` — Imagen con Nginx, PHP-FPM y scripts necesarios.
- `entrypoint.sh` — Script de arranque.
- `egg-nginx--p-h-p--f-p-m.json` — Egg para usar en Pterodactyl.
- `logrotate.d` — Configuración de rotación de logs para Nginx.

## Características

- Integración de Nginx directamente desde un servidor administrado por Pterodactyl.
- Instalaciones Composer automaticas al momento de iniciar tu servidor.
- `set_real_ip_from` integrado.
- `limit_req` integrado.
- `Spatie media library optimization tools` integrado.
- Logs rotados automáticamente.
- Versión de Nginx: `nginx/1.22.1`.
- Versiónes de PHP: `8.3.30, 8.4.17, 8.5.2`.

## Requisitos:

- Pterodactyl instalado.

## Instalación:

- Carga `egg-nginx--p-h-p--f-p-m.json` en tu panel.
- Subir archivo [pterodactyl-nginx](https://github.com/Sinaloense/pterodactyl-nginx/blob/main/logrotate.d/pterodactyl-nginx) en el directorio `/etc/logrotate.d/` de tu host principal.
- Subir archivo [pterodactyl-phpfpm](https://github.com/Sinaloense/pterodactyl-phpfpm/blob/main/logrotate.d/pterodactyl-phpfpm) en el directorio `/etc/logrotate.d/` de tu host principal.

## Recomendado usarse en conjunto con:
- [Pterodactyl Cloudflared.](https://github.com/Sinaloense/pterodactyl-cloudflared)
