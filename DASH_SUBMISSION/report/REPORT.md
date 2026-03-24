# CSI_6_SIT Smart Internet Technologies
# Detailed Project Report: DASH Video Streaming and QoE Evaluation

## 1. Project Description

This project is a Dynamic Adaptive Streaming over HTTP (DASH) Quality of Experience (QoE) analysis testbed developed for the CSI_6_SIT Smart Internet Technologies coursework.

The implementation demonstrates an end-to-end DASH workflow using two Ubuntu 22.04 virtual machines in VirtualBox:

1. A server VM for media processing, DASH packaging, web hosting, and egress traffic shaping.
2. A client VM for DASH playback, ingress policing, and subjective quality scoring.

The project processes HD source videos with FFmpeg, transcodes them into multiple bitrate representations, packages them into DASH manifests and media segments, serves them through Apache, and evaluates user-perceived quality under controlled network artifacts using Linux traffic control tools.

The QoE study focuses on how TBF, HTB, and ingress policing affect playback behavior, startup delay, rebuffering, and adaptation stability. Subjective quality is measured through Mean Opinion Score (MOS) following ITU-R BT.500 principles.

## 2. Project Aim and Objectives

### 2.1 Aim

The aim of this coursework is to build a complete DASH test environment and evaluate how network artifacts impact perceived video quality.

### 2.2 Objectives

1. Prepare adaptive video content with FFmpeg.
2. Host DASH content via web server URLs.
3. Emulate network constraints using Linux traffic control.
4. Evaluate user experience via MOS.
5. Document reproducible procedures in GitHub.

## 3. Project Structure

The cloned repository contains the following top-level components:

1. `about.md`: Project overview, structure summary, installation requirements, and deployment notes.
2. `README.md`: Main coursework narrative and implementation evidence.
3. `screenshots/`: Screenshot evidence for report figures and GitHub documentation.
4. `DASH_SUBMISSION/`: Main project directory containing the streaming assets and executable scripts.

Inside `DASH_SUBMISSION/`, the major components are:

1. `ffmpeg_lab/`: Working media directory containing source and transcoded video files, plus generated DASH output under `ffmpeg_lab/dash/video1` and `ffmpeg_lab/dash/video2`.
2. `html/`: Web delivery directory containing `index.html` and published stream folders under `html/streams/video1` and `html/streams/video2`.
3. `report/`: Detailed lab report folder containing `REPORT.md`.
4. `scripts/`: Shell scripts for FFmpeg processing, setup, and traffic-control scenarios.

The scripted components referenced for reproducibility are:

1. `server_setup.sh`
2. `client_setup.sh`
3. `transcode_and_dash.sh`
4. `tc_tbf.sh`
5. `tc_htb.sh`
6. `tc_ingress_police.sh`

## 4. Experimental Testbed

### 4.1 Virtual Machine Setup

Two Ubuntu virtual machines were created in VirtualBox:

1. `server-vm`: media processing, DASH packaging, web hosting, and egress shaping.
2. `client-vm`: DASH playback, ingress policing, and subjective scoring.

### 4.2 Network Configuration

Both VMs were configured with Bridged networking to communicate over routable LAN or Internet IPs.

Recorded example addresses:

1. Server VM IP: `192.168.33.97`
2. Client VM IP: `192.168.33.40`

Connectivity validation commands used in the report include:

```bash
ping -c 4 192.168.33.97
ping -c 4 192.168.33.40
```

### 4.3 Software Stack

The source files identify the following software stack:

1. Ubuntu 22.04 LTS
2. FFmpeg
3. Apache2
4. iperf3
5. iproute2 (`tc`)
6. Browser and dash.js-based player

## 5. Installation Requirements

### 5.1 Operating System and Network

1. Operating System: Ubuntu 22.04 LTS on two VMs, one server and one client.
2. Network: Bridged Adapter configuration for both VMs.

### 5.2 Core Tool Installation

The core tools identified across the source files are installed with:

```bash
sudo apt update
sudo apt install -y ffmpeg apache2 iperf3 iproute2 git
```

