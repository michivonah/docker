# Docker
A collection of docker compose files in a general form

You can use the most of the services with traefik as reverse proxy by adding the following lines to your docker-compose file:
```yaml
labels:
      - "traefik.enable=true"
      - "traefik.http.routers.<SERVICENAME>.entrypoints=http, https"
      - "traefik.http.routers.<SERVICENAME>.rule=Host(`<YOURDOMAIN>`)"
      - "traefik.http.routers.<SERVICENAME>.tls=true"
      - "traefik.http.routers.<SERVICENAME>.tls.certresolver=production"
      - "traefik.docker.network=traefik_default"
networks:
      - traefik
      - <SERVICENAME>
```

```yaml
networks:
  <SERVICENAME>:
    external: false
  traefik:
    name: traefik_default
    external: true
```

Please not that you must replace `<SERVICENAME>` with a name for your service and `<YOURDOMAIN>` with the domain name pointing to your server for this service. Then traefik will automatically request a SSL certificate and deploy your application. If you shut down the service, traefik will also automatically remove the proxy rules created for this service. You don't have to care about any further configuration.

> If you have questions free to open a issue. :)