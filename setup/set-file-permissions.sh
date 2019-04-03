#!/usr/bin/env bash

#### Detect environment
BASE_DIR=$(dirname $(dirname $(cd $(dirname $0) && pwd)))
cd ${BASE_DIR}

#-----------------------------------------------
# Script set Directory access
#-----------------------------------------------

### List of writable directories
WRITABLE_RECURSIVE_PATH=(
    "/app/attachment"
    "/app/cache"
    "/app/import_export"
    "/app/logs"
    "/web/bundles"
    "/web/css"
    "/web/js"
)
WRITABLE_PATH=( )

#### Detect environment values
# Users running php scripts
read -r -a WWW_RUN_USERS      <<< $(ps aux|grep -E '[p]hp-fpm|[a]pache|[h]ttpd|[_]www|[w]ww-data'|grep -v root|cut -d' ' -f1|uniq)
if [ -z ${WWW_RUN_USERS} ]; then
    read -r -a WWW_RUN_USERS  <<< $(getent passwd www-data apache wwwrun www|cut -d: -f1|uniq)
fi
# Users accessing to www access
read -r -a WWW_USERS          <<< $(ps aux|grep -E '[p]hp-fpm|[a]pache|[h]ttpd|[_]www|[w]ww-data|[n]ginx'|grep -v root|cut -d' ' -f1|uniq)
if [ -z ${WWW_USERS} ]; then
    read -r -a WWW_USERS      <<< $(getent passwd www-data apache wwwrun nginx www|cut -d: -f1|uniq)
fi
CURRENT_USER=$(id -un)

#### Tools
set_oro_recursive_permissions () {
    echo "Set user ${1} write access recursively to ${2}"
    # Linux style
    setfacl -Rm "u:${1}:rwX,d:u:${1}:rwX" $2 > /dev/null 2>&1
    # Mac style
    chmod +R +a "${1} allow delete,write,append,file_inherit,directory_inherit" $2 > /dev/null 2>&1
    # SmartOS style
    /bin/chmod -R A+user:$(id -u ${1}):rwxp--a-------:fd-----:allow $2 > /dev/null 2>&1
}
set_oro_permissions () {
    echo "Set user ${1} write access to ${2}"
    # Linux style
    setfacl -m "u:${1}:rwX,d:u:${1}:rwX" $2 > /dev/null 2>&1
    # Mac style
    chmod +a "${1} allow delete,write,append" $2 > /dev/null 2>&1
    # SmartOS style
    /bin/chmod A+user:$(id -u ${1}):rwxp--a-------:fd-----:allow $2 > /dev/null 2>&1
}
set_oro_recursive_read_permissions () {
    echo "Set user ${1} read access recursively to ${2}"
    # Linux style
    setfacl -Rm "u:${1}:rX,d:u:${1}:rX" $2 > /dev/null 2>&1
    # Mac style
    chmod -R +a "${1} allow delete,append" $2 > /dev/null 2>&1
    # SmartOS style
    /bin/chmod -R A+user:$(id -u ${1}):r-xp--a-------:fd-----:allow $2 > /dev/null 2>&1
}
set_oro_read_permissions () {
    echo "Set user ${1} read access to ${2}"
    # Linux style
    setfacl -m "u:${1}:rX,d:u:${1}:rX" $2 > /dev/null 2>&1
    # Mac style
    chmod +a "${1} allow delete,append" $2 > /dev/null 2>&1
    # SmartOS style
    /bin/chmod A+user:$(id -u ${1}):r-xp--a-------:fd-----:allow $2 > /dev/null 2>&1
}

#### Set Acls

# SmartOS cleanup all ACL
# /bin/chmod -R A- ${BASE_DIR}
# restore git permission
# git diff -p | /opt/local/bin/grep -E '^(diff|old mode|new mode)' | /opt/local/bin/sed -e 's/^old/NEW/;s/^new/old/;s/^NEW/new/' | git apply

# Set full right for you to have access to all folders
setfacl -Rm "u:${CURRENT_USER}:rwX,d:u:${CURRENT_USER}:rwX" $2 > /dev/null 2>&1
chmod +R +a "${CURRENT_USER} allow delete,write,append,file_inherit,directory_inherit" ${BASE_DIR} > /dev/null 2>&1
/bin/chmod -R A+user:$(id -u ${CURRENT_USER}):rwxpdDaARWcCos:fd-----:allow ${BASE_DIR} > /dev/null 2>&1

for user in "${WWW_USERS[@]}"; do
    set_oro_recursive_read_permissions ${user} ${BASE_DIR}
    set_oro_recursive_permissions ${user} ${BASE_DIR}/cache
done
for user in "${WWW_RUN_USERS[@]}"; do
    set_oro_recursive_read_permissions ${user} ${BASE_DIR}
done

for path in "${WRITABLE_RECURSIVE_PATH[@]}"; do
    pathFull="${BASE_DIR}${path}"
    for path in ${pathFull}; do
        if [ -e ${path} ]; then
            # Set right for apache user
            for user in "${WWW_RUN_USERS[@]}"; do
                set_oro_recursive_permissions ${user} ${path}
            done
        fi
	done
done

for path in "${WRITABLE_PATH[@]}"; do
    pathFull="${BASE_DIR}${path}"
    for path in ${pathFull}; do
        if [ -e ${path} ]; then
            # Set right for apache user

            for user in "${WWW_RUN_USERS[@]}"; do
                set_oro_permissions ${user} ${path}
            done
        fi
	done
done
