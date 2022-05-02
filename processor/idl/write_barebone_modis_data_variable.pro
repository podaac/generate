;  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: write_barebone_modis_data_variable.pro,v 1.2 2006/10/12 00:53:38 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
; New Request #xxxx

FUNCTION write_barebone_modis_data_variable,$
         i_filename,$
         i_dataset_array,$
         i_dataset_name,$
         i_long_name,$
         i_units,$
         i_data_type,$
         i_coordinates,$
         i_source,$
         i_comment

; Function write one MODIS data variable along its barebone attributes to an existing NetCDF file.
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
    print, 'write_barebone_modis_data_variable: ERROR, Cannot open file for update.'
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
    print, 'write_barebone_modis_data_variable: ERROR, Cannot set netCDF file into define mode AAA.'
    print, i_filename
    status = FAILURE;
    ; Must return immediately.
    return, status
endif

ncdf_control, file_id, /REDEF
CATCH, /CANCEL

;
; Get the id's of the lat and lon from file.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_barebone_modis_data_variable: ERROR, Cannot get the ids for lat, lon, time dimensions.'
    print, i_filename
    status = FAILURE;
    ; Must return immediately.
    return, status
endif
dataset_lat_id = ncdf_dimid(file_id,'nj');
dataset_lon_id = ncdf_dimid(file_id,'ni');
dataset_time_id = ncdf_dimid(file_id,'time');
CATCH, /CANCEL

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_barebone_modis_data_variable: ERROR, Cannot create variable for dataset. Variable = ',i_dataset_name
    print, i_filename
    status = FAILURE;
    ; Must return immediately.
    return, status
endif

;
; Create the id for the dataset.  Becareful, the 3rd argument is has
; lat id, lon id, and time id respectively.
;

;    print, 'write_barebone_modis_data_variable: INFO, i_data_type = [',i_data_type,']';
if (i_data_type EQ 'INT' || i_data_type EQ 'SHORT') then begin
;        print, 'write_barebone_modis_data_variable: INT';
    dataset_id = ncdf_vardef(file_id, i_dataset_name, [dataset_lon_id,dataset_lat_id,$
                         dataset_time_id], /SHORT);
endif else begin
    if (i_data_type EQ 'BYTE') then begin
;            print, 'write_barebone_modis_data_variable: BYTE';
            dataset_id = ncdf_vardef(file_id, i_dataset_name, [dataset_lon_id,dataset_lat_id,$
                         dataset_time_id], /BYTE);
    endif else begin
            if (i_data_type EQ 'FLOAT') then begin
;                print, 'write_barebone_modis_data_variable: FLOAT';
                dataset_id = ncdf_vardef(file_id, i_dataset_name, [dataset_lon_id,dataset_lat_id,$
                             dataset_time_id], /FLOAT);
    endif else begin
                print, 'write_barebone_modis_data_variable: ERROR, data type not supported at this point. i_data_type = ', i_data_type;
            endelse
    endelse
endelse 
CATCH, /CANCEL

;print, 'write_barebone_modis_data_variable: newly created dataset_id = ', dataset_id

;
; Define attributes for the data set variable.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_barebone_modis_data_variable: ERROR, Cannot define attributes for the dataset.'
    print, 'i_filename   = ', i_filename;
    status = FAILURE;
    ; Must return immediately.
    return, status
endif

ncdf_attput,file_id,dataset_id,N_LONG_NAME,   i_long_name,  /CHAR;
ncdf_attput,file_id,dataset_id,N_UNITS,       i_units,    /CHAR;
ncdf_attput,file_id,dataset_id,N_COORDINATES, i_coordinates,/CHAR;

; Only write the source if it has something in it. 

if (N_ELEMENTS(i_source) NE 0) then begin
   if (STRLEN(i_source) GT 0) then begin
       ncdf_attput,file_id,dataset_id,N_SOURCE,   i_source,  /CHAR;
   end
end

; Only write the comment if it has something in it. 
if (N_ELEMENTS(i_comment) NE 0) then begin
   if (STRLEN(i_comment) GT 0) then begin
       ncdf_attput,file_id,dataset_id,N_COMMENT,   i_comment,  /CHAR;
   end
end

CATCH, /CANCEL

;
; Put netCDF file out of define mode and into data mode for writing:
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'write_barebone_modis_data_variable: ERROR, Cannot set netCDF file into data mode DDD.'
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
    print, 'write_barebone_modis_data_variable: ERROR, Cannot write dataset to netCDF file.'
    print, 'write_barebone_modis_data_variable: i_dataset_name = ', i_dataset_name;
    print, 'write_barebone_modis_data_variable: i_filename      = ', i_filename;
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
