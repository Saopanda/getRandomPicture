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

# 找到我们的专属文件,并且倒序排列一下 `-r`
file_names=`ls -r ${file_path}*-randBG.jpg 2>/dev/null`
# 判断 ls 是否出错
if [ $? -eq 1 ]
	# 找不到序号为 1
	then file_num=1

elif [ -z $file_names ]

	# 如果为空 序号为 1
	then file_num=1

else
	# 处理数组
	a=0
	for str in $file_names
		do
			file_names_array[a]=${str##*/}
			let a++
		done

	# 使用sort排序 获得文件名数组
	file_names=($(echo ${file_names_array[*]} | tr ' ' '\n' | sort -n -r))
	# 拿到最大数值
	max_file_name_num=${file_names[0]%%-*}
	file_num=$[$max_file_name_num+1]
fi

file_name=${file_num}-randBG.jpg

# 下载
wget -O $file_path$file_name $file_url
echo -n $file_num > ${file_path}/max
exit;
