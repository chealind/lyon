FROM nginx:latest

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./*.html /etc/nginx/html/