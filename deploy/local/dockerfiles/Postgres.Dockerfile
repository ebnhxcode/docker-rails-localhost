FROM postgres:11-alpine

RUN apk update && apk upgrade
RUN apk --update add nano bash curl vim wget htop grep git apk-tools
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf
RUN echo "listen_addresses='*'" >> /var/lib/postgresql/data/postgresql.conf

EXPOSE 5432

CMD ["postgres"]