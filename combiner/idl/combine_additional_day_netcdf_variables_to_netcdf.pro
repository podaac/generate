;  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION combine_additional_day_netcdf_variables_to_netcdf,i_filename,i_num_lons,i_num_lats,i_out_filename

; Function combine additional NetCDF variables to write to NetCDF if the file is marked "Day"
;
; Assumptions:
;
;   1. 
;
;------------------------------------------------------------------------------------------------

; Load constants.

@modis_data_config.cfg

; Define local variables.

r_status = SUCCESS;

routine_name = "combine_additional_day_netcdf_variables_to_netcdf";
msg_type = "";
i_data = "";

; Get the DEBUG_MODE if it is set.
debug_module = 'combine_additional_day_netcdf_variables_to_netcdf:';
debug_flag = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2_COMBINER_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_flag = 1;
endif

r_long_name = "DUMMY_LONG_NAME";
r_units     = "DUMMY_UNITS";

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Read additional day arrays from NetCDF file and write to NetCDF file.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;--------------------------------------------------------------------------------
; Read chlor_a from NetCDF file.
;--------------------------------------------------------------------------------

variable_short_name = 'chlor_a';

if (debug_flag) then print, debug_module, 'Calling read_netcdf_one_variable file ', i_filename , ' variable_short_name ', variable_short_name;

r_status =  read_netcdf_one_variable(i_filename,$
                                     variable_short_name,$
                                     o_data_variable_structure);

if (GETENV('GHRSST_MODIS_COMBINER_FAILED_CHLOR_A_VARIABLE_READ_TEST') EQ 'true') then r_status = FAILURE;

if (r_status EQ FAILURE) then begin
    msg_type = "warning";
    msg = 'Cannot read variable ' + variable_short_name + ' from file ' + i_filename;

    donotcare = echo_message_to_screen(routine_name,msg,msg_type);
    donotcare = error_log_writer(routine_name,msg);
    donotcare = wrapper_ghrsst_notify_operator($
                        routine_name,$
                        msg_type,$
                        msg,$
                        i_data);
    ; keep going
