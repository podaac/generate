;  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

PRO is_netcdf_granule_quicklook_or_refined,$
        i_sst_filename

; Program returns if the granule was quickook or refined.  This program is different than the other program with similar name in that it reads a NetCDf
; file instead of an HDF file.
;
;------------------------------------------------------------------------------------------------

args = COMMAND_LINE_ARGS(COUNT = argCount);

IF argCount EQ 0 THEN BEGIN
        ;PRINT, 'process_modis_datasets:No input arguments specified'
        ;RETURN
ENDIF ELSE BEGIN
    i_sst_filename  = args[0];
ENDELSE

; Load constants.

@modis_data_config.cfg

; Return if file does not exist.

file_exist = FILE_TEST(i_sst_filename);

if (file_exist EQ 0) then begin
    print, 'is_netcdf_granule_quicklook_or_refined:ERROR, File not found: ' + i_sst_filename;
    l_status = error_log_writer('is_netcdf_granule_quicklook_or_refined','File not found:' + i_sst_filename);
    return;
endif

o_quicklook_or_refined_flag = '';
processing_version = "DUMMY_PROCESSING_VERSION";
r_status = read_netcdf_global_attribute(i_sst_filename,'processing_version',processing_version);
do_not_care = verify_returned_status(i_sst_filename,r_status,SUCCESS,'Cannot read processing_version attribute from file ' + i_sst_filename);

; Remove the non-ascii character from variable.
processing_version = convert_to_ascii_string(processing_version);

; If were were not able to read the attribute, we exit the program by printing DUMMY_PROCESSING_VERSION to console.
; The below logic "(STRPOS(processing_version,"QL")" will either set o_quicklook_or_refined_flag to QUICKLOOK or REFINED, which is not correct.

if (processing_version EQ "DUMMY_PROCESSING_VERSION") then begin
    print, 'QUICKLOOK_OR_REFINED' + ' ' + processing_version;
    return;
endif

if (processing_version EQ '') then begin
    print, 'QUICKLOOK_OR_REFINED' + ' ' + 'DUMMY_PROCESSING_VERSION';
    return;
endif

; The quicklook has the value "QL" in the "processing_version" attribute.

if (STRLEN(processing_version) GT 0) AND (STRPOS(processing_version,"QL") GE 0) then begin
    o_quicklook_or_refined_flag = 'QUICKLOOK';
endif else begin
    o_quicklook_or_refined_flag = 'REFINED'; 
endelse

; The new name may not have 'QL' in the processing_version so we look in product_name for a clue.


r_status = read_netcdf_global_attribute(i_sst_filename,'product_name',product_name);
;product_name = product_name + '.NRT';
;print, 'product_name' + ' ' + product_name;
;print, 'i_sst_filename, product_name ',i_sst_filename + ' ' + product_name
;print, 'i_sst_filename, processing_version ',i_sst_filename + ' ' + processing_version
if STRPOS(product_name,'.NRT') GE 0 then begin
;print, 'NAME_CONTAINS_NRT ' + i_sst_filename
    o_quicklook_or_refined_flag = 'QUICKLOOK';
endif

print, 'QUICKLOOK_OR_REFINED' + ' ' + o_quicklook_or_refined_flag;  ; Let the callee decide what to do with the output.
;return, r_status
end
