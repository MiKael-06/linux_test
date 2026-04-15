#!/bin/bash
#Advantech.ASH.ISG.RD Yu
#2024/11/06 3.1.0
###################################################################################################
    target=/mnt
    TEST_CONFIG=$target/inf/config.txt
    TEST_INFOR=$target/inf/infor.txt
    TEST_DATE=$target/log/date.txt
    TEST_SET=$target/inf/set.txt
###################################################################################################
    log_date=$(date)
###################################################################################################   
function start_main(){
    start_sign=$(cat $TEST_SET | grep sta_config: | cut -c 13-23)
    start_mode=$(cat $TEST_SET | grep mod_config: | cut -c 13-23)
    if  [ "$((start_sign))" -eq "1" ]; then
    	if [ "$((start_mode))" -eq "1" ]; then
    	    echo ">>>reboot_mode<<<"
            start_main_loading
        else
            if  [ "$((start_mode))" -eq "2" ]; then
            	echo ">>>shutdown_mode<<<"
                start_main_loading
            else
                echo ">>>start_mode_error<<<"
                exit 1
            fi
        fi
    else
        exit 1
    fi
}
function start_main_loading(){
    start_time=$(cat $TEST_SET | grep cyc_config: | cut -c 13-23)
    sleep_time=$(cat $TEST_SET | grep slp_config: | cut -c 13-23)
    declare -i count=$(cat $target/count)
    if  [ $count -lt $start_time ]; then
        sleep 5
        start_main_time
        start_main_test_main
        echo "$[ $count+1 ]" > $target/count
        #start_main_buglist
        echo ">>>Tested $[ $count+1 ] times already<<<"
        echo ">>>$time_date<<<"
        echo ">>>Sleeping $sleep_time s<<<"
        sleep $sleep_time
	start_main_buglist
	sleep 1
        if [ "$((start_mode))" -eq "1" ]; then
            sudo init 6
            /sbin/reboot
            echo ">>>reboot<<<"
        else
            sudo init 0
            /sbin/shutdown -h now
            echo ">>>shutdown<<<"
        fi
    else
        rm -r $target/inf/*
	printf "\n>>>Finished.<<< \n"
    fi
}
###################################################################################################
function start_main_autostop(){
    start_stop=$(cat $TEST_SET | grep ato_config: | cut -c 13-23)
    if  [ "$((start_stop))" -eq "2" ]; then
	sleep 5
        echo ">>>Test fail. Already stop.<<<"
	stop_program=$(sudo pgrep autoReboot)
       	kill $stop_program
       	echo "Are You OK? :)"
    fi
}
function start_main_buglist(){
    buglist=0
    for log_file in $target/bug/*.log; do
    	[ -e "$log_file" ] || continue
    	if [ -s "$log_file" ]; then
            echo ">>>Error: $log_file<<<"
            buglist=1
    	fi
    done
    if [ $buglist -eq 1 ]; then
    	echo ">>>The test has encountered an error<<< "
    	start_main_autostop
    else
    	echo ">>>All tests check pass<<< "
    fi
}
###################################################################################################
function start_main_time(){
    time_sec=$(date +%s)
    time_date=$(date +'%D %T')
    [ ! -e $target/inf/datetemp.log ] && echo "$time_sec" > $target/inf/datetemp.log
    TIME_TEMP=$target/inf/datetemp.log
    time_info=$(cat $TIME_TEMP | cut -c 1-10)
    time_diff=$(($time_sec - $time_info))
    echo "$time_date $time_sec ($time_diff s)" >> $TEST_DATE
    echo "$time_date $time_sec ($time_diff s)"
    sleep 1
    echo "$time_sec" > $TIME_TEMP
    echo ">>>Date check done.<<<"
}
###################################################################################################
function menu_main_mode_test_config_com(){
    touch $target/log/com_count.log
    touch $target/bug/com_count_bug.log
    COM_COUNT=$target/log/com_count.log
    COM_COUNT_BUG=$target/bug/com_count_bug.log
    com_name=$(cat $TEST_INFOR | grep com_infor: | cut -c 12-22)
    com_real=$(cat $TEST_INFOR | grep com_count: | cut -c 12-22)
    com_scan=$(dmesg | grep $com_name | grep irq)
    com_temp=$(dmesg | grep $com_name | grep irq | wc -l)
    echo "$[ $count+1 ]" 		>> $COM_COUNT
    echo "$log_date" 			>> $COM_COUNT
    echo "$com_scan" 			>> $COM_COUNT
    echo "" 				>> $COM_COUNT
    if  [ "$com_temp" -lt "$((com_real))" ]; then
        echo "$[ $count+1 ]" 		>> $COM_COUNT_BUG
        echo "$log_date" 		>> $COM_COUNT_BUG
        echo "Expected  :$com_real." 	>> $COM_COUNT_BUG
        echo "But Found :$com_temp." 	>> $COM_COUNT_BUG
	echo "$com_scan" 		>> $COM_COUNT_BUG
        echo "" 			>> $COM_COUNT_BUG
        echo "$com_scan" 
        echo ">>>com check fail.<<<"
    else
        echo "$com_scan"    
        echo ">>>com check pass.<<<"
    fi
}
function menu_main_mode_test_config_irq(){
    touch $target/inf/com_irq_temp.log
    touch $target/inf/com_irq_diff.log
    touch $target/log/com_irq_infor.log
    touch $target/bug/com_irq_bug_infor.log
    IRQ_REAL=$target/inf/com_irq_information.log
    IRQ_TEMP=$target/inf/com_irq_temp.log
    IRQ_DIFF=$target/inf/com_irq_diff.log
    IRQ_INFOR=$target/log/com_irq_infor.log
    IRQ_INFOR_BUG=$target/bug/com_irq_bug_infor.log
    irq_name=$(cat $TEST_INFOR | grep com_irqnm: | cut -c 12-22)
    irq_scan=$(dmesg | grep $irq_name | grep irq)
    irq_temp=$(dmesg | grep $irq_name | grep irq | awk '{print $3$4$5$6$7$8$9$10$11$12$13}')
    echo "$irq_temp" 			>  $IRQ_TEMP 
    echo "$[ $count+1 ]" 		>> $IRQ_INFOR
    echo "$log_date" 			>> $IRQ_INFOR
    echo "$irq_scan" 			>> $IRQ_INFOR
    echo "" 				>> $IRQ_INFOR
    irq_diff=$(diff $IRQ_TEMP $IRQ_REAL | grep -v "^$")
    echo "$irq_diff" 			>  $IRQ_DIFF
    if  [ -s $IRQ_DIFF ]&&[ $(wc -c < $IRQ_DIFF) -gt 10 ]; then
    	echo "$[ $count+1 ]" 		>> $IRQ_INFOR_BUG
        echo "$log_date" 		>> $IRQ_INFOR_BUG
	echo "$irq_temp" 		>> $IRQ_INFOR_BUG
        echo "" 			>> $IRQ_INFOR_BUG
        echo "$irq_scan" 
        echo ">>>com irq check fail.<<<"
    else
        echo "$irq_scan" 
        echo ">>>com irq check pass.<<<"
    fi
}
function menu_main_mode_test_config_pci(){
    touch $target/log/pci_infor.log
    touch $target/bug/pci_bug_infor.log
    PCI_INFOR=$target/log/pci_infor.log
    PCI_INFOR_BUG=$target/bug/pci_bug_infor.log
    pci_real=$(cat $TEST_INFOR | grep pci_count: | cut -c 12-22)
    pci_scan=$(lspci)
    pci_temp=$(lspci | wc -l)
    echo "$[ $count+1 ]" 		>> $PCI_INFOR
    echo "$log_date" 			>> $PCI_INFOR
    echo "$pci_scan" 			>> $PCI_INFOR
    echo "" 				>> $PCI_INFOR
    if  [ "$pci_temp" -ne "$((pci_real))" ]; then
        echo "$[ $count+1 ]" 		>> $PCI_INFOR_BUG
        echo "$log_date" 		>> $PCI_INFOR_BUG
        echo "Expected  :$pci_real." 	>> $PCI_INFOR_BUG
        echo "But Found :$pci_temp." 	>> $PCI_INFOR_BUG
	echo "$pci_scan" 		>> $PCI_INFOR_BUG
        echo "" 			>> $PCI_INFOR_BUG
        echo "$pci_scan" 
        echo ">>>pci check fail.<<<"
    else
        echo "$pci_scan"
    	echo ">>>pci check pass.<<<"
    fi
}
function menu_main_mode_test_config_pci_width(){
    touch $target/inf/pci_width_temp.log
    touch $target/inf/pci_width_diff.log
    touch $target/log/pci_width.log
    touch $target/bug/pci_width_bug.log
    PCI_WIDTH_REAL=$target/inf/pci_width_information.log
    PCI_WIDTH_TEMP=$target/inf/pci_width_temp.log
    PCI_WIDTH_DIFF=$target/inf/pci_width_diff.log
    PCI_WIDTH=$target/log/pci_width.log
    PCI_WIDTH_BUG=$target/bug/pci_width_bug.log
    pci_busif=$(lspci | awk '{print $1}')
    for pci_width in ${pci_busif}
    do
        pci_lnkcap=$(lspci -s $pci_width -vvv | grep -i LnkCap)
        pci_lnksta=$(lspci -s $pci_width -vvv | grep -i LnkSta)
        echo "PCI Bus:$pci_width" 	>> $PCI_WIDTH_TEMP
        echo "$pci_lnkcap" 		>> $PCI_WIDTH_TEMP
        echo "$pci_lnksta" 		>> $PCI_WIDTH_TEMP
        echo "------------------------" >> $PCI_WIDTH_TEMP
    done
    pci_scan=$(cat $PCI_WIDTH_TEMP)
    echo "$[ $count+1 ]" 		>> $PCI_WIDTH
    echo "$log_date" 			>> $PCI_WIDTH
    echo "$pci_scan" 			>> $PCI_WIDTH
    echo "" 				>> $PCI_WIDTH
    pci_diff=$(diff $PCI_WIDTH_TEMP $PCI_WIDTH_REAL | grep -v "^$")
    echo "$pci_diff" 			>  $PCI_WIDTH_DIFF
    if  [ -s $PCI_WIDTH_DIFF ]&&[ $(wc -c < $PCI_WIDTH_DIFF) -gt 10 ]; then
     	echo "$[ $count+1 ]" 		>> $PCI_WIDTH_BUG
        echo "$log_date" 		>> $PCI_WIDTH_BUG
        echo "$pci_scan" 		>> $PCI_WIDTH_BUG
        echo "" 			>> $PCI_WIDTH_BUG
        echo "$pci_scan"
        echo ">>>pci width check fail.<<<"
    else
    	echo "$pci_scan"
    	echo ">>>pci width check pass.<<<"
    fi
    sleep 1
    rm -r $PCI_WIDTH_TEMP
}
function menu_main_mode_test_config_usb(){
    touch $target/log/usb_infor.log
    touch $target/bug/usb_bug_infor.log
    USB_INFOR=$target/log/usb_infor.log
    USB_INFOR_BUG=$target/bug/usb_bug_infor.log
    usb_real=$(cat $TEST_INFOR | grep usb_count: | cut -c 12-22)
    usb_scan=$(lsusb)
    usb_temp=$(lsusb | wc -l)
    echo "$[ $count+1 ]" 		>> $USB_INFOR
    echo "$log_date" 			>> $USB_INFOR
    echo "$usb_scan" 			>> $USB_INFOR
    echo "" 				>> $USB_INFOR
    if  [ "$usb_temp" -ne "$((usb_real))" ]; then
        echo "$[ $count+1 ]" 		>> $USB_INFOR_BUG
        echo "$log_date" 		>> $USB_INFOR_BUG
        echo "Expected  :$usb_real." 	>> $USB_INFOR_BUG
        echo "But Found :$usb_temp." 	>> $USB_INFOR_BUG
	echo "$usb_scan" 		>> $USB_INFOR_BUG
        echo "" 			>> $USB_INFOR_BUG
        echo "$usb_scan"
        echo ">>>usb check fail.<<<"
    else
        echo "$usb_scan"
    	echo ">>>usb check pass.<<<"
    fi
}
function menu_main_mode_test_config_usb_speed(){
    touch $target/inf/usb_speed_temp.log
    touch $target/inf/usb_speed_diff.log
    touch $target/log/usb_speed.log
    touch $target/bug/usb_bug_speed.log
    USB_REAL=$target/inf/usb_speed_information.log
    USB_TEMP=$target/inf/usb_speed_temp.log
    USB_DIFF=$target/inf/usb_speed_diff.log
    USB_SPEED=$target/log/usb_speed.log
    USB_SPEED_BUG=$target/bug/usb_bug_speed.log
    usp_scan=$(lsusb -t | awk -F'[, ]+' '{for(i=1;i<=NF;i++){if($i~/Class=/)print $i, $(i+1), $(i+2), $(i+3), $(i+4), $(i+5), $(i+6), $(i+7), $(i+8), $(i+9)}}' | sort)
    echo "$usp_scan"			>  $USB_TEMP
    echo "$[ $count+1 ]" 		>> $USB_SPEED
    echo "$log_date" 			>> $USB_SPEED
    echo "$usp_scan" 			>> $USB_SPEED
    echo "" 				>> $USB_SPEED
    usp_diff=$(diff $USB_TEMP $USB_REAL | grep -v "^$")
    echo "$usp_diff" 			>  $USB_DIFF
    if  [ -s $USB_DIFF ]&&[ $(wc -c < $USB_DIFF) -gt 10 ]; then
 	echo "$[ $count+1 ]" 		>> $USB_SPEED_BUG
        echo "$log_date" 		>> $USB_SPEED_BUG
        echo "$usp_scan" 		>> $USB_SPEED_BUG
        echo "" 			>> $USB_SPEED_BUG
        echo "$usp_scan" 
        echo ">>>usb speed check fail.<<<"
    else
        echo "$usp_scan" 
        echo ">>>usb speed check pass.<<<"
    fi
}
function menu_main_mode_test_config_mem(){
    touch $target/log/mem_infor.log
    touch $target/bug/mem_bug_infor.log
    MEM_INFOR=$target/log/mem_infor.log
    MEM_INFOR_BUG=$target/bug/mem_bug_infor.log
    mem_real=$(cat $TEST_INFOR | grep mem_count: | cut -c 12-22)
    mem_scan=$(cat /proc/meminfo | grep Mem)
    mem_temp=$(cat /proc/meminfo | grep MemTotal | cut -c 17-21)
    echo "$[ $count+1 ]" 		>> $MEM_INFOR
    echo "$log_date" 			>> $MEM_INFOR
    echo "$mem_scan" 			>> $MEM_INFOR
    echo "" 				>> $MEM_INFOR
    if  [ "$mem_temp" -ne "$((mem_real))" ]; then
        echo "$[ $count+1 ]" 		>> $MEM_INFOR_BUG
        echo "$log_date" 		>> $MEM_INFOR_BUG
	echo "$mem_scan" 		>> $MEM_INFOR_BUG
        echo "" 			>> $MEM_INFOR_BUG
        echo "$mem_scan"
        echo ">>>mem check fail.<<<"
    else
    	echo "$mem_scan"
    	echo ">>>mem check pass.<<<"
    fi
}
function menu_main_mode_test_config_mem_frequency(){
    touch $target/inf/mem_frequency_temp.log 
    touch $target/inf/mem_frequency_diff.log
    touch $target/log/mem_speed.log
    touch $target/bug/mem_bug_speed.log
    MEM_SPEED_REAL=$target/inf/mem_frequency_diff_information.log
    MEM_SPEED_TEMP=$target/inf/mem_frequency_temp.log 
    MEM_SPEED_DIFF=$target/inf/mem_frequency_diff.log
    MEM_SPEED=$target/log/mem_speed.log
    MEM_SPEED_BUG=$target/bug/mem_bug_speed.log
    mfq_scan=$(dmidecode -t memory)
    mfq_temp=$(dmidecode -t memory | grep Configured\ Memory)
    echo "$mfq_temp" 			>  $MEM_SPEED_TEMP
    echo "$[ $count+1 ]" 		>> $MEM_SPEED
    echo "$log_date" 			>> $MEM_SPEED
    echo "$mfq_scan" 			>> $MEM_SPEED
    echo "" 				>> $MEM_SPEED
    mfq_diff=$(diff $MEM_SPEED_TEMP $MEM_SPEED_REAL | grep -v "^$")
    echo "$mfq_diff" 			>  $MEM_SPEED_DIFF
    if  [ -s $MEM_SPEED_DIFF ]&&[ $(wc -c < $MEM_SPEED_DIFF) -gt 10 ]; then
 	echo "$[ $count+1 ]" 		>> $MEM_SPEED_BUG
        echo "$log_date" 		>> $MEM_SPEED_BUG
        echo "$mfq_scan" 		>> $MEM_SPEED_BUG
        echo "" 			>> $MEM_SPEED_BUG
        echo "$mfq_scan"
        echo ">>>mem frequency check fail.<<<"
    else
        echo "$mfq_scan"
    	echo ">>>mem frequency check pass.<<<"
    fi
}
function menu_main_mode_test_config_net(){
    touch $target/log/net_infor.log
    touch $target/bug/net_bug_infor.log
    NET_COUNT=$target/log/net_infor.log
    NET_COUNT_BUG=$target/bug/net_bug_infor.log
    net_real=$(cat $TEST_INFOR | grep net_count: | cut -c 12-22)
    net_scan=$(ifconfig)
    net_temp=$(ifconfig | grep flags | wc -l)
    echo "$[ $count+1 ]" 		>> $NET_COUNT
    echo "$log_date" 			>> $NET_COUNT
    echo "$net_scan" 			>> $NET_COUNT
    echo "" 				>> $NET_COUNT
    if  [ "$net_temp" -ne "$((net_real))" ]; then
        echo "$[ $count+1 ]" 		>> $NET_COUNT_BUG
        echo "$log_date" 		>> $NET_COUNT_BUG
        echo "Expected  :$net_real." 	>> $NET_COUNT_BUG
        echo "But Found :$net_temp." 	>> $NET_COUNT_BUG
	echo "$net_scan" 		>> $NET_COUNT_BUG
        echo "" 			>> $NET_COUNT_BUG
        echo "$net_scan"
        echo ">>>netport check fail.<<<"
    else
    	echo "$net_scan"
    	echo ">>>netport check pass.<<<"
    fi
}
function menu_main_mode_test_config_mod(){
    touch $target/log/mod_infor.log
    touch $target/bug/mod_bug_infor.log
    MOD_COUNT=$target/log/mod_infor.log
    MOD_COUNT_BUG=$target/bug/mod_bug_infor.log
    mod_real=$(cat $TEST_INFOR | grep mod_count: | cut -c 12-22)
    mod_scan=$(lsmod | sort)
    mod_temp=$(lsmod | sort | wc -l)
    echo "$[ $count+1 ]" 		>> $MOD_COUNT
    echo "$log_date" 			>> $MOD_COUNT
    echo "$mod_scan" 			>> $MOD_COUNT
    echo "" 				>> $MOD_COUNT
    if  [ "$mod_temp" -lt "$((mod_real))" ]; then
        echo "$[ $count+1 ]" 		>> $MOD_COUNT_BUG
        echo "$log_date" 		>> $MOD_COUNT_BUG
        echo "Expected  :$mod_real." 	>> $MOD_COUNT_BUG
        echo "But Found :$mod_temp." 	>> $MOD_COUNT_BUG
	echo "$mod_scan" 		>> $MOD_COUNT_BUG
        echo "" 			>> $MOD_COUNT_BUG
        echo "$mod_scan"
        echo ">>>mod check fail.<<<"
    else
    	echo "$mod_scan"
    	echo ">>>mod check pass.<<<"
    fi
}
function menu_main_mode_test_config_sto(){
    touch $target/log/sto_infor.log
    touch $target/bug/sto_bug_infor.log
    STO_COUNT=$target/log/sto_infor.log
    STO_COUNT_BUG=$target/bug/sto_bug_infor.log 
    sto_real=$(cat $TEST_INFOR | grep sdx_count: | cut -c 12-22)
    sto_scan=$(lsblk -o NAME | grep sd)
    sto_temp=$(lsblk | grep sd | wc -l)
    echo "$[ $count+1 ]" 		>> $STO_COUNT
    echo "$log_date" 			>> $STO_COUNT
    echo "$sto_scan" 			>> $STO_COUNT
    echo "" 				>> $STO_COUNT
    if  [ "$sto_temp" -ne "$((sto_real))" ]; then
        echo "$[ $count+1 ]" 		>> $STO_COUNT_BUG
        echo "$log_date" 		>> $STO_COUNT_BUG
        echo "Expected  :$sto_real." 	>> $STO_COUNT_BUG
        echo "But Found :$sto_temp." 	>> $STO_COUNT_BUG
	echo "$sto_scan" 		>> $STO_COUNT_BUG
        echo "" 			>> $STO_COUNT_BUG
        echo "$sto_scan" 
        echo ">>>storage check fail.<<<"
    else
    	echo "$sto_scan"
    	echo ">>>storage check pass.<<<"
    fi
}
function menu_main_mode_test_config_ata(){
    touch $target/inf/ata_speed_temp.log 
    touch $target/inf/ata_speed_diff.log
    touch $target/log/ata_speed.log
    touch $target/bug/ata_bug_speed.log
    SATA_SPEED_REAL=$target/inf/ata_speed_information.log
    SATA_SPEED_TEMP=$target/inf/ata_speed_temp.log 
    SATA_SPEED_DIFF=$target/inf/ata_speed_diff.log
    SATA_SPEED=$target/log/ata_speed.log
    SATA_SPEED_BUG=$target/bug/ata_bug_speed.log
    sata_scan=$(dmesg | grep SATA\ link)
    sata_temp=$(dmesg | grep SATA\ link\ up | awk '{print $4 $5 $6 $7 $8}' | sort)
    echo "$sata_temp" 			>  $SATA_SPEED_TEMP
    echo "$[ $count+1 ]" 		>> $SATA_SPEED
    echo "$log_date" 			>> $SATA_SPEED
    echo "$sata_scan" 			>> $SATA_SPEED
    echo "" 				>> $SATA_SPEED
    sata_diff=$(diff $SATA_SPEED_TEMP $SATA_SPEED_REAL | grep -v "^$")
    echo "$sata_diff" 			>  $SATA_SPEED_DIFF
    if  [ -s $SATA_SPEED_DIFF ]&&[ $(wc -c < $SATA_SPEED_DIFF) -gt 10 ]; then
 	echo "$[ $count+1 ]" 		>> $SATA_SPEED_BUG
        echo "$log_date" 		>> $SATA_SPEED_BUG
        echo "$sata_scan" 		>> $SATA_SPEED_BUG
        echo "" 			>> $SATA_SPEED_BUG
        echo "$sata_scan"
        echo ">>>satalink check fail.<<<"
    else
        echo "$sata_scan"
    	echo ">>>satalink check pass.<<<"
    fi
}
function menu_main_mode_test_config_pci_aer(){
    AER_CONFIG=$target/inf/aercfg.log
    touch $target/log/aer_infor.log
    touch $target/inf/aer_temp.log
    touch $target/inf/aer_diff.log
    touch $target/bug/aer_bug_infor.log
    AER_AERIF=$target/inf/aerif.log
    AER_INFOR=$target/log/aer_infor.log
    AER_TEMP=$target/inf/aer_temp.log
    AER_DIFF=$target/inf/aer_diff.log
    AER_BUG=$target/bug/aer_bug_infor.log
    while read line; do
        pci_bus_bdf=$(echo "$line" | awk '{print $1}')
    	pci_bus_inf=$(echo "$line")
    	pci_bus_ed=$(lspci -s "$pci_bus_bdf" -vvv | grep Endpoint)
   	pci_bus_dc=$(lspci -s "$pci_bus_bdf" -vvv | grep DevCtl:)
   	pci_bus_ar=$(lspci -s "$pci_bus_bdf" -vvv | grep Advanced)
   	pci_bus_us=$(lspci -s "$pci_bus_bdf" -vvv | grep UESta:)
   	pci_bus_cs=$(lspci -s "$pci_bus_bdf" -vvv | grep CESta:)
   	echo "$pci_bus_inf" >>  $AER_TEMP
   	echo "$pci_bus_ed"  >>  $AER_TEMP
   	echo "$pci_bus_dc"  >>  $AER_TEMP
   	echo "$pci_bus_ar"  >>  $AER_TEMP
   	echo "$pci_bus_us"  >>  $AER_TEMP
   	echo "$pci_bus_cs"  >>  $AER_TEMP
    done < $AER_CONFIG
    sleep 1
    aer_temp=$(cat $AER_TEMP)
    echo "$[ $count+1 ]" 		>> $AER_INFOR
    echo "$log_date" 			>> $AER_INFOR
    echo "$aer_temp" 			>> $AER_INFOR
    echo "" 				>> $AER_INFOR
    aer_diff=$(diff $AER_TEMP $AER_AERIF | grep -v "^$")
    echo "$aer_diff" 			>  $AER_DIFF
    if  [ -s $AER_DIFF ]&&[ $(wc -c < $AER_DIFF) -gt 10 ]; then
 	echo "$[ $count+1 ]" 		>> $AER_BUG
        echo "$log_date" 		>> $AER_BUG
        echo "$aer_temp" 		>> $AER_BUG
        echo "" 			>> $AER_BUG
        echo "$aer_temp"
        echo ">>>aer check fail.<<<"
    else
    	echo "$aer_temp"
    	echo ">>>aer check pass.<<<"
    fi
    sleep 1
    rm -r $AER_TEMP
}
function menu_main_mode_test_config_fdk(){
    touch $target/inf/dsk_model_temp.log 
    touch $target/inf/dsk_model_diff.log
    touch $target/log/dsk_model.log
    touch $target/bug/dsk_bug_model.log
    DSK_MODEL_REAL=$target/inf/dsk_model_information.log
    DSK_MODEL_TEMP=$target/inf/dsk_model_temp.log 
    DSK_MODEL_DIFF=$target/inf/dsk_model_diff.log
    DSK_MODEL=$target/log/dsk_model.log
    DSK_MODEL_BUG=$target/bug/dsk_bug_model.log
    dsk_temp=$(fdisk -l | grep Disk\ model: | sort)
    echo "$dsk_temp" 			>  $DSK_MODEL_TEMP
    echo "$[ $count+1 ]" 		>> $DSK_MODEL
    echo "$log_date" 			>> $DSK_MODEL
    echo "$dsk_temp" 			>> $DSK_MODEL
    echo "" 				>> $DSK_MODEL
    dsk_diff=$(diff $DSK_MODEL_TEMP $DSK_MODEL_REAL | grep -v "^$")
    echo "$dsk_diff" 			>  $DSK_MODEL_DIFF
    if  [ -s $DSK_MODEL_DIFF ]&&[ $(wc -c < $DSK_MODEL_DIFF) -gt 10 ]; then
 	echo "$[ $count+1 ]" 		>> $DSK_MODEL_BUG
        echo "$log_date" 		>> $DSK_MODEL_BUG
        echo "$dsk_temp" 		>> $DSK_MODEL_BUG
        echo "" 			>> $DSK_MODEL_BUG
        echo "$dsk_temp"
        echo ">>>diskmodel check fail.<<<"
    else
        echo "$dsk_temp"
    	echo ">>>diskmodel check pass.<<<"
    fi
}
###################################################################################################
function start_main_test_execute() {
    local letter=$1
    local function_name="${program_names[$letter]}"
    local new_x=()
    local found=false
    for elem in "${x[@]}"; do
        if [[ "$elem" == "$letter" ]]; then
            sleep 1
            echo ">>>Loading: $function_name<<<"
            sleep 1
            $function_name
            found=true
        else
            new_x+=("$elem")
        fi
    done
    if [[ "$found" == true ]]; then
        x=("${new_x[@]}")
    fi
}
function start_main_test_main(){
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
            start_main_test_execute "$letter"
        done
    done
    echo ">>>All tests check completed<<<"
}
###################################################################################################
start_main
exit 0
###################################################################################################
