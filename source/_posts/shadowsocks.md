---
# 文章标题
title: 科学上网
# 文章创建时间
date: 2018-06-07 17:17:50
# 标签 可多选
tags: ["Shadowsocks"]
# 类别 可多选
categories: ["技术"]
# 右侧最新文章预览图
thumbnail: https://qiniu.caowencheng.cn/shadowsocks.png
# 文章顶部banner 可多张图片
banner: https://blog.zhangruipeng.me/hexo-theme-icarus/gallery/math.jpg
---

<!-- ![ShadowsocksX](https://qiniu.caowencheng.cn/shadowsocks.png "description") -->

centOS服务器配置ss
==========

```
yum -y install wget
wget -N --no-check-certificate https://softs.fun/Bash/ssr.sh && chmod +x ssr.sh && bash ssr.sh
```
<h5>备用下载地址：</h5>

```
yum -y install wget
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubi/doubi/master/ssr.sh && chmod +x ssr.sh && bash ssr.sh
```

>复制上面的代码到VPS服务器里，安装脚本后，以后只需要运行这个快捷命令就可以出现下图的界面进行设置，快捷管理命令为：bash ssr.sh

<!--more-->

![图-1](https://qiniu.caowencheng.cn/shadowsocks-1.png "description")

>如上图出现管理界面后，输入数字1来安装SSR服务端。如果输入1后不能进入下一步，那么请退出xshell，重新连接vps服务器，然后输入快捷管理命令bash ssr.sh再尝试。

![图-2](https://qiniu.caowencheng.cn/shadowsocks-2.png "description")

>根据上图提示，依次输入自己想设置的端口和密码 ( 密码建议用字母，图中的密码只是作为演示用)，回车键用于确认

![图-3](https://qiniu.caowencheng.cn/shadowsocks-3.png "description")

>如上图，选择想设置的加密方式，比如10，按回车键确认
接下来是选择协议插件，如下图：

![图-4](https://qiniu.caowencheng.cn/shadowsocks-4.png "description")

![图-5](https://qiniu.caowencheng.cn/shadowsocks-5.png "description")

>选择并确认后，会出现上图的界面，提示你是否选择兼容原版，这里的原版指的是SS客户端，可以根据需求进行选择，原则上不推荐使用SS客户端，演示选择n
之后进行混淆插件的设置，如下面

![图-6](https://qiniu.caowencheng.cn/shadowsocks-6.png "description")

>进行混淆插件的设置后，会依次提示你对设备数、单线程限速和端口总限速进行设置，默认值是不进行限制，个人使用的话，选择默认即可，即直接敲回车键。

![图-7](https://qiniu.caowencheng.cn/shadowsocks-7.png "description")

>之后代码就正式自动部署了，到下图所示的位置，提示你下载文件，输入：y

![图-8](https://qiniu.caowencheng.cn/shadowsocks-8.png "description")

>耐心等待一会，出现下面的界面即部署完成：

![图-9](https://qiniu.caowencheng.cn/shadowsocks-9.png "description")

![图-10](https://qiniu.caowencheng.cn/shadowsocks-10.png "description")

>根据上图就可以看到自己设置的SSR账号信息，包括IP、端口、密码、加密方式、协议插件、混淆插件。如果之后想修改账号信息，直接输入快捷管理命令：bash ssr.sh 进入管理界面，选择相应的数字来进行一键修改。例如：

![图-11](https://qiniu.caowencheng.cn/shadowsocks-11.png "description")

![图-12](https://qiniu.caowencheng.cn/shadowsocks-12.png "description")

【谷歌BBR加速教程】
==============
>此加速教程为谷歌BBR加速,Vultr的服务器框架可以装BBR加速，加速后对速度的提升很明显，所以推荐部署加速脚本。该加速方法是开机自动启动，部署一次就可以了。
>按照第二步的步骤，连接服务器ip，登录成功后，在命令栏里粘贴以下代码：
```
yum -y install wget
wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
chmod +x bbr.sh
./bbr.sh
```
>把上面整个代码复制后粘贴进去，不动的时候按回车，然后耐心等待，最后重启vps服务器即可。
>演示开始，如图：
>复制并粘贴代码后，按回车键确认

![图-13](https://qiniu.caowencheng.cn/shadowsocks-13.png "description")

>如下图提示，按任意键继续部署

![图-14](https://qiniu.caowencheng.cn/shadowsocks-14.png "description")

![图-15](https://qiniu.caowencheng.cn/shadowsocks-15.png "description")
>部署到上图这个位置的时候，等待3～6分钟

![图-16](https://qiniu.caowencheng.cn/shadowsocks-16.png "description")

>最后输入y重启服务器或者手动输入代码reboot来确保加速生效。

>转自 <https://www.cnblogs.com/yjiu1990/p/7771429.html>