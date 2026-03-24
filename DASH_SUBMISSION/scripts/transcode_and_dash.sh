ffmpeg -i video1_hd.mp4 -c:v libx264 -preset veryfast -b:v 1500k -maxrate 1500k -bufsize 3000k -c:a aac -b:a 128k video1_1500.mp4
ffmpeg -i video1_hd.mp4 -c:v libx264 -preset veryfast -b:v 2000k -maxrate 2000k -bufsize 4000k -c:a aac -b:a 128k video1_2000.mp4
ffmpeg -i video1_hd.mp4 -c:v libx264 -preset veryfast -b:v 4000k -maxrate 4000k -bufsize 8000k -c:a aac -b:a 128k video1_4000.mp4
ffmpeg -i video2_hd.mp4 -c:v libx264 -preset veryfast -b:v 1500k -maxrate 1500k -bufsize 3000k -c:a aac -b:a 128k video2_1500.mp4
ffmpeg -i video2_hd.mp4 -c:v libx264 -preset veryfast -b:v 2000k -maxrate 2000k -bufsize 4000k -c:a aac -b:a 128k video2_2000.mp4
ffmpeg -i video2_hd.mp4 -c:v libx264 -preset veryfast -b:v 4000k -maxrate 4000k -bufsize 8000k -c:a aac -b:a 128k video2_4000.mp4
mkdir -p ~/ffmpeg_lab/dash/video1
ffmpeg \
	-i video1_1500.mp4 -i video1_2000.mp4 -i video1_4000.mp4 \
	-map 0:v -map 1:v -map 2:v -map 0:a \
	-c copy -f dash -seg_duration 4 -use_timeline 1 -use_template 1 \
	/ffmpeg_lab/dash/video1/manifest.mpd
mkdir -p  ~/ffmpeg_lab/dash/video2
ffmpeg \
	-i video2_1500.mp4 -i video2_2000.mp4 -i video2_4000.mp4 \
	-map 0:v -map 1:v -map 2:v -map 0:a \
	-c copy -f dash -seg_duration 4 -use_timeline 1 -use_template 1 \
	/ffmpeg_lab/dash/video2/manifest.mpd
ls -lh ~/ffmpeg_lab/dash/video1
ls -lh ~/ffmpeg_lab/dash/video2
