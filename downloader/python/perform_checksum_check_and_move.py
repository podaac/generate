#  Copyright 2017, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Function to perform a checksum check on a downloaded file and then move the file to its final destination.
# If the checksum fail, an attempt will be made to get the latest checksum from OBPG and perform the checksum again.
#------------------------------------------------------------------------------------------------

import hashlib
import os
import time

from file_move_with_error_handling import file_move_with_error_handling;
from get_file_checksum             import get_file_checksum;
from log_this import log_this;
from const import CONST_SUCCESS_STATUS,CONST_FAILURE_STATUS,CONST_FILE_NOT_FOUND;

import settings;

#------------------------------------------------------------------------------------------------------------------------
def perform_checksum_check_and_move(i_final_location_of_downloaded_file,
                                    i_temporary_location_of_downloaded_file,
                                    i_perform_checksum_flag,
                                    i_file_name_to_get_checksum_for,
                                    i_checksum_value):

    g_routine_name= "perform_checksum_check_and_move";
    debug_module  = "perform_checksum_check_and_move:";
    debug_mode    = 0;


    o_move_status = CONST_SUCCESS_STATUS; #  A value of 1 signifies the checksum checks out.

    # If the file already has been downloaded before, we remove it so it can be download again. 
    # Perhaps we can make this a flag from command line.
    # Note that we move the removal of the existing file and the renaming of the temporary file to final
    # destination closer together so there will not be a long gap between the file removal and the replacement
    # of the new file.

    checksum_status = CONST_SUCCESS_STATUS; 
    ok_to_remove_existing_file_flag = 1;

    exist_status = os.path.isfile(i_final_location_of_downloaded_file);
    if (debug_mode):
        print(debug_module + "i_final_location_of_downloaded_file " + i_final_location_of_downloaded_file + " exist_status = " + str(exist_status));

    if (exist_status):

        # If using a file locking mechanism, lock the file using nfs_lock_file() function with the semaphore with ".lck" appended to the file name.
        if (settings.g_use_file_locking_mechanism_flag):
            from nfs_lock_file_wrapper import nfs_lock_file_wrapper;
            (ok_to_remove_existing_file_flag,o_the_lock) = nfs_lock_file_wrapper(i_temporary_location_of_downloaded_file,None);

        if (ok_to_remove_existing_file_flag):
            log_this("INFO",g_routine_name,"REMOVE_EXISTING_FILE " + i_final_location_of_downloaded_file);
            os.remove(i_final_location_of_downloaded_file);
        else:
            checksum_status = CONST_FAILURE_STATUS;   # Set this checksum_status to 0 to signify that we did not compare the checksum because we could not remove existing file.

#        # Remove the lock if exist.

    if (debug_mode):
        print(debug_module + "ok_to_remove_existing_file_flag         ",ok_to_remove_existing_file_flag);
        print(debug_module + "checksum_status                         ",checksum_status);
        print(debug_module + "i_perform_checksum_flag                 ",i_perform_checksum_flag);
        print(debug_module + "i_checksum_value                        ",i_checksum_value);
        print(debug_module + "i_temporary_location_of_downloaded_file ",i_temporary_location_of_downloaded_file);
        print(debug_module + "i_final_location_of_downloaded_file     ",i_final_location_of_downloaded_file);
        print(debug_module + "os.path.isfile(i_temporary_location_of_downloaded_file)",os.path.isfile(i_temporary_location_of_downloaded_file));

#    # Do the checksum check if requested and the file was downloaded successfully.
    if (ok_to_remove_existing_file_flag and  
        (i_perform_checksum_flag == 'yes' and os.path.isfile(i_temporary_location_of_downloaded_file+ '/' + i_file_name_to_get_checksum_for ))):
        # Only perform the checksum if it is not empty.

        if (i_checksum_value != ""):
            time_start_checksum_check = time.time();
            (checksum_status,hash_elapsed) = perform_checksum_check((i_temporary_location_of_downloaded_file+ '/' + i_file_name_to_get_checksum_for),i_checksum_value);
            if (debug_mode):
                print(debug_module + "checksum_status",checksum_status);

            if (checksum_status == CONST_FILE_NOT_FOUND):
                log_this("ERROR",g_routine_name,"TEMPORARY_DOWNLOADED_FILE_NOT_EXIST " + i_temporary_location_of_downloaded_file + '/' + i_file_name_to_get_checksum_for );
            elif (checksum_status == CONST_FAILURE_STATUS):
                # If the checksum fail, we attempt to get the checksum from the file search and then do another compare.
                log_this("WARN",g_routine_name,"CHECKSUM_VALUE_DOES_NOT_MATCH " + i_checksum_value + " " + i_temporary_location_of_downloaded_file + '/' + i_file_name_to_get_checksum_for );
                checksum_from_file_search = get_file_checksum(i_file_name_to_get_checksum_for,None,None);
                log_this("WARN",g_routine_name,"CHECKSUM_VALUE_FETCHED_FROM_FILE_SEARCH " + checksum_from_file_search + " " + i_temporary_location_of_downloaded_file + '/' + i_file_name_to_get_checksum_for );
                (checksum_status,hash_elapsed) = perform_checksum_check((i_temporary_location_of_downloaded_file + '/' + i_file_name_to_get_checksum_for) ,checksum_from_file_search);
                if (debug_mode):
                    print(debug_module + "second_try:checksum_status",checksum_status,"checksum_from_file_search",checksum_from_file_search);

            time_end_checksum_check = time.time();
            time_spent_in_checksum_check = time_end_checksum_check - time_start_checksum_check;
            if (debug_mode):
                print(debug_module + "time_spent_in_checksum_check            ", time_spent_in_checksum_check);
        else:
            log_this("WARN",g_routine_name,"CHECKSUM_VALUE_IS_EMPTY_FROM_FILE " + i_temporary_location_of_downloaded_file + '/' + i_file_name_to_get_checksum_for );

    # If everything is OK from the download, we rename the temporary file to its final name.
    # Note that we also change the last modified time to the current time since the server preserves it.
    # The last modified time is important to the uncompressor and the combiner as it uses that time to determine
    # how long to wait for the arrival of other files.
    
    if (os.path.isfile(i_temporary_location_of_downloaded_file + '/' + i_file_name_to_get_checksum_for ) and (checksum_status == CONST_SUCCESS_STATUS)):
        # If using a file locking mechanism, lock the file using nfs_lock_file() function with the semaphore with ".lck" appended to the file name.

        time_start_file_move = time.time();
        move_status = file_move_with_error_handling(i_temporary_location_of_downloaded_file + '/' + i_file_name_to_get_checksum_for , i_final_location_of_downloaded_file);
        time_end_file_move = time.time();
        if (move_status):
            os.system("touch " + i_final_location_of_downloaded_file);
        else:
            # Something went wrong with the download.  We cannot move the file to its final destination.
            o_move_status = CONST_FAILURE_STATUS;

        time_spent_in_file_move = time_end_file_move - time_start_file_move;
        if (debug_mode):
            print(debug_module + "time_spent_in_file_move ",time_spent_in_file_move);

