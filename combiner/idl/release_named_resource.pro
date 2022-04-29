;  Copyright 2012, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

PRO release_named_resource, $
        i_lock_name

;
; Release the semaphore.  No status is required.
;

SEM_RELEASE,i_lock_name;
;print, 'release_named_resource: SEM_RELEASE called';

;
; Create a catch block to catch error.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'release_named_resource: ERROR, Failed in SEM_DELETE for i_lock_name:' + i_lock_name;
    ; Must return immediately.
    return
endif

;
; Attempt to delete the semaphore.
;

SEM_DELETE,i_lock_name;
;print, 'release_named_resource: SEM_DELETE called';

; If got to here, the release of the semaphore was successful.

;
; Close up shop.
;

END
