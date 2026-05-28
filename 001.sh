#!/bin/sh
  
#chmod +x /tmp/001.sh && /tmp/001.sh
printf "\033[32;1m--- [Cron] start install or update..\033[0m\n"
cronTask="10 4 * * * sh <(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/001.sh) 2>&1 | tee /root/run.log"
str=$(grep -i "10 4 \* \* \* sh \<\(wget --no-check-certificate -q -O - https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main/001.sh\) 2\>&1 \| tee /root/run.log" /etc/crontabs/root)
#if [ -z "$str" ] 
#then
    echo "Add cron task auto run script"
    echo "$cronTask" > /etc/crontabs/root
#fi
printf "\033[32;1m--- [Cron] all completed..\033[0m\n"
 
#git="githubusercontent.com"; grep -q "raw.$git" /etc/hosts || { printf "#$git\n185.199.109.133 raw.$git release-assets.$git\n185.199.108.133 private-user-images.$git gist.$git avatars.$git\n" >> /etc/hosts; /etc/init.d/dnsmasq restart 2>/dev/null; }; echo -e "\033[0;32mOK\033[0m"

#opkg update

URL="https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main"


printf "\n\033[32;1m--- [Opera-proxy] start install or update..\033[0m\n"
#opkg remove --force-removal-of-dependent-packages opera-proxy
printf "\033[32;1m--- [Opera-proxy] all completed..\033[0m\n"

printf "\n\033[32;1m--- [youtubeUnblock] start install or update..\033[0m\n"
opkg remove --force-removal-of-dependent-packages youtubeUnblock
printf "\033[32;1m--- [youtubeUnblock] all completed..\033[0m\n"

printf "\n\033[32;1m--- [Podkop] start install or update..\033[0m\n"
opkg remove --force-removal-of-dependent-packages podkop
printf "\033[32;1m--- [Podkop] all completed..\033[0m\n"


nameRule="option name 'Block_UDP_443'"
str=$(grep -i "$nameRule" /etc/config/firewall)
if [ -z "$str" ] 
then
  echo "Add block QUIC..."

  uci add firewall rule # =cfg2492bd
  uci set firewall.@rule[-1].name='Block_UDP_80'
  uci add_list firewall.@rule[-1].proto='udp'
  uci set firewall.@rule[-1].src='lan'
  uci set firewall.@rule[-1].dest='wan'
  uci set firewall.@rule[-1].dest_port='80'
  uci set firewall.@rule[-1].target='REJECT'
  uci add firewall rule # =cfg2592bd
  uci set firewall.@rule[-1].name='Block_UDP_443'
  uci add_list firewall.@rule[-1].proto='udp'
  uci set firewall.@rule[-1].src='lan'
  uci set firewall.@rule[-1].dest='wan'
  uci set firewall.@rule[-1].dest_port='443'
  uci set firewall.@rule[-1].target='REJECT'
  uci commit firewall
fi



printf "\n\033[32;1m--- [Zapret] start install or update..\033[0m\n"
#echo '9' | sh <(wget -O - https://raw.githubusercontent.com/StressOzz/Zapret-Manager/main/Zapret-Manager.sh)
wget -O /tmp/Zapret-Manager.sh https://raw.githubusercontent.com/StressOzz/Zapret-Manager/main/Zapret-Manager.sh && echo '9' | sh /tmp/Zapret-Manager.sh
printf "\033[32;1m--- [Zapret] all completed..\033[0m\n"



printf "\033[32;1mScript run complete...\033[0m\n"
printf "\033[31;1mAUTOREBOOT ROUTER...\033[0m\n"
reboot