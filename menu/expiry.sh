clear

CONFIG="/etc/xray/config.json"
today=$(date +"%Y-%m-%d")

remove_expired_users() {

local marker="$1"
local proto="$2"

users=($(grep "^$marker " "$CONFIG" | awk '{print $2}' | sort -u))

for user in "${users[@]}"; do

exp=$(grep -w "^$marker $user" "$CONFIG" | awk '{print $3}' | head -n1)

d1=$(date -d "$exp" +%s)
d2=$(date -d "$today" +%s)

days_left=$(( (d1 - d2) / 86400 ))

if [[ $days_left -le 0 ]]; then

echo -e " ${RD}⛔${NC} Removing expired ${YE}$proto${NC} user: ${CY}$user${NC}"

sed -i "/^$marker $user $exp/,/\"email\": \"$user\"/d" "$CONFIG"

else

echo -e " ${GR}✅${NC} ${YE}$proto${NC} : ${CY}$user${NC} ${DM}→ ${days_left} day(s) remaining${NC}"

fi

done
}

remove_expired_ssh() {

echo ""
echo -e "${CY}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CY}║${NC}             🔐 ${WH}CHECKING SSH ACCOUNTS${NC} 🔐              ${CY}║${NC}"
echo -e "${CY}║${NC}                    💻 ${WH}𝑴𝑹 𝑻𝑶𝑴${NC}                         ${CY}║${NC}"
echo -e "${CY}╚════════════════════════════════════════════════════════════╝${NC}"

awk -F: '$8!="" {print $1":"$8}' /etc/shadow > /tmp/expirelist.txt

while IFS=: read -r user exp_days; do

exp_ts=$(( exp_days * 86400 ))
today_ts=$(date +%s)

if (( exp_ts < today_ts )); then

echo -e " ${RD}⛔${NC} Removing expired SSH user: ${CY}$user${NC}"

userdel --force "$user" 2>/dev/null
rm -rf /home/$user

fi

done < /tmp/expirelist.txt
}

remove_expired_zivpn() {

echo ""
echo -e "${CY}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CY}║${NC}            🛡️ ${WH}CHECKING ZIVPN ACCOUNTS${NC} 🛡️             ${CY}║${NC}"
echo -e "${CY}║${NC}                    💻 ${WH}𝑴𝑹 𝑻𝑶𝑴${NC}                         ${CY}║${NC}"
echo -e "${CY}╚════════════════════════════════════════════════════════════╝${NC}"

[[ ! -f "$ZIVPN_DB" ]] && return

while read -r line; do

user=$(echo "$line" | awk '{print $1}')
pass=$(echo "$line" | awk '{print $2}')
exp=$(echo "$line" | awk '{print $3}')

[[ -z "$user" || -z "$exp" ]] && continue

d1=$(date -d "$exp" +%s)
d2=$(date -d "$today" +%s)

if (( d1 < d2 )); then

echo -e " ${RD}⛔${NC} Removing expired ZIVPN user: ${CY}$user${NC}"

sed -i "/\"$pass\"/d" "$ZIVPN_CFG"
sed -i "/^$user /d" "$ZIVPN_DB"

else

echo -e " ${GR}✅${NC} ZIVPN : ${CY}$user${NC} ${DM}→ Active${NC}"

fi

done < "$ZIVPN_DB"

systemctl restart zivpn
}

# ══════════════════════════════════════════════════════════════
#                    🚀 START CLEANUP
# ══════════════════════════════════════════════════════════════

echo ""
echo -e "${CY}${BD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CY}${BD}║${NC}                                                            ${CY}${BD}║${NC}"
echo -e "${CY}${BD}║${NC}          🧹 ${WH}${BD}EXPIRED USERS CLEANER${NC} 🧹                 ${CY}${BD}║${NC}"
echo -e "${CY}${BD}║${NC}                    💻 ${WH}𝑴𝑹 𝑻𝑶𝑴${NC}                          ${CY}${BD}║${NC}"
echo -e "${CY}${BD}║${NC}                                                            ${CY}${BD}║${NC}"
echo -e "${CY}${BD}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""

remove_expired_users "###" "VMess"
remove_expired_users "#&"  "VLESS"
remove_expired_users "#!"  "Trojan"
remove_expired_users "#@"  "SOCKS"

remove_expired_ssh
remove_expired_zivpn

systemctl restart xray

echo ""
echo -e "${GR}${BD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GR}${BD}║${NC}                                                            ${GR}${BD}║${NC}"
echo -e "${GR}${BD}║${NC}             🎉 ${WH}CLEANUP COMPLETED${NC} 🎉                   ${GR}${BD}║${NC}"
echo -e "${GR}${BD}║${NC}                                                            ${GR}${BD}║${NC}"
echo -e "${GR}${BD}║${NC}  ✅ Expired users cleaned successfully"
echo -e "${GR}${BD}║${NC}  🚀 Xray restarted"
echo -e "${GR}${BD}║${NC}  💻 ${WH}𝑴𝑹 𝑻𝑶𝑴${NC}"
echo -e "${GR}${BD}║${NC}                                                            ${GR}${BD}║${NC}"
echo -e "${GR}${BD}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""