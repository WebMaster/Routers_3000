#!/bin/sh

#chmod +x /tmp/awg_update_25112025.sh && /tmp/awg_update_25112025.sh

URL="https://raw.githubusercontent.com/WebMaster/Routers_3000/refs/heads/main"

opkg install coreutils-base64
opkg install jq
opkg install curl

service dnsmasq restart
service odhcpd restart
service doh-proxy restart
service podkop stop
service youtubeUnblock restart

printf "\n\033[32;1m--- [AmneziaWG] start install or update..\033[0m\n"
PACKAGE="kmod-amneziawg"
REQUIRED_VERSION="6.6.110.1.0.20251005-r1"
INSTALLED_VERSION=$(opkg list-installed | grep "^$PACKAGE" | cut -d ' ' -f 3)
if [ "$INSTALLED_VERSION" != "$REQUIRED_VERSION" ]; then
    /etc/init.d/$PACKAGE stop
    #opkg remove --force-removal-of-dependent-packages $PACKAGE
    DOWNLOAD_DIR="/tmp/d_amneziawg"
    mkdir -p "$DOWNLOAD_DIR"
    ipk_files="kmod-amneziawg_v24.10.4_aarch64_cortex-a53_mediatek_filogic.ipk
        amneziawg-tools_v24.10.4_aarch64_cortex-a53_mediatek_filogic.ipk
        luci-proto-amneziawg_v24.10.4_aarch64_cortex-a53_mediatek_filogic.ipk
        luci-i18n-amneziawg-ru_v24.10.4_aarch64_cortex-a53_mediatek_filogic.ipk"
    for file in $ipk_files
    do
        echo "AmneziaWG download $file..."
        wget -q -O "$DOWNLOAD_DIR/$file" "$URL/ipk/amneziawg/$file"
        opkg install $DOWNLOAD_DIR/$file
        rm -f $DOWNLOAD_DIR/$file
    done
else
    echo "AmneziaWG install version $INSTALLED_VERSION not need update..."
fi



echo "AmneziaWG config update..."
# AWG
requestConfWARP1()
{
  #запрос конфигурации WARP AWG 1.5 (3 вариант)
  local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://config-generator-warp.vercel.app/warp4w' \
    -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36' \
	-H 'accept: */*' \
    -H 'accept-language: ru-RU,ru;q=0.9' \
    -H 'referer: https://config-generator-warp.vercel.app/')
  echo "$result"
}

requestConfWARP2()
{
  #запрос конфигурации WARP AWG 1.5 (2 вариант)
  local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://config-generator-warp.vercel.app/warp3w' \
    -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36' \
	-H 'accept: */*' \
    -H 'accept-language: ru-RU,ru;q=0.9' \
    -H 'referer: https://config-generator-warp.vercel.app/')
  echo "$result"
}

requestConfWARP3()
{
  #запрос конфигурации WARP AWG 1.5 (1 вариант)
  local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://config-generator-warp.vercel.app/warp2w' \
    -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36' \
	-H 'accept: */*' \
    -H 'accept-language: ru-RU,ru;q=0.9' \
    -H 'referer: https://config-generator-warp.vercel.app/')
  echo "$result"
}

requestConfWARP4()
{
  #запрос конфигурации WARP AWG Стандартный конфиг
  local result=$(curl --connect-timeout 20 --max-time 60 -w "%{http_code}" 'https://config-generator-warp.vercel.app/warp1w' \
    -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36' \
	-H 'accept: */*' \
    -H 'accept-language: ru-RU,ru;q=0.9' \
    -H 'referer: https://config-generator-warp.vercel.app/')
  echo "$result"
}


