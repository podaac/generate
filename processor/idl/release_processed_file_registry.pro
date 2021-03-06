;  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: release_processed_file_registry.pro,v 1.1 2007/05/01 17:39:41 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

PRO release_processed_file_registry

;tstart = systime(1)
;print, 'release_processed_file_registry: execution start time:', systime() 

; Status and such.

SUCCESS = 1;
FAILURE = 0;

; Make a lock name.

l_lock_name = 'MY_PROCESSED_FILE_REGISTRY_LOCK';

;
; Release the semaphore.  No status is required.
;

SEM_RELEASE,l_lock_name;
;print, 'release_processed_file_registry: SEM_RELEASE called';

;
; Create a catch block to catch error.
;

CATCH, error_status
if (error_status NE 0) then begin
    CATCH, /CANCEL
    print, 'release_processed_file_registry: ERROR, Failed in SEM_DELETE for l_lock_name:' + l_lock_name;
    ; Must return immediately.
    return
endif

;
; Attempt to delete the semaphore.
;

SEM_DELETE,l_lock_name;
;print, 'release_processed_file_registry: SEM_DELETE called';

; If got to here, the release of the semaphore was successful.

;
; Close up shop.
;

END
