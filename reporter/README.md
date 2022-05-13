# reporter

The reporter generates, prints, and emails daily reports on the total number of files processed by Generate.

## pre-requisites to building

If you would like email reports, enter an email address(es) in `reporter_config` on line 9.

## build command

`docker build --tag reporter:0.1 . `

## execute command

MODIS A QUICKLOOK
`docker run --name gen-test -v /{reporter}/scratch:/data/scratch -v /{reporter}/logs/processing_logs:/data/processing_logs -v /{reporter}:/data/output reporter:0.1 MODIS_A QUICKLOOK today -m`

MODIS A REFINED
`docker run --name gen-test -v /{reporter}/scratch:/data/scratch -v /{reporter}/logs/processing_logs:/data/processing_logs -v /{reporter}:/data/output reporter:0.1 MODIS_A REFINED today -m`

MODIS T QUICKLOOK
`docker run --name gen-test -v /{reporter}/scratch:/data/scratch -v /{reporter}/logs/processing_logs:/data/processing_logs -v /{reporter}:/data/output reporter:0.1 MODIS_T QUICKLOOK today -m`

MOODIS T REFINED
`docker run --name gen-test -v /{reporter}/scratch:/data/scratch -v /{reporter}/logs/processing_logs:/data/processing_logs -v /{reporter}:/data/output reporter:0.1 MODIS_T REFINED today -m`

VIIRS QUICKLOOK
`docker run --name gen-test -v /{reporter}/scratch:/data/scratch -v /{reporter}/logs/processing_logs:/data/processing_logs -v /{reporter}:/data/output reporter:0.1 VIIRS QUICKLOOK today -m`

VIIRS REFINED
`docker run --name gen-test -v /{reporter}/scratch:/data/scratch -v /{reporter}/logs/processing_logs:/data/processing_logs -v /{reporter}:/data/output reporter:0.1 VIIRS REFINED today -m`

***Please note that in order for the commands to execute the `/reporter/` directories will need to point to actual directories on the system.***

## additional notes

The Reporter component currently uses postfix and mailutils to send reports via email. It may make sense to move the mail functionality out of the container and let the Generate cloud infrastructure handling email notifications.