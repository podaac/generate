;  Copyright 2005, by the California Institute of Technology.  ALL RIGHTS
;  RESERVED. United States Government Sponsorship acknowledged. Any commercial
;  use must be negotiated with the Office of Technology Transfer at the
;  California Institute of Technology.
;
; 21 Sep 00	e.armstrong	JPL/Caltech/NASA
; Calculate the calendar day from year day. 
; Inputs are year and yearday. Outputs are month_string, 
; month (numeric), and day.
;
; SYNOPSIS:
; Calculates the calendar day of year.  Determines if leap year by 
; checking the modulus of year divided by 4, 100, and 400.
;
; $Id: calday.pro,v 1.1 2006/06/01 21:08:22 qchau Exp $
; DO NOT EDIT THE LINE ABOVE - IT IS AUTOMATICALLY GENERATED BY CVS
; New Request #xxxx

FUNCTION calday, year, yearday, month_string, month, monthday

    status = 0;
    daytab = intarr(12,2)
    daytab = [ $
    [ 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365 ], $
    [ 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366 ]  $
    ];

    month_string_tab = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", $
    			 "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
    month_tab = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ]

    leap = 0
    ; determine if leap year 
    IF (year MOD 4 eq 0 AND year MOD 100 ne 0) OR year MOD 400 eq 0 THEN leap = 1

    ; error check 
    IF yearday GT daytab[11, leap] OR yearday lt 1 THEN BEGIN
	print,  "year day must be >1 and <", daytab[11, leap];
	stop
    ENDIF

    FOR i=0,11 DO BEGIN
        IF yearday le daytab[i, leap] THEN BEGIN
            month = month_tab[i]
            month_string = month_string_tab[i]
            goto, GOT_MONTH
        ENDIF
    ENDFOR

    GOT_MONTH:

    IF month_string eq "Jan" THEN BEGIN 
	monthday = yearday
    ENDIF ELSE BEGIN
        monthday = yearday - daytab[i-1, leap] 
    ENDELSE

    ;print, " year is ", year
    ;print, " month is ", month_string
    ;print, " month number is ",  month
    ;print, " month day is ", monthday
return, status
END
