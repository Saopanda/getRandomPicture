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
echo '/images/'.mt_rand(1,$max_num).'.jpg';
```

## 存在的问题
* 好像不能传相对路径
* 应该对下载状态弄一个判断，下载成功与否
* 发现定格在 30.jpg了， 简单看了下 应该是 ls 那里的锅