confWarpBuilder()
{
	response_body=$1
	peer_pub=$(echo "$response_body" | jq -r '.result.config.peers[0].public_key')
		    client_ipv4=$(echo "$response_body" | jq -r '.result.config.interface.addresses.v4')
		    client_ipv6=$(echo "$response_body" | jq -r '.result.config.interface.addresses.v6')
		    priv=$(echo "$response_body" | jq -r '.result.key')
		    conf=$(cat <<-EOM
[Interface]
PrivateKey = ${priv}
S1 = 0
S2 = 0
Jc = 120
Jmin = 23
Jmax = 911
H1 = 1
H2 = 2
H3 = 3
H4 = 4
MTU = 1280
I1 = <b 0xc2000000011419fa4bb3599f336777de79f81ca9a8d80d91eeec000044c635cef024a885dcb66d1420a91a8c427e87d6cf8e08b563932f449412cddf77d3e2594ea1c7a183c238a89e9adb7ffa57c133e55c59bec101634db90afb83f75b19fe703179e26a31902324c73f82d9354e1ed8da39af610afcb27e6590a44341a0828e5a3d2f0e0f7b0945d7bf3402feea0ee6332e19bdf48ffc387a97227aa97b205a485d282cd66d1c384bafd63dc42f822c4df2109db5b5646c458236ddcc01ae1c493482128bc0830c9e1233f0027a0d262f92b49d9d8abd9a9e0341f6e1214761043c021d7aa8c464b9d865f5fbe234e49626e00712031703a3e23ef82975f014ee1e1dc428521dc23ce7c6c13663b19906240b3efe403cf30559d798871557e4e60e86c29ea4504ed4d9bb8b549d0e8acd6c334c39bb8fb42ede68fb2aadf00cfc8bcc12df03602bbd4fe701d64a39f7ced112951a83b1dbbe6cd696dd3f15985c1b9fef72fa8d0319708b633cc4681910843ce753fac596ed9945d8b839aeff8d3bf0449197bd0bb22ab8efd5d63eb4a95db8d3ffc796ed5bcf2f4a136a8a36c7a0c65270d511aebac733e61d414050088a1c3d868fb52bc7e57d3d9fd132d78b740a6ecdc6c24936e92c28672dbe00928d89b891865f885aeb4c4996d50c2bbbb7a99ab5de02ac89b3308e57bcecf13f2da0333d1420e18b66b4c23d625d836b538fc0c221d6bd7f566a31fa292b85be96041d8e0bfe655d5dc1afed23eb8f2b3446561bbee7644325cc98d31cea38b865bdcc507e48c6ebdc7553be7bd6ab963d5a14615c4b81da7081c127c791224853e2d19bafdc0d9f3f3a6de898d14abb0e2bc849917e0a599ed4a541268ad0e60ea4d147dc33d17fa82f22aa505ccb53803a31d10a7ca2fea0b290a52ee92c7bf4aab7cea4e3c07b1989364eed87a3c6ba65188cd349d37ce4eefde9ec43bab4b4dc79e03469c2ad6b902e28e0bbbbf696781ad4edf424ffb35ce0236d373629008f142d04b5e08a124237e03e3149f4cdde92d7fae581a1ac332e26b2c9c1a6bdec5b3a9c7a2a870f7a0c25fc6ce245e029b686e346c6d862ad8df6d9b62474fbc31dbb914711f78074d4441f4e6e9edca3c52315a5c0653856e23f681558d669f4a4e6915bcf42b56ce36cb7dd3983b0b1d6fdf0f8efddb68e7ca0ae9dd4570fe6978fbb524109f6ec957ca61f1767ef74eb803b0f16abd0087cf2d01bc1db1c01d97ac81b3196c934586963fe7cf2d310e0739621e8bd00dc23fded18576d8c8f285d7bb5f43b547af3c76235de8b6f757f817683b2151600b11721219212bf27558edd439e73fce951f61d582320e5f4d6c315c71129b719277fc144bbe8ded25ab6d29b6e189c9bd9b16538faf60cc2aab3c3bb81fc2213657f2dd0ceb9b3b871e1423d8d3e8cc008721ef03b28e0ee7bb66b8f2a2ac01ef88df1f21ed49bf1ce435df31ac34485936172567488812429c269b49ee9e3d99652b51a7a614b7c460bf0d2d64d8349ded7345bedab1ea0a766a8470b1242f38d09f7855a32db39516c2bd4bcc538c52fa3a90c8714d4b006a15d9c7a7d04919a1cab48da7cce0d5de1f9e5f8936cffe469132991c6eb84c5191d1bcf69f70c58d9a7b66846440a9f0eef25ee6ab62715b50ca7bef0bc3013d4b62e1639b5028bdf757454356e9326a4c76dabfb497d451a3a1d2dbd46ec283d255799f72dfe878ae25892e25a2542d3ca9018394d8ca35b53ccd94947a8>
Address = ${client_ipv4}, ${client_ipv6}
DNS = 1.1.1.1, 2606:4700:4700::1111, 1.0.0.1, 2606:4700:4700::1001

[Peer]
PublicKey = ${peer_pub}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = 162.159.192.1:500
EOM
)
echo "$conf"
}

