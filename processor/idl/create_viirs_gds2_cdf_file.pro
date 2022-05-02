;  Copyright 2016, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

FUNCTION create_viirs_gds2_cdf_file,$
             i_filename,$
             i_start_time_array_element,$
             i_gds2_global_start,$
             i_gds2_global_stop,$
             i_northernmost_latitude,$
             i_southernmost_latitude,$
             i_easternmost_longitude,$
             i_westernmost_longitude,$
             i_num_cols,$
             i_num_rows,$
             i_title,$
             i_dsd_entry_id,$
             i_platform,$
             i_comment,$
             i_start_node,i_end_node,i_day_or_night,$
             i_processing_type

;
; Function creates a VIIRS L2P file in GDS2 version in NetCDF4 file format.
;
; Input:
;
;    see above 
;
; Output:
;
;    o_status       Status of file creation.
;
;------------------------------------------------------------------------------------------------

; Load constants and configuration data.

@data_const_config.cfg
@modis_data_config.cfg

; If producing VIIRS dataset, define constants appropriately.
@viirs_data_config.cfg

routine_name = 'create_viirs_gds2_cdf_file';
debug_module = routine_name + ':';

debug_mode = 0
if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif

; Define local variables.

o_status = SUCCESS;

; Do a sanity check on the input i_filename to make sure we can write to the directory.

directory_name = FILE_DIRNAME(i_filename);
if ~FILE_TEST(directory_name,/WRITE) then begin
    print, debug_module + 'ERROR: User does not have write permission on directory ' + directory_name;
    o_status = FAILURE;
    return, o_status;
endif

; Make sure the time fields are valid. 

attribute_name = 'gds2_global_start';
o_time_field_valid_flag = validate_time_field($
                              attribute_name,$
                              i_gds2_global_start,o_timestamp_string);

if (o_time_field_valid_flag NE SUCCESS) then begin
    status = FAILURE;
    msg_type = 'error';
    msg = 'Attribute ' + attribute_name + ' value ' + i_gds2_global_start + ' from file ' + i_filename + ' is not a valid time field.';
    print, debug_module + msg;
    donotcare = error_log_writer(routine_name,msg);
    ; Must return immediately.
    return, status;
endif

attribute_name = 'gds2_global_stop';
o_time_field_valid_flag = validate_time_field($
                              attribute_name,$
                              i_gds2_global_stop,o_timestamp_string);

if (o_time_field_valid_flag NE SUCCESS) then begin
    status = FAILURE;
    msg_type = 'error';
    msg = 'Attribute ' + attribute_name + ' value ' + i_gds2_global_stop + ' from file ' + i_filename + ' is not a valid time field.';
    print, debug_module + msg;
    donotcare = error_log_writer(routine_name,msg);
    ; Must return immediately.
    return, status;
endif

; Make sure the type of the bounding box is FLOAT.

attribute_name = 'northernmost_latitude';
attribute_value = i_northernmost_latitude;
attribute_type  = SIZE(attribute_value,/TNAME);
if ((attribute_type EQ 'FLOAT') OR (attribute_type EQ 'DOUBLE')) then begin
    ; Do nothing, this is OK.
    if (debug_mode) then begin
        msg = 'Attribute ' + attribute_name + ' value ' + STRING(attribute_value) + ' of type ' + attribute_type + ' from file ' + i_filename + ' is the correct type of FLOAT or DOUBLE.';
        print, debug_module + msg;
    endif
endif else begin
    status = FAILURE;
    msg_type = 'error';
    msg = 'Attribute ' + attribute_name + ' value ' + STRING(attribute_value) + ' of type ' + attribute_type + ' from file ' + i_filename + ' is NOT a valid geographical type of FLOAT or DOUBLE.';
    print, debug_module + msg;
    donotcare = error_log_writer(routine_name,msg);
    ; Must return immediately.
    return, status;
endelse

