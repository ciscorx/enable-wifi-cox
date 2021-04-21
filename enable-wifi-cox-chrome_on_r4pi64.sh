#!/bin/sh

###############################
##  enable-wifi-cox-chrome_on_r4pi64.sh  
###############################
#  This sh script takes 2 arguments to either enable or disable the
#  wifi on a Cox panoramic wifi modem, the first argument pertaining
#  to 2.4gh and the 2nd argument pertaining to the 5G wifi.  An
#  argument of 1 means enable and 0 means disable.  If the script is
#  run without any arguments, the arguments are then assumed to be 1
#  1, enabling both 2.4ghz and 5Gi.  The computer on which the script
#  runs must be in the same LAN as the Cox Panoramic Wifi Gateway
#  router, which has an ip of 192.168.0.1 Unforunately, disabling the
#  wifi on a Cox panoramic wifi gateway modem will not stop it from
#  transmitting 5G and 2.4ghz wifi, as the modem continues to emit the
#  same amount of microwave radiation after its wifis are disabled via
#  the GUI web interface.  The screen shots of each step of the
#  process of enabling or disabling the wifi are optionally saved to
#  the tmp directory.  The only reason why I wrote this was because
#  vivaldi wouldnt work with Xvfb on tinkerboard s for some reason.
#  And, I'd prefer to risk losing all my vivaldi settings than my
#  chromium settings.

#  Warning: oh yeah, back up all chromium settings before using this
#  script, as it will hose all bookmarks and site data, including
#  passwords.

#  Requirements: linux, xvfb, xautomation, scrot 0.8-18+,
#  chromium-browser, Imagemagick (for optionally outputting
#  screenshots), gcc (to optionally compile the c programs for marking
#  up screen shots)

#  Authors/maintainers: ciscorx@gmail.com
#  License: GNU GPL v3


addr=192.168.0.1
router_password=password
output_screenshots=1
step_temp_dir=/tmp/$0

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
pkill chromium
pkill Xvfb
sleep 1
mkdir -p /tmp/temp-disk-cache-dir/
Xvfb :99 -fbdir /tmp &
sleep 1 

DISPLAY=:99 chromium --user-data-dir=/tmp/temp-disk-cache-dir --disk-cache-dir=/tmp/temp-disk-cache-dir --disk-cache-size=104857600 --profile-directory="Profile 2" $addr &

# up 40 left 40

sleep 10

# reset zoom if applied
DISPLAY=:99 xte 'keydown Control_L' 'str 0' 'keyup Control_L' 
sleep 1


# check to see if login/password are empty and focus is on login textbox, all the while the default browser prompt is displayed just below the address bar
md5=$(get_md5 233 290 250 60)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:0
fi

if [ $md5 = "6f35c2cdf9410b5ceceea8f5de87138c" ] || [ $md5 = "3d9f928d192692745361c99258a45e7e" ] || [ $md5 = "b412ec12572b18de34363eafbae83a49" ] || [ $md5 = "1efb8645330b9d8ca9ed2d34ecc68393" ]; then
    # login/password are empty with focus on login textbox
    DISPLAY=:99 xte  'str admin' 'key Tab' "str $router_password" 'sleep 1' 'key Return' 'sleep 5'
    echo login and password were empty, with focus on login textbox, now populated 
fi

