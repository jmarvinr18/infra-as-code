FROM node:18

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

RUN npm run build-only

# FROM nginx
EXPOSE 3000

RUN rm /etc/nginx/sites-enabled/*
RUN cp docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod +x docker/entrypoint.sh

ENTRYPOINT [ "docker/entrypoint.sh" ]