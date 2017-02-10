# mibox
小米盒子协议

### 设备发现


可以通过DNS-SD协议来发现设备：

```
dns-sd -B _rc._tcp local
```

可以看到下面的信息：

```
Browsing for _rc._tcp.local
DATE: ---Wed 16 Dec 2015---
 1:06:35.536  ...STARTING...
Timestamp     A/R    Flags  if Domain               Service Type         Instance Name
 1:06:35.537  Add        2   4 local.               _rc._tcp.            客厅的小米盒子
 ```

这样拿到了Instance Name，就可以用来查询一些信息：

```
dns-sd -L 客厅的小米盒子 _rc._tcp.
```

运行结果：

```
Lookup 客厅的小米盒子._rc._tcp..local
DATE: ---Wed 16 Dec 2015---
 1:07:40.072  ...STARTING...
 1:07:40.073  客厅的小米盒子._rc._tcp.local. can be reached at milink-1501334514.local.:6091 (interface 4)
 protver=16777500 prottext=RC\ Ver\ 1.0.1.28 platform_id=206 scrnw=1920 scrnh=1080 server_address=media.v2.t001.ottcn.com mac=10:48:b1:c7:b9:72 serverport=6088 photoport=6089 rid=1ec74a9ce2de4ce39155c4d687b557c7 apmac=e0:05:c5:d8:75:5a operator=0 miversion=1.3.111 wol=1 amac=04:e6:76:46:03:52 CP=\[118463\] VC=0
```

还有另外一套协议`_airkan._tcp`，没有继续探究。另外，手机客户端也会同时请求服务器来发现设备：[发现局域网内盒子的HTTP请求](https://milink.pandora.xiaomi.com/milink/probe?mac_address=1&opaque=a3b5b9be00c475d425559d062f73c93a1144a231)

### 通信协议

盒子与客户端采用TCP直接通信，小端模式。菜单按钮的点击后一次发送的数据格式为：

```
0000   04 00 41 01 00 00 00 02 00 3a 01 00 00 00 00 02
0010   00 00 00 01 03 00 00 00 52 04 00 00 00 8b 05 00
0020   00 00 00 06 00 00 00 08 07 00 00 00 00 00 00 00
0030   00 08 00 00 00 00 00 00 00 00 0a 00 00 00 02 0b
0040   00 00 03 01
```

按照64位来拆分，变化的部分为：

- 0004~0007 串行序号，每次发送后加1
- 0010~0013 每次按键会发送两次数据，第一次使用0，第二次使用1
- 0018~001f 不同的事件值不同，如下

命令 | 值
--- | ---
Menu | 0x52040000008b0500
Return | 0x04040000009e0500
Home | 0x0304000000660500
Off | 0x1a04000000740500
Confirm | 0x42040000001c0500
Volumn Up | 0x1804000000730500
Volumn Down | 0x1904000000720500
Up | 0x1304000000670500
Down | 0x14040000006c0500
Left | 0x1504000000690500
Right | 0x16040000006a0500

