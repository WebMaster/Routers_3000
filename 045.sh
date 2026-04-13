#!/bin/sh
  
#chmod +x /tmp/045.sh && /tmp/045.sh
printf "\033[32;1m--- [Cron] start install or update..\033[0m\n"
cronTask="10 4 * * * sh <(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/045.sh) 2>&1 | tee /root/run.log"
str=$(grep -i "10 4 \* \* \* sh \<\(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/045.sh\) 2\>&1 \| tee /root/run.log" /etc/crontabs/root)
if [ -z "$str" ] 
then
    echo "Add cron task auto run script"
    echo "$cronTask" > /etc/crontabs/root
fi
printf "\033[32;1m--- [Cron] all completed..\033[0m\n"
 
opkg update

printf "\n\033[32;1m--- [Zapret] start install or update..\033[0m\n"
wget -O /tmp/Zapret-Manager.sh https://raw.githubusercontent.com/StressOzz/Zapret-Manager/main/Zapret-Manager.sh
echo '9' | sh /tmp/Zapret-Manager.sh
printf "\033[32;1m--- [Zapret] all completed..\033[0m\n"


printf "\033[32;1mScript run complete...\033[0m\n"
printf "\033[31;1mAUTOREBOOT ROUTER...\033[0m\n"
reboot