For FFmpeg verification, the report uses:

```bash
sudo apt update
sudo apt install -y ffmpeg
ffmpeg -version
```

The installation was verified by confirming the `ffmpeg -version` output.

## 6. Deployment Instructions

### 6.1 Server Setup

The project deploys the generated DASH content to Apache on the server VM.

Install and enable Apache:

```bash
sudo apt install -y apache2
sudo systemctl enable apache2
sudo systemctl restart apache2
```

Create web directories:

```bash
sudo mkdir -p /var/www/html/streams/video1 /var/www/html/streams/video2
```

Copy DASH outputs to the web root:

```bash
sudo cp -r ~/ffmpeg_lab/dash/video1/* /var/www/html/streams/video1/
sudo cp -r ~/ffmpeg_lab/dash/video2/* /var/www/html/streams/video2/
```

Apply ownership and permissions:

```bash
sudo chown -R www-data:www-data /var/www/html/streams
sudo chmod -R 755 /var/www/html/streams
```

If UFW is enabled, allow HTTP traffic:

```bash
sudo ufw allow 80/tcp
sudo ufw status
```

Restart Apache after deployment if required:

```bash
sudo systemctl restart apache2
```

### 6.2 Server IP and Stream Access

The server IP should be accessible, for example `192.168.33.97`.

The playout URLs identified in the source files are:

1. `http://192.168.33.97/streams/video1/manifest.mpd`
2. `http://192.168.33.97/streams/video2/manifest.mpd`

Validation commands used from the client side include:

```bash
curl -I http://192.168.33.97/dash/video1/manifest.mpd
curl -I http://192.168.33.97/dash/video2/manifest.mpd
```

### 6.3 Player Deployment and Usage

The player is provided through `index.html` and is accessed from a host browser using:

`http://192.168.33.97/index.html`

The player supports DASH playback for both streams, and the user monitors playback behavior while recording MOS observations.

## 7. Media Preparation and DASH Packaging

### 7.1 HD Video Sources

The HD source videos were obtained from:

1. https://www.pexels.com/search/videos/HD/
2. https://www.videezy.com/free-video/hd

### 7.2 Bitrate Transcoding

Each input video was transcoded into three bitrate representations: 1.5 Mbps, 2.0 Mbps, and 4.0 Mbps.

Example commands for Video A:

```bash
ffmpeg -i video1_hd.mp4 -c:v libx264 -preset veryfast -b:v 1500k -maxrate 1500k -bufsize 3000k -c:a aac -b:a 128k videoA_1500.mp4
ffmpeg -i video1_hd.mp4 -c:v libx264 -preset veryfast -b:v 2000k -maxrate 2000k -bufsize 4000k -c:a aac -b:a 128k videoA_2000.mp4
ffmpeg -i video1_hd.mp4 -c:v libx264 -preset veryfast -b:v 4000k -maxrate 4000k -bufsize 8000k -c:a aac -b:a 128k video1_4000.mp4
```

Example commands for Video B:

```bash
ffmpeg -i video2_hd.mp4 -c:v libx264 -preset veryfast -b:v 1500k -maxrate 1500k -bufsize 3000k -c:a aac -b:a 128k video2_1500.mp4
ffmpeg -i videoB_hd.mp4 -c:v libx264 -preset veryfast -b:v 2000k -maxrate 2000k -bufsize 4000k -c:a aac -b:a 128k video2_2000.mp4
ffmpeg -i videoB_hd.mp4 -c:v libx264 -preset veryfast -b:v 4000k -maxrate 4000k -bufsize 8000k -c:a aac -b:a 128k video2_4000.mp4
```

### 7.3 DASH Packaging

The DASH output is generated in `~/ffmpeg_lab/dash/video1` and `~/ffmpeg_lab/dash/video2`.

Example packaging flow:

```bash
mkdir -p ~/ffmpeg_lab/dash/video1
ffmpeg \
	-i videoA_1500.mp4 -i videoA_2000.mp4 -i videoA_4000.mp4 \
	-map 0:v -map 1:v -map 2:v -map 0:a \
	-c copy -f dash -seg_duration 4 -use_timeline 1 -use_template 1 \
	/ffmpeg_lab/dash/video1/manifest.mpd
```

For Video B:

```bash
mkdir -p  ~/ffmpeg_lab/dash/video1
ffmpeg \
	-i videoB_1500.mp4 -i videoB_2000.mp4 -i videoB_4000.mp4 \
	-map 0:v -map 1:v -map 2:v -map 0:a \
	-c copy -f dash -seg_duration 4 -use_timeline 1 -use_template 1 \
	/ffmpeg_lab/dash/video2/manifest.mpd
```

Output verification is performed with:

```bash
ls -lh ~/ffmpeg_lab/dash/video1
ls -lh ~/ffmpeg_lab/dash/video2
```

The expected output is one `.mpd` file plus `.m4s` segments for each representation.

## 8. Playback and Quality Testing

### 8.1 DASH Playback

Playback is performed from the client VM using a custom dash.js-based `index.html` page. Both streams are validated from the Windows host browser by loading the player page and entering the MPD URLs.

Playback procedure:

1. Open the browser on the client VM.
2. Load the player page.
3. Enter the Video A MPD URL and start playback.
4. Repeat the process with the Video B MPD URL.
5. Observe adaptive quality switching events.

The report states that both titles played successfully with adaptive bitrate switching.

### 8.2 Competing TCP Flow with iPerf

The project establishes a 1 Mbps TCP iPerf flow with higher priority than video traffic.

Server command:

```bash
iperf3 -s -D --logfile iperf_server.log
```

Client command:

```bash
iperf3 -c 192.168.33.97 -t 300 -b 1M &
```

The report also includes the simpler execution form:

```bash
iperf3 -s
iperf3 -c 192.168.33.97 -t 180 -b 1M
```

The prioritization policy described in the report gives iPerf traffic a higher HTB priority (`prio 0`) while video traffic remains in a lower-priority class (`prio 1`).

## 9. Network Artifact Emulation

The report evaluates three Linux traffic-control scenarios.

### 9.1 TBF at Server Egress

Target parameters:

1. Rate: `2.5mbit`
2. Burst: `20kb`
3. Latency: `50ms`

Commands:

```bash
sudo tc qdisc del dev enp0s3 root 2>/dev/null
sudo tc qdisc add dev enp0s3 root tbf rate 2.5mbit burst 20kb latency 50ms
tc -s qdisc show dev enp0s3
```

The report states that throughput was constrained near 2.5 Mbps and buffering probability increased for higher ladder levels.

### 9.2 HTB at Server Egress

Target parameters:

1. Guaranteed minimum bandwidth: `2.5mbit`
2. Maximum class bandwidth: `5mbit`
3. Burst: `20kb`

Commands:

```bash
sudo tc qdisc del dev enp0s3 root 2>/dev/null
sudo tc qdisc add dev enp0s3 root handle 1: htb default 10
sudo tc class add dev enp0s3 parent 1: classid 1:10 htb rate 2.5mbit ceil 5mbit burst 20k
tc -s class show dev enp0s3
```

The report states that iPerf maintained stable throughput and that video adaptation was smoother than in the TBF-only case under moderate load.

### 9.3 Ingress Policing at Client

Target parameter:

1. Drop traffic above `3.5mbit`

Commands:

```bash
sudo tc qdisc del dev enp0s3 ingress 2>/dev/null
sudo tc qdisc add dev enp0s3 handle ffff: ingress
sudo tc filter add dev enp0s3 parent ffff: protocol ip prio 1 u32 \
	match u32 0 0 police rate 3.5mbit burst 20kb drop flowid :1
tc -s filter show dev enp0s3
```

The report states that burst traffic above 3.5 Mbps was dropped, producing quality oscillation and occasional stalling during high-motion scenes.

## 10. Quality of Experience Evaluation

### 10.1 MOS Methodology

