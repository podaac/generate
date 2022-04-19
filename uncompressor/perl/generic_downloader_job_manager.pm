#!/usr/local/bin/perl
#  Copyright 2016, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# This Perl module allows the handling of job registry/removal of the downloader module.

use File::Basename;

package generic_downloader_job_manager;

$GHRSST_PERL_LIB_DIRECTORY = $ENV{GHRSST_PERL_LIB_DIRECTORY};
do "$GHRSST_PERL_LIB_DIRECTORY/mkdir_with_error_handling.pl";

my $g_routine_name = "generic_downloader_job_manager";
my $g_package_name = "generic_downloader_job_manager";

# Package private variables.

my %m_crawler_info_lookup_table;
my %m_output_directory_name_lookup_table;

#------------------------------------------------------------------------------------------------------------------------
sub setup_lookup_table {
   # The table consists of key = processing type
   #                     value = output sub directory name corresponding to processing type
   # Add any new dataset here.

   $m_output_directory_name_lookup_table{'MODIS_A'} = 'MODIS_AQUA_L2_SST_OBPG';
   $m_output_directory_name_lookup_table{'MODIS_T'} = 'MODIS_TERRA_L2_SST_OBPG';
   $m_output_directory_name_lookup_table{'VIIRS'}   = 'VIIRS_L2_SST_OBPG';

   return(1);
}

#------------------------------------------------------------------------------------------------------------------------
sub print_lookup_table {
     print "print_lookup_table() called\n";
     print "$_ $m_output_directory_name_lookup_table{$_}\n" for (keys %m_output_directory_name_lookup_table);
}

#------------------------------------------------------------------------------------------------------------------------
sub setup_crawler_info_lookup_table {
   # The table consists of key = processing type
   #                     value = First character of granule name.
   # Add any new dataset here.
   $m_crawler_info_lookup_table{'MODIS_A'}  = "A";
   $m_crawler_info_lookup_table{'MODIS_T'}  = "T";
   $m_crawler_info_lookup_table{'VIIRS'}    = "V";

   return(1);
}

#------------------------------------------------------------------------------------------------------------------------
sub get_crawl_info  {
    # Get the granule search directory and granule data name prefix given the processing type.
    my $self              = shift;
    my $i_processing_type = shift;

    my $o_granule_search_directory = "";
    my $o_granule_data_name_prefix = "";

    $o_granule_data_name_prefix = $m_crawler_info_lookup_table{$i_processing_type};

    if ($o_granule_data_name_prefix eq "") { die("ERROR: Cannot get crawler info for processing type [$i_processing_type]")};

    return($o_granule_data_name_prefix);
}

#------------------------------------------------------------------------------------------------------------------------
sub get_output_sub_directory_name {
     my $self = shift;
     my $i_processing_type = shift;
     return($m_output_directory_name_lookup_table{$i_processing_type});
}

#------------------------------------------------------------------------------------------------------------------------
sub new
{
    my $class = shift;
    my $self = {
    };

    bless $self, $class;

    # After blessing, we can now call some set up functions.
    $self->setup_lookup_table();
    $self->setup_crawler_info_lookup_table();

    return $self;
}

