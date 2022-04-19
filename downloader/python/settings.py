#  Copyright 2017, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Global settings for the generic downloader.

import os;

from generic_downloader_job_manager import *;

def init():
    global g_gdjm;
    g_gdjm = generic_downloader_job_manager();

    global g_use_file_locking_mechanism_flag;
    g_use_file_locking_mechanism_flag = 1;  # Set to 1 to use the file locking mechanism.  This prevent two processes from acting on the same file.
    #g_use_file_locking_mechanism_flag = 0;  # Set to 0 to not use the file locking mechanism.  We don't care about two process clobbing same file.
    # If the user explicitly does not want to use file locking, we can disable it.
    if (os.getenv("CRAWLER_SEARCH_FILE_LOCKING_MECHANISM_FLAG","") != ""):
        if (os.getenv("CRAWLER_SEARCH_FILE_LOCKING_MECHANISM_FLAG","") == "false"):
            g_use_file_locking_mechanism_flag = 0;  # Set to 0 to not use the file locking mechanism.