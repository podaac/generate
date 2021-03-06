#! /usr/local/bin/perl

#  Copyright 2005, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: build_name_without_bunzip_extension.pl,v 1.3 2007/02/06 00:13:23 qchau Exp $
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
# New Request #xxxx

# Subroutine parses a MODIS sea surface temperature for the start time
# Certain assumptions are made about the format of the filename.
#
#------------------------------------------------------------------------------------------------

do "$GHRSST_PERL_LIB_DIRECTORY/remove_refined_prefix_from_filename.pl";

sub build_name_without_bunzip_extension {

    #
    # Get input.
    #

    my $i_bzip_filename = $_[0];

    #
    # Local variables.
    #
    
    my $r_status = 0;
    my $r_after_bunzip_data_filename = ""; 


    #
    # Now, we split the name into separate substrings separated by the slash
    #

    my @splitted_array = split(/\//,$i_bzip_filename);

    #
    # The name without the directory is the last substring.
    #

    my $num_substrings = @splitted_array;

    #
    # Remove any refined prefix.
    #
    my $name_only = $splitted_array[$num_substrings-1];
    my $l_status = 0;
    ($l_status,$name_only) = remove_refined_prefix_from_filename($name_only);

    my $name_with_bzip_extension = $name_only; 
#    my $name_with_bzip_extension = $splitted_array[$num_substrings-1];

    # Create the name without the .bz2 extension.  Get from beginning
    # and stop before the .bz2 (which is 4 characters long).

    $last_dot_pos = rindex($name_with_bzip_extension[$count],".");

    # Check to see if the file already has been uncompressed.  If it has been uncompressed, take the file as is.
    if (index($name_with_bzip_extension,".bz2") >= 0) {
        $r_after_bunzip_data_filename = substr($name_with_bzip_extension,0,
            length($name_with_bzip_extension) - 4);
    } else {
        $r_after_bunzip_data_filename = $name_only; 
    }


#print "build_name_without_bunzip_extension:Found dot.\n";
#print "build_name_without_bunzip_extension:name_with_bzip_extension = $name_with_bzip_extension\n";
#print "build_name_without_bunzip_extension:r_after_bunzip_data_filename = $r_after_bunzip_data_filename\n";
#print "build_name_without_bunzip_extension:last_dot_pos = $last_dot_pos\n";
#exit(0);


    return ($r_after_bunzip_data_filename)
}