attribute_name  = 'southernmost_latitude';
attribute_value = i_southernmost_latitude;
attribute_type  = SIZE(attribute_value,/TNAME);
if ((attribute_type EQ 'FLOAT') OR (attribute_type EQ 'DOUBLE')) then begin
    ; Do nothing, this is OK.
    if (debug_mode) then begin
        msg = 'Attribute ' + attribute_name + ' value ' + STRING(attribute_value) + ' of type ' + attribute_type + ' from file ' + i_filename + ' is the correct type of FLOAT or DOUBLE.';
        print, debug_module + msg;
    endif
endif else begin
    status = FAILURE;
    msg_type = 'error';
    msg = 'Attribute ' + attribute_name + ' value ' + STRING(attribute_value) + ' of type ' + attribute_type + ' from file ' + i_filename + ' is NOT a valid geographical type of FLOAT or DOUBLE.';
    print, debug_module + msg;
    donotcare = error_log_writer(routine_name,msg);
    ; Must return immediately.
    return, status;
endelse

attribute_name = 'easternmost_longitude';
attribute_value = i_easternmost_longitude;
attribute_type  = SIZE(attribute_value,/TNAME);
if ((attribute_type EQ 'FLOAT') OR (attribute_type EQ 'DOUBLE')) then begin
    ; Do nothing, this is OK.
    if (debug_mode) then begin
        msg = 'Attribute ' + attribute_name + ' value ' + STRING(attribute_value) + ' of type ' + attribute_type + ' from file ' + i_filename + ' is the correct type of FLOAT or DOUBLE.';
        print, debug_module + msg;
    endif
endif else begin
    status = FAILURE;
    msg_type = 'error';
    msg = 'Attribute ' + attribute_name + ' value ' + STRING(attribute_value) + ' of type ' + attribute_type + ' from file ' + i_filename + ' is NOT a valid geographical type of FLOAT or DOUBLE.';
    print, debug_module + msg;
    donotcare = error_log_writer(routine_name,msg);
    ; Must return immediately.
    return, status;
endelse

attribute_name = 'westernmost_longitude';
attribute_value = i_westernmost_longitude;
attribute_type  = SIZE(attribute_value,/TNAME);
if ((attribute_type EQ 'FLOAT') OR (attribute_type EQ 'DOUBLE')) then begin
    ; Do nothing, this is OK.
    if (debug_mode) then begin
        msg = 'Attribute ' + attribute_name + ' value ' + STRING(attribute_value) + ' of type ' + attribute_type + ' from file ' + i_filename + ' is the correct type of FLOAT or DOUBLE.';
        print, debug_module + msg;
    endif
endif else begin
    status = FAILURE;
    msg_type = 'error';
    msg = 'Attribute ' + attribute_name + ' value ' + STRING(attribute_value) + ' of type ' + attribute_type + ' from file ' + i_filename + ' is NOT a valid geographical type of FLOAT or DOUBLE.';
    print, debug_module + msg;
    donotcare = error_log_writer(routine_name,msg);
    ; Must return immediately.
    return, status;
endelse

;
; Get today's date and time in JULIAN UTC format.
;

today_in_jul = SYSTIME(/JULIAN,/UTC)

; Get the individual fields: month, day, year, hour, minute, second from program CALDAT

CALDAT,today_in_jul,jul_month,jul_day,jul_year,jul_hour,jul_minute,jul_second;

; Format the date_create field in preparation for writing.  The format is yyyymmddThhmmssZ.

date_created = STRING(jul_year,jul_month,jul_day,    FORMAT='(I4,I02,I02)' ) + 'T' + $;
               STRING(jul_hour,jul_minute,jul_second,FORMAT='(I02,I02,I02)') + 'Z'

; Add the Quicklook or Refined string depending on the processing type
specific_comment = "";
if (i_processing_type EQ 'QUICKLOOK') then begin
    specific_comment = i_comment + '; Quicklook';
endif else begin
    specific_comment = i_comment + '; Refined';
endelse

;
; Create a catch block to catch error in interaction with FILE IO.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'create_viirs_gds2_cdf_file: ERROR, Cannot open file for output ' + i_filename
    o_status = FAILURE;
    ; Must return immediately.
    return, o_status
endif

; Create a NETCDF4 file.  Wipe out any existing file.