endif else begin
    r_dataset_array = *(o_data_variable_structure.s_variable_array);
    PTR_FREE,o_data_variable_structure.s_variable_array;
    r_status = find_netcdf_variable_attribute_info('scale_factor',o_data_variable_structure.s_attributes_array,r_slope);
    r_status = find_netcdf_variable_attribute_info('add_offset',o_data_variable_structure.s_attributes_array,r_intercept);
    r_status = find_netcdf_variable_attribute_info('units',o_data_variable_structure.s_attributes_array,r_units);
    r_status = find_netcdf_variable_attribute_info('long_name',o_data_variable_structure.s_attributes_array,r_long_name);
    r_status = find_netcdf_variable_attribute_info('_FillValue',o_data_variable_structure.s_attributes_array,r_fill_value);
    r_status = find_netcdf_variable_attribute_info('valid_min',o_data_variable_structure.s_attributes_array,r_valid_min);
    r_status = find_netcdf_variable_attribute_info('valid_max',o_data_variable_structure.s_attributes_array,r_valid_max);
    data_type_as_int = SIZE(r_dataset_array,/TYPE);
    r_data_type = convert_int_type_to_char_type(data_type_as_int);

    ; The chlor_a variable in the NetCDF file may not have slope and intercept.  We have to set them to default value of 1.0 and 0.0
    ; Note that these values are of FLOAT type since the write_control_points_variable_to_netcdf() expects them to be FLOAT.
    if (debug_flag) then begin
        print, debug_module,'PRE_CHECK:variable_short_name      = ', variable_short_name;
        print, debug_module,'PRE_CHECK:r_slope                    = ', r_slope;
        print, debug_module,'PRE_CHECK:r_intercept                = ', r_intercept;
    endif
    if ((~(N_ELEMENTS(r_slope)))     OR (r_slope EQ '')) then begin
        r_slope = 1.0;
    endif 
    if ((~(N_ELEMENTS(r_intercept))) OR (r_intercept EQ '')) then begin
        r_intercept = 0.0;
    endif 

    tweak_fill_value_flag = 0;
    if ((~(N_ELEMENTS(r_fill_value))) OR (r_fill_value EQ '')) then begin
        r_fill_value = -32767s;
        tweak_fill_value_flag = 1;
    endif

    tweak_valid_min_value_flag = 0;
    if ((~(N_ELEMENTS(r_valid_min))) OR (r_valid_min EQ '')) then begin
        r_valid_min = 0.001;
        tweak_valid_min_value_flag = 1;
    endif

    tweak_valid_max_value_flag = 0;
    if ((~(N_ELEMENTS(r_valid_max))) OR (r_valid_max EQ '')) then begin
        r_valid_max = 100.0;
        tweak_valid_max_value_flag = 1;
    endif

    if (debug_flag) then begin
        print, debug_module,'variable_short_name        = ', variable_short_name;
        print, debug_module,'r_slope                    = ', r_slope;
        print, debug_module,'r_intercept                = ', r_intercept;
        print, debug_module,'tweak_fill_value_flag      = ', tweak_fill_value_flag;
        print, debug_module,'tweak_valid_min_value_flag = ', tweak_valid_min_value_flag;
        print, debug_module,'tweak_valid_max_value_flag = ', tweak_valid_max_value_flag ;
        print, debug_module,'r_fill_value               = ', r_fill_value;
        print, debug_module,'r_valid_min                = ', r_valid_min 
        print, debug_module,'r_valid_max                = ', r_valid_max 
        if (tweak_fill_value_flag)      then print, debug_module,'TWEAKED:r_fill_value = ', r_fill_value
        if (tweak_valid_min_value_flag) then print, debug_module,'TWEAKED:r_valid_min = ', r_valid_min
        if (tweak_valid_max_value_flag) then print, debug_module,'TWEAKED:r_valid_max = ', r_valid_max
    endif

    ; Validate the variable dimensions and type.

    o_variable_valid_flag = validate_variable_dimensions($
                                i_filename,$
                                variable_short_name,$
                                i_num_lons,$       ; Same as Number_of_Scan_Lines = 2030
                                i_num_lats,$       ; Same as pixel_control_points = 1354
                                r_dataset_array);

    if (o_variable_valid_flag NE 1) then begin
        ; Must return immediately.
        return, FAILURE;
    endif

    if (debug_flag) then begin
        print, 'combine_additional_day_netcdf_variables_to_netcdf: INFO, i_filename            = ', i_filename; 
        print, 'combine_additional_day_netcdf_variables_to_netcdf: INFO, variable_short_name   = ', variable_short_name; 
        print, 'combine_additional_day_netcdf_variables_to_netcdf: INFO, r_data_type           = ', r_data_type;
        print, 'combine_additional_day_netcdf_variables_to_netcdf: INFO, r_slope = [', r_slope, ']';
        print, 'combine_additional_day_netcdf_variables_to_netcdf: INFO, r_intercept = [', r_intercept, ']';
        if (N_ELEMENTS(r_fill_value)) then begin
            print, debug_module,'r_fill_value  : ', r_fill_value;
        endif
        if (N_ELEMENTS(r_valid_min)) then begin
            print, debug_module,'r_valid_min   : ', r_valid_min;
        endif
        if (N_ELEMENTS(r_valid_max)) then begin
            print, debug_module,'r_valid_max   : ', r_valid_max;
        endif
    endif

    r_status = write_control_points_variable_to_netcdf(i_out_filename,variable_short_name,$
                           r_dataset_array , r_long_name,$
                           r_units,r_data_type,r_slope,r_intercept,r_fill_value,r_valid_min,r_valid_max);

    if (GETENV('GHRSST_MODIS_COMBINER_FAILED_CHLOR_A_VARIABLE_WRITE_TEST') EQ 'true') then r_status = FAILURE;

    if (r_status NE SUCCESS) then begin
        msg_type = "warning";
        msg = 'Cannot write variable ' + variable_short_name + ' to file ' + i_out_filename;
   
        donotcare = echo_message_to_screen(routine_name,msg,msg_type);
        donotcare = error_log_writer(routine_name,msg);
        donotcare = wrapper_ghrsst_notify_operator($
                            routine_name,$
                            msg_type,$
                            msg,$
                            i_data);
        ; Keep going
    endif

