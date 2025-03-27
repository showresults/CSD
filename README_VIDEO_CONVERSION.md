# Video Conversion Scripts

This folder contains scripts to convert videos to browser-compatible formats using FFmpeg.

## Requirements

- [FFmpeg](https://ffmpeg.org/download.html) must be installed and available in your system PATH
- PowerShell 5.1 or higher

## Available Scripts

### fixed_convert.ps1

The main script for converting videos to browser-compatible formats. This script:

1. Identifies videos that are not already in browser-compatible format (H.264)
2. Converts them to H.264/AAC format for maximum browser compatibility
3. Optionally creates WebM versions as fallback for browsers without H.264 support
4. Updates the HTML to use both formats if WebM versions are created

### Usage

1. Open PowerShell in the project directory
2. Run the script:
   ```
   .\fixed_convert.ps1
   ```
3. When prompted, choose whether to create WebM versions as fallback (recommended for maximum compatibility)

## How Browser Video Compatibility Works

- **MP4 with H.264/AAC**: Supported by all modern browsers, but may have patent licensing issues in some contexts
- **WebM with VP9/Opus**: Open format supported by Chrome, Firefox, and Edge, but not by older browsers

The scripts generate HTML that looks like this when WebM is enabled:

```html
<video controls loop>
    <source src="path/to/video.mp4" type="video/mp4">
    <source src="path/to/video.webm" type="video/webm">
    Your browser does not support the video tag.
</video>
```

This ensures browsers will try MP4 first, and fall back to WebM if needed.

## Troubleshooting

- If videos fail to play, check that they are properly encoded using:
  ```
  ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 path/to/video.mp4
  ```
  The output should be "h264" for properly converted videos.

- If WebM videos are not created, ensure FFmpeg was built with VP9 and Opus support. 