# Функция для обработки выполнения запроса
check_request() {
    local response="$1"
	local choice="$2"
	
    # Извлекаем код состояния
    response_code="${response: -3}"  # Последние 3 символа - это код состояния
    response_body="${response%???}"    # Все, кроме последних 3 символов - это тело ответа
    #echo $response_body
	#echo $response_code
    # Проверяем код состояния
    if [ "$response_code" -eq 200 ]; then
		case $choice in
		1)
			content=$(echo $response_body | jq -r '.content')    
            warp_config=$(echo "$content" | base64 -d)
            echo "$warp_config"
            ;;
		2)
			content=$(echo $response_body | jq -r '.content')  
            warp_config=$(echo "$content" | base64 -d)
            echo "$warp_config"
            ;;
		3)
			content=$(echo $response_body | jq -r '.content')
			warp_config=$(echo "$content" | base64 -d)
            echo "$warp_config"
            ;;
		4)
			content=$(echo $response_body | jq -r '.content')
			warp_config=$(echo "$content" | base64 -d)
            echo "$warp_config"
            ;;
		*)
			echo "Error"
		esac
	else
		echo "Error"
	fi
}



#if [ "$1" = "y" ] || [ "$1" = "Y" ]
#then
#	is_manual_input_parameters="y"
#else
	is_manual_input_parameters="n"
#fi
#if [ "$2" = "y" ] || [ "$2" = "Y" ] || [ "$2" = "" ]
#then
#	is_reconfig_podkop="y"
#else
	is_reconfig_podkop="n"
#fi

echo "Configure dhcp..."

uci set dhcp.cfg01411c.strictorder='1'
uci set dhcp.cfg01411c.filter_aaaa='1'
uci commit dhcp

cat <<EOF > /etc/sing-box/config.json
{
	"log": {
	"disabled": true,
	"level": "error"
},
"inbounds": [
	{
	"type": "tproxy",
	"listen": "::",
	"listen_port": 1100,
	"sniff": false
	}
],
"outbounds": [
	{
	"type": "http",
	"server": "127.0.0.1",
	"server_port": 18080
	}
],
"route": {
	"auto_detect_interface": true
}
}
EOF

echo "Setting sing-box..."
uci set sing-box.main.enabled='1'
uci set sing-box.main.user='root'
uci add_list sing-box.main.ifaces='wan'
uci add_list sing-box.main.ifaces='wan2'
uci add_list sing-box.main.ifaces='wan6'
uci add_list sing-box.main.ifaces='wwan'
uci add_list sing-box.main.ifaces='wwan0'
uci add_list sing-box.main.ifaces='modem'
uci add_list sing-box.main.ifaces='l2tp'
uci add_list sing-box.main.ifaces='pptp'
uci commit sing-box

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

isWorkOperaProxy=0
printf "\033[32;1mCheck opera proxy...\033[0m\n"
service sing-box restart
curl --proxy http://127.0.0.1:18080 ipinfo.io/ip
if [ $? -eq 0 ]; then
	printf "\n\033[32;1mOpera proxy well work...\033[0m\n"
	isWorkOperaProxy=1
else
	printf "\n\033[32;1mOpera proxy not work...\033[0m\n"
	isWorkOperaProxy=0
fi

