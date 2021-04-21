#!/bin/sh
###############################
##  status-wifi-cox-chromium.sh  
###############################
#  This sh script takes no arguments and says whether the wifi, both
#  2.4ghz and 5G, are active or inactive.
#
#  The computer on which the script runs must be in the same LAN as
#  the Cox Panoramic Wifi Gateway router, which has an ip of
#  192.168.0.1, and the router_password for the router must be hard
#  coded into this script since it has to log into the router via the
#  web interface.  The panoramic router that Cox provides is the only
#  router I know of that actually makes you log in just to see the
#  wifi status.
#
#  The screen shots of each step of the process of checking the wifi
#  status are optionally saved to the tmp directory.  This script has
#  been tested on raspberry pi 4 64 bit OS, raspberry pi 4 64 bit OS,
#  and tinkerboard s.

#  Warning: oh yeah, back up all your chromium settings before using
#  this script, as it will hose all bookmarks and site data, including
#  passwords.

#  Requirements: linux, xvfb, xautomation, scrot 0.8-18+, chromium,
#  Imagemagick (for optionally outputting screenshots), gcc (to
#  optionally compile the enclosed c programs provided for marking up
#  screen shots)

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

if [ $md5 = "14af589422f3fa378f68280b4d13f466" ] ; then
    # login/password are empty with no focus on either
    echo Incorrect username.  You need to use the word admin as the login.  Exited unsuccessfully.
    exit
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

if [ $md5 = "fa40166b689bb1a9bf15167a7c464fe2" ] || [ $md5 = "d595f5306769b7cf8a33df2dd26af1ec" ]; then
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
sleep 5

# check again for connection left bar menu option and click it, this step only works for tinkerboard s
md5=$(get_md5 82 285 90 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))  #### step:9
fi

if [ $md5 = "5d641ea99e80e889533b8ee28dfddc0c" ] || [ $md5 = "b2e18d520e439243069edbcfe556c2b7" ]; then
    DISPLAY=:99 xte 'mousemove 127 291' 'mouseclick 1'
    echo clicked connection menu option 
fi



sleep 2
# check for status left bar menu option and click it
md5=$(get_md5 97 297 45 15)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "dd080e7fa8091f7ea8837a95be933790" ] || [ $md5 = "" ]; then

    DISPLAY=:99 xte 'mousemove 120 304' 'mouseclick 1'
    echo clicked status left bar menu option 
fi

sleep 2
# check again for status left bar menu option and click it,  This step only works for tinkerboard s
md5=$(get_md5 103 316 45 15)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "85e18da2ec8eb78ef63f025e4d41b177" ] || [ $md5 = "df5d05cf76ed2fe647bf5e5c1d9c83e7" ]; then

    DISPLAY=:99 xte 'mousemove 125 322' 'mouseclick 1'
    echo clicked status left bar menu option 
fi




sleep 5
# check status of 2.4ghz.  This step only works for tinkerboard s
md5=$(get_md5 792 410 52 11)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "79406c2a8dd1ea693460b2d8f8137701" ] || [ $md5 = "" ]; then
    echo wifi 2.4ghz is inactive 
elif [ $md5 = "211a10da78d346ca83290aeab4438bdd" ] || [ $md5 = "53be3a85237cafae4f5b8bc75b984b45" ]; then
     echo wifi 2.4ghz is active
fi




# check status of 5G
md5=$(get_md5 792 672 52 11)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "8ecb64f0c33d14137c656f0cad5da05b" ] || [ $md5 = "" ]; then
    echo wifi 5G is inactive 

elif [ $md5 = "211a10da78d346ca83290aeab4438bdd" ]; then
     echo wifi 5G is active
fi

# check status of 5G   This works for Tinkerboard S
md5=$(get_md5 792 691 52 11)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "79406c2a8dd1ea693460b2d8f8137701" ] || [ $md5 = "" ]; then
    echo wifi 5G is inactive 

elif [ $md5 = "211a10da78d346ca83290aeab4438bdd" ] || [ $md5 = "53be3a85237cafae4f5b8bc75b984b45" ]; then
     echo wifi 5G is active
fi


DISPLAY=:99 scrot /tmp/test.ppm
sleep 1
DISPLAY=:99 xte 'keydown Control_L' 'str w' 'keyup Control_L'
sleep 2

pkill Xvfb
echo "ok"
