FROM nginx:1.27.3-alpine

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./*.html /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx"]