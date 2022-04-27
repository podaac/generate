#!/usr/local/bin/perl
#  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

$GHRSST_PERL_LIB_DIRECTORY = $ENV{GHRSST_PERL_LIB_DIRECTORY};

do "$GHRSST_PERL_LIB_DIRECTORY/log_this.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/mkdir_with_error_handling.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/move_combined_file_to_final_location.pl";

use File::Copy;

# Some variables related to sigevent.

my $sigevent_provider      = "JPL";
my $sigevent_type = "information";
my $sigevent_category = "UNCATEGORIZED";
my $sigevent_msg = "hello there";
my $sigevent_email_to = "DUMMY_EMAIL";
my $sigevent_url = $ENV{GHRSST_SIGEVENT_URL};
my $sigevent_source = "GHRSST-PROCESSING";

my $g_routine_name = "move_to_holding_tank_with_error_handling";

#------------------------------------------------------------------------------------------------------------------------
sub move_to_holding_tank_with_error_handling {
    # After a file has been processed, we move the file to a temporary holding tank so it can be made available in case
    # it is needed again if a new version of SST arrives due to a changed in checksum.  This is an issue with the data provider
    # where the checksum is updated about 20 minutes to an hour after it was posted on the page.
    #
    # Note:  Another script should be ran against the holding tank to expire these files since we cannot hold
    #        them indefinitely due to disk space.
    #
    # Assumption(s):
    #
    #   1.  The holding tank is a sub directory in scratch area with the name holding_tank.

    my $i_filename_to_move = shift;
    my $i_scratch_area     = shift;

    if (-e $i_filename_to_move) {
          # Get the parent directory name, and the file name only.
          my $parent_directory_name = dirname($i_filename_to_move);
          my $name_only             = basename($i_filename_to_move);

          if ($g_perform_holding_tank_mkdir_level_1_test_make_it_failed == 1) { $i_scratch_area = "/tmp_cannot_create_this_directory_1"; }

          # Create the directory if it does not exist.
          if (!(-e $i_scratch_area)) {
              my $status_mkdir = mkdir_with_error_handling($i_scratch_area);
              # The mkdir function returns true if successful and false if failed.
              if ($status_mkdir == 0) { return; }
          }

          # The holding tank directory name is in scratch area.

          my $holding_tank_directory_name = $i_scratch_area . "/holding_tank";

          if ($g_perform_holding_tank_mkdir_level_2_test_make_it_failed == 1) { $holding_tank_directory_name = "/tmp_cannot_create_this_directory_2"; }

          # Create the directory if it does not exist.
          if (!(-e $holding_tank_directory_name)) {
              my $status_mkdir = mkdir_with_error_handling($holding_tank_directory_name);
              # The mkdir function returns true if successful and false if failed.
              if ($status_mkdir == 0) { return; }
          }

          # Do the move.  The rename() function is destructive, i.e will overwrite an existing file.
          my $destination_name = $holding_tank_directory_name . "/" . $name_only;
          rename($i_filename_to_move,$destination_name);

          if ($g_perform_holding_tank_rename_test_make_it_failed == 1) { $destination_name = "/some_file_should_not_exist"; }

          # Do a sanity check on the existence of the destination file.

          if (-e $destination_name) {
              log_this("INFO",$g_routine_name,"MOVING_FILE_TO_HOLDING_TANK " . $i_filename_to_move . " " .  $destination_name);
          } else {
              $sigevent_msg = "FILE_MOVE_TO_HOLDING_TANK_FAILED_CANNOT_PERFORM_RENAME $i_filename_to_move $destination_name";
              $sigevent_type = "ERROR";
              $sigevent_url = $ENV{GHRSST_SIGEVENT_URL};
              log_this("ERROR",$g_routine_name,$sigevent_msg);
              raise_sigevent($sigevent_url,$sigevent_provider,$sigevent_source,$sigevent_type,$sigevent_category,$g_routine_name . ":" . $sigevent_msg,$sigevent_data);
          }
    } else {
        # Since we allow the input file names to be DUMMY_SST4_FILENAME or DUMMY_OC_FILENAME or DUMMY_SST_FILENAME,
        # we check to see if it contains these names.  Only report it as an error if the names are different.
        # Check to see if the name does not start with DUMMY.
        if ($i_filename_to_move !~ /^DUMMY/) {
            $sigevent_msg = "FILE_MOVE_TO_HOLDING_TANK_FAILED_FILE_DOES_NOT_EXIST $i_filename_to_move";
            $sigevent_type = "ERROR";
            $sigevent_url = $ENV{GHRSST_SIGEVENT_URL};
            log_this("ERROR",$g_routine_name,$sigevent_msg);
            raise_sigevent($sigevent_url,$sigevent_provider,$sigevent_source,$sigevent_type,$sigevent_category,$g_routine_name . ":" . $sigevent_msg,$sigevent_data);
        }
    }
}

