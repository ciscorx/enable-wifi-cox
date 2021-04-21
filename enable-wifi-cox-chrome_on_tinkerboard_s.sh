#!/bin/sh

###############################
##  enable-wifi-cox-chrome_on_tinkeroard_s.sh  
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
#  I'd prefer to risk losing all my vivaldi settings than my chromium
#  settings.

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



# check for default browser, this only catches default browser on tinkerboard s
md5=$(get_md5 35 110 375 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:1
fi

if [ $md5 = "6827ff4ef9c930807d12636d9b9cf477" ]; then
    echo Chrome isnt your default browser
    sleep 3

fi



# check for the x Cancel button on set default browser prompt and click it, this step only works on tinkerboard s
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

# check again to see if login/password are empty with focus on login textbox, and if so enter them.  This step only works on tinkerboard s
md5=$(get_md5 281 300 260 60)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:3
fi

if [ $md5 = "fa40166b689bb1a9bf15167a7c464fe2" ] || [ $md5 = "d595f5306769b7cf8a33df2dd26af1ec" ]; then
    # login/password are empty with no focus on either
    DISPLAY=:99 xte  'str admin' 'sleep 2' 'key Tab' 'usleep 300000' "str $router_password" 'sleep 2' 'key Return' 'sleep 2'
    echo login and password were empty, with no focus on them
fi


# check for incorrect user name, this step only works on tinkerboard s
md5=$(get_md5 332 118 140 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:4
fi

if [ $md5 = "14af589422f3fa378f68280b4d13f466" ]; then
    # login/password are empty with no focus on either
    echo Incorrect username.  You need to use the word admin as the login.  Exited unsuccessfully.
    exit
fi





# check again for connection left bar menu option and click it, this step only works for tinkerboard s
md5=$(get_md5 82 285 90 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:9
fi

if [ $md5 = "5d641ea99e80e889533b8ee28dfddc0c" ] || [ $md5 = "b2e18d520e439243069edbcfe556c2b7" ]; then
    DISPLAY=:99 xte 'mousemove 127 291' 'mouseclick 1'
    echo clicked connection menu option 
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



sleep 2
# check for wifi left bar menu option and click it.  Works for tinkerboard s
md5=$(get_md5 104 412 35 15)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:10
fi

if [ $md5 = "583be636762bb6c079eb6dc28edf79ef" ] || [ $md5 = "6f6a05d4cc38af2184b7273640d2aadb" ]; then
    DISPLAY=:99 xte 'mousemove 116 419' 'mouseclick 1'
    echo clicked wifi left bar menu option 
fi


sleep 3
# check for 1st wifi edit button and click it.  Tinkerboard s
md5=$(get_md5 917 407 26 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:11
fi

if [ $md5 = "34ea40559498a395dfde9a0e76bef56e" ]; then
    
    DISPLAY=:99 xte 'mousemove 930 413' 'mouseclick 1'
    echo clicked wifi 2.4ghz edit button

fi

# Tinkerboard s
sleep 5
if [ $enable_wifi1 = 1 ]; then
    sleep 1
# check for enable wifi 1 button and click it
    md5=$(get_md5 538 388 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:12
fi

    if [ $md5 = "e2b027c6488c2dca26a4c09bb9f6e4dc" ] || [ $md5 = "7ce09d782d7813204fee33284f699da7" ] ; then
	DISPLAY=:99 xte 'mousemove 560 395' 'mouseclick 1'
	echo clicked enable wifi 2.4ghz button 
    fi
else
    sleep 1
    # check for disable wifi 1 button 
    md5=$(get_md5 610 388 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:13
fi

    if [ $md5 = "51885a5b9d4266922ad7d0c56ba8ecea" ] ; then
	DISPLAY=:99 xte 'mousemove 639 395' 'mouseclick 1'
	echo clicked disable wifi 2.4ghz button 
    fi
    
fi


# save wifi 1 settings.  Tinkerboard s
sleep 5
md5=$(get_md5 528 903 93 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:14
fi

if [ $md5 = "deeb6e46692feba05b50c18a6e21cd83" ] ; then
    DISPLAY=:99 xte 'mousemove 570 908' 'mouseclick 1'
    echo saved wifi 2.4ghz setting
    
fi    


# save wifi 1 settings again at a different position just to be sure.  Tinkerboard s
sleep 5
md5=$(get_md5 535 824 90 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:14
fi

if [ $md5 = "037bb5437a6125fe9e23324a80df2e8f" ] ; then
    DISPLAY=:99 xte 'mousemove 570 829' 'mouseclick 1'
    echo saved wifi 2.4ghz setting
    
fi    


sleep 5
# check for save password?  Tinkerboard s
md5=$(get_md5 585 83 250 38)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:15
fi

if [ $md5 = "3c68ead4834e443efdada83d17cdedda" ] ; then
    # save password prompt is here, lets click save
    
    # DISPLAY=:99 xte  'mousemove 840 223' 'mouseclick 1' # save button
    
    # DISPLAY=:99 xte 'mousemove 922 223' 'mouseclick 1'  # never button
    DISPLAY=:99 xte 'mousemove 995 83' 'mouseclick 1'  # x (dont save but close prompt)
    echo clicked x to close the save password prompt, without saving password 

fi


sleep 2
# check for wifi left bar menu option and click it.  Works for tinkerboard s
md5=$(get_md5 104 412 35 15)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:10
fi

if [ $md5 = "583be636762bb6c079eb6dc28edf79ef" ] || [ $md5 = "6f6a05d4cc38af2184b7273640d2aadb" ] || [ $md5 = "f7ff7a85d54643cc69c252ed3945f416" ]; then
    DISPLAY=:99 xte 'mousemove 116 419' 'mouseclick 1'
    echo clicked wifi left bar menu option 
fi



sleep 2  
# check for 2nd wifi (5G) edit button and click it.  Tinkerboard s
md5=$(get_md5 917 437 26 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:17
fi

if [ $md5 = "9ed90bdd9dfc5c8d0caf6dde5de0dfa4" ] ; then
    DISPLAY=:99 xte 'mousemove 930 444' 'mouseclick 1'
    echo clicked wifi 5G menu edit button 
    
fi




# Tinkerboard s
sleep 5
if [ $enable_wifi1 = 1 ]; then
    sleep 1
# check for enable wifi 1 button and click it
    md5=$(get_md5 538 388 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:12
fi

    if [ $md5 = "e2b027c6488c2dca26a4c09bb9f6e4dc" ] || [ $md5 = "7ce09d782d7813204fee33284f699da7" ] ; then
	DISPLAY=:99 xte 'mousemove 560 395' 'mouseclick 1'
	echo clicked enable wifi 5G button 
    fi
else
    sleep 1
    # check for disable wifi 1 button 
    md5=$(get_md5 610 388 47 15)
    if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:13
fi

    if [ $md5 = "51885a5b9d4266922ad7d0c56ba8ecea" ] ; then
	DISPLAY=:99 xte 'mousemove 639 395' 'mouseclick 1'
	echo clicked disable wifi 5G button 
    fi
    
fi


# save wifi 2 settings.  Tinkerboard s
sleep 5
md5=$(get_md5 528 903 93 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:14
fi

if [ $md5 = "deeb6e46692feba05b50c18a6e21cd83" ] ; then
    DISPLAY=:99 xte 'mousemove 570 908' 'mouseclick 1'
    echo saved wifi 5G setting
    
fi    

# save wifi 2 settings again at a different position just to be sure.  Tinkerboard s
sleep 5
md5=$(get_md5 535 824 90 10)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:14
fi

if [ $md5 = "037bb5437a6125fe9e23324a80df2e8f" ] ; then
    DISPLAY=:99 xte 'mousemove 570 829' 'mouseclick 1'
    echo saved wifi 5G setting
    
fi    


sleep 5
# check for save password?  Tinkerboard s
md5=$(get_md5 585 83 250 38)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:15
fi

if [ $md5 = "3c68ead4834e443efdada83d17cdedda" ] ; then
    # save password prompt is here, lets click save
    
    # DISPLAY=:99 xte  'mousemove 840 223' 'mouseclick 1' # save button
    
    # DISPLAY=:99 xte 'mousemove 922 223' 'mouseclick 1'  # never button
    DISPLAY=:99 xte 'mousemove 995 83' 'mouseclick 1'  # x (dont save but close prompt)
    echo clicked x to close the save password prompt, without saving password 

fi



sleep 3
DISPLAY=:99 scrot /tmp/test.ppm
sleep 1
DISPLAY=:99 xte 'keydown Control_L' 'str wq' 'keyup Control_L'
sleep 2

pkill Xvfb
echo "ok"
