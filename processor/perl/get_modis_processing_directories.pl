#!/usr/local/bin/perl
#
#  Copyright 2008, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Function returns processing directories during MODIS processing based on
# processing type.
#
# Assumption(s):
#
#   1.  The configuration has been loaded into memory already.
#
#------------------------------------------------------------------------------------------------

do "$GHRSST_PERL_LIB_DIRECTORY/get_ghrsst_config.pl";
do "$GHRSST_PERL_LIB_DIRECTORY/actualize_directory.pl";

sub get_modis_processing_directories {

    #
    # Get input(s).
    #
    
    my $i_datasource       = uc(shift);
    my $i_processing_type  = uc(shift);

    my $debug_module = "get_modis_processing_directories:";
    my $debug_mode   = 0; 

    #
    # Returned variable(s).
    #

    my $r_modis_search_directory = "DUMMY";
    my $r_modis_data_name_prefix = "";
    my $r_l2p_core_output_directory  = $ENV{MODIS_SEATMP_L2P_CORE_DIRECTORY}; 

    # Add support for VIIRS dataset.
    if ($i_datasource eq "VIIRS") {
        $r_l2p_core_output_directory  = $ENV{VIIRS_SEATMP_L2P_CORE_DIRECTORY}; 
    }
    # Do a sanity check to make sure the output directory is defined and the account has write permission.
    if ($r_l2p_core_output_directory eq "") {
        print $debug_module . "ERROR: The expected environment variable VIIRS_SEATMP_L2P_CORE_DIRECTORY has not been defined to a valid directory.\n";
        exit(0);
    }

    #
    # Local variable(s).
    #

    my $l_modis_data_directory   = "";


    # Create director(ies) if they don't exist already.
    my $l_actualize_status = 0;
    $l_actualize_status = actualize_directory($r_l2p_core_output_directory);

    #
    # Get the directory name containing the datasets we want.
    #
    
    if ($i_datasource eq "MODIS_A") {
        $r_modis_data_name_prefix = "A"; 
        if ($i_processing_type eq "QUICKLOOK") {
            $l_modis_data_directory   =  get_ghrsst_config("MODIS_A_SEATMP_DATASETS_DIRECTORY");
            $r_l2p_core_output_directory = $r_l2p_core_output_directory . "/MODIS_A"; 
        } elsif ($i_processing_type eq "REFINED") {
            $l_modis_data_directory   =  get_ghrsst_config("MODIS_A_REFINED_SEATMP_DATASETS_DIRECTORY");
            $r_l2p_core_output_directory = $r_l2p_core_output_directory . "/MODIS_A_REFINED"; 
        } elsif ($i_processing_type eq "REPROCESSED") {
            $l_modis_data_directory   =  get_ghrsst_config("MODIS_A_REPROCESSED_SEATMP_DATASETS_DIRECTORY");
            $r_l2p_core_output_directory = $r_l2p_core_output_directory . "/MODIS_A_REPROCESSED"; 
        }
    } elsif ($i_datasource eq "MODIS_T") {
        $r_modis_data_name_prefix = "T"; 
        if ($i_processing_type eq "QUICKLOOK") {
            $l_modis_data_directory   =  get_ghrsst_config("MODIS_T_SEATMP_DATASETS_DIRECTORY");
            $r_l2p_core_output_directory = $r_l2p_core_output_directory . "/MODIS_T"; 
        } elsif ($i_processing_type eq "REFINED") {
            $l_modis_data_directory   =  get_ghrsst_config("MODIS_T_REFINED_SEATMP_DATASETS_DIRECTORY");
            $r_l2p_core_output_directory = $r_l2p_core_output_directory . "/MODIS_T_REFINED"; 
        } elsif ($i_processing_type eq "REPROCESSED") {
            $l_modis_data_directory   =  get_ghrsst_config("MODIS_A_REPROCESSED_SEATMP_DATASETS_DIRECTORY");
            $r_l2p_core_output_directory = $r_l2p_core_output_directory . "/MODIS_T_REPROCESSED"; 
        }
    } elsif ($i_datasource eq "VIIRS") {
        $r_modis_data_name_prefix = "V";
        if ($i_processing_type eq "QUICKLOOK") {
            $l_modis_data_directory   =  get_ghrsst_config("VIIRS_QUICKLOOK_SEATMP_DATASETS_DIRECTORY");
            $r_l2p_core_output_directory = $r_l2p_core_output_directory . "/VIIRS";
        } elsif ($i_processing_type eq "REFINED") {
            $l_modis_data_directory   =  get_ghrsst_config("VIIRS_REFINED_SEATMP_DATASETS_DIRECTORY");
            $r_l2p_core_output_directory = $r_l2p_core_output_directory . "/VIIRS_REFINED";
        }
    } else {
        print "get_modis_processing_directories: data source is not supported at the moment.\n";
        print "get_modis_processing_directories: i_datasource = $i_datasource\n";
        $o_status = 1;
        return ($o_status);
    }

    if ($debug_mode) {
        print $debug_module . "i_datasource             [$i_datasource]\n";
        print $debug_module . "i_processing_type        [$i_processing_type]\n";
        print $debug_module . "l_modis_data_directory   [$l_modis_data_directory]\n";
        print $debug_module . "r_l2p_core_output_directory [$r_l2p_core_output_directory]\n";
    }

    $r_modis_search_directory = $l_modis_data_directory . "/" ;

    # Create directorie(s) if they don't exist already.
    $l_actualize_status = actualize_directory($r_l2p_core_output_directory);

    # ---------- Close up shop ----------
    return ($r_modis_search_directory,
            $r_modis_data_name_prefix,
            $r_l2p_core_output_directory);

} # end get_modis_processing_directories 


