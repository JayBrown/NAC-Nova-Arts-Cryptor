![NAC-platform-macos](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![NAC-code-shell](https://img.shields.io/badge/code-shell-yellow.svg)
[![NAC-depend-tnote](https://img.shields.io/badge/dependency-terminal--notifier%201.6.3-green.svg)](https://github.com/alloy/terminal-notifier)
[![NAC-license](http://img.shields.io/badge/license-MIT+-blue.svg)](https://github.com/JayBrown/NAC-Nova-Arts-Cryptor/blob/master/license.md)

# NAC – Nova Arts Cryptor <img src="https://github.com/JayBrown/NAC-Nova-Arts-Cryptor/blob/master/img/jb-img.png" height="20px"/>
**Steganography workflows for macOS to encrypt and hide any file of any size in an image file of any size, and decrypt them later**

There are perfectly fine steganographical tools for macOS like Rbcafé's **Outguess**. They apply a very discrete kind of steganography, but that usually comes with a disadvantage: their methods don't allow you to hide large files in smaller images, e.g. a 100 MB DMG in a 10 KB GIF. Enter **NAC**, the **Nova Arts Cryptor**, which applies a dumb (a *really* dumb) kind of steganography, but it will hide your files nonetheless. NAC will first compress your target file or folder with bzip2, then password-encrypt the archive (AES-256) using `openssl`, and finally obscure it by simply appending it to an image file of your choice, regardless of the file sizes involved. NAC currently works with PNG, JPEG, GIF and TIFF images files.

Since NAC only cats two files together instead of interweaving them, the hidden data winds up at the end of the image file as a single stream, i.e. it can easily be detected; therefore the additional AES encryption. This also means that image hosting services such as **imgur** will strip the hidden data, but it's fine to upload a NAC image to standard file hosting services.

The name of this workflow is a hat-tip to a long defunct and dearly missed German hacking collective, who offered a tool exactly like this one, albeit for Windows only. Ugh. So instead of firing up my Win98 VM every time I need some quick & dirty steg, I thought I'd rather redo it myself. So here you go. Hide away.

## Installation
* [Download the latest DMG](https://github.com/JayBrown/NAC-Nova-Arts-Cryptor/releases) and open

### Workflows
* Double-click on the workflow files to install
* If you encounter problems, open them with Automator and save/install from there
* Standard Finder integration in the Services menu

### terminal-notifier [optional, recommended]
More information: [terminal-notifier](https://github.com/alloy/terminal-notifier)

You need to have Spotlight enabled for `mdfind` to locate the terminal-notifier.app on your volume; if you don't install terminal-notifier, or if you have deactivated Spotlight, the NAC scripts will call notifications via AppleScript instead

#### Installation method #1
Install using [Homebrew](http://brew.sh) with `brew install terminal-notifier` (or with a similar manager)

#### Installation method #2
* move the terminal-notifier zip archive from the DiMaGo disk image to a folder on your main volume
* unzip the application and move it to a suitable location, e.g. to `/Applications`, `/Applications/Utilities`, or `$HOME/Applications`

### Main shell scripts [optional]
Only necessary if for some reason you want to run NAC from the shell or another shell script. For normal use the workflows will be sufficient.

* Move the scripts `nac-encrypt.sh` and `nac-decrypt.sh` to `/usr/local/bin`
* In your shell enter `chmod +x /usr/local/bin/nac-encrypt.sh` and `chmod +x /usr/local/bin/nac-decrypt.sh`
* Run the script with `nac-encrypt.sh /path/to/target` and `nac-decrypt.sh /path/to/target`

## Uninstall
Remove the following files or folders:

```
$HOME/Downloads/NAC
$HOME/Library/Caches/local.lcars.nac
$HOME/Library/Services/NAC\ ➤\ Encrypt.workflow
$HOME/Library/Services/NAC\ ➤\ Decrypt.workflow
$HOME/Pictures/NAC
/usr/local/bin/nac-encrypt.sh
/usr/local/bin/nac-decrypt.sh
```

## To do
* cleanup
* add checksum information of original tbz archive for additional security
* workflow for encrypting text selections
* add support for bitmap format

## Acknowledgments
* **NAC** (the *actual* NAC)
