#!/usr/local/bin/perl

#  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Subroutine stage the MODIS datasets for processing by attempting to perform the copying 5 times
# to the staging area.
#
# Assumption:
#
#   1) The file to be staged exist.
#   2) TBD. 
#
#------------------------------------------------------------------------------------------------

use File::Basename;  # Use in parsing the full file name.

do "$GHRSST_PERL_LIB_DIRECTORY/uncompress_one_modis_dataset.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/report_error_to_error_file_registry.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/email_ops_to_report_error.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/create_modis_processing_error_string.pl";

sub iterate_stage_commands {


    # Returned status.  Value of 0 means ok, 1 means bad.

    my $o_status = 0;

    #
    # Get input.
    #

    my $i_scratch_area                 = shift;
    my $i_processing_type              = shift;
    my $i_uncompress_flag              = shift;
    my $i_uncompressed_data_filename   = shift;
    my $i_l2p_core_name_only_filename  = shift;

    # For every file in the list, perform the copying to the stage area.

    my $name_only = "";
    my $directory_path = "";
    my $destination_name = "";

    my $MAX_LOOP             = 5;
    my $copied_success       = 0;
    my $uncompressed_success = 0;
    my $attempt_index        = 1;
    my $attempts_exhausted   = 0;

    # Start out assuming we are successful with this subroutine.
    my $o_status = 0;

    chomp($i_uncompressed_data_filename);  # Remove the carriage return.

    # Parse the name.
    ($name_only,$directory_path) = fileparse($i_uncompressed_data_filename);

    # Form the destination name.
    $destination_name = $i_scratch_area . "/" . $name_only;
 
#print "iterate_stage_commands:INFO, i_l2p_core_name_only_filename = [$i_l2p_core_name_only_filename]\n";

    # Repeat 5 times or until able to copy and uncompressed.
    do {

print "--------------------------------------------------------------------------------\n";
print "iterate_stage_commands:INFO, attempt_index = $attempt_index\n";
        #
        # Only copy the file if it does not exist already at the destination.
        #

#print "  cp $i_uncompressed_data_filename $i_scratch_area/\n";
#print "  destination_name = $destination_name\n";
        if (-e $destination_name) {
            print "  INFO, File $destination_name exist.  Will not be copied.\n";
            $copied_success = 1; # Eventhough this code did not copy the file, it is found so we considered it copied. 
            # Uncompress the file also if flag is set.
            if (lc($i_uncompress_flag) eq 'yes') {
                print "  INFO, Performing uncompressing on $destination_name\n";
                my $l_status = uncompress_one_modis_dataset($destination_name);
                # If the file was copied and uncompressed, we keep track of how many.
                if ($l_status == 0) {
                    $uncompressed_success = 1;
                    $attempts_exhausted = 1;
                }
            } else {
                print "iterate_stage_commands:INFO, i_uncompress_flag = [$i_uncompress_flag]\n";
                $attempts_exhausted = 1;
            }
        } else {
            if ($ENV{PERFORM_MOVE_INSTEAD_OF_COPY_WHEN_STAGING_HDF_FILE} eq "yes") {
                # Note, since the mv command preserve the last modified time, we perform an additional touch command to update the time to now.
                system("mv  $i_uncompressed_data_filename $i_scratch_area/");
print "  INFO, Moving $i_uncompressed_data_filename to $destination_name\n";
                if (-e $destination_name) {
                    system("touch $destination_name");
                }
            } else {
                system("cp $i_uncompressed_data_filename $i_scratch_area/");
print "  INFO, Copying $i_uncompressed_data_filename to $destination_name\n";
            }

            #
            # Check for errors from the cp command.
            #
            my $l_proceed_to_uncompress_flag = 0;

            if ($? == -1) {
                print "iterate_stage_commands:ERROR, system cp $i_uncompressed_data_filename $i_scratch_area/ failed to execute: $?\n";
                $o_status = 1;
            } elsif ($? == 256){
                print "iterate_stage_commands:ERROR, Cannot find file  $i_uncompressed_data_filename\n";
                print "iterate_stage_commands:attempt_index $attempt_index failed\n";
                $o_status = 1;
            } elsif ($? == 0){
                $l_proceed_to_uncompress_flag = 1;  # We set this so the file will get uncompress later. 
                $copied_success               = 1;
            } else {
                print "iterate_stage_commands:ERROR, system cp $i_uncompressed_data_filename $i_scratch_area/ executed with: $?\n";
                $o_status = 1;
            }

            if ($l_proceed_to_uncompress_flag == 1) {
                # Uncompress the file also if flag is set.
                if (lc($i_uncompress_flag) eq 'yes') {
print "  INFO, Performing uncompressing on $destination_name\n";

                   my $l_status = uncompress_one_modis_dataset($destination_name);
                   # If the file was copied and uncompressed, we keep track of how many.
                   if ($l_status == 0) {
                      $uncompressed_success = 1;
                      $attempts_exhausted = 1;
                   }
                } else {
                    print "iterate_stage_commands:INFO, i_uncompress_flag = [$i_uncompress_flag]\n";
                    $attempts_exhausted = 1;
                }
            } # end if ($l_proceed_to_uncompress_flag == 1)
        }

        $attempt_index += 1; 

    } until (($attempt_index > $MAX_LOOP) || ($attempts_exhausted == 1));

    # Depends on what happened above, we send an email to the operator.

    if ($copied_success == 0) {
        #
        # Report the error to the Error File Registry (EFR).
        #

        my $l_status = report_error_to_error_file_registry($i_processing_type,
                                    $i_l2p_core_name_only_filename,
                                    "File not found cp command failed");
        #
        # Create an error string and send an email to the operator.
        #

        my @ref_error_message = create_modis_processing_error_string(
                                              $i_uncompressed_data_filename,
                                              $i_l2p_core_name_only_filename,
                                              $i_processing_type);

        email_ops_to_report_error(@ref_error_message);
    } else {
        # Was able to copy the file, check to see if it was able to be compressed.
        # Only send the email if i_uncompress_flag was "yes".
        if ($i_uncompress_flag eq "yes" && $uncompressed_success == 0) {
            #
            # Report the error to the Error File Registry (EFR).
            #

            my $l_status = report_error_to_error_file_registry($i_processing_type,
                                        $i_l2p_core_name_only_filename,
                                        "File is corrupted cannot uncompress");
            #
            # Create an error string and send an email to the operator.
            #

            my @ref_error_message = create_modis_processing_error_string(
                                                  $i_uncompressed_data_filename,
                                                  $i_l2p_core_name_only_filename,
                                                  $i_processing_type);

            email_ops_to_report_error(@ref_error_message);
        }
    }

    #
    # Report status of staging.
    #

    # ---------- Close up shop ----------
    return ($o_status);

} # end sub iterate_stage_commands