#printf "\033[32;1mAutomatic generate config AmneziaWG WARP (n) or manual input parameters for AmneziaWG (y)...\033[0m\n"
countRepeatAWGGen=2
#echo "Input manual parameters AmneziaWG? (y/n): "
#read is_manual_input_parameters
currIter=0
isExit=0
while [ $currIter -lt $countRepeatAWGGen ] && [ "$isExit" = "0" ]
do
	currIter=$(( $currIter + 1 ))
	printf "\033[32;1mCreate and Check AWG WARP... Attempt #$currIter... Please wait...\033[0m\n"
	if [ "$is_manual_input_parameters" = "y" ] || [ "$is_manual_input_parameters" = "Y" ]
	then
		read -r -p "Enter the private key (from [Interface]):"$'\n' PrivateKey
		read -r -p "Enter S1 value (from [Interface]):"$'\n' S1
		read -r -p "Enter S2 value (from [Interface]):"$'\n' S2
		read -r -p "Enter Jc value (from [Interface]):"$'\n' Jc
		read -r -p "Enter Jmin value (from [Interface]):"$'\n' Jmin
		read -r -p "Enter Jmax value (from [Interface]):"$'\n' Jmax
		read -r -p "Enter H1 value (from [Interface]):"$'\n' H1
		read -r -p "Enter H2 value (from [Interface]):"$'\n' H2
		read -r -p "Enter H3 value (from [Interface]):"$'\n' H3
		read -r -p "Enter H4 value (from [Interface]):"$'\n' H4
		
		while true; do
			read -r -p "Enter internal IP address with subnet, example 192.168.100.5/24 (from [Interface]):"$'\n' Address
			if echo "$Address" | egrep -oq '^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]+)?$'; then
				break
			else
				echo "This IP is not valid. Please repeat"
			fi
		done

		read -r -p "Enter the public key (from [Peer]):"$'\n' PublicKey
		read -r -p "Enter Endpoint host without port (Domain or IP) (from [Peer]):"$'\n' EndpointIP
		read -r -p "Enter Endpoint host port (from [Peer]) [51820]:"$'\n' EndpointPort

		DNS="1.1.1.1"
		MTU=1280
		AllowedIPs="0.0.0.0/0"
		isExit=1
	else
		warp_config="Error"
		
		printf "\033[32;1mRequest WARP config... Attempt #1\033[0m\n"
		result=$(requestConfWARP1)
		warpGen=$(check_request "$result" 1)
		
		if [ "$warpGen" = "Error" ]
		then
			printf "\033[32;1mRequest WARP config... Attempt #2\033[0m\n"
			result=$(requestConfWARP2)
			warpGen=$(check_request "$result" 2)
			if [ "$warpGen" = "Error" ]
			then
				printf "\033[32;1mRequest WARP config... Attempt #3\033[0m\n"
				result=$(requestConfWARP3)
				warpGen=$(check_request "$result" 3)
				if [ "$warpGen" = "Error" ]
				then
					printf "\033[32;1mRequest WARP config... Attempt #4\033[0m\n"
					result=$(requestConfWARP3)
					warpGen=$(check_request "$result" 3)
					if [ "$warpGen" = "Error" ]
					then
						warp_config="Error"
					else
						warp_config=$warpGen
					fi
				else
					warp_config=$warpGen
				fi
			else
				warp_config=$warpGen
			fi
		else
			warp_config=$warpGen
		fi
		
		if [ "$warp_config" = "Error" ] 
		then
			printf "\033[32;1mGenerate config AWG WARP failed...Try again later...\033[0m\n"
			isExit=2
			#exit 1
		else
			while IFS=' = ' read -r line; do
			if echo "$line" | grep -q "="; then
				# Разделяем строку по первому вхождению "="
				key=$(echo "$line" | cut -d'=' -f1 | xargs)  # Убираем пробелы
				value=$(echo "$line" | cut -d'=' -f2- | xargs)  # Убираем пробелы
				#echo "key = $key, value = $value"
				eval "$key=\"$value\""
			fi
			done < <(echo "$warp_config")

			#вытаскиваем нужные нам данные из распарсинного ответа
			Address=$(echo "$Address" | cut -d',' -f1)
			DNS=$(echo "$DNS" | cut -d',' -f1)
			AllowedIPs=$(echo "$AllowedIPs" | cut -d',' -f1)
			EndpointIP=$(echo "$Endpoint" | cut -d':' -f1)
			EndpointPort=$(echo "$Endpoint" | cut -d':' -f2)
		fi
	fi
	
	if [ "$isExit" = "2" ] 
	then
		isExit=0
	else
		printf "\033[32;1mCreate and configure tunnel AmneziaWG WARP...\033[0m\n"

		#задаём имя интерфейса
		INTERFACE_NAME="awg10"
		CONFIG_NAME="amneziawg_awg10"
		PROTO="amneziawg"
		ZONE_NAME="awg"

		uci set network.${INTERFACE_NAME}=interface
		uci set network.${INTERFACE_NAME}.proto=$PROTO
		if ! uci show network | grep -q ${CONFIG_NAME}; then
			uci add network ${CONFIG_NAME}
		fi
		uci set network.${INTERFACE_NAME}.private_key=$PrivateKey
		uci del network.${INTERFACE_NAME}.addresses
		uci add_list network.${INTERFACE_NAME}.addresses=$Address
		uci set network.${INTERFACE_NAME}.mtu=$MTU
		uci set network.${INTERFACE_NAME}.awg_jc=$Jc
		uci set network.${INTERFACE_NAME}.awg_jmin=$Jmin
		uci set network.${INTERFACE_NAME}.awg_jmax=$Jmax
		uci set network.${INTERFACE_NAME}.awg_s1=$S1
		uci set network.${INTERFACE_NAME}.awg_s2=$S2
		uci set network.${INTERFACE_NAME}.awg_h1=$H1
		uci set network.${INTERFACE_NAME}.awg_h2=$H2
		uci set network.${INTERFACE_NAME}.awg_h3=$H3
		uci set network.${INTERFACE_NAME}.awg_h4=$H4
		if [ -z "$I1" ] 
		then
			I1="<b 0xc10000000114367096bb0fb3f58f3a3fb8aaacd61d63a1c8a40e14f7374b8a62dccba6431716c3abf6f5afbcfb39bd008000047c32e268567c652e6f4db58bff759bc8c5aaca183b87cb4d22938fe7d8dca22a679a79e4d9ee62e4bbb3a380dd78d4e8e48f26b38a1d42d76b371a5a9a0444827a69d1ab5872a85749f65a4104e931740b4dc1e2dd77733fc7fac4f93011cd622f2bb47e85f71992e2d585f8dc765a7a12ddeb879746a267393ad023d267c4bd79f258703e27345155268bd3cc0506ebd72e2e3c6b5b0f005299cd94b67ddabe30389c4f9b5c2d512dcc298c14f14e9b7f931e1dc397926c31fbb7cebfc668349c218672501031ecce151d4cb03c4c660b6c6fe7754e75446cd7de09a8c81030c5f6fb377203f551864f3d83e27de7b86499736cbbb549b2f37f436db1cae0a4ea39930f0534aacdd1e3534bc87877e2afabe959ced261f228d6362e6fd277c88c312d966c8b9f67e4a92e757773db0b0862fb8108d1d8fa262a40a1b4171961f0704c8ba314da2482ac8ed9bd28d4b50f7432d89fd800c25a50c5e2f5c0710544fef5273401116aa0572366d8e49ad758fcb29e6a92912e644dbe227c247cb3417eabfab2db16796b2fba420de3b1dc94e8361f1f324a331ddaf1e626553138860757fd0bf687566108b77b70fb9f8f8962eca599c4a70ed373666961a8cb506b96756d9e28b94122b20f16b54f118c0e603ce0b831efea614ad836df6cf9affbdd09596412547496967da758cec9080295d853b0861670b71d9abde0d562b1a6de82782a5b0c14d297f27283a895abc889a5f6703f0e6eb95f67b2da45f150d0d8ab805612d570c2d5cb6997ac3a7756226c2f5c8982ffbd480c5004b0660a3c9468945efde90864019a2b519458724b55d766e16b0da25c0557c01f3c11ddeb024b62e303640e17fdd57dedb3aeb4a2c1b7c93059f9c1d7118d77caac1cd0f6556e46cbc991c1bb16970273dea833d01e5090d061a0c6d25af2415cd2878af97f6d0e7f1f936247b394ecb9bd484da6be936dee9b0b92dc90101a1b4295e97a9772f2263eb09431995aa173df4ca2abd687d87706f0f93eaa5e13cbe3b574fa3cfe94502ace25265778da6960d561381769c24e0cbd7aac73c16f95ae74ff7ec38124f7c722b9cb151d4b6841343f29be8f35145e1b27021056820fed77003df8554b4155716c8cf6049ef5e318481460a8ce3be7c7bfac695255be84dc491c19e9dedc449dd3471728cd2a3ee51324ccb3eef121e3e08f8e18f0006ea8957371d9f2f739f0b89e4db11e5c6430ada61572e589519fbad4498b460ce6e4407fc2d8f2dd4293a50a0cb8fcaaf35cd9a8cc097e3603fbfa08d9036f52b3e7fcce11b83ad28a4ac12dba0395a0cc871cefd1a2856fffb3f28d82ce35cf80579974778bab13d9b3578d8c75a2d196087a2cd439aff2bb33f2db24ac175fff4ed91d36a4cdbfaf3f83074f03894ea40f17034629890da3efdbb41141b38368ab532209b69f057ddc559c19bc8ae62bf3fd564c9a35d9a83d14a95834a92bae6d9a29ae5e8ece07910d16433e4c6230c9bd7d68b47de0de9843988af6dc88b5301820443bd4d0537778bf6b4c1dd067fcf14b81015f2a67c7f2a28f9cb7e0684d3cb4b1c24d9b343122a086611b489532f1c3a26779da1706c6759d96d8ab>"
		fi
		uci set network.${INTERFACE_NAME}.awg_i1="$I1"
		uci set network.${INTERFACE_NAME}.nohostroute='1'
		
		uci set network.@${CONFIG_NAME}[-1].description="${INTERFACE_NAME}_peer"
		uci set network.@${CONFIG_NAME}[-1].public_key=$PublicKey
		uci set network.@${CONFIG_NAME}[-1].endpoint_host=$EndpointIP
		uci set network.@${CONFIG_NAME}[-1].endpoint_port=$EndpointPort
		uci set network.@${CONFIG_NAME}[-1].persistent_keepalive='25'
		uci set network.@${CONFIG_NAME}[-1].allowed_ips='0.0.0.0/0'
		uci set network.@${CONFIG_NAME}[-1].route_allowed_ips='0'
		uci commit network

		if ! uci show firewall | grep -q "@zone.*name='${ZONE_NAME}'"; then
			printf "\033[32;1mZone Create\033[0m\n"
			uci add firewall zone
			uci set firewall.@zone[-1].name=$ZONE_NAME
			uci set firewall.@zone[-1].network=$INTERFACE_NAME
			uci set firewall.@zone[-1].forward='REJECT'
			uci set firewall.@zone[-1].output='ACCEPT'
			uci set firewall.@zone[-1].input='REJECT'
			uci set firewall.@zone[-1].masq='1'
			uci set firewall.@zone[-1].mtu_fix='1'
			uci set firewall.@zone[-1].family='ipv4'
			uci commit firewall
		fi

		if ! uci show firewall | grep -q "@forwarding.*name='${ZONE_NAME}'"; then
			printf "\033[32;1mConfigured forwarding\033[0m\n"
			uci add firewall forwarding
			uci set firewall.@forwarding[-1]=forwarding
			uci set firewall.@forwarding[-1].name="${ZONE_NAME}"
			uci set firewall.@forwarding[-1].dest=${ZONE_NAME}
			uci set firewall.@forwarding[-1].src='lan'
			uci set firewall.@forwarding[-1].family='ipv4'
			uci commit firewall
		fi

		# Получаем список всех зон
		ZONES=$(uci show firewall | grep "zone$" | cut -d'=' -f1)
		#echo $ZONES
		# Циклически проходим по всем зонам
		for zone in $ZONES; do
		# Получаем имя зоны
		CURR_ZONE_NAME=$(uci get $zone.name)
		#echo $CURR_ZONE_NAME
		# Проверяем, является ли это зона с именем "$ZONE_NAME"
		if [ "$CURR_ZONE_NAME" = "$ZONE_NAME" ]; then
			# Проверяем, существует ли интерфейс в зоне
			if ! uci get $zone.network | grep -q "$INTERFACE_NAME"; then
			# Добавляем интерфейс в зону
			uci add_list $zone.network="$INTERFACE_NAME"
			uci commit firewall
			#echo "Интерфейс '$INTERFACE_NAME' добавлен в зону '$ZONE_NAME'"
			fi
		fi
		done
		if [ "$currIter" = "1" ]
		then
			service firewall restart
		fi
		#service firewall restart
		#service network restart

		if [ "$is_manual_input_parameters" = "n" ]; then
			I=0
			WARP_ENDPOINT_HOSTS="engage.cloudflareclient.com 162.159.192.1 162.159.192.2 162.159.192.4 162.159.195.1 162.159.195.4 188.114.96.1 188.114.96.23 188.114.96.50 188.114.96.81"
			#WARP_ENDPOINT_HOSTS="engage.cloudflareclient.com"
			WARP_ENDPOINT_PORTS="500 1701 2408 3138 4500"
			#WARP_ENDPOINT_PORTS="500"
			for element in $WARP_ENDPOINT_HOSTS; do
				EndpointIP="$element"
				for element2 in $WARP_ENDPOINT_PORTS; do
					I=$(( $I + 1 ))
					EndpointPort="$element2"
					uci set network.@${CONFIG_NAME}[-1].endpoint_host=$EndpointIP
					uci set network.@${CONFIG_NAME}[-1].endpoint_port=$EndpointPort
					uci commit network
					# Отключаем интерфейс
					ifdown $INTERFACE_NAME
					# Включаем интерфейс
					ifup $INTERFACE_NAME
					printf "\033[33;1mIter #$I: Check Endpoint WARP $element:$element2. Wait up AWG WARP 10 second...\033[0m\n"
					sleep 10
					
					pingAddress="8.8.8.8"
					if ping -c 1 -I $INTERFACE_NAME $pingAddress >/dev/null 2>&1
					then
						printf "\033[32;1m	Endpoint WARP $element:$element2 work...\033[0m\n"
						isExit=1
						break
					else
						printf "\033[31;1m	Endpoint WARP $element:$element2 not work...\033[0m\n"
						isExit=0
					fi
				done
				if [ "$isExit" = "1" ]
				then
					break
				fi
			done
		else
			# Отключаем интерфейс
			ifdown $INTERFACE_NAME
			# Включаем интерфейс
			ifup $INTERFACE_NAME
			printf "\033[32;1mWait up AWG WARP 10 second...\033[0m\n"
			sleep 10
			
			pingAddress="8.8.8.8"
			if ping -c 1 -I $INTERFACE_NAME $pingAddress >/dev/null 2>&1
			then
				isExit=1
			else
				isExit=0
			fi
		fi
	fi
done
# AWG

varByPass=0
isWorkWARP=0

if [ "$isExit" = "1" ]
then
	printf "\033[32;1mAWG WARP well work...\033[0m\n"
	isWorkWARP=1
else
	printf "\033[32;1mAWG WARP not work.....Try opera proxy...\033[0m\n"
	isWorkWARP=0
fi

printf "\033[32;1m$messageComplete\033[0m\n"
#printf "\033[31;1mAUTOREBOOT ROUTER...\033[0m\n"
#reboot
printf "\033[32;1m--- [AmneziaWG] all completed..\033[0m\n"
exit 1






