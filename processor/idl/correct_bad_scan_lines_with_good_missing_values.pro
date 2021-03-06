;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS

FUNCTION correct_bad_scan_lines_with_good_missing_values, $
             i_array_name,$
             i_num_bad_scan_lines, $
             i_scan_line_flag_array, $
             i_fill_value, $
             io_array_to_fill

; Function fills each row of the io_array_to_fill with the i_fill_value using the indices in the
; i_scan_line_flag_array where the value is 0.
;
; Assumptions:
;
;   1. The data types of i_fill_value and io_array_to_fill are the same.
;   2. The dimension of io_array_to_fill is 2.
;   3. The indices in i_bad_scan_lines_array are within the size of the array io_array_to_fill.
;

;------------------------------------------------------------------------------------------------

; Load constants.

@modis_data_config.cfg

; Define local variables.

r_status = SUCCESS;

; Get the DEBUG_MODE if it is set.
;append_ancillary_data_variable_gds2
debug_module = 'correct_bad_scan_lines_with_good_missing_values:';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1; 
endif

;
; Do nothing if there are no bad scan lines.  The value of i_num_bad_scan_lines can be negative
; or zero but then we don't do anything anyhow.
;

if (i_num_bad_scan_lines LE 0) then return, r_status;


; Get the size of the incoming array.

;print, 'correct_bad_scan_lines_with_good_missing_values: before size()';

size_array = size(io_array_to_fill);

;print, 'correct_bad_scan_lines_with_good_missing_values: after size()';

; Extract individual dimensions.
;
; Indices      Value
;   0          number of dimensions
;   1          columns
;   2          rows
;   3          data type
;   4          number of elements

if (size_array[0] NE 2) then begin
    print, 'correct_bad_scan_lines_with_good_missing_values: ERROR, Incoming array must be of two dimensions';
    print, 'correct_bad_scan_lines_with_good_missing_values: i_array_name = ', i_array_name
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

;
; Get the two dimensions.
;

num_lats = size_array[1]; 
num_lons = size_array[2]; 

;help, num_lats;
;help, num_lons;

if (i_num_bad_scan_lines GT num_lons) then begin
    print, 'correct_bad_scan_lines_with_good_missing_values: ERROR, Number of bad scan lines cannot be greater than num_lons';
    print, 'correct_bad_scan_lines_with_good_missing_values: i_array_name           = ', i_array_name;
    print, 'correct_bad_scan_lines_with_good_missing_values: i_num_bad_scan_lines   = ', i_num_bad_scan_lines; 
    print, 'correct_bad_scan_lines_with_good_missing_values: num_lats               = ', num_lats; 
    print, 'correct_bad_scan_lines_with_good_missing_values: num_lons               = ', num_lons; 
    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
end

;
; Get the indices where the values are zero.  We expect there will be at least one since there
; are bad scan lines if the code got to here.
;

bad_longitude_lines_array = where(i_scan_line_flag_array EQ 0, count_bad);

;print, 'correct_bad_scan_lines_with_good_missing_values: count_bad = ', count_bad;
;print, 'correct_bad_scan_lines_with_good_missing_values: i_array_name = ', i_array_name; 
;print, 'correct_bad_scan_lines_with_good_missing_values  i_fill_value = ', i_fill_value;

if (count_bad GT 0) then begin
    ;
    ; For each bad scan (longitude) line, we fill that line (going across) with the fill value.  
    ;

    io_array_to_fill[*,bad_longitude_lines_array] = i_fill_value;
;    one_bad_value_index = bad_longitude_lines_array[0]; 
;    print, 'correct_bad_scan_lines_with_good_missing_values  io_array_to_fill[0,',one_bad_value_index,$
;           '] = ', io_array_to_fill[0,one_bad_value_index];

    if (debug_mode) then begin
        print, debug_module + 'Corrected ', count_bad, ' values ' + ' in variable ' + i_array_name;
    endif
endif

; ---------- Close up shop ---------- 

return, r_status
end
