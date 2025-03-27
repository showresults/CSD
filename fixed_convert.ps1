# Fixed PowerShell script to convert videos to browser-compatible format
# Uses ffmpeg to convert videos to MP4 with H.264 codec

Write-Host "===== Video Format Conversion Tool (Fixed) ====="
Write-Host "This script will convert all videos to browser-compatible formats"
Write-Host

# Function to check if a video is already browser-compatible
function Test-VideoCompatibility {
    param (
        [string]$videoPath
    )
    
    try {
        # Get video codec information using ffprobe
        $probeResult = & ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 $videoPath
        $codecName = $probeResult.Trim()
        
        # Check if codec is already H.264 (browser compatible)
        if ($codecName -eq "h264") {
            return $true
        }
        return $false
    }
    catch {
        # If ffprobe fails, assume video is not compatible
        return $false
    }
}

# Function to convert videos in a directory
function Convert-VideosInDirectory {
    param (
        [string]$dirPath
    )

    # Get all video files in the directory
    $videoFiles = Get-ChildItem -Path $dirPath -Filter "*.mp4" -File -Recurse
    $totalFiles = $videoFiles.Count
    $currentFile = 0

    if ($totalFiles -eq 0) {
        Write-Host "No MP4 files found in $dirPath"
        return
    }

    # Process each video file
    foreach ($video in $videoFiles) {
        $currentFile++
        $sourcePath = $video.FullName
        $progressPercent = [math]::Round(($currentFile / $totalFiles) * 100)
        
        # Check if already compatible
        $isCompatible = Test-VideoCompatibility -videoPath $sourcePath
        
        if ($isCompatible) {
            Write-Host "[$progressPercent%] $($video.Name) is already browser-compatible, skipping..."
            continue
        }
        
        try {
            Write-Host "[$progressPercent%] Converting $($video.Name) to MP4 (H.264)..."
            
            # Create temp file path
            $tempFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString() + ".mp4")
            
            # Convert video to browser-compatible format (H.264 video, AAC audio)
            & ffmpeg -i $sourcePath -c:v libx264 -preset fast -crf 22 -c:a aac -b:a 128k -movflags faststart $tempFile -y
            
            # If conversion was successful, replace original file
            if (Test-Path $tempFile) {
                Copy-Item -Path $tempFile -Destination $sourcePath -Force
                Remove-Item -Path $tempFile -Force
                Write-Host "[$progressPercent%] Successfully converted $($video.Name)"
            }
            
            # Create WebM version if requested
            if ($createWebM) {
                $webmPath = [System.IO.Path]::ChangeExtension($sourcePath, "webm")
                Write-Host "[$progressPercent%] Creating WebM version of $($video.Name)..."
                
                # Convert to WebM format (VP9 video, Opus audio)
                & ffmpeg -i $sourcePath -c:v libvpx-vp9 -b:v 1M -c:a libopus -b:a 128k $webmPath -y
            }
        }
        catch {
            Write-Error "Error converting $($video.Name): $_"
        }
    }
}

# Main execution
try {
    # Check if ffmpeg is available
    $ffmpegVersion = & ffmpeg -version
    if (-not $?) {
        throw "FFmpeg is not installed or not in PATH. Please install FFmpeg first."
    }

    # Process quantitative videos
    $quantDirs = @(
        "./"
    )
    
    foreach ($dir in $quantDirs) {
        if (Test-Path $dir) {
            Write-Host "Converting videos in $dir"
            Convert-VideosInDirectory -dirPath $dir
        } else {
            Write-Host "Directory $dir not found, skipping..."
        }
    }

    
    Write-Host
    Write-Host "===== Conversion Complete ====="
    Write-Host "All videos have been converted to browser-compatible formats."
    if ($createWebM) {
        Write-Host "The HTML has been updated to support both MP4 and WebM formats."
    }
}
catch {
    Write-Error "Error: $_"
} 