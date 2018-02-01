FROM nginx:1.13-alpine
USER root
RUN apk add --update --no-cache \
    ca-certificates \
    supervisor \
    wget \
    && update-ca-certificates

RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.15.0/confd-0.15.0-linux-amd64 \
    && mkdir -p /opt/confd/bin \
    && mv confd-0.15.0-linux-amd64 /opt/confd/bin/confd \
    && chmod +x /opt/confd/bin/confd \
    && export PATH="$PATH:/opt/confd/bin" \
    && mkdir -p /etc/confd/{conf.d,templates}

# Configure Supervisor
RUN mkdir -p /var/log/supervisor \
    && mkdir -p /etc/supervisor.d
COPY config/supervisor/proxy.ini /etc/supervisor.d/proxy.ini
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/confd /etc/confd
COPY certs/selfsigned.cert.pem /etc/certs/
COPY certs/selfsigned.key.pem /etc/certs/

EXPOSE 80
EXPOSE 443

COPY entrypoint.sh /usr/bin/docker_entrypoint.sh
RUN chmod +x /usr/bin/docker_entrypoint.sh

ENTRYPOINT [ "/usr/bin/docker_entrypoint.sh" ]

CMD /usr/bin/supervisord --pidfile /var/run/supervisord.pid --nodaemon --configuration /etc/supervisord.conf