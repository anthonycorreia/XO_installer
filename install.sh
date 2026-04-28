#!/bin/sh
Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
White='\033[0;37m'

NORMAL=$(tput sgr0)

if [ $(id -u) != 0 ] ; then
  echo "${Red}Super-user (root) rights are required to install${NORMAL}"
  echo "${Red}Please run 'sudo $0' or login as root, then restart $0${NORMAL}"
  exit 1
fi

apt_install() {
  if [ $? -ne 0 ]; then
    echo "${Red}Cannot install $@ - Cancellation${NORMAL}"
    exit 1
  fi
}

step_1_upgrade() {
  echo "---------------------------------------------------------------------"
  echo "${Yellow}Starting step 1 Update and base pakage${NORMAL}"
  echo ""
  apt update
  apt upgrade -y
  apt install -y curl
  apt install -y npm
  echo "${Green}Step 1 completed${NORMAL}"
  echo ""
}

step_2_node_install() {
  echo "---------------------------------------------------------------------"
  echo "${Yellow}Starting step 2 Node v20 install${NORMAL}"
  echo ""
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
  echo "${Green}Step 2 completed${NORMAL}"
  echo ""
}

step_3_yarn_install() {
  echo "---------------------------------------------------------------------"
  echo "${Yellow}Starting step 3 Yarn install${NORMAL}"
  echo ""
  npm install --global yarn
  echo "${Green}Step 3 completed${NORMAL}"
  echo ""
}

step_4_packages_install() {
  echo "---------------------------------------------------------------------"
  echo "${Yellow}Starting step 4 XO packages install${NORMAL}"
  echo ""
  apt install -y build-essential
  apt install -y redis-server
  apt install -y libpng-dev
  apt install -y git
  apt install -y python3-minimal
  apt install -y libvhdi-utils
  apt install -y lvm2
  apt install -y cifs-utils
  echo "${Green}Step 4 completed${NORMAL}"
  echo ""
}

step_5_fetching_xo_code() {
  echo "---------------------------------------------------------------------"
  echo "${Yellow}Starting step 5 fetching the XO code${NORMAL}"
  echo ""
  git clone -b master https://github.com/vatesfr/xen-orchestra
  echo "${Green}Step 5 completed${NORMAL}"
  echo ""
}

step_6_dependencies_install() {
  echo "---------------------------------------------------------------------"
  echo "${Yellow}Starting step 6 Dependency install${NORMAL}"
  echo ""
  cd xen-orchestra
  yarn
  yarn build
  cd packages/xo-server
  mkdir -p ~/.config/xo-server
  cp sample.config.toml ~/.config/xo-server/config.toml
  echo "${VERT}Step 6 completed${NORMAL}"
  echo ""
}

step_7_xo_running() {
  echo "---------------------------------------------------------------------"
  echo "${Yellow}Starting step 7 running XO${NORMAL}"
  echo ""
  yarn global add forever
  yarn global add forever-service
  cd /home/root/xen-orchestra/packages/xo-server/
  forever-service install orchestra -r root -s dist/cli.mjs
  service orchestra start
  echo "${Green}Step 7 completed${NORMAL}"
  echo ""
}


STEP=0

echo ""
echo "${Purple}Welcome to XO installer by Antho${NORMAL}"
echo "${Purple}XO version : from sources${NORMAL}"
echo "${Purple}XO folder : xen-orchestra/packages/xo-server${NORMAL}"
echo ""

case ${STEP} in
  0)
  echo "${Yellow}Start all steps of installer${NORMAL}"
  echo ""
  step_1_upgrade
  step_2_node_install
  step_3_yarn_install
  step_4_packages_install
  step_5_fetching_xo_code
  step_6_dependencies_install
  step_7_xo_running
  echo "Installation complete."
  ;;
  1) step_1_upgrade
  ;;
  2) step_2_node_install
  ;;
  3) step_3_yarn_install
  ;;
  4) step_4_packages_install
  ;;
  5) step_5_fetching_xo_code
  ;;
  6) step_6_dependencies_install
  ;;
  7) step_7_xo_running
  ;;
  *) echo "${Red}Sorry, I cannot select a ${STEP} step for you!${NORMAL}"
  ;;
esac

exit 0
