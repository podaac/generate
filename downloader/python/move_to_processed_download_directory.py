#  Copyright 2017, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

import os
import time
from time import strftime, gmtime

from mkdir_with_error_handling     import mkdir_with_error_handling;
from file_move_with_error_handling import file_move_with_error_handling;
from get_local_time                import get_local_pdt_time;
from log_this                      import log_this;
from raise_sigevent_wrapper        import raise_sigevent_wrapper;

#------------------------------------------------------------------------------------------------------------------------
# After a file list has been processed, we move the file to a directory "processed_download_filelist" for safe keeping for a few weeks.
#   
# Note:  Another script should be ran against the downloaded file list since we don't want to keep them around
#        for too long.
#
# Assumption(s):
#
#   1.  The processed download file list is a sub directory in scratch area with the name processed_download_filelist.

def move_to_processed_download_directory(i_processing_type,
                                         i_filename_to_move,
                                         i_scratch_area,
                                         i_today_date):

    g_routine_name = "move_to_processed_download_directory";
    debug_module = "move_to_processed_download_directory:";
    debug_mode   = 1;

    o_status_move = 1;  # Returns 1 if success and 0 if failed.

    if ((os.path.isfile(i_filename_to_move)) and (os.path.exists(i_filename_to_move))):
          # Get the parent directory name, and the file name only.
          parent_directory_name = os.path.dirname(i_filename_to_move);
          name_only             = os.path.basename(i_filename_to_move);

          # The processed download file list directory name is in scratch area.

          processed_download_directory_name = i_scratch_area + "/processed_download_filelist";

          #  Create top level directory.
          if (not os.path.isdir(i_scratch_area)):
              print("mkdir " + i_scratch_area);
              status_mkdir = mkdir_with_error_handling(i_scratch_area);
              # The mkdir function returns true if successful and false if failed.
              if (status_mkdir == 0): return(0);

          # Create the directory if it does not exist.
          if (not os.path.isdir(processed_download_directory_name)):
              print("mkdir " + processed_download_directory_name);
              status_mkdir = mkdir_with_error_handling(processed_download_directory_name);
              if (status_mkdir == 0): return(0); 

          # Get the current year and day of year and create the subdirectory if it does not already exist, i.e. 2015/192 for August 11, 2015.
          localtime = get_local_pdt_time();
          this_year   = str(localtime.tm_year);
          day_of_year = str("%03d" % localtime.tm_yday);

          processed_download_directory_name = processed_download_directory_name + "/" + i_processing_type;
          # Create the directory if it does not exist.
          if (not os.path.isdir(processed_download_directory_name)):
              print("mkdir " + processed_download_directory_name);
              status_mkdir = mkdir_with_error_handling(processed_download_directory_name);
              if (status_mkdir == 0): return(0);

          processed_download_directory_name = processed_download_directory_name + "/" + this_year;
          # Create the directory if it does not exist.
          if (not os.path.isdir(processed_download_directory_name)):
              print("mkdir " + processed_download_directory_name);
              status_mkdir = mkdir_with_error_handling(processed_download_directory_name);
              if (status_mkdir == 0): return(0);

          processed_download_directory_name = processed_download_directory_name + "/" + day_of_year;
          # Create the directory if it does not exist.
          if (not os.path.isdir(processed_download_directory_name)):
              print("mkdir " + processed_download_directory_name);
              status_mkdir = mkdir_with_error_handling(processed_download_directory_name);
              if (status_mkdir == 0): return(0);

          # Add the unique directory so the file doesn't get overwritten.
          processed_download_directory_name = processed_download_directory_name + "/" + i_today_date;

          # Create the directory if it does not exist.
          if (not os.path.isdir(processed_download_directory_name)):
              print("mkdir " + processed_download_directory_name);
              status_mkdir = mkdir_with_error_handling(processed_download_directory_name);
              if (status_mkdir == 0): return(0);

          destination_name = processed_download_directory_name +  "/" + name_only;

          log_this("INFO",g_routine_name,"FILE_MOVE_DOWNLOAD_INPUT_FILE " + i_filename_to_move + " " + destination_name);

          print("file_move_with_error_handling");
          o_status_move = file_move_with_error_handling(i_filename_to_move,destination_name);
    else:
        # The filelist to move does not exist, report the error and return.
        o_status_move = 0;

        sigevent_type     = 'ERROR'
        sigevent_description = "FILE_MOVE_FAILED_FILE_DOES_NOT_EXIST " + i_filename_to_move;
        sigevent_category = 'UNCATEGORIZED'
        sigevent_data        = "";
        sigevent_debug_flag  = None;

        print(debug_module + sigevent_description);
        log_this("ERROR",g_routine_name,sigevent_description);

        raise_sigevent_wrapper(sigevent_type,
                               sigevent_category,
                               sigevent_description,
                               sigevent_data,
                               sigevent_debug_flag);

    return(o_status_move);

