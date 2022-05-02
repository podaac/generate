#! /usr/local/bin/perl

#  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM 

sub rename_output_file_to_gds2_format
{
    my $i_out_filename = shift;

    my $o_out_filename = "";

# Function rename a MODIS L2P GDS1 output file name to a GDS2 file name.
#
# This output file
#
#      20061127-MODIS_A-JPL-L2P-A2006331133500.L2_LAC_GHRSST_N-v01.nc
#
# will be converted to
#
#      20061127133500-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc
#
#------------------------------------------------------------------------------------------------

    my $day_or_night = '';
    if (index($i_out_filename,"L2_LAC_GHRSST_D") >= 0) {
       $day_or_night = 'D';
    } else {
       $day_or_night = 'N';
    }

    my @dot_name_tokens  = split("\\.",$i_out_filename);
    # Split the token using '-' to break down: 20061127-MODIS_A-JPL-L2P-A2006331133500
    my @dash_name_tokens = split("-",$dot_name_tokens[0]);

    # dash_name_tokens[0] = "20061127"
    # dash_name_tokens[1] = "MODIS_A"
    # dash_name_tokens[2] = "JPL"
    # dash_name_tokens[3] = "L2P" 
    # dash_name_tokens[4] = "A2006331133500";

    # to form 20061127133500-JPL-L2P_GHRSST-SSTskin-MODIS_A-N-v02.0-fv01.0.nc

    if (scalar(@dash_name_tokens) != 5) { 
        print 'rename_output_file_to_gds2_format: ERROR, Expecting exactly 5 tokens, received ' . scalar(@dash_name_tokens) . ' tokens';
        $o_status = 0;
        #return, o_status;
    } 

    # Get the time portion from the 5th token.
    # dash_name_tokens[4] = "A2006331133500";
    #                        01234567890123

    my $time_portion = substr($dash_name_tokens[4],8);

    #                  20061127                   133500       -             JPL           -             L2P           _     GHRSST-SSTskin     -        MODIS_A            -     N     -     v02.0     -     fv01.0     .nc
    if ($day_or_night eq 'D') { 
        $o_out_filename = $dash_name_tokens[0] . $time_portion . "-" . $dash_name_tokens[2] . "-" . $dash_name_tokens[3] . "_" . "GHRSST-SSTskin" . "-" . $dash_name_tokens[1] . "-" . "D" . "-" . "v02.0" . "-" . "fv01.0" . ".nc";
    }
    if ($day_or_night eq 'N' or $day_or_night eq 'M') {
        $o_out_filename = $dash_name_tokens[0] . $time_portion . "-" . $dash_name_tokens[2] . "-" . $dash_name_tokens[3] . "_" . "GHRSST-SSTskin" . "-" . $dash_name_tokens[1] . "-" . "N" . "-" . "v02.0" . "-" . "fv01.0" . ".nc";
    }

# ---------- Close up shop ----------

    return($o_out_filename);
}
