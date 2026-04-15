#!/bin/bash
#Advantech.ASH.ISG.RD Yu
#2024/11/06 3.1.0
###################################################################################################
    target=/mnt
    bootdir=/boot
    
    mkdir -p $target/log
    mkdir -p $target/inf
    mkdir -p $target/bug

    touch $target/inf/config.txt
    touch $target/inf/infor.txt
    touch $target/log/date.txt
    touch $target/inf/set.txt

    TEST_CONFIG=$target/inf/config.txt
    TEST_INFOR=$target/inf/infor.txt
    TEST_DATE=$target/log/date.txt
    TEST_SET=$target/inf/set.txt
    
    [ ! -e $target/count ] && echo "0" > $target/count

    date=$(date +'%D %T')
    count=$(cat $target/count)
###################################################################################################
    #menu_main=("menu_main_install" "menu_main_mode" "menu_main_stop" "menu_main_result" "exit")
    #menu_main_install=("menu_main_install_tool" "menu_main_remove_tool" "back")
    #menu_main_install_tool=("menu_main_install_tool_ubuntu" "menu_main_install_tool_centos" "back")
    #menu_main_remove_tool=("menu_main_remove_tool_ubuntu" "menu_main_remove_tool_centos" "back")
    #menu_main_mode=("menu_main_mode_test_config" "menu_main_mode_test_start" "menu_main_mode_test_reset_config" "menu_main_mode_test_reset_test" "back")
    #menu_main_stop=("menu_main_stop_once" "menu_main_stop" "menu_main_rerun" "menu_main_restart" "back")
    #menu_main_result=("menu_main_result_logsave" "menu_main_result_logclean" "menu_main_result_buglist" "menu_main_result_resetall" "back")
###################################################################################################
    menu_main=("Initialize Tool" "Loading Test" "Test Option" "Result Check" "Exit")
    menu_main_install=("Install" "Remove" "Back to Top")
    menu_main_install_tool=("Ubuntu" "CentOS" "Back")
    menu_main_remove_tool=("Ubuntu" "CentOS" "Back")
    menu_main_mode=("Add test option" "Check information" "Reset test option" "Reset test mode" "Back to Top")
    menu_main_stop=("Kill test now" "Stop test" "Re-run test" "Re-start test" "Back to Top")
    menu_main_result=("Save to history" "Clean history" "Show bug" "Clean result" "Back to Top")
