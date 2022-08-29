#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${APM_TMP_DIR}" ]]; then
    echo "APM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_INSTALL_DIR}" ]]; then
    echo "APM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_BIN_DIR}" ]]; then
    echo "APM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/indygreg/python-build-standalone/releases/download/20220802/cpython-3.9.13+20220802-x86_64-unknown-linux-gnu-install_only.tar.gz -O $APM_TMP_DIR/cpython-3.9.13.tar.gz
  tar xf $APM_TMP_DIR/cpython-3.9.13.tar.gz -C $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/cpython-3.9.13.tar.gz

  wget https://github.com/threat9/routersploit/archive/3fd394637f5566c4cf6369eecae08c4d27f93cda.tar.gz -O $APM_TMP_DIR/routersploit.tar.gz
  tar xf $APM_TMP_DIR/routersploit.tar.gz -C $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/routersploit.tar.gz
  mv $APM_PKG_INSTALL_DIR/routersploit-3fd394637f5566c4cf6369eecae08c4d27f93cda mv $APM_PKG_INSTALL_DIR/routersploit

  $APM_PKG_INSTALL_DIR/python/bin/pip3.9 install -r $APM_PKG_INSTALL_DIR/routersploit/requirements.txt
  (cd $APM_PKG_INSTALL_DIR/routersploit && $APM_PKG_INSTALL_DIR/python/bin/python3.9 setup.py install)

  ln -s $APM_PKG_INSTALL_DIR/python/bin/rsf.py $APM_PKG_BIN_DIR/
}

uninstall() {
  rm -rf $APM_PKG_BIN_DIR/python
  rm -rf $APM_PKG_BIN_DIR/routersploit
  rm $APM_PKG_BIN_DIR/rsf.py
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1