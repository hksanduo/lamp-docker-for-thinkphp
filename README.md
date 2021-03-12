# 背景
最近项目上需要把基于thinkphp5开发的项目使用docker进行部署，以前使用lamp脚本自动部署，中间也没遇到玄学问题，这次试用docker进行部署，遇到不少问题，我就在这里记录一下，方便积累和他人参考

# 支持的功能
* ssh
* vim
* php7.0
* mysql8.0
* apache2
* rz/sz

# 构建
构建指令如下：
```
docker build -t thinkphp:v1 .
```

# 运行thinkphp
这里直接以host模式启动thinkphp容器，运行指令如下：
```
docker run \
--name thinkphp \
--network host \
--privileged=true \
-it thinkphp:v1
```

# 运行mysql8.0
对于mysql,运行指令如下：
```
docker run \
--name esmp-mysql \
-e MYSQL_ROOT_PASSWORD=P@ssw0rd \
--privileged=true \
-v /data/mysql:/var/lib/mysql \
--network host \
-d mysql:8.0 \
mysqld --default-authentication-plugin=mysql_native_password
```
需要注意的是所有的指令都会在history中留存，如果不注意，可能会导致数据库密码泄露风险，个人建议是运行mysql容器后，然后登录数据库修改root密码，或者移除
命令行中的密码信息，通过docker exec，在容器中执行密码修改等操作。另外提供的命令中映射了mysql数据存储的路径，如果重复使用该指令，需要修改映射的目录。

# 注意事项
* 构建时自行修改Dockerfile中root的密码
* 启动mysql，注意修改mysql的root密码
* 为了防止端口冲突，ssh端口号修改成222，连接容器进行部署需要注意
* 宿主机和thinkphp容器中请求mysql，请求的链接地址为：127.0.0.1
* thinkphp项目部署到thinkphp容器的/var/www目录下，修改拥有者和所属组为：www-data:www-data
* 试用rz或者scp或者自行修改Dockerfile，复制部署的文件
* 目前设置的字符集是C.UTF-8,来应对中文需求，对于其他字符集，当前系统并未预先安装，如果有相关需求，请自行安装locales来管理配置
* ......
