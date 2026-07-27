FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY . /usr/share/nginx/html
# Defensa en profundidad: COPY . mete .git/ y los archivos de build dentro del
# docroot y quedan accesibles por HTTP. Se eliminan del contenedor.
RUN rm -rf /usr/share/nginx/html/.git \
           /usr/share/nginx/html/.gitattributes \
           /usr/share/nginx/html/nginx.conf \
           /usr/share/nginx/html/Dockerfile
EXPOSE 80
