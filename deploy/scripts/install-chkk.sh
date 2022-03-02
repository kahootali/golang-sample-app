#!/usr/bin/env bash

# Copyright © 2021 Chkk <support@chkk.io>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ue

DEFAULT_INSTALL_PATH=/usr/local/bin
USER_INSTALL_PATH="$HOME/bin"
CHKK_POST_RENDERER_VERSION=""

CHKK_BANNER="
       _      _     _      
   ___| |__  | | __| | __
  / __| '_ \ | |/ /| |/ /
 | (__| | | ||   < |   <
  \___|_| |_||_|\_\|_|\_\  
                           
By chkk.dev
"


# String formatting functions.
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi

tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_cyan="$(tty_mkbold 36)"
tty_yellow="$(tty_mkbold 33)"
tty_green="$(tty_mkbold 32)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

# Trap ctrl-c and call ctrl_c() to reset terminal.
trap ctrl_c INT

function ctrl_c() {
    stty sane
    exit
}

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

emph() {
  printf "${tty_bold}==> %s${tty_reset}\n" "$(shell_join "$@")"
}

abort() {
  printf "%s\n" "$1"
  exit 1
}

exists_but_not_writable() {
  [[ -e "$1" ]] && ! [[ -r "$1" && -w "$1" && -x "$1" ]]
}

# init_arch discovers the architecture for the target system.
init_arch() {
  ARCH=$(uname -m)
  case $ARCH in
    x86_64) ARCH="amd64";;
    arm64) ARCH="arm64";;
    *) ARCH="unknown";;
  esac
}

# init_os discovers the operating system for the target system.
init_os() {
  OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')
}

# verify_supported checks that the os/arch combination is supported for
# Chkk binary packages. Currently supported platforms are:
# (1) linux-amd64
# (2) darwin
verify_supported() {
  local __supported="linux-amd64\darwin-amd64\darwin-arm64"
  if ! echo "${__supported}" | grep -q "${OS}-${ARCH}"; then
    echo "No prebuilt Chkk binary is supported for target system: ${OS}-${ARCH}."
    exit 1
  fi

  if ! type "curl" >/dev/null 2>&1; then
    echo "curl is required"
    exit 1
  fi
}

# download_package downloads the Chkk post renderer package from remote
# repository.
download_package() {
  local __helm_post_renderer_version=`curl -sS https://get.chkk.dev/helm/latest.txt`
  local __download_url="https://get.chkk.dev/${__helm_post_renderer_version}/chkk-post-renderer-${OS}"
  CHKK_POST_RENDERER_VERSION=${__helm_post_renderer_version}
  printf "Downloading Chkk Post Renderer version: $__helm_post_renderer_version\n\n"
  curl -sSLo chkk-post-renderer $__download_url
  chmod +x chkk-post-renderer

  case "${INSTALL_PATH}" in
    */)
        mv chkk-post-renderer ${INSTALL_PATH}chkk-post-renderer
        ;;
    *)
        mv chkk-post-renderer ${INSTALL_PATH}/chkk-post-renderer
        ;;
    esac

  printf "Chkk Post Renderer download complete\n"
}

if exists_but_not_writable "${DEFAULT_INSTALL_PATH}"; then
    DEFAULT_INSTALL_PATH=${USER_INSTALL_PATH}
fi

# configure_default_settings sets up default environment and run configurations for Chkk
configure_default_settings() {
  # Create default directory if it does not exist
  mkdir -p $HOME/.chkk

  cat > $HOME/.chkk/config.yaml << EOF
---
filters:
  - Secret.data # DO NOT EDIT THIS LINE
  - Secret.data.* # DO NOT EDIT THIS LINE

EOF

}

echo "${CHKK_BANNER}"

emph "Info:"
cat << EOS
Chkk is an API first platform to catch reliability risks in your Kubernetes deployments and upgrades.
Chkk is built for developers, by developers and integrates across the software deployment workflows 
enabling continuous application and infrastructure reliability to eliminate your operational pain.
More information at: ${tty_underline}https://www.chkk.dev${tty_reset}

This command will install the Chkk Post Renderer for Helm (chkk-post-renderer) in a location selected by you.
After installation, you can easily use Chkk to catch reliability risks in your Kubernetes deployments 
and upgrades.

Docs:
  ${tty_underline}https://docs.chkk.dev${tty_reset}


EOS

emph "Installing Chkk Post Renderer for Helm:"
INSTALL_PATH=${INSTALL_PATH:-${DEFAULT_INSTALL_PATH}}
echo "Install Path: $INSTALL_PATH"
if exists_but_not_writable "${INSTALL_PATH}"; then
    abort "${INSTALL_PATH} is not writable or does not exist."
fi

if [[ ! -e "${INSTALL_PATH}" ]]; then
    if ! mkdir -p "${INSTALL_PATH}"; then
        abort "Failed to create directory: ${INSTALL_PATH}"
    fi
fi

init_arch
init_os
verify_supported
download_package
configure_default_settings

echo
emph "Next steps:"
cat << EOS
- Chkk Post Renderer ${CHKK_POST_RENDERER_VERSION} has been installed to: ${INSTALL_PATH}.
- Log in at ${tty_underline}https://www.chkk.dev/authenticate${tty_reset} to get your Chkk Access Token.
  Export the token as a local environment variable in your system:

    export CHKK_ACCESS_TOKEN=<YOUR_TOKEN>

- Chkk can be used in both Helm install and upgrade workflows to catch reliability risks in your deployments
  and upgrades. Simply specify the Chkk post-renderer executable 'chkk-post-renderer' when installing or upgrading
  your Kubernetes manifests. See examples below:

    Example1: Install Nginx Ingress Controller for Kubernetes
       helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
       helm repo update
       helm install my-ingress-nginx ingress-nginx/ingress-nginx --version 3.35.0 --post-renderer ${INSTALL_PATH}/chkk-post-renderer


    Example2: Upgrade Nginx Ingress Controller for Kubernetes
       helm upgrade my-ingress-nginx ingress-nginx/ingress-nginx --version 3.36.0 --post-renderer ${INSTALL_PATH}/chkk-post-renderer


- For more details, you can visit the Chkk UI Dashboard: ${tty_underline}https://www.chkk.dev/console${tty_reset}
- Further documentation on how to use Chkk in your custom workflows is available at:
    ${tty_underline}https://docs.chkk.dev${tty_reset}
EOS