function menu() {
    local options=("$@")
    local selected=0
    local key=""
    while true; do
        clear
        echo "Move with W/↑ (Up) and S/↓ (Down) to select"
        echo "Press Enter to confirm:"
        echo
        for i in $(seq 0 $((${#options[@]} - 1))); do
            if [ $i -eq $selected ]; then
                echo "> ${options[i]}"
            else
                echo "  ${options[i]}"
            fi
        done
        menu_input
        case "$key" in
            w|up) 
                selected=$((selected - 1))
                [ $selected -lt 0 ] && selected=$((${#options[@]} - 1))
                ;;
            s|down) 
                selected=$((selected + 1))
                [ $selected -eq ${#options[@]} ] && selected=0
                ;;
            enter) 
                echo
                return $selected
                ;;
        esac
    done
}
function menu_input() {
    local _key
    read -s -n1 _key
    key="$_key"
    if [[ "$_key" == $'\e' ]]; then
        read -s -n2 -t 0.1 _arrow
        case "$_arrow" in
            '[A') key='up' ;;    # Up arrow
            '[B') key='down' ;;  # Down arrow
            *) key="$_key$_arrow" ;;
        esac
    elif [[ "$_key" == "w" || "$_key" == "W" ]]; then
        key='w'
    elif [[ "$_key" == "s" || "$_key" == "S" ]]; then
        key='s'
    elif [[ -z "$_key" ]]; then
        key='enter'
    fi
}
function menu_choice() {
    while true; do
        menu "${menu_main[@]}"
        choice_main=$?
        case $choice_main in
            0)
                while true; do
                    menu "${menu_main_install[@]}"
                    choice_main_install=$?
                    case $choice_main_install in
                        0)
                            while true; do
                                menu "${menu_main_install_tool[@]}"
                                choice_main_install_tool=$?
                                case $choice_main_install_tool in
                                    0)
                                        menu_main_install_tool_ubuntu
                                        #echo "menu_main_install_tool_ubuntu"
                                        sleep 2
                                        break
                                        ;;
                                    1)
                                        menu_main_install_tool_centos
                                        #echo "menu_main_install_tool_centos"
                                        sleep 2
                                        break
                                        ;;
                                    2)
                                        break
                                        ;;
                                esac
                            done    
                            ;;
                        1)
                            while true; do
                                menu "${menu_main_remove_tool[@]}"
                                choice_main_remove_tool=$?
                                case $choice_main_remove_tool in
                                0)
                                    menu_main_remove_tool_ubuntu
                                    #echo "menu_main_remove_tool_ubuntu"
                                    sleep 2
                                    break
                                    ;;
                                1)
                                    menu_main_remove_tool_centos
                                    #echo "menu_main_remove_tool_centos"
                                    sleep 2
                                    break
                                    ;;
                                2)
                                    break
                                    ;;
                                esac
                            done
                            ;;
                        2)
                            break
                            ;;
                    esac
                done
                ;;
            1)
                while true; do
                    menu "${menu_main_mode[@]}"
                    choice_menu_main_mode=$?
    
                    case $choice_menu_main_mode in
                        0)
                            menu_main_mode_test_config
                            #echo "menu_main_mode_test_config"
                            sleep 2
                            break
                            ;;
                        1)
                            menu_main_mode_test_start
                            #echo "menu_main_mode_test_start"
                            sleep 2
                            break
                            ;;
                        2)
                            menu_main_mode_test_reset_config
                            #echo "menu_main_mode_test_reset_config"
                            sleep 2
                            break
                            ;;
                        3)
                            menu_main_mode_test_reset_test
                            #echo "menu_main_mode_test_reset_test"
                            sleep 2
                            break
                            ;;
                        4)
                            break
                            ;;
                    esac
                done
                ;;
            2)
                while true; do
                    menu "${menu_main_stop[@]}"
                    choice_menu_main_stop=$?
    
                    case $choice_menu_main_stop in
                        0)
                            menu_main_stop_once
                            #echo "menu_main_stop_once"
                            sleep 2
                            break
                            ;;
                        1)
                            menu_main_stop
                            #echo "menu_main_stop"
                            sleep 2
                            break
                            ;;
                        2)
                            menu_main_rerun
                            #echo "menu_main_rerun"
                            sleep 2
                            break
                            ;;
                        3)
                            menu_main_restart
                            #echo "menu_main_restart"
                            sleep 2
                            break
                            ;;
                        4)
                            break
                            ;;    
                    esac
                done
                ;;
            3)
                while true; do
                    menu "${menu_main_result[@]}"
                    choice_menu_main_result=$?
    
                    case $choice_menu_main_result in
                        0)
                            menu_main_result_logsave
                            #echo "menu_main_result_logsave"
                            sleep 2
                            break
                            ;;
                        1)
                            menu_main_result_logclean
                            #\echo "menu_main_result_logclean"
                            sleep 2
                            break
                            ;;
                        2)
                            menu_main_result_buglist
                            #echo "menu_main_result_buglist"
                            sleep 2
                            break
                            ;;        
                        3)
                            menu_main_result_resetall
                            #echo "menu_main_result_resetall"
                            sleep 2
                            break
                            ;;
                        4)
                            break
                            ;;
                            
                    esac
                done
                ;;
            4)
                printf "\n-Version 3.1.0-\n-2024/11/06-\n-Advantech-\n\no(*≧▽≦)ツ No Game,No Life.\n\n"
                #echo "Exit"
                exit 0
                ;;
        esac
    done
}
###################################################################################################
function menu_main_install_tool_ubuntu(){
    rc_local_service
    rc_local_ubuntu
    autoReboot_ubuntu
    sleep 2
    enable_rc_local
    sleep 2
    start_rc_local_service
    echo "Tool Install Done!"
}
function rc_local_service(){
    sudo cp rc-local.service /etc/systemd/system/
}
function rc_local_ubuntu(){
    sudo cp rc.local /etc/
    sudo chmod +x /etc/rc.local
}
function autoReboot_ubuntu(){
    sudo cp -r autoReboot.sh $bootdir/
    sudo chmod +x $bootdir/autoReboot.sh
}
function enable_rc_local(){
    sudo systemctl enable rc-local
}
function status_rc_local_service(){
    sudo systemctl status rc-local.service
}
function start_rc_local_service(){
    sudo systemctl start rc-local.service
}
function menu_main_remove_tool_ubuntu(){
    menu_main_remove_tool_ubuntu_remove
    echo "Tool Remove Done!"
    exit 0
}
function menu_main_remove_tool_ubuntu_remove(){
    sudo rm -r /etc/systemd/system/rc-local.service  /etc/rc.local  $bootdir/autoReboot.sh
    sudo rm -r $target/log  $target/inf  $target/count  $target/bug
}
###################################################################################################
function menu_main_install_tool_centos(){
    rc_local_centos
    sleep 2
    autoReboot_centos
    echo "Tool Install Done!"
}
function rc_local_centos(){
    sudo cp rc.local /etc/rc.d 
    sudo chmod +x /etc/rc.d/rc.local
}
function autoReboot_centos(){
    sudo cp -r autoReboot.sh $bootdir/
    sudo chmod +x $bootdir/autoReboot.sh
}
function menu_main_remove_tool_centos(){
    menu_main_remove_tool_centos_remove
    echo "Tool Remove Done!"
    exit 0
}
function menu_main_remove_tool_centos_remove(){
    sudo rm -r $bootdir/autoReboot.sh
    sudo echo "#!bin/bash" > /etc/rc.d/rc.local
    sudo chmod -x /etc/rc.d/rc.local
    sudo rm -r $target/log  $target/inf  $target/count  $target/bug
}
###################################################################################################
function menu_main_mode_test_config_setup_terminal() {
    stty -echo
    if command -v tput > /dev/null 2>&1; then
        tput civis
    fi
}
function menu_main_mode_test_config_reset_terminal() {
    stty echo
    if command -v tput > /dev/null 2>&1; then
        tput cnorm
    fi
}
function menu_main_mode_test_config_error_handler() {
    echo "Error: $1" >&2
    menu_main_mode_test_config_reset_terminal
    exit 1
}
function menu_main_mode_test_config_cleanup() {
    menu_main_mode_test_config_reset_terminal
}
trap 'menu_main_mode_test_config_error_handler $LINENO' ERR
trap menu_main_mode_test_config_cleanup EXIT
function menu_main_mode_test_config_option(){
    config_options=("a. COM_Number_Check" "b. PCI_Number_Check" "c. USB_Number_Check" "d. STORAGE_Number_Check" "e. MEMORY_Capacity_Check" "f. NETPORT_Number_Check" "g. ISMOD_Number_Check" "h. COM_IRQ_Check" "i. PCI_BANDWIDTH_Check" "j. USB_BANDWIDTH_Check" "k. SATA_BANDWIDTH_Check" "l. MEMORY_FREQUENCY_Check" "m. PCI_AER_Check" "n. Disk_model_Check")
    config_selected=()
    for config_i in "${!config_options[@]}"; do
        config_selected[$config_i]=0
    done
}
function menu_main_mode_test_config_menu() {
    clear
    echo "Move with W/↑ (Up) and S/↓ (Down), X Select/Deselect, Enter Confirms:"
    echo
    for config_i in "${!config_options[@]}"; do
        if [ $config_i -eq $config_cursor ]; then
            echo -n "> "
        else
            echo -n "  "
        fi
        if [ ${config_selected[$config_i]} -eq 1 ]; then
            echo "[X] ${config_options[$config_i]}"
        else
            echo "[ ] ${config_options[$config_i]}"
        fi
    done
    echo
    echo "Current Selection: ${config_current_selection[*]}"
}

