# develop stage
FROM micadoproject/quasar:1.0.3 as build-stage
COPY --chown=node:node ./app /code
RUN ls -lat /code

RUN npm install
RUN quasar build

# production stage
FROM alpine
COPY --from=build-stage /code/dist/spa /var/www/html2
VOLUME /var/www/html2/
COPY busyscript.sh /usr/local/bin/busyscript
RUN chmod +x /usr/local/bin/busyscript
CMD ["busyscript"]
