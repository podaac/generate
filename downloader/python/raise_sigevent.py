#  Copyright 2017, by the California Institute of Technology.  ALL RIGHTS
#  RESERVED. United States Government Sponsorship acknowledged. Any commercial
#  use must be negotiated with the Office of Technology Transfer at the
#  California Institute of Technology.
#
# $Id$
# DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CM

# Subroutine to report a sigevent to the sigevent manager.
#
# Assumption(s):
#
#    (1)  The URL to the sigevent manager is valid.
#    (2)  The sigevent description is limit to 255 characters.  Any string longer will be truncated.
#
# A return parameter o_status will be set to 1 if good, and -1 if bad.
#------------------------------------------------------------------------------------------------

import socket
import requests

def raise_sigevent(sigevent_url         , 
                   sigevent_provider    ,
                   sigevent_source      ,
                   sigevent_type        ,
                   sigevent_category    ,
                   sigevent_description ,
                   sigevent_data        ): 

    # Output parameter(s)

    o_status = 1;  # A value of 1 is good, -1 is bad.

    # Local variables.
    g_function_name = "raise_sigevent"; # This function name.
    debug_module    = "raise_sigevent:"; # This function name.

    sigevent_format      = 'TEXT';  # This is the default format of a a sigevent.  

    # Get the computer name this script is running on.

    host_name = socket.gethostname();
    sigevent_computer = host_name;

    # Do a sanity check on the description length.  Shorten it to length of 255 if it's too long.

    if (len(sigevent_description) > 255):
        original_description_length = len(sigevent_description);
        sigevent_description = sigevent_description[0:255];
        new_description_length = len(sigevent_description);
    # end if (len(sigevent_description) > 255):

    # Build the URL to make the rest service call.
    # Note that the strings "/sigevent/events/create?" are required to create a new sigevent.  This is the expected format to create a new sigevent.

    rest_service_call  = sigevent_url + '/sigevent/events/create?'          +        \
                                        'format='      + sigevent_format    + '&' +  \
                                        'type='        + sigevent_type      + '&' +  \
                                        'category='    + sigevent_category  + '&' +  \
                                        'source='      + sigevent_source    + '&' +  \
                                        'provider='    + sigevent_provider  + '&' +  \
                                        'computer='    + sigevent_computer  + '&' +  \
                                        'data="'       + sigevent_data      + '"' + '&' +  \
                                        'description=' + sigevent_description;

    print("rest_service_call [" + rest_service_call + "]");


    # Issue request, with an HTTP header.

    try:
        response = requests.put(rest_service_call);
        print("response",response);
    except requests.exceptions.ConnectionError:
        print(debug_module + "ERROR:Cannot make connection to sigevent manager " + sigevent_url);
        print(debug_module + "ERROR: rest_service_call [" + rest_service_call + "]");
        o_status = -1;  # A value of 1 is good, -1 is bad.
    except:
        print(debug_module + "ERROR:Encountered unexpected error to sigevent manager " + sigevent_url);
        print(debug_module + "ERROR: rest_service_call [" + rest_service_call + "]");
        o_status = -1;  # A value of 1 is good, -1 is bad.


    return(o_status);


if __name__ == "__main__":

    sigevent_url           = "http://seacastle.jpl.nasa.gov:9080";
    sigevent_provider      = "JPL";
    sigevent_source        = "GHRSST-PROCESSING";
    sigevent_type          = "INFO";
    sigevent_category      = 'GENERATE';
    sigevent_description   = "This is sigevent_description";
    sigevent_data          = "This is sigevent_data";

    raise_sigevent(sigevent_url         ,
                   sigevent_provider    ,
                   sigevent_source      ,
                   sigevent_type        ,
                   sigevent_category    ,
                   sigevent_description ,
                   sigevent_data        );
