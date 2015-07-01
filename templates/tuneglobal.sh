# setting values for all the "-e ALF_xxx=..." parameters provided at startup
for thing in `env`
do
 if [[ $thing == ALF* ]]; then
# replace the "\075" when equal is escaped (see tutum)
    thingreplaced=`echo -e $thing`
# another possibility to escape with tutul is to use .EQ. 
    string_to_replace_with="="
    result_string="${thingreplaced/.EQ./$string_to_replace_with}"
    thingreplaced=$result_string
    echo $thingreplaced
# getting the value of the parameter
     val=`echo -e  "$thingreplaced" | awk -F "=" '{print $1}'`
     echo "val:$val"
# getting the name value of the configuration variable passed as parameter
     name=`echo -e "${!val}" | awk -F "\.EQ\.|=" '{print $1}'`
     echo "name:$name"
     varvalue=`echo -e "${!val}" | awk -F "\.EQ\.|=" '{print $2}'`
     echo "varvalue:$varvalue"
# if varvalue starts with TUTUM then it is considered as a tutum variable
     if [[ $varvalue == TUTUM* ]]; then
        varvalue=`echo -e "${!varvalue}"`
        echo "varvalue tutum:$varvalue"
     fi
# if varvalue starts with MYSQL then it is considered as a MYSQL comming from the linked container
     if [[ $varvalue == MYSQL* ]]; then
        varvalue=`echo -e "${!varvalue}"`
        echo "varvalue MYSQL:$varvalue"
     fi
# if varvalue starts with POSTGRES then it is considered as a POSTGRES comming from the linked container
     if [[ $varvalue == POSTGRES* ]]; then
        varvalue=`echo -e "${!varvalue}"`
        echo "varvalue POSTGRES:$varvalue"
     fi
# if varvalue starts with ORACLE then it is considered as a ORACLE comming from the linked container
     if [[ $varvalue == ORACLE* ]]; then
        varvalue=`echo -e "${!varvalue}"`
        echo "varvalue ORACLE:$varvalue"
     fi
# test if varvalue already configured in alfresco-global.properties
     if grep -q ^$name /opt/alfresco-__version__/tomcat/shared/classes/alfresco-global.properties
     then
        sed -i "/opt/alfresco-__version__/tomcat/shared/classes/alfresco-global.properties" -e "s/$name=.*/$name=$varvalue/g"
    else
        echo  "$name=$varvalue" >> "/opt/alfresco-__version__/tomcat/shared/classes/alfresco-global.properties"
    fi
 fi
done

