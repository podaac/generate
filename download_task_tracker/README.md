# download task tracker

The download task tracker checks for any download processes that may have stalled and generates a SigEvent.

## pre-requisites to building

An IDL license for executing IDL within the Docker container. This can be accomplished by mounting your local IDL installation into the Docker container.

The following IDL files must be compiled to `.sav` files:
- ghrsst_notify_operator.pro

To compile IDL files:
1. `cd` to the IDL directory (`download task tracker/idl`).
2. Execute `idl`.
3. Inside the IDL command prompt, execute: `.FULL_RESET_SESSION`
4. Inside the IDL command prompt, execute: `.COMPILE {file name without '.pro' extension}` 
    1. Example: `.COMPILE ghrsst_notify_operator`
5. Inside the IDL command prompt, execute: `RESOLVE_ALL`
6. Inside the IDL command prompt, execute: `SAVE, /ROUTINES, FILENAME='{file name}.sav'`
    1. Example: `SAVE, /ROUTINES, FILENAME='ghrsst_notify_operator.sav'`

## build command

`docker build --tag tasks_tracker:0.1 . `

## execute command

MODIS A: 
`docker run --name gen-test -v /download_task_tracker/logs:/data/logs -v /download_task_tracker/scratch:/data/scratch -v /usr/local:/usr/local tasks_tracker:0.1 /data/scratch/modis_aqua_level2_download_processes 120`

MODIS T: 
`docker run --name gen-test -v /download_task_tracker/logs:/data/logs -v /download_task_tracker/scratch:/data/scratch -v /usr/local:/usr/local tasks_tracker:0.1 /data/scratch/modis_terra_level2_download_processes 120`

VIIRS: 
`docker run --name gen-test -v /download_task_tracker/logs:/data/logs -v /download_task_tracker/scratch:/data/scratch -v /usr/local:/usr/local tasks_tracker:0.1 /data/scratch/viirs_level2_download_processes 120`

**NOTES**
- In order for the commands to execute the `/download task tracker/` directories will need to point to actual directories on the system.
- The `/usr/local` directory contains the IDL license requirements.