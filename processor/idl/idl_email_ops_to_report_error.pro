;  Copyright 2010, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

;
; Function email an operator of error in the Cluster Job Processing.  The message
; is an array of string.
;
; Because this function may be used by the Ancillary Filling or the MODIS L2P Processing,
; we check for different for environment settings. 
;
;------------------------------------------------------------------------------------------------

FUNCTION  idl_email_ops_to_report_error, $
              i_error_message

    ; Determine if email address recipients have been defined
    if (STRLEN(GETENV('OPS_MODIS_MONITOR_EMAIL_LIST')) EQ 0) then begin
        print, "idl_email_ops_to_report_error:ERROR, Neither system environment GAPOPSLIST nor OPS_MODIS_MONITOR_EMAIL_LIST is set.";
        print, "idl_email_ops_to_report_error:i_error_message = ";
        print, i_error_message;
        exit;
    endif

    ; Create the email message.
    temp_email_filename = GETENV('EMPTY_EMAIL_LOCATION') + "/send_this_email_to_operator_from_cluster_processing" + STRTRIM(STRING(LONG(SYSTIME(/SECONDS))),2) + '.txt';
    OPENW, out_lun, temp_email_filename, ERROR = err_no, /GET_LUN;
    
    for loop = 0, N_ELEMENTS(i_error_message) - 1 do begin;
        print, i_error_message[loop];
        printf, out_lun, i_error_message[loop];
    endfor

    FREE_LUN, out_lun;

    ; If err_no is nonzero, something bad happened.  Print the error message
    ; to the standard error file (logical unit -2):
    ; Changed later to print to log if desired.
    if (err_no NE 0) then begin
        print, 'idl_email_ops_to_report_error: ERROR, Cannot open pipe for sendmail program for output.'
        exit;
    end

    ; Define the subject.
    SPAWN,"echo $HOST",host_command_results;
    host_name = STRTRIM(host_command_results,2);

    ; Add the ".jpl.nasa.gov" if the name does not contain it.
    if (STRMATCH(host_name,"*jpl*") NE 1) then begin
        host_name = host_name + ".jpl.nasa.gov";
    endif

    subject = 'Reporting Cluster Significant Event Running on machine ' + host_name

    ; Now use SPAWN function to send the email.
    mail_str = 'mail -r processor@generate.app -s ' + '"' + subject + '"' + ' ' + GETENV('OPS_MODIS_MONITOR_EMAIL_LIST') +' < ' + temp_email_filename
    print, 'MAIL STRING: ', mail_str
    SPAWN, mail_str

    FILE_DELETE, temp_email_filename,  /ALLOW_NONEXISTENT, /QUIET;

    ; Close up shop.
    return, 1;
END
