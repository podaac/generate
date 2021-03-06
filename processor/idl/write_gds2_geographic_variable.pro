;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION write_gds2_geographic_variable,$
             i_filename,$
             i_dataset_array,$
             i_dataset_short_name,$
             i_standard_name,$
             i_units,$
             i_fill_value,$
             i_data_type,$
             i_valid_min,$
             i_valid_max,$
             i_comment,$
             i_long_name

; Function write one a geographic variable {lat,lon} along with its attributes to an existing NetCDF file in GDS2 format.
;
; Assumptions:
;
;   1. The NetCDF file exist.
;

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

o_status = SUCCESS;

; Get the DEBUG_MODE if it is set.

debug_module = 'write_gds2_geographic_variable:';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

; Check to see if the compression is suppressed.  It is on by default.

compression_flag = 1; By default, we will use the compression chunking if possible.
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_CHUNKING_SUPPRESS')) EQ 'TRUE') then begin
    compression_flag = 0;
endif

; Check to see if the GZIP compression level is set.  It is default to 5.

compression_level = 5;
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_CHUNKING_COMPRESSION_LEVEL')) NE '') then begin
    compression_level = FIX(GETENV('GHRSST_MODIS_L2P_CHUNKING_COMPRESSION_LEVEL'));
endif

; Create a catch block to catch error in interaction with FILE IO
CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot open file for update ' + i_filename
    o_status = FAILURE;
    ; Must return immediately.
    return, o_status
endif

;
; Open NetCDF file for update. 
;

file_id = NCDF_OPEN(i_filename,/WRITE);

;
; Put netCDF file into define mode for writing:
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot set netCDF file into define mode for file ' + i_filename;
    o_status = FAILURE;
    ; Must return immediately.
    return, o_status
endif

NCDF_CONTROL, file_id, /REDEF
CATCH, /CANCEL

;
; Get the id's of the lat and lon dimensions.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot get the ids for lat, lon dimension for file ' + i_filename;
    o_status = FAILURE;
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    ; Must return immediately.
    return, o_status
endif

; Code used by developer to test this function.
; Change to 2 EQ 2 to purposely get a dimension zzz that we haven't created before.
if (2 EQ 3) then begin
if (debug_mode) then print, debug_module + 'Calling NCDF_DIMID for dimension zzz' + ' from file ' + i_filename;
dataset_zzz_id = NCDF_DIMID(file_id,'zzz');
CATCH, /CANCEL
help, dataset_zzz_id;

if (dataset_zzz_id EQ -1) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot get the id for zzz dimension for file ' + i_filename;
    o_status = FAILURE;
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    ; Must return immediately.
    return, o_status
endif
endif

if (debug_mode) then print, debug_module + '    NCDF_DIMID for dimension nj' + ' from file ' + i_filename;
dataset_lat_id = NCDF_DIMID(file_id,'nj');
CATCH, /CANCEL
if (dataset_lat_id EQ -1) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot get the id for nj dimension for file ' + i_filename;
    o_status = FAILURE;
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    ; Must return immediately.
    return, o_status
endif
if (debug_mode) then print, debug_module + '    NCDF_DIMID for dimension ni' + ' from file ' + i_filename;
dataset_lon_id = NCDF_DIMID(file_id,'ni');
CATCH, /CANCEL
if (dataset_lon_id EQ -1) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot get the id for ni dimension for file ' + i_filename;
    o_status = FAILURE;
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    ; Must return immediately.
    return, o_status
endif

CATCH, /CANCEL



; Set the chunk_dimension_vector to pass it onto NCDF_VARDEF function for the infile compression.

lon_size = (SIZE(i_dataset_array))[1];
lat_size = (SIZE(i_dataset_array))[2];

chunk_dimension_vector = [lon_size,lat_size];

; Tweak the chunk dimension if we can divide lon_size by 2

modulo_of_lon = lon_size MOD 2;
modulo_of_lat = lat_size MOD 2;
if ((modulo_of_lon EQ 0) AND (modulo_of_lat EQ 0))  then begin
    chunk_dimension_vector = [lon_size/2,lat_size/2];
endif


CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot create variable for dataset. Variable ' + i_dataset_short_name + " file " + i_filename;
    o_status = FAILURE;
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    ; Must return immediately.
    return, o_status
endif

if ((i_data_type EQ 'INT') OR (i_data_type EQ 'SHORT')) then begin
    if (debug_mode) then begin
        print, debug_module + '    NCDF_VARDEF for variable ' + i_dataset_short_name + ' to file ' + i_filename + ' with INT or SHORT data type';
    endif
    if (compression_flag) then begin
        dataset_id = NCDF_VARDEF(file_id, i_dataset_short_name, [dataset_lon_id,dataset_lat_id], /SHORT, GZIP=compression_level, CHUNK_DIMENSIONS=chunk_dimension_vector);
    endif else begin
        dataset_id = NCDF_VARDEF(file_id, i_dataset_short_name, [dataset_lon_id,dataset_lat_id], /SHORT);
    endelse
endif else begin
    if (i_data_type EQ 'BYTE') then begin
        if (debug_mode) then begin
            print, debug_module + '    NCDF_VARDEF for variable ' + i_dataset_short_name + ' to file ' + i_filename + ' with BYTE data type';
        endif
        if (compression_flag) then begin
            dataset_id = NCDF_VARDEF(file_id, i_dataset_short_name, [dataset_lon_id,dataset_lat_id],/BYTE, GZIP=compression_level, CHUNK_DIMENSIONS=chunk_dimension_vector);
        endif else begin
            dataset_id = NCDF_VARDEF(file_id, i_dataset_short_name, [dataset_lon_id,dataset_lat_id],/BYTE);
        endelse
       
    endif else begin
        if (i_data_type EQ 'FLOAT') then begin
            if (debug_mode) then begin
                print, debug_module + '    NCDF_VARDEF for variable ' + i_dataset_short_name + ' to file ' + i_filename + ' with FLOAT data type';
            endif
            if (compression_flag) then begin
                dataset_id = NCDF_VARDEF(file_id, i_dataset_short_name, [dataset_lon_id,dataset_lat_id],/FLOAT, GZIP=compression_level, CHUNK_DIMENSIONS=chunk_dimension_vector);
            endif else begin
                dataset_id = NCDF_VARDEF(file_id, i_dataset_short_name, [dataset_lon_id,dataset_lat_id],/FLOAT);
            endelse
        endif else begin
            print, debug_module + 'ERROR, data type not supported at this point. i_data_type = ', i_data_type;
        endelse
    endelse
endelse 
CATCH, /CANCEL

; Because the function NCDF_VARDEF does not throw an exception, we have to check for the validity of the dataset_id.
; If it is -1, close the file and return.
if (dataset_id EQ -1) then begin
    print, debug_module + 'ERROR, Cannot define variable ' + i_dataset_short_name + ' for file ' + i_filename;
    o_status = FAILURE;
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    ; Must return immediately.
    return, o_status
endif

;
; Define attributes for the data set variable.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot write attribute ' + write_this_attribute + ' for the dataset for file ' + i_filename;
    o_status = FAILURE;
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    ; Must return immediately.
    return, o_status
endif

; Any errors below from the NCDF_ATTPUT function will be caught in the code segment above.
; Note that we don't explicitly call CATCH, /CANCEL after every call NCDF_ATTPUT to avoid the program from stopping due any undefined attribute.

if (N_ELEMENTS(i_long_name)) then begin
    write_this_attribute = 'long_name';
    if (debug_mode) then print, debug_module + '    NCDF_ATTPUT attribute ' + write_this_attribute + ' to variable ' + i_dataset_short_name;
    NCDF_ATTPUT,file_id,dataset_id,write_this_attribute,i_long_name;
endif
if (N_ELEMENTS(i_standard_name)) then begin
    write_this_attribute = 'standard_name';
    if (debug_mode) then print, debug_module + '    NCDF_ATTPUT attribute ' + write_this_attribute + ' to variable ' + i_dataset_short_name;
    NCDF_ATTPUT,file_id,dataset_id,write_this_attribute,i_standard_name;
endif
if (N_ELEMENTS(i_units)) then begin
    write_this_attribute = 'units';
    if (debug_mode) then print, debug_module + '    NCDF_ATTPUT attribute ' + write_this_attribute + ' to variable ' + i_dataset_short_name;
    NCDF_ATTPUT,file_id,dataset_id,write_this_attribute,        i_units;
endif
if (N_ELEMENTS(i_fill_value)) then begin
    write_this_attribute = '_FillValue';
    if (debug_mode) then print, debug_module + '    NCDF_ATTPUT attribute ' + write_this_attribute + ' to variable ' + i_dataset_short_name;
    NCDF_ATTPUT,file_id,dataset_id,write_this_attribute,   i_fill_value;
endif
if (N_ELEMENTS(i_valid_min)) then begin
    write_this_attribute = 'valid_min';
    if (debug_mode) then print, debug_module + '    NCDF_ATTPUT attribute ' + write_this_attribute + ' to variable ' + i_dataset_short_name;
    NCDF_ATTPUT,file_id,dataset_id,write_this_attribute,    i_valid_min;
endif
if (N_ELEMENTS(i_valid_max)) then begin
    write_this_attribute = 'valid_max';
    if (debug_mode) then print, debug_module + '    NCDF_ATTPUT attribute ' + write_this_attribute + ' to variable ' + i_dataset_short_name;
    NCDF_ATTPUT,file_id,dataset_id,write_this_attribute,    i_valid_max;
endif
if (N_ELEMENTS(i_comment)) then begin
    write_this_attribute = 'comment';
    if (debug_mode) then print, debug_module + '    NCDF_ATTPUT attribute ' + write_this_attribute + ' to variable ' + i_dataset_short_name;
    NCDF_ATTPUT,file_id,dataset_id,write_this_attribute,      i_comment;
endif

; Add an additional attribute: 11/14/2019

if (STRUPCASE(GETENV('GHRSST_WRITE_COVERAGE_CONTENT_TYPE_FLAG')) EQ 'TRUE') then begin
    NCDF_ATTPUT,file_id,dataset_id,"coverage_content_type",get_coverage_content_type(i_dataset_short_name);
endif

; Code used by developer to test this function.
; Change to 2 EQ 2 to purposely write the dummy attribute with a value we haven't set in i_dummy variable.
if (2 EQ 3) then begin
    write_this_attribute = 'dummy';
    if (debug_mode) then print, debug_module + '    NCDF_ATTPUT attribute ' + write_this_attribute + ' to variable ' + i_dataset_short_name;
    NCDF_ATTPUT,file_id,dataset_id,"dummy",      i_dummy;
endif

CATCH, /CANCEL

;
; Put netCDF file out of define mode and into data mode for writing:
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot set netCDF file into data mode in anticipation for writing to file ' + i_filename;
    o_status = FAILURE;
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    ; Must return immediately.
    return, o_status
endif

NCDF_CONTROL, file_id, /ENDEF
CATCH, /CANCEL

;
; Write the data set to netCDF file.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot write dataset ' + i_dataset_short_name + ' to netCDF file ' + i_filename;
    NCDF_CLOSE, file_id;
    CATCH, /CANCEL
    o_status = FAILURE;
    ; Must return immediately.
    return, o_status
endif

if (debug_mode) then print, debug_module + '    NCDF_VARPUT variable ' + i_dataset_short_name + ' to netCDF file ' + i_filename;
NCDF_VARPUT, file_id, dataset_id, i_dataset_array;
CATCH, /CANCEL

; ---------- Close up shop ---------- 

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, debug_module + 'ERROR, Cannot close file ' + i_filename;
    o_status = FAILURE;
    ; Must return immediately.
    return, o_status
endif

NCDF_CLOSE, file_id;
CATCH, /CANCEL

return, o_status
end
