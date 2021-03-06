;  Copyright 2010, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

FUNCTION idl_prepare_email_body, $
             i_sigevent_message

; Function prepare a pre-canned email and return the body to callee as an array of strings.
;
; This array of strings will then be passed to idl_email_ops_to_report_error() function
; to send the email to the operator.
;
;------------------------------------------------------------------------------------------------

r_error_message = STRARR(12);
r_error_message[0] = "You are receiving this email because there is a sigevent in the cluster job processing.";
r_error_message[1] = "";
r_error_message[2] = "Please do not reply to this email.";
r_error_message[3] = "";
r_error_message[4] = "There is a sigevent in this top function execute_idl_processing_jobs.pro";
r_error_message[5] = "from executing this command string or sigevent message:";
r_error_message[6] = "";
r_error_message[7] = "[" + i_sigevent_message + "]";
r_error_message[8] = "";
r_error_message[9] = "";
r_error_message[10] = "The sigevent may have occurred in the children function.";
r_error_message[11] = "";

return, r_error_message;
end
