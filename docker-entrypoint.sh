#!/bin/bash
set -e

# return lowercase
function getLowercase () {
    echo "${1}" | tr "[:upper:]" "[:lower:]"
}

# convert string to boolean
function getBoolean () {
    case $(getLowercase "${1}") in
        "true") echo true ;;
        *) echo false ;;
    esac
}

streamURL=${STREAM_URL}
dir="/usr/data/recordings"
fileExtension="mp4"

echo "Environment Variables:"
echo " TZ = $TZ"
echo " HOUSEKEEP_ENABLED = $HOUSEKEEP_ENABLED"
echo " HOUSEKEEP_DAYS = $HOUSEKEEP_DAYS"
echo " VIDEO_SEGMENT_TIME = $VIDEO_SEGMENT_TIME"
echo " VIDEO_FORMAT = $VIDEO_FORMAT"
echo " Stream URL = $STREAM_URL"

# exit if no stream parameter has been passed
if [ -z "${streamURL// }" ]; then
    echo "Please pass a stream url as parameter to the container. Exiting..."
    exit 1
fi

HOUSEKEEP_ENABLED=$(getBoolean "$HOUSEKEEP_ENABLED")

mkdir -p "$dir"

if [ $(getLowercase "$VIDEO_FORMAT") == "mkv" ]; then
    fileExtension="mkv"
fi

# remove old recordings
if [ "$HOUSEKEEP_ENABLED" = true ]; then
    cronDailyPath="/etc/periodic/daily"

    echo "#!/bin/sh" > "$cronDailyPath/delete-old-streams"
    echo "find $dir -type f -mtime +$HOUSEKEEP_DAYS -delete" >> "$cronDailyPath/delete-old-streams"

    chmod +x "$cronDailyPath/delete-old-streams"

    crond
fi

echo "Saving stream in \"$dir\""

# start recording with ffmpeg
ffmpeg -rtsp_transport tcp \
    -y \
    -stimeout 1000000 \
    -i "$streamURL" \
    -c copy \
    -f segment \
    -segment_time "$VIDEO_SEGMENT_TIME" \
    -segment_atclocktime 1 \
    -strftime 1 \
    "$dir"/%Y-%m-%d_%H-%M-%S."$fileExtension" \
    -loglevel panic
