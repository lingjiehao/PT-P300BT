# Printing to a Brother P-Touch Cube PT-P300BT label printer from a computer

## Introduction

The [Brother P-touch Cube PT-P300BT labelling machine](https://support.brother.com/g/b/producttop.aspx?c=gb&lang=en&prod=p300bteuk) is intended to be controlled from the official Brother P-touch Design&Print 2 app for [Android](https://play.google.com/store/apps/details?id=com.brother.ptouch.designandprint2) and [iOS](https://apps.apple.com/it/app/brother-p-touch-design-print/id1105307806) devices, instead of from a computer.

This Gist provides small code revision and some additional scripts to the [dogtopus/Pipfile](https://gist.github.com/dogtopus/64ae743825e42f2bb8ec79cea7ad2057) one, which in turn is forked from the excellent [stecman](https://gist.github.com/stecman/ee1fd9a8b1b6f0fdd170ee87ba2ddafd) one, in order to print text labels via scripts on computers with different O.S. or subsystems.

The scripts are used to convert text labels to appropriate images compatible with 12mm width craft tapes like [TZe-131](https://www.brother-usa.com/products/tze131) or [TZe-231](https://www.brother-usa.com/products/tze231). The font is fixed (TrueType ps:[helvetica](https://en.wikipedia.org/wiki/Helvetica)) and the [ImageMagick convert parameters](https://imagemagick.org/script/command-line-options.php) are tuned for the max allowed character size with this printer.

Two settings are empirically experimented: for character sequences (numbers and [uppercase (or lowercase) letters](https://en.wikipedia.org/wiki/Letter_case)) which do not [overshoot](https://en.wikipedia.org/wiki/Overshoot_(typography)) below the [baseline](https://en.wikipedia.org/wiki/Baseline_(typography)) (e.g., different from `jgpq|\$/@_()[]{}`), the max size can be obtained via `-pointsize 86 -splice 0x5 -border 10x10` (e.g., uppercase characters and numbers get the full size of about 9 mm with upper and lower tape border of 1,5 mm); otherwise, a slightly smaller but more compatible size (allowing overshoots) can be used via `-size x82 -gravity south -splice 0x15` ([corpus size](https://en.wikipedia.org/wiki/X-height) of ab. 6 mm, [cap height](https://en.wikipedia.org/wiki/Cap_height) of over 7 mm). WSL has different values (see below). In all cases, `-background white -bordercolor white -fill black` have to be added. [`-style`](https://imagemagick.org/script/command-line-options.php#style) and [`-weight`](https://imagemagick.org/script/command-line-options.php#weight) attributes can be added for italic and bold styles (while [`-stretch`](https://imagemagick.org/script/command-line-options.php#stretch) does not produce differences). The cap height of the default setting of the Brother P-touch Design&Print 2 app is about 5 mm, but can be resized via text submenu.

Other possibly compatible fonts (if installed) which could be added with the [`-family`](https://imagemagick.org/script/command-line-options.php#family) parameter (with Ubuntu):

- Andale Mono
- Courier New
- Georgia
- Liberation Mono
- Liberation Sans
- Liberation Sans Narrow
- Liberation Serif
- Nimbus Mono L
- Ubuntu
- Ubuntu Condensed

The latter (`-family "Ubuntu Condensed"`) could be the most appropriate one for condensed text.

The scripts are simple examples which can be easily replaced by more functional apps.

Notice that the printer separates each printout by about 27 mm of unprinted tape.

## Windows

### Package installation on Windows

Download [ImageMagick](https://imagemagick.org/script/download.php) checking the legacy convert tool while installing.

- Install the latest version of [Python](https://www.python.org/downloads/windows/)
- Install *git* from [Git-scm](https://git-scm.com/download/win) or using the [Git for Windows installer](https://gitforwindows.org/)
- Open a CMD:

```cmd
python3 -m pip install --upgrade pip
python3 -m pip install pillow packbits
git clone https://gist.github.com/bd53c77c98ecd3d7db340c0398b22d8a.git printlabel # this Gist
cd printlabel
```

Unzip all files in "printlabel.zip" to the current directory, replacing the old ones (code modified to support RFCOMM on the Windows COM port).

### Usage on Windows

Pair the printer with an RFCOMM COM port using the Windows Bluetooth panel.

Usage: `printlabel "label to print" "COM Port"`

```bash
./printlabel "Lorem Ipsum" COM5
```

## Ubuntu

### Package installation on Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-dev python3-pip git imagemagick imagemagick-6.q16 libbluetooth-dev
python3 -m pip install --upgrade pip
python3 -m pip install pybluez pillow packbits
git clone https://gist.github.com/64ae743825e42f2bb8ec79cea7ad2057.git printlabel # dogtopus/Pipfile Gist
cd printlabel

cat > printlabel <<\eof
#!/bin/bash

if [ $# -ne 2 ]
   then echo "Usage: $(basename $0)" '"label to print" "Bluetooth MAC address"'
        exit 1
fi
echo "Press ESC to print or Control-C to break"
trap 'exit 2' 1 2 13 15
if [[ "$1" =~ [\]jgpq\|\\\$/@_(){}\[] ]]
   then convert -size x82 -gravity south -splice 0x15 -background white -bordercolor white label:"$1" -fill black label.png
        echo "standard mode"
   else convert -pointsize 86 -background white -bordercolor white label:"$1" -fill black -splice 0x5 -border 10x10 label.png # UPPERCASE BLOCK
        echo "UPPERCASE MODE (bigger font)"
fi
display label.png
python3 labelmaker.py -i label.png "$2"
rm label.png
exit 0
eof

chmod a+x printlabel
```

Note: Windows Subsystem for Linux (also V2) does not support Bluetooth at the moment.

### Bluetooth printer connection on Ubuntu

Switch on the printer.

Connect the printer via [Ubuntu Bluetooth panel](https://help.ubuntu.com/stable/ubuntu-help/bluetooth-connect-device.html.en) (e.g., Settings, Bluetooth).

To read the MAC address:

```bash
hcitool scan
```

### Usage on Ubuntu

Usage: `printlabel "label to print" "Bluetooth MAC address"`

Selecting standard font size:

```bash
./printlabel "Lorem Ipsum" "AA:BB:CC:DD:EE:FF"
```

Selecting bigger font with uppercase letters and numbers:

```bash
./printlabel "LOREM IPSUM" "AA:BB:CC:DD:EE:FF"
```

## WSL (Windows Subsystem for Linux)

### Package installation on WSL

On [WSL](https://docs.microsoft.com/en-us/windows/wsl/about) the installation uses the same code for Windows, with a shell based procedure without "display", which needs an X-Windows server.

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-dev python3-pip git imagemagick imagemagick-6.q16 libbluetooth-dev
python3 -m pip install --upgrade pip
python3 -m pip install pillow packbits
git clone https://gist.github.com/bd53c77c98ecd3d7db340c0398b22d8a.git printlabel # this Gist
cd printlabel
unzip printlabel.zip
rm printlabel.zip

cat > printlabel.sh <<\eof
#!/bin/bash

if [ $# -ne 2 ]
   then echo "Usage: $(basename $0)" '"label to print" /dev/ttyS_serial_port_number'
        exit 1
fi
if [[ "$1" =~ [\]jgpq\|\\\$/@_(){}\[] ]]
   then convert -size x65 -splice 0x5 -background white -bordercolor white label:"$1" -fill black label.png
        echo "standard mode"
   else convert -pointsize 86 -background white -bordercolor white label:"$1" -fill black -splice 0x17 -border 0x0 label.png # UPPERCASE BLOCK
        echo "UPPERCASE MODE (bigger font)"
fi
python3 labelmaker.py -i label.png "$2"
rm label.png
exit 0
eof

chmod a+x printlabel.sh
```

### Usage on WSL

Pair the printer with an RFCOMM COM port using the Windows Bluetooth panel. Check the outbound RFCOMM COM port number and use it to define /dev/ttyS_serial_port_number; for instance, *COM5* is */dev/ttyS5*.

Usage: printlabel.sh "label to print" /dev/ttyS_serial_port_number

Selecting standard font size:

```bash
./printlabel.sh "Lorem Ipsum" /dev/ttyS5
```

Selecting bigger font with uppercase letters and numbers:

```bash
./printlabel.sh "LOREM IPSUM" /dev/ttyS5
```
