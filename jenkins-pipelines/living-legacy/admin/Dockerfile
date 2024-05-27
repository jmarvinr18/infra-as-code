FROM node:18 as base

ARG GITHUB_ORG
ARG GITHUB_REPO
ARG GITHUB_BRANCH
ARG GITHUB_USER
ARG GITHUB_PAT

WORKDIR /app

RUN apt-get update && apt-get install -y git nginx

RUN git clone --branch ${GITHUB_BRANCH} https://${GITHUB_USER}:${GITHUB_PAT}@github.com/${GITHUB_ORG}/${GITHUB_REPO}.git /app

RUN echo ${GITHUB_REPO}

RUN ls -la

RUN pwd

# RUN cp package.json ./

RUN npm install

# CMD [ "npm", "run", "build" ]

RUN npm run build

# FROM nginx
EXPOSE 8080

RUN rm /etc/nginx/sites-enabled/*
RUN cp docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf
RUN cp -r dist/* /usr/share/nginx/html
RUN rm /var/www/html/index*.html
RUN cp -r dist/* /var/www/html

CMD [ "nginx", "-g", "daemon off;" ]