;  Copyright 2019, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION get_coverage_content_type,$
             i_dataset_name

; Function returns the appropriate value for coverage_content_type

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

function_name = "get_coverage_content_type:";

o_status = SUCCESS;
o_coverage_content_type = "";

; Get the DEBUG_MODE if it is set.

debug_module = 'get_coverage_content_type:';
debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

MAX_NUM_CONTENTS_TYPE = 13; Becareful that the content below matches this number.
coverage_content_types_list = STRARR(MAX_NUM_CONTENTS_TYPE);
global_index = 0;


coverage_content_types_list[global_index++] = "lat:coordinate";
coverage_content_types_list[global_index++] = "lon:coordinate";
coverage_content_types_list[global_index++] = "time:coordinate";
coverage_content_types_list[global_index++] = "sea_surface_temperature:physicalMeasurement";
coverage_content_types_list[global_index++] = "sst_dtime:referenceInformation";
coverage_content_types_list[global_index++] = "quality_level:qualityInformation";
coverage_content_types_list[global_index++] = "sses_bia:auxiliaryInformation";
coverage_content_types_list[global_index++] = "sses_standard_deviation:auxiliaryInformation";
coverage_content_types_list[global_index++] = "l2p_flags:qualityInformation";
coverage_content_types_list[global_index++] = "wind_speed:auxiliaryInformation";
coverage_content_types_list[global_index++] = "dt_analysis:auxiliaryInformation";
coverage_content_types_list[global_index++] = "K_490:auxiliaryInformation";
coverage_content_types_list[global_index++] = "chlorophyll:auxiliaryInformation";

FOR II = 0, MAX_NUM_CONTENTS_TYPE -1 DO BEGIN
    tokens_array = STRSPLIT(coverage_content_types_list[II],":",/EXTRACT);
    variable_name = STRTRIM(tokens_array[0],2);
    variable_type = STRTRIM(tokens_array[1],2);
    ;PRINT, function_name + "tokens_array ", tokens_array
    IF STRPOS(i_dataset_name,variable_name) GE 0 THEN BEGIN
        o_coverage_content_type = variable_type;
    ENDIF
ENDFOR

IF o_coverage_content_type EQ "" THEN BEGIN
    o_coverage_content_type = " ";
    PRINT, function_name + "WARN: Cannot determined coverage_content_type of variable ", i_dataset_name
    PRINT, function_name + "WARN: Setting to default value ", o_coverage_content_type 
ENDIF

return, o_coverage_content_type;
end
