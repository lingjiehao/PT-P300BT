## 确定打印端口

Windows 10 通过蓝牙连接到打印机，设备管理器里会出现两个串口设备，我这里是'COM6'和'COM7'，
这两个端口看起来一模一样，但只有一个能用于打印，目前还不知道怎么准确区分哪个是打印口，最终试出来
是'COM7'能打印，'COM6'会一直卡在'=> Querying printer status...'。

## 打印

可以通过`printlabel.cmd`快速打印：

```
printlabel.cmd "ABCD1234" COM7
```

``

`printlabel.cmd`中使用magick convert生成图片，然后调用`labelmaker.py`打印这个图片，所以先手动通过magick convert生成图片，再调用:

```
python labelmaker.py -i label.png COM7
```

效果是一样的。

PS:

```
magick convert -size x82 -gravity south -splice 0x15 -background white -bordercolor white label:"Lorem Ipsum" -flop -fill black label.png

-flop: 镜像图片
```

下面不再调用`printlabel.cmd`， 而是直接调用`labelmaker.py`

`labelmaker.py`参数:

```
$ python labelmaker.py -h

usage: labelmaker.py [-h] [-i IMAGE] [-n] [-F] [-a] [-m] [-e END_MARGIN] [-r] [-C] comport

positional arguments:
  comport               Printer COM port.

optional arguments:
  -h, --help            show this help message and exit
  -i IMAGE, --image IMAGE
                        Image file to print.
  -n, --no-print        Only configure the printer and send the image but do not send print command.
  -F, --no-feed         Disable feeding at the end of the print (chaining). ---> 链式/连续打印
  -a, --auto-cut        Enable auto-cutting (or print label boundary on e.g. PT-P300BT). --->添加剪切标记
  -m, --mirror-print    Mirror print label. --->镜像打印
  -e END_MARGIN, --end-margin END_MARGIN
                        End margin (in dots).
  -r, --raw             Send the image to printer as-is without any pre-processing.
  -C, --nocomp          Disable compression.
```

使用示例
```
python labelmaker.py -F -a -m -i label.png COM7
```


