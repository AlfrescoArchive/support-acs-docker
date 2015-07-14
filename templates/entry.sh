if [ ! -f /foo.txt ]; then
    bash /tunerepo.sh;/modifinitpass.sh;/opt/alfresco-__version__/alfresco.sh start;/waitready.sh;/opt/alfresco-__version__/alfresco.sh stop;/tunesolr.sh;touch /foo.txt
fi

# setting values for all the "-e ALF_xxx=..." parameters provided at startup
bash /tuneglobal.sh

# install the license
if [ -f /*.lic ]; then
   if [ -f /opt/alfresco-__version__/tomcat/shared/classes/alfresco/extension/license/*.installed ]; then
# remmove installed license and replace it with new one
      rm /opt/alfresco-__version__/tomcat/shared/classes/alfresco/extension/license/*.installed
   fi
   cp /*.lic /opt/alfresco-__version__/tomcat/shared/classes/alfresco/extension/license/
fi

