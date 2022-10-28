#/usr/local/bin/perl
#  Copyright 2012, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

$GHRSST_PERL_LIB_DIRECTORY = $ENV{GHRSST_PERL_LIB_DIRECTORY};

do "$GHRSST_PERL_LIB_DIRECTORY/log_this.pl";

#------------------------------------------------------------------------------------------------------------------------
sub delete_job {
    # Remove a running job by removing the file representing the job from disk.
    # If no job exist, we can't delete it.  Just report the status as 0.
    # We assume the name has a certain format.

    my $i_function_name   = shift;
    my $i_processing_type = shift;
    my $job_name = shift;

    my $o_job_delete_status = 1;  # If cannot delete job, return 0.

    if (-e $job_name) {
        # If job exists, remove it by removing the file.

        my @line_result = readpipe("cat $job_name");
        my $num_lines = scalar(@line_result);
        my $process_id_from_file = "";

        if ($num_lines > 0) {
            my @splitted_tokens   = split(' ',$line_result[0]);
            my $function_name     = $splitted_tokens[0];
            $process_id_from_file = $splitted_tokens[1];
        }

        unlink($job_name);
        my $now_is = localtime;
        print $now_is . " INFO " . "[$i_function_name] REGISTERED_JOB_END $process_id_from_file $job_name\n";
    } else {
        my $now_is = localtime;
        print $now_is . " WARN " . "[$i_function_name] No job $job_name exist.\n";
        $o_job_delete_status = 0;  # If cannot delete job, return 0.
    }

    return ($o_job_delete_status);
}
