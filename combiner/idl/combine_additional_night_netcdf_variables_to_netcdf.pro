;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION combine_additional_night_netcdf_variables_to_netcdf,i_filename,i_num_lons,i_num_lats,i_out_filename

; Function combine additional NetCDF variables to HDF file if the data was marked as "Night" or "Mixed".
;
; Assumptions:
;
;   1. TBD.
;
; Notes:
;
;   1.  August 2014: A major revamp of error handling.  Because a night variable is optional, if a variable
;       cannot be read, a message will echoed to screen, loggged to error file and a WARN sigevent will be raised.

;------------------------------------------------------------------------------------------------

; Load constants.

@modis_data_config.cfg

; Define local variables.

r_status = SUCCESS;

routine_name = "combine_additional_night_netcdf_variables_to_netcdf";
msg_type = "";
i_data = "";

; Get the DEBUG_MODE if it is set.
debug_module = 'combine_additional_night_netcdf_variables_to_netcdf:';
debug_flag = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2_COMBINER_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_flag = 1;
endif

r_long_name = "DUMMY_LONG_NAME";
r_units     = "DUMMY_UNITS";

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Read additional night arrays from NetCDF file and write to HDF file.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

i_variable_short_name = 'sst4';

r_status =  read_netcdf_one_variable(i_filename,$
                                     i_variable_short_name,$
                                     o_data_variable_structure);

if (GETENV('GHRSST_MODIS_COMBINER_FAILED_SST4_VARIABLE_READ_TEST') EQ 'true') then r_status = FAILURE;

if (r_status EQ FAILURE) then begin
    msg_type = "warning";
    msg = 'Cannot read variable ' + i_variable_short_name + ' from file ' + i_filename;

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

    ; If the variable does not have slope and intercept, we set them to 1.0 and 0.0;
    ; Note that these values are of FLOAT type since the write_control_points_variable_to_netcdf() expects them to be FLOAT.
;help, r_slope
    if (N_ELEMENTS(r_slope) NE 0) then begin
        if (r_slope EQ '') then r_slope = 1.0;  If the variable is a string, we set it to a default.
    endif
;help, r_slope
;help, r_intercept
    if (N_ELEMENTS(r_intercept) NE 0) then begin
        if (r_intercept EQ '') then r_intercept = 0.0;  If the variable is a string, we set it to a default.
    endif
;help, r_intercept
;stop;
    ; Validate the variable dimensions and type.

    o_variable_valid_flag = validate_variable_dimensions($
                                i_filename,$
                                i_variable_short_name,$
                                i_num_lons,$       ; Same as Number_of_Scan_Lines = 2030
                                i_num_lats,$       ; Same as pixel_control_points = 1354
                                r_dataset_array);

    if (o_variable_valid_flag NE 1) then begin
        ; Must return immediately.
        return, FAILURE;
    endif

    if (debug_flag) then begin
        print, debug_module,': INFO, i_filename = ', i_filename; 
        print, debug_module,': INFO, i_variable_short_name = ', i_variable_short_name; 
        print, debug_module,': INFO, r_data_type           = ', r_data_type;
        print, debug_module,': INFO, r_slope = [', r_slope, ']';
        print, debug_module,': INFO, r_intercept = [', r_intercept, ']';
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

    r_status = write_control_points_variable_to_netcdf(i_out_filename,i_variable_short_name,$
                           r_dataset_array , r_long_name,$
                           r_units,r_data_type,r_slope,r_intercept,r_fill_value,r_valid_min,r_valid_max);

    if (GETENV('GHRSST_MODIS_COMBINER_FAILED_SST4_VARIABLE_WRITE_TEST') EQ 'true') then r_status = FAILURE;

    if (r_status NE SUCCESS) then begin
        msg_type = "warning";
        msg = 'Cannot write variable ' + i_variable_short_name + ' to file ' + i_out_filename;
    
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
; Read bias_sst4 from NetCDF file.
;--------------------------------------------------------------------------------

i_variable_short_name = 'bias_sst4';

