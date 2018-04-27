---
title: Docker实战
subtitle: Docker
date: 2018-03-08 19:16:50
header-img: /images/docker.jpg
tags: ["Docker", "容器", "镜像"]
---
docker(https://hub.docker.com/u/wensent/)
1.启动nginx
systemctl start docker
2.关闭nginx
systemctl stop docker
3.设置开机启动
systemctl enable docker
4.关闭开机启动
systemctl disable docker

docker search  nginx  查找镜像文件；
docker pull nginx  下载镜像文件；
docker rmi nginx  删除镜像文件；
docker rm  $container  删除容器；
docker start $container  开启一个容器；
docker stop $container  停止一个容器；
docker images 列出已下载镜像
docker ps 列出运行中的容器
docker ps -a 列出所有容器
docker stop 7836fh47dvb8 停止指定容器
docker kill 7836fh47dvb8 强制停止指定容器
docker rm 7836fh47dvb8 删除指定容器
docker rm -f 7836fh47dvb8 强制删除指定容器
docker start 7836fh47dvb8 启动已停止的容器
docker rm -f $(docker ps -a -q) 删除所有容器

例：启动一个nginx容器
docker run -d -p 3333:80 nginx
-d # 后台运行
-p 宿主机端口：容器端口 # 开放容器端口到宿主机端口

例：Dockerfile
FROM nginx
RUN mkdir -p /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
COPY ./dist/index.html ./
COPY ./dist/static ./static
EXPOSE 80