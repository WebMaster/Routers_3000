#!/bin/sh

#chmod +x /tmp/001.sh && /tmp/001.sh
NUMBER="001"

cronTask="10 4 * * * sh <(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/$NUMBER.sh) 2>&1 | tee /root/run.log"
str=$(grep -i "10 4 \* \* \* sh \<\(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/$NUMBER.sh\) 2\>&1 \| tee /root/run.log" /etc/crontabs/root)
if [ -z "$str" ] 
then
    echo "Add cron task auto run script $NUMBER.sh"
    echo "$cronTask" >> /etc/crontabs/root
fi

printf "\033[32;1mScript run complete...\033[0m\n"
printf "\033[31;1mAUTOREBOOT ROUTER...\033[0m\n"
#reboot