r_status =  read_netcdf_one_variable(i_filename,$
                                     i_variable_short_name,$
                                     o_data_variable_structure);

if (GETENV('GHRSST_MODIS_COMBINER_FAILED_BIAS_SST4_VARIABLE_READ_TEST') EQ 'true') then r_status = FAILURE;

if (r_status EQ FAILURE) then begin
    msg_type = "warning";
    msg = 'Cannot read variable ' + i_variable_short_name + ' from file ' + i_filename;

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

    ; If the variable does not have slope and intercept, we set them to 1.0 and 0.0 respectively.
    ; Note that these values are of FLOAT type since the write_control_points_variable_to_netcdf() expects them to be FLOAT.
    if (N_ELEMENTS(r_slope) NE 0) then begin
        if (r_slope EQ '') then r_slope = 1.0;  If the variable is a string, we set it to a default.
    endif
    if (N_ELEMENTS(r_intercept) NE 0) then begin
        if (r_intercept EQ '') then r_intercept = 0.0;  If the variable is a string, we set it to a default.
    endif

    ; Validate the variable dimensions and type.

    o_variable_valid_flag = validate_variable_dimensions($
                                i_filename,$
                                i_variable_short_name,$
                                i_num_lons,$       ; Same as Number_of_Scan_Lines = 2030
                                i_num_lats,$       ; Same as pixel_control_points = 1354
                                r_dataset_array);

    if (o_variable_valid_flag NE 1) then begin
        ; Must return immediately.
        return, FAILURE;
    endif

    if (debug_flag) then begin
        print, debug_module,': INFO, i_filename = ', i_filename; 
        print, debug_module,': INFO, i_variable_short_name = ', i_variable_short_name; 
        print, debug_module,': INFO, r_data_type           = ', r_data_type;
        print, debug_module,': INFO, r_slope = [', r_slope, ']';
        print, debug_module,': INFO, r_intercept = [', r_intercept, ']';
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

    r_status = write_control_points_variable_to_netcdf(i_out_filename,i_variable_short_name,$
                           r_dataset_array , r_long_name,$
                           r_units,r_data_type,r_slope,r_intercept,r_fill_value,r_valid_min,r_valid_max);

    if (GETENV('GHRSST_MODIS_COMBINER_FAILED_BIAS_SST4_VARIABLE_WRITE_TEST') EQ 'true') then r_status = FAILURE;

    if (r_status NE SUCCESS) then begin
        msg_type = "warning";
        msg = 'Cannot write variable ' + i_variable_short_name + ' to file ' + i_out_filename;

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
; Read stdv_sst4 from NetCDF file.
;--------------------------------------------------------------------------------

i_variable_short_name = 'stdv_sst4';

r_status =  read_netcdf_one_variable(i_filename,$
                                     i_variable_short_name,$
                                     o_data_variable_structure);

if (GETENV('GHRSST_MODIS_COMBINER_FAILED_STDV_SST4_VARIABLE_READ_TEST') EQ 'true') then r_status = FAILURE;

