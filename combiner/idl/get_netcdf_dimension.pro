;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION get_netcdf_dimension,$
             i_netcdf_input_filename,$
             i_dimension_name,$
             o_dimension_value

; Function returns the dimension value given the dimension name.
;
; Assumptions:
;
;   1. The NetCDF4 file exists.
;

;------------------------------------------------------------------------------------------------
; Load constants.

@modis_data_config.cfg

o_status = SUCCESS; 
o_dimension_value = -1;  This is default output value.

debug_flag = 0;

;
; Create a catch block to catch error in interaction with FILE IO
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'get_netcdf_dimensions: ERROR, Cannot open file for reading ' + i_netcdf_input_filename;
    o_status = FAILURE;
    ; Must return immediately.
    return, o_status
endif

;
; Open file for reading only.
;

file_id = ncdf_open(i_netcdf_input_filename,/NOWRITE);

; Create an array to hold all the dimension names and value.

MAX_NUM_DIMS = 5;
dimension_names_array  = STRARR(MAX_NUM_DIMS);
dimension_values_array = LONARR(MAX_NUM_DIMS);

; Get all the dimension names and values from the file.

num_dim_inspected = 0;
dum_dim_id        = 0;

WHILE (num_dim_inspected LT MAX_NUM_DIMS) DO BEGIN

    ;
    ; Create a catch block to catch error in interaction with FILE IO
    ;

    CATCH, error_status
    if (error_status NE 0) then begin
        CATCH, /CANCEL
        print, 'get_netcdf_dimension: ERROR, Cannot get global attribute ' + i_attribute_name + ' from file ' + i_netcdf_input_filename
        o_status = FAILURE;
        ; Must return immediately.
        return, o_status
    endif

    if (debug_flag) then begin
        print, 'get_netcdf_dimension: NCDF_DIMINQ ' + i_attribute_name
    endif
    NCDF_DIMINQ, file_id, num_dim_inspected, dim_name, dim_size;  Use the num_dim_inspected as the dimension id since it starts at 0.
    CATCH, /CANCEL

    ; Save the dimension name and values.

    dimension_names_array[num_dim_inspected] = dim_name;
    dimension_values_array[num_dim_inspected] = dim_size;

    num_dim_inspected = num_dim_inspected + 1;
    dum_dim_id        = dum_dim_id + 1;
ENDWHILE

; If testing reading bad long attribute, tweak the name of the dimension so it couldn't possibly be found.

dimension_name_to_look_for = i_dimension_name;

if (GETENV('GHRSST_MODIS_COMBINER_FAILED_READ_LONG_ATTRIBUTE_TEST') EQ 'true') then begin
    if (i_dimension_name EQ 'number_of_lines') then begin
        dimension_name_to_look_for = 'BAD_ATTRIBUTE_number_of_lines';
    endif
    if (i_dimension_name EQ 'pixel_control_points') then begin
        dimension_name_to_look_for = 'BAD_ATTRIBUTE_pixel_control_points';
    endif
endif

; If testing reading missing global attribute, tweak the name of the dimension so it couldn't possibly be found.

if (GETENV('GHRSST_MODIS_COMBINER_CREATE_MISSING_ATTRIBUTE') EQ 'pixel_control_points') then begin
    if (i_dimension_name EQ 'pixel_control_points') then begin
        dimension_name_to_look_for = 'BAD_ATTRIBUTE_pixel_control_points';
    endif
endif

if (GETENV('GHRSST_MODIS_COMBINER_CREATE_MISSING_ATTRIBUTE') EQ 'scan_control_points') then begin
    if (i_dimension_name EQ 'number_of_lines') then begin
        dimension_name_to_look_for = 'BAD_ATTRIBUTE_number_of_lines';
    endif
endif

; Now, return the correct dimension value based on what the user requested.

num_dim_inspected = 0;
found_dimension_name_flag = 0;
WHILE ((num_dim_inspected LT MAX_NUM_DIMS) AND (found_dimension_name_flag EQ 0)) DO BEGIN
    if (dimension_names_array[num_dim_inspected] EQ dimension_name_to_look_for) then begin
        o_dimension_value = dimension_values_array[num_dim_inspected];
        found_dimension_name_flag = 1;
    endif
    num_dim_inspected = num_dim_inspected + 1;
ENDWHILE

if (found_dimension_name_flag EQ 0) then begin
    o_status = FAILURE;
endif

; ---------- Close up shop ---------- 

;
; Create a catch block to catch error in interaction with FILE IO.
;

CATCH, error_status
if (error_status NE 0) then begin
   CATCH, /CANCEL
   print, 'get_netcdf_dimension: ERROR, Cannot close input file: ', i_netcdf_input_filename;
   o_status = FAILURE;
   ; Must return immediately.
   return, o_status
endif
NCDF_CLOSE, file_id;
CATCH, /CANCEL

;print, 'get_netcdf_dimension: INFO, i_dimension_name  = ', i_dimension_name;
;print, 'get_netcdf_dimension: INFO, o_dimension_value = ', o_dimension_value ;

return, o_status;
end