#        # Remove the lock if exist.

    else:
        # Something went wrong with the download.  The file we expect is not there or we can perform the checksum check.
        o_move_status = CONST_FAILURE_STATUS;
        log_this("ERROR",g_routine_name,"File does not exist " + i_temporary_location_of_downloaded_file + '/' + i_file_name_to_get_checksum_for + " or checksum_status is not CONST_SUCCESS_STATUS");

    if (debug_mode):
        print(debug_module + "o_move_status",o_move_status);
    
    return(o_move_status);

#------------------------------------------------------------------------------------------------------------------------
def perform_checksum_check(i_download_file_name,i_checksum_value):
    # Perform checksum calculation of the recently downloaded file.

    debug_module = "perform_checksum_check:";
    debug_mode   = 1;

    o_checksum_status = CONST_SUCCESS_STATUS;
    o_hash_elapsed = 0;

    BLOCKSIZE = 65536;
    h0 = time.time();
    hasher = hashlib.sha1();

    # Do a sanity check to make sure the file exist.  If not, we return immediately with CONST_FILE_NOT_FOUND status.

    if (not os.path.isfile(i_download_file_name)):
        print(debug_module + "ERROR: NON_EXISTENCE_FILE " + i_download_file_name);
        o_checksum_status = CONST_FILE_NOT_FOUND;
        return(o_checksum_status,o_hash_elapsed);

    # File exist, we can now read it into memory so we can create the checksum.
    with open(i_download_file_name, 'rb') as afile:
            buf = afile.read(BLOCKSIZE);
            while len(buf) > 0:
                hasher.update(buf);
                buf = afile.read(BLOCKSIZE);

    h1 = time.time();
    o_hash_elapsed = h1 - h0;

    #  The entire buffer has been updated, we now can get the digest.
    calculated_checksum = hasher.hexdigest();

    # Now that we have both checksum valuels, we can compare them.
    if (calculated_checksum == i_checksum_value):
        # All is indeed good.
        print("INFO: CHECKSUM_SAMENESS CALCULATED_CHECKSUM", calculated_checksum, "PROVIDED_CHECKSUM",i_checksum_value);
    else:
        # All is not good.
        print("ERROR: CHECKSUM_MISMATCHED CALCULATED_CHECKSUM", calculated_checksum, "PROVIDED_CHECKSUM",i_checksum_value);
        o_checksum_status = CONST_FAILURE_STATUS;

    return(o_checksum_status,o_hash_elapsed);

if __name__ == "__main__":
    i_final_location_of_downloaded_file     = "/data/dev/scratch/qchau/IO/data/VIIRS_L2_SST_OBPG/V2016293000000.L2_SNPP_SST.nc";
    i_temporary_location_of_downloaded_file = "/data/dev/scratch/qchau/IO/data/VIIRS_L2_SST_OBPG/.hidden/V2016293000000.L2_SNPP_SST.nc";
    i_perform_checksum_flag                 = "yes";
    i_file_name_to_get_checksum_for         = "V2016293000000.L2_SNPP_SST.nc";
    i_checksum_value                        = "11809b45a7f18d43314023b54f3309217a0b5678_added";

    print("User should run the below command if the unit test run with the following errorg message:'File does not exist', and run the unit test again.");
    print("");
    print("cp $OBPG_RUNENV_RESOURCES_HOME/" + i_file_name_to_get_checksum_for + " " + i_temporary_location_of_downloaded_file);
    print("");

    # We need to initialize our global variables with the init() function.
    settings.init();

    o_download_and_move_status = perform_checksum_check_and_move(i_final_location_of_downloaded_file,
                                                                 i_temporary_location_of_downloaded_file,
                                                                 i_perform_checksum_flag,
                                                                 i_file_name_to_get_checksum_for,
                                                                 i_checksum_value);
    exit(0);