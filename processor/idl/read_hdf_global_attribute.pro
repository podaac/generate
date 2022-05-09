;  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: read_hdf_global_attribute.pro,v 1.6 2006/10/12 00:53:37 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
; New Request #xxxx

FUNCTION read_hdf_global_attribute,$
         i_filename,$
         i_attribute_name,$
         r_attribute_value

; Function read global attribute from an HDF formatted file and return the value.
;
; Assumptions:
;
;   1. The file is opened already.
;   2. TBD. 
;   3. TBD.
;   4. TBD. 
;   5. TBD. 
;

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

r_status = SUCCESS;

;help, i_filename; 

; Return if file does not exist.

if ~FILE_TEST(i_filename) then begin
    print, 'read_hdf_global_attribute:ERROR, File not found: ' + i_filename;
    print, 'read_hdf_global_attribute:Cannot retrieve attribute: ' + i_attribute_name; 

    l_status = error_log_writer($
               'read_hdf_global_attribute',$
               'File not found:' + i_filename + ', reading attribute ' + i_attribute_name);

    r_status = FAILURE;
    return, r_status;
endif

;
; Create a catch block to catch error in interaction with reading global attributes.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'read_hdf_global_attribute: ERROR, Failed in HDF_SD_START: ' + i_filename + ', reading attribute ' + i_attribute_name;

    l_status = error_log_writer($
               'read_hdf_global_attribute',$
               'Failed in HDF_SD_START:' + i_filename + ', reading attribute ' + i_attribute_name);

    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

;
; Get the data set ID in this file.
;

sd_id = HDF_SD_START(i_filename,/READ); Function HDF_AN_START does not return any status.
CATCH, /CANCEL

;
; Create a catch block to catch error in interaction with reading global attributes.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'read_hdf_global_attribute: ERROR, Failed in HDF_SD_FILEINFO function: ' + i_filename;

    l_status = error_log_writer($
               'read_hdf_global_attribute',$
               'Failed in HDF_SD_FILEINFO:' + i_filename + ', reading attribute ' + i_attribute_name);

    r_status = FAILURE;
    ; Must return immediately.
    return, r_status
endif

;
; Get the total number of global attributes.
;

HDF_SD_FILEINFO,sd_id,n_datasets,n_global_attributes;
CATCH, /CANCEL

;
; Read through all the global attributes and find the one.  Exit when found or when run out.
;

found_attribute = 0;
global_index = 0;

while (found_attribute EQ 0 && global_index LT n_global_attributes) do begin

    ;
    ; Create a catch block to catch error in interaction with reading global attributes.
    ;

    CATCH, error_status
    if (error_status NE 0) then begin
        CATCH, /CANCEL
        print, 'read_hdf_global_attribute: ERROR, Failed in HDF_SD_ATTRINFO function:' + i_filename

        l_status = error_log_writer($
               'read_hdf_global_attribute',$
               'Failed in HDF_SD_ATTRINFO:' + i_filename + ', reading attribute ' + i_attribute_name);

        r_status = FAILURE;
        ; Must return immediately.
        return, r_status
    endif

    ;
    ; Read one attribute.
    ;

    HDF_SD_ATTRINFO,sd_id,global_index,name=l_attribute_name,data=l_attribute_value
    CATCH, /CANCEL

    ; Check to see if this is the attribute we want.  Exit if found.
    
    if (l_attribute_name EQ i_attribute_name) then begin
;help, l_attribute_name
;help, l_attribute_value

        r_attribute_value = l_attribute_value;
        found_attribute = 1;
    endif else begin

        ;
        ; Not found, keep looking.
        ;
        global_index = global_index + 1; 
    endelse
endwhile

if (found_attribute EQ 0) then r_status = FAILURE; 

; ---------- Close up shop ---------- 

HDF_SD_END, sd_id;
return, r_status
end