#debug
# check for default browser
md5=$(get_md5 35 110 375 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:1
fi

if [ $md5 = "6827ff4ef9c930807d12636d9b9cf477" ]; then
    echo Chrome isnt your default browser
    sleep 3

fi


#debug
# check for the x Cancel button on set default browser prompt and click it
md5=$(get_md5 1034 115 12 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:2
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
echo $step - $md5; step=$(($step + 1))  #### step:3
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
echo $step - $md5; step=$(($step + 1))  #### step:4
fi

if [ $md5 = "" ]; then
    # login/password are empty with no focus on either
    echo Incorrect username error from $addr.  You need to use the word admin as the login.  Exited unsuccessfully.
    
fi

# check slightly to the right for incorrect user name
md5=$(get_md5 372 140 140 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:5
fi

if [ $md5 = "c478e60d7d3fd6b6f0c434437a293259" ]; then
    # login/password are empty with no focus on either
    echo Incorrect username error from $addr.  You need to use the word admin as the login.  Exited unsuccessfully.
    exit 
fi

# check for incorrect password for admin
md5=$(get_md5 330 115 200 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:6
fi

if [ $md5 = "15ab2216947d6533c99a844f2a7f0adc" ] || [ $md5 = "5942cb5d90cf5b0bd6580f8479a7e1f4" ]; then
    # incorrect password for admin
    DISPLAY=:99 xte 'mousemove 700 165' 'mouseclick 1'
    echo Incorrect password for admin from $addr, exited unsuccessfully
    exit
fi

#debug
# check to see if login/password are empty and focus is on login textbox
md5=$(get_md5 281 300 260 60)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:7
fi

if [ $md5 = "fa40166b689bb1a9bf15167a7c464fe2" ]; then
    # login/password are empty with focus on login textbox
     DISPLAY=:99 xte  'str admin' 'sleep 1' 'key Tab' 'usleep 300000' "str $router_password" 'sleep 1' 'key Return' 
    echo login and password are empty, with focus on login textbox 
fi

sleep 5
# check for save password?
md5=$(get_md5 677 253 130 18)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:8
fi

if [ $md5 = "6e95919c8ed294ff6cb2596653ffaf5b" ] ; then
    # save password prompt is here, lets click save
    
    # DISPLAY=:99 xte  'mousemove 930 400' 'mouseclick 1' # save button
    
    # DISPLAY=:99 xte 'mousemove 850 400' 'mouseclick 1'  # never button
    DISPLAY=:99 xte 'mousemove 968 90' 'mouseclick 1'  # x (dont save but close prompt)
    echo clicked x to close the save password prompt, without saving password 

fi

sleep 5
# check for connection left bar menu option and click it
md5=$(get_md5 82 267 90 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:9
fi

if [ $md5 = "16f8f2799daaa1e623babb67f8895d68" ] || [ $md5 = "4bd772e20165fd9710811f4de37f882e" ]; then
    DISPLAY=:99 xte 'mousemove 120 273' 'mouseclick 1'
    echo clicked connection menu option 
fi

sleep 2
# check for wifi left bar menu option and click it
md5=$(get_md5 103 393 35 15)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:10
fi

if [ $md5 = "309be51b325e9ed8fff985d0cd39127d" ] || [ $md5 = "16e0d263d27b46304bc1db23069aa88f" ]; then
    DISPLAY=:99 xte 'mousemove 121 400' 'mouseclick 1'
    echo clicked wifi left bar menu option 
fi

sleep 5


# check for 1st wifi edit button and click it
md5=$(get_md5 917 388 26 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:11
fi

if [ $md5 = "b17a19321e64e93fb76b920f7515111d" ]; then
    
    DISPLAY=:99 xte 'mousemove 930 394' 'mouseclick 1'
    echo clicked wifi 2.4ghz edit button

fi
    

if [ $enable_wifi1 = 1 ]; then
    sleep 1
# check for enable wifi 1 button and click it
    md5=$(get_md5 538 370 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:12
fi

    if [ $md5 = "8e7ba168740f5a53403b7628635e6ce7" ] || [ $md5 = "" ] ; then
	DISPLAY=:99 xte 'mousemove 560 377' 'mouseclick 1'
	echo clicked enable wifi 2.4ghz button 
    fi
else
    sleep 1
    # check for disable wifi 1 button 
    md5=$(get_md5 610 370 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:13
fi

    if [ $md5 = "10319fee60a8bc9aaf4502e81f2610fd" ] ; then
	DISPLAY=:99 xte 'mousemove 639 377' 'mouseclick 1'
	echo clicked disable wifi 2.4ghz button 
    fi
    
fi


# save wifi1 settings
sleep 5
md5=$(get_md5 535 805 90 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:14
fi

if [ $md5 = "2a9081ef33e95e38ef04c75d81393886" ] ; then
    DISPLAY=:99 xte 'mousemove 570 810' 'mouseclick 1'
    echo saved wifi 2.4ghz setting
    
fi    



sleep 5
# check for save password?
md5=$(get_md5 677 253 130 18)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:15
fi

if [ $md5 = "6e95919c8ed294ff6cb2596653ffaf5b" ] ; then
    # save password prompt is here, lets click save
    
    # DISPLAY=:99 xte  'mousemove 930 400' 'mouseclick 1' # save button
    
    # DISPLAY=:99 xte 'mousemove 850 400' 'mouseclick 1'  # never button
    DISPLAY=:99 xte 'mousemove 968 90' 'mouseclick 1'  # x (dont save but close prompt)
    echo clicked x to close the save password prompt, without saving password 

fi


sleep 2
# check for wifi left bar menu option and click it
md5=$(get_md5 103 393 35 15)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:16
fi

if [ $md5 = "309be51b325e9ed8fff985d0cd39127d" ] || [ $md5 = "f142fa9b56812094412065f14f315961" ]; then
    DISPLAY=:99 xte 'mousemove 121 400' 'mouseclick 1'
    echo clicked wifi left bar menu option 
fi

sleep 2  
# check for 2nd wifi (5G) edit button and click it
md5=$(get_md5 917 419 26 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:17
fi

if [ $md5 = "b17a19321e64e93fb76b920f7515111d" ] ; then
    DISPLAY=:99 xte 'mousemove 930 425' 'mouseclick 1'
    echo clicked wifi 5G menu option 
    
fi

sleep 10
if [ $enable_wifi1 = 1 ]; then
    sleep 1
# check for enable wifi 2 button and click it
    md5=$(get_md5 538 370 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:18
fi

    if [ $md5 = "8e7ba168740f5a53403b7628635e6ce7" ] || [ $md5 = "04524ff985935a107c7e61fd117e0a45" ] ; then
	DISPLAY=:99 xte 'mousemove 560 377' 'mouseclick 1'
	echo clicked enable wifi 5G button 
    fi
else
    sleep 1
    # check for disable wifi 2 button 
    md5=$(get_md5 610 370 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:19
fi

    if [ $md5 = "10319fee60a8bc9aaf4502e81f2610fd" ] ; then
	DISPLAY=:99 xte 'mousemove 639 377' 'mouseclick 1'
	echo clicked disable wifi 5G button 
    fi
    
fi


# save wifi 2 settings
sleep 5
md5=$(get_md5 528 884 90 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:20
fi

if [ $md5 = "879149efee157df52bde003c3b2b4c88" ] ; then
    DISPLAY=:99 xte 'mousemove 568 889' 'mouseclick 1'
    echo saved wifi 5G setting
    
fi    

# save wifi 2 settings, the more likely location
sleep 5
md5=$(get_md5 536 805 90 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:21
fi

if [ $md5 = "75609f0b779b97508b3ec5575801cf26" ] ; then
    DISPLAY=:99 xte 'mousemove 581 810' 'mouseclick 1'
    echo saved wifi 5G setting
    
fi    



sleep 5
# check for save password?
md5=$(get_md5 677 253 130 18)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:22
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
DISPLAY=:99 xte 'keydown Control_L' 'str w' 'keyup Control_L'
sleep 2

pkill Xvfb
echo "ok"