endelse

;--------------------------------------------------------------------------------
; Read Kd_490 from NetCDF file.
;--------------------------------------------------------------------------------

variable_short_name = 'Kd_490';

if (debug_flag) then print, debug_module, 'Calling read_netcdf_one_variable file ', i_filename , ' variable_short_name ', variable_short_name;

r_status =  read_netcdf_one_variable(i_filename,$
                                     variable_short_name,$
                                     o_data_variable_structure);

if (GETENV('GHRSST_MODIS_COMBINER_FAILED_KD_490_VARIABLE_READ_TEST') EQ 'true') then r_status = FAILURE;

if (r_status EQ FAILURE) then begin
    msg_type = "warning";
    msg = 'Cannot read variable ' + variable_short_name + ' from file ' + i_filename;

    donotcare = echo_message_to_screen(routine_name,msg,msg_type);
    donotcare = error_log_writer(routine_name,msg);
    donotcare = wrapper_ghrsst_notify_operator($
                    routine_name,$
                    msg_type,$
                    msg,$
                    i_data);
    ; Keep going
endif else begin
    r_dataset_array = *(o_data_variable_structure.s_variable_array);
    PTR_FREE,o_data_variable_structure.s_variable_array;
    r_status = find_netcdf_variable_attribute_info('scale_factor',o_data_variable_structure.s_attributes_array,r_slope);
    r_status = find_netcdf_variable_attribute_info('add_offset',o_data_variable_structure.s_attributes_array,r_intercept);
    r_status = find_netcdf_variable_attribute_info('units',o_data_variable_structure.s_attributes_array,r_units);
    r_status = find_netcdf_variable_attribute_info('long_name',o_data_variable_structure.s_attributes_array,r_long_name);
    r_status = find_netcdf_variable_attribute_info('_FillValue',o_data_variable_structure.s_attributes_array,r_fill_value);
    r_status = find_netcdf_variable_attribute_info('valid_min',o_data_variable_structure.s_attributes_array,r_valid_min);
    r_status = find_netcdf_variable_attribute_info('valid_max',o_data_variable_structure.s_attributes_array,r_valid_max);
    data_type_as_int = SIZE(r_dataset_array,/TYPE);
    r_data_type = convert_int_type_to_char_type(data_type_as_int);
    variable_short_name = 'K_490';

    ; The Kd_490 variable in the NetCDF file may not have slope and intercept.  We have to set them to default value of 1 and 0.0
    ; Note that these values are of FLOAT type since the write_control_points_variable_to_netcdf() expects them to be FLOAT.
    if (debug_flag) then begin
        print, debug_module,'PRE_CHECK:variable_short_name        = ', variable_short_name;
        print, debug_module,'PRE_CHECK:r_slope                    = ', r_slope;
        print, debug_module,'PRE_CHECK:r_intercept                = ', r_intercept;
    endif
    if ((~N_ELEMENTS(r_slope))     OR (r_slope EQ '')) then begin
        r_slope = 1.0;
    endif
    if ((~N_ELEMENTS(r_intercept)) OR (r_intercept EQ '')) then begin
        r_intercept = 0.0;
    endif

    ; If some attributes are not provided, we hard-code the values here.
    
    tweak_fill_value_flag = 0;
    if ((~(N_ELEMENTS(r_fill_value))) OR (r_fill_value EQ '')) then begin
        r_fill_value = -32767s;
        tweak_fill_value_flag = 1;
    endif 

    tweak_valid_min_value_flag = 0;
    if ((~(N_ELEMENTS(r_valid_min))) OR (r_valid_min EQ '')) then begin
        r_valid_min = 50s;
        tweak_valid_min_value_flag = 1;
    endif

    tweak_valid_max_value_flag = 0;
    if ((~(N_ELEMENTS(r_valid_max))) OR (r_valid_max EQ '')) then begin
        r_valid_max = 30000s;
        tweak_valid_max_value_flag = 1;
    endif

    if (debug_flag) then begin
        print, debug_module,'variable_short_name        = ', variable_short_name;
        print, debug_module,'r_slope                    = ', r_slope;
        print, debug_module,'r_intercept                = ', r_intercept;
        print, debug_module,'tweak_fill_value_flag      = ', tweak_fill_value_flag;
        print, debug_module,'tweak_valid_min_value_flag = ', tweak_valid_min_value_flag;
        print, debug_module,'tweak_valid_max_value_flag = ', tweak_valid_max_value_flag ;
        print, debug_module,'r_fill_value               = ', r_fill_value;
        print, debug_module,'r_valid_min                = ', r_valid_min 
        print, debug_module,'r_valid_max                = ', r_valid_max 
        if (tweak_fill_value_flag) then print, debug_module,'TWEAKED:r_fill_value = ', r_fill_value
        if (tweak_valid_min_value_flag) then print, debug_module,'TWEAKED:r_valid_min = ', r_valid_min
        if (tweak_valid_max_value_flag) then print, debug_module,'TWEAKED:r_valid_max = ', r_valid_max
    endif

    ; Validate the variable dimensions and type.

    o_variable_valid_flag = validate_variable_dimensions($
                                i_filename,$
                                variable_short_name,$
                                i_num_lons,$       ; Same as Number_of_Scan_Lines = 2030
                                i_num_lats,$       ; Same as pixel_control_points = 1354
                                r_dataset_array);

    if (o_variable_valid_flag NE 1) then begin
        ; Must return immediately.
        return, FAILURE;
    endif

    if (debug_flag) then begin
        print, 'combine_additional_day_netcdf_variables_to_netcdf: INFO, variable_short_name   = ', variable_short_name; 
        print, 'combine_additional_day_netcdf_variables_to_netcdf: INFO, r_data_type           = ', r_data_type;
        print, 'combine_additional_day_netcdf_variables_to_netcdf: INFO, r_slope               = ', r_slope;
        print, 'combine_additional_day_netcdf_variables_to_netcdf: INFO, r_intercept           = ', r_intercept;
        if (N_ELEMENTS(r_fill_value)) then begin
            print, debug_module,'r_fill_value  : ', r_fill_value;
        endif
        if (N_ELEMENTS(r_valid_min)) then begin
            print, debug_module,'r_valid_min   : ', r_valid_min;
        endif
        if (N_ELEMENTS(r_valid_max)) then begin
            print, debug_module,'r_valid_max   : ', r_valid_max;
        endif
    endif

    r_status = write_control_points_variable_to_netcdf(i_out_filename,variable_short_name,$
                           r_dataset_array , r_long_name,$
                           r_units,r_data_type,r_slope,r_intercept,r_fill_value,r_valid_min,r_valid_max);

    if (GETENV('GHRSST_MODIS_COMBINER_FAILED_KD_490_VARIABLE_WRITE_TEST') EQ 'true') then r_status = FAILURE;

    if (r_status NE SUCCESS) then begin
        msg_type = "warning";
        msg = 'Cannot write variable ' + variable_short_name + ' to file ' + i_out_filename;

        donotcare = echo_message_to_screen(routine_name,msg,msg_type);
        donotcare = error_log_writer(routine_name,msg);
        donotcare = wrapper_ghrsst_notify_operator($
                            routine_name,$
                            msg_type,$
                            msg,$
                            i_data);
        ; Keep going
    endif
endelse

; ---------- Close up shop ---------- 

return, r_status
end
