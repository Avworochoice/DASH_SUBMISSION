# DASH Quality of Experience (QoE) Analysis Project

## 1. Project Overview
This repository contains the implementation for Choice Avworo (Student ID: 4979151) as part of the CSI_6_SIT Smart Internet Technologies coursework.

The project demonstrates a Dynamic Adaptive Streaming over HTTP (DASH) testbed used to evaluate network performance and video quality under various traffic conditions.

## 2. Project Structure
- `dash/`: Contains the video manifest (`.mpd`) and segments (`.m4s`).
- `index.html`: The web player for viewing the DASH content.
- `report/`: Detailed lab report covering all 10 steps of the analysis.
- `scripts/`: Shell scripts for network emulation (TC) and iPerf traffic generation.

## 3. Installation & Requirements
1. **Operating System:** Ubuntu 22.04 LTS (2 VMs: Server and Client).
2. **Network:** Bridged Adapter configuration for both VMs.
3. **Core Tools:**
   ```bash
   sudo apt update
   sudo apt install ffmpeg apache2 iperf3 iproute2
   ```

## 4. Deployment Instructions

### A. Server Setup (Ubuntu VM)
1. **Copy Files to Web Root:**
   ```bash
   sudo cp -r ~/Submission_DASH/* /var/www/html/
   sudo systemctl restart apache2
   ```
2. **IP Configuration:**
   Ensure the Server's IP is accessible (e.g., `192.168.33.97`).

### B. DASH Packaging
The video segments and manifest are generated using FFmpeg:
```bash
ffmpeg -i input_hd.mp4 -map 0 -map 0 -map 0 -c:v libx264 -s:v:0 1280x720 -b:v:0 2500k -s:v:1 854x480 -b:v:1 1000k -s:v:2 640x360 -b:v:2 500k -use_timeline 1 -use_template 1 -f dash /var/www/html/dash/manifest.mpd
```

### C. Network Emulation (Traffic Control)
To simulate network constraints (e.g., TBF rate limiting):
```bash
sudo tc qdisc add dev enp0s3 root tbf rate 2mbit burst 32kbit latency 400ms
```

### D. Running Quality Tests
1. **Start Traffic Server (VM Server):**
   ```bash
   iperf3 -s -D
   ```
2. **Generate Competing Traffic (VM Client):**
   ```bash
   iperf3 -c 192.168.33.97 -t 60
   ```
3. **Monitor Video:**
   Open `http://192.168.33.97/index.html` in your host browser and record Mean Opinion Score (MOS) observations.

## 5. Usage
Access the video player via your host machine browser at:
`http://[SERVER_IP]/index.html`

Explore different network scenarios by switching between TBF, HTB (Priority), and Ingress Policing scripts located in the `scripts/` folder.

- `http://192.168.33.97/dash/video2/manifest.mpd`

Evidence:
- See `Figure 5` in the report.

### Step 5: DASH playback from client VM
- Used a custom `index.html` file based on the dash.js library.
- Validated playback of both streams via Windows Host browser pointing to `http://192.168.33.97/index.html`.

Evidence:
- See `Figure 6` in the report.

### Step 6: IPERF TCP 1 Mbps with higher priority
Server:
```bash
iperf3 -s -D --logfile iperf_server.log
```
Client:
```bash
iperf3 -c 192.168.33.97 -t 300 -b 1M &
```

Evidence:
- See `Figure 7` in the report.

### Step 7: Network artifact scenarios using `tc`
#### 7.1 TBF at server egress
Target parameters: 2.5 Mbps, 20K burst, <= 50 ms latency.
```bash
sudo tc qdisc add dev enp0s3 root tbf rate 2.5mbit burst 20kb latency 50ms
```
Evidence:
- See `Figure 8` in the report.

#### 7.2 HTB at server egress
Target parameters: 2.5 Mbps guaranteed, 5 Mbps max.
```bash
sudo tc qdisc add dev enp0s3 root handle 1: htb default 20
sudo tc class add dev enp0s3 parent 1: classid 1:1 htb rate 2.5mbit ceil 5mbit burst 20kb
```
Evidence:
- See `Figure 9` in the report.

#### 7.3 Ingress policing at client
Drop above 3.5 Mbps.
```bash
sudo tc qdisc add dev enp0s3 handle ffff: ingress
sudo tc filter add dev enp0s3 parent ffff: protocol ip prio 1 u32 match u32 0 0 police rate 3.5mbit burst 20kb drop flowid :1
```
Evidence:
- See `Figure 10` in the report.

### Step 8: MOS for each scenario
Subjective scoring based on ITU-T BT.500 ACR scale (1-5).
- Average scores and qualitative analysis are detailed in Section 3.8 of the report.

Evidence:
- See `Figure 11` & `Figure 12` in the report.

- 1: Bad

Formula:
```text
MOS = sum(scores) / N
```

Store evidence:
- Raw scores in `mos/raw_scores.csv`
- Final MOS in `mos/mos_results.csv`

### Step 9: Upload complete project to GitHub (20 marks)
Include:
- Project structure
- Description
- Installation and deployment instructions

Required evidence:
- `screenshots/github_structure_1.png`
- `screenshots/github_structure_2.png`
- `screenshots/github_structure_3.png`

### Step 10: Narrative and analysis
- Explain how QoE is measured from MOS findings.
- Explain end-device parameters that can improve QoE.

Report note keyword required by brief:
- Mention `chaotic theory` in report narrative.

## 6. Scripts
Place all executable steps in `scripts/` and document usage:
- `server_setup.sh`
- `client_setup.sh`
- `transcode_and_dash.sh`
- `tc_tbf.sh`
- `tc_htb.sh`
- `tc_ingress_police.sh`

## 7. Verification Checklist
- [ ] ffmpeg installed and validated.
- [ ] Two HD source videos downloaded and licensed for use.
- [ ] Bitrate ladder generated for each video.
- [ ] DASH manifests created for both streams.
- [ ] Two unique URL endpoints accessible from client.
- [ ] DASH playback validated on client.
- [ ] iperf TCP 1 Mbps flow established and prioritized.
- [ ] TBF scenario tested and captured.
- [ ] HTB scenario tested and captured.
- [ ] Ingress policing scenario tested and captured.
- [ ] MOS collected and computed for all scenarios.
- [ ] GitHub repository includes instructions and screenshots.
- [ ] Report written with IEEE references.

## 8. References
Use IEEE citation style in report and optionally mirror key references here.
