#!/bin/sh

image_dir_prefix="/data/logo"
image_logo_path="/data/logo/logo.png"
ffmpeg_path="/opt/tool/ffmpeg/ffmpeg -analyzeduration 999999999 -probesize 999999999 "


input_stream_prefix="rtmp://localhost/watermark"
output_stream_prefix="rtmp://localhost/hls"


codec_flag='-c:v libx264 -profile:v baseline -b:v 1000k -preset:v veryfast -c:a aac -ab 64k'

if [ $# -lt 1 ]; then
	echo "$0 stream_name"
	exit 1
fi

stream_name=$1
input_stream_url=$input_stream_prefix"/$stream_name"
output_stream_url=$output_stream_prefix"/$stream_name"

image_dir="$image_dir_prefix/$stream_name"
image_top_path=$image_dir"/top.png"
image_bottom_path=$image_dir"/bottom.png"

declare cmd

function check_image() {
	r=`date +%s%N`
	$ffmpeg_path -i $1 -y /tmp/$r.jpg
	retval=$?
	rm -f /tmp/$r.jpg
	if [ $retval -eq 0 ];then 
		return 1
	else
		return 0
	fi
	
}



function cmd_onlylogo() {
	cmd="$ffmpeg_path -i $input_stream_url -i $image_logo_path -filter_complex [0:v][1:v]overlay=main_w-overlay_w-10:10 $codec_flag -f flv $output_stream_url"
}

function cmd_logotop() {
	cmd="$ffmpeg_path -i $input_stream_url -i $image_logo_path -i $image_top_path -filter_complex [0:v][1:v]overlay=main_w-overlay_w-10:10[mid0];[mid0][2:v]overlay=10:10 $codec_flag -f flv $output_stream_url"
}

function cmd_logobottom() {
	cmd="$ffmpeg_path -i $input_stream_url -i $image_logo_path -i $image_bottom_path -filter_complex [0:v][1:v]overlay=main_w-overlay_w-10:10[mid0];[mid0][2:v]overlay=(main_w-overlay_w)/2:main_h-overlay_h-10 $codec_flag -f flv $output_stream_url"
}

function cmd_logotopbottom() {
	cmd="$ffmpeg_path -i $input_stream_url -i $image_logo_path -i $image_top_path -i $image_bottom_path -filter_complex [0:v][1:v]overlay=main_w-overlay_w-10:10[mid0];[mid0][2:v]overlay=10:10[mid1];[mid1][3:v]overlay=(main_w-overlay_w)/2:main_h-overlay_h-10 $codec_flag -f flv $output_stream_url"
}


# 1. 检查水印图像是否可用
check_image $image_top_path
top_image_exist=$?
check_image $image_bottom_path
bottom_image_exist=$?

echo "top_image_exist : $top_image_exist, bottom_image_exist: $bottom_image_exist"

# 2. 根据可用水印转码

if [ "$top_image_exist" -eq "1" ] && [ "$bottom_image_exist" -eq "1" ];
then
	cmd_logotopbottom
elif [ $top_image_exist -eq 1 ]
then
	cmd_logotop
elif [ $bottom_image_exist -eq 1 ]
then
	cmd_logobottom
else
	cmd_onlylogo
fi

echo $cmd
$cmd