file_id = NCDF_CREATE(i_filename,/NETCDF4_FORMAT, /CLOBBER);
CATCH, /CANCEL

;
; Since the file is new, write all the global attributes.
;

; Create a large global attribute array of 51 elements to store the required attributes, their types, and values into 3 columns.
; Care should be taken to not add more elements than allowed.

MAX_NUM_GLOBAL_ATTRIBUTES = 51;
MAX_NUM_GLOBAL_ATTRIBUTES = 54;  Add 3 more attributes: startDirection, endDirection and day_night_flag = "Night";
MAX_NUM_GLOBAL_ATTRIBUTES = 53;  Delete 1 Metadata_Conventions

global_attributes_array = STRARR(MAX_NUM_GLOBAL_ATTRIBUTES);
global_index = 0;

;global_attributes_array[global_index++] = "Conventions | string | CF-1.6, ACDD-1.1";
global_attributes_array[global_index++] = "Conventions | string | CF-1.7, ACDD-1.3";
global_attributes_array[global_index++] = "title       | string | " + i_title;
global_attributes_array[global_index++] = "summary     | string | Sea surface temperature (SST) retrievals produced at the NASA OBPG for the Visible Infrared Imaging Radiometer Suite (VIIRS) sensor on the Suomi National Polar-Orbiting Partnership (Suomi NPP) platform. These have been reformatted to GHRSST GDS version 2 Level 2P specifications by the JPL PO.DAAC. VIIRS SST algorithms developed by the University of Miami, RSMAS";

global_attributes_array[global_index++] = "references  | string | GHRSST Data Processing Specification v2r5";
global_attributes_array[global_index++] = "institution | string | " + const_institution;
global_attributes_array[global_index++] = "history     | string | VIIRS L2P created at JPL PO.DAAC by combining OBPG SNPP_SST and SNPP_SST3, and outputing to the  GHRSST GDS2 netCDF file format";
global_attributes_array[global_index++] = "comment     | string | " + specific_comment;
global_attributes_array[global_index++] = "license     | string | GHRSST and PO.DAAC protocol allow data use as free and open."
global_attributes_array[global_index++] = "id          | string | " + i_dsd_entry_id;
global_attributes_array[global_index++] = "naming_authority | string | org.ghrsst";
global_attributes_array[global_index++] = "product_version  | string | " + const_gds2_product_version;
global_attributes_array[global_index++] = "uuid             | string | b6ac7651-7b02-44b0-942b-c5dc3c903eba"; Numerous, simple tools can be used to create a UUID, which is inserted as the value of this attribute. See http://en.wikipedia.org/wiki/Universally_Unique_Identifier for more information and tools."
global_attributes_array[global_index++] = "gds_version_id        | string  | 2.0";
global_attributes_array[global_index++] = "netcdf_version_id     | string  | 4.1";
global_attributes_array[global_index++] = "date_created          | string  | " + date_created;
global_attributes_array[global_index++] = "file_quality_level    | integer | " + STRING(const_gds2_file_quality_index);
global_attributes_array[global_index++] = "spatial_resolution    | string  | " + const_spatial_resolution;
global_attributes_array[global_index++] = "start_time            | string  | " + i_gds2_global_start;
global_attributes_array[global_index++] = "time_coverage_start   | string  | " + i_gds2_global_start;
global_attributes_array[global_index++] = "stop_time             | string  | " + i_gds2_global_stop;
global_attributes_array[global_index++] = "time_coverage_end     | string  | " + i_gds2_global_stop;
global_attributes_array[global_index++] = "northernmost_latitude | float   | " + STRING(i_northernmost_latitude);
global_attributes_array[global_index++] = "southernmost_latitude | float   | " + STRING(i_southernmost_latitude);
global_attributes_array[global_index++] = "easternmost_longitude | float   | " + STRING(i_easternmost_longitude);
global_attributes_array[global_index++] = "westernmost_longitude | float   | " + STRING(i_westernmost_longitude);

