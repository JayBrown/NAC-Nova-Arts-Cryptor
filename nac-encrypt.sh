#!/bin/bash

# NAC - Nova Arts Cryptor v1.0.1
# NAC ➤ Encrypt (shell script version)

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
ACCOUNT=$(/usr/bin/id -un)
CURRENT_VERSION="1.01"

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

# encryption directory
CRYPT_DIR="$CACHE_DIR/crypt"
if [[ ! -e "$CRYPT_DIR" ]] ; then
	mkdir -p "$CRYPT_DIR"
fi
rm -rf "$CRYPT_DIR/"*

# pictures directory
IMG_DIR="${HOME}/Pictures/NAC"
if [[ ! -e "$IMG_DIR" ]] ; then
	mkdir -p "$IMG_DIR"
fi
DEST_DIR="$IMG_DIR/encrypted"
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

# detect/create Apple/ThinkDifferent image
ATD_LOC="$IMG_DIR/Apple-ThinkDifferent.png"
if [[ ! -f "$ATD_LOC" ]] ; then
	ATD64="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
AABJRU5ErkJggg=="
	echo "$ATD64" > "$IMG_DIR/atd.base64"
	/usr/bin/base64 -D -i "$IMG_DIR/atd.base64" -o "$ATD_LOC" && rm -rf "$IMG_DIR/atd.base64"
fi
if [[ -f "$IMG_DIR/atd.base64" ]] ; then
	rm -rf "$IMG_DIR/atd.base64"
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
TARGET_PARENT=$(/usr/bin/dirname "$FILEPATH")

# choose image file
IMG_RETURN=""
BREAKER=""
until [[ "$IMG_RETURN" == "true" ]]
do
	IMG_LOC=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theDirectory to "$IMG_DIR" as string
	set anImage to choose file with prompt "Choose the image file that will hide your target…" default location theDirectory of type {"public.jpeg", "com.compuserve.gif", "public.png", "public.tiff"} without invisibles
	set theImagePath to (POSIX path of anImage)
end tell
theImagePath
EOT)
	if [[ "$IMG_LOC" == "" ]] || [[ "$IMG_LOC" == "false" ]] ; then
		BREAKER="true"
		IMG_RETURN="true"
		continue
	fi
	# check for previous steg
	INFO=$(/usr/bin/tail -n 6 "$IMG_LOC" | /usr/bin/grep "END INFO")
	if [[ "$INFO" != "" ]] ; then
		notify "Steg error" "Image already contains NAC data"
		continue
	fi
	# check image type
	TYPE_RAW=$(/usr/bin/file "$IMG_LOC" | /usr/bin/awk -F": " '{print $2}')
	TYPE=$(echo "$TYPE_RAW" | /usr/bin/awk -F" " '{print $1}')
	if [[ "$TYPE" == "PNG" ]] ; then
		TYPE="png"
	elif [[ "$TYPE" == "JPEG" ]] ; then
		TYPE="jpg"
	elif [[ "$TYPE" == "GIF" ]] ; then
		TYPE="gif"
	elif [[ "$TYPE" == "TIFF" ]] ; then
		TYPE="tif"
	else
		notify "Internal error!" "Image format not recognized"
		continue
	fi
	IMG_RETURN="true"
done
if [[ "$BREAKER" == "true" ]] ; then
	exit # ALT: continue
fi

# check for correct extension
IMG_BASENAME=$(/usr/bin/basename "$IMG_LOC")
if [[ "$IMG_BASENAME" != *".$TYPE" ]] ; then
	if [[ "$IMG_BASENAME" == *".tiff" ]] || [[ "$IMG_BASENAME" == *".jpeg" ]] ; then
		IMG_BASENAME="${IMG_BASENAME%.*}"
	fi
	IMG_NAME="$IMG_BASENAME"
	IMG_BASENAME="$IMG_BASENAME.$TYPE"
else
	IMG_NAME="${IMG_BASENAME%.*}"
fi

