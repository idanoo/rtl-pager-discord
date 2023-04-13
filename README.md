# rtl-pager-discord
Docker container to pull pager message into a discord channel from an RTL-SDR.

You will need to find the USB bus that the SDR is plugged into

```
docker run \
  -e "FREQUENCY=157.945M" \
  -e "GAIN=40.2" \
  -e "DISCORD_WEBHOOK_URL=https:..." \
  --device /dev/bus/usb/001/001:/dev/bus/usb/001/001 \
  idanoo/rtl-pager-discord

ENV VARS:    
- FREQUENCY    
- GAIN    
- DISCORD_WEBHOOK_URL    