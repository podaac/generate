#!/usr/local/bin/perl

#  Copyright 2006, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: manage_ghrsst_modis_data_sets.pl,v 1.39 2007/12/05 19:49:09 qchau Exp $
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
# New Request #xxxx

#
#
# Program manages the GHRSST MODIS datasets by:
#
#    1) Create a list of MODIS dataset files.
#    2) Stage these datasets on a scratch area.
#    3) Pass along this filenames to an IDL program to process these datasets.
#
# Assumption:
#
#   1) The variables in uppercase should have been defined in another program as globals. 
#   2) Both Perl and IDL are available on the running system.
#   3) The run configuration has been loaded.
#
#------------------------------------------------------------------------------------------------

do "$GHRSST_PERL_LIB_DIRECTORY/get_ghrsst_config.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/build_modis_dataset_names_for_processing.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/build_L2P_processed_file_registry.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/perform_modis_temporary_files_cleanup.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/stage_modis_datasets_for_processing.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/append_heart_beat.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/stage_filled_quicklook_datasets_for_processing.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/actualize_directory.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/create_random_filename.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/remove_temporary_log_dir.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/get_modis_processing_directories.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/clear_staged_modis_datasets.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/email_ops_to_report_error.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/generic_get_registry_filename.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/does_temporary_directory_exist.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/load_file_list.pl";

do "$GHRSST_PERL_LIB_DIRECTORY/OLock.pm";

sub get_actual_source_name {
    # Given the combination of 'quicklook_viirs" or "quicklook_modis_a" or "quicklook_modis_t" and return without the _a or _b.
    my $i_partial_directory_name = shift;
    my $o_source_name = "";

    my @splitted_tokens = split(/_/,$i_partial_directory_name,2);  # Get at most 2 tokens.
    $o_source_name = $newstring = join('_', @splitted_tokens[0..1]);
#    print "splitted_tokens[0] [" . $splitted_tokens[0] . "]\n";
#    print "splitted_tokens[0] [" . $splitted_tokens[1] . "]\n";
#    print "i_partial_directory_name [$i_partial_directory_name]\n";
#    print "o_source_name [$o_source_name]\n";
    return($o_source_name);
}

