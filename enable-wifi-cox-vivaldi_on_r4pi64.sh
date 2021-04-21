#!/bin/sh

###############################
##  enable-wifi-cox-vivaldi_on_r4pi64.sh  
###############################
#  This sh script takes 2 arguments to either enable or disable the
#  wifi on a Cox panoramic wifi modem, the first argument pertaining
#  to 2.4gh and the 2nd argument pertaining to the 5G wifi.  An
#  argument of 1 means enable and 0 means disable.  If the script is
#  run without any arguments, the arguments are then assumed to be 1
#  1.  The computer on which the script runs must be in the same LAN
#  as the Cox Panoramic Wifi Gateway router, which has an ip of
#  192.168.0.1 Unforunately, disabling the wifi on a Cox panoramic
#  wifi gateway modem will not stop it from transmitting 5G and 2.4ghz
#  wifi; the modem continues to emit the same amount of microwave
#  radiation after its wifis are disabled via the GUI web interface.
#  The screen shots of each step of the process of enabling or
#  disabling the wifi are saved to the tmp directory, and can be
#  disabled by setting output_screenshots=0.  Use the 'make' shell
#  command to compile the c programs that are used to mark up the
#  screenshots.  Vivaldi is being used instead of chrome because i
#  dont want to risk losing any user data or bookmarks in chrome.

#  Warning: This script will hose all your vivaldi settings
#  such as bookmarks and site data.

#  Requirements: linux, xvfb, xautomation, scrot 0.8-18+,
#  vivaldi-stable, Imagemagick (for optionally outputting
#  screenshots), gcc (for optionally compiling c functions to output
#  screenshots)

#  Authors/maintainers: ciscorx@gmail.com
#  License: GNU GPL v3


addr=192.168.0.1
router_password=password
output_screenshots=1
step_temp_dir=/tmp/$0
wwwbrowser=vivaldi-stable

rm -rf /tmp/temp-disk-cache-dir
rm -rf $step_temp_dir
mkdir -p $step_temp_dir

step=0

get_md5 () {
    DISPLAY=:99 scrot -a $1,$2,$3,$4 /tmp/targ.ppm
    tmpmd5=`md5sum /tmp/targ.ppm | awk '{print $1}'`

    if [ $output_screenshots = 1 ]; then
	cp /tmp/targ.ppm $step_temp_dir/$(printf "%.3d" $step)\ -$tmpmd5.ppm
	DISPLAY=:99 scrot /tmp/fullscreen.ppm
	cp /tmp/fullscreen.ppm $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm
	./draw_a_rectangle_in_a_ppm_file.o $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm $1 $2 $3 $4
	./draw_a_circle_in_a_ppm_file.o $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm $(($1+$3/2)) $(($2+$4/2)) $3
	convert $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm  $step_temp_dir/$(printf "%.3d" $step)\ -\ $1\ $2\ $3\ $4.png
	rm $step_temp_dir/$step\ -\ $1\ $2\ $3\ $4.ppm
    fi
    echo $tmpmd5
}

if [ $# = 0 ]; then
    enable_wifi1=1
    enable_wifi2=1
else
    enable_wifi1=$1
    enable_wifi2=$2
fi

# have to start out by killing any opened chromium sessions or the script will try to use an already opened session
pkill $wwwbrowser
rm -rf /tmp/temp-disk-cache-dir
rm -rf ~/.config/vivaldi
rm -rf ~/.cache/vivialdi
pkill Xvfb

sleep 1
mkdir -p /tmp/temp-disk-cache-dir/
Xvfb :99 -fbdir /tmp &
sleep 1 

DISPLAY=:99 $wwwbrowser --user-data-dir=/tmp/temp-disk-cache-dir --disk-cache-dir=/tmp/temp-disk-cache-dir --disk-cache-size=104857600 --profile-directory="Profile 2" $addr &

# up 40 left 40

sleep 10

# reset zoom if applied
DISPLAY=:99 xte 'keydown Control_L' 'str 0' 'keyup Control_L' 
sleep 1

# check to see if login/password are empty and focus is on login textbox, all the while the default browser prompt is displayed just below the address bar
md5=$(get_md5 402 287 250 60)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "42beede61137d8c1b0a519b952b78cf1" ] || [ $md5 = "b29c25a73bece5d3fc45665558438889" ] || [ $md5 = "" ] || [ $md5 = "" ]; then
    # login/password are empty with focus on login textbox
    DISPLAY=:99 xte  'str admin' 'key Tab' "str $router_password" 'sleep 1' 'key Return' 'sleep 5'
    echo login and password were empty, with focus on login textbox, now populated 
