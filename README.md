# mac_address_changer
AUTOMATIC MAC ADDRESS CHANGER macOS High Sierra (10.13+)

--------------------------------
##1. INSTALL THE SCRIPT
--------------------------------

Open Terminal and run:
```
sudo mkdir -p /usr/local/bin
sudo cp change_mac.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/change_mac.sh
```
Verify:
ls -l /usr/local/bin/change_mac.sh

Expected permissions:
-rwxr-xr-x


--------------------------------
2. INSTALL LAUNCHDAEMON
--------------------------------

Copy the plist file:

sudo cp com.user.macchanger.plist /Library/LaunchDaemons/

Set correct permissions:

sudo chown root:wheel /Library/LaunchDaemons/com.user.macchanger.plist
sudo chmod 644 /Library/LaunchDaemons/com.user.macchanger.plist


--------------------------------
3. START THE SERVICE
--------------------------------

Load the daemon:

sudo launchctl load /Library/LaunchDaemons/com.user.macchanger.plist

Check status:

sudo launchctl list | grep macchanger


--------------------------------
4. VERIFY OPERATION
--------------------------------

Check current MAC address:

ifconfig en0 | grep ether

Run manual test (without waiting for the interval):

sudo /usr/local/bin/change_mac.sh

View log:

sudo tail -f /var/log/mac_changer.log


--------------------------------
5. SERVICE MANAGEMENT
--------------------------------

Stop the service:
sudo launchctl unload /Library/LaunchDaemons/com.user.macchanger.plist

Start again:
sudo launchctl load /Library/LaunchDaemons/com.user.macchanger.plist

Remove completely:
sudo launchctl unload /Library/LaunchDaemons/com.user.macchanger.plist
sudo rm /Library/LaunchDaemons/com.user.macchanger.plist
sudo rm /usr/local/bin/change_mac.sh
sudo rm /var/log/mac_changer*.log


--------------------------------
IMPORTANT NOTES
--------------------------------

• The MAC address changes at system startup and then periodically (default: every hour).
• Wi‑Fi will be temporarily disabled for a few seconds during the change.
• If the service is disabled, the original hardware MAC will be restored after reboot.
• If your Wi‑Fi interface is not en0, find it using:

networksetup -listallhardwareports
