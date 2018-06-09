FROM daocloud.io/node:latest

# https://blog.caowencheng.cn
RUN mkdir -p /data/www
WORKDIR /data/www
COPY . .
RUN npm install yarn -g
RUN yarn install
RUN yarn global add hexo-cli
RUN hexo generate

# PORT
EXPOSE 3001

# RUN
ENTRYPOINT ["hexo", "server"]