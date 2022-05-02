;  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: read_control_points_variable.pro,v 1.1.1.1 2006/04/25 19:15:40 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
; New Request #xxxx

FUNCTION read_control_points_variable,$
             i_filename,$
             i_variable_short_name,$
             r_dataset_array,$
             r_long_name,$
             r_units,$
             r_data_type,$
             r_fill_value

; Function read a dataset from an HDF formatted file and return the array containing the
; data sets with 'r_' as the beginning of the name.
;
; Assumptions:
;
;   1. The input file exist and is in HDF format.
;

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

o_status = SUCCESS;

l_long_name = 'long_name';     HDF's attribute names associated with this variable.
l_units     = 'units';

; Output attributes:

r_long_name = "long_name";
r_units     = "none"; 

debug_mode = 0;

if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
    debug_mode = 1;
endif


sd_id = HDF_SD_START(i_filename,/READ); Function HDF_SD_START does not return any status.

; Get the index to the actual variable.

sd_index = HDF_SD_NAMETOINDEX(sd_id,i_variable_short_name);

if (sd_index EQ -1) then begin
    print, 'read_control_points_variable: ERROR, Cannot get index of HDF variable name: ' + i_variable_short_name + ' from file ' + i_filename;
    o_status = FAILURE;
    ; Must return immediately.
    return, o_status
endif


; Get the dataset id.

sds_id = HDF_SD_SELECT(sd_id,sd_index);

; Get some info on the variable at hand.

HDF_SD_GETINFO,sds_id,ndims=ndims,dims=dims,type=r_data_type

; Read the slab from HDF file.

HDF_SD_GETDATA,sds_id,r_dataset_array;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Read the associated attributes of the variable.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Use a new function get_hdf_variable_attributes to get the variable attribute to avoid the error from IDL when an attribute does not exist:
;
;     'HDF_SD_ATTRFIND: Unable to find the HDF-SD attribute named'

attribute_name = 'long_name';
attribute_read_status = get_hdf_variable_attributes($
                            sd_id,$
                            sds_id,$
                            i_variable_short_name,$
                            attribute_name,$
                            r_long_name);

if (debug_mode) then begin
    help, i_variable_short_name;
    help, attribute_name;
    help, r_long_name;
endif

attribute_name = 'fill_value';
attribute_read_status = get_hdf_variable_attributes($
                            sd_id,$
                            sds_id,$
                            i_variable_short_name,$
                            attribute_name,$
                            r_fill_value);

if (debug_mode) then begin
    help, i_variable_short_name;
    help, attribute_name;
    help, r_long_name;
endif

attribute_name = 'units';
attribute_read_status = get_hdf_variable_attributes($
                            sd_id,$
                            sds_id,$
                            i_variable_short_name,$
                            attribute_name,$
                            r_units);

if (debug_mode) then begin
    help, i_variable_short_name;
    help, attribute_name;
    help, r_long_name;
endif

; ---------- Close up shop ---------- 

HDF_SD_END, sd_id;
return, o_status
end
