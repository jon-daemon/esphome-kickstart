#!/bin/bash

set -e
mkdir -p build/
cd yaml/
configs=("bk7231t" "bk7231n" "rtl8710bn" "esp8266" "esp32")

echo -e "\nSelect configuration to compile (q to quit):"
for i in "${!configs[@]}"; do
    echo "$((i+1)). ${configs[i]}"
done
echo -e "\nEnter numbers separated by spaces ('1 3 5'), or 'all' to compile all:"

selected=()

while true; do
    read -r input
    if [[ $input == "q" ]]; then
        exit 0
    elif [[ $input == "all" ]]; then
        selected=("${configs[@]}")
        break
    else
        indices=($input)
        for index in "${indices[@]}"; do
            if [[ $index =~ ^[0-9]+$ && $index -ge 1 && $index -le ${#configs[@]} ]]; then
                selected+=("${configs[index-1]}")
            else
                echo "Invalid input"
            fi
        done
        break
    fi
done

for config in "${selected[@]}"; do
    esphome compile kickstart-"$config".yaml

    if [ $config = "esp8266" ] || [ $config = "esp32" ]; then
        cp .esphome/build/kickstart-${config}/.pioenvs/kickstart-${config}/firmware.bin ../build/kickstart-${config}.bin
    else
        cp .esphome/build/kickstart-${config}/.pioenvs/kickstart-${config}/firmware.uf2 ../build/kickstart-${config}.uf2

        if [ $config = "esp8266" ] || [ $config = "esp32" ]; then
	        cp .esphome/build/kickstart-${config}/.pioenvs/kickstart-${config}/*.ota.rbl ../build/ || true
	        cp .esphome/build/kickstart-${config}/.pioenvs/kickstart-${config}/*.ota.ug.bin ../build/ || true
	        cp .esphome/build/kickstart-bk7231t/.pioenvs/kickstart-bk7231t/*.ota.rbl ../build/OpenBK7231T_OTA_upgrade_to_esphome_$1.rbl || true
			cp .esphome/build/kickstart-bk7231n/.pioenvs/kickstart-bk7231n/*.ota.rbl ../build/OpenBK7231N_OTA_upgrade_to_esphome_$1.rbl || true
		fi
    fi
done
