#!/bin/bash

# Make sure redis is booted!
echo 'Booting redis'
/etc/init.d/redis-server start

# Array of messages to skip
declare -A toSkip
toSkip+=( "this is a test" )
toSkip+=( "enabled demodulators" )
toSkip+=( "test page" )
toSkip+=( "assigned to station" )

# Array of emojis to add
declare -A emojiArr
# House
emojiArr[house]=":house:"
emojiArr[roof]=":house:"
# Car
emojiArr[mva]=":blue_car:"
emojiArr[mvc]=":blue_car:"
emojiArr[car ]=":blue_car:"
#Heli
emojiArr[westp1]=":helicopter:"
# Fire
emojiArr[fire]=":fire:"
emojiArr[stru]=":fire:"
emojiArr[smoke]=":fire:"
emojiArr[smoking]=":fire:"
emojiArr[chimney]=":fire:"
emojiArr[sprnklr]=":fire:"
# Flood
emojiArr[flood]=":ocean:"
# Wind
emojiArr[wind]=":wind_blowing_face:"
emojiArr[blow]=":wind_blowing_face:"
# Power
emojiArr[power]=":zap:"
emojiArr[electric]=":zap:"
emojiArr[spark]=":zap:"
# Ambulance
emojiArr[chest pain]=":ambulance:"
emojiArr[not alert]=":ambulance:"
emojiArr[seizure]=":ambulance:"
emojiArr[breath]=":ambulance:"
emojiArr[pain]=":ambulance:"
emojiArr[fall ]=":ambulance:"
emojiArr[orange]=":ambulance:"
emojiArr[sweats]=":ambulance:"
emojiArr[acute]=":ambulance:"
emojiArr[red 1]=":ambulance:"
emojiArr[red 2]=":ambulance:"
emojiArr[respitory]=":ambulance:"
emojiArr[bleeding]=":ambulance:"
emojiArr[purple]=":ambulance:"
# Rescue
emojiArr[resc ]=":helmet_with_cross:"
emojiArr[hazchem]=":biohazard:"
# Tree
emojiArr[tree]=":evergreen_tree:"

# Send to discord
sendMsg () {
  # Clean up messages
  STRIP=$(echo "$1" | sed ':a;N;$!ba;s/\n/ /g' | awk '{$1=$1};1' | sed 's/^|\(.*\)/\1/' | sed 's/<ETX>//g')
  STRIPLOWER=$(echo "$STRIP" | tr '[:upper:]' '[:lower:]')
  
  # Append emojis
  for find in "${!emojiArr[@]}"; do
      # Check if keyword matches
      if [[ "$STRIPLOWER" == *"$find"* ]]; then
          # Check if we have already added the keyword
          if [[ "$STRIP" == *"${emojiArr[$find]}"* ]]; then
              continue
          fi

          # Prepend the keyword
          STRIP="${emojiArr[$find]} $STRIP"
      fi
  done

  CACHECHECK=$(cacheCheck "$STRIP")
  if [[ "$CACHECHECK" == "OK" ]]; then
      # send to discord
      curl -sS -H "Content-Type: application/json" -d "{\"username\":\"Pager\",\"content\":\"$STRIP\"}" $DISCORD_WEBHOOK_URL > /dev/null
  fi
}

# Check if we've sent recently (5min TTL)
cacheCheck () {
    redis-cli SET "pager:$(echo -n $1 | md5sum | awk '{print $1}')" "true" NX EX 300
}

# Run script!
rtl_fm -M fm -f ${FREQUENCY:=157.945M} -g ${GAIN:=40.2} -s 22050 -- | multimon-ng -t raw -a POCSAG512 -a POCSAG1200 -a FLEX -a POCSAG2400 /dev/stdin | while read -r line ; do
  LINELOWER=$(echo "$line" | tr '[:upper:]' '[:lower:]')
  # Skip certain messages
  for find in "${!toSkip[@]}"; do
    # Check if keyword matches - if so.. ignore
    if [[ "$LINELOWER" == *"$find"* ]]; then
        continue 2
    fi
  done

  # Remove prefixes
  if [[ "$line" == "FLEX"* ]]; then
    sendMsg "${line#*ALN}"
  elif [[ "$line" == "POCSAG"* ]]; then
    if [[ "$line" == *"Alpha"* ]]; then
      sendMsg "${line#*Alpha:}"
    fi
  else
    sendMsg "$line"
  fi
done
