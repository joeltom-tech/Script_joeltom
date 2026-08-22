SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/ui.sh" ]; then
  source "$SCRIPT_DIR/ui.sh"
elif [ -f "/usr/local/sbin/ui.sh" ]; then
  SCRIPT_DIR="/usr/local/sbin"
  source "$SCRIPT_DIR/ui.sh"
else
  echo "Erreur : ui.sh introuvable" >&2
  exit 1
fi

menu() {
  exec bash "$SCRIPT_DIR/menu.sh"
}

# ══════════════════════════════════════════════════════════════
#                         🎨 COLORS
# ══════════════════════════════════════════════════════════════

export LN='\033[38;5;39m'
export BG='\033[48;5;17m'
export NC='\033[0m'
export GR='\033[38;5;82m'
export RD='\033[38;5;196m'
export YE='\033[38;5;226m'
export CY='\033[38;5;51m'
export WH='\033[97m'
export DM='\033[90m'
export BD='\033[1m'

show_current_dns() {

current_dns=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | xargs)

if [[ -z "$current_dns" ]]; then
current_dns="No DNS configured"
fi

echo -e "${LN}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e "${LN}│${NC}  ${CY}${BD}📡 CURRENT ACTIVE DNS${NC}                              ${LN}│${NC}"
echo -e "${LN}│${NC}                                                            ${LN}│${NC}"
echo -e "${LN}│${NC}  ${GR}🟢${NC} ${WH}${current_dns}${NC}"
echo -e "${LN}╰────────────────────────────────────────────────────────────╯${NC}"
echo ""
}

apply_dns() {

if systemctl is-active --quiet systemd-resolved; then

if [ -L /etc/resolv.conf ]; then
sudo unlink /etc/resolv.conf
fi

echo -e "nameserver $dns1
nameserver $dns2" | sudo tee /etc/resolv.conf > /dev/null

sudo systemctl restart systemd-resolved

else

echo -e "nameserver $dns1
nameserver $dns2" | sudo tee /etc/resolv.conf > /dev/null

fi
}

dns_menu() {

clear

menu_header "DNS PANEL" "Choisissez un fournisseur DNS"

echo ""
echo -e "${LN}${BD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${LN}${BD}║${NC}                                                            ${LN}${BD}║${NC}"
echo -e "${LN}${BD}║${NC}              ${CY}${BD}🚀  DNS MANAGER  🚀${NC}                       ${LN}${BD}║${NC}"
echo -e "${LN}${BD}║${NC}                  ${DM}💻 𝑴𝑹 𝑻𝑶𝑴 💻${NC}                         ${LN}${BD}║${NC}"
echo -e "${LN}${BD}║${NC}                                                            ${LN}${BD}║${NC}"
echo -e "${LN}${BD}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""

show_current_dns

echo -e "${LN}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e "${LN}│${NC}                ${CY}${BD}🌐 DNS PROVIDERS 🌐${NC}                     ${LN}│${NC}"
echo -e "${LN}├────────────────────────────────────────────────────────────┤${NC}"

echo -e "${LN}│${NC}  ${GR}${BD}[01]${NC} 🔎 Google DNS          ${GR}${BD}[04]${NC} 🛡️ Quad9 DNS"
echo -e "${LN}│${NC}  ${GR}${BD}[02]${NC} ☁️ Cloudflare DNS      ${GR}${BD}[05]${NC} 🧩 AdGuard Default"
echo -e "${LN}│${NC}  ${GR}${BD}[03]${NC} 🌎 OpenDNS             ${GR}${BD}[06]${NC} 👨‍👩‍👧 AdGuard Family"

echo -e "${LN}│${NC}"
echo -e "${LN}├────────────────────────────────────────────────────────────┤${NC}"

echo -e "${LN}│${NC}  ${YE}${BD}[99]${NC} ⚙️ DNS personnalisé"
echo -e "${LN}│${NC}  ${RD}${BD}[00]${NC} 🔙 Retour au menu principal"

echo -e "${LN}╰────────────────────────────────────────────────────────────╯${NC}"

echo ""
echo -ne " ${CY}${BD}➤${NC} 🎯 ${WH}Choix${NC} ${DM}➜${NC} "
read -rp "" opt

case $opt in

1 |01)
dns1="8.8.8.8"
dns2="8.8.4.4"
provider="Google DNS"
;;

2 |02)
dns1="1.1.1.1"
dns2="1.0.0.1"
provider="Cloudflare DNS"
;;

3 |03)
dns1="208.67.222.222"
dns2="208.67.220.220"
provider="OpenDNS"
;;

4 |04)
dns1="9.9.9.9"
dns2="149.112.112.112"
provider="Quad9"
;;

5 |05)
dns1="94.140.14.14"
dns2="94.140.15.15"
provider="AdGuard Default"
;;

6 |06)
dns1="94.140.14.15"
dns2="94.140.15.16"
provider="AdGuard Family"
;;

99)

echo ""
echo -e "${LN}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e "${LN}│${NC}              ${YE}${BD}🛠️ DNS PERSONNALISÉ 🛠️${NC}                   ${LN}│${NC}"
echo -e "${LN}╰────────────────────────────────────────────────────────────╯${NC}"

echo ""

read -rp " 🔹 Primary DNS   : " dns1
read -rp " 🔹 Secondary DNS : " dns2

provider="Custom DNS"
;;

0 |00)
clear
menu
;;

*)
echo ""
echo -e " ${RD}${BD}❌ ERROR${NC} ${WH}Invalid option!${NC}"
sleep 2
dns_menu
;;

esac

apply_dns

clear

menu_header "DNS PANEL" "Configuration appliquée"

echo ""
echo -e "${GR}${BD}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GR}${BD}║${NC}                                                            ${GR}${BD}║${NC}"
echo -e "${GR}${BD}║${NC}          ${GR}${BD}🎉 DNS CONFIGURED SUCCESSFULLY 🎉${NC}              ${GR}${BD}║${NC}"
echo -e "${GR}${BD}║${NC}                    ${DM}💻 𝑴𝑹 𝑻𝑶𝑴 💻${NC}                       ${GR}${BD}║${NC}"
echo -e "${GR}${BD}║${NC}                                                            ${GR}${BD}║${NC}"
echo -e "${GR}${BD}╚════════════════════════════════════════════════════════════╝${NC}"

echo ""

echo -e "${LN}╭────────────────────────────────────────────────────────────╮${NC}"
echo -e "${LN}│${NC}  🏷️ ${WH}Fournisseur${NC} : ${CY}${provider}${NC}"
echo -e "${LN}│${NC}  📡 ${WH}Primaire${NC}    : ${GR}${dns1}${NC}"
echo -e "${LN}│${NC}  🔗 ${WH}Secondaire${NC}  : ${GR}${dns2}${NC}"
echo -e "${LN}╰────────────────────────────────────────────────────────────╯${NC}"

echo ""

menu_pause
dns_menu
}

dns_menu