#!/bin/bash

sudo rm -rf ~/aleo

if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi



function install_and_run_aleo(){
    work_name=$1
    mkdir -p ~/aleo && cd ~/aleo
    wget -O aleo-pool-prover https://github.com/zkrush/aleo-pool-client/releases/download/v1.5-testnet-beta/aleo-pool-prover && chmod +x aleo-pool-prover

    run_dir=$(pwd)

    sudo tee <<EOF >/dev/null /etc/systemd/system/aleo.service
[Unit]
Description=Aleo Service
After=network-online.target
[Service]
User=root
WorkingDirectory=$run_dir
ExecStart=$run_dir/aleo-pool-prover --pool wss://aleo.zkrush.com:3333 --account equinox --worker-name $worker_name
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload && \
    sudo systemctl enable aleo && \
    sudo systemctl restart aleo

    echo "运行日志>>>>>>>"
    journalctl -u ceremonyclient.service  -n 10
    exit
}

function stop_aleo(){
    sudo systemctl stop aleo
}


if [[ $1 == "install" ]]; then

    if [ "$2" ]; then
        worker_name=$2
    else
        ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
        worker_name=${ip//\./\_}
    fi
    echo $worker_name
    install_and_run_aleo $work_name
elif [[ $1 == "stop" ]];then
    stop_aleo
fi
