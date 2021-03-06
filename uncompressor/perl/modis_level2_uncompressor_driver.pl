#!/usr/local/bin/perl
#  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Subroutine to perform the crawling for files and perform the uncompression.
#
#------------------------------------------------------------------------------------------------

# Location of GHRSST Perl library functions.

$GHRSST_PERL_LIB_DIRECTORY = $ENV{GHRSST_PERL_LIB_DIRECTORY};

do "$GHRSST_PERL_LIB_DIRECTORY/actualize_directory.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/crawl_sst_sst4_directories.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/is_granule_quicklook_or_refined.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/ghrsst_notify_operator.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/register_job.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/delete_job.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/uncompress_straggling_files.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/rename_from_test_file_name_to_ops_file_name.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/mkdir_with_error_handling.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/file_move_with_error_handling.pl";

use File::Basename;
use File::Copy;

# Global variables related to file locking.

$g_use_file_locking_mechanism_flag = 0;  # Flag to indicate if the file locking mechanism is to be used or not.
$g_semaphore_name = "";                  # Name of semaphore if using file locking mechanism.

# Load the nfs*lock.pl scripts if using the file locking mechanism.
if ($ENV{GHRSST_MODIS_L2_USE_FILE_LOCK} eq "true") {
    # Set this global variable so we can detect if we are using the file locking mechanism or not.
    $g_use_file_locking_mechanism_flag = 1;
    do "$GHRSST_PERL_LIB_DIRECTORY/nfs_lock_file_wrapper.pl";
    do "$GHRSST_PERL_LIB_DIRECTORY/nfs_unlock_file.pl";
}

my $NUM_FILES_TO_PROCESS = 500;  # Default number of files to process.  Will reset to smaller number if input is smaller.

