;  Copyright 2005, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; $Id: get_seconds_since_1981.pro,v 1.1.1.1 2006/04/25 19:15:39 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
; New Request #xxxx

FUNCTION get_seconds_since_1981,$
    i_year,$
    i_doy,$
    i_hour,$
    i_minute,$
    i_second,$
    r_seconds_since_1981

;
; Function calculate seconds since 1981 given a date.
;
; From http://mathforum.org/library/drmath/view/61035.html

;It's more complicated than that; you have to take leap _seconds_ into 
;account as well. (Every so often, we have to add or subtract a second 
;to account for changes in the earth's rotational period.)  
;
;But basically, the conversion looks like this:
;
;  seconds past 1980 =   (days since 1 Jan 1980) * 86400
;                      + (hours since midnight) * 3600
;                      + (minutes past the hour) * 60
;                      + (seconds past the minute)
;                      + (leap seconds)
;
;To find the number of days, you can do this:
;
;  days since 1 Jan 1980 =    (current year - 1980) * 365
;
;                           + (current day of year - 1)
;
;                           + (1 leap day for 
;                              1980, 1984, 1988, 1992, 1996, 
;                              2000, 2004, and any other 
;                              leap years that have passed)  
;
;Here is a table, through 1999, of the leap seconds accumulated by 
;date:
;
;  Leap seconds      Date
;  ------------    ----------
;      19          1980-JAN-1
;      20          1981-JUL-1
;      21          1982-JUL-1
;      22          1983-JUL-1
;      23          1985-JUL-1
;      24          1988-JAN-1
;      25          1990-JAN-1
;      26          1991-JAN-1
;      27          1992-JUL-1
;      28          1993-JUL-1
;      29          1994-JUL-1
;      30          1996-JAN-1
;      31          1997-JUL-1
;      32          1999-JAN-1
;      33          2006-JAN-1
;      34          2009-JAN-1

;------------------------------------------------------------------------------------------------

; Load constants.

@data_const_config.cfg

; Define local variables.

status = SUCCESS;

; Some pertinents info regarding leap years.
; Set the correct accumulated second based on i_year
if (i_year GE 1999) then begin
    accummulated_leap_seconds = 32L;
endif

if (i_year GE 2006) then begin
    accummulated_leap_seconds = 33L;
endif

if (i_year GE 2009) then begin
    accummulated_leap_seconds = 34L;
endif

; Set the correct number of leap days (years) since 1981  for i_year

if (i_year GE 1997)  then begin
    leap_years_array = [1984, 1988, 1992, 1996];  4 leap days if between 1985 and 2000 inclusive.
endif

if (i_year GE 2001)  then begin
    leap_years_array = [1984, 1988, 1992, 1996, 2000];  5 leap days if between 1985 and 2004 inclusive.
endif

if (i_year GE 2005) then begin
    leap_years_array = [1984, 1988, 1992, 1996, 2000, 2004];  6 leap days if between 1985 and 2008 inclusive.
endif

if (i_year GE 2009) then begin
    leap_years_array = [1984, 1988, 1992, 1996, 2000, 2004, 2008]; 7 leap days if between 1985 and 2012 inclusive
endif

if ((i_year GE 2013) && (i_year LE 2016)) then begin
    leap_years_array = [1984, 1988, 1992, 1996, 2000, 2004, 2008, 2012]; 8 leap days if between 1985 and 2016 inclusive.
endif

num_leap_days_since_1984 = LONG(size(leap_years_array,/N_ELEMENTS));

; Calculate the number of days since 1981.

days_since_jan_01_1981 =  (i_year - 1981L) * 365L  $ 
                         +(i_doy - 1L) $
                         + num_leap_days_since_1984;


; Calculate the number of seconds since 1981
                 
r_seconds_since_1981 = days_since_jan_01_1981 * 86400L    $
                     + (i_hour               * 3600L  )  $
                     + (i_minute             * 60L    )  $
                     + (i_second                     )  $
                     + accummulated_leap_seconds;

; ---------- Close up shop ----------
;

return, status;
end
