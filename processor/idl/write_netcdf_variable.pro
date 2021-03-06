;  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: write_netcdf_variable.pro,v 1.4 2006/08/04 18:41:20 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
; New Request #xxxx

FUNCTION write_netcdf_variable,$
         i_filename,$
         i_dataset_array,$
         i_dataset_name,$
         i_data_type,$
         i_unit,$
         i_long_name

; Function write one MODIS data variable along with its attributes to an existing NetCDF file.
;
; Assumptions:
;
;   1. The NetCDF file exist.
;   2. The lat and lon ids have been defined for the size of the variable.  
;   3. TBD. 
;   4. TBD.
;   5. TBD. 
;   6. TBD. 
;

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

status = SUCCESS;

; Create a catch block to catch error in interaction with FILE IO
CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_netcdf_variable: ERROR, Cannot open file for update.'
    print, i_filename
    status = FAILURE;
    ; Must return immediately.
    return, status
endif

;
; Open NetCDF file for update. 
;

file_id = ncdf_open(i_filename,/WRITE);

;
; Put netCDF file into define mode for writing:
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_netcdf_variable: ERROR, Cannot set netCDF file into define mode AAA.'
    print, i_filename
    status = FAILURE;
    ; Must return immediately.
    return, status
endif

ncdf_control, file_id, /REDEF
CATCH, /CANCEL

begin_check_id = ncdf_dimid(file_id,'time');
ncdf_diminq, file_id, begin_check_id, dim_name, start_time_dim_size
CATCH, /CANCEL


;
; Get the id's of the lat and lon from file.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_netcdf_variable: ERROR, Cannot get the ids for lat, lon, time dimensions.'
    print, i_filename
    status = FAILURE;
    ; Must return immediately.
    return, status
endif
dataset_time_id = ncdf_dimid(file_id,'time');
CATCH, /CANCEL

;print, 'write_netcdf_variable: dataset_time_id = ', dataset_time_id 

    CATCH, error_status
    if (error_status NE 0) then begin
        CATCH, /CANCEL
        print, 'write_netcdf_variable: ERROR, Cannot create variable for dataset. Variable = ',i_dataset_name
        print, i_filename
        status = FAILURE;
        ; Must return immediately.
        return, status
    endif

;
; Create the id for the dataset.  Becareful, the 3rd argument is has
; lat id, lon id, and time id respectively.
;

;    print, 'write_netcdf_variable: INFO, i_data_type = [',i_data_type,']';
if (i_data_type EQ 'LONG') then begin
;        print, 'write_netcdf_variable: LONG';
    dataset_id = ncdf_vardef(file_id, i_dataset_name, [dataset_time_id], /LONG);
endif else begin
    if (i_data_type EQ 'SHORT') then begin
;            print, 'write_netcdf_variable: SHORT';
        dataset_id = ncdf_vardef(file_id, i_dataset_name, [dataset_time_id], /SHORT);
    endif else begin
        if (i_data_type EQ 'FLOAT') then begin
;                print, 'write_netcdf_variable: SHORT';
            dataset_id = ncdf_vardef(file_id, i_dataset_name, [dataset_time_id], /SHORT);
        endif else begin
                print, 'write_netcdf_variable: ERROR, data type not supported at this point. i_data_type = ', i_data_type;
        endelse
    endelse
endelse 
CATCH, /CANCEL

;    print, 'write_netcdf_variable: newly created dataset_id = ', dataset_id

;
; Define attributes for the data set variable.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_netcdf_variable: ERROR, Cannot define attribute(s) for the dataset ' + i_dataset_name + ' in file ' + i_filename;
    status = FAILURE;
    ; Must return immediately.
    return, status
endif

ncdf_attput,file_id,dataset_id,N_LONG_NAME,i_long_name, /CHAR;
ncdf_attput,file_id,dataset_id,N_UNITS,i_unit,     /CHAR;
CATCH, /CANCEL

;
; Put netCDF file out of define mode and into data mode for writing:
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_netcdf_variable: ERROR, Cannot set netCDF file into data mode DDD.'
    print, i_filename
    status = FAILURE;
    ; Must return immediately.
    return, status
endif

ncdf_control, file_id, /ENDEF
CATCH, /CANCEL

;
; Write the data set to netCDF file.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_netcdf_variable: ERROR, Cannot write dataset ' + i_dataset_name + ' to file ' + i_filename;
    status = FAILURE;
    ; Must return immediately.
    return, status
endif

ncdf_varput, file_id, dataset_id, i_dataset_array;
CATCH, /CANCEL


; ---------- Close up shop ---------- 
ncdf_close, file_id
return, status
end