#------------------------------------------------------------------------------------------------------------------------
sub register_this_job {
    # Function register a given job by creating an empty file in the .registry directory.  This allow us later to check to see that the file
    # is deleted when it is finished.

    my $self                         = shift;
    my $i_one_line                   = shift;
    my $i_top_level_output_directory = shift;
    my $i_processing_type            = shift;


    my $debug_module = "register_this_job:";
    my $debug_mode   = 1;

    my $o_register_status = 1;
    my $o_temporary_location_of_downloaded_file = "";

    chomp($i_one_line);
    my @splitted_tokens = split(' ',$i_one_line);
    # Do a sanity check to make sure we have at least 1 token.
    if (scalar(@splitted_tokens) < 1) {
        log_this("WARN",$debug_module,"Expecting at least 1 token from splitting with space i_one_line [$i_one_line]");
    }

    my $checksum_value = $splitted_tokens[1]; # Retrieve the checksum so we can write it to the registry.

    my @splitted_tokens = split(/\//,$splitted_tokens[0]);
    # Do a sanity check to make sure we have at least 1 token.
    if (scalar(@splitted_tokens) < 1) {
        log_this("WARN",$debug_module,"Expecting at least 1 token from splitting with / splitted_token[0] [" . $splitted_tokens[0]. "]");
    }

    my $filename_only = File::Basename::basename($splitted_tokens[scalar(@splitted_tokens)-1]);  # Get the actual file name without the http and directory: http://oceandata.sci.gsfc.nasa.gov/cgi/getfile/A2015001201000.L2_LAC_SST.nc 
    my $first_character = substr($filename_only,0,1);

    # Determine the output directory based on the initial character of the filename.

    my $first_character = substr($filename_only,0,1);

    my $destination_output_directory = "";

    my $output_sub_directory_name = $self->get_output_sub_directory_name($i_processing_type);
    if ($output_sub_directory_name ne "") {
        $destination_output_directory = $i_top_level_output_directory . "/" . $self->get_output_sub_directory_name($i_processing_type);
    } else{
        die("The sub directory for processing_type $i_processing_type is not supported yet.");
    }

    my $hidden_download_directory = $destination_output_directory . "/.registry";

    # Create directory if it does not exist yet
    if (!(-e $hidden_download_directory)) {
        my $status_mkdir = mkdir_with_error_handling($hidden_download_directory);
    }

    $o_temporary_location_of_downloaded_file = $hidden_download_directory    . "/" . $filename_only;

    # Create an empty file to register this job.
    my $temp_fh;
    if (not open($temp_fh,'>', $o_temporary_location_of_downloaded_file)) {
        print $debug_module . "WARN:Unable to create empty file $o_temporary_location_of_downloaded_file : $! \n";
        $o_register_status = 0;
    }
    print $temp_fh $checksum_value . "\n"; # Write the checksum as the only content of the registry.
    if (not close($temp_fh)) {
        print $debug_module . "WARN:Unable to close file : $o_temporary_location_of_downloaded_file $! \n";
    }

    log_this("INFO",$g_package_name,"REGISTRY_ADDED   $o_temporary_location_of_downloaded_file");
    return($o_register_status,$o_temporary_location_of_downloaded_file);
}

#------------------------------------------------------------------------------------------------------------------------
sub remove_this_job {
    # Function remove a given job by deleting the registy from the .registry directory.

    my $self                         = shift;
    my $i_one_line                   = shift;
    my $i_top_level_output_directory = shift;
    my $i_processing_type            = shift;

    my $debug_module = "remove_this_job:";
    my $debug_mode   = 1;

    my $o_register_status = 1;
    my $o_location_of_registry_file = "";

    chomp($i_one_line);
    my @splitted_tokens = split(' ',$i_one_line);
    # Do a sanity check to make sure we have at least 1 token.
    if (scalar(@splitted_tokens) < 1) {
        log_this("WARN",$debug_module,"Expecting at least 1 token from splitting with space i_one_line [$i_one_line]");
    }

    my $checksum_value = $splitted_tokens[1]; # Retrieve the checksum so we can write it to the registry.

    my @splitted_tokens = split(/\//,$splitted_tokens[0]);
    # Do a sanity check to make sure we have at least 1 token.
    if (scalar(@splitted_tokens) < 1) {
        log_this("WARN",$debug_module,"Expecting at least 1 token from splitting with / splitted_token[0] [" . $splitted_tokens[0]. "]");
    }

    my $filename_only =  File::Basename::basename($splitted_tokens[scalar(@splitted_tokens)-1]);  # Get the actual file name without the http and directory: http://oceandata.sci.gsfc.nasa.gov/cgi/getfile/A2015001201000.L2_LAC_SST.nc 
    my $first_character = substr($filename_only,0,1);

    # Determine the output directory based on the initial character of the filename.

    my $first_character = substr($filename_only,0,1);

    my $destination_output_directory = "";
    my $output_sub_directory_name = $self->get_output_sub_directory_name($i_processing_type);
    if ($output_sub_directory_name ne "") {
        $destination_output_directory = $i_top_level_output_directory . "/" . $output_sub_directory_name;
    } else{
        die("The sub directory for processing_type $i_processing_type is not supported yet.");
    }

    my $hidden_download_directory = $destination_output_directory . "/.registry";

    # Create directory if it does not exist yet
    if (!(-e $hidden_download_directory)) {
        my $status_mkdir = mkdir_with_error_handling($hidden_download_directory);
    }

    $o_location_of_registry_file = $hidden_download_directory    . "/" . $filename_only;
    if (-e $o_location_of_registry_file) {
        unlink($o_location_of_registry_file);
        log_this("INFO",$g_package_name,"REGISTRY_REMOVED $o_location_of_registry_file");
    }

    return($o_register_status,$o_location_of_registry_file);
}

#------------------------------------------------------------------------------------------------------------------------
sub is_this_job_complete {
    # Function check to see if a particular download job associated with a file is completed.  The completion of the job
    # is signified by the non-existence of a file or files in the .hidden directory that matches our given file name.
    # If the file exist, we also check to see how old it is.  If it older than a certain a number of seconds, we assume the download has went stale.

    my $self                         = shift;
    my $i_one_line                   = shift;
    my $i_top_level_output_directory = shift;
    my $i_processing_type            = shift; 

    my $debug_module = "is_this_job_complete:";
    my $debug_mode   = 0;

    # The three possible states for a job are:
    #
    #   FILE_STATE_COMPLETED              The file in .hidden/.registry directory has been removed.  The download is considered done.
    #   FILE_STATE_STALE                  The file in .hidden/.registry directory is there and its age is outside the threshold window.
    #   FILE_STATE_CURRENTLY_DOWNLOADING  The file in .hidden/.registry directory is there and its age is within  the threshold window.

    my $o_job_is_completed_flag;
    my $o_incomplete_job_name = "";

    my @splitted_tokens = split(' ',$i_one_line);
    # Do a sanity check to make sure we have at least 1 token.
    if (scalar(@splitted_tokens) < 1) {
        log_this("WARN",$debug_module,"Expecting at least 1 token from splitting with space i_one_line [$i_one_line]");
    }

    my @splitted_tokens = split(/\//,$splitted_tokens[0]);
    # Do a sanity check to make sure we have at least 1 token.
    if (scalar(@splitted_tokens) < 1) {
        log_this("WARN",$debug_module,"Expecting at least 1 token from splitting with / splitted_token[0] [" . $splitted_tokens[0]. "]");
    }

    my $filename_only = File::Basename::basename($splitted_tokens[scalar(@splitted_tokens)-1]);  # Get the actual file name without the http and directory: http://oceandata.sci.gsfc.nasa.gov/cgi/getfile/A2015001201000.L2_LAC_SST.nc 
    my $first_character = substr($filename_only,0,1);

    # Determine the output directory based on the initial character of the filename.

    my $first_character = substr($filename_only,0,1);

    my $destination_output_directory = "";
    my $output_sub_directory_name = $self->get_output_sub_directory_name($i_processing_type);
    if ($output_sub_directory_name ne "") {
        $destination_output_directory = $i_top_level_output_directory . "/" . $output_sub_directory_name;
    } else{
        die("The sub directory for processing_type $i_processing_type is not supported yet.");
    }

    my $temporary_location_of_downloaded_file = "";

    my $o_hidden_download_directory = $destination_output_directory . "/.hidden";

    $temporary_location_of_downloaded_file = $o_hidden_download_directory    . "/" . $filename_only;
    my $o_lock_filename_filter = $temporary_location_of_downloaded_file . ".lck.NFSLock";

    # Define the registry location so we can also look for it.
    my $registry_download_directory = $destination_output_directory . "/.registry";
    my $job_registry_filename       = $registry_download_directory . "/" . $filename_only;

    # Look for any file in the directory that matches our given file name.
    if (-e $temporary_location_of_downloaded_file) {
        $o_incomplete_job_name = $temporary_location_of_downloaded_file;
    }
    if (-e $o_lock_filename_filter) {
        $o_incomplete_job_name = $o_lock_filename_filter;
    }
    if (-e $job_registry_filename) {
        $o_incomplete_job_name = $job_registry_filename;
    }

    if ($debug_mode) {
       print $debug_module . "temporary_location_of_downloaded_file [$temporary_location_of_downloaded_file]\n";
       print $debug_module . "o_lock_filename_filter                [$o_lock_filename_filter]\n";
       print $debug_module . "o_incomplete_job_name                 [" . $o_incomplete_job_name      . "]\n";
    }

    # If at least one file exist, we check to see how old it is.
    if (($o_incomplete_job_name ne "") and (-e $o_incomplete_job_name)) {
        # We use the last access time instead of modify time because the modify time gives false time.
        #
        # An example:
        #
        # /data/dev/scratch/qchau/IO/data/MODIS_AQUA_L2_SST_OBPG/.hidden/A2015039000500.L2_LAC_OC.nc file_age_in_seconds 30592969 MODIS_LEVEL2_CONST_MAX_AGE_BEFORE_CONSIDERED_STALE 1
        #
        # current_timestamp 1465322761  Tue, 07 Jun 2016 18:06:01 GMT 
        # epoch_timestamp   1434729792  Fri, 19 Jun 2015 16:03:12 GMTk
        #
        # Clearly, the last modified time of a file we know is current is not from 2015, a year a go.

        my $epoch_timestamp   = (stat($o_incomplete_job_name))[8];
        my $current_timestamp = time();
        my $file_age_in_seconds = $current_timestamp - $epoch_timestamp;
        # If the file is older than a threshold, we consider it to be incomplete because the download should have been done.
        if ($file_age_in_seconds > $MODIS_LEVEL2_CONST_MAX_AGE_BEFORE_CONSIDERED_STALE) {
            $o_job_is_completed_flag = "FILE_STATE_STALE";
        } else {
            $o_job_is_completed_flag = "FILE_STATE_CURRENTLY_DOWNLOADING";
        }
        if ($debug_mode) {
            print $debug_module . "o_incomplete_job_name $o_incomplete_job_name file_age_in_seconds $file_age_in_seconds MODIS_LEVEL2_CONST_MAX_AGE_BEFORE_CONSIDERED_STALE $MODIS_LEVEL2_CONST_MAX_AGE_BEFORE_CONSIDERED_STALE\n"; 
        }
    } else {
        $o_job_is_completed_flag = "FILE_STATE_COMPLETED";
    }

    if ($debug_mode) {
        print $debug_module . "i_one_line [" . sprintf("%-120s",$i_one_line) . "] o_job_is_completed_flag $o_job_is_completed_flag o_incomplete_job_name [$o_incomplete_job_name] o_hidden_download_directory $o_hidden_download_directory\n"; 
    }

    return ($o_job_is_completed_flag,$o_incomplete_job_name,$o_hidden_download_directory,$o_lock_filename_filter);
}

#------------------------------------------------------------------------------------------------------------------------
sub monitor_job_completion {
    # Given all the jobs dispatched, this function will monitor all jobs until their completion or until the threshold has reached.
    # The dispatched jobs are assumed to have been written by the sub process to the child_ledger.  The master_ledger is the other end
    # of the pipe and can now be read for each jobs dispatched.

    my $self                         = shift;
    my $i_num_jobs                   = shift;
    my $i_top_level_output_directory = shift;
    my $i_processing_type            = shift;
    my $i_all_of_lines_to_download_ref = shift;

    my $debug_module = "monitor_job_completion:";
    my $debug_mode   = 0;

    # Set the default wait in between each check and how long to wait total before considering a job had failed.

    my $MAX_WAIT_DURATION_BETWEEN_CHECKS = 4;
    if ($MODIS_LEVEL2_CONST_MAX_WAIT_DURATION_BETWEEN_CHECKS ne "") {
        $MAX_WAIT_DURATION_BETWEEN_CHECKS = $MODIS_LEVEL2_CONST_MAX_WAIT_DURATION_BETWEEN_CHECKS;
    }

    my $MAX_RUNNING_THRESHOLD_IN_SECONDS  = int($i_num_jobs) * 300;  # Max 5 minutes of running time is allowed per download of a file.
    if ($MODIS_LEVEL2_CONST_MAX_AGE_BEFORE_CONSIDERED_STALE ne "") {
        $MAX_RUNNING_THRESHOLD_IN_SECONDS = int($i_num_jobs) * $MODIS_LEVEL2_CONST_MAX_AGE_BEFORE_CONSIDERED_STALE;
    }

    my @all_of_lines_to_download  = @$i_all_of_lines_to_download_ref;

    # Create an array of all 0's to keep track of the job completion.  Each job will be set to 1 if it has completed.

    my @job_completion_flag_array = (0) x $i_num_jobs;

    my $o_total_seconds_waited   = 0;  # How long have we waited checking for completion of the jobs.
    my $o_all_jobs_are_completed = 0;  # Flag to indicate if all the jobs are done.
    my $o_num_incompleted_jobs   = 0;  # Number of jobs not completed.
    my $o_hidden_download_directory = "";
    my $o_lock_filename_filter      = "";

    log_this("INFO",$debug_module,"MONITOR_JOB_COMPLETION START NUM_JOBS $i_num_jobs TOP_LEVEL_OUTPUT_DIRECTORY $i_top_level_output_directory PROCESSING_TYPE $i_processing_type");
    log_this("INFO",$debug_module,"MONITOR_JOB_COMPLETION NUM_BATCH_OF_LINES_TO_DOWNLOAD " . scalar(@all_of_lines_to_download));

    # Loop until o_all_jobs_are_completed is 1 or have waited beyond the maximum time to wait.
    my $iteration_number = 0;

    while ((not $o_all_jobs_are_completed) and ($o_total_seconds_waited <= $MAX_RUNNING_THRESHOLD_IN_SECONDS)) {
        $iteration_number += 1;

        # For each job, we check to see if it is still running.
        # If it does, we set the flag to 1.  The flag o_all_jobs_are_completed is set to True when all the values are 1.

        $o_num_incompleted_jobs   = 0;  # Number of jobs not completed.
        my $job_is_completed_flag;
        my $incomplete_job_name   = "";
        my $num_jobs_checked      = 0;
        my $num_jobs_completed    = 0;

        for my $job_completion_index (0..($i_num_jobs-1)) {
           my $one_line = $all_of_lines_to_download[$job_completion_index];
           chomp($one_line);

           if ($debug_mode) {
               print "--------------------------------------------------------------------------------\n";
               print "iteration [$iteration_number]\n";
               print "i_num_jobs [$i_num_jobs]\n";
               print "job_completion_index [$job_completion_index]\n";
               print "scalar(all_of_lines_to_download) " . scalar(@all_of_lines_to_download) . "\n";
               print "one_line [$one_line]\n";
               print "i_top_level_output_directory [$i_top_level_output_directory]\n";
               print "i_processing_type [$i_processing_type]\n";
           }

           # For each incomplete job, check to see if it is completed.
           if ($job_completion_flag_array[$job_completion_index] == 0) {
               $num_jobs_checked = $num_jobs_checked + 1;
               ($job_is_completed_flag,$incomplete_job_name,$o_hidden_download_directory,$o_lock_filename_filter) = $self->is_this_job_complete($one_line,
                                                                                                                                                $i_top_level_output_directory,
                                                                                                                                                $i_processing_type);
               if ($debug_mode) {
                    print $debug_module . "$iteration_number $job_completion_index o_lock_filename_filter [$o_lock_filename_filter] job_is_completed_flag [$job_is_completed_flag]\n"
               }
               if ($job_is_completed_flag eq "FILE_STATE_COMPLETED") {
                   $job_completion_flag_array[$job_completion_index] = 1;  # The job has completed, we are done with this job check.
                   $num_jobs_completed = $num_jobs_completed +1;
               } else {
                   $o_num_incompleted_jobs = $o_num_incompleted_jobs + 1;  # Keep track of the number of jobs not completed.  Its status may be the latter two of {FILE_STATE_COMPLETED,FILE_STATE_STALE,FILE_STATE_CURRENTLY_DOWNLOADING}
               }
               if ($debug_mode) {
                   print $debug_module . "ITERATION_NUMBER $iteration_number JOB_COMPLETION_INDEX $job_completion_index job_is_completed_flag $job_is_completed_flag [$one_line]\n";
               }
           } else { # end if ($job_completion_flag_array[$job_completion_index] == 0)
               # This job is completed, we don't need to check for it again.
               if ($debug_mode) {
                    print $debug_module . "ITERATION_NUMBER $iteration_number JOB_COMPLETION_INDEX $job_completion_index job_is_completed_flag FILE_STATE_COMPLETED [$one_line]\n";
               }
               $num_jobs_completed = $num_jobs_completed +1;
           }
        } # end for my $job_completion_index (0..($i_num_jobs-1))

        if ($debug_mode) {
            print $debug_module . "ITERATION_NUMBER $iteration_number NUM_JOBS_CHECKED $num_jobs_checked OUT_OF $i_num_jobs NUM_JOBS_COMPLETED $num_jobs_completed NUM_JOBS_INCOMPLETE $o_num_incompleted_jobs\n";
        }

        # Here we temporary assume that all the jobs are completed.
        # If any of the flag is zero, we flip it back to false.  Basically, we only consider all jobs are done if each individual element
        # in array job_completion_flag_array is set to 1.

        my $optimistic_flag_jobs_done = 1;

        my $jobs_not_completed = "";

        # Collect the names of all the jobs not completed yet so the operator knows.
        my $found_first_incomplete_job_flag = 0;
        for my $job_completion_index (0..$i_num_jobs-1) {
            if ($job_completion_flag_array[$job_completion_index] == 0) {
                $optimistic_flag_jobs_done = 0;
                # Collect the names of all the jobs not completed so the operator knows.
                if ($found_first_incomplete_job_flag == 0) {
                    $jobs_not_completed = sprintf("%d",$job_completion_index+1);  # If this is the first name, don't add the leading space.
                    $found_first_incomplete_job_flag = 1;  # Now that we have found the first incomplete job, we set this flag to 1.
                } else {
                    $jobs_not_completed = $jobs_not_completed . " " . sprintf("%d",$job_completion_index+1);
                }
            } # end if (job_completion_flag_array[job_completion_index] == 0)
        } # end for my $job_completion_index (0..($i_num_jobs-1)

        # Print this for every loop so the operator will know how many jobs are not complete for every iteration.
        my $now_is_as_str  = localtime;
        if ($debug_mode) {
            print $debug_module . "[" . $now_is_as_str . "]:" . "iteration_number ". $iteration_number ." o_total_seconds_waited " . $o_total_seconds_waited . " MAX_WAIT_DURATION_BETWEEN_CHECKS " . $MAX_WAIT_DURATION_BETWEEN_CHECKS . " MAX_RUNNING_THRESHOLD_IN_SECONDS " . $MAX_RUNNING_THRESHOLD_IN_SECONDS . " jobs_not_completed = [" . $jobs_not_completed . "]\n";
        }

        # Now, we do a final check to see if all the flags are true via the one flag optimistic_flag_jobs_done
        # Otherwise, we wait MAX_WAIT_DURATION_BETWEEN_CHECKS seconds and check again.

        if ($optimistic_flag_jobs_done == 1) {
            # All the jobs are done, we can now exit this forever loop.
            $o_all_jobs_are_completed = 1;
        } else {
            if ($debug_mode) {
                print $debug_module . 'SLEEPING_FOR MAX_WAIT_DURATION_BETWEEN_CHECKS ' . $MAX_WAIT_DURATION_BETWEEN_CHECKS . "\n";
            }
            # The job is not done yet, we wait again.
            sleep $MAX_WAIT_DURATION_BETWEEN_CHECKS;

            # Keep track of how long we have waited so the loop can stop when this value greater than MAX_RUNNING_THRESHOLD_IN_SECONDS.
            $o_total_seconds_waited = $o_total_seconds_waited + $MAX_WAIT_DURATION_BETWEEN_CHECKS;
        } # end else if ($optimistic_flag_jobs_done == 1)
    } # end while ((not $o_all_jobs_are_completed) and ($o_total_seconds_waited <= $MAX_RUNNING_THRESHOLD_IN_SECONDS))

    if ($o_all_jobs_are_completed) {
        log_this("INFO",$debug_module,"MONITOR_JOB_COMPLETION STOP  NUM_JOBS $i_num_jobs TOP_LEVEL_OUTPUT_DIRECTORY $i_top_level_output_directory PROCESSING_TYPE $i_processing_type JOBS_COMPLETED_FLAG $o_all_jobs_are_completed TOTAL_SECONDS_WAITED $o_total_seconds_waited MAX_RUNNING_THRESHOLD_IN_SECONDS $MAX_RUNNING_THRESHOLD_IN_SECONDS");
    } else {
        log_this("ERROR",$debug_module,"MONITOR_JOB_COMPLETION STOP  NUM_JOBS $i_num_jobs TOP_LEVEL_OUTPUT_DIRECTORY $i_top_level_output_directory PROCESSING_TYPE $i_processing_type JOBS_COMPLETED_FLAG $o_all_jobs_are_completed TOTAL_SECONDS_WAITED $o_total_seconds_waited MAX_RUNNING_THRESHOLD_IN_SECONDS $MAX_RUNNING_THRESHOLD_IN_SECONDS");
    }
    return($o_all_jobs_are_completed,
           $o_num_incompleted_jobs,
           $o_hidden_download_directory,
           $o_total_seconds_waited);
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
1;