# Main program calls the subroutine defined above.
my $debug_module = "get_modis_processing_directories:";
my $module_name  = "get_modis_processing_directories.pl";

if (index($0,$module_name) >= 0)
{
    # Because we are running this script for unit test, we have to call the next 3 statements explicitly to define the variable GHRSST_PERL_LIB_DIRECTORY
    # and execute the next 2 scripts.  Without these 3 lines, this script will complain about not defined funtion:
    # "Undefined subroutine &main::create_random_filename called at take_directory_snapshot.pl line 63"

    $GHRSST_PERL_LIB_DIRECTORY = $ENV{GHRSST_PERL_LIB_DIRECTORY};
    $GHRSST_DATA_CONFIG_FILE = $ENV{GHRSST_DATA_CONFIG_FILE};
    do "$GHRSST_PERL_LIB_DIRECTORY/load_ghrsst_run_config.pl";
    do "$GHRSST_PERL_LIB_DIRECTORY/get_ghrsst_config.pl";
    do "$GHRSST_PERL_LIB_DIRECTORY/actualize_directory.pl";

    my $debug_module = "get_modis_processing_directories:";
    my $debug_mode   = 1;

    # For the unit test, we have to load the configuration into memory first, otherwise the function get_ghrsst_config() won't work.
    my $l_status = load_ghrsst_run_config($GHRSST_DATA_CONFIG_FILE);

    #
    # Test the VIIRS REFINED
    #
    my $i_datasource       = uc("VIIRS");
    my $i_processing_type  = uc("REFINED");
    my ($r_modis_search_directory,
        $r_modis_data_name_prefix,
        $r_l2p_core_output_directory) = get_modis_processing_directories($i_datasource,
                                                                         $i_processing_type);

    print $debug_module ."i_datasource                $i_datasource\n";
    print $debug_module ."i_processing_type           $i_processing_type\n";
    print $debug_module ."r_modis_search_directory    $r_modis_search_directory\n";
    print $debug_module ."r_modis_data_name_prefix    $r_modis_data_name_prefix\n";
    print $debug_module ."r_l2p_core_output_directory $r_l2p_core_output_directory\n";
    print "\n";

    #
    # Test the VIIRS QUICKLOOK
    #
    my $i_datasource       = uc("VIIRS");
    my $i_processing_type  = uc("QUICKLOOK");
    my ($r_modis_search_directory,
        $r_modis_data_name_prefix,
        $r_l2p_core_output_directory) = get_modis_processing_directories($i_datasource,
                                                                         $i_processing_type);

    print $debug_module ."i_datasource                $i_datasource\n";
    print $debug_module ."i_processing_type           $i_processing_type\n";
    print $debug_module ."r_modis_search_directory    $r_modis_search_directory\n";
    print $debug_module ."r_modis_data_name_prefix    $r_modis_data_name_prefix\n";
    print $debug_module ."r_l2p_core_output_directory $r_l2p_core_output_directory\n";
    print "\n";

    #
    # Test the AQUA QUICKLOOK
    #
    my $i_datasource       = uc("MODIS_A");
    my $i_processing_type  = uc("QUICKLOOK");
    my ($r_modis_search_directory,
        $r_modis_data_name_prefix,
        $r_l2p_core_output_directory) = get_modis_processing_directories($i_datasource,
                                                                         $i_processing_type);

    print $debug_module ."i_datasource                $i_datasource\n";
    print $debug_module ."i_processing_type           $i_processing_type\n";
    print $debug_module ."r_modis_search_directory    $r_modis_search_directory\n";
    print $debug_module ."r_modis_data_name_prefix    $r_modis_data_name_prefix\n";
    print $debug_module ."r_l2p_core_output_directory $r_l2p_core_output_directory\n";
    print "\n";

    #
    # Test the AQUA REFINED
    #
    my $i_datasource       = uc("MODIS_A");
    my $i_processing_type  = uc("REFINED");
    my ($r_modis_search_directory,
        $r_modis_data_name_prefix,
        $r_l2p_core_output_directory) = get_modis_processing_directories($i_datasource,
                                                                         $i_processing_type);

    print $debug_module ."i_datasource                $i_datasource\n";
    print $debug_module ."i_processing_type           $i_processing_type\n";
    print $debug_module ."r_modis_search_directory    $r_modis_search_directory\n";
    print $debug_module ."r_modis_data_name_prefix    $r_modis_data_name_prefix\n";
    print $debug_module ."r_l2p_core_output_directory $r_l2p_core_output_directory\n";
    print "\n";

    #
    # Test the TERRA QUICKLOOK
    #
    my $i_datasource       = uc("MODIS_T");
    my $i_processing_type  = uc("QUICKLOOK");
    my ($r_modis_search_directory,
        $r_modis_data_name_prefix,
        $r_l2p_core_output_directory) = get_modis_processing_directories($i_datasource,
                                                                         $i_processing_type);

    print $debug_module ."i_datasource                $i_datasource\n";
    print $debug_module ."i_processing_type           $i_processing_type\n";
    print $debug_module ."r_modis_search_directory    $r_modis_search_directory\n";
    print $debug_module ."r_modis_data_name_prefix    $r_modis_data_name_prefix\n";
    print $debug_module ."r_l2p_core_output_directory $r_l2p_core_output_directory\n";
    print "\n";

    #
    # Test the TERRA REFINED
    #
    my $i_datasource       = uc("MODIS_T");
    my $i_processing_type  = uc("REFINED");
    my ($r_modis_search_directory,
        $r_modis_data_name_prefix,
        $r_l2p_core_output_directory) = get_modis_processing_directories($i_datasource,
                                                                         $i_processing_type);

    print $debug_module ."i_datasource                $i_datasource\n";
    print $debug_module ."i_processing_type           $i_processing_type\n";
    print $debug_module ."r_modis_search_directory    $r_modis_search_directory\n";
    print $debug_module ."r_modis_data_name_prefix    $r_modis_data_name_prefix\n";
    print $debug_module ."r_l2p_core_output_directory $r_l2p_core_output_directory\n";
    print "\n";
}