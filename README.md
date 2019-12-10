## 概要
有一个随机图片的接口 每次访问可以得到一张高清图片。由于是国外服务器，有诸多不稳定因素，慢，卡等（平时还挺快的），我想写一个脚本把这些随机图down到本地，这样就会稳定多了

```
https://uploadbeta.com/api/pictures/random/?key=BingEverydayWallpaperPicture
```

## 执行

```
./downpicture {下载路径}
```

## 用PHP读一个随机图

```
$max_num=file_get_contents('./images/max');
echo '/images/'.mt_rand(1,$max_num).'-randBG.jpg';
```

## 优化
* 下载 wget 结果加判断，不然下载失败max文件数字依然增加
* 增加一个下载文件类型判断，这样可以下载不同的东西了
