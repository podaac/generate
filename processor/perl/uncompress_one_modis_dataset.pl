#! /usr/local/bin/perl

#  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

#
# Function uncompress one MODIS datasets from .bz2 to HDF format.
#
# Assumption:
#
#   1) Global variable(s) is defined:
#       $GLOBAL_SYSTEM_BIN_DIRECTORY
#   2) The file contains extensions among: {.bz2,.} 
#
#------------------------------------------------------------------------------------------------

use File::Basename;  # Use in parsing the full file name.

sub uncompress_one_modis_dataset {

    # Returned status.  Value of 0 means ok, 1 means bad.

    my $o_status = 0;

    #
    # Get input.
    #
    
    my $i_uncompressed_filename = shift; 

    my $call_shell_command_str  = "$GLOBAL_SYSTEM_BIN_DIRECTORY/bunzip2";

    # If the file has been uncompressed already, we don't do anything.
    if (index($i_uncompressed_filename,".bz2") < 0) {
print "uncompress_one_modis_dataset: INFO, File $i_uncompressed_filename] is already uncompressed.\n";
       return ($o_status);
    }

    # Check to see if the file can be found.
    if (!(-e $i_uncompressed_filename)) {
print "uncompress_one_modis_dataset: ERROR, File is not found: [$i_uncompressed_filename]\n";
       $o_status = 1;
       return($o_status);
    }

    # Parse the name.
    my ($name_only,$directory_path,$suffix) = fileparse($i_uncompressed_filename,qr/\.[^.]*/);

    # Check for suffix.  We are only uncompressing .bz2 files in this function.

    if ($suffix ne '.bz2') {
        print "uncompress_one_modis_dataset: ERROR, This function only uncompressing .bz2 files\n";
        $o_status = 1;
        return($o_status);
    }

    my $name_without_extension = $directory_path . $name_only;

#print "name_without_extension = [$name_without_extension]\n";

    # Remove any previously uncompressed file first.

    if (-e $name_without_extension) {
        print "Removing previously uncompressed $name_without_extension\n"; 
        unlink($name_without_extension);
    }

    #
    # Uncompress file with bunzip2.  New name will not have .bz2 extension.
    #

print "  $call_shell_command_str $i_uncompressed_filename\n";
    system("$call_shell_command_str $i_uncompressed_filename");

    #
    # Check for errors.
    #
    if ($? != 0) {
        print "uncompress_one_modis_dataset: system $args[0] executed with: $?\n";
        print "uncompress_one_modis_dataset: Cannot bunzip2 file: $i_uncompressed_filename\n";

        # Remove the .bz2 file since we can't uncompress it.
        unlink($i_uncompressed_filename);

        # Report to log file.  Format is: "ERROR file_name reason";
        print "uncompress_one_modis_dataset, ERROR File $i_uncompressed_filename may be corrupted\n";

        $o_status = 1;
    }

    return ($o_status);
}
