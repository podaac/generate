;  Copyright 2010, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS

PRO idl_one_process_executor, $
        i_task_string

; Program receives a string containg an IDL program call and pass it onto the EXECUTE function.
;
; Assumptions:
;
; 1.  The strings representing the IDL program call contains the correct format. 
; 2.  No other error checking is done on the string in.  It is assume that the string contains valid program call and
;     the correct number of parameters.
;

    args = COMMAND_LINE_ARGS(COUNT = argCount);

;print, 'argcount ', argCount;
    IF argCount EQ 0 THEN BEGIN
;        PRINT, 'idl_one_process_executor:No input arguments specified'
;        RETURN
    ENDIF ELSE BEGIN
;print, 'args ', size(args);
;help,    args[0];
        i_task_string = args[0];
    ENDELSE


tstart = systime(1)
;print, 'idl_one_process_executor: execution start time:', systime()

;exit;

@load_maf_constants

over_all_status = SUCCESS;

MAX_LOOP_RUNS = 5;  We run at least 5 times until the command is successful.

loop_count = 0;
run_status = 0;
time_slept = 0;  Keep track of how long we have slept.

while ((loop_count LT MAX_LOOP_RUNS) AND (run_status NE 1)) do begin
;print, 'do_busy_work_test: pre  EXECUTE[' + i_task_string + ']';
    ; Run it.
    run_status = EXECUTE(i_task_string);
;print, 'do_busy_work_test: post EXECUTE[' + i_task_string + ']';
;run_status = 0;
    ; If the user entered the i_force_fail_status as 'true' or 'yes', then we set run_status to 0 to simulate a bad execution.
    if (N_ELEMENTS(i_force_fail_status) EQ 1) then begin
        if ((i_force_fail_status EQ "yes")  OR (i_force_fail_status EQ "true")) then begin
            run_status = 0;
        endif
    endif

    ; Sleep for minute if not successful.
    if (run_status NE 1) then begin
        sleep_time = 60 * (loop_count + 1);
        print, "idl_one_process_executor: ERROR, LOOP_COUNT " + STRTRIM(STRING(loop_count+1),2) + " OUT_OF " + STRTRIM(STRING(MAX_LOOP_RUNS),2) + ":The EXECUTE call on [" + i_task_string + "] failed.  Will sleep for " + STRTRIM(STRING(sleep_time),2) + " seconds to call again.";
        WAIT, sleep_time;
        time_slept = time_slept + sleep_time;
    endif
    loop_count = loop_count + 1;
end

; Make sure the status is good.  If not, report it. 

if (run_status NE 1) then begin
    print, "idl_one_process_executor: ERROR, The below procedure failed:";
    print, i_task_string

    l_status = error_log_writer($
               'idl_one_process_executor',$
               'The below procedure failed:' + i_task_string);

    donotcare = idl_email_ops_to_report_error(idl_prepare_email_body(i_task_string));

endif

;print, 'Overall execution time:', systime(1) - tstart
;help,/heap

;
; Close up shop.
;

END
