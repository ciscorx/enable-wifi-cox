#!/bin/sh

##########################
##  enable-wifi-cox.sh  
##########################
#  This script takes 2 arguments to either enable or disable the wifi
#  on a Cox panoramic wifi modem, the first argument pertaining to
#  2.4gh and the 2nd argument pertaining to the 5G wifi.  An argument
#  of 1 means enable and 0 means disable.  If the script is run
#  without any arguments, the arguments are then assumed to be 1 1.
#  The computer on which the script runs must be in the same LAN as
#  the Cox Panoramic Wifi Gateway router, which has an ip of
#  192.168.0.1 Unforunately, disabling the wifi on a Cox panoramic
#  wifi gateway modem will not stop it from transmitting 5G and 2.4ghz
#  wifi; the modem continues to emit the same amount of microwave
#  radiation after its wifis are disabled via the GUI web interface.

#  Requirements: linux, xvfb, xautomation, vivaldi web browser ( works
#  well on raspberry pi and tinkerboard s, but on tinkerboard you must
#  first kill lightdm for the ram )

#  Authhors/maintainers: ciscorx@gmail.com
#

get_md5 () {
    
    DISPLAY=:99 scrot -a $1,$2,$3,$4 /tmp/targ.ppm

    tmpmd5=`md5sum /tmp/targ.ppm | awk '{print $1}'`

    echo $tmpmd5

}

