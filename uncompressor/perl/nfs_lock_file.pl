#!/usr/bin/perl

#  Copyright 2015, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Subroutine to lock a file using the File::NFSLock module.
#
# This function is meant to work on NFS mounted file system.
#
# If the lock cannot be acquired after the default 10 seconds, it will exit with the variable o_the_lock undefined.
# The callee will check using the function defined() function on the returned variable.

use File::NFSLock qw(uncache);
use Fcntl qw(LOCK_EX);

my $debug_flag = 0;

if ($ENV{GHRSST_MODIS_L2_UNCOMPRESSOR_DEBUG_MODE} eq "true") { $debug_flag = 1; }

sub nfs_lock_file {
    my $i_semaphore_name  = shift;  # The name of the semaphore should ends with .lck and a full pathname.

    my $routine_name = "nfs_lock_file"; 

    if ($debug_flag) { print localtime() . " DEBUG [" . $routine_name . "] Attempting to lock file $i_semaphore_name\n"; }

    # Do a sanity check to see if the semaphore ends with ".lck".  If not, return the undefined o_the_lock.

    if (not ($i_semaphore_name =~ m/.lck$/)) {
        print localtime() . " ERROR [" . $routine_name . "] i_semaphore_name $i_semaphore_name  does not ends with .lck\n";
        # Return an undefined variable.
        return ($o_the_lock);
    } else {
        if ($debug_flag) { print localtime() . " DEBUG [" . $routine_name . "] i_semaphore_name $i_semaphore_name ends with .lck\n"; }
    }

    # Attempt to get the exclusive lock, but only wait for 10 seconds.  If 11 seconds has passed
    # and the lock could not be acquired, exit with the lock undefined.

    my $MAX_BLOCKING_TIME_OUT = 10;

    if ($ENV{GHRSST_MODIS_L2_MAX_FILE_LOCK_BLOCKING_TIME_OUT} ne "") {
        # Do a sanity check to make sure it is more than 1.
        if ($ENV{GHRSST_MODIS_L2_MAX_FILE_LOCK_BLOCKING_TIME_OUT} >= 1) {
            $MAX_BLOCKING_TIME_OUT= $ENV{GHRSST_MODIS_L2_MAX_FILE_LOCK_BLOCKING_TIME_OUT};
        } else {
            die("Must set GHRSST_MODIS_L2_MAX_FILE_LOCK_BLOCKING_TIME_OUT environment variable to value greater than or equal to 1.  Current value " . $ENV{GHRSST_MODIS_MAX_FILE_LOCK_BLOCKING_TIME_OUT});
        }
    }

    my $o_the_lock = File::NFSLock->new({file               => $i_semaphore_name,
                                         lock_type          => LOCK_EX,
                                         blocking_timeout   => $MAX_BLOCKING_TIME_OUT,  # 10 sec, default
                                         stale_lock_timeout => 30 * 60,                 # 30 min, default
                                         });

    # If the locking was successful, a file with the name .NFSLock appended to the variable i_semaphore_name will exist
    # until it is unlocked or the process owning the file exits.  The variable o_the_lock will be defined.

    if (defined($o_the_lock)) {
        if ($debug_flag) { print localtime() . " DEBUG [" . $routine_name . "] File $i_semaphore_name is now locked. Lock acquired\n"; }
    } else {
        print localtime() . " ERROR [" . $routine_name . "] File $i_semaphore_name is still locked by another process.  Lock not acquired.\n";
    }
 
    return ($o_the_lock);
}
#return 1;
