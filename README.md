## 概要
有一个随机图片的接口 每次访问可以得到一张高清图片。由于是国外服务器，有诸多不稳定因素，慢，卡等（平时还挺快的），我想写一个脚本把这些随机图down到本地，这样就会稳定多了

```
https://uploadbeta.com/api/pictures/random/?key=BingEverydayWallpaperPicture
```

下载东西我首先想到了 `wget` ，查一下 wget

惊了惊了 好多选项 ，hold住，先找我们需要的
* wget -O 以指定文件名下载文件

```
wget -O 123.txt http://xxx
```

好的，文件名自定义一下，为了保证文件名不重复，我想到了时间戳

查到了shell的时间可以通过一个`date`的命令拿到
> 时间格式设置：
> `+%a`  +号开头，可以直接跟在date后面，也可以字符串形式 `"+%a"`

格式的设置快看疯了！以下是常用的 | --
-- | --
%m |   月 (01..12)
%d |   日 (01..31)
%H |   24小时制
%d |   12小时制
%M |   分钟
%S |   秒
%e |   短格式天 ( 1..31)
%k |   24小时制 短格式
%l |   12小时制 短格式
%F |   %Y-%m-%d 2019-11-26
%s |   时间戳！
%N |   更精确的时间戳 // mac环境无效

```
//  默认格式
# date
2019年11月26日 星期二 15时01分56秒 CST

//  定义格式
# date +%s
1574751787
```

好了，开始写脚本，先定义一个文件名吧！

```
#!/bin/bash
# 使用纳秒
file_name=`date +%N`
# 前面加个日期前缀，中间用纳秒再截取一部分做唯一，后面再加个后缀
file_name=`date +%F`_${file_name:4}_bg.jpg
```

要开始使用 `wget` 了！我突然意识到到需要指定一个下载目录，使用 -P 指定
既然路径可以变，那就让他可以从脚本外传进来吧
>接收执行脚本传递的参数 $n 第几个参数就是$几

>第一次执行发生了错误，$0 第一个参数 是shell的第一个参数 主命令算在内的，整个的第一个参数其实是 $1 开始

```
# 参数判断一下 没有默认当前目录
if [ -n "$1" ]; then
    file_path=$1
else
    file_path="./"
fi
# 同样的 下载的网址干脆也来个值传递
if [ -n "$2" ]; then
    file_url=$2
else
    file_url='https://uploadbeta.com/api/pictures/random/?key=BingEverydayWallpaperPicture'
fi

## 第二次错误代码 
# wget -O $file_name -P $file_path $file_url
```
>运行到这，发现 -P指定的目录无效，都是直接下载到当前目录。
>直接执行 `wget -P -O` 发现也不好使
>经过 -P -O等参数的反复试验，发现`-O`是可以直接带路径的，不带路径是当前目录，且使用了 `-O` 后 `-P` 是无效的
于是去掉 -P 变成这样

```
wget -O $file_path$file_name $file_url
```

完美 第一阶段完成，执行后可以保存在指定目录里

![1431574764249_.pic.jpg][1]

## 第二阶段
我想把图片名按数字从小到大命名，这样方便读取图片（数字+扩展名），也容易通过随机数直接做到读取随机图片的效果
> 1.jpg 2.jpg 3.jpg 4.jpg 

先读取选定目录下存在的文件列表，去掉后缀，拿到文件名，放到一个数组里，搞一个都是文件名的数组
获取文件名的方法：
> ${var%.*} 变量从右边往左，删掉第一个 . 和右边的字符
```
num=0
for str in `ls $file_path`
do
    file_name_array[$num]=${str%.*}
    num+=1
done
```

接下来是对文件名数组排序，一共有三步，第一步：
>输出file_name_array数组内所有元素
第二步：
>用tr命令把空格替换成换行符
第三步：
>用sort命令把内容排序：-n 是按自然数排序 -r 是倒序排序

```
file_name_array=$(echo ${file_name_array[*]} | tr ' ' '\n' | sort -n -r)

# 把包含空格的字符串直接转为数组 因为shell的数组就是空格分割的
file_name_array=($file_name_array)
```

> `$file_name_array[0]` 就是选定目录下最大数字的文件名
我们再对拿到的文件名进行一下判断

```
# 判断是不是数字
if [ ${file_name_array[0]} -gt 0 ] 2>/dev/null
    # 然后给文件名数字加1 这里卡了 bash里面原来不能直接做算术运算，借用了 expr
    # 那我上面循环的 num+=1 岂不是错了？ 晕。。但是回去看了眼 但是好像正常
    file_num=$(echo `expr ${file_name_array[0]} + 1`)
    then file_name=${file_num}.jpg
else
    echo '目录内没有纯数字文件！';exit;
fi

```

运行几次，初步完美了！
这个目录还要创建一个文件，用来存放当前图片最大值

```
# 简单粗暴 放到max文件里
# echo $file_num > max
## 这样写 echo会在末尾自动加上换行，使用 -n 参数直接写到文件中

echo -n $file_num > max
```

最后的效果

![1451574846347_.pic.jpg][2]

用PHP读一个随机图

```
$max_num=file_get_contents('./images/max');
echo mt_rand(1,$max_num).'.jpg';
```

## 存在的问题
* 不能传相对路径。。悲催的死机好几次才发现
* 应该对下载状态弄一个判断，下载成功与否







## 最后
贴上完整代码

```
#!/bin/bash

# 参数判断一下 没传值默认当前目录
if [ -n "$1" ]; then
    file_path=$1
else
    file_path="./"
fi
# 同样的 下载的网址参数
if [ -n "$2" ]; then
    file_url=$2
else
    file_url='https://uploadbeta.com/api/pictures/random/?key=BingEverydayWallpaperPicture'
fi

# 第二阶段 开始搞文件名 找当前目录内存在的最大数字
# 将文件名搞到数组里 file_name_array
num=0
for str in `ls $file_path`
do
    file_name_array[$num]=${str%.*}
    num+=1
done
# 对文件名数组进行自然数倒序排序，变成新数组
file_name_array=$(echo ${file_name_array[*]} | tr ' ' '\n' | sort -n -r)
file_name_array=($file_name_array)
# 判断数组内第一个元素是不是数字
if [ ${file_name_array[0]} -gt 0 ] 2>/dev/null
    file_num=$(echo `expr ${file_name_array[0]} + 1`)
    then file_name=${file_num}.jpg
else
# 不是数字退出
    echo '目录内没有纯数字文件！';exit;
fi

# 下载随机图
wget -O $file_path$file_name $file_url
echo -n $file_num > ${file_path}/max

```


  [1]: https://saopanda.top/usr/uploads/2019/11/2747507115.jpg
  [2]: https://saopanda.top/usr/uploads/2019/11/3265425867.jpg