sub manage_ghrsst_modis_data_sets {

    # Returned status.  Value of 0 means ok, 1 means bad.

    my $o_status = 0;

    #
    # Get input(s).
    #
    
    my $i_datatype          = lc($_[0]);   # Lowercase the input. {sea_surface_temperature}
    my $i_datasource        = $_[1];       # Instrument: {MODIS_A,MODIS_T}
    my $i_ftp_push_flag     = $_[2];    # To push the MODIS L2P to melia or not: {yes,no}
    my $i_compress_flag     = $_[3];    # To compress the NetCDF file or not after done writing.
                                    # Values are {"yes", "no"}.  Default is "no". 
    my $i_checksum_flag     = $_[4];    # To create a checksum or not: {yes,no}
    my $i_convert_to_kelvin = $_[5];    # To convert from celcius to kelvin: {yes,no}
    my $i_processing_type   = $_[6];    # Processing type: {QUICKLOOK,REFINED}
    my $i_job_index         = $_[7];     # Job index to pull input data for.
    my $i_use_cluster_flag  = uc($_[8]);  # Use the cluster or not: {MAKE_USE_CLUSTER_IF_AVAILABLE,LEAVE_ALONE_CLUSTER_IF_AVAILABLE}
    my $i_test_parameter    = $_[9];

    #
    # Local variables.
    #

    my $debug_module = "manage_ghrsst_modis_data_sets:";
    my $debug_mode   = 0;

    print "manage_ghrsst_modis_data_sets: i_test_parameter [$i_test_parameter]\n";

    my $file_search_directory = "DUMMY";
    my $modis_search_directory = "DUMMY";
    my $doy_search_directory  = "DUMMY";

    # Time related variables.
    my $time_start = time();

    # Create director(ies) if they don't exist already.
    my $l2p_core_output_directory     = ""; 
    my $scratch_area                  = $ENV{SCRATCH_AREA}; 
    my $l_actualize_status = 0;
    $l_actualize_status = actualize_directory($scratch_area);

    # Make a random number used in creating unique file names.
    my $random_number_suffix = $time_start; 
    my $l_current_time = $time_start;

    my $l_partial_directory_name = lc($i_processing_type) . "_" . lc($i_datasource);
    my $tmp_uncompressed_bzip_filelist = create_random_filename(
                                         $l_partial_directory_name,"uncompressed_bzip_filelist_modis");

    my $modis_data_directory   = "";
    my $modis_data_name_prefix = "";
    my $idl_argument_strings   = "";
    my $rt_flag = "";
    my $call_system_command_str = "";
    my $call_shell_command_str  = ""; 
    my $source_and_type = $i_datasource . "_" . $i_processing_type;
    my $L2P_registry = ""; 

    # Get the flag from config file whether we should uncompress the staged
    # data files or not.

    my $l_uncompress_modis_input_flag      = get_ghrsst_config("UNCOMPRESS_MODIS_INPUT_FILE_FLAG");
    my $l_uncompress_filled_quicklook_flag = get_ghrsst_config("UNCOMPRESS_FILLED_QUICKLOOK_INPUT_FILE_FLAG");
    my $l_stage_filled_quicklook_flag = get_ghrsst_config("STAGE_FILLED_QUICKLOOK_INPUT_FILE_FLAG");

    # Depend on the processing type, use different registry.
    $L2P_registry = generic_get_registry_filename($scratch_area,
                                                  $i_datasource,
                                                  $i_processing_type);

    # Location of bin directories.  May be different on different
    # machines.  On seaworld, the two values are /usr/bin and /bin

    my $GLOBAL_SYSTEM_BIN_DIRECTORY = get_ghrsst_config("LOCAL_MACHINE_SYSTEM_BIN_DIRECTORY");

    # Create a semaphore to lock the L2P Processing process.  This should lock
    # only the MODIS_A or MODIS_T thus allowing two processing streams to run the same time.
    # Make sure to add the processing type to the name to allow the REFINED stream to run as well.

    my $semaphore_lock_common_area    = $ENV{SEMAPHORE_LOCK_COMMON_AREA};
    my $lock_name = "$semaphore_lock_common_area" . "/" . $i_processing_type . "_" . $i_datasource . "_L2P_process_" . $ENV{RANDOM_NUMBER};
    my $l2p_stream_lock = OLock->new("$lock_name");

    # Lock the process stream.
    $l2p_stream_lock->semlock();

    #
    # Get the processing directories.
    #

    ($modis_search_directory,
     $modis_data_name_prefix,
     $l2p_core_output_directory) = get_modis_processing_directories( 
                                       $i_datasource,
                                       $i_processing_type);

    # Get a list of names of the full directory.

    my $l_status = 0;

    my $num_directory_levels = 3;  # The directory tree has year/day_of_year/filename
    my $sort_flag = 'no';

    # Extract everything except the last two characters from the l_partial_directory_name
    # since we don't want the "_a" or "_t" from the name.

    #    my $source_name = substr($l_partial_directory_name,0,length($l_partial_directory_name)-2);
    my $source_name = get_actual_source_name($l_partial_directory_name);
    my ($status,$input_list_ref) = load_file_list($modis_search_directory, $i_datasource, $i_processing_type, $modis_data_name_prefix, $i_job_index);
    my @modis_filelist = @$input_list_ref;


    if ($debug_mode) {
        print $debug_module . "modis_search_directory [$modis_search_directory]\n";
        print $debug_module . "modis_data_name_prefix [$modis_data_name_prefix]\n";
        print $debug_module . "scratch_area           [$scratch_area]\n";
        print $debug_module . "source_name            [$source_name]\n";
        print $debug_module . "num_directory_levels   [$num_directory_levels]\n";
        print $debug_module . "sort_flag              [$sort_flag]\n";
        print $debug_module . "l_current_time         [$l_current_time]\n";
    }
    #    exit(0);

    if ($i_test_parameter eq "FAILED_LOAD_FILE_LIST") { $l_status = 1; }

    if ($l_status != 0) {
        print "manage_ghrsst_modis_data_sets: Failure in load_file_list function.\n";
        print "manage_ghrsst_modis_data_sets: Cannot continue.\n";
        $o_status = 1;

        my @error_message = ();
        push(@error_message,"\n");
        push(@error_message,"You are receiving this message because there was an error in MODIS L2P Processing.\n");
        push(@error_message,"Please do not reply to the email.\n");
        push(@error_message,"\n"); 
        push(@error_message,"manage_ghrsst_modis_data_sets: Failure in load_file_list() function.\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: modis_search_directory = $modis_search_directory\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: modis_data_name_prefix = $modis_data_name_prefix\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: scratch_area           = $scratch_area\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: source_name            = $source_name\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: num_directory_levels   = $num_directory_levels\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: sort_flag              = $sort_flag\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: l_current_time         = $l_current_time\n");
        push(@error_message,"\n");

        email_ops_to_report_error(\@error_message);

        return ($o_status);
    }

    # Build the file if it does not exist already.

    $l_status = build_L2P_processed_file_registry($L2P_registry);

    if ($i_test_parameter eq "FAILED_BUILD_L2P_PROCESSED_FILE_REGISTRY") { $l_status = 1; }

    if ($l_status != 0) {
        print "manage_ghrsst_modis_data_sets: Failure in build_L2P_processed_file_registry() function.\n";
        print "manage_ghrsst_modis_data_sets: Cannot continue.\n";
        $o_status = 1;

        my @error_message = ();
        push(@error_message,"\n");
        push(@error_message,"You are receiving this message because there was an error in MODIS L2P Processing.\n");
        push(@error_message,"Please do not reply to the email.\n");
        push(@error_message,"\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: Failure in build_L2P_processed_file_registry() function.\n");

        email_ops_to_report_error(\@error_message);

        return ($o_status);
    }

    #
    # Build a list of names of datasets to process.
    #

    my $num_datasets_to_process = 0; 
    my $l_build_name_status = 0; 

    # For each new file, check against the L2P_registry.  If found, do nothing.
    # The returned list can be empty. 

    ($l_build_name_status,
     $num_datasets_to_process,
     $ref_original_uncompressed_filelist,
     $ref_uncompressed_data_filelist,
     $ref_l2p_core_filelist,
     $ref_l2p_core_name_only_filelist,
     $ref_meta_data_filelist) = build_modis_dataset_names_for_processing($tmp_uncompressed_bzip_filelist,
                                                          $L2P_registry,
                                                          $l2p_core_output_directory,
                                                          $i_datasource,
                                                          $scratch_area,
                                                          $i_compress_flag,
                                                          \@modis_filelist,
                                                          $i_processing_type);

    if ($l_build_name_status != 0) {
        print "manage_ghrsst_modis_data_sets: Failure in build_modis_dataset_names_for_processing() function.\n";
        print "manage_ghrsst_modis_data_sets: Cannot continue.\n";
        $o_status = 1;
        return ($o_status);
    }


    # Add heart beat to signify that the the data are being staged.
    if ($num_datasets_to_process == 0) { $num_datasets_to_process = "ZERO"; }
    my $l_heart_beat_status = append_heart_beat("dummy","MODIS_L2P_PROCESSING $i_processing_type $i_datasource $i_use_cluster_flag, $num_datasets_to_process datasets PROCESSING_STAGING");

    # Stage the MODIS datasets by copying them from ftp site to a stage area.
    my $l_stage_status = stage_modis_datasets_for_processing($ref_original_uncompressed_filelist,
                                                             $scratch_area,
                                                             $i_processing_type,
                                                             $i_datasource,$l_uncompress_modis_input_flag,$ref_l2p_core_name_only_filelist);

    if ($i_test_parameter eq "FAILED_STAGE_MODIS_DATASETS_FOR_PROCESSING") { $l_stage_status = 1; }

    if ($l_stage_status != 0) {
        print "manage_ghrsst_modis_data_sets: Failure in stage_modis_datasets_for_processing() function.\n";
        print "manage_ghrsst_modis_data_sets: Cannot continue.\n";
        $o_status = 1;

        my @error_message = ();
        push(@error_message,"\n");
        push(@error_message,"You are receiving this message because there was an error in MODIS L2P Processing.\n");
        push(@error_message,"Please do not reply to the email.\n");
        push(@error_message,"\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: Failure in stage_modis_datasets_for_processing() function.\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: ref_original_uncompressed_filelist = $ref_original_uncompressed_filelist\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: scratch_area                       = $scratch_area\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: i_processing_type                  = $i_processing_type\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: i_datasource                       = $i_datasource\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: l_uncompress_modis_input_flag      = $l_uncompress_modis_input_flag\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: ref_l2p_core_name_only_filelist    = $ref_l2p_core_name_only_filelist\n");

        email_ops_to_report_error(\@error_message);

        return ($o_status);
    }
    my $staged_time_in_seconds = time() - $time_start;
    if ($num_datasets_to_process == 0) { $num_datasets_to_process = "ZERO"; }
    my $l_heart_beat_status = append_heart_beat("dummy","MODIS_L2P_PROCESSING $i_processing_type $i_datasource $i_use_cluster_flag, $num_datasets_to_process datasets PROCESSING_STAGED, $staged_time_in_seconds elapsed_seconds");

    # If the processing type is REFINED, stage the additional "filled" Quicklook MODIS L2P so
    # the Refined MODIS L2P can be filled with the ancillary data.
    #
    # These files will then be picked up and processed by the IDL codes.

    # Add heart beat to signify that the processing have started.
    if ($num_datasets_to_process == 0) { $num_datasets_to_process = "ZERO"; }
    my $l_heart_beat_status = append_heart_beat("dummy","MODIS_L2P_PROCESSING $i_processing_type $i_datasource $i_use_cluster_flag, $num_datasets_to_process datasets PROCESSING_STARTED");

    if ($i_processing_type eq "REFINED" && $l_stage_filled_quicklook_flag eq "yes") {
        my $time_start_stage_filled_quicklook = time();
        my $l_heart_beat_status = append_heart_beat("dummy","MODIS_L2P_PROCESSING $i_processing_type $i_datasource $i_use_cluster_flag, $num_datasets_to_process datasets PROCESSING_STAGING_FILLED_QUICKLOOK");
        # Stage the Filled Quicklook datasets.
        my $l_stage_filled_quicklook_status = stage_filled_quicklook_datasets_for_processing(
                             $ref_l2p_core_filelist,
                             $scratch_area,
                             $i_processing_type,
                             $i_datasource,$l_uncompress_filled_quicklook_flag);
        my $staged_time_in_seconds = time() - $time_start_stage_filled_quicklook;
        my $l_heart_beat_status = append_heart_beat("dummy","MODIS_L2P_PROCESSING $i_processing_type $i_datasource $i_use_cluster_flag, $num_datasets_to_process datasets PROCESSING_STAGED_FILLED_QUICKLOOK, $staged_time_in_seconds elapsed_seconds");

        # Note: If the data cannot be staged, we keep going.  The IDL code will merely skip
        # these files.
    }

    # We release the lock here since the datasets have been staged
    # and we are gauranteed that another script will not trample over the current jobs.

    $l2p_stream_lock->semunlock();

    ################################################################################
    #                                                                              #
    # Create a temporary IDL batch file to process the MODIS data file.            #
    #                                                                              #
    ################################################################################

    # Add to heart beat.

    #    my $l_heart_beat_status = append_heart_beat("dummy","manage_ghrsst_modis_data_sets, MODIS_L2P_JOB_BEGIN $i_processing_type $i_datasource $i_use_cluster_flag, $num_datasets_to_process datasets");

    # Call IDL if anything to process.

    # ---> Begin IDL call block 
    if ($num_datasets_to_process > 0) {

        $idl_argument_strings = "-args \"$tmp_uncompressed_bzip_filelist\" \"$source_and_type\" \"$i_convert_to_kelvin\" \"$L2P_registry\" \"$i_compress_flag\" \"$i_processing_type\" \"$i_use_cluster_flag\" ";

        #
        # Pass the list of MODIS data files and have them processed by the IDL program. 
        #

        #print "calling process_modis_datasets.pro with modis_filelist\n";

        print "manage_ghrsst_modis_data_sets: Running process_modis_datasets IDL script...\n\n";

        @args = ("/usr/local/bin/idl");

        #    print "args[0] = $args[0]\n";

        $rt_flag = "-rt=$ENV{GHRSST_IDL_LIB_DIRECTORY}/process_modis_datasets.sav";    # NET edit. (IDL directory)
        $call_system_command_str = "$args[0] $rt_flag $idl_argument_strings";

        #    system("$call_system_command_str");
        #    my $sys_stat = $? >> 8;
        #
        #    if ($sys_stat != 1) {
        #        print "manage_ghrsst_modis_data_sets: sys_stat is not equal to 1.  sys_stat = $sys_stat\n";
        #    } else {
        #        print "manage_ghrsst_modis_data_sets: sys_stat is equal to 1\n";
        #    }


        if ($i_test_parameter eq "FAILED_IDL_EXECUTION") {
            # This is a no-op 
            my $dummy_variable = 0;
        } else {
            # Only make the system call if we are not testing the FAILED_IDL_EXECUTION parameter.
            system("$call_system_command_str");
        }

        #
        # Check for errors.
        #

        if ($? == -1) {
                print "manage_ghrsst_modis_data_sets: system [$call_system_command_str] failed to execute: $?\n";
                $o_status = 1;
        } elsif ($? == 256){
                print "manage_ghrsst_modis_data_sets: Cannot find file in system [$call_system_command_str].\n";
                $o_status = 1;
        } elsif ($? == 0){
                # print "manage_ghrsst_modis_data_sets: system $args[0] < $args[1] executed with: $?\n";
                # print "manage_ghrsst_modis_data_sets: Everything is OK.\n";
                $o_status = 0;
        } else {
                print "manage_ghrsst_modis_data_sets: system [$call_system_command_str] executed with: $?\n";
                $o_status = 1;
        }

        #  Must shift 8 bits to get the actual value.

        #printf "manage_ghrsst_modis_data_sets: child exited with value %d\n", $?;
        #printf "manage_ghrsst_modis_data_sets: child exited with value shifted %d\n", $? >> 8;

        #print "done calling process_modis_datasets.pro with modis_filelist\n";

    } # ---> End IDL call block 

    # Time-related calculations for heart_beat.

    my $time_end = time();
    my $elapsed_in_seconds = $time_end - $time_start;
    my $elapsed_in_minutes = sprintf("%.2f",($elapsed_in_seconds/60.0));
    my $average_time_per_dataset = 0.0; 
    if ($num_datasets_to_process > 0) {
       $average_time_per_dataset = sprintf("%.2f",($elapsed_in_minutes / $num_datasets_to_process));
    }

    # Add to heart beat.

    if ($num_datasets_to_process == 0) { $num_datasets_to_process = "ZERO"; }

    if ($i_test_parameter eq "FAILED_IDL_EXECUTION") { $o_status = 1; }

    if ($o_status == 0) {
        my $l_heart_beat_status = append_heart_beat("dummy","MODIS_L2P_PROCESSING $i_processing_type $i_datasource $i_use_cluster_flag, $num_datasets_to_process datasets PROCESSING_ENDED, $elapsed_in_minutes elapsed_minutes, $average_time_per_dataset average");
    } else {
        # Clear out staged modis datasets if failed in IDL codes.
        my $l_stage_status = clear_staged_modis_datasets($ref_uncompressed_data_filelist,
                                                     $scratch_area,
                                                     $i_processing_type,
                                                     $ref_l2p_core_name_only_filelist);

        my $l_heart_beat_status = append_heart_beat("dummy","MODIS_L2P_PROCESSING $i_processing_type $i_datasource $i_use_cluster_flag, $num_datasets_to_process datasets PROCESSING_FAILED, $elapsed_in_minutes elapsed_minutes, $average_time_per_dataset average");

        my @error_message = ();
        push(@error_message,"\n");
        push(@error_message,"You are receiving this message because there was an error in MODIS L2P Processing.\n");
        push(@error_message,"Please do not reply to the email.\n");
        push(@error_message,"\n");
        push(@error_message,"manage_ghrsst_modis_data_sets: System command failed [$call_system_command_str]\n");

        email_ops_to_report_error(\@error_message);
    }

    #
    # Clean up.
    #

    if (-e $tmp_filelist)                   { unlink($tmp_filelist); }
    if (-e $tmp_uncompressed_bzip_filelist) { unlink($tmp_uncompressed_bzip_filelist); }

    # Remove temporary log directory created by script.

    if (does_temporary_directory_exist($l_partial_directory_name)) {
         remove_temporary_log_dir($l_partial_directory_name);
    }
    if (does_temporary_directory_exist($l_partial_directory_name . "_" . lc($modis_data_name_prefix))) {
        remove_temporary_log_dir($l_partial_directory_name . "_" . lc($modis_data_name_prefix));
    }

    # Release the semaphore.  We don't need it anymore.
    # Commented out for now since it is called after the files were staged.
    #$l2p_stream_lock->semunlock();

    # ---------- Close up shop ----------
    return ($o_status);

} # end sub manage_ghrsst_modis_data_sets