fi

#debug
# check for default browser
md5=$(get_md5 35 110 375 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "6827ff4ef9c930807d12636d9b9cf477" ]; then
    echo Chrome isnt your default browser
    sleep 3

fi


#debug
# check for the x Cancel button on set default browser prompt and click it
md5=$(get_md5 1034 115 12 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "a42c9b7f21a1eb148c110b78fc9f4303" ]; then
    ## Set as Default button has focus
    # click Set As Default
    # DISPLAY=:99 xte 'mousemove 510 216' 'mouseclick 1'
    # click x Cancel
    DISPLAY=:99 xte 'mousemove 1040 121' 'mouseclick 1'  'sleep 1'
       
fi
       
#debug    
# check to see if login/password are empty with focus on neither login nor password textboxes, and if so enter them
md5=$(get_md5 281 300 260 60)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "" ]; then
    # login/password are empty with no focus on either
    DISPLAY=:99 xte  'mousemove 420 305' 'mouseclick 1' 'sleep 2' 'str admin' 'sleep 2' 'key Tab' 'usleep 300000' "str $router_password" 'sleep 2' 'key Return' 'sleep 2'
    echo login and password were empty, with no focus on them
fi

#debug
# check for incorrect user name
md5=$(get_md5 472 140 140 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "" ]; then
    # login/password are empty with no focus on either
    echo Incorrect username error from $addr
fi

#debug
# check for incorrect password for admin
md5=$(get_md5 330 115 200 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "15ab2216947d6533c99a844f2a7f0adc" ]; then
    # incorrect password for admin
    DISPLAY=:99 xte 'mousemove 700 165' 'mouseclick 1'
    echo Incorrect password for admin from $addr, clicked ok to that
fi


# check again for incorrect password for admin, this time to the right
md5=$(get_md5 475 137 200 13)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "15ab2216947d6533c99a844f2a7f0adc" ]; then
    # incorrect password for admin
    DISPLAY=:99 xte 'mousemove  500 190' 'mouseclick 1'
    echo Incorrect password for admin from $addr, clicked ok to that
    exit
fi

#debug
# check to see if login/password are empty and focus is on login textbox
md5=$(get_md5 281 300 260 60)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "fa40166b689bb1a9bf15167a7c464fe2" ]; then
    # login/password are empty with focus on login textbox
     DISPLAY=:99 xte  'str admin' 'sleep 1' 'key Tab' 'usleep 300000' "str $router_password" 'sleep 1' 'key Return' 
    echo login and password are empty, with focus on login textbox 
fi

sleep 5
# check for save password?
md5=$(get_md5 960 33 133 18)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "183673e23def260905d8c6721e7cbe75" ] ; then
    
    #  DISPLAY=:99 xte  'mousemove 1210 162' 'mouseclick 1' # save button
    
    # DISPLAY=:99 xte 'mousemove 1140 162' 'mouseclick 1'  # never button
    DISPLAY=:99 xte 'mousemove 1250 28' 'mouseclick 1'  # x (dont save but close prompt)
    echo clicked x to close the save password prompt, without saving password 

fi

sleep 5
# check for connection left bar menu option and click it
md5=$(get_md5 202 270 90 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "b167d9c5cad09312c813d3d5b1ee847e" ] || [ $md5 = "56f496eadd2297226e52b74702beb994" ] ; then
    DISPLAY=:99 xte 'mousemove 247 276' 'mouseclick 1'
    echo clicked connection menu option 
fi

sleep 2
# check for wifi left bar menu option and click it
md5=$(get_md5 225 397 35 15)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "309be51b325e9ed8fff985d0cd39127d" ] || [ $md5 = "16e0d263d27b46304bc1db23069aa88f" ]; then
    DISPLAY=:99 xte 'mousemove 240 405' 'mouseclick 1'
    echo clicked wifi left bar menu option 
fi

sleep 5

# check for 1st wifi edit button and click it
md5=$(get_md5 1039 392 26 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "b17a19321e64e93fb76b920f7515111d" ]; then
    
    DISPLAY=:99 xte 'mousemove 1052 398' 'mouseclick 1'
    echo clicked wifi 2.4ghz edit button

fi


sleep 1
if [ $enable_wifi1 = 1 ]; then
    sleep 1
