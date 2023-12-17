#!/bin/bash

# By : Ayoub Bablil
# Feel free to change anything you want ;)
# Big thanks to bleach : https://github.com/Ra-Wo/bleach_42

# colors
RED='\033[0;31m'
NO_COLOR='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
BGREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'

# ------------------------------- SPECIFY YOUR CONFIG HERE ------------------------------------------------
THEME="dark" # "dark" or "light"
SYSTEM_APPS=("Visual Studio Code")
USER_APPS_PATH="/Applications/" # don't change this :)
USER_APPS=("Brave Browser" "Discord" "Spotify") # open applications path on your terminal to get apps names
WALLPAPER_PATH="" # keep this empty if you don't want to change the wallpaper
# ---------------------------------------------------------------------------------------------------------

clear_dock()
{
    echo -e "\n${YELLOW}> Clearing dock...${NO_COLOR}"
    defaults write "com.apple.dock" "persistent-apps" -array
    killall Dock
    echo -e "${GREEN}✅ Done!${NO_COLOR}"
    sleep 1
}

add_dock_apps(){
    echo -e "\n${YELLOW}> Adding apps to dock...${NO_COLOR}"

    for app in "${SYSTEM_APPS[@]}"; do
        if [[ -d "/Applications/$app.app" ]]; then
            app_path="/Applications/$app.app"
            echo -e "${GREEN}✅ $app added to dock${NO_COLOR}"
        elif [[ -d "/System/Applications/$app.app" ]]; then
            app_path="/System/Applications/$app.app"
        else
            echo -e "${RED}❌ $app is not installed${NO_COLOR}"
            continue
        fi
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app_path</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    done

    for app in "${USER_APPS[@]}"; do
        if [[ -d "$USER_APPS_PATH$app.app" ]]; then
            echo -e "${GREEN}✅ $app added to dock${NO_COLOR}"
            app_path="$USER_APPS_PATH$app.app"
            defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app_path</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
        else
            echo -e "${RED}❌ $app is not installed${NO_COLOR}"
        fi
    done

    sleep 1
    killall Dock
}

open_apps(){
    echo -e "${YELLOW}> Opening apps...${NO_COLOR}"
    for app in "${SYSTEM_APPS[@]}"; do
        if [[ -d "/Applications/$app.app" ]]; then
            echo -e "${GREEN}✅ $app opened${NO_COLOR}"
            open -a "$app"
        elif [[ -d "/System/Applications/$app.app" ]]; then
            echo -e "${GREEN}✅ $app opened${NO_COLOR}"
            open -a "$app"
        else
            echo -e "${RED}❌ $app is not installed${NO_COLOR}"
        fi
    done

    for app in "${USER_APPS[@]}"; do
        if [[ -d "$USER_APPS_PATH$app.app" ]]; then
            echo -e "${GREEN}✅ $app opened${NO_COLOR}"
            open -a "$app"
        else
            echo -e "${RED}❌ $app is not installed${NO_COLOR}"
        fi
    done
    sleep 1
}

set_system_theme(){
    if [[ $1 == "dark" ]]; then
        echo -e "\n${YELLOW}> Setting system theme to dark mode...${NO_COLOR}"
        osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'
        echo -e "${GREEN}✅ System theme set${NO_COLOR}"
    elif [[ $1 == "light" ]]; then
        echo -e "${YELLOW}> Setting system theme to light mode...${NO_COLOR}"
        osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to false'
        echo -e "${GREEN}✅ System theme set${NO_COLOR}"
    else
        echo -e "${RED}❌ Invalid theme: $1${NO_COLOR}"
    fi
    sleep 1
}

set_wallpaper()
{
    if [[ -z "$WALLPAPER_PATH" ]]; then
        return
    fi
    echo -e "${YELLOW}> Setting wallpaper...${NO_COLOR}"
    
    echo "❗ Please allow the permission to change the wallpaper"
    
    if [[ -f "$WALLPAPER_PATH" ]]; then
        osascript -e 'tell application "Finder" to set desktop picture to POSIX file "'"$WALLPAPER_PATH"'"'
        echo -e "${GREEN}✅ Wallpaper set${NO_COLOR}"
    else
        echo -e "${RED}❌ $WALLPAPER_PATH does not exist or is not a file${NO_COLOR}"
    fi
    sleep 1
}

check_storage() 
{
    local when=$1

    STORAGE=$(df -h "$HOME" | grep "$HOME" | awk '{print($4)}' | tr 'i' 'B')
    
    if [ "$STORAGE" == "0BB" ]; then
        STORAGE="0B"
    fi

    if [ "$when" == "before" ]; then
        echo -e "${GREEN}✅ Storage before cleaning : ${STORAGE}"
    elif [ "$when" == "after" ]; then
        echo -e "${GREEN}✅ Storage after cleaning : ${STORAGE}"
    else
        echo "Invalid value for 'when'. Use 'before' or 'after'."
    fi
}

cleaning_device()
{
    echo -e "\n${YELLOW}> Cleaning your device...${NO_COLOR}"

    check_storage "before"

    /bin/rm -rf ~/Library/*.42* &>/dev/null
    /bin/rm -rf ~/*.42* &>/dev/null
    /bin/rm -rf ~/.zcompdump* &>/dev/null
    /bin/rm -rf ~/.cocoapods.42_cache_bak* &>/dev/null

    /bin/rm -rf ~/Library/Caches/* &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/Caches/* &>/dev/null

    /bin/rm -rf ~/Library/Application\ Support/Slack/Service\ Worker/CacheStorage/* &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/Code/User/workspaceStorage/* &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/discord/Cache/* &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/discord/Code\ Cache/js* &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/Google/Chrome/Profile\ [0-9]/Service\ Worker/CacheStorage/* &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Service\ Worker/CacheStorage/* &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/Google/Chrome/Profile\ [0-9]/Application\ Cache/* &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/Google/Chrome/Default/Application\ Cache/* &>/dev/null

    find ~/Desktop -name .DS_Store -depth -exec /bin/rm {} \; &>/dev/null

    /bin/rm -rf ~/Library/Application\ Support/Chromium/Default/File\ System &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/Chromium/Profile\ [0-9]/File\ System &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/Google/Chrome/Default/File\ System &>/dev/null
    /bin/rm -rf ~/Library/Application\ Support/Google/Chrome/Profile\ [0-9]/File\ System &>/dev/null

    /bin/rm -rf ~/Desktop/Piscine\ Rules\ *.mp4
    /bin/rm -rf ~/Desktop/PLAY_ME.webloc

    check_storage "after"

    sleep 1
}

initApp(){
	echo -e "\033c"
    echo -e "${BLUE}--------------- 1337 / 42 Launcher - By : Ayoub Bablil  ---------------${NO_COLOR}"
}

exitApp(){
    echo -e "\n\n${GREEN}✅ All Done!${NO_COLOR}"
    echo -e "${BLUE}-----------------------------------------------------------------------${NO_COLOR}"
    exit
}

initApp
open_apps
clear_dock
add_dock_apps
set_system_theme $THEME
set_wallpaper
cleaning_device
exitApp