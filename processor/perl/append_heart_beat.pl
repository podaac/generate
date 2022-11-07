#!/usr/local/bin/perl

#  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: append_heart_beat.pl,v 1.3 2007/11/13 16:41:37 qchau Exp $
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
# New Request #xxxx

# Subroutine appends a string to the end of the heart beat file.
#
# Assumption(s):
#
# 1.  The configuration file has been read into memory already.
# 2.  The global variable GHRSST_PERL_LIB_DIRECTORY has been defined.
# 3.  The heart beat file is stored in HOME/heart_beart.txt for convenience,
#     so only one heart beat is allowed per user.
#
#------------------------------------------------------------------------------------------------

do "$GHRSST_PERL_LIB_DIRECTORY/OLock.pm";

sub append_heart_beat {

    #
    # Get input.
    #

    my $i_heart_beat_filename = $_[0];
    my $i_heart_beat_message  = $_[1];

$i_heart_beat_filename =  "$ENV{SCRATCH_AREA}/heart_beat_$ENV{RANDOM_NUMBER}.txt";    # NET edit. (Place in scratch)

    #
    # Local variable(s).
    #
    
    my $r_status = 0;

    # Create a lock name.
    my $semaphore_lock_common_area    = $ENV{SEMAPHORE_LOCK_COMMON_AREA};
    my $lock_name = "$semaphore_lock_common_area" . "/MODIS_L2P_AND_MAF_HEARTBEAT_$ENV{RANDOM_NUMBER}";
#print "append_heart_beat: lock_name = [$lock_name]\n";
    my $l2p_stream_lock = OLock->new("$lock_name");

    # Lock the process stream.
    $l2p_stream_lock->semlock();

    # Create an empty heart beat file if it does not already exist.
    system("touch $i_heart_beat_filename");

    if (-e $i_heart_beat_filename) {
       # Build the heart beat entry by prepending the current time.
       my $l_heart_beat_entry = localtime() . ", " . $i_heart_beat_message;

       # Append the heart beat entry.
       system("echo '$l_heart_beat_entry' >> $i_heart_beat_filename");
#       print "echo '[$l_heart_beat_entry]'\n";
    } else {
       print "append_heart_beat: File not found $i_heart_beat_filename\n";
       print "append_heart_beat: Cannot append message [$i_heart_beat_message].\n";
       $r_status = 1;
    }

    # Release the semaphore.  We don't need it anymore.

    $l2p_stream_lock->semunlock();

    # Close up shop.

    return ($r_status);
}