if [ $# = 0 ]; then
    enable_wifi1=1
    enable_wifi2=1
else
    enable_wifi1=$1
    enable_wifi2=$2
fi
addr=192.168.0.1
router_password=password

Xvfb :99 &
sleep 2
DISPLAY=:99 vivaldi --start-in-incognito --disk-cache-dir=/tmp $addr &

# xvfb-run -l -n 99 vivaldi --start-in-incognito --disk-cache-dir=/tmp $addr &  # ok why doesnt xvfb-run work?

sleep 20
# check to see if vivaldi is being started for the very first time, in which case restart it
md5=$(get_md5 254 52 130 15)
echo $md5
if [ $md5 = "be87917ac5fba0c604eddbf1e42607a7" ]; then
    echo killing vivaldi and restarting
    sudo pkill vivaldi
    sleep 3
    
    DISPLAY=:99 vivaldi --start-in-incognito --disk-cache-dir=/tmp $addr &
    sleep 20
fi



# check for default browser
md5=$(get_md5 450 140 230 15)
echo $md5
if [ $md5 = "90fc4b88386dd331f6eb14a97f8b78e7" ]; then
    echo Vivaldi isnt your default browser
    sleep 3

fi


# check for the checking of default browser on startup
md5=$(get_md5 450 140 230 15)
echo $md5
if [ $md5 = "0f80186fc58f6beffee5b3c4c2dbfeea" ]; then
    echo and checkmark on checking of default browser on startup is checked
    ## checkbox is at 466 166
    # DISPLAY=:99 xte 'mousemove 466 166' 'mouseclick 1'
    sleep 3

fi

# check for Cancel button on set default browser prompt and click it
echo $md5
md5=$(get_md5 466 200 230 33)
if [ $md5 = "10bfb3a48e9b44094ced81ebd0915a5d" ] || [ $md5 = "db3ec24fd81bde784c2176c0d916c9be" ] || [ $md5 = "529b85cacf506be3c05972f1c7881d14" ]; then
    ## Set as Default button has focus
    # click Set As Default
    # DISPLAY=:99 xte 'mousemove 510 216' 'mouseclick 1'
    # click Cancel
    DISPLAY=:99 xte 'mousemove 640 216' 'mouseclick 1'  'sleep 1'
       
fi
       
    
# check to see if login/password are empty with focus on neither login nor password textboxes, and if so enter them
md5=$(get_md5 400 288 268 58)
echo $md5
if [ $md5 = "ed3e5f40f2cd795e1e264766c77cfb2a" ]; then
    # login/password are empty with no focus on either
    DISPLAY=:99 xte  'mousemove 420 305' 'mouseclick 1' 'sleep 2' 'str admin' 'sleep 2' 'key Tab' 'usleep 300000' "str $router_password" 'sleep 2' 'key Return' 'sleep 2'
    echo login and password were empty, with no focus on them
fi

# check for incorrect user name
md5=$(get_md5 472 140 140 20)
echo $md5
if [ $md5 = "97d60a96ff2ada1aa915b0f574c1714e" ]; then
    # login/password are empty with no focus on either
    echo Incorrect username error from $addr
fi


# check for incorrect password for admin
md5=$(get_md5 472 140 196 20)
echo $md5
if [ $md5 = "39ac67797ff41f8005108daea3714681" ]; then
    # incorrect password for admin
    echo Incorrect password for admin from $addr
fi


# check to see if login/password are empty and focus is on login textbox
md5=$(get_md5 400 288 268 58)
echo $md5
if [ $md5 = "3127d0881a9e981cf56daaa2e87dff13" ]; then
    # login/password are empty with focus on login textbox
     DISPLAY=:99 xte  'str admin' 'key Tab' "str $router_password" 'sleep 1' 'key Return' 'sleep 5'
    echo login and password are empty, with focus on login textbox 
fi

sleep 5
# check for save password?
md5=$(get_md5 824 257 145 58)
echo $md5
if [ $md5 = "b1fdd597cbe0883b58a88985da6479a6" ] ; then
    # save password prompt is here, lets click save
    
    DISPLAY=:99 xte  'mousemove 1070 397' 'mouseclick 1' # save button
    
    #DISPLAY=:99 xte 'mousemove 1000 400' 'mouseclick 1'  # never button
    # DISPLAY=:99 xte 'mousemove 1113 97' 'mouseclick 1'  # x (dont save and close prompt)
    echo login and password are empty, with focus on login textbox 

fi

sleep 5

# check for connect left bar menu option and click it
md5=$(get_md5 215 268 73 15)
echo $md5
if [ $md5 = "505210b9e2558f2b865d9ef4be97fd02" ] ; then
    DISPLAY=:99 xte 'mousemove 245 277' 'mouseclick 1'
    echo clicked connection menu option 
fi

sleep 2
# check for wifi left bar menu option and click it
md5=$(get_md5 225 397 35 15)
echo $md5
if [ $md5 = "2b075cdb20d188bd9bd96a14213e1c34" ] ; then
    DISPLAY=:99 xte 'mousemove 240 405' 'mouseclick 1'
    echo clicked wifi left bar menu option 
fi

sleep 5
# check for 1st wifi edit button and click it
md5=$(get_md5 1038 393 30 10)
echo $md5
if [ $md5 = "0c684d0b0d6fedf58063936b84f2b608" ] || [ $md5 = "fd16ceb5a9caf9b64305b39b73e769c8" ] ; then
    
    DISPLAY=:99 xte 'mousemove 1050 400' 'mouseclick 1'
    echo clicked wifi 1 menu option 

fi
    

if [ $enable_wifi1 = 1 ]; then
    sleep 1
# check for enable wifi 1 button and click it
    md5=$(get_md5 668 374 47 15)
    echo $md5
    if [ $md5 = "30d436649a355b3ebb7d2ad65e732af4" ] ; then
	DISPLAY=:99 xte 'mousemove 680 380' 'mouseclick 1'
	echo clicked enable wifi1 button 
    fi
else
    sleep 1
    # check for disable wifi 1 button 
    md5=$(get_md5 731 374 47 15)
    echo $md5
    if [ $md5 = "1a0780704096fe10069d2e5c04309d56" ] ; then
	DISPLAY=:99 xte 'mousemove 744 380' 'mouseclick 1'
	echo clicked disable wifi1 button 
    fi
    
fi


# the buttons might be offset so try to enable or disable wifi again 
sleep 3
if [ $enable_wifi1 = 1 ]; then
    sleep 1
# check for enable wifi 1 button and click it
    md5=$(get_md5 658 374 47 15)
    echo $md5
    if [ $md5 = "43db26e9fa09b7273938e6b884839237" ] ; then
	DISPLAY=:99 xte 'mousemove 678 380' 'mouseclick 1'
	echo clicked enable wifi1 button 
    fi
else
    sleep 1
    # check for disable wifi 1 button 
    md5=$(get_md5 731 374 47 15)
    echo $md5
    if [ $md5 = "1a0780704096fe10069d2e5c04309d56" ] ; then
	DISPLAY=:99 xte 'mousemove 744 380' 'mouseclick 1'
	echo clicked disable wifi1 button 
    fi
    
fi

# save wifi1 settings
sleep 5
md5=$(get_md5 657 807 92 15)
echo $md5
if [ $md5 = "af364861268972e0fa234680ca1f8f7d" ] ; then
    DISPLAY=:99 xte 'mousemove 700 813' 'mouseclick 1'
    echo saved wifi1 setting
    
fi    

# check for save password again
sleep 10
md5=$(get_md5 800 257 135 18)
echo $md5
if [ $md5 = "b99e0565d7c138fc5e979f2efee9f87d" ] ; then
    md5=$(get_md5 1035 387 40 19)
    if [ $md5 = "1044b78815e0b2ea494509a74ec16a6e" ]; then
	 DISPLAY=:99 xte 'mousemove 1060 395' 'mouseclick 1'  ## SAVE
	# DISPLAY=:99 xte 'mousemove 975 395' 'mouseclick 1'  ## Never
	# DISPLAY=:99 xte 'mousemove 1090 95' 'mouseclick 1'  ## x for close window
	echo save wifi 1 passphrase button clicked
    fi
    
fi    


sleep 5

# check for wifi left bar menu option again and click it
md5=$(get_md5 225 397 35 15)
echo $md5
if [ $md5 = "2b075cdb20d188bd9bd96a14213e1c34" ] || [ $md5 = "29950e58f0f88e8daee7ea9c6251c0f3" ]; then
    DISPLAY=:99 xte 'mousemove 240 405' 'mouseclick 1'
    echo clicked wifi left bar menu option 
fi

sleep 5
# check for 2nd wifi (5G) edit button and click it
md5=$(get_md5 1038 422 30 10)
echo $md5
if [ $md5 = "a5c48a6700da64ebaee83b20e93b1587" ] || [ $md5 = "67abbb9eaecd64a101c55cf801c428ec" ] || [ $md5 = "ac3ed3febf8f2c6bd5bc7b84c14b499c" ] || [ $md5 = "a09b0ba8f0e3f84c2ef8dbb46ccb0dd6" ]; then
    DISPLAY=:99 xte 'mousemove 1050 430' 'mouseclick 1'
    echo clicked wifi 5G menu option 
    
fi

sleep 10
if [ $enable_wifi2 = 1 ]; then
# check for enable wifi 2 button and click it
    md5=$(get_md5 660 374 40 15)
    echo checking to enable wifi 5G button
    echo $md5
    if [ $md5 = "ee3508bca8e53d787417d075970c1110" ] ; then
	DISPLAY=:99 xte 'mousemove 680 380' 'mouseclick 1'
	echo clicked enable wifi 5G button 
    fi
else
# check for disable wifi 2 button 
    md5=$(get_md5 732 374 45 15)
    echo checking to disable wifi 5G button
    echo $md5
    if [ $md5 = "20bb53083c8417ccc674f9e33b3563d0" ] ; then
	DISPLAY=:99 xte 'mousemove 744 380' 'mouseclick 1'
	echo clicked disable wifi 5G button 
    fi    
fi



# save wifi2 settings
sleep 1
md5=$(get_md5 655 807 92 12)
echo $md5
if [ $md5 = "9332dfc9cf77bf7e8faa630f7493636b" ] ; then
    DISPLAY=:99 xte 'mousemove 700 813' 'mouseclick 1'
    
    echo saved wifi 5G setting
    
fi    
# save wifi2 settings
sleep 1
md5=$(get_md5 650 887 92 12)
echo $md5
if [ $md5 = "189a97f879c199d9d528ed102aee015a" ] ; then
    DISPLAY=:99 xte 'mousemove 700 892' 'mouseclick 1'
    
    echo saved wifi 5G setting
    
fi    


# check for save password again
sleep 10
md5=$(get_md5 800 257 135 18)
echo $md5
if [ $md5 = "b99e0565d7c138fc5e979f2efee9f87d" ] ; then
    md5=$(get_md5 1035 387 40 19)
    if [ $md5 = "1044b78815e0b2ea494509a74ec16a6e" ]; then
	DISPLAY=:99 xte 'mousemove 1060 395' 'mouseclick 1'  ## SAVE
	# DISPLAY=:99 xte 'mousemove 975 395' 'mouseclick 1'  ## Never
	# DISPLAY=:99 xte 'mousemove 1090 95' 'mouseclick 1'  ## x for close window
	echo save wifi 5G passphrase button clicked
    fi
    
fi    





sleep 3
DISPLAY=:99 scrot /tmp/test.ppm
sleep 1
DISPLAY=:99 xte 'keydown Control_L' 'str wq' 'keyup Control_L'
sleep 2
sudo pkill Xvfb
echo "ok"
