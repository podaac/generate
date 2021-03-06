;  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id$
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

FUNCTION perform_compression_on_l2p_file,$
             i_processing_type,$
             i_l2p_core_filename,$
             i_l2p_core_name_only,$
             i_o_l2p_core_filename

    ; Function compresses a newly created MODIS L2P file and returns the compressed file.
    ; It is assumed the compression is .bz2 format.

    ; Load constants.  No ending semicolon is required.

    @modis_data_config.cfg

    o_compress_status = SUCCESS;

    ; Get the DEBUG_MODE if it is set.

    routine_name = 'perform_compression_on_l2p_file:';
    debug_module = 'perform_compression_on_l2p_file:';
    debug_mode = 0
    if (STRUPCASE(GETENV('GHRSST_MODIS_L2P_DEBUG_MODE')) EQ 'TRUE') then begin
        debug_mode = 1;
    endif

     i_o_l2p_core_filename = i_l2p_core_filename;

    ; The default compression type is BZ2.
    call_shell_command_str = ''; 
    if ((STRUPCASE(GETENV('GHRSST_MODIS_L2P_COMPRESSION_TYPE')) EQ 'BZ2') OR $ 
        (GETENV('GHRSST_MODIS_L2P_COMPRESSION_TYPE') EQ '')) then begin
        call_shell_command_str     = "/usr/bin/bzip2 ";
        ; Add the ".bz2" extension if the file is to be compressed.
        i_o_l2p_core_filename += ".bz2";
    endif else begin
        if (GETENV('GHRSST_MODIS_L2P_COMPRESSION_TYPE') EQ 'GZIP') then begin
            call_shell_command_str = "/bin/gzip ";
            ; Add the ".gz" extension if the file is to be compressed.
            i_o_l2p_core_filename += ".gz";
        endif
    endelse

    ; Delete the .bz2 file if it exist since the compression program won't allow it.
    if FILE_TEST(i_o_l2p_core_filename) then begin
        print, debug_module + "Removing existing compressed file " + i_o_l2p_core_filename;
        FILE_DELETE, i_o_l2p_core_filename, /QUIET;
    endif

    ; Perform the compression on the L2P file.
    compact_start_time = SYSTIME(/SECONDS);
    perform_compress_on_l2p_core_file = call_shell_command_str + i_l2p_core_filename;
    if (debug_mode) then begin
        print, debug_module + "Compressing " + i_l2p_core_filename;
        print, debug_module + "perform_compress_on_l2p_core_file = " + perform_compress_on_l2p_core_file;
    endif
    SPAWN, perform_compress_on_l2p_core_file, out_string, error_string; 

    ; Report error and return if cannot perform compression on file.
    if (STRLEN(error_string) GT 0) then begin
            l_reason = 'Cannot compress file:' + i_l2p_core_filename;
            print, routine_name + 'perform_compress_on_l2p_core_file = ' + perform_compress_on_l2p_core_file;
            print, routine_name + l_reason;
            l_status = error_log_writer('compress_and_ftp_push_modis_L2P_core_datasets',l_reason);
            o_compress_status = FAILURE;
            return, o_compress_status;
    endif

    compact_total_time = SYSTIME(/SECONDS) - compact_start_time;
    do_not_care = write_to_processing_log(FILE_BASENAME(i_l2p_core_filename),$
                                          (i_processing_type + "," + "COMPACT_TOTAL_TIME: " + $
                                           STRING(compact_total_time,FORMAT='(f0.2)')));

    if (debug_mode) then begin
            print, debug_module + "compact_total_time ",compact_total_time;
            print, debug_module + "i_l2p_core_name_only ",i_l2p_core_name_only;
            print, debug_module + "i_o_l2p_core_filename ",i_o_l2p_core_filename;
    endif
    return, o_compress_status;
end
