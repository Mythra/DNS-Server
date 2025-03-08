#!/usr/bin/env bash

set -euo pipefail

echo "Refreshing DNS Records!"
ZONES=($(cat dns_zones.json | jq '.[].name' -r))
echo '[' > dns_zones.json
rm -f dns_zones-hosts.txt
for ZONE_TO_LOAD in "${ZONES[@]}"; do
  # Prefer WiiLink
  # then Kaeru
  # then Wiimmfi
  result=$(dig "$ZONE_TO_LOAD" A @167.235.229.36 +short | tail -n1)
  if [[ "x$result" == "x" ]]; then
    result=$(dig "$ZONE_TO_LOAD" A @178.62.43.212 +short | tail -n1)
    if [[ "x$result" == "x" ]]; then
      result=$(dig "$ZONE_TO_LOAD" A @95.217.77.151 +short | tail -n1)
      if [[ "x$result" == "x" ]]; then
        echo "Could not find: [$ZONE_TO_LOAD]"
	echo "Press enter to confirm removal, Ctrl-C to exit"
	read unused
	continue
      fi
    fi
  fi
  echo "$result $ZONE_TO_LOAD" >> dns_zones-hosts.txt
  echo -e "   {\n      \"type\":\"a\",\n      \"name\":\"$ZONE_TO_LOAD\",\n      \"value\":\"$result\"\n   }," >> dns_zones.json
done
echo ']' >> dns_zones.json
echo "All Done!"
