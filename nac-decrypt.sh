#!/bin/bash

# NAC - Nova Arts Cryptor v1.0.1
# NAC ➤ Decrypt (shell script version)

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
ACCOUNT=$(/usr/bin/id -un)
CURRENT_VERSION="1.0.1"

# check compatibility
MACOS2NO=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')
if [[ "$MACOS2NO" -le 7 ]] ; then
	echo "Error! NAC needs at least OS X 10.8 (Mountain Lion)"
	echo "Exiting..."
	INFO=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set userChoice to button returned of (display alert "Error! Minimum OS requirement:" & return & "OS X 10.8 (Mountain Lion)" ¬
		as critical ¬
		buttons {"Quit"} ¬
		default button 1 ¬
		giving up after 60)
end tell
EOT)
	exit
fi

# cache directory
CACHE_DIR="${HOME}/Library/Caches/local.lcars.nac"
if [[ ! -e "$CACHE_DIR" ]] ; then
	mkdir -p "$CACHE_DIR"
fi

# decryption directory
DECRYPT_DIR="$CACHE_DIR/decrypt"
if [[ ! -e "$DECRYPT_DIR" ]] ; then
	mkdir -p "$DECRYPT_DIR"
fi
rm -rf "$DECRYPT_DIR/"* # 2>/dev/null

# decrypted content directory
DEST_DIR="${HOME}/Downloads/NAC"
if [[ ! -e "$DEST_DIR" ]] ; then
	mkdir -p "$DEST_DIR"
fi

# notification function
notify () {
 	if [[ "$NOTESTATUS" == "osa" ]] ; then
		/usr/bin/osascript &>/dev/null << EOT
tell application "System Events"
	display notification "$2" with title "NAC [" & "$ACCOUNT" & "]" subtitle "$1"
end tell
EOT
	elif [[ "$NOTESTATUS" == "tn" ]] ; then
		"$TERMNOTE_LOC/Contents/MacOS/terminal-notifier" \
			-title "NAC [$ACCOUNT]" \
			-subtitle "$1" \
			-message "$2" \
			-appIcon "$ICON_LOC" \
			>/dev/null
	fi
}

# detect/create icon for terminal-notifier and osascript windows
ICON_LOC="$CACHE_DIR/lcars.png"
if [[ ! -f "$ICON_LOC" ]] ; then
	ICON64="iVBORw0KGgoAAAANSUhEUgAAAIwAAACMEAYAAAD+UJ19AAACYElEQVR4nOzUsW1T
URxH4fcQSyBGSPWQrDRZIGUq2IAmJWyRMgWRWCCuDAWrGDwAkjsk3F/MBm6OYlnf
19zqSj/9i/N6jKenaRpjunhXV/f30zTPNzePj/N86q9fHx4evi9j/P202/3+WO47
D2++3N4uyzS9/Xp3d319+p3W6+fncfTnqNx3Lpbl3bf/72q1+jHPp99pu91sfr4f
43DY7w+fu33n4tVLDwAul8AAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATIC
A2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEB
MgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZ
gQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzA
ABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERggIzBARmCA
jMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJARGCAjMEBG
YICMwAAZgQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMw
QEZggIzAABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERgg
IzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJAR
GCAjMEBGYICMwAAZgQEy/wIAAP//nmUueblZmDIAAAAASUVORK5CYII="
	echo "$ICON64" > "$CACHE_DIR/lcars.base64"
	/usr/bin/base64 -D -i "$CACHE_DIR/lcars.base64" -o "$ICON_LOC" && rm -rf "$CACHE_DIR/lcars.base64"
fi
if [[ -f "$CACHE_DIR/lcars.base64" ]] ; then
	rm -rf "$CACHE_DIR/lcars.base64"
fi

# look for terminal-notifier
TERMNOTE_LOC=$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'nl.superalloy.oss.terminal-notifier'" 2>/dev/null | /usr/bin/awk 'NR==1')
if [[ "$TERMNOTE_LOC" == "" ]] ; then
	NOTESTATUS="osa"
else
	NOTESTATUS="tn"
fi

for FILEPATH in "$1" # ALT: "$@"
do

TARGET_NAME=$(/usr/bin/basename "$FILEPATH")

# check image type
TYPE_RAW=$(/usr/bin/file "$FILEPATH" | /usr/bin/awk -F": " '{print $2}')
TYPE=$(echo "$TYPE_RAW" | /usr/bin/awk -F" " '{print $1}')
if [[ "$TYPE" != "PNG" ]] && [[ "$TYPE" != "JPEG" ]] && [[ "$TYPE" != "GIF" ]] && [[ "$TYPE" != "TIFF" ]] ; then
	EXTENSION="${TARGET_NAME##*.}"
	if [[ "$EXTENSION" == "" ]] ; then
		EXTENSION="n/a"
	fi
	notify "Error: $EXTENSION" "Format not compatible"
	exit # ALT: continue
fi

# read info
INFO=$(/usr/bin/tail -n 6 "$FILEPATH" | /usr/bin/awk '/-----END INFO-----/{f=0} f; /-----BEGIN INFO-----/{f=1}')
if [[ "$INFO" == "" ]] ; then
	notify "Error: no NAC data" "$TARGET_NAME"
	exit # ALT: continue
