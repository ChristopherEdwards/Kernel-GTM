ZZUTZOSV ;KRM/CJE - ZOSV2 unit tests ;11/18/2013 ; 3/14/14 3:53P
 ;;1.0;UNIT TEST;;Aug 28, 2013;Build 1
 ; makes it easy to run tests simply by running this routine and
 ; insures that XTMUNIT will be run only where it is present
 I $T(EN^XTMUNIT)'="" D EN^XTMUNIT("ZZUTZOSV")
 Q
 ;
STARTUP ; optional entry point
 ; if present executed before any other entry point any variables
 ; or other work that needs to be done for any or all tests in the
 ; routine.  This is run only once at the beginning.
 Q
 ;
SHUTDOWN ; optional entry point
 ; if present executed after all other processing is complete to remove
 ; any variables, or undo work done in STARTUP.
 Q
 ;
SETUP ; optional entry point
 ; if present it will be executed before each test entry to set up
 ; variables, etc.
 Q
 ;
TEARDOWN ; optional entry point
 ; if present it will be exceuted after each test entry to clean up
 ; variables, etc.
 Q
 ;
SIMPL; Simple $ZROUTINES (single routine dir) - NO shared object
 N OLDZRO,RTNDIR
 S OLDZRO=$ZRO
 S $ZRO="/home/osehra/r"
 S RTNDIR=$$RTNDIR^%ZOSV
 S $ZRO=OLDZRO
 D CHKEQ^XTMUNIT("/home/osehra/r/",RTNDIR,"$$RTNDIR^%ZOSV didn't return the correct value")
 Q
 ;
SHRONLY; $ZROUTINES - ONLY shared object
 N OLDZRO,RTNDIR
 S OLDZRO=$ZRO
 S $ZRO="/home/osehra/lib/gtm/libgtmutil.so"
 ; This only works because %ZOSV is already loaded into memory or it would fail
 S RTNDIR=$$RTNDIR^%ZOSV
 S $ZRO=OLDZRO
 D CHKEQ^XTMUNIT("",RTNDIR,"$$RTNDIR^%ZOSV didn't return the correct value")
 Q
 ;
NOSHR ; $ZROUTINES - No shared object
 N OLDZRO,RTNDIR
 S OLDZRO=$ZRO
 S $ZRO="/home/osehra/r/V6.0-002_x86_64(/home/osehra/r) /home/osehra/lib/gtm"
 S RTNDIR=$$RTNDIR^%ZOSV
 S $ZRO=OLDZRO
 D CHKEQ^XTMUNIT("/home/osehra/r/",RTNDIR,"$$RTNDIR^%ZOSV didn't return the correct value")
 Q
 ;
SHROBJ; $ZROUTINES - WITH shared object
 N OLDZRO,RTNDIR
 S OLDZRO=$ZRO
 S $ZRO="/home/osehra/lib/gtm/libgtmutil.so /home/osehra/r/V6.0-002_x86_64(/home/osehra/r)"
 S RTNDIR=$$RTNDIR^%ZOSV
 S $ZRO=OLDZRO
 D CHKEQ^XTMUNIT("/home/osehra/r/",RTNDIR,"$$RTNDIR^%ZOSV didn't return the correct value")
 Q
 ;
PSDIR ; $ZROUTINES (multiple directories) - WITH shared object
 N OLDZRO,RTNDIR
 S OLDZRO=$ZRO
 S $ZRO="/home/osehra/lib/gtm/libgtmutil.so /home/osehra/p/V6.0-002_x86_64(/home/osehra/p) /home/osehra/s/V6.0-002_x86_64(/home/osehra/s) /home/osehra/r/V6.0-002_x86_64(/home/osehra/r)"
 S RTNDIR=$$RTNDIR^%ZOSV
 S $ZRO=OLDZRO
 D CHKEQ^XTMUNIT("/home/osehra/p/",RTNDIR,"$$RTNDIR^%ZOSV didn't return the correct value")
 Q
 ;
ACTJ ; Default path through ACTJ^ZOSV
 N JOBS,ACTJ
 ; Read the global to get what the system thinks is the active jobs
 S JOBS=$G(^XUTL("XUSYS","CNT"))
 I 'JOBS D FAIL^XTMUNIT("System has no jobs on file. Can't test default path") Q
 ; Run the algorithm
 S ACTJ=$$ACTJ^%ZOSV
 D CHKEQ^XTMUNIT(JOBS,ACTJ,"$$ACTJ^%ZOSV didn't return the correct value")
 Q
 ;
ACTJ0 ; Force ^XUTL("XUSYS","CNT") to 0 to force algorithm to run
 N JOBS,ACTJ
 ; Read the global to get what the system thinks is the active jobs
 S JOBS=$G(^XUTL("XUSYS","CNT"))
 ; Force algorithm to run
 S ^XUTL("XUSYS","CNT")=0
 ; Run the algorithm
 S ACTJ=$$ACTJ^%ZOSV
 D CHKEQ^XTMUNIT(JOBS,ACTJ,"$$ACTJ^%ZOSV is out of sync with jobs on file")
 Q
 ;
DOLRO ; Ensure symbol table is saved correctly
 N TEST,X
 ; Will check for this variable and value in the open root
 S TEST="TEST1"
 ; DOLRO reads the variable X to figure put where to save the symbol table to
 S X="^TMP(""ZZUTZOSV"","
 ; Save the symbol table
 D DOLRO^%ZOSV
 D CHKEQ^XTMUNIT(^TMP("ZZUTZOSV","TEST"),"TEST1","DOLRO^%ZSOV Didn't save the correct variable value")
 ; Debug
 ZWR ^TMP("ZZUTZOSV",*)
 ; Kill test variable
 K ^TMP("ZZUTZOSV")
 Q
 ;
XTROU ;
 ;;
 ; Entry points for tests are specified as the third semi-colon piece,
 ; a description of what it tests is optional as the fourth semi-colon
 ; piece on a line. The first line without a third piece terminates the
 ; search for TAGs to be used as entry points
XTENT ;
 ;;SIMPL; Simple $ZROUTINES (single routine dir) - NO shared object
 ;;SHRONLY; $ZROUTINES - ONLY shared object
 ;;NOSHR; Simple $ZROUTINES (split objects and routines) - NO shared object
 ;;SHROBJ; Simple $ZROUTINES (split objects and routines) - WITH shared object
 ;;PSDIR; Medium $ZROUTINES (multiple directories) - WITH shared object
 ;;ACTJ; Ensure ACTJ returns value in global first
 ;;ACTJ0; Force ACTJ to determine number of jobs running
 ;;DOLRO; Ensure Symbol table is saved correctly
 Q
