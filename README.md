 [Alpine-based container](https://hub.docker.com/r/hpaolini/tiny-nvr) that captures your camera's live stream, saves the video in segments, and deletes the old ones as time goes on.

First, you'll need to gather the following info from your IP camera:

* Credentials (username and password)
* IP address and port
* RTSP stream URL syntax (for example, some Hikvision cameras follow this syntax _rtsp://username:password@address:port//Streaming/Channels/1_).

If your camera allows it, I recommend enabling TCP for the live stream. UDP is fine for view-only purposes but not saving, since frames are usually dropped to keep up with the packets.

```
docker run \
       -v '<RECORDINGS_DESTINATION_FOLDER>:/usr/data/recordings' \
       -e TZ=America/Chicago \
       -e STREAM_URL='<RTSP_URL>' \
       -e HOUSEKEEP_ENABLED=true \
       -e HOUSEKEEP_DAYS=3 \
       -e VIDEO_SEGMENT_TIME=900 \
       -e VIDEO_FORMAT=mp4 \
       tiagoqpinto/tiny-nvr
```

```
camera1_recordings:
    volumes:
      - '<RECORDINGS_DESTINATION_FOLDER>:/usr/data/recordings'
    environment:
      - TZ=Europe/Lisbon
      - STREAM_URL='<RTSP_URL>'
      - HOUSEKEEP_ENABLED=true
      - HOUSEKEEP_DAYS=3
      - VIDEO_SEGMENT_TIME=900
      - VIDEO_FORMAT=mp4
    image: tiagoqpinto/tiny_nvr:latest
    container_name: camera1_recordings
    restart: unless-stopped
```

I added the following environment variables for additional customization. (Remember, environment variables are changed using the `-e` flag.)


| ENV                | Default       | Description |
| :----------------- | :----         | :------ |
| TZ                 | _Europe/Lisbon_ | timezone data |
| HOUSEKEEP_ENABLED  | _true_        | cron job to delete old recordings |
| HOUSEKEEP_DAYS     | _3_           | delete files older than this number of days, if HOUSEKEEP_ENABLED is enabled|
| VIDEO_SEGMENT_TIME | _900_         | seconds of each recording[^1] |
| VIDEO_FORMAT       | _mp4_           | save output as MKV or MP4 file |

Combine this with Kubernetes or Docker Swarm and you've got a simple NVR with a small footprint. Happy hacking!

[^1]: I recommend saving streams in segments of 30 minutes or less. If your camera fails, most likely only your latest recording  would result in a corrupted file, so you still have access to recordings that are closer to the point of failure. Also, the most recent recordings are synced faster to a backup solution.

Forked from https://github.com/hpaolini
