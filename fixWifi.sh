#!/usr/bin env bash

repo="https://github.com/lwfinger/rtlwifi_new"

checkGit() {
  if git --version  &> /dev/null; then
    echo "Git found"
  else
    echo "Git not found"
  fi
}

installGit() {
  echo "Installing git\n"
  sudo apt-get install git >> /dev/null
}

cloneRepo() {
  echo "Downloading latest drivers from $repo"
  if git clone $repo /tmp/rtlwifi_new_$$; then
    echo "Drivers downloaded successfully"
  else
    echo "Download couldn't be completed. Exiting"
    exit 1
  fi
}

installDrivers() {
  cd /tmp/rtlwifi_new_$$ || (echo "Drivers not found"; exit 1)
  echo "Building drivers"
  if make && sudo make install; then
    echo "Drivers built successfully"
  else
    echo "Drivers couldn't be built. Exiting"
    exit 1
  fi
}
configureWiFi() {
  echo "Configuring the WiFi settings"
  cd $1
  if (cat ./rtl8723be.conf  | sudo tee /etc/modprobe.d/rtl8723be.conf); then
    echo "WiFi settings configured"
  else
    echo "Wifi settings couldn't be configured"
  fi
}

restartWiFi() {
  echo "Restarting WiFi"
  if sudo modprobe -r rtl8723be && sudo modprobe rtl8723be; then
    echo "WiFi restarted"
  else
    echo "Couldn't restart WiFi"
  fi
}

echo "Fixing Wifi"
checkGit || installGit
cloneRepo
installDrivers
configureWiFi
restartWiFi
echo "Your WiFi is fixed. Enjoy!"
echo "If this doen't help, try changing rtl8723be.conf and repeating the process"
exit 0