#------------------------------------------------------------------------------------------------------------------------
sub modis_level2_uncompressor_driver {
    # Set the input retrieved from command line.

    my $i_datatype          = shift;  # Always "sea_surface_temperature".
    my $i_datasource        = shift;  # The data sources are: {MODIS_A,MODIS_T}
    my $i_processing_type   = shift;  # Processing types are: {AQUA_QUICKLOOK, TERRA_QUICKLOOK, AQUA_REFINED, TERRA_REFINED} all uppercase.
    my $i_modis_search_directory     = shift;
    my $i_modis_data_name_prefix     = shift; 
    my $i_num_files_to_uncompress    = shift; 
    my $i_value_move_instead_of_copy = shift;

    my $debug_module = "modis_level2_uncompressor_driver:";
    my $debug_mode   = 0;

    # Output variable(s).

    my $o_uncompressor_driver_status = 0;  # A status of 0 means successful and 1 means failed.

    # Register our job.

    my ($job_register_status,$job_name,$job_age) = register_job($g_routine_name,$i_processing_type);
    if ($job_register_status == 0) {
       log_this("WARN",$g_routine_name,"Job $job_name, age $job_age (in seconds) already exist.  Nothing to do.");
       exit(1); # Set the status to 1 so the client will know what to do.
    }

    # Some time related business.

    my $begin_processing_time = localtime;
    log_this("INFO",$g_routine_name,"BEGIN_PROCESSING_TIME $begin_processing_time");

    # Some variables related to sigevent.

    my $sigevent_type = "information";
    my $sigevent_msg = "hello there";
    my $sigevent_email_to = "DUMMY_EMAIL";
    my $sigevent_url = $ENV{GHRSST_SIGEVENT_URL};
    if ($sigevent_url eq '') {
        print "You must defined the sigevent URL: i.e. setenv GHRSST_SIGEVENT_URL http://lanina.jpl.nasa.gov:8100\n"; 
        die ("Cannot continue until environment GHRSST_SIGEVENT_URL is defined"); 
    }

    my $sigevent_clause = "SIGEVENT=" . $sigevent_url . "&category=UNCATEGORIZED&provider=jpl";
    my $temp_dir = "/tmp/";
    my $msg2report = 7;
    my $sigevent_data = '';

    # Time related variables used to keep track of how long things take.

    my $program_time_start = time();
    my $current_time = $program_time_start;

    my $log_message   = ""; 

    # Crawl for a list of files in input directory.

    my $time_start_crawling = time();
    log_this("INFO",$g_routine_name,"BEGIN_CRAWLING $i_modis_search_directory"); 

    $i_datatype = "";   # This is not used in crawl_sst_sst4_directories() function.
    my ($status,$file_list_ref) = crawl_sst_sst4_directories($i_datatype,$i_datasource,$i_processing_type,$i_modis_search_directory,$i_modis_data_name_prefix);

    log_this("INFO",$g_routine_name,"CRAWL_STAGE  " . scalar(@$file_list_ref) . " CRAWL_DIRECTORY " . $i_modis_search_directory); 

    my $time_end_crawling = time();
    my $time_spent_in_crawling = $time_end_crawling - $time_start_crawling; 

    # Create a new list to igore the .md5 files if the crawling had picked them up.
    # Also ignore any files that ends with .NFSLock file since it is a file related to file locking mechanism.

    my @filtered_sst_sst4_names_without_md5_files = ();

    foreach $filename (@$file_list_ref) {
        if ((rindex($filename,".md5")     == -1) &&
            (rindex($filename,".NFSLock") == -1)) {
            push @filtered_sst_sst4_names_without_md5_files,$filename;
        }
    }

    my $scratch_area = $ENV{SCRATCH_AREA};
    my $l_actualize_status = actualize_directory($scratch_area);

    my @sst_sst4_filelist = @filtered_sst_sst4_names_without_md5_files; 

    my $num_sst_sst4_files = scalar(@sst_sst4_filelist);

    if ($debug_mode) {
        print $debug_module . "num_sst_sst4_file            $num_sst_sst4_files\n";
        print $debug_module . "i_datatype                   $i_datatype\n";
        print $debug_module . "i_datasource                 $i_datasource\n";
        print $debug_module . "i_processing_type            $i_processing_type\n";
        print $debug_module . "i_modis_search_directory     $i_modis_search_directory\n";
        print $debug_module . "i_modis_data_name_prefix     $i_modis_data_name_prefix\n";
        print $debug_module . "i_num_files_to_uncompress    $i_num_files_to_uncompress\n";
        print $debug_module . "i_value_move_instead_of_copy $i_value_move_instead_of_copy\n";
        print $debug_module . "sst_sst4_filelist\n";
        print "[\n";
        print @sst_sst4_filelist;
        print "]\n";
    }

    # Return if there's nothing to do.
    if ($num_sst_sst4_files == 0) {
        my $end_processing_time = localtime;
        log_this("INFO",$g_routine_name,"NO_FILES_FOUND $i_modis_search_directory");
        log_this("INFO",$g_routine_name,"BEGIN_PROCESSING_TIME $begin_processing_time");
        log_this("INFO",$g_routine_name,"END_PROCESSING_TIME   $end_processing_time");
        my $job_delete_status = delete_job($g_routine_name,$i_processing_type);
        exit(0);
    }

    log_this("INFO",$g_routine_name,"FILTER_STAGE " . $num_sst_sst4_files . " $i_modis_search_directory"); 

    # Everything is OK, we can proceed with the decompression task.

    my $index_to_sst_sst4_list = 0;
    my $i_sst_filename = "";
    my $sst_filename_compressed_file = "";

    my $num_files_read                  = 0;
    my $num_uncompressed_files_created  = 0;
    my $time_spent_in_uncompressing     = 0; 
    my $time_spent_in_deciphering_quicklook_refined = 0; 
    my $time_spent_in_moving_to_destination         = 0; 
    my $total_Bytes_in_files        = 0; 
    my $total_Bytes_created_files   = 0; 
    my $name_only = "";

    # Reset the number of files to process if input is smaller.

    if ($i_num_files_to_uncompress <= $NUM_FILES_TO_PROCESS) {
        $NUM_FILES_TO_PROCESS = $i_num_files_to_uncompress;
    }

    # For every name found, send it to be uncompressed.

    while (($index_to_sst_sst4_list < $num_sst_sst4_files) && ($num_uncompressed_files_created < $NUM_FILES_TO_PROCESS)) {

        $sst_filename_compressed_file  = $sst_sst4_filelist[$index_to_sst_sst4_list]; 

        # Remove the carriage return

        chomp ($sst_filename_compressed_file);

        #log_this("INFO",$g_routine_name,($num_uncompressed_files_created + 1) . " OUT_OF " . $num_sst_sst4_files . " PROCESSING_GRANULE $sst_filename_compressed_file");
        log_this("INFO",$g_routine_name,($index_to_sst_sst4_list + 1) . " OUT_OF " . $num_sst_sst4_files . " PROCESSING_GRANULE $sst_filename_compressed_file");

        #
        # Get the size of this file.
        #

        my $size_of_sst_file_in_bytes  = (stat($sst_filename_compressed_file))[7];
        log_this("INFO",$g_routine_name,"ORIGINAL_FILE $sst_filename_compressed_file");
        $total_Bytes_in_files += $size_of_sst_file_in_bytes; 

        # Get the age of the file so we can report it.

        my $time_now = time();
        my $minutes_difference_between_sst_and_now = 0;
        my $last_modified_time_of_sst              =  (stat($sst_filename_compressed_file))[9];  # Get last modified time in seconds since 1970
        my $seconds_difference_between_sst_and_now = $time_now - $last_modified_time_of_sst;
        $minutes_difference_between_sst_and_now = sprintf("%.0f",$seconds_difference_between_sst_and_now/60);

        # Set the scratch area for decompression to the same directory as the compressed file so the move later to the _QUICKLOOK or _REFINED directory won't be costly.

        #my $decompress_to_directory = dirname($sst_filename_compressed_file);  # Having problem with this, moving back to scratch_area variable.
        my $decompress_to_directory = $scratch_area;
        log_this("INFO",$g_routine_name,"DECOMPRESS_TO_DIRECTORY $decompress_to_directory FILE $sst_filename_compressed_file");

        # Uncompressed the file.

        my $time_start_uncompress = time();

        # Status returned: 0 good, 1 bad.

        my ($status,$i_sst_filename)  = perform_decompression_task($sst_filename_compressed_file,$i_processing_type,$decompress_to_directory,$i_value_move_instead_of_copy);

        if ($status == 1) {
            $sigevent_type = "error";
            $sigevent_msg = "File $sst_filename_compressed_file is either not found, may be corrupted or may have a lock on it.";
            $sigevent_data = ""; # Must reset to empty string to signify there's no data to pass along.
            ghrsst_notify_operator($g_routine_name,$sigevent_type,$sigevent_msg,$sigevent_email_to,$sigevent_clause,$temp_dir,$msg2report,$sigevent_data);

            $index_to_sst_sst4_list     = $index_to_sst_sst4_list + 1;
            log_this("ERROR",$g_routine_name,$sigevent_msg);

            # Set status of decompression so we can return it.
            $o_uncompressor_driver_status = 1;  # A status of 0 means successful and 1 means failed.
            $num_files_read += 1;
            $index_to_sst_sst4_list += 1;
            next;
        }

        log_this("INFO",$g_routine_name,"UNCOMPRESSED_FILE $i_sst_filename");
        if (!(-e $i_sst_filename)) {
            log_this("WARN",$g_routine_name,"UNCOMPRESSED_FILE_NOT_FOUND $i_sst_filename");
        }

        #
        # Get the size of this file.
        #

        my $size_of_uncompressed_file_in_bytes  = (stat($i_sst_filename))[7];
        $total_Bytes_created_files   += $size_of_uncompressed_file_in_bytes; 

        # Keep track of how many files we have read.
        $num_files_read += 1;

        my $time_end_uncompress = time();
        $time_spent_in_uncompressing += ($time_end_uncompress - $time_start_uncompress); 

        # If processing test files from OBPG, we need to rename the files to reflect the NetCDF file type and the correct types: SST, SST4 and OC
        my $original_uncompressed_filename = $i_sst_filename;
        $i_sst_filename = rename_from_test_file_name_to_ops_file_name($i_sst_filename);

        # If the name did changed from the original, go ahead and do the rename of the file on the file system.
        # We can use rename since it is on the same file system otherwise, we have to use the move() function.

        if ($original_uncompressed_filename ne $i_sst_filename) {
            rename($original_uncompressed_filename,$i_sst_filename);
            log_this("INFO",$g_routine_name,"NETCDF_FILE_RENAME FROM $original_uncompressed_filename TO $i_sst_filename");
        }

        # Since we cannot determined if the file is quicklook or refined just from the filename, we have to open up the uncompressed file and read the "Processing Version" attribute.
        # Once that is known, we can move the file to its final location.

        my $time_start_deciphering = time();

        # New logic: We have a Perl script to allow the fetching of the processing_version global attribute.
        # By default, we will not use it.  Set GHRSST_MODIS_L2_USE_PERL_FUNCTION_TO_GET_REFINED_FLAG to true if wish to use the new function.

        my $quicklook_or_refined_flag = "";

        # If the stream is historical, there is no need to open the file since we assume they are refined.

        if ($ENV{GHRSST_MODIS_L2_STREAM_IS_HISTORICAL} eq "true") {
            $quicklook_or_refined_flag = 'REFINED';
        } else {   
            my $use_perl_script_to_get_refined_flag = 0;
            if ($ENV{GHRSST_MODIS_L2_USE_PERL_FUNCTION_TO_GET_REFINED_FLAG} eq "true") {
                $use_perl_script_to_get_refined_flag = 1;
            }

            if ($use_perl_script_to_get_refined_flag) {
                do "$GHRSST_PERL_LIB_DIRECTORY/is_granule_quicklook_or_refined_historical.pl";
                $quicklook_or_refined_flag = is_granule_quicklook_or_refined_historical($i_sst_filename);
            } else {
                $quicklook_or_refined_flag = is_granule_quicklook_or_refined($i_sst_filename);
            }
        }
        my $time_end_deciphering = time();

        $time_spent_in_deciphering_quicklook_refined += ($time_end_deciphering - $time_start_deciphering);

        # If performing a test, set the value of quicklook_or_refined_flag to 'UNDEFINED' to see what the code will do.
        if ($g_perform_quick_refined_make_it_bad_test) { $quicklook_or_refined_flag = 'UNDEFINED'; }

        # Do one last sanity check if the file was neither QUICKLOOK nor REFINED, we raise a sigevent.

        if (($quicklook_or_refined_flag ne "QUICKLOOK") && ($quicklook_or_refined_flag ne "REFINED")) {
            $sigevent_type = "error";
            $sigevent_msg = "File $i_sst_filename could not determined to be QUICKLOOK or REFINED.";
            $sigevent_data = ""; # Must reset to empty string to signify there's no data to pass along.
            log_this("ERROR",$g_routine_name,$sigevent_msg);
            ghrsst_notify_operator($g_routine_name,$sigevent_type,$sigevent_msg,$sigevent_email_to,$sigevent_clause,$temp_dir,$msg2report,$sigevent_data);
            $o_uncompressor_driver_status = 1;  # A status of 0 means successful and 1 means failed.
            $index_to_sst_sst4_list += 1;
            move_to_quarantine($scratch_area,$i_sst_filename);
            next;
        }

        #
        # Build the output file name by adding the value in quicklook_or_refined_flag variable.
        #

        # First remove the directory name of the input file and just get the file name.

        my @splitted_tokens = split(/\//,$i_sst_filename);
        my $num_tokens = @splitted_tokens;
        $name_only = $splitted_tokens[$num_tokens-1];  # Get just the name.   We assume the name is the last token.

        my $directory_name = dirname($sst_filename_compressed_file); # Use the directory name of the compressed file to get the output directory.

        my $upper_level_output_directory = strip_trailing_slash($directory_name) . '_' . $quicklook_or_refined_flag;  # We add _QUICKLOOK or _REFINED to the directory name.

        if ($g_uncompressor_make_top_level_mkdir_failed == 1) { $upper_level_output_directory = "/tmp_cannot_create_this_directory"; }

        # Create the directory if it does not exist yet.
        if (!(-e $upper_level_output_directory)) {
            my $status_mkdir = mkdir_with_error_handling($upper_level_output_directory);
            # The mkdir function returns true if successful and false if failed.  If cannot make the directory, return.
            if ($status_mkdir == 0) { 
                $o_uncompressor_driver_status = 1;  # A status of 0 means successful and 1 means failed.
                return($o_uncompressor_driver_status);
            }
        }

        # Now we can create our output name with its proper bucket.

        my $out_filename  = $upper_level_output_directory . "/" . $name_only;

        $log_message = "FILE_SIZE " . $size_of_uncompressed_file_in_bytes . " " . $i_sst_filename . " " . "FILE_AGE " . $minutes_difference_between_sst_and_now;
        log_this("INFO",$g_routine_name,$log_message);

        $log_message = "FILE_TYPE $quicklook_or_refined_flag $i_sst_filename"; 
        log_this("INFO",$g_routine_name,$log_message);

        #
        # Finally, we can move the file to its proper location.
        #

        my $time_start_moving = time();

        # There are 2 ways to move the file.  One is to use the File::Copy module with the move() function.
        # The other method is to use the system mv command.  Both does take time.

        $log_message = "FILE_MOVE $i_sst_filename $out_filename";
        log_this("INFO",$g_routine_name,$log_message);

        if (2 == 2) {
            if ($g_uncompressor_make_file_move_failed == 1) { $i_sst_filename = "/tmp/this_file_does_not_exist"; }
            my $move_status = file_move_with_error_handling($i_sst_filename,$out_filename);
            if ($move_status == 0) {
                $index_to_sst_sst4_list += 1;
                $o_uncompressor_driver_status = 1;  # A status of 0 means successful and 1 means failed.
                next;
            }
        } else {
            # This method can move across devices.
            system("mv $i_sst_filename $out_filename");
            if ($g_debug) { log_this("DEBUG",$g_routine_name,"mv $i_sst_filename $out_filename"); }
        }
        my $time_end_moving = time();
        $time_spent_in_moving_to_destination += ($time_end_moving - $time_start_moving); 

        $log_message = "UNCOMPRESSED_FILE_CREATED ". $out_filename; 
        log_this("INFO",$g_routine_name,$log_message);

        $num_uncompressed_files_created += 1;
        $index_to_sst_sst4_list         += 1;
    }    # End while loop

    my $program_time_end = time();
    my $elapsed_in_seconds = $program_time_end - $program_time_start;
    my $elapsed_in_minutes = sprintf("%.2f",($elapsed_in_seconds/60.0));

    # ---------- Close up shop ----------

    #
    # Variables related to disk space calculation.
    #

    my $Kilobyte_to_Byte_conversion_factor     = 1024;       # Kilobyte_const in Bytes
    my $Megabyte_to_Byte_conversion_factor     = 1048576;    # Megabyte_const in Bytes
    my $Gigabyte_to_Byte_conversion_factor     = 1073741824; # in Bytes
    my $Gigabyte_to_Megabyte_conversion_factor = 1024;       # in Megabyte

    my $total_Megabytes_in_files = $total_Bytes_in_files / $Megabyte_to_Byte_conversion_factor;
    my $total_Gigabytes_in_files = $total_Bytes_in_files / $Gigabyte_to_Byte_conversion_factor;

    # Print run statistics.

    #log_this("INFO",$g_routine_name,"TIME_STAT Seconds_spent_in_crawling         $time_spent_in_crawling");
    log_this("INFO",$g_routine_name,"TIME_STAT Seconds_spent_in_uncompress                    $time_spent_in_uncompressing");
    log_this("INFO",$g_routine_name,"TIME_STAT Seconds_spent_in_deciphering_quicklook_refined $time_spent_in_deciphering_quicklook_refined");
    log_this("INFO",$g_routine_name,"TIME_STAT Seconds_spent_in_moving_to_destination         $time_spent_in_moving_to_destination");
    log_this("INFO",$g_routine_name,"FILES_STAT Number_of_files_read             $num_files_read");
    log_this("INFO",$g_routine_name,"FILES_STAT total_Gigabytes_in_files         $total_Gigabytes_in_files");
    #log_this("INFO",$g_routine_name,"FILES_STAT Batch_size                       $NUM_FILES_TO_PROCESS");
    #log_this("INFO",$g_routine_name,"FILES_STAT Number_of_uncompressed_files_created $num_uncompressed_files_created");
    #log_this("INFO",$g_routine_name,"FILES_STAT total_Bytes_in_files             $total_Bytes_in_files");
    #log_this("INFO",$g_routine_name,"FILES_STAT total_Megabytes_in_files         $total_Megabytes_in_files");
    #
    my $total_Megabytes_created = $total_Bytes_created_files / $Megabyte_to_Byte_conversion_factor;
    my $total_Gigabytes_created = $total_Bytes_created_files / $Gigabyte_to_Byte_conversion_factor;

    #log_this("INFO",$g_routine_name,"FILES_STAT total_Bytes_created_files $total_Bytes_created_files");
    log_this("INFO",$g_routine_name,"FILES_STAT total_Megabytes_created   $total_Megabytes_created");
    log_this("INFO",$g_routine_name,"FILES_STAT total_Gigabytes_created   $total_Gigabytes_created");

    if ($num_uncompressed_files_created > 0) {
        my $average_processing_time = $elapsed_in_seconds / $num_uncompressed_files_created;
        log_this("INFO",$g_routine_name,"TIME_STAT Seconds_Average_Processing $average_processing_time");
    }

    #log_this("INFO",$g_routine_name,"TIME_STAT Seconds_Elapsed           $elapsed_in_seconds");
    #log_this("INFO",$g_routine_name,"TIME_STAT Minutes_Elapsed           $elapsed_in_minutes");

    # Before ending the processing, we place an additional processing task to uncompressed any files that have been copied/moved
    # to the scratch area but was not able to be uncompressed or moved to its final destination.
    # The scratch directory may also contain uncompressed file but the job to moved the file may also died or failed to move it.

    # We change the search directory to our scratch directory for files that have been copied but have not been uncompressed.
    # This is necessary due to the fact that sometimes a job may die and leave the files moved to the scratch area but
    # did not get uncompressed.

    $i_modis_output_directory = $i_modis_search_directory;            # This will let the next routine know where to move the uncompressed file to.
                                                                      # If the search directory was MODIS_AQUA_L2_SST_OBPG and the file was quicklook,
                                                                      # then the output will be MODIS_AQUA_L2_SST_OBPG_QUICKLOOK.
    $i_modis_search_directory = $scratch_area . "/" . $i_datasource;  # The scratch directory plus the file type "MODIS_A" or "MODIS_T" is where the left over files is stored.

    $g_routine_name = "uncompress_straggling_files";
    uncompress_straggling_files($i_datatype,
                                $i_datasource,
                                $i_processing_type,
                                $i_modis_search_directory,
                                $i_modis_data_name_prefix,
                                $i_num_files_to_uncompress,
                                $i_modis_output_directory);

    # Reset the name of the routine back to this function so we can log properly and delete the job.
    $g_routine_name = "modis_level2_uncompressor";
    my $end_processing_time = localtime;
    log_this("INFO",$g_routine_name,"BEGIN_PROCESSING_TIME $begin_processing_time");
    log_this("INFO",$g_routine_name,"END_PROCESSING_TIME   $end_processing_time, $elapsed_in_seconds seconds");

    my $job_delete_status = delete_job($g_routine_name,$i_processing_type);

    return($o_uncompressor_driver_status);
}

# End of of main subroutine modis_level2_uncompressor_driver.



#------------------------------------------------------------------------------------------------------------------------
sub perform_decompression_task {
    # If the name contains .bz2, we will apply the bunzip2 program to it.
    # If it does not, we will simply perform a mv command.  Even if the file are mounted on different devices, the move will be successful.

    # Get input.

    my $i_compressed_filename               = shift;
    my $i_processing_type                   = shift;
    my $i_scratch_directory                 = shift;
    my $i_value_move_instead_of_copy        = shift;

    my $debug_module = "perform_decompression_task:";
    my $debug_mode   = 0;

    if ($debug_mode) {
        print $debug_module . "i_compressed_filename        $i_compressed_filename\n";
        print $debug_module . "i_processing_type            $i_processing_type\n";
        print $debug_module . "i_scratch_directory          $i_scratch_directory\n";
        print $debug_module . "i_value_move_instead_of_copy $i_value_move_instead_of_copy\n";
    }

    # Output variable(s).

    my $o_status = 0;
    my $o_uncompressed_filename = "";

    my $function_name = "perform_decompression_task";

    # Remove the directory name by splitting the name and get just the name.

    my @splitted_tokens = split(/\//,$i_compressed_filename);
    my $num_tokens = @splitted_tokens;
    my $name_only = $splitted_tokens[$num_tokens-1];  # Get just the name. 

    # We must check for existence of the uncompressed file. The program bunzip2 will not allow an overwrite.
    my $name_without_bz_extension = $name_only; 
    my $file_is_compressed_flag = 0;
    if (((rindex($name_only,".bz2")) >= 0) || ((rindex($name_only,".gz")) >= 0)) {
        if ((rindex($name_only,".bz2")) >= 0) {
            $name_without_bz_extension = substr($name_only,0,-4);  # Get everything up to and not include the .
        } else {
            $name_without_bz_extension = substr($name_only,0,-3);  # Get everything up to and not include the .
        }
        $file_is_compressed_flag = 1;
    }

    # Based on the processing type, we will figure where to either uncompress or move the file to.

    my $upper_level_output_directory = "$i_scratch_directory/$i_processing_type";

    # Create the directory if it does not exist yet.
    if (!(-e $upper_level_output_directory)) {
        mkdir($upper_level_output_directory);
    }

    $o_uncompressed_filename = "$upper_level_output_directory/$name_without_bz_extension";
    if ($g_debug) { 
        print "$function_name: file_is_compressed_flag [$file_is_compressed_flag]\n";
        print "$function_name: o_uncompressed_filename [$o_uncompressed_filename]\n";
    }

    # If using a file locking mechanism, lock the file using nfs_lock_file() function with the semaphore with ".lck" appended to the file name.
    my $ok_to_decompress_file_flag = 1;

    if ($g_use_file_locking_mechanism_flag) {
        $ok_to_decompress_file_flag = nfs_lock_file_wrapper($i_compressed_filename);
        if ($g_debug) { 
            print "$g_routine_name: ok_to_decompress_file_flag [$ok_to_decompress_file_flag]\n";
        }
        if ($ok_to_decompress_file_flag == 0) {
            $o_status = 1;
            return ($o_status,$o_uncompressed_filename);
        }
    }

    if (($file_is_compressed_flag == 1) && (-e "$o_uncompressed_filename")) {
        log_this("INFO",$g_routine_name,"FILE_REMOVE_EXISTING_FILE $o_uncompressed_filename");
        unlink "$o_uncompressed_filename";
    }

    if ($g_debug) { 
        print "$function_name: file_is_compressed_flag [$file_is_compressed_flag]\n";
    }
    if ($file_is_compressed_flag == 1)  {
        my $call_system_command_str = "";
        my $move_or_copy_command = "";
        if ($i_value_move_instead_of_copy eq 'yes') {
            $call_system_command_str = "mv $i_compressed_filename $upper_level_output_directory";
            $move_or_copy_command = "FILE_MOVE";
        } else {
            $call_system_command_str = "cp $i_compressed_filename $upper_level_output_directory";
            $move_or_copy_command = "FILE_COPY";
        }

        if ($g_debug) { 
            print "$function_name: call_system_command_str [$call_system_command_str]\n";
        }
        # Do the file move or copy.
        system("$call_system_command_str");

        #
        # Check for errors.
        #
        if ($? == -1) {
            log_this("ERROR",$g_routine_name,"system [$call_system_command_str] failed to execute: $?");
            $o_status = 1;
        } elsif ($? == 256){
            log_this("ERROR",$g_routine_name,"Cannot find file $i_compressed_filename");
            $o_status = 1;
        } elsif ($? == 0){
            $o_status = 0;
            log_this("INFO",$g_routine_name,"$move_or_copy_command $i_compressed_filename $upper_level_output_directory");
        } else {
            log_this("ERROR",$g_routine_name,"system [$call_system_command_str] executed with: $?");
            $o_status = 1;
        }

        # Now that the move or copy is successful, we uncompress the file.
        # Do the uncompression.

        my $temporary_compressed_filename = "$upper_level_output_directory/$name_only";
 
        if (index($name_only,".bz2") >= 0) {
            $call_system_command_str = "/usr/bin/bunzip2 $upper_level_output_directory/$name_only";
        } elsif (index($name_only,".gz") >= 0) {
            $call_system_command_str = "/bin/gunzip        $upper_level_output_directory/$name_only";
        } else {
            print "modis_level2_uncompressor::perform_decompression_task: This program only support .bz2 or .gz uncompression.\n";
            log_this("ERROR",$g_routine_name,"This program only support .bz2 or .gz uncompression.");
            exit(1);
        }

        system("$call_system_command_str");

        #
        # Check for errors.
        #
        if ($? == -1) {
            log_this("ERROR",$g_routine_name,"system [$call_system_command_str] failed to execute: $?");
            $o_status = 1;
        } elsif ($? == 256){
            log_this("ERROR",$g_routine_name,"Cannot find file $upper_level_output_directory/$name_only");
            $o_status = 1;
        } elsif ($? == 0){
            $o_status = 0;
        } else {
            log_this("ERROR",$g_routine_name,"system [$call_system_command_str] executed with: $?");
            $o_status = 1;

            # Since we cannot uncompress this file, it may be corrupted.
            # We need to move it to a quarantine directory for operator to inspect.

            move_to_quarantine($i_scratch_directory,$temporary_compressed_filename);
        }

    } else {
        $o_uncompressed_filename = $i_compressed_filename;  # The file was not compressed at all, we set the output name to the input name.
        log_this("INFO",$g_routine_name,"ORIGINAL_FILE_IS_UNCOMPRESSED_ALREADY $o_uncompressed_filename");
    }

    if ($g_debug) { 
        print "$function_name: o_status [$o_status] o_uncompressed_filename [$o_uncompressed_filename]\n";
    }
    # Remove the lock if using file locking mechanism.
    if ($g_use_file_locking_mechanism_flag) {
        if (defined($g_the_lock)) {
            nfs_unlock_file($g_the_lock,$g_semaphore_name);
        }
    }
    return ($o_status,$o_uncompressed_filename);
}

#------------------------------------------------------------------------------------------------------------------------
sub move_to_quarantine {
    my $i_scratch_directory = shift;
    my $i_filename_to_move  = shift;
    # Since we cannot uncompress this file, it may be corrupted.
    # We need to move it to a quarantine directory for operator to inspect.

    my $quarantine_directory = "$i_scratch_directory/quarantine";

    # Create the directory if it does not exist yet.
    if (!(-e $quarantine_directory)) {
        mkdir($quarantine_directory);
    }
    # Use the module File::Copy to do the move.
    move($i_filename_to_move,$quarantine_directory);
    log_this("ERROR",$g_routine_name,"FILE_MOVE $i_filename_to_move $quarantine_directory");
}

#------------------------------------------------------------------------------------------------------------------------
sub strip_trailing_slash {
    # If a name ends with a slash, function will remove it.
    my $i_name = shift;

    my $o_stripped_name = $i_name; 

    # Get the last character from the input name.

    my $name_length = length($i_name);
    my $last_character = substr($i_name,($name_length-1));

    # If the name ends with a slash, get just up to the slash, not including.
    if ($last_character eq '/') { 
        $o_stripped_name = substr($i_name,0,$name_length-1); # Copy up to the '/' character.
    }
   return ($o_stripped_name);
}

#------------------------------------------------------------------------------------------------------------------------
sub log_this {
    # Function to log a message to screen.
    my $i_log_type      = shift;  # Possible types are {INFO,WARN,ERROR}
    my $i_function_name = shift;  # Where the logging is coming from.  Useful in debuging if something goes wrong.
    my $i_log_message   = shift;  # The text you wish to log screen.

    my $now_is = localtime;

    print $now_is . " " . $i_log_type . " [" . $i_function_name . "] " . $i_log_message . "\n";
}
