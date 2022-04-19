#!/usr/local/bin/perl

#  Copyright 2012, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Function to crawl the sst and sst4 directories for new files.
#
#------------------------------------------------------------------------------------------------

do "$GHRSST_PERL_LIB_DIRECTORY/get_ghrsst_config.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/big_directory_crawl.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/actualize_directory.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/remove_temporary_log_dir.pl";

do "$GHRSST_PERL_LIB_DIRECTORY/OLock.pm";

sub crawl_sst_sst4_directories {

    # Returned status.  Value of 0 means ok, 1 means bad.

    my $o_status = 0;

    #
    # Get input(s).
    #

    my $i_datatype        =   lc($_[0]); # Lowercase the input. {sea_surface_temperature}
    my $i_datasource      =      $_[1];  # Instrument: {MODIS_A,MODIS_T}
    my $i_processing_type =      $_[2];  # Quicklook or Refined.
    my $i_modis_search_directory = $_[3]; # Directory name to crawl.
    my $i_modis_data_name_prefix = $_[4]; # Either A or T.
    my $i_optional_days_back     = $_[5];

    # Time related variables.
    my $time_start = time();

    # Create director(ies) if they don't exist already.
    # Local variables.

    my $scratch_area       = $ENV{SCRATCH_AREA}; 
    my $l_actualize_status = actualize_directory($scratch_area);

    my $l_current_time = $time_start;

    my $l_partial_directory_name = lc($i_processing_type) . "_" . lc($i_datasource);

    # Get a list of names of the full directory.

    my $l_status = 0;

    # Extract everything except the last two characters from the l_partial_directory_name
    # since we don't want the "_a" or "_t" from the name.

    my $source_name = substr($l_partial_directory_name,0,length($l_partial_directory_name)-2);

    ($l_status, $tmp_filelist) = big_directory_crawl(
                                      $i_modis_search_directory,
                                      $i_modis_data_name_prefix,
                                      $scratch_area,
                                      $source_name,
                                      $l_current_time,
                                      $i_optional_days_back);

    if ($l_status != 0) {
        print "crawl_sst_sst4_directories: Failure in big_directory_crawl () function.\n";
        print "crawl_sst_sst4_directories: Cannot continue.\n";
        $o_status = 1;
        return ($o_status);
    }

    #
    # Read the entire file into memory.  Exit if there's a problem.
    #

    open (FH, "< $tmp_filelist") or die "crawl_sst_sst4_directories:Can't open file for reading $tmp_filelist: $!";

    my @o_modis_filelist= <FH>;
    close (FH);

    #
    # Clean up.
    #

    if (-e $tmp_filelist)                   { unlink($tmp_filelist); }

    # Remove temporary log directory created by script.

    remove_temporary_log_dir($l_current_time,$l_partial_directory_name);

    # ---------- Close up shop ----------
    return ($o_status,\@o_modis_filelist);

} # end sub crawl_sst_sst4_directories