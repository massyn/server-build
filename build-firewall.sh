#!/bin/bash

# == does the /etc/rc.local file exist ?

if [ `whoami` == "root" ]; then
        if [ ! -f "/etc/rc.local" ]; then
                echo "Creating /etc/rc.local..."
                echo "#!/bin/bash" > /etc/rc.local
                echo "$PWD/fw.sh" >> /etc/rc.local
                chmod +x /etc/rc.local
        else
                cat /etc/rc.local | grep "fw.sh" > /dev/null 2>&1
                if [ $? != 0 ]; then
                        echo "Adding an entry to the /etc/rc.local file..."
                        echo "$PWD/fw.sh" >> /etc/rc.local
                else
                        echo " ** nothing to do **"
                fi
        fi
else
        echo "Run the script as root"
fi