; Add these to improve ACDD v1.1 recommended attribute compliance
global_attributes_array[global_index++] = "geospatial_lat_max    | float   | " + STRING(i_northernmost_latitude);
global_attributes_array[global_index++] = "geospatial_lat_min    | float   | " + STRING(i_southernmost_latitude);
global_attributes_array[global_index++] = "geospatial_lon_max    | float   | " + STRING(i_easternmost_longitude);
global_attributes_array[global_index++] = "geospatial_lon_min    | float   | " + STRING(i_westernmost_longitude);

global_attributes_array[global_index++] = "source                | string | VIIRS sea surface temperature observations from the Ocean Biology Processing Group (OBPG)";
global_attributes_array[global_index++] = "platform              |string | " + i_platform; Satellite(s) used to create this data file. Select from the entries found in the Satellite Platform column of Table 7 - 5 and provide as a comma separated list if there is more than one.  GDS The Recommended GHRSST Data Specification (GDS) version 2.0 revision 5 Filename:GDS20r5.doc Page 40 o f 123 Last s aved on : 09/10/2012 12:40:00"
global_attributes_array[global_index++] = "sensor                | string | " + const_sensor_name; 
;global_attributes_array[global_index++] = "Metadata_Conventions  | string | Unidata Dataset Discovery v1.1";
global_attributes_array[global_index++] = "metadata_link         | string | http://podaac.jpl.nasa.gov/ws/metadata/dataset/?format=iso&shortName=" + i_dsd_entry_id;
global_attributes_array[global_index++] = "keywords              | string | Oceans > Ocean Temperature > Sea Surface Temperature > Skin Sea Surface Temperature";
global_attributes_array[global_index++] = "keywords_vocabulary   | string | NASA Global Change Master Directory (GCMD) Science Keywords";
global_attributes_array[global_index++] = "standard_name_vocabulary | string | NetCDF Climate and Forecast (CF) Metadata Conventions"; 
global_attributes_array[global_index++] = "geospatial_lat_units     | string | degrees_north";
global_attributes_array[global_index++] = "geospatial_lat_resolution| float  | 0.0075";
global_attributes_array[global_index++] = "geospatial_lon_units     | string | degrees_east";
global_attributes_array[global_index++] = "geospatial_lon_resolution| float  | 0.0075";
global_attributes_array[global_index++] = "acknowledgment           | string | The VIIRS L2P sea surface temperature data are sponsored by NASA"
global_attributes_array[global_index++] = "creator_name             | string | " + const_creator_name; Provide a name and email address for the most relevant point of contact at the producing RDAC, as well as a URL relevant to this data set.  ACDD"
global_attributes_array[global_index++] = "creator_email            | string | " + const_creator_email;
global_attributes_array[global_index++] = "creator_url              | string | http://podaac.jpl.nasa.gov";
global_attributes_array[global_index++] = "project                  | string | Group for High Resolution Sea Surface Temperature";
global_attributes_array[global_index++] = "publisher_name           | string | The GHRSST Project Office";
global_attributes_array[global_index++] = "publisher_url            | string | http://www.ghrsst.org";
global_attributes_array[global_index++] = "publisher_email          | string | ghrsst-po@nceo.ac.uk";
global_attributes_array[global_index++] = "processing_level         | string | L2P";
global_attributes_array[global_index++] = "cdm_data_type            | string | swath";
global_attributes_array[global_index++] = "startDirection           | string | " + i_start_node; 
global_attributes_array[global_index++] = "endDirection             | string | " + i_end_node;
global_attributes_array[global_index++] = "day_night_flag           | string | " + i_day_or_night;

; Write all the global attributes to file.

o_status = write_gds2_modis_global_attributes(file_id,$
                                              i_filename,$
                                              global_attributes_array,$
                                              i_num_cols,$
                                              i_num_rows);

;
; Create a catch block to catch error in interaction with FILE IO.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'create_viirs_gds2_cdf_file: ERROR, Cannot close file: ' + i_filename;
    o_status = FAILURE;
    ; Must return immediately.
    return, o_status
endif
    
NCDF_CLOSE, file_id;
CATCH, /CANCEL

; ---------- Close up shop ---------- 

return, o_status
end

