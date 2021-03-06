;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

; Function convert a short into signed byte array.  The scaling factor and offset will also be calculated.

; Assumption: array is 2 dimensional.

FUNCTION apply_scaling_from_short_to_byte_for_stdv_variable,$
         i_scale_factor,$
         i_short_variable_array,$
         o_byte_variable_array,$
         o_scale_factor,$
         o_add_offset

; Load constants.

@modis_data_config.cfg

o_status = SUCCESS;

module_name = 'apply_scaling_from_short_to_byte_for_stdv_variable:';

debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

;debug_mode = 1;

; Get the dimensions of the array.

size_array = size(i_short_variable_array);

num_columns = size_array[1];
num_rows    = size_array[2];

; Allocate an integer array to hold all the values.  NetCDF will convert from integer to byte when we write it out.

o_byte_variable_array = INTARR(num_columns,num_rows,/NOZERO);

; Calculate the new o_scale_factor and o_add_offset.

o_scale_factor = 20.0 / 254.0;

; Now solve for the o_add_offset using the new o_scale_factor.

o_add_offset = (127.0 * o_scale_factor);

if (debug_mode) then begin
    print, module_name + 'i_scale_factor = ', i_scale_factor;
    print, module_name + 'o_scale_factor = ', o_scale_factor;
    print, module_name + 'o_add_offset   = ', o_add_offset;
endif

array_index = 0L;
total_elements = LONG(num_columns) * LONG(num_rows);
for array_index=0L,total_elements - 1 do begin
    o_byte_variable_array[array_index] = (i_short_variable_array[array_index] * i_scale_factor - 10.0) / o_scale_factor;
endfor

; Get the indices of the bad values.

bad_indices   = WHERE (i_short_variable_array EQ SHORT_FILL_VALUE, num_indices_bad);
good_indices  = WHERE (i_short_variable_array NE SHORT_FILL_VALUE, num_indices_good);

if (debug_mode) then begin
    print, module_name + 'SHORT_FILL_VALUE = ', SHORT_FILL_VALUE;
    print, module_name + 'num_indices_bad  = ', num_indices_bad
    print, module_name + 'num_indices_good = ', num_indices_good
endif

; Set the byte array to fill values for the bad_indices if any.

if (num_indices_bad GT 0) then begin
    if (debug_mode) then begin
        print, module_name + 'Setting o_byte_variable_array with ' + STRTRIM(STRING(num_indices_bad),2) + ' bad_indices to -128B'
    endif
    o_byte_variable_array[bad_indices] = -128B;
endif

return, o_status;
end
