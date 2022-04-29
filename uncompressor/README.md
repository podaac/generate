# uncompressor

The uncompressor decompresses any files that are compressed and moves them to a directory that indicates if they are 'quicklook' or 'refined'.

## pre-requisites to building

An IDL license for executing IDL within the Docker container. This can be accomplished by mounting your local IDL installation into the Docker container.

The following IDL files must be compiled to `.sav` files:
- combine_netcdf_sst_and_sst3_files_to_netcdf.pro
- combine_netcdf_sst_and_sst4_files_to_netcdf.pro
- is_netcdf_granule_night_or_day.pro

To compile IDL files:
1. `cd` to the IDL directory (`combiner/idl`).
2. Execute `idl`.
3. Inside the IDL command prompt, execute: `.FULL_RESET_SESSION`
4. Inside the IDL command prompt, execute: `.COMPILE {file name without '.pro' extension}` 
    1. Example: `.COMPILE combine_netcdf_sst_and_sst3_files_to_netcdf`
5. Inside the IDL command prompt, execute: `RESOLVE_ALL`
6. Inside the IDL command prompt, execute: `SAVE, /ROUTINES, FILENAME='{file name}.sav'`
    1. Example: `SAVE, /ROUTINES, FILENAME='is_netcdf_granule_quicklook_or_refined.sav'`


## build command

`docker build --tag uncompressor:0.1 . `

## execute command

MODIS A: 
`docker run --name gen-test -v /uncompressor/input:/input -v /uncompressor/logs:/logs -v /uncompressor/jobs:/jobs -v /uncompressor/scratch:/scratch -v /usr/local:/usr/local uncompressor:0.1 20 yes /data/input MODIS_A`

MODIS T: 
`docker run --name gen-uncomp -v /uncompressor/input:/input -v /uncompressor/logs:/logs -v /uncompressor/jobs:/jobs -v /uncompressor/scratch:/scratch -v /usr/local:/usr/local uncompressor:0.1 20 yes /data/input MODIS_T`

VIIRS: 
`docker run --name gen-uncomp -v /uncompressor/input:/input -v /uncompressor/logs:/logs -v /uncompressor/jobs:/jobs -v /uncompressor/scratch:/scratch -v /usr/local:/usr/local uncompressor:0.1 20 yes /data/input VIIRS`

**NOTES**
- In order for the commands to execute the `/uncompressor/` directories will need to point to actual directories on the system.
- The `/usr/local` directory contains the IDL license requirements.