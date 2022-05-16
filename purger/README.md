# purger

The purger deletes `holding_tank` files older than a specified number of minutes and downloaded files older than a specified number of days.

## pre-requisites to building

None.

## build command

`docker build --tag purger:0.1 . `

## execute command

DOWNLOADS
docker run --name gen-test -v /{purger}/scratch:/data/scratch -v /{purger}/logs:/data/logs purger:0.1 downloaded 7 no

HOLDING TANK SST
docker run --name gen-test -v /{purger}/scratch:/data/scratch -v /{purger}/logs:/data/logs purger:0.1 1440 no '*L2.SST*'

HOLDING TANK LAC
docker run --name gen-test -v /{purger}/scratch:/data/scratch -v /{purger}/logs:/data/logs purger:0.1 holding 1440 no ' *LAC*'

***Please note that in order for the commands to execute the `/purger/` directories will need to point to actual directories on the system.***