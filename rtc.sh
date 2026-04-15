#!/bin/bash
#Advantech.ASH.ISG.RD Yu
#2023/09/13 1.0.6
#Path:/Desktop
function manu(){
    printf "\nManu:\n 1. Advantech ASH  NTP Server\n 2. Advantech AKTC NTP Server\n 3. National Time Center NTP Server\n 4. Other\n 5. Version \n"
    read -t 20 -p "Choose Your Server in 20 sec(1-5): " choice
    case $choice in
        1)
            host=172.21.75.39
            printf "\nAdvantech ASH  NTP Server Is Loding...\n"
            ;;
        2)
            host=172.21.128.10
            printf "\nAdvantech AKTC NTP Server Is Loding...\n"
            ;;            
        3)
            host=ntp.ntsc.ac.cn
            printf "\nNational Time Center NTP Server Is Loding...\n"
            ;;            
        4)
            ip
            printf "\nYour Server Is Loding...\n"
            ;;
        5)
            printf "\n-Version 1.0.6-\n-Advantech.ASH.ISG.RD Yu-\n\n┌( ಠ_ಠ)┘ Nothing is impossible! \n2023/09/13\n\n"         
            exit 0
            ;; 
        *)
            echo "Invalid choice or timeout reached."
            exit 1
            ;;
    esac    
}
function ip(){
    printf "\nEnter Your NTP Server IP\n"
    read ip
    host=$ip
}
function ipcheck(){
    ping -c 1 -W 1 $host > /dev/null 2>&1 
    if [ $? -eq 0 ]; then
        echo "Connect $host Success!"
        sleep 2
    else
        echo "Connect $host Fail!" 
        printf "\nPlease check your network or try to use another ntp server. \n\n"
        exit 1
    fi
}
function sec(){
    printf "\nManu:\n 1. 24H\n 2. Other\n"
    read -t 20 -p "Intup Your Test Time in 20 sec(1-2): " choice
    case $choice in
        1)
            sec=86400
            printf "\nDone! \n\n"
            ;;
        2)
            secdiy
            printf "\nDone! \n\n"
            ;;
        *)
            echo "Invalid choice or timeout reached."
            exit 1
            ;;
    esac  
}
function secdiy(){
    printf "\nEnter Test Time (sec): "
    read secdiy
    sec=$secdiy
}
function ntpd(){
    ntpdate $host | awk '{print $10}'
}
function ntpda(){
    cat inf.log | sed 's/[-+]*//'
}
function inf(){
    cat inf.log
}
function timeclock(){
    while [ $sec -ge 0 ]; do
        hours=$((sec / 3600 % 24))
        mins=$((sec / 60 % 60))
        secs=$((sec % 60))
        printf "%02d:%02d:%02d\r" $hours $mins $secs
    sleep 1
        sec=$((sec-1)) 
    done
        echo "Ready to check result..."
}
function check(){
    if [ "$b" -le "2" ];then
        echo "pass!"
    else
        echo "fail!"
    fi
}
function clear(){
    rm -r info.log inf.log
}
function cleap(){
    rm -r info.log inf.log net.log
}
function main1(){
        echo "RTC Check Runing..."
        ntpdate $host > info.log
        echo "System clock sync completed! "
    hwclock -w
        echo "Hardware clock sync completed! "
    timeclock
    ipcheck
        ntpd > inf.log
        ntpda > info.log
        sys=$(cat info.log |cut -d. -f1)
        b=$sys
        echo "System Clock:"
    check
    inf
    sleep 5
    hwclock -s
        ntpd > inf.log
        ntpda > info.log
        rtc=$(cat info.log |cut -d. -f1)
        b=$rtc
    echo "Hardware clock:"
    check
    inf
    sleep 1
    clear
}
function dynamic(){
      timectl
      stpserver
      sleep 2
      manu
      ipcheck
      sec 
      main1
    exit 0
}
function stpserver(){
    sudo systemctl stop ntp
    echo "The NTP service on this machine is stopped~"
}
function timectl(){
    timedatectl set-local-rtc 1
}
function main2(){
        echo "RTC Check Runing..."
        ntpdate $host > info.log
        echo "System clock sync completed! "
    hwclock -w
        echo "Hardware clock sync completed! "
        echo "3278" > inf.log
        echo "$host" > net.log
        exit 0
}
function static(){
    touch inf.log
    sleep 1
    ca=$(cat inf.log)
    if [ "$((ca))" -eq "3278" ]; then
        echo "Checking..."
        stpserver
        sleep 3
        sta
    else
        timectl
        stpserver
        sleep 2
        manu
        ipcheck
        main2
        echo "Please shutdown this machine!"
    fi
}
function sta(){  
    host=$(cat net.log)
    ipcheck
        ntpd > inf.log
        ntpda > info.log
        sys=$(cat info.log |cut -d. -f1)
        b=$sys
        echo "System Clock:"
    check
    inf
    sleep 5
    hwclock -s
        ntpd > inf.log
        ntpda > info.log
        rtc=$(cat info.log |cut -d. -f1)
        b=$rtc
    echo "Hardware clock:"
    check
    inf
    sleep 1
    cleap

}
function start(){
    printf "\nManu:\n 1. Dynamic RTC\n 2. Static RTC\n"
    read -t 20 -p "Intup Your Test Time in 20 sec(1-2): " choice
    case $choice in
        1)
            dynamic
            exit 0
            ;;
        2)
            static
            exit 0
            ;;
        *)
            echo "Invalid choice or timeout reached."
            exit 1
            ;;
    esac  
}

  start
exit 0
