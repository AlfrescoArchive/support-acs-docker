show databases;
create database alfresco default character set utf8 collate utf8_bin;
grant all on alfresco.* to 'alfresco'@'%' identified by 'alfresco' with grant option;
show databases;