# check for enable wifi 1 button and click it
    md5=$(get_md5 659 375 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

    if [ $md5 = "5aba143488d7f4248df389a302d8aaa1" ] || [ $md5 = "52f0821dc18bed27432e7dcd8cc7492b" ] ; then
	DISPLAY=:99 xte 'mousemove 683 382' 'mouseclick 1'
	echo clicked enable wifi 2.4ghz button 
    fi
else
    sleep 1
    # check for disable wifi 1 button 
    md5=$(get_md5 732 375 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

    if [ $md5 = "edfcbf14dbae7a7955d3662c281fd34a" ] ; then
	DISPLAY=:99 xte 'mousemove 755 381' 'mouseclick 1'
	echo clicked disable wifi 2.4ghz button 
    fi
    
fi


# save wifi1 settings
sleep 5
md5=$(get_md5 658 809 90 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "75609f0b779b97508b3ec5575801cf26" ] ; then
    DISPLAY=:99 xte 'mousemove 700 814' 'mouseclick 1'
    echo saved wifi 2.4ghz setting
    
fi    


# save wifi1 settings again but at a lower location
sleep 5
md5=$(get_md5 651 888 90 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "79b1332155255843d19b851e4b4259f5" ] ; then
    DISPLAY=:99 xte 'mousemove 700 893' 'mouseclick 1'
    echo saved wifi 2.4ghz setting
    
fi    


sleep 5
# check for save password?
md5=$(get_md5 960 33 133 18)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "183673e23def260905d8c6721e7cbe75" ] ; then
    # save password prompt is here, lets click save
    
    # DISPLAY=:99 xte  'mousemove 1210 162' 'mouseclick 1' # save button
    
    # DISPLAY=:99 xte 'mousemove 1140 162' 'mouseclick 1'  # never button
    DISPLAY=:99 xte 'mousemove 1250 28' 'mouseclick 1'  # x (dont save but close prompt)
    echo clicked x to close the save password prompt, without saving password 

fi



sleep 2
# check for wifi left bar menu option and click it
md5=$(get_md5 225 397 35 15)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "309be51b325e9ed8fff985d0cd39127d" ] || [ $md5 = "67d7bb8c0c947eba483547995aa64cb6" ] || [ $md5 = "f142fa9b56812094412065f14f315961" ]; then
    DISPLAY=:99 xte 'mousemove 240 405' 'mouseclick 1'
    echo clicked wifi left bar menu option 
fi


# check for 2nd wifi edit button and click it
md5=$(get_md5 1039 423 26 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "b17a19321e64e93fb76b920f7515111d" ]; then
    
    DISPLAY=:99 xte 'mousemove 1052 429' 'mouseclick 1'
    echo clicked wifi 5G edit button

fi
    


sleep 1
if [ $enable_wifi1 = 1 ]; then
    sleep 1
# check for enable wifi 2 button and click it
    md5=$(get_md5 659 375 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

    if [ $md5 = "5aba143488d7f4248df389a302d8aaa1" ] || [ $md5 = "52f0821dc18bed27432e7dcd8cc7492b" ] ; then
	DISPLAY=:99 xte 'mousemove 683 382' 'mouseclick 1'
	echo clicked enable wifi 5G button 
    fi
else
    sleep 1
    # check for disable wifi 1 button 
    md5=$(get_md5 732 375 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

    if [ $md5 = "edfcbf14dbae7a7955d3662c281fd34a" ] ; then
	DISPLAY=:99 xte 'mousemove 755 381' 'mouseclick 1'
	echo clicked disable wifi 5G button 
    fi
    
fi


# save wifi 2 settings
sleep 5
md5=$(get_md5 658 809 90 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "75609f0b779b97508b3ec5575801cf26" ] ; then
    DISPLAY=:99 xte 'mousemove 700 815' 'mouseclick 1'
    echo saved wifi 5G setting
    
fi    



sleep 5
# check for save password?
md5=$(get_md5 677 253 130 18)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "6e95919c8ed294ff6cb2596653ffaf5b" ] ; then
    # save password prompt is here, lets click save
    
    # DISPLAY=:99 xte  'mousemove 930 400' 'mouseclick 1' # save button
    
    # DISPLAY=:99 xte 'mousemove 850 400' 'mouseclick 1'  # never button
    DISPLAY=:99 xte 'mousemove 968 90' 'mouseclick 1'  # x (dont save but close prompt)
    echo clicked x to close the save password prompt, without saving password 

fi



sleep 3
DISPLAY=:99 scrot /tmp/test.ppm
sleep 1
DISPLAY=:99 xte 'keydown Control_L' 'str wq' 'keyup Control_L'
sleep 2

pkill Xvfb
echo "ok"