if (r_status EQ FAILURE) then begin
    msg_type = "warning";
    msg = 'Cannot read variable ' + i_variable_short_name + ' from file ' + i_filename;
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

    ; If the variable does not have slope and intercept, we set them to 1.0 and 0.0 respectively.
    ; Note that these values are of FLOAT type since the write_control_points_variable_to_netcdf() expects them to be FLOAT.
    if (N_ELEMENTS(r_slope) NE 0) then begin
        if (r_slope EQ '') then r_slope = 1.0;  If the variable is a string, we set it to a default.
    endif
    if (N_ELEMENTS(r_intercept) NE 0) then begin
        if (r_intercept EQ '') then r_intercept = 0.0;  If the variable is a string, we set it to a default.
    endif

    ; Validate the variable dimensions and type.

    o_variable_valid_flag = validate_variable_dimensions($
                                i_filename,$
                                i_variable_short_name,$
                                i_num_lons,$       ; Same as Number_of_Scan_Lines = 2030
                                i_num_lats,$       ; Same as pixel_control_points = 1354
                                r_dataset_array);

    if (o_variable_valid_flag NE 1) then begin
        ; Must return immediately.
        return, FAILURE;
    endif

    if (debug_flag) then begin
        print, debug_module,': INFO, i_filename = ', i_filename; 
        print, debug_module,': INFO, i_variable_short_name = ', i_variable_short_name; 
        print, debug_module,': INFO, r_data_type           = ', r_data_type;
        print, debug_module,': INFO, r_slope = [', r_slope, ']';
        print, debug_module,': INFO, r_intercept = [', r_intercept, ']';
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

    r_status = write_control_points_variable_to_netcdf(i_out_filename,i_variable_short_name,$
                           r_dataset_array , r_long_name,$
                           r_units,r_data_type,r_slope,r_intercept,r_fill_value,r_valid_min,r_valid_max);

    if (GETENV('GHRSST_MODIS_COMBINER_FAILED_STDV_SST4_VARIABLE_WRITE_TEST') EQ 'true') then r_status = FAILURE;

    if (r_status NE SUCCESS) then begin
        msg_type = "warning";
        msg = 'Cannot write variable ' + i_variable_short_name + ' to file ' + i_out_filename;

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
; Read qual_sst4 from NetCDF file and write to HDF file.
;--------------------------------------------------------------------------------

i_variable_short_name = 'qual_sst4';

r_status =  read_netcdf_one_variable(i_filename,$
                                     i_variable_short_name,$
                                     o_data_variable_structure);

if (GETENV('GHRSST_MODIS_COMBINER_FAILED_QUAL_SST4_VARIABLE_READ_TEST') EQ 'true') then r_status = FAILURE;

if (r_status EQ FAILURE) then begin
    msg_type = "warning";
    msg = 'Cannot read variable ' + i_variable_short_name + ' from file ' + i_filename;

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

    ; If the variable does not have slope and intercept, we set them to 1.0 and 0.0 respectively.
    ; Note that these values are of FLOAT type since the write_control_points_variable_to_netcdf() expects them to be FLOAT.
    if (N_ELEMENTS(r_slope) NE 0) then begin
        if (r_slope EQ '') then r_slope = 1.0;  If the variable is a string, we set it to a default.
    endif
    if (N_ELEMENTS(r_intercept) NE 0) then begin
        if (r_intercept EQ '') then r_intercept = 0.0;  If the variable is a string, we set it to a default.
    endif

    ; Validate the variable dimensions and type.

    o_variable_valid_flag = validate_variable_dimensions($
                                i_filename,$
                                i_variable_short_name,$
                                i_num_lons,$       ; Same as Number_of_Scan_Lines = 2030
                                i_num_lats,$       ; Same as pixel_control_points = 1354
                                r_dataset_array);

    if (o_variable_valid_flag NE 1) then begin
        ; Must return immediately.
        return, FAILURE;
    endif

    if (debug_flag) then begin
        print, debug_module,': INFO, i_filename = ', i_filename; 
        print, debug_module,': INFO, i_variable_short_name = ', i_variable_short_name; 
        print, debug_module,': INFO, r_data_type           = ', r_data_type;
        print, debug_module,': INFO, r_slope = [', r_slope, ']';
        print, debug_module,': INFO, r_intercept = [', r_intercept, ']';
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

    r_status = write_control_points_variable_to_netcdf(i_out_filename,i_variable_short_name,$
                           r_dataset_array , r_long_name,$
                           r_units,r_data_type,r_slope,r_intercept,r_fill_value,r_valid_min,r_valid_max);

    if (GETENV('GHRSST_MODIS_COMBINER_FAILED_QUAL_SST4_VARIABLE_WRITE_TEST') EQ 'true') then r_status = FAILURE;

    if (r_status NE SUCCESS) then begin
        msg_type = "warning";
        msg = 'Cannot write variable ' + i_variable_short_name + ' to file ' + i_out_filename;

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