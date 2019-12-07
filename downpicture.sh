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
echo ${file_name_array[*]}
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
exit;
