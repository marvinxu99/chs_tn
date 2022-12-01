DROP PROGRAM ccl_parameter_exam2 GO
CREATE PROGRAM ccl_parameter_exam2
DECLARE par = c20
SET lnum = 0
SET num=1
SET cnt = 0
SET cnt2 = 0
WHILE (num>0)
	SET par = reflect(parameter(num,0))
	IF (par = " ")
	;no more parameters
		SET cnt = num-1
		SET num = 0
	ELSE
	;valid parameter
		IF (substring(1,1,par) = "L") ;this is list type
			CALL ECHO(build("$(",num,")",par))
			SET lnum = 1
			WHILE (lnum>0)
				SET par = reflect(parameter(num,lnum))
				IF (par = " ")
					;no more items in list for parameter
					SET cnt2 = lnum-1
					SET lnum = 0
				ELSE
					;valid item in list for parameter
					CALL ECHO(build("$(",num,".",lnum,")",par,"=",parameter(num,lnum)))
					SET lnum = lnum+1
				ENDIF
			ENDWHILE
		ELSE
			CALL ECHO(build("$(",num,")",par,"=",parameter(num,lnum)))
		ENDIF
		SET num = num+1
	ENDIF
ENDWHILE
CALL ECHO(build("num param=",cnt))
END GO
