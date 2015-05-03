if [ ! -f /foo.txt ]; then
    bash /tunerepo.sh;/modifinitpass.sh;/opt/alfresco-__version__/alfresco.sh start;/waitready.sh;/opt/alfresco-__version__/alfresco.sh stop;/tunesolr.sh;touch /foo.txt
fi

# setting values for all the "-e ALF_xxx=..." parameters provided at startup
bash /tuneglobal.sh

