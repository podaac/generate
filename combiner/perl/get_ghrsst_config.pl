#! /usr/local/bin/perl

#  Copyright 2012, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

#
# Subroutine returns the value of a given parameter.
#
# Assumption:
#
#   1) The config file format is "parameter value", separated by space. 
#   2) The array ghrsst_configuration_array has been filled in by function load_ghrsst_run_config().
#   3) First parameter found is the parameter returned.
#   4) Parameter in is all in UPPERCASE.
#
#------------------------------------------------------------------------------------------------

sub get_ghrsst_config {

    #
    # Returned value.   Start with a blank.  Returned blank if cannot find parameter.
    #

    my $o_value = "";;

    #
    # Get input.  Case is important.
    #

    my $i_parameter_name =  $_[0];

    #
    # Search through the entire array for the parameter name and return the value. 
    # Note: no error checking.
    #

    my $config_array_size = @ghrsst_configuration_array;
    my $found_name        = 0;
    my $array_index       = 0;

#print "get_ghrsst_config:Looking for $i_parameter_name\n";
#print "get_ghrsst_config:config_array_size = $config_array_size\n";

    while (!$found_name && $array_index < $config_array_size) {

        # Remove leading blanks.

	my $a_line = $ghrsst_configuration_array[$array_index];
	$a_line =~ s/^\s+//;
	$a_line =~ s/\s+$//;

#$where_pound = index($a_line,"#");
#$line_len    = length($a_line);
#print "get_ghrsst_config:a_line      = [$a_line]\n";
#print "get_ghrsst_config:where_pound = [$where_pound]\n";
#print "get_ghrsst_config:line_len    = [$line_len]\n";

        # Only process non-blank lines and lines that are not comments.

        if ((index($a_line,"#") < 0) && (length($a_line) > 0)) {

          # Parse the element for the instrument name and the time resolution.
          # The format of each element should be: instrument_field i_yyyy i_mm i_ddd e_yyyy e_mm e_ddd
          # Use ' ' to split the line into each fields.

          my @splitted_strings = split(' ',$a_line);

#print "get_ghrsst_config:array_index = $array_index\n";
#print "get_ghrsst_config:splitted_strings[0] = $splitted_strings[0]\n";
#print "get_ghrsst_config:splitted_strings[1] = $splitted_strings[1]\n";

          # First tokens is the parameter name.  Second is the value.

          if ($splitted_strings[0] eq $i_parameter_name) {
                $found_name = 1;
                # Save the value to be returned.
                $o_value = $splitted_strings[1];;
#print "get_ghrsst_config:                  FOUND $i_parameter_name at $array_index\n";
          }
        }

        # Look for next element in the array.
        $array_index = $array_index + 1;
    }

    # ---------- Close up shop ----------
    return ($o_value);

} # end sub get_ghrsst_config
