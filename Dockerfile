FROM daocloud.io/node:latest

# https://blog.caowencheng.cn
RUN mkdir -p /data/www
WORKDIR /data/www
COPY . .
RUN npm install --registry=https://registry.npm.taobao.org --verbose
RUN npm install hexo-cli -g
RUN hexo generate

# PORT
EXPOSE 3001

# RUN
ENTRYPOINT ["hexo", "server"]