The project uses subjective Mean Opinion Score evaluation based on ITU-T BT.500 using the Single Stimulus method and the ACR 5-point scale.

The report records:

1. Viewing distance: `3H to 5H`
2. Participants: `5 subjects`

### 10.2 MOS Results

| Subject ID | Baseline | 7.1 (TBF) | 7.2 (HTB) | 7.3 (Ingress) |
| :--- | :---: | :---: | :---: | :---: |
| User_1 | 5 | 3 | 4 | 2 |
| User_2 | 5 | 3 | 4 | 3 |
| User_3 | 4 | 2 | 3 | 2 |
| User_4 | 5 | 3 | 4 | 3 |
| User_5 | 5 | 2 | 4 | 2 |
| **Average (MOS)** | **4.8** | **2.6** | **3.8** | **2.4** |

Formula used:

```text
MOS = sum(scores) / N
```

The source files also reference storing MOS evidence in:

1. `mos/raw_scores.csv`
2. `mos/mos_results.csv`

### 10.3 Observations

The qualitative observations recorded in the report are:

1. Baseline playback was perfect at 4000 kbps with no delay.
2. TBF caused frequent quality switches and visible blurriness.
3. HTB allowed prioritized iPerf traffic while maintaining a fair 2000 kbps video bitrate without stalling.
4. Ingress policing caused the strongest degradation, including visible frame drops and audio or video synchronization issues.

## 11. GitHub Documentation Requirements

The GitHub deliverables identified in the source files include:

1. Project structure
2. Project description
3. Installation and deployment instructions
4. Scripts and report folder contents
5. Screenshots showing command output and topology proof

The report states that the repository should include:

1. `README.md` with setup and deployment instructions
2. `about.md` with project overview and deployment summary
3. `DASH_SUBMISSION/scripts/` with FFmpeg and traffic-control commands
4. `DASH_SUBMISSION/ffmpeg_lab/` with media files and generated DASH assets
5. `DASH_SUBMISSION/html/` with the player page and published stream folders
6. `DASH_SUBMISSION/report/` with the written report
7. `screenshots/` with supporting evidence

## 12. Verification Checklist

The checklist captured in the source files is:

1. FFmpeg installed and validated
2. Two HD source videos downloaded and licensed for use
3. Bitrate ladder generated for each video
4. DASH manifests created for both streams
5. Two unique URL endpoints accessible from client
6. DASH playback validated on client
7. iPerf TCP 1 Mbps flow established and prioritized
8. TBF scenario tested and captured
9. HTB scenario tested and captured
10. Ingress policing scenario tested and captured
11. MOS collected and computed for all scenarios
12. GitHub repository includes instructions and screenshots
13. Report written with IEEE references

## 13. Discussion and Conclusion

The implementation demonstrates that network control policies strongly influence adaptive streaming outcomes. TBF is described as simple and deterministic but restrictive for variable bitrate content. HTB provides better class-based control and policy-driven fairness, especially when prioritizing concurrent non-video flows such as iPerf. Ingress policing is useful for emulating constrained receiving networks but introduces packet-loss behavior that can destabilize adaptation.

The report identifies the following limitations:

1. Results depend on the selected videos and scene complexity.
2. The MOS sample size can affect confidence.
3. VM host resource contention may influence playback smoothness.

The implementation concludes that the end-to-end DASH pipeline was successfully built and that clear QoE differences were observed across TBF, HTB, and ingress policing scenarios. According to the report, HTB-based prioritization offered the best balance in this testbed, and MOS analysis confirmed that throughput constraints, traffic prioritization, and packet dropping patterns directly affect perceived quality.

## 14. References Mentioned in the Source Files

1. ITU-R BT.500 methodology for subjective television picture quality assessment.
2. Tecmint guidance for FFmpeg installation in Linux.
3. FFmpeg DASH packaging guidance from Andriika.
4. CodeSamplez PHP HTML5 video streaming tutorial.
5. Bitmovin MPEG-DASH open source player tools.
6. Linux Traffic Control HOWTO.
7. Pexels HD video source.
8. Videezy HD video source.
