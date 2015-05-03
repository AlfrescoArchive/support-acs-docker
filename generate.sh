# Generate the files necessary to build an image. The templates sources are in ./templates and it generates in ./generated
# Example build the image: 
#   sudo docker build -t alfresco-5.0.1.a ./generated
TEMPLATES=` ls --hide=*~ ./templates`
if [[ -d ./generated ]]; then
    echo "Removing './generated' folder"
    rm -rf ./generated
fi

mkdir ./generated
mkdir ./generated/jdbcs
mkdir ./generated/license

# copying the installer
cp ./installers/alfresco-enterprise-$1-installer-linux-x64.bin ./generated

cp ./*.py ./generated

cp ./*.xml ./generated

cp ./*.amp ./generated

cp ./jdbcs/$1/*.jar ./generated/jdbcs

# copy the license corresponding to the version 
cp ./licenses/$1/*.lic ./generated/license

for f in $TEMPLATES
do
  echo "Replacing in : $f"
 sed -e "s/__version__/$1/g" <./templates/$f >./generated/$f
done
