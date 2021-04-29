#!/bin/sh


###############################
##  enable-wifi-cox-vivaldi_on_r4pi.sh  
###############################
#  This sh script takes no arguments and says whether the wifi, both
#  2.4ghz and 5G, are active or inactive.
#
#  To do this computer on which the script runs must be in the same
#  LAN as the Cox Panoramic Wifi Gateway router, which has an ip of
#  192.168.0.1, and the router_password for the router must be typed
#  into this script since it has to log into the router via the web
#  interface.  The panoramic router that Cox provides is the only
#  router I know of that actually makes you log in just to see the
#  wifi status
#
#  The screen shots of each step of the process of enabling or
#  disabling the wifi are optionally saved to the tmp directory.  

#  Warning: oh yeah, back up all vivaldi settings before using this
#  script, as it will hose all bookmarks and site data, including
#  passwords.

#  Requirements: linux, xvfb, xautomation, scrot 0.8-18+, vivaldi,
#  Imagemagick (for optionally outputting screenshots), gcc (to
#  optionally compile the enclosed c programs provided for marking up
#  screen shots)

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


sleep 5
# check to see if vivaldi is being started for the very first time, in which case restart it
md5=$(get_md5 254 52 130 15)
echo $md5
if [ $md5 = "be87917ac5fba0c604eddbf1e42607a7" ]; then
    echo killing vivaldi and restarting
    xte 'keydown Control_L' 'str wwwwq' 'keyup Control_L'
    sleep 3
    pkill Xvfb
    sleep 2
    Xvfb :99 -fbdir /tmp &
    sleep 2 
    DISPLAY=:99 $wwwbrowser --user-data-dir=/tmp/temp-disk-cache-dir --disk-cache-dir=/tmp/temp-disk-cache-dir --disk-cache-size=104857600 --profile-directory="Profile 2" 192.168.0.1 &
    sleep 15

# reset zoom if applied
DISPLAY=:99 xte 'keydown Control_L' 'str 0' 'keyup Control_L' 
sleep 1

fi



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


# check for default browser again, on r4pi32 it is in a different location

md5=$(get_md5 455 96 140 20)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "6281cdc4d7f92b8e0edafdf64a76edca" ]; then
    echo Chrome isnt your default browser
    sleep 3
    
    # check to see if the checkbox to ask to set default browser is checked
    md5=$(get_md5 462 163 12 12)
    if [ $output_screenshots = 1 ]; then
	echo $step - $md5; step=$(($step + 1))
    fi


    if [ $md5 = "7e207ae740e4d803d6226922dfb7adcf" ]; then
	echo ask default browser Check on startup checkbox is checked
    fi
    # DISPLAY=:99 xte 'mousemove 461 102' mouseclick 1'  # check on startup checkbox
    # DISPLAY=:99 xte 'mousemove 510 210' 'mouseclick 1'  # Set as Default button
    DISPLAY=:99 xte 'mousemove 625 210' 'mouseclick 1'  'sleep 1' # cancel button
       
fi
       
#debug    
# check to see if login/password are empty with focus on neither login nor password textboxes, and if so enter them
md5=$(get_md5 281 300 260 60)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "de67310869080d47f8267b84454a7877" ]; then
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

if [ $md5 = "15ab2216947d6533c99a844f2a7f0adc" ] || [ $md5 = "1fb3a57b9d48a2c2b7f47606635fee97" ]; then
    # incorrect password for admin
  #  DISPLAY=:99 xte 'mousemove  500 190' 'mouseclick 1'
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
# check again for save password in a different location?
md5=$(get_md5 823 255 133 18)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "aacc9d92b798b9258bbdaf0ecfb03fad" ] ; then
    # save password prompt is here, lets click save
    
    # DISPLAY=:99 xte  'mousemove 1080 394' 'mouseclick 1' # save button
    
    # DISPLAY=:99 xte 'mousemove 990 394' 'mouseclick 1'  # never button
    DISPLAY=:99 xte 'mousemove 1115 95' 'mouseclick 1'  # x (dont save but close prompt)
    echo clicked x to close the save password prompt, without saving password 

fi


sleep 5
# check for connection left bar menu option and click it
md5=$(get_md5 202 270 90 12)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "b167d9c5cad09312c813d3d5b1ee847e" ] || [ $md5 = "56f496eadd2297226e52b74702beb994" ] || [ $md5 = "0d4be742c114f4653d5f46f78ac61bdb" ] || [ $md5 = "7900df076dadc306ea68c55e193d2d7e" ]; then
    DISPLAY=:99 xte 'mousemove 247 276' 'mouseclick 1'
    echo clicked connection menu option 
fi


sleep 2
# check for status left bar menu option and click it
md5=$(get_md5 225 300 45 15)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "c0b19ce85475614a893da9c1252d7f80" ] || [ $md5 = "c129eecf83ad6439306266b7123ea1ed" ] || [ $md5 = "785d0386ef4c4dd953d86f6c57bc06cd" ]; then
    DISPLAY=:99 xte 'mousemove 250 307' 'mouseclick 1'
    echo clicked wifi left bar menu option 
fi



sleep 5
# check status of 2.4ghz
md5=$(get_md5 914 395 52 11)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "8ecb64f0c33d14137c656f0cad5da05b" ] || [ $md5 = "4f7aad1839d28025b1f8435cff3f74f6" ]; then
    echo wifi 2.4ghz is inactive 
elif [ $md5 = "211a10da78d346ca83290aeab4438bdd" ] || [ $md5 = "6993c78a121380d012deb3c2af1df6a0" ]; then
     echo wifi 2.4ghz is active
fi

# check status of 5G
md5=$(get_md5 914 676 52 11)
if [ $output_screenshots = 1 ]; then
echo $step - $md5; step=$(($step + 1))
fi

if [ $md5 = "8ecb64f0c33d14137c656f0cad5da05b" ] || [ $md5 = "4f7aad1839d28025b1f8435cff3f74f6" ]; then
    echo wifi 5G is inactive 

elif [ $md5 = "211a10da78d346ca83290aeab4438bdd" ] || [ $md5 = "6993c78a121380d012deb3c2af1df6a0" ]; then
     echo wifi 5G is active
fi

DISPLAY=:99 scrot /tmp/test.ppm

sleep 1
DISPLAY=:99 xte 'keydown Control_L' 'str wq' 'keyup Control_L'
sleep 2

pkill Xvfb