function menu_main_mode_test_config_update() {
    config_current_selection=()
    for config_i in "${!config_selected[@]}"; do
        if [ ${config_selected[$config_i]} -eq 1 ]; then
            config_current_selection+=("${config_options[$config_i]}")
        fi
    done
}

function menu_main_mode_test_config_input() {
    if read -r -s -n 1 config_key; then
        if [[ $config_key == $'\e' ]]; then
            if read -r -s -n 2 -t 0.1 config_arrow; then
                case $config_arrow in
                    '[A') config_key='w' ;;  # Up arrow
                    '[B') config_key='s' ;;  # Down arrow
                esac
            fi
        elif [[ $config_key == '' ]]; then
            config_key='enter'
        fi
    fi
}
function menu_main_mode_test_config(){
    menu_main_mode_test_config_setup_terminal
    menu_main_mode_test_config_option
    config_cursor=0
    while true; do
        menu_main_mode_test_config_menu
        menu_main_mode_test_config_input
        case "$config_key" in
            w)
                ((config_cursor--))
                [ $config_cursor -lt 0 ] && config_cursor=$((${#config_options[@]}-1))
                ;;
            s)
                ((config_cursor++))
                [ $config_cursor -eq ${#config_options[@]} ] && config_cursor=0
                ;;
            x)
                if [ ${config_selected[$config_cursor]} -eq 0 ]; then
                    config_selected[$config_cursor]=1
                else
                    config_selected[$config_cursor]=0
                fi
                menu_main_mode_test_config_update
                ;;
            "enter")
                break
                ;;
        esac
    done
    menu_main_mode_test_config_reset_terminal
    clear
    echo "Your final choice is:"
    for config_item in "${config_current_selection[@]}"; do
        echo "- $config_item"
        echo "adv_confg:$config_item" >> $TEST_CONFIG
    done
}
###################################################################################################
function menu_main_mode_test_aer_init_terminal() {
    stty -echo
    if command -v tput > /dev/null 2>&1; then
        tput civis
    fi
}
function menu_main_mode_test_aer_restore_terminal() {
    stty echo
    if command -v tput > /dev/null 2>&1; then
        tput cnorm
    fi
}
function menu_main_mode_test_aer_error_management() {
    echo "Error: $1" >&2
    menu_main_mode_test_aer_restore_terminal
    exit 1
}
function menu_main_mode_test_aer_cleanup() {
    menu_main_mode_test_aer_restore_terminal
}
trap 'menu_main_mode_test_aer_error_management $LINENO' ERR
trap menu_main_mode_test_aer_cleanup EXIT
function menu_main_mode_test_aer_populate_items(){
    IFS=$'\n' read -d '' -r -a device_collection < <(lspci)
    device_selection_status=()
    for device_index in "${!device_collection[@]}"; do
        device_selection_status[$device_index]=0
    done
}
function menu_main_mode_test_aer_interface() {
    clear
    echo "Move with W/↑ (Up) and S/↓ (Down), X Select/Deselect, Enter Confirms:"
    echo
    for device_index in "${!device_collection[@]}"; do
        if [ $device_index -eq $device_cursor_position ]; then
            echo -n "> "
        else
            echo -n "  "
        fi
        if [ ${device_selection_status[$device_index]} -eq 1 ]; then
            echo "[X] ${device_collection[$device_index]}"
        else
            echo "[ ] ${device_collection[$device_index]}"
        fi
    done
    echo
    echo "Current Selection: ${current_user_selections[*]}"
}
function menu_main_mode_test_aer_update_selected() {
    current_user_selections=()
    for device_index in "${!device_selection_status[@]}"; do
        if [ ${device_selection_status[$device_index]} -eq 1 ]; then
            current_user_selections+=("${device_collection[$device_index]}")
        fi
    done
}
function menu_main_mode_test_aer_handle_input() {
    if read -r -s -n 1 user_input_key; then
        if [[ $user_input_key == $'\e' ]]; then
            if read -r -s -n 2 -t 0.1 arrow_key_input; then
                case $arrow_key_input in
                    '[A') user_input_key='w' ;;  # Up arrow
                    '[B') user_input_key='s' ;;  # Down arrow
                esac
            fi
        elif [[ $user_input_key == '' ]]; then
            user_input_key='enter'
        fi
    fi
}
function menu_main_mode_test_aer_config(){
    menu_main_mode_test_aer_init_terminal
    menu_main_mode_test_aer_populate_items
    device_cursor_position=0
    while true; do
        menu_main_mode_test_aer_interface
        menu_main_mode_test_aer_handle_input
        case "$user_input_key" in
            w)
                ((device_cursor_position--))
                [ $device_cursor_position -lt 0 ] && device_cursor_position=$((${#device_collection[@]}-1))
                ;;
            s)
                ((device_cursor_position++))
                [ $device_cursor_position -eq ${#device_collection[@]} ] && device_cursor_position=0
                ;;
            x)
                if [ ${device_selection_status[$device_cursor_position]} -eq 0 ]; then
                    device_selection_status[$device_cursor_position]=1
                else
                    device_selection_status[$device_cursor_position]=0
                fi
                menu_main_mode_test_aer_update_selected
                ;;
            "enter")
                break
                ;;
        esac
    done
    menu_main_mode_test_aer_restore_terminal
    clear
    echo "Your final choice is:"
    for selected_item in "${current_user_selections[@]}"; do
        echo "- $selected_item"
        echo "$selected_item" >> $AER_CONFIG
    done
}
###################################################################################################
function menu_main_mode_test_config_com(){
    printf "\nPlease enter the name of COM Port: "
    read com_name
    echo "com_infor: $com_name" >> $TEST_INFOR
    sleep 1					
    #com_catif=$(cat $TEST_INFOR | grep com_infor: | cut -c 10-20)
    com_infor=$(dmesg | grep $com_name | grep irq)
    com_count=$(dmesg | grep $com_name | grep irq | wc -l)
    echo "com_count: $com_count" >> $TEST_INFOR
    printf "\nThe information captured by the script \n "
    printf "\n$com_infor \n "
    printf "\nThe number of scripts captured $com_count \n "
    #printf "\nPlease check the COM device and enter (y/n) : "
}
function menu_main_mode_test_config_irq(){
    printf "\nPlease enter the name of COM Port: "
    read com_name
    echo "com_irqnm: $com_name" >> $TEST_INFOR
    sleep 1
    #com_catif=$(cat $TEST_INFOR | grep com_infor: | cut -c 10-20) 
    com_infor=$(dmesg | grep $com_name | grep irq)					
    com_irqif=$(dmesg | grep $com_name | grep irq | awk '{print $3$4$5$6$7$8$9$10$11$12$13}')
    echo "$com_irqif" >> $target/inf/com_irq_information.log 
    printf "\nThe information captured by the script \n "
    printf "\n$com_infor \n "
    #printf "\nPlease check the COM device and enter (y/n) : "
}
function menu_main_mode_test_config_pci(){
    
    
    pci_infor=$(lspci)
    pci_count=$(lspci | wc -l)
    echo "pci_count: $pci_count" >> $TEST_INFOR
    echo "$pci_infor" >> $target/inf/pci_infor_information.log
    printf "\nThe information captured by the script \n "
    printf "\n$pci_infor \n "
    printf "\nThe number of scripts captured $pci_count \n "
    #printf "\nPlease check the PCI device and enter (y/n) : "
}
function menu_main_mode_test_config_pci_width(){
    pci_busif=$(lspci | awk '{print $1}')
    printf "\nThe information captured by the script \n"
    for pci_width in ${pci_busif}
    do
        pci_lnkcap=$(lspci -s $pci_width -vvv | grep -i LnkCap)
        pci_lnksta=$(lspci -s $pci_width -vvv | grep -i LnkSta)
        printf "\nPCI Bus: %s" "$pci_width"
        printf "\n%s" "$pci_lnkcap"
        printf "\n%s\n" "$pci_lnksta"
        echo "PCI Bus:$pci_width" >> $target/inf/pci_width_information.log
        echo "$pci_lnkcap" >> $target/inf/pci_width_information.log
        echo "$pci_lnksta" >> $target/inf/pci_width_information.log
        echo "------------------------" >> $target/inf/pci_width_information.log
    done
    #printf "\nPlease check the PCI device and enter (y/n) : "
}
function menu_main_mode_test_config_usb(){
    usb_infor=$(lsusb)
    usb_count=$(lsusb | wc -l)
    echo "usb_count: $usb_count" >> $TEST_INFOR
    printf "\nThe information captured by the script \n "
    printf "\n$usb_infor \n "
    printf "\nThe number of scripts captured $usb_count \n "
    #printf "\nPlease check the USB device and enter (y/n) : " 
}
function menu_main_mode_test_config_usb_speed(){
    usb_infor=$(lsusb)
    usb_speed=$(lsusb -t | awk -F'[, ]+' '{for(i=1;i<=NF;i++){if($i~/Class=/)print $i, $(i+1), $(i+2), $(i+3), $(i+4), $(i+5), $(i+6), $(i+7), $(i+8), $(i+9)}}' | sort)
    echo "$usb_speed" >> $target/inf/usb_speed_information.log
    printf "\nThe information captured by the script \n "
    printf "\n$usb_speed \n "
    #printf "\nPlease check the USB device and enter (y/n) : " 
}
function menu_main_mode_test_config_mem(){
    mem_total=$(cat /proc/meminfo | grep Mem)
    mem_count=$(cat /proc/meminfo | grep MemTotal | cut -c 17-21)
    echo "mem_count: $mem_count" >> $TEST_INFOR
    printf "\nThe information captured by the script \n "
    printf "\n$mem_total \n "
    #printf "\nPlease check the MEM INFO and enter (y/n) : "
}
function menu_main_mode_test_config_mem_frequency(){
    mem_infor=$(dmidecode -t memory)
    mem_frequ=$(dmidecode -t memory | grep Configured\ Memory)
    echo "$mem_infor" >> $target/inf/mem_frequency_information.log
    echo "$mem_frequ" >> $target/inf/mem_frequency_diff_information.log
    printf "\nThe information captured by the script \n "
    printf "\n$mem_infor \n "
    #printf "\nPlease check the MEM INFO and enter (y/n) : "
}
function menu_main_mode_test_config_net(){
    net_infor=$(ifconfig)
    net_count=$(ifconfig | grep flags | wc -l)
    echo "net_count: $net_count" >> $TEST_INFOR
    echo "$net_infor" >> $target/inf/net_infor_information.log
    printf "\nThe information captured by the script \n "
    printf "\n$net_infor \n "
    printf "\nThe number of scripts captured $net_count \n "
    #printf "\nPlease check the NET port and enter (y/n) : " 
}
function menu_main_mode_test_config_mod(){
    mod_infor=$(lsmod | sort)
    mod_count=$(lsmod | sort | wc -l)
    echo "mod_count: $mod_count" >> $TEST_INFOR
    echo "$mod_infor" >> $target/inf/mod_infor_information.log
    printf "\nThe information captured by the script \n "
    printf "\n$mod_infor \n "
    printf "\nThe number of scripts captured $mod_count \n "
    #printf "\nPlease check the MOD installed and enter (y/n) : " 
}
function menu_main_mode_test_config_sto(){
    sdx_infor=$(lsblk | grep sd)
    sdx_busif=$(lsblk -o NAME | grep sd)
    sdx_count=$(lsblk | grep sd | wc -l)
    echo "sdx_count: $sdx_count" >> $TEST_INFOR
    echo "$sdx_busif" >> $target/inf/sdx_busif_information.log
    printf "\nThe information captured by the script \n "
    printf "\n$sdx_infor \n "
    #printf "\nPlease check the STORAGE and enter (y/n) : " 
}
function menu_main_mode_test_config_ata(){
    ata_infor=$(dmesg | grep SATA\ link | sort)
    ata_speed=$(dmesg | grep SATA\ link\ up | awk '{print $4 $5 $6 $7 $8}' | sort)
    ata_count=$(dmesg | grep SATA\ link\ up | wc -l)
    echo "ata_count: $ata_count" >> $TEST_INFOR
    echo "$ata_speed" >> $target/inf/ata_speed_information.log
    printf "\nThe information captured by the script \n "
    printf "\n$ata_infor \n "
    printf "\nThe number of scripts captured $ata_count \n "
    #printf "\nPlease check the SATA LINK SPEED and enter (y/n) : "
}
function menu_main_mode_test_config_pci_aer(){
    touch $target/inf/aercfg.log
    touch $target/inf/aerif.log
    AER_CONFIG=$target/inf/aercfg.log
    AER_AERIF=$target/inf/aerif.log
    menu_main_mode_test_aer_config
    while read line; do
        pci_bus_bdf=$(echo "$line" | awk '{print $1}')
    	pci_bus_inf=$(echo "$line")
    	pci_bus_ed=$(lspci -s "$pci_bus_bdf" -vvv | grep Endpoint)
   	pci_bus_dc=$(lspci -s "$pci_bus_bdf" -vvv | grep DevCtl:)
   	pci_bus_ar=$(lspci -s "$pci_bus_bdf" -vvv | grep Advanced)
   	pci_bus_us=$(lspci -s "$pci_bus_bdf" -vvv | grep UESta:)
   	pci_bus_cs=$(lspci -s "$pci_bus_bdf" -vvv | grep CESta:)
   	echo "$pci_bus_inf" >>  $AER_AERIF
   	echo "$pci_bus_ed"  >>  $AER_AERIF
   	echo "$pci_bus_dc"  >>  $AER_AERIF
   	echo "$pci_bus_ar"  >>  $AER_AERIF
   	echo "$pci_bus_us"  >>  $AER_AERIF
   	echo "$pci_bus_cs"  >>  $AER_AERIF
   	printf "\n----------------\n$pci_bus_inf \n$pci_bus_ed \n$pci_bus_dc \n$pci_bus_ar \n$pci_bus_us \n$pci_bus_cs \n"
    done < $AER_CONFIG
    #printf "\nPlease check the SATA LINK SPEED and enter (y/n) : "
}
function menu_main_mode_test_config_fdk(){
    dsk_model=$(fdisk -l | grep Disk\ model: | sort)
    echo "$dsk_model" >> $target/inf/dsk_model_information.log
    printf "\nThe information captured by the script \n "
    printf "\n$dsk_model \n "
    #printf "\nPlease check the SATA LINK SPEED and enter (y/n) : "
}    
###################################################################################################
function menu_main_mode_test_start(){
    menu_main_mode_test_start_main
    menu_main_mode_test_start_init
    menu_main_mode_test_start_autostop
    menu_main_mode_test_start_sleep_time
}
function menu_main_mode_test_start_check(){
    printf "\nPlease check the information and enter (y/n) : "
    read check
    if [ $check == y ] ; then
        echo "Done!"
    else
    	rm -r $target/inf/*
        exit 0
    fi 
}
function menu_main_mode_test_start_execute() {
    local letter=$1
    local function_name="${program_names[$letter]}"
    local new_x=()
    local found=false
    for elem in "${x[@]}"; do
        if [[ "$elem" == "$letter" ]]; then
            sleep 1
            echo "Loading: $function_name"
            sleep 1
            $function_name
            menu_main_mode_test_start_check
            found=true
        else
            new_x+=("$elem")
        fi
    done
    if [[ "$found" == true ]]; then
        x=("${new_x[@]}")
    fi
}
function menu_main_mode_test_start_main(){
    declare -A program_names
    declare -A processed
    x=()
    program_names[a]="menu_main_mode_test_config_com"
    program_names[b]="menu_main_mode_test_config_pci"
    program_names[c]="menu_main_mode_test_config_usb"
    program_names[d]="menu_main_mode_test_config_sto"
    program_names[e]="menu_main_mode_test_config_mem"
    program_names[f]="menu_main_mode_test_config_net"
    program_names[g]="menu_main_mode_test_config_mod"
    program_names[h]="menu_main_mode_test_config_irq"
    program_names[i]="menu_main_mode_test_config_pci_width"
    program_names[j]="menu_main_mode_test_config_usb_speed"
    program_names[k]="menu_main_mode_test_config_ata"
    program_names[l]="menu_main_mode_test_config_mem_frequency"
    program_names[m]="menu_main_mode_test_config_pci_aer"
    program_names[n]="menu_main_mode_test_config_fdk"
    while IFS= read -r line; do
        if [[ $line =~ ^adv_confg:[a-z]\..* ]]; then
            letter=$(echo "$line" | cut -d'.' -f1 | cut -d':' -f2)
            if [[ -z "${processed[$letter]}" ]]; then
                x+=("$letter")
                processed[$letter]=1
            fi
        fi
    done < $TEST_CONFIG
    while [ ${#x[@]} -gt 0 ]; do
        #echo "Current testing programs: ${x[*]}"
        for letter in {a..n}; do
            menu_main_mode_test_start_execute "$letter"
        done
    done
    echo "All tests set completed!"
}
function menu_main_mode_test_start_init(){
    printf "\nPlease select power mode to run in 120 seconds:\n 1. reboot mode\n 2. shutdown mode\n"
    read -t 120 -p "Enter your choice (1-2): " menu_main_mode_test_start_init_choice
    case $menu_main_mode_test_start_init_choice in
        1)
            echo "You chose reboot  mode" 
            echo "mod_config: 1" >> $TEST_SET
            menu_main_mode_test_start_number_of_laps
            ;;
        2)
            echo "You chose shutdown  mode" 
            echo "mod_config: 2" >> $TEST_SET
            menu_main_mode_test_start_number_of_laps
            #echo "cyc_config: 99999" >> $TEST_SET
            ;;    
        *)
            echo "Invalid choice or timeout reached."
            exit 1
            ;;
    esac   
}
function menu_main_mode_test_start_number_of_laps(){
    printf "\nPlease select the number of tests required:"
    read menu_main_mode_test_start_number_of_laps_tests
    echo "cyc_config: $menu_main_mode_test_start_number_of_laps_tests" >> $TEST_SET
}
function menu_main_mode_test_start_autostop(){
    printf "\nPlease enter whether automatic stop is required:\n 1. normal mode\n 2. autostop mode\n "
    read -p "Enter your choice (1-2): " menu_main_mode_test_start_autostop
    case $menu_main_mode_test_start_autostop in
        1)
            echo "ato_config: 1" >> $TEST_SET
            ;;
        2)
            echo "ato_config: 2" >> $TEST_SET
            ;;    
        *)
            echo "Invalid choice or timeout reached."
            exit 1
            ;;
    esac   
}
function menu_main_mode_test_start_sleep_time(){
    printf "\nPlease input the delay time: \n\n< SSD suggest no less than 20 sec >\n< HDD suggest no less than 60 sec >\n\nPlease enter the tiem of delay:"
    read menu_main_mode_test_start_sleep_time
    echo "slp_config: $menu_main_mode_test_start_sleep_time" >> $TEST_SET
    echo "sta_config: 1" >> $TEST_SET
}
###################################################################################################
function menu_main_mode_test_reset_config(){
    rm -r $TEST_CONFIG
    rm -r $TEST_INFOR
    rm -r $target/inf/*.log
    menu_main_mode_test_config
    menu_main_mode_test_start_main
}
function menu_main_mode_test_reset_test(){
    rm -r $TEST_SET
    menu_main_mode_test_start_init
    menu_main_mode_test_start_autostop
    menu_main_mode_test_start_sleep_time
}
###################################################################################################
function menu_main_stop_once(){
    sudo echo "$date ******You stop the test******" >> $TEST_DATE
    stoponce=$(sudo pgrep autoReboot)
    kill $stoponce
    sleep 1
}
function menu_main_stop(){
    mv $bootdir/autoReboot.sh $bootdir/autoRebootstop.sh 
    menu_main_stop_once
    echo "Done!"
}
function menu_main_rerun(){
    mv $bootdir/autoRebootstop.sh $bootdir/autoReboot.sh 
    echo "Done!"
}
function menu_main_restart(){
    rm -r $target/log/*
    echo "0" > $target/count
    echo "Done!"
}
###################################################################################################
function menu_main_result_logsave(){
    mkdir -p $target/history
    historyname=$(date +%Y-%m-%d_%H-%M-%S)
    mkdir $target/history/$historyname
    mkdir $target/history/$historyname/log
    mkdir $target/history/$historyname/bug
    mkdir $target/history/$historyname/inf
    mv $target/log/* $target/history/$historyname/log
    mv $target/bug/* $target/history/$historyname/bug
    mv $target/inf/* $target/history/$historyname/inf
    mv $target/count $target/history/$historyname
    echo "Save Done!"
    touch $target/inf/config.txt
    touch $target/inf/infor.txt
    touch $target/log/date.txt
    touch $target/inf/set.txt
}
function menu_main_result_logclean(){
    rm -r $target/history
    echo "Clean Done!"
}
function menu_main_result_buglist(){
    bugsign=0
    for log_file in $target/bug/*.log; do
    	[ -e "$log_file" ] || continue
    	if [ -s "$log_file" ]; then
            echo "Error: $log_file"
            bugsign=1
    	fi
    done
    if [ $bugsign -eq 1 ]; then
    	exit 0
    else
    	echo "All tests check pass"
    fi
}
function menu_main_result_resetall(){
    rm -r $target/inf
    rm -r $target/log
    rm -r $target/bug
    rm -r $target/count
    echo "Done!"
    exit 0
}
###################################################################################################
     menu_choice
exit 0
