;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION parse_attribute_array,$
         i_variable_name,$
         i_attribute_type,$
         i_raw_attribute_value,$
         o_attribute_value

; Function parse an attribute {flag_masks,flag_meanings}.  The attribute is a string that may contain a series of values.  If that is the case, the returned value
; will be an array, i.e.
;
; flag_masks|LONG|1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536,131072,262144,524288,1048576,2097152,4194304,8388608,16777216,33554432,67108864,134217728,268435456,536870912,1073741824,-2147483648
; flag_meanings|BYTE|ATMFAIL LAND PRODWARN HIGLINT HILT HISATZEN COASTZ SPARE STRAYLIGHT CLDICE COCCOLITH TURBIDW HISOLZEN SPARE LOWLW CHLFAIL NAVWARN ABSAER SPARE MAXAERITER MODGLINT CHLWARN ATMWARN SPARE SEAICE NAVFAIL FILTER SPARE SPARE HIPOL PRODFAIL SPARE
;
; If i_variable_name is not defined or empty string, function will return an empty string.
;
; Assumptions:
;
;   1. This function treats the FLOAT array as one value only so do not expect to get an array of floats here.
;

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

debug_flag = 0;

; Get the DEBUG_MODE if it is set.

debug_module = 'parse_attribute_array:';
if (STRUPCASE(GETENV('GHRSST_MODIS_L2_COMBINER_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_flag = 1;
endif

; Set default return value.
; This is a design decision: to return an empty string instead of an undefined value.  The function
; that calls this, must do a check for empty string instead of an undefined value.

o_attribute_value = '';  This can be anything from string to float, to double, to byte.

array_index = 0;
found_variable_name_flag = 0;

if (debug_flag) then begin
    print, debug_module + 'i_variable_name    [' + i_variable_name + ']';
    print, debug_module + 'i_raw_attribute_value [' + i_raw_attribute_value + ']';
endif

        if (i_attribute_type EQ "BYTE") then begin
            ; Check to see if the attribute is an ARRAY: ARRAY 3 1b 2b 3b
            ; If it is, we have to break up all the tokens and store them into an array.
            last_token = i_raw_attribute_value;
            num_of_values = 0;
            ELEMENTS_OFFSET = 0;  We skip the first 2 tokens "ARRAY 3" to get to "1b"
            if (STRCMP(last_token,"ARRAY",5)) then begin
                tokens_array = STRSPLIT(i_raw_attribute_value,/EXTRACT);
                num_of_values = tokens_array[1];
                ELEMENTS_OFFSET = 2;  We skip the first 2 tokens "ARRAY 3" to get to "1b"
            endif else begin
                tokens_array = STRSPLIT(i_raw_attribute_value,/EXTRACT);  Split using spaces
                num_of_values = N_ELEMENTS(tokens_array)
                ; If there is only 1 value, using the comma to split. 
                if (num_of_values LE 1) then begin
                    tokens_array = STRSPLIT(i_raw_attribute_value,',',/EXTRACT);  Split using comma
                    num_of_values = N_ELEMENTS(tokens_array)
                endif
            endelse
            value_index = 0;
            if (num_of_values GT 1) then begin
                o_attribute_value = BYTARR(num_of_values);
                while (value_index LT num_of_values) do begin
                    o_attribute_value[value_index] = tokens_array[ELEMENTS_OFFSET + value_index];
                    value_index = value_index + 1;
                endwhile
            endif else begin
                o_attribute_value = BYTE(FIX(tokens_array[ELEMENTS_OFFSET + value_index]));
            endelse

        endif
        if (i_attribute_type EQ "FLOAT") then begin
            o_attribute_value = FLOAT(i_raw_attribute_value);
        endif
        if (i_attribute_type EQ "LONG") then begin
            ; Check to see if the attribute is an ARRAY: ARRAY 32 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32
            ; If it is, we have to break up all the tokens and store them into an array.
            last_token = i_raw_attribute_value;
            num_of_values = 0;
            ELEMENTS_OFFSET = 0;  We skip the first 2 tokens "ARRAY 32" to get to "1"
            if (STRCMP(last_token,"ARRAY",5)) then begin
                tokens_array = STRSPLIT(i_raw_attribute_value,/EXTRACT);
                num_of_values = tokens_array[1];
                ELEMENTS_OFFSET = 2;  We skip the first 2 tokens "ARRAY 32" to get to "1"
            endif else begin
                tokens_array = STRSPLIT(i_raw_attribute_value,/EXTRACT);  Split using spaces
                num_of_values = N_ELEMENTS(tokens_array)
                ; If there is only 1 value, using the comma to spli. 
                if (num_of_values LE 1) then begin
                    tokens_array = STRSPLIT(i_raw_attribute_value,',',/EXTRACT);  Split using comma
                    num_of_values = N_ELEMENTS(tokens_array)
                endif
            endelse
            value_index = 0;
            o_attribute_value = LONARR(num_of_values);
            while (value_index LT num_of_values) do begin
                o_attribute_value[value_index] = tokens_array[ELEMENTS_OFFSET + value_index];
                value_index = value_index + 1;
            end
        endif
        if (i_attribute_type EQ "INT") OR (i_attribute_type EQ "SHORT") then begin

            ; Check to see if the attribute is an ARRAY: ARRAY 32 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32
            ; If it is, we have to break up all the tokens and store them into an array.
            last_token = i_raw_attribute_value;
            num_of_values = 0;
            ELEMENTS_OFFSET = 0;  We skip the first 2 tokens "ARRAY 32" to get to "1"
            if (STRCMP(last_token,"ARRAY",5)) then begin
                tokens_array = STRSPLIT(i_raw_attribute_value,/EXTRACT);
                num_of_values = tokens_array[1];
                ELEMENTS_OFFSET = 2;  We skip the first 2 tokens "ARRAY 32" to get to "1"
            endif else begin
                tokens_array = STRSPLIT(i_raw_attribute_value,/EXTRACT);  Split using spaces
                num_of_values = N_ELEMENTS(tokens_array)
                ; If there is only 1 value, using the comma to spli. 
                if (num_of_values LE 1) then begin
                    tokens_array = STRSPLIT(i_raw_attribute_value,',',/EXTRACT);  Split using comma
                    num_of_values = N_ELEMENTS(tokens_array)
                endif
            endelse
            value_index = 0;
            o_attribute_value = INTARR(num_of_values);
            while (value_index LT num_of_values) do begin
                o_attribute_value[value_index] = tokens_array[ELEMENTS_OFFSET + value_index];
                value_index = value_index + 1;
            end
        endif

        if (i_attribute_type EQ "STRING") then begin
            o_attribute_value = STRING(i_raw_attribute_value);
        endif

if (debug_flag) then begin
    print, debug_module + 'i_variable_name   [', i_variable_name, ']';
    print, debug_module + 'o_attribute_value [', o_attribute_value , ']';
    print, debug_module + 'SIZE(o_attribute_value,/TNAME) [', SIZE(o_attribute_value,/TNAME) , ']';
endif

; ---------- Close up shop ---------- 
return, o_attribute_value;
end
