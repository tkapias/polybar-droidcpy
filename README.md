# droidcpy
**A [Polybar](https://github.com/polybar/polybar) script** to control your **Android device remote control services**. Handling, Mirror display, Audio, Webcam. Using scrcpy, sndcpy and v4l2loopback with IP Webcam.


![image](https://user-images.githubusercontent.com/45816387/161807714-bcdeffbe-2a5b-4923-8e07-8b684e884d0b.png)

![image](https://user-images.githubusercontent.com/45816387/161813431-e4631644-30f6-40b0-a0e5-4026cdaf380a.png)


> The configurations proposed by this repository are **not adapted to all operating systems or easily customized** without reading some code.
> It is **dedicated to advanced Android/Linux** users who run at least **Polybar and Systemd**, ideally i3wm too.
> 
> You can use the Systemd services individually with any other launcher too.


## Features

  - Display a **panel with 3 icons/controls** on the status bar, **when the Android device is connected** on USB.
    - Launch a **remote screen/mouse/keyboard** control with [scrcpy](https://github.com/Genymobile/scrcpy).
    - Launch a **remote sound forwarding** with [sndcpy](https://github.com/rom1v/sndcpy).
    - Launch an **IP webcam** device using your smartphone as a camera with [v4l2loopback](https://github.com/umlaeute/v4l2loopback) and [IP Webcam Pro/Lite](https://play.google.com/store/apps/details?id=com.pas.webcam.pro).
  - A left-click **Stop/start** the services cleanly with the same icon.
  - The **status** of the device and services is **displayed graphically**.
    - The panel check if the device is connected to ADB and finished booting, if the **device is disconnected the panel is hidden**.
    - Icons **displays the current status** of the services by their color: activated, failed, stopped.
    - The **background** of the Panel is **Green** if any service is Activated.
      - **Or Red** if a service is still activated or failed when the device is not ready.


## Limitations

  - My testing device was rooted and runs on Android 11, but it should work **without root** and **at least from Android 10**.
  - Clicking on a failed service try to start it again, not to stop it.
  - If you **disconnect the device** while a service was running, it **may not stop but switch to failed**, you will have to reconnect the device and start/stop cleanly before disconnecting again. Or the Red icon will stay visible.
  - I choose to limit the bitrate (2M) and the resolution (1024) in the parameters to get the best perfs, you can tweak the exec command in the systemd service files.
  - On some device the orientation of the Webcam may be wrong, you can change those settings in the IP Webcam app or in the systemd service file.
  - As it was a quick project and the scripts are commented, I did not centralize options, device name or output colors. **There is no central ENV or attributes**, you wil have to find it in the code.
  - The scripts are **not written to work when there is more than 1 device connected on ADB**. And **you have to specify the name of your device** in the script, or use a wildcard, but then any adb device will show the panel.
  - I did not find any good open source solution for the IP webcam application on Android, it's possible to use [Open Camera](https://github.com/almalence/OpenCamera) with scrcpy and v4l2loopback to forward the picture from the screen but it's more limited. But [IP Webcam Pro](https://play.google.com/store/apps/details?id=com.pas.webcam.pro) seems to be a clean and serious application.


## Requirements

  - [scrcpy](https://github.com/Genymobile/scrcpy): display and control of Android devices connected via USB.
    - On Debian and Ubuntu: `apt install scrcpy`
    - On Arch Linux: `pacman -S scrcpy`
    - Make sure you [enabled adb debugging](https://developer.android.com/studio/command-line/adb.html#Enabling) on your device.
  - [sndcpy.apk](https://github.com/rom1v/sndcpy): audio forwarding of Android devices connected via USB.
    - You need only the APK from [release 1.1](https://github.com/rom1v/sndcpy/releases/download/v1.1/sndcpy-v1.1.zip)
    - Install the sndcpy.apk to your device manually or by droping it in [scrcpy file drop](https://github.com/Genymobile/scrcpy#file-drop).
    - polybar-droidcpy use ffplay from the Ffmpeg package, instead of vlc:
      - On Debian and Ubuntu: `apt install ffmpeg`
      - On Arch Linux: `pacman -S ffmpeg`
  - [v4l2loopback](https://github.com/umlaeute/v4l2loopback): kernel module to create V4L2 loopback devices.
    - On Debian and Ubuntu: `apt install v4l2loopback-dkms`
    - On Arch Linux: `pacman -S v4l2loopback-dkms`
    - Create a first loopback device (/dev/video0): `sudo modprobe v4l2loopback`
    - To load the device after reboot add a new file to your system, 
      - with the content "v4l2loopback": `sudo echo "v4l2loopback > "/etc/modules-load.d/v4l2loopback.conf`
  - [IP Webcam Pro](https://play.google.com/store/apps/details?id=com.pas.webcam.pro): turns your phone into a network camera.
    - I use the Pro version but it should work with the [Lite version](https://play.google.com/store/apps/details?id=com.pas.webcam) too.
    - I changed some settings in the app manually:
      - Video Preferences/Main caméra: Frontal
      - Video Preferences/Resolution: 1280x720
      - Video Preferences/Quality: 80
      - Video Preferences/Orientation: Landscape
      - Local Sharing/Port: 8082 (used in systemd config)
      - Audio Mode: Disabled
  - [ADB] Google/Android useful tool for debugging android devices:
    - On Debian and Ubuntu: `apt install android-tools-adb`
    - On Arch Linux: `pacman -S android-tools`
    - Check if you see you device : `adb devices -l`
  - [Polybar](https://github.com/polybar/polybar): beautiful and highly customizable status bars.
    - On Debian and Ubuntu: `apt install polybar`
    - On Arch Linux: `pacman -S polybar`
    - Incorporate this script as a module in one of your bars.
  - [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts): Nerd Fonts takes popular programming fonts and adds a bunch of Glyphs.
    - polybar-droidcpy use icons provided by a Nerd Font, you need at any of them, or to modify the icons in [polybar/scripts/droidcpy.sh](https://github.com/tkapias/polybar-droidcpy/blob/main/polybar/scripts/droidcpy.sh).
  - [Systemd](https://www.freedesktop.org/software/systemd/man/systemd.service.html): system and service manager for Linux operating systems.
    - Your desktop operating system probably works on this manager. If not, it's complicated to install it.

### Optional

  - [i3wm](https://github.com/i3/i3): a tiling window manager for X11.
    - It's not mandatory but use a fork with more features: [i3wm-gaps](https://github.com/Airblader/i3)


## Installation

  - Check all the [Requirements](#requirements).
  - **Copy polybar-droidcpy's repo** on your machine: 
    ```shell
    cd /tmp
    git clone https://github.com/tkapias/polybar-droidcpy.git
    cd polybar-droidcpy
    ```
  - **Add the systemd services to your user:**
    ```shell
    cp systemd/user/* ~/.config/systemd/user/
    mkdir ~/.logs
    systemctl --user daemon-reload
    systemctl --user status scrcpy.service sndcpy.service v4l2-ipwebcam.service
    ```
  - **Copy the Polybar droidcpy script** to your config directory:
    ```shell
    mkdir ~/.config/polybar/scripts/
    cp polybar/scripts/droidcpy.sh ~/.config/polybar/scripts/
    ```
  - **Change the name of your device** (variable my_device="") **in the script** (~/.config/polybar/scripts/droidcpy.sh).
    - You can find the name here: `adb devices -l`
  - **Add droidcpy to your Polybar** config.ini:
    - New module section:
      ```
      [module/droidcpy]
      type   = custom/script
      exec   = ~/.config/polybar/scripts/droidcpy.sh
      tail   = false
      ```
    - Add it to one of your bars section, example:
      ```
      [bar/base]
      modules-left = droidcpy
      ```
    - **Reload your Polybar**.
  - **If you use i3wm**, add some rules for scrcpy, example:
    ```shell
    # assign the program to workspace 3, because I use "set $ws3 number 3"
    assign [class="scrcpy"] $ws3
    
    # force no borders and a floating window for scrpy
    for_window [class=".*"] border pixel 0
    for_window [class="scrcpy"] floating enable
    ```
    - **Reload your i3wm**.


## Acknowledgements

  - Thanks to [Nitin Rai](https://github.com/imneonizer) for his [original script idea and some adb commands](https://github.com/imneonizer/android-webcam).
  - Thanks to [Romain Vimont](https://github.com/rom1v) for his [sndcpy](https://github.com/rom1v/sndcpy) APK which has no comparable alternative at present.
