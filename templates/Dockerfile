FROM ubuntu
MAINTAINER Philippe Dubois
RUN   apt-get update
RUN   apt-get install -y --no-install-recommends ubuntu-desktop
RUN   apt-get update
RUN   apt-get install -y wget
# RUN   wget http://dl.alfresco.com/release/community/5.0.c-build-00145/alfresco-community-5.0.c-installer-linux-x64.bin
COPY  ./alfresco-enterprise-__version__-installer-linux-x64.bin /
RUN   chmod +x ./alfresco-enterprise-__version__-installer-linux-x64.bin
RUN   ./alfresco-enterprise-__version__-installer-linux-x64.bin --mode unattended --alfresco_admin_password admin --disable-components alfrescogoogledocs,postgres 
RUN   rm ./alfresco-enterprise-__version__-installer-linux-x64.bin
# copy the license
COPY ./license/*.lic /
RUN   mkdir /opt/alfresco-__version__/tomcat/shared/classes/alfresco/extension/license
RUN   mv *.lic /opt/alfresco-__version__/tomcat/shared/classes/alfresco/extension/license
# make root readable by others
RUN   chmod go+r /root
COPY  passencode.py /
RUN   chmod +x /passencode.py
COPY  ./modifinitpass.sh /
RUN   chmod +x /modifinitpass.sh
COPY  ./tunesolr.sh /
RUN   chmod +x /tunesolr.sh
COPY  ./tunerepo.sh /
RUN   chmod +x /tunerepo.sh
RUN   apt-get update
RUN   apt-get install -y curl
RUN   apt-get install -y xmlstarlet
COPY  ./waitready.sh /
RUN   chmod +x /waitready.sh
COPY  ./entry.sh /
RUN   chmod +x /entry.sh
COPY  ./tuneglobal.sh /
RUN   chmod +x /tuneglobal.sh
# COPY  ./alfrescotrashcancleaner2.amp  /
# RUN   mv /alfrescotrashcancleaner2.amp /opt/alfresco-__version__/amps
# COPY  ./protectnodes.amp /
COPY ./modules/server/ /
RUN find . -maxdepth 1 -name '*.amp' -type f -exec mv -t /opt/alfresco-__version__/amps '{}' +
COPY ./modules/share/ /
RUN find . -maxdepth 1 -name '*.amp' -type f -exec mv -t /opt/alfresco-__version__/amps_share '{}' +
# copy jdbcs
COPY ./jdbcs/*.jar /
RUN  mv *.jar /opt/alfresco-__version__/tomcat/lib
# RUN   mv /protectnodes.amp /opt/alfresco-__version__/amps
# apply amps
COPY  ./apply_amps_unatended.sh /
RUN   chmod +x /apply_amps_unatended.sh
RUN   mv /apply_amps_unatended.sh /opt/alfresco-__version__/bin
RUN   /opt/alfresco-__version__/bin/apply_amps_unatended.sh
# configure for allowing and managing correctly user names containing '@', see http://docs.alfresco.com/4.2/tasks/usernametypes-mix-config.html
COPY  ./custom-surf-application-context.xml /
RUN   mv /custom-surf-application-context.xml /opt/alfresco-__version__/tomcat/shared/classes/alfresco/web-extension
ENTRYPOINT /entry.sh;/opt/alfresco-__version__/alfresco.sh start;bash