# choose random password or input manually (double input)
PW_RETURN="false"
BREAKER=""
until [[ "$PW_RETURN" == "true" ]]
do
	# first input or choose random
	PW_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.nac:lcars.png"
	set {thePassword, theButton} to {text returned, button returned} of (display dialog "Enter the encryption passphrase for your target file or create a random passphrase. The passphrase will be copied to your clipboard." ¬
		with hidden answer ¬
		default answer "" ¬
		buttons {"Cancel", "Random", "Enter"} ¬
		default button 3 ¬
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
	if [[ "$BUTTON" == "Random" ]] ; then
		# create random password
		PASSPHRASE=$(/usr/bin/openssl rand -base64 47 | /usr/bin/tr -d /=+ | /usr/bin/cut -c -32)
		PW_RETURN="true"
		continue
	fi
	FIRST_PW=$(echo "$PW_CHOICE" | /usr/bin/awk -F"@DELIM@" '{print $1}')
	if [[ "$BUTTON" == "Enter" ]] && [[ "$FIRST_PW" == "" ]] ; then
		notify "Input error" "No passphrase"
		continue
	fi

	# input a second time
	SECOND_PW=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.nac:lcars.png"
	set thePassword to text returned of (display dialog "Enter the encryption passphrase again." ¬
		with hidden answer ¬
		default answer "" ¬
		buttons {"Enter"} ¬
		default button 1 ¬
		with title "NAC: " & "$TARGET_NAME" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
thePassword
EOT)
	if [[ "$SECOND_PW" == "" ]] ; then
		notify "Input error" "No passphrase"
		continue
	fi
	if [[ "$SECOND_PW" == "$FIRST_PW" ]] ; then
		PASSPHRASE="$SECOND_PW"
		PW_RETURN="true"
		continue
	else
		notify "Input error" "Passphrases don't match"
		continue
	fi
done
if [[ "$BREAKER" == "true" ]] ; then
	exit # ALT: continue
fi

# choose new name for the steg image
OV_RETURN=""
BREAKER=""
until [[ "$OV_RETURN" == "true" ]]
do
	IMG_NAMING=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.nac:lcars.png"
	set {theNaming, theBaseName} to {button returned, text returned} of (display dialog "Enter the new name for the encrypted image." ¬
		default answer "$IMG_BASENAME" ¬
		buttons {"Cancel", "Enter & Append Date", "Enter"} ¬
		default button 3 ¬
		with title "NAC: " & "$TARGET_NAME" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theNaming & "@@@" & theBaseName
EOT)
	if [[ "$IMG_NAMING" == "" ]] || [[ "$IMG_NAMING" == "false" ]] || [[ "$IMG_NAMING" == "@@@" ]] ; then
		BREAKER="true"
		OV_RETURN="true"
		break
	fi
	NAMING=$(echo "$IMG_NAMING" | /usr/bin/awk -F"@@@" '{print $1}')
	DEST_NAME=$(echo "$IMG_NAMING" | /usr/bin/awk -F"@@@" '{print $2}')
	if [[ "$DEST_NAME" == "" ]] || [[ "$IMG_NAME" == "."* ]] ; then
		DEST_NAME="$IMG_BASENAME"
	fi
	if [[ "$NAMING" == "Enter & Append Date" ]] ; then
		APPDATE=$(/bin/date "+%Y%m%d")
		if [[ "$DEST_NAME" != *".$TYPE" ]] ; then
			DEST_NAME="$DEST_NAME-$APPDATE.$TYPE"
		else
			DEST_NAME="${DEST_NAME//.$TYPE}-$APPDATE.$TYPE"
		fi
	elif [[ "$NAMING" == "Enter" ]] ; then
		if [[ "$DEST_NAME" != *".$TYPE" ]] ; then
			DEST_NAME="$DEST_NAME.$TYPE"
		fi
	fi
	if [[ -f "$DEST_DIR/$DEST_NAME" ]] ; then
		OV_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.nac:lcars.png"
	set theOverwrite to button returned of (display dialog "An encrypted image with that name already exists in your destination folder. Do you want to replace it with the one you're creating, or do you want to rename the new image? " ¬
		buttons {"Cancel", "Rename", "Replace"} ¬
		with title "NAC: " & "$DEST_NAME" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theOverwrite
EOT)
		if [[ "$OV_CHOICE" == "Replace" ]] ; then
			OV_RETURN="true"
		elif [[ "$OV_CHOICE" == "Rename" ]] ; then
			OV_RETURN=""
		else
			BREAKER="true"
			OV_RETURN="true"
		fi
	else
		OV_RETURN="true"
	fi
done
if [[ "$BREAKER" == "true" ]] ; then
	exit # ALT: continue
fi

# notify
notify "Please wait!" "Encrypting…"

# compress target file/folder
cd "$TARGET_PARENT"
COMPRESS=$(/usr/bin/tar -jcvf "$CRYPT_DIR/target.tbz" "$TARGET_NAME" 2>&1)
cd /
if [[ $(echo "$COMPRESS" | /usr/bin/grep "tar: ") != "" ]] ; then
	echo "$COMPRESS"
	notify "Compression error" "$TARGET_NAME"
	rm -rf "$CRYPT_DIR/"*
	exit # ALT: continue
fi
TBZ_CHECKSUM=$(/usr/bin/shasum -a 256 "$CRYPT_DIR/target.tbz" | /usr/bin/awk '{print $1}')

# encrypt target archive
ENCRYPT=$(/usr/bin/openssl enc -aes-256-cbc -a -salt -pass pass:"$PASSPHRASE" -in "$CRYPT_DIR/target.tbz" -out "$CRYPT_DIR/target.aes" 2>&1)
if [[ "$ENCRYPT" != "" ]] ; then
	echo "$ENCRYPT"
	notify "Encryption error" "$TARGET_NAME"
	rm -rf "$CRYPT_DIR/"*
	exit # ALT: continue
fi
AES_CHECKSUM=$(/usr/bin/shasum -a 256 "$CRYPT_DIR/target.aes" | /usr/bin/awk '{print $1}')
LINE_COUNT=$(/usr/bin/wc -l "$CRYPT_DIR/target.aes" | /usr/bin/awk '{print $1}' | xargs)
OFFSET=$(/bin/expr $LINE_COUNT + 8)

# echo delimiters
echo "
-----BEGIN DATA-----" > "$CRYPT_DIR/delim1.txt"
echo "-----END DATA-----
-----BEGIN INFO-----
type=data
offset=$OFFSET
sha-tbz=$TBZ_CHECKSUM
sha-aes=$AES_CHECKSUM
-----END INFO-----" > "$CRYPT_DIR/delim2.txt"

# concat image and data
CONCAT=$(/bin/cat "$IMG_LOC" "$CRYPT_DIR/delim1.txt" "$CRYPT_DIR/target.aes" "$CRYPT_DIR/delim2.txt" > "$DEST_DIR/$DEST_NAME" 2>&1)
if [[ $(echo "$CONCAT" | /usr/bin/grep "cat: ") != "" ]] ; then
	echo "$CONCAT"
	notify "Steg error" "$TARGET_NAME"
	rm -rf "$CRYPT_DIR/"*
	exit # ALT: continue
fi

# final stuff
rm -rf "$CRYPT_DIR/"*
echo "$PASSPHRASE" | /usr/bin/pbcopy
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
