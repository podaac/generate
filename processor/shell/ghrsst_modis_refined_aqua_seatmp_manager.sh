#!/bin/csh
#  Copyright 2007, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id: ghrsst_modis_refined_aqua_seatmp_manager.sh,v 1.7 2007/11/14 00:04:34 qchau Exp $
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM
#
# C-shell script to start the Refined MODIS Aqua processing script.

#setenv TASKDL2_DIR /usr/depot/cots/redhat/taskdl/2.0.0
#setenv TASKDL2_DIR /usr/depot/cots/redhat/taskdl/taskdl-jpl
#setenv HOST seaworld.jpl.nasa.gov

source $HOME/generate/workspace/generate/processor/config/processor_config

# # *** COMMENTING OUT FOR TESTING AS SFTP IS NOT NEEDED *** # #
# # Make sure the machine we will be pushing the L2P to is alive and well.  Exit if machine is down.
# # Split the environment SEND_MODIS_L2P_SFTP_AUTHENTICATION_INFO with the equal sign, then further split by the @ symbol in the 
# # value 'gftpin@seatide.jpl.nasa.gov' to get access to the host name.
# #
# # % printenv | grep SEND_MODIS_L2P_SFTP_AUTHENTICATION_INFO
# # SEND_MODIS_L2P_SFTP_AUTHENTICATION_INFO=gftpin@seatide.jpl.nasa.gov
# #

# set host_to_ping = `printenv | grep SEND_MODIS_L2P_SFTP_AUTHENTICATION_INFO | awk '{split ($0,a,"="); print a[2]}' | awk '{split ($0,b,"@"); print b[2]}'`
# echo "host_to_ping [$host_to_ping]"

# source $GHRSST_PERL_LIB_DIRECTORY/pinger.csh $host_to_ping $OPS_MODIS_MONITOR_EMAIL_LIST

# # The exit status of the previous command will be 1 if machine is down.  We exit.

# if ($status == 1) then
#    echo "Something is wrong.  Status of $GHRSST_PERL_LIB_DIRECTORY/pinger.csh is [$status].  Must exit."
#    exit 1
# endif

# Continue as normal.

# The touch command is to create a log file if one does not exist already.
# The >> re-direction of the perl script below requires that the file exist.

touch $PROCESSOR_LOGGING/my_crontab_log_from_ghrsst_modis_refined_aqua_seatmp_manager

perl $GHRSST_PERL_LIB_DIRECTORY/ghrsst_modis_refined_aqua_seatmp_manager.pl 100 yes >> $HOME/my_crontab_log_from_ghrsst_modis_refined_aqua_seatmp_manager   # NET Edit. (Added perl binary)
