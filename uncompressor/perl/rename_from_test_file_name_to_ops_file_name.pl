#!/usr/local/bin/perl
#  Copyright 2014, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.

use File::Basename;

#------------------------------------------------------------------------------------------------------------------------
sub rename_from_test_file_name_to_ops_file_name {
    # This is a one-off function to allow the modis_level2_uncompressor.pl script to rename the files to their proper names.
    # If the input files does not contain the test file regular expressions, the name will remain the same.
    #
    # This function actually does not rename the filename on the file system but merely returns the new name.
    # After calling this function, you'll have to use rename($old_name,$new_name) to do the rename of the file on the file system.

    my $i_test_file_name = shift;

    # If processing test files from OBPG, we need to rename the files to reflect the NetCDF file type and the correct types: SST, SST4 and OC
    #   
    #    A2003060223500.L2_LAC_AT108      should be renamed to A2003060223500.L2_LAC_OC.nc
    #    A2003060223500.L2_LAC_AT109      should be renamed to A2003060223500.L2_LAC_SST.nc
    #    A2003060223500.L2_LAC_AT109_SST4 should be rename to A2003060223500.L2_LAC_SST4.nc 
    #
    # For the compressed files.
    #
    #    A2003060223500.L2_LAC_AT108.bz2      should be renamed to A2003060223500.L2_LAC_OC.nc.bz2
    #    A2003060223500.L2_LAC_AT109.bz2      should be renamed to A2003060223500.L2_LAC_SST.nc.bz2
    #    A2003060223500.L2_LAC_AT109_SST4.bz2 should be rename to A2003060223500.L2_LAC_SST4.nc .bz2
    #
    # For the 2007 files, which has the .nc extension.
    #
    #    A2007060235500.L2_LAC_AT108.nc      should be renamed to A2007060235500.L2_LAC_OC.nc
    #    A2007060235500.L2_LAC_AT109_SST.nc  should be renamed to A2007060235500.L2_LAC_SST.nc
    #    A2007060235500.L2_LAC_AT109_SST4.nc  should be renamed to A2007060235500.L2_LAC_SST4.nc

    my $o_ops_filename   = $i_test_file_name;  # Save the original name in case we did not need to perform the rename.

    # Get the directory name and save it.

    my $directory_name = dirname($i_test_file_name);

    # Rename LAC_AT108 and /LAC_AT108.bz2 files.

    if ($i_test_file_name =~ /LAC_AT108$/) {
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT108"); # Get the name without the extension.
        $o_ops_filename = $directory_name . "/" . $name_without_extension . ".L2_LAC_OC.nc";
    }
    if ($i_test_file_name =~ /LAC_AT108.bz2$/) {
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT108.bz2"); # Get the name without the extension.
        $o_ops_filename = $directory_name .  "/" .$name_without_extension . ".L2_LAC_OC.nc.bz2";
    } 
    
    # Rename the LAC_AT108.nc files.

    if ($i_test_file_name =~ /LAC_AT108.nc$/) { 
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT108.nc"); # Get the name without the extension.
        $o_ops_filename = $directory_name . "/" . $name_without_extension . ".L2_LAC_OC.nc";
    }

    # Rename LAC_AT109 and LAC_AT109.bz2 files.

    if ($i_test_file_name =~ /LAC_AT109$/) {
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT109"); # Get the name without the extension.
        $o_ops_filename = $directory_name .  "/" .$name_without_extension . ".L2_LAC_SST.nc";
    }   

    # Rename the LAC_AT109_SST.nc files
    if ($i_test_file_name =~ /LAC_AT109.nc$/) {
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT109.nc"); # Get the name without the extension.
        $o_ops_filename = $directory_name .  "/" .$name_without_extension . ".L2_LAC_SST.nc";
    }

    # Rename the LAC_AT109_SST.nc files
    if ($i_test_file_name =~ /LAC_AT109_SST.nc$/) {
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT109_SST.nc"); # Get the name without the extension.
        $o_ops_filename = $directory_name .  "/" .$name_without_extension . ".L2_LAC_SST.nc";
    }   

    # Rename the LAC_AT109_SST4.nc files
    if ($i_test_file_name =~ /LAC_AT109_SST4.nc$/) {
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT109_SST4.nc"); # Get the name without the extension.
        $o_ops_filename = $directory_name .  "/" .$name_without_extension . ".L2_LAC_SST4.nc";
    }

    if ($i_test_file_name =~ /LAC_AT109.bz2$/) {
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT109.bz2"); # Get the name without the extension.
        $o_ops_filename = $directory_name .  "/" .$name_without_extension . ".L2_LAC_SST.nc.bz2";
    }   

    # Rename LAC_AT109_SST4 and LAC_AT109_SST4.bz2 files.

    if ($i_test_file_name =~ /LAC_AT109_SST4$/) {
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT109_SST4"); # Get the name without the extension.
        $o_ops_filename = $directory_name .  "/" .$name_without_extension . ".L2_LAC_SST4.nc";
    }   
    if ($i_test_file_name =~ /LAC_AT109_SST4.bz2$/) {
        my $name_without_extension = basename($i_test_file_name,".L2_LAC_AT109_SST4.bz2"); # Get the name without the extension.
        $o_ops_filename = $directory_name .  "/" .$name_without_extension . ".L2_LAC_SST4.nc.bz2";
    }   

    return ($o_ops_filename);
}
