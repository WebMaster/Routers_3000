#!/bin/sh
   
#chmod +x /tmp/054.sh && /tmp/054.sh
git="github.com"; grep -q "^140.82.114.3 $git" /etc/hosts || { printf "#$git\n140.82.114.3 $git\n185.199.110.154 github.githubassets.com\n185.199.110.133 camo.githubassets.com\n" >> /etc/hosts; /etc/init.d/dnsmasq restart 2>/dev/null; }; echo -e "\033[0;32mOK\033[0m"
sleep 5
git="githubusercontent.com"; grep -q "raw.$git" /etc/hosts || { printf "#$git\n185.199.109.133 raw.$git release-assets.$git\n185.199.108.133 private-user-images.$git gist.$git avatars.$git\n" >> /etc/hosts; /etc/init.d/dnsmasq restart 2>/dev/null; }; echo -e "\033[0;32mOK\033[0m"
sleep 5
opkg update


printf "\n\033[32;1m--- [Zapret] start install or update..\033[0m\n"
echo '1' | sh <(wget -O - https://raw.githubusercontent.com/StressOzz/Zapret-Manager/main/Zapret-Manager.sh)
sleep 5
echo 'f' | sh <(wget -O - https://raw.githubusercontent.com/StressOzz/Zapret-Manager/main/Zapret-Manager.sh)
printf "\033[32;1m--- [Zapret] all completed..\033[0m\n"



printf "\033[32;1mScript run complete...\033[0m\n"
#printf "\033[31;1mAUTOREBOOT ROUTER...\033[0m\n"
#reboot
