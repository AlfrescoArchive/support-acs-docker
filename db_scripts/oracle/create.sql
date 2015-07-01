export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
./u01/app/oracle/product/11.2.0/xe/bin/sqlplus  system/oracle
CREATE TABLESPACE alfresco DATAFILE 'ALFRESCO2-TS.DAT' SIZE 512M REUSE AUTOEXTEND ON NEXT 256M;
CREATE USER alfresco DEFAULT TABLESPACE alfresco TEMPORARY TABLESPACE temp IDENTIFIED BY alfresco;
ALTER USER alfresco QUOTA unlimited ON alfresco;
GRANT connect TO alfresco;
GRANT resource TO alfresco;
exit;
