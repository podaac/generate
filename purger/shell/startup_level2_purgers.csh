#!/bin/csh
#
# This is the C-shell wrapper to execute the script to purge files in the 
# holding tank older than a number of minutes or in the scratch directory that
# contains downloaded files older than a number of days. 
#
# It will usually be ran as part of a cronjob.
# The log files created will be in directory $SCRATCH/logs with the extension 
# .log.

# Set the environments.
source /app/config/purger_config

# Get the input.
if ($# < 3) then
    echo "startup_level2_holding_tank_purger:ERROR, You must specify at least 3 arguments: purge_op_type num_time_units perform_disk_space_count_only"
    echo "USAGE:"
    echo ""
    echo "If wish to actually remove files older than 60 minutes from the holding tank:"
    echo ""
    echo "       source startup_level2_holding_tank_purger.csh holding 60 no SST"
    echo ""
    echo "If wish to perform disk space count only for the holding tank:"
    echo ""
    echo "       source startup_level2_holding_tank_purger.csh holding 60 yes LAC"
    echo ""
    echo "If wish to actually remove files older than 7 days from the downloaded files:"
    echo ""
    echo "       source startup_level2_holding_tank_purger.csh downloaded 7 yes"
    exit
endif

# Arguments:
#
#  1 = purge_op_type (Type of purge operation: 'holding' or 'downloaded')
#  2 = num_time_units (Either in minutes for holding or days for downloaded)
#  3 = perform_disk_space_count_only (If set to yes, will only do disk space count, no removal)
#  4 = purge_name_pattern (Required only for 'holding': '*L2.SST*' or ' *LAC*' when purging the holding tank)
set i_purge_op_type = $1
set i_num_time_units    = $2
set i_perform_disk_space_count_only = "no"
set i_perform_disk_space_count_only = $3 
set noglob on
set i_purge_name_pattern = $4
set noglob off

# Create the logs directory if it does not exist yet
set logging_dir = `printenv | grep PURGER_LOGGING | awk -F= '{print $2}'`    # NET edit.
if (! -e $logging_dir) then    # NET edit.
    mkdir $logging_dir    # NET edit.
endif
set log_top_level_directory = $logging_dir     # NET edit.

set today_date = `date '+%m_%d_%y'`
if ($i_purge_op_type == "holding") then

    # Set log name
    set log_name = "$log_top_level_directory/modis_level2_holding_tank_purger_output_${today_date}.log"
    touch $log_name

    # Set environment variable
    setenv FILE_PURGE_NAME_PATTERN $i_purge_name_pattern

    # Purge the holding tank files 
    perl $GHRSST_PERL_LIB_DIRECTORY/purge_l2_holding_tank.pl $i_num_time_units $i_perform_disk_space_count_only >> $log_name
    echo "Output has been sent to $log_name"

else

    # Purge the MODIS_A AQUA_QUICKLOOK
    set i_data_source = "MODIS_A"
    set i_processing_type = "AQUA_QUICKLOOK"
    set log_name = "$log_top_level_directory/modis_level2_purger_${i_data_source}_${i_processing_type}_output_${today_date}.log"
    touch $log_name
    perl $GHRSST_PERL_LIB_DIRECTORY/purge_l2_temporary_files.pl $i_data_source $i_processing_type $i_num_time_units $i_perform_disk_space_count_only >> $log_name
    echo "Output has been sent to $log_name"

    # Purge the MODIS_A AQUA_REFINED
    set i_data_source = "MODIS_A"
    set i_processing_type = "AQUA_REFINED"
    set log_name = "$log_top_level_directory/modis_level2_purger_${i_data_source}_${i_processing_type}_output_${today_date}.log"
    touch $log_name
    perl $GHRSST_PERL_LIB_DIRECTORY/purge_l2_temporary_files.pl $i_data_source $i_processing_type $i_num_time_units $i_perform_disk_space_count_only >> $log_name
    echo "Output has been sent to $log_name"

    # Purge the MODIS_T TERRA_QUICKLOOK
    set i_data_source = "MODIS_T"
    set i_processing_type = "TERRA_QUICKLOOK"
    set log_name = "$log_top_level_directory/modis_level2_purger_${i_data_source}_${i_processing_type}_output_${today_date}.log"
    touch $log_name
    perl $GHRSST_PERL_LIB_DIRECTORY/purge_l2_temporary_files.pl $i_data_source $i_processing_type $i_num_time_units $i_perform_disk_space_count_only >> $log_name
    echo "Output has been sent to $log_name"

    # Purge the MODIS_T TERRA_REFINED
    set i_data_source = "MODIS_T"
    set i_processing_type = "TERRA_REFINED"
    set log_name = "$log_top_level_directory/modis_level2_purger_${i_data_source}_${i_processing_type}_output_${today_date}.log"
    touch $log_name
    perl $GHRSST_PERL_LIB_DIRECTORY/purge_l2_temporary_files.pl $i_data_source $i_processing_type $i_num_time_units $i_perform_disk_space_count_only >> $log_name
    echo "Output has been sent to $log_name"

    # Purge the VIIRS VIIRS_QUICKLOOK
    set i_data_source = "VIIRS"
    set i_processing_type = "VIIRS_QUICKLOOK"
    set log_name = "$log_top_level_directory/viirs_level2_purger_${i_data_source}_${i_processing_type}_output_${today_date}.log"
    touch $log_name
    perl $GHRSST_PERL_LIB_DIRECTORY/purge_l2_temporary_files.pl $i_data_source $i_processing_type $i_num_time_units $i_perform_disk_space_count_only >> $log_name
    echo "Output has been sent to $log_name"

    # Purge the VIIRS VIIRS_REFINED
    set i_data_source = "VIIRS"
    set i_processing_type = "VIIRS_REFINED"
    set log_name = "$log_top_level_directory/viirs_level2_purger_${i_data_source}_${i_processing_type}_output_${today_date}.log"
    touch $log_name
    perl $GHRSST_PERL_LIB_DIRECTORY/purge_l2_temporary_files.pl $i_data_source $i_processing_type $i_num_time_units $i_perform_disk_space_count_only >> $log_name
    echo "Output has been sent to $log_name"

endif

exit
