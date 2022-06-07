#!/usr/local/bin/perl
#  Copyright 2013, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Program to monitor the status of a handler to make sure it is not dead.
# It monitors the last modified time of the job file every time this program is ran.
# If the threshold is met, a sigevent will be raised so the operator can be notified to restart the handler.
#
# Example:
#
#      source ~/define_modis_operation_environment_for_combiner
#      perl $GHRSST_PERL_LIB_DIRECTORY/modis_level2_download_tasks_tracker.pl -input_directory=$HOME/scratch/modis_level2_download_processes -threshold_in_minutes=5
#
# Where the parameters are:
#
#      input_directory
#      task_age (in minutes)
#
# The output should be something like this:
#
#   Wed Oct 24 13:28:31 2012 INFO [modis_level2_download_tasks_tracker] BEGIN_PROCESSING_TIME Wed Oct 24 13:28:31 2012
#   Wed Oct 24 13:28:31 2012 INFO [modis_level2_download_tasks_tracker] Last modified time of job file [/home/qchau/logs/startup_modisd.MODIS_Daemon_Dev_1.log] age 0 is within 5 minutes threshold.
#   
#   Wed Oct 24 13:28:31 2012 INFO [modis_level2_download_tasks_tracker] BEGIN_PROCESSING_TIME Wed Oct 24 13:28:31 2012
#   Wed Oct 24 13:28:31 2012 INFO [modis_level2_download_tasks_tracker] END_PROCESSING_TIME   Wed Oct 24 13:28:31 2012
#
#
#------------------------------------------------------------------------------------------------

# Location of GHRSST Perl library functions.

$GHRSST_PERL_LIB_DIRECTORY = $ENV{GHRSST_PERL_LIB_DIRECTORY};

do "$GHRSST_PERL_LIB_DIRECTORY/ghrsst_notify_operator.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/actualize_directory.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/big_directory_crawl.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/remove_temporary_log_dir.pl";

use Getopt::Long;
use File::Basename;

# Clobal variable(s)

$g_routine_name = "modis_level2_download_tasks_tracker";

# Some time related business.

my $begin_processing_time = localtime;

log_this("INFO",$g_routine_name,"BEGIN_PROCESSING_TIME $begin_processing_time");

# Some variables related to sigevent.

my $sigevent_type = "information";
my $sigevent_msg = "hello there";
my $sigevent_email_to = "DUMMY_EMAIL";
my $sigevent_url = $ENV{GHRSST_SIGEVENT_URL};
if ($sigevent_url eq '') {
    print "You must defined the sigevent URL: i.e. setenv GHRSST_SIGEVENT_URL http://test.test.test:8100\n"; 
    die ("Cannot continue until environment GHRSST_SIGEVENT_URL is defined"); 
}

my $sigevent_clause = "SIGEVENT=" . $sigevent_url . "&category=GENERATE&provider=jpl";
my $temp_dir = "/download_task_tracker/tmp/";
my $msg2report = 7;
my $sigevent_data = '';

# Get the inputs.

my $i_input_directory = "";
my $i_threshold_in_minutes  = 0;

GetOptions("input_directory=s"        => \$i_input_directory,
           "threshold_in_minutes=i"         => \$i_threshold_in_minutes);

# Do sanity check to make sure we have the correct number of parameters.

if ($i_input_directory eq "") {
    print "modis_level2_download_tasks_tracker:ERROR, All parameters must be provided\n";
    print "Variables:\n\n";
    print "input_directory [$i_input_directory]\n";
    print "threshold_in_minutes  [$i_threshold_in_minutes]\n";
    print "\n";
    print "Usage:\n";
    print "\n";
    print "    perl modis_level2_download_tasks_tracker.pl -input_directory=$HOME/scratch/modis_level2_download_processes -threshold_in_minutes=5\n";
    print "\n";
    exit(1);
}

# Do a sanity check to make sure the log file is there.

if (!(-e $i_input_directory)) {
    print "modis_level2_download_tasks_tracker:ERROR, Cannot find file [$i_input_directory]\n";
    exit(1);
}

# Do sanity check on the value of the age.

if ($i_threshold_in_minutes < 0) {
    print "ERROR: The parameter threshold_in_minutes should be a positive value.\n";
   exit(1);
}

# Time related variables used to keep track of how long things take.

my $program_time_start = time();
my $current_time = $program_time_start;

my $log_type      = ""; 
my $function_name = $g_routine_name;
my $log_message   = ""; 


