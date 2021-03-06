;  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM
; New Request #xxxx
PRO is_netcdf_granule_night_or_day,$
        i_sst_filename

; Program returns when the granule was observed, either Mixed, Day, or Night.
; It is up to the callee to parse the output string for the actual value.
;
; Assumptions:
;
;   1.  The file format is NetCDF file.
;
;------------------------------------------------------------------------------------------------

args = COMMAND_LINE_ARGS(COUNT = argCount);

IF argCount EQ 0 THEN BEGIN
        ;PRINT, 'is_netcdf_granule_night_or_day:No input arguments specified'
        ;RETURN
ENDIF ELSE BEGIN
    i_sst_filename  = args[0];
ENDELSE

; Load constants.

@modis_data_config.cfg
 
; Return if file does not exist.

file_exist = FILE_TEST(i_sst_filename);

if (file_exist EQ 0) then begin
    print, 'is_netcdf_granule_night_or_day:ERROR, File not found: ' + i_sst_filename;

    l_status = error_log_writer('is_netcdf_granule_night_or_day','File not found:' + i_sst_filename);
    return;
endif

r_day_or_night = '';

r_status = read_netcdf_global_attribute(i_sst_filename,'day_night_flag',r_day_or_night);
in_filename_only = FILE_BASENAME(i_sst_filename);
do_not_care = verify_returned_status(in_filename_only,r_status,SUCCESS,'Cannot read day_night_flag attribute from file ' + i_sst_filename);

; Remove the non-ascii character from variable.

r_day_or_night = convert_to_ascii_string(r_day_or_night);

print, 'DAY_OR_NIGHT' + ' ' + r_day_or_night;  ; Let the callee decide what to do with the output.

end
