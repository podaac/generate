;  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION read_netcdf_one_variable,$
         i_file_name,$
         i_variable_short_name,$
         r_data_variable_structure

; Function read one variable from a NetCDF4 file along with its attributes and returns the structure r_data_variable_structure.
;
; Assumptions:
;
;   1. The NetCDF4 file exist.
;   2. The lat and lon ids have been defined for the size of the variable.  
;

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

o_read_status = SUCCESS;
l_verbose = 0;       Set to 1 if wish to see all the debug print messages.

; Get the DEBUG_MODE if it is set.

debug_module = 'read_netcdf_one_variable:';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2_COMBINER_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

if (debug_mode) then print, debug_module, 'Entering'

; Cancel error catching in case previously other funtions did not clear.

if (debug_mode) then print, debug_module, 'PRE_CALL CATCH, /CANCEL'
CATCH, /CANCEL
if (debug_mode) then print, debug_module, 'POST_CALL CATCH, /CANCEL'

;
; Create a catch block to catch error in interaction with FILE IO
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'read_netcdf_one_variable: ERROR, Cannot open file for reading ' + i_file_name;
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

;
; Open file for reading only. 
;

if (debug_mode) then print, debug_module, 'Opening file ', i_file_name

file_id = NCDF_OPEN(i_file_name,/NOWRITE);
CATCH, /CANCEL

if (debug_mode) then print, debug_module, 'Calling read_netcdf_get_group_id with file ', i_file_name, ' file_id ', file_id

group_id = read_netcdf_get_group_id($
                  i_file_name,$
                  file_id,$
                  i_variable_short_name);

;
; Create a catch block to catch error in interaction with FILE IO
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'read_netcdf_one_variable: ERROR, Cannot get NCDF_VARID ' + i_variable_short_name + ' from file ' + i_file_name; 
    r_status = FAILURE;
    NCDF_CLOSE, file_id;    Don't forget to close the file otherwise the file handle will openedd if running within IDL space multiple times.
    ; Must return immediately.
    return, r_status
endif

if (debug_mode) then print, debug_module, 'Calling NCDF_VARID with i_variable_short_name ', i_variable_short_name;

varid = NCDF_VARID(group_id,i_variable_short_name);
CATCH, /CANCEL

; Do a sanity check to make sure the varid is not -1.  If it is, we don't continue.

if (varid EQ -1) then begin
    print, 'read_netcdf_one_variable: ERROR, Cannot get a valid varid for variable ' + i_variable_short_name + ' from file ' + i_file_name;
    r_status = FAILURE;
    NCDF_CLOSE, file_id;    Don't forget to close the file otherwise the file handle will openedd if running within IDL space multiple times.
    ; Must return immediately.
    return, r_status 
endif

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'read_netcdf_one_variable: ERROR, Cannot get NCDF_VARINQ for group_id ', group_id, ' varid ', varid;
    r_status = FAILURE;
    NCDF_CLOSE, file_id;    Don't forget to close the file otherwise the file handle will openedd if running within IDL space multiple times.
    ; Must return immediately.
    return, r_status
endif

if (debug_mode) then print, debug_module, 'Calling NCDF_VARINQ with  varid ', varid, ' group_id ', group_id;
inquire_variable_info = NCDF_VARINQ(group_id,varid)
CATCH, /CANCEL

; Save the data type as well.

;r_data_type = inquire_variable_info.datatype;

; Get the actual variable.

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'read_netcdf_one_variable: ERROR, Cannot get NCDF_VARGET for group_id ', group_id, ' varid ', varid;
    r_status = FAILURE;
    NCDF_CLOSE, file_id;    Don't forget to close the file otherwise the file handle will stay opened if running within IDL space multiple times.
    ; Must return immediately.
    return, r_status
endif

NCDF_VARGET, group_id, varid, r_variable_array;
CATCH, /CANCEL

; Something odd:  The type of sst in the ncdump is short:
; group: geophysical_data {
;  variables:
;  	short sst(Number_of_Scan_Lines, Pixels_per_Scan_Line) ;
;  		sst:long_name = "Sea Surface Temperature" ;
;  		sst:scale_factor = 0.005f ;
;  		sst:add_offset = 0.f ;
;  		sst:units = "degrees-C" ;
;  		sst:standard_name = "sea_surface_temperature" ;
;  		sst:_FillValue = -32767s ;
;  		sst:valid_min = -1000s ;
;  		sst:valid_max = 10000s ;
;
;  but the type returned from NCDF_VARGET is of type INT
; 

; Get all the variable attributes, types, and values
; Because the new file format, we pass in the group_id instead of file_id since the variable is part of a group.

read_status = get_netcdf_variable_attribute_info($
                  group_id,$
                  i_variable_short_name,$
                  o_attribute_info);

num_attributes = N_ELEMENTS(o_attribute_info);

if (debug_mode) then begin
    print, debug_module, ':INFO', 'i_file_name ', i_file_name, ' i_variable_short_name ', i_variable_short_name, '  num_attributes = ', num_attributes;
    for loop_count=0,num_attributes-1 do begin
        print, debug_module, ':INFO, o_attribute_info ', loop_count, ' ', o_attribute_info[loop_count]; 
    end
endif

;
; Create a structure to return to callee.
;

modis_data_variable_str = {  $
  s_variable_array   : PTR_NEW(), $
  s_attributes_array : STRARR(num_attributes) $
};

r_data_variable_structure = replicate(modis_data_variable_str, 1)

; Create a pointer to point to the newly read variable array.
; The data type is dynamic.

r_data_variable_structure.s_variable_array = PTR_NEW(r_variable_array,/NO_COPY);  The /NO_COPY does not make a copy (save time) but make variable r_variable_array undefined (which is OK, since we don't need it).
r_data_variable_structure.s_attributes_array = o_attribute_info;

; ---------- Close up shop ---------- 

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'read_netcdf_one_variable: ERROR, Cannot get close NetCDF file with file_id ', file_id;
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

NCDF_CLOSE, file_id;
CATCH, /CANCEL

;print, 'read_netcdf_one_variable: INFO, Just close NetCDF file with file_id ', file_id;
;stop;
if (debug_mode) then print, debug_module, 'Exiting'
return, o_read_status
end