fi

# enter decryption password
PW_RETURN="false"
until [[ "$PW_RETURN" == "true" ]]
do
	# first input or choose random
	PW_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.nac:lcars.png"
	set {thePassword, theButton} to {text returned, button returned} of (display dialog "Enter the passphrase that was used to encrypt the original file or folder." ¬
		with hidden answer ¬
		default answer "" ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		with title "NAC: " & "$TARGET_NAME" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
thePassword & "@DELIM@" & theButton
EOT)
	if [[ "$PW_CHOICE" == "" ]] || [[ "$PW_CHOICE" == "false" ]] || [[ "$PW_CHOICE" == "@DELIM@" ]] ; then
		BREAKER="true"
		PW_RETURN="true"
		continue
	fi
	BUTTON=$(echo "$PW_CHOICE" | /usr/bin/awk -F"@DELIM@" '{print $2}')
	PASSPHRASE=$(echo "$PW_CHOICE" | /usr/bin/awk -F"@DELIM@" '{print $1}')
	if [[ "$BUTTON" == "Enter" ]] && [[ "$PASSPHRASE" == "" ]] ; then
		notify "Input error" "No passphrase"
		continue
	fi
	if [[ "$BUTTON" == "Enter" ]] && [[ "$PASSPHRASE" != "" ]] ; then
		PW_RETURN="true"
		continue
	fi
done
if [[ "$BREAKER" == "true" ]] ; then
	exit # ALT: continue
fi

# notify
notify "Please wait!" "Decrypting original file…"

# determine data information
CRTYPE=$(echo "$INFO" | /usr/bin/grep "type=" | /usr/bin/awk -F"=" '{print $2}')
OFFSET=$(echo "$INFO" | /usr/bin/grep "offset=" | /usr/bin/awk -F"=" '{print $2}')

# read encrypted data
/usr/bin/tail -n $OFFSET "$FILEPATH" | /usr/bin/awk '/-----END DATA-----/{f=0} f; /-----BEGIN DATA-----/{f=1}' > "$DECRYPT_DIR/target.aes"
AES_CHECKSUM1=$(echo "$INFO" | /usr/bin/grep "sha-aes=" | /usr/bin/awk -F"=" '{print $2}')
AES_CHECKSUM2=$(/usr/bin/shasum -a 256 "$DECRYPT_DIR/target.aes" | /usr/bin/awk '{print $1}')
if [[ "$AES_CHECKSUM2" != "$AES_CHECKSUM1" ]] ; then
	notify "Steg error" "Checksums don't match"
	rm -rf "$DECRYPT_DIR/"*
	exit # ALT: continue
fi

# decrypt
DECRYPT=$(/usr/bin/openssl enc -aes-256-cbc -a -d -salt -pass pass:"$PASSPHRASE" -in "$DECRYPT_DIR/target.aes" -out "$DECRYPT_DIR/target.tbz" 2>&1)
if [[ "$DECRYPT" != "" ]] ; then
	if [[ $(echo "$DECRYPT" | /usr/bin/grep "bad decrypt") != "" ]] ; then
		notify "Decryption error" "Wrong password?"
	else
		notify "Decryption error" "$TARGET_NAME"
	fi
	echo "$DECRYPT"
	rm -rf "$DECRYPT_DIR/"*
	exit # ALT: continue
fi
TBZ_CHECKSUM1=$(echo "$INFO" | /usr/bin/grep "sha-tbz=" | /usr/bin/awk -F"=" '{print $2}')
TBZ_CHECKSUM2=$(/usr/bin/shasum -a 256 "$DECRYPT_DIR/target.tbz" | /usr/bin/awk '{print $1}')
if [[ "$TBZ_CHECKSUM2" != "$TBZ_CHECKSUM1" ]] ; then
	notify "Decryption error" "Checksums don't match"
	rm -rf "$DECRYPT_DIR/"*
	exit # ALT: continue
fi

# decompress
DECOMPRESS=$(/usr/bin/tar -jxvf "$DECRYPT_DIR/target.tbz" -C "$DEST_DIR" 2>&1)
if [[ $(echo "$DECOMPRESS" | /usr/bin/grep "tar: ") != "" ]] ; then
	echo "$DECOMPRESS"
	notify "Decompression error" "$TARGET_NAME"
	rm -rf "$DECRYPT_DIR/"*
	exit # ALT: continue
fi

rm -rf "$DECRYPT_DIR/"*
open "$DEST_DIR"

done

# check for update
NEWEST_VERSION=$(/usr/bin/curl --silent https://api.github.com/repos/JayBrown/NAC-Nova-Arts-Cryptor/releases/latest | /usr/bin/awk '/tag_name/ {print $2}' | xargs)
if [[ "$NEWEST_VERSION" == "" ]] ; then
	NEWEST_VERSION="0"
fi
NEWEST_VERSION=${NEWEST_VERSION//,}
if (( $(echo "$NEWEST_VERSION > $CURRENT_VERSION" | /usr/bin/bc -l) )) ; then
	notify "Update available" "NAC v$NEWEST_VERSION"
	/usr/bin/open "https://github.com/JayBrown/NAC-Nova-Arts-Cryptor/releases/latest"
fi

exit # ALT: delete