# Crawl directory.
# For each name found, get last modified time of file and compare it with time now.
#   If time difference is greater than threshold, raise a sigevent.
#   If time difference is less than threshold, do nothing.


# Crawl for a list of files in input directory.

my $time_start_crawling = time();
log_this("INFO",$g_routine_name,"BEGIN_CRAWLING $i_input_directory");

my $i_filename_prefix = "obpg_download_process_";  # The crawler will look for files that start with "obpg_download_process_";

my ($status,$file_list_ref) = fetch_filenames($i_input_directory,$i_filename_prefix);

log_this("INFO",$g_routine_name,"CRAWL_STAGE  " . scalar(@$file_list_ref) . " CRAWL_DIRECTORY " . $i_input_directory);

my $time_end_crawling = time();
my $time_spent_in_crawling = $time_end_crawling - $time_start_crawling;

# For each file name found in the input directory, check for last modified time of the file.  If it is past the threshold, we throw a sigevent.
foreach $filename (@$file_list_ref) {
    chomp($filename); # Don't forget to remove the carriage return.
    my $last_modified_time_of_file = (stat($filename))[9];  # Get last modified time in seconds since 1970
    my $time_now = time();

    my $seconds_difference_between_file_and_now = 0;
    my $minutes_difference_between_file_and_now = 0;
    $seconds_difference_between_file_and_now = $time_now - $last_modified_time_of_file;
    $minutes_difference_between_file_and_now = sprintf("%.0f",$seconds_difference_between_file_and_now/60);

    if ($minutes_difference_between_file_and_now > $i_threshold_in_minutes) {
        my $file = basename($filename);
        $sigevent_type = "error";
        $sigevent_msg = "The script for the process: $file may be stalled and required attention as it is $minutes_difference_between_file_and_now minutes old.";
        $sigevent_data = "The script for this process $file has been running for more $minutes_difference_between_file_and_now minutes and may required some attention.";
        log_this("ERROR",$g_routine_name,$sigevent_msg . "\n");
        ghrsst_notify_operator($g_routine_name,$sigevent_type,$sigevent_msg,$sigevent_email_to,$sigevent_clause,$temp_dir,$msg2report,$sigevent_data);
    } else {
        $sigevent_msg = "Last modified time of this process [$filename] age $minutes_difference_between_file_and_now is within $i_threshold_in_minutes minutes threshold.";
        log_this("INFO",$g_routine_name,$sigevent_msg);
    }
}

my $program_time_end = time();
my $elapsed_in_seconds = $program_time_end - $program_time_start;
my $elapsed_in_minutes = sprintf("%.2f",($elapsed_in_seconds/60.0));

# ---------- Close up shop ----------

my $end_processing_time = localtime;

log_this("INFO",$g_routine_name,"BEGIN_PROCESSING_TIME $begin_processing_time");
log_this("INFO",$g_routine_name,"END_PROCESSING_TIME   $end_processing_time");

#------------------------------------------------------------------------------------------------------------------------
sub fetch_filenames {

    my $i_search_directory = shift;
    my $i_filename_prefix = shift;

    my $i_optional_days_back = "";

    # Create director(ies) if they don't exist already.
    # Local variables.

    my $scratch_area       = $ENV{SCRATCH_AREA};
    my $l_actualize_status = actualize_directory($scratch_area);

    my $l_current_time = $time_start;
    my $l_partial_directory_name = "monitor_crawl";

    # Get a list of names of the full directory.

    my $source_name = "DUMMY_SOURCE_NAME";

    my ($l_status, $tmp_filelist) = big_directory_crawl($i_search_directory,
                                                        $i_filename_prefix,
                                                        $scratch_area,
                                                        $source_name,
                                                        $l_current_time,
                                                        $i_optional_days_back);

    if ($l_status != 0) {
        print "fetch_filenames: Failure in big_directory_crawl () function.\n";
        print "fetch_filenames: Cannot continue.\n";
        $o_status = 1;
        return ($o_status);
    }

    #
    # Read the entire file into memory.  Exit if there's a problem.
    #

    open (FH, "< $tmp_filelist") or die "fetch_filenames:Can't open file for reading $tmp_filelist: $!";

    my @o_filelist= <FH>;
    close (FH);

    #
    # Clean up.
    #

    if (-e $tmp_filelist)                   { unlink($tmp_filelist); }

    # Remove temporary log directory created by script.

    remove_temporary_log_dir($l_current_time,$l_partial_directory_name);

    # ---------- Close up shop ----------
    return ($o_status,\@o_filelist);

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
