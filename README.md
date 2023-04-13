# rtl-pager-discord
Docker container to pull pager message into a discord channel from an RTL-SDR

```
docker run -e "FREQUENCY=157.945M" -e "GAIN=40.2" -e "DISCORD_WEBHOOK_URL=https:..." idanoo/rtl-pager-discord

ENV VARS:    
- FREQUENCY    
- GAIN    
- DISCORD_WEBHOOK_URL    