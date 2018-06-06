all:
	# 删除老容器
	docker rm -f blog
	# 删除老镜像
	docker rmi hexo-blog
	# 构建新镜像
	docker build -t hexo-blog .
	# 构建新容器
	docker run -d --name blog -p 3001:3001 hexo-blog
clean:
	# 删除老容器
	docker rm -f blog
	# 删除老镜像
	docker rmi hexo-blog
build:
	# 构建新镜像
	docker build -t hexo-blog .
	# 构建新容器
	docker run -d --name blog -p 3001:3001 hexo-blog
