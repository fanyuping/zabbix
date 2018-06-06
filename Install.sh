zabbix安装日志

设置yum源
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo 

安装更新LAMP环境
yum install 
yum update gcc gcc-c++ autoconf httpd php mysql mysql-server php-mysql php php-common httpd-manual mod_ssl mod_perl  mod_auth_mysql php-gd php-xml php-ldap php-pear php-xmlrpc mysql-connector-odbc  mysql-devel  libdbi-dbd-mysql net-snmp-devel curl-devel  -y 
yum -y install php-mbstring php-bcmath

修改php配置
date.timezone=PRC
max_execution_time=300
post_max_size=32M
max_input_time=300
memory_limit=128M
mbstring.func_overload=2

编译安装zabbix
useradd -u 201 zabbix
./configure --prefix=/usr/local/zabbix --enable-server --enable-proxy --enable-agent --with-mysql=/usr/bin/mysql_config --with-net-snmp --with-libcurl
make && make install

创建数据库导入数据文件
service mysqld start
chkconfig mysqld on
mysqlamin -u root password "123456"
mysql -u root -p
create database zabbix character set utf8;
grant all on zabbix.* to zabbix@localhost identified by '123456';
cd ./zabbix-2.2.1/database/mysql
mysql -uzabbix -p123456 zabbix <schema.sql 
mysql -uzabbix -p123456 zabbix <images.sql 
mysql -uzabbix -p123456 zabbix <data.sql 

设置zabbix服务
mkdir /var/log/zabbix
chown zabbix.zabbix /var/log/zabbix/
ln -s /usr/local/zabbix/etc /etc/zabbix
ln -s /usr/local/zabbix/bin/* /usr/bin/
ln -s /usr/local/zabbix/sbin/* /usr/sbin/

cd ~/zabbix/zabbix-2.2.1/misc/init.d/fedora/core
cp zabbix_* /etc/init.d/

修改启动脚本
vim /etc/init.d/zabbix_server
BASEDIR=/usr/local/zabbix
vim /etc/init.d/zabbix_agentd
BASEDIR=/usr/local/zabbix

修改服务端口信息
vim /etc/services
zabbix-agent 10050/tcp  #zabbix Agent
zabbix-agent 10050/udp  #zabbix Agent
zabbix-server 10051/tcp #zabbix Trapper
zabbix-server 10051/udp #zabbix Trapper

修改zabbix的配置文件（本机是主机亦是客户端）
vim /etc/zabbix/zabbix_server.conf
DBName=zabbix
DBUser=zabbix
DBPassword=123456
LogFile=/var/log/zabbix/zabbix_server.log

vim /etc/zabbix/zabbix_agentd.conf
Server=127.0.0.1,192.168.194.10
ServerActive=192.168.194.10:10051
Hostname=zabbix server
LogFile=/var/log/zabbix/zabbix_server.log
UnsafeUserParemeters=1 

配置web页面，启动Zabbix服务
cp -r frontends/php /var/www/html/zabbix
chown -R apache.apache /var/www/html/zabbix
service zabbix_server start
chkconfig zabbix_server 
service zabbix_agentd 
chkconfig zabbix_agentd on

设置apache ,启动服务
chkconfig httpd on
service httpd start

打开网页http://zabbix-server/zabbix/按照向导安装完成
登陆默认用户名Username：admin Password：zabbix

被监控端设置

编译安装
useradd -u 201 zabbix-2
./configure --prefix=/usr/local/zabbix --enable-agent 
make && make install

服务设置
mkdir /var/log/zabbix
chown -R zabbix.zabbix /var/log/zabbix
cp ./misc/init.d/fedora/core/zabbix_agentd  /etc/init.d/
chmod 755 /etc/init.d/zabbix_agentd
ln -s /usr/local/zabbix/etc /etc/zabbix
ln -s /usr/local/zabbix/bin/* 	/usr/bin/
ln -s /usr/local/zabbix/sbin/*  /usr/sbin/

vim /etc/services
zabbix-agent 10050/tcp  #zabbix Agent
zabbix-agent 10050/udp  #zabbix Agent
zabbix-server 10051/tcp #zabbix Trapper
zabbix-server 10051/udp #zabbix Trapper

修改配置文件
vim zabbix_agentd.conf
Server=192.168.194.10
ServerActive=192.168.194.10:10051
Hostname=zabbix server
LogFile=/var/log/zabbix/zabbix_server.log
UnsafeUserParemeters=1 

修改启动脚本：
vim /etc/init.d/zabbix_agentd
BASEDIR=/usr/local/zabbix
启动服务
service zabbix-agentd start
chkconfig zabbix-agentd on

