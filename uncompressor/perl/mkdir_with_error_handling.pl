#!/usr/local/bin/perl
#  Copyright 2013, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Location of GHRSST Perl library functions.

$GHRSST_PERL_LIB_DIRECTORY = $ENV{GHRSST_PERL_LIB_DIRECTORY};

do "$GHRSST_PERL_LIB_DIRECTORY/raise_sigevent.pl";

# Some variables related to sigevent.

my $sigevent_provider      = "JPL";
my $sigevent_type = "information";
my $sigevent_category = "UNCATEGORY";
my $sigevent_msg = "hello there";
my $sigevent_email_to = "DUMMY_EMAIL";
my $sigevent_url = $ENV{GHRSST_SIGEVENT_URL};
my $sigevent_source = "GHRSST-PROCESSING";

#------------------------------------------------------------------------------------------------------------------------
sub mkdir_with_error_handling {
    # Function perform a mkdir() function on the given directory name and returns 1 if successful and 0 if failed.
    # A sigevent will be raised if the directory cannot be created. 

    my $i_directory_to_create = shift;

    my $o_mkdir_status = 1;

    # Do a sanity check to see if the destination exist already exist and is directory.

    if ((-e $i_directory_to_create) and (-d $i_directory_to_create)) {
        # Do nothing, this is good.
        log_this("INFO",$g_routine_name,"MKDIR_SUCCESS_DIRECTORY_ALREADY_EXISTS " . $i_directory_to_create);
        return($o_mkdir_status);
    }

    # Do a sanity check to see if the destination exist already exist and is a file.
    # If it is already a file, we can't create a directory over it.

    if ((-e $i_directory_to_create) and (-f $i_directory_to_create)) { 
        # Do nothing, this is bad.  We don't want to create a directory over an existing file.
        log_this("ERROR",$g_routine_name,"MKDIR_FAILED_NAMED_DIRECTORY_ALREADY_EXISTS_AND_IS_A_FILE " . $i_directory_to_create);
        $o_mkdir_status = 0;
        return($o_mkdir_status); 
    }

    # The directory does not yet exist, create it.

    my $status_mkdir = mkdir($i_directory_to_create);

#    log_this("INFO",$g_routine_name,"STATUS_MKDIR [" . $status_mkdir . "]");

    # The mkdir function returns true if successful and false if failed.
    if ($status_mkdir) {
        # Do nothing, this is good.
        log_this("INFO",$g_routine_name,"MKDIR_SUCCESS " . $i_directory_to_create);
    } else {
        $o_mkdir_status = 0;
        # Notify operator and return.
        $sigevent_msg = "MKDIR_FAILED " . $i_directory_to_create;
        log_this("ERROR",$g_routine_name,$sigevent_msg);
        $sigevent_type = "ERROR";
        $sigevent_category = "UNCATEGORIZED";
        $sigevent_url = $ENV{GHRSST_SIGEVENT_URL};
        raise_sigevent($sigevent_url,$sigevent_provider,$sigevent_source,$sigevent_type,$sigevent_category,$g_routine_name . ":" . $sigevent_msg,$sigevent_data);
    }
    return($o_mkdir_status);
}

sub log_this {
    # Function to log a message to screen.
    my $i_log_type      = shift;  # Possible types are {INFO,WARN,ERROR}
    my $i_function_name = shift;  # Where the logging is coming from.  Useful in debuging if something goes wrong.
    my $i_log_message   = shift;  # The text you wish to log screen.

    my $now_is = localtime;

    print $now_is . " " . $i_log_type . " [" . $i_function_name . "] " . $i_log_message . "\n";
}