def get_today_date():
    # Return today's date in 11_20_14_11_25
    #                        mm_dd_yy_hh_mm
    o_today_date = ""

    # Get the current year and day of year and create the subdirectory if it does not already exist, i.e. 2015/192 for August 11, 2015.
    os.environ["TZ"]="US/Pacific"
    time.tzset();
    localtime = time.localtime(time.time())
    this_year   = str(localtime.tm_year)[-2:];
    this_month  = str("%02d" % localtime.tm_mon);
    this_day    = str("%02d" % localtime.tm_mday);
    this_hour   = str("%02d" % localtime.tm_hour);
    this_minute = str("%02d" % localtime.tm_min);
    this_second = str("%02d" % localtime.tm_sec);

    o_today_date = this_year + "_" + this_month + "_" + this_day + "_" + this_hour + "_" + this_minute + "_" + this_second; 
    return(o_today_date);

import subprocess

if __name__ == "__main__":

    # Testing moving VIIRS downloadlist.
    i_processing_type  = 'VIIRS';
    i_filename_to_move = 'this_file.txt';
    i_scratch_area     = os.getenv('SCRATCH_AREA','');
    i_today_date       = get_today_date();
    print("i_today_date",i_today_date);

    subprocess.call(["touch",i_filename_to_move]);

    o_status_move = move_to_processed_download_directory(i_processing_type,
                                                         i_filename_to_move,
                                                         i_scratch_area,
                                                         i_today_date);
    exit(0);


    # Testing moving MODIS_A downloadlist.
    i_processing_type  = 'MODIS_A';
    i_filename_to_move = 'this_file.txt';
    i_scratch_area     = os.getenv('SCRATCH_AREA','');
    i_today_date       = get_today_date();
    print("i_today_date",i_today_date);

    subprocess.call(["touch",i_filename_to_move]);

    o_status_move = move_to_processed_download_directory(i_processing_type,
                                                         i_filename_to_move,
                                                         i_scratch_area,
                                                         i_today_date);

    # Testing moving MODIS_T downloadlist.
    i_processing_type  = 'MODIS_T';
    i_filename_to_move = 'this_file.txt';
    i_scratch_area     = os.getenv('SCRATCH_AREA','');
    i_today_date       = get_today_date();
    print("i_today_date",i_today_date);

    subprocess.call(["touch",i_filename_to_move]);

    o_status_move = move_to_processed_download_directory(i_processing_type,
                                                         i_filename_to_move,
                                                         i_scratch_area,
                                                         i_today_date);

    # Testing moving AQUARIUS downloadlist.
    i_processing_type  = 'AQUARIUS';
    i_filename_to_move = 'this_file.txt';
    i_scratch_area     = os.getenv('SCRATCH_AREA','');
    i_today_date       = get_today_date();
    print("i_today_date",i_today_date);

    subprocess.call(["touch",i_filename_to_move]);

    o_status_move = move_to_processed_download_directory(i_processing_type,
                                                         i_filename_to_move,
                                                         i_scratch_area,
                                                         i_today_date);
