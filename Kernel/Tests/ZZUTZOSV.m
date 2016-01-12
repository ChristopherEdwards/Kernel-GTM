ZZUTZOSV ;KRM/CJE - ZOSV2 unit tests ;2016-01-11  5:52 PM; 3/14/14 3:53P
 ;;1.0;UNIT TEST;;Aug 28, 2013;Build 1
 ; makes it easy to run tests simply by running this routine and
 ; insures that %ut will be run only where it is present
 I $T(EN^%ut)'="" D EN^%ut("ZZUTZOSV",2)
 Q
 ;
ZRO1 ; @TEST $ZROUTINES Parsing Single Object Multiple dirs
 N ZR S ZR="o(p r) /var/abc(/var/abc/r/) /abc/def $gtm_dist/libgtmutl.so vista.so"
 N DIRS D PARSEZRO^%ZOSV(.DIRS,ZR)
 N FIRSTDIR S FIRSTDIR=$$ZRO1ST^%ZOSV(.DIRS)
 D CHKEQ^%ut(FIRSTDIR,"p/")
 QUIT
 ;
ZRO2 ; @TEST $ZROUTINES Parsing 2 Single Object Single dir
 N ZR S ZR="/var/abc(/var/abc/r/) o(p r) /abc/def $gtm_dist/libgtmutl.so vista.so"
 N DIRS D PARSEZRO^%ZOSV(.DIRS,ZR)
 N FIRSTDIR S FIRSTDIR=$$ZRO1ST^%ZOSV(.DIRS)
 D CHKEQ^%ut(FIRSTDIR,"/var/abc/r/")
 QUIT
 ;
ZRO3 ; @TEST $ZROUTINES Parsing Shared Object/Code dir
 N ZR S ZR="/abc/def /var/abc(/var/abc/r/) o(p r) $gtm_dist/libgtmutl.so vista.so"
 N DIRS D PARSEZRO^%ZOSV(.DIRS,ZR)
 N FIRSTDIR S FIRSTDIR=$$ZRO1ST^%ZOSV(.DIRS)
 D CHKEQ^%ut(FIRSTDIR,"/abc/def/")
 QUIT
 ;
ZRO4 ; @TEST $ZROUTINES Parsing Single Directory by itself
 N ZR S ZR="/home/osehra/r"
 N DIRS D PARSEZRO^%ZOSV(.DIRS,ZR)
 N FIRSTDIR S FIRSTDIR=$$ZRO1ST^%ZOSV(.DIRS)
 D CHKEQ^%ut(FIRSTDIR,"/home/osehra/r/")
 QUIT
 ;
ZRO5 ; @TEST $ZROUTINES Parsing Leading Space
 N ZR S ZR=" o(p r) /var/abc(/var/abc/r/) /abc/def $gtm_dist/libgtmutl.so vista.so"
 N DIRS D PARSEZRO^%ZOSV(.DIRS,ZR)
 N FIRSTDIR S FIRSTDIR=$$ZRO1ST^%ZOSV(.DIRS)
 D CHKEQ^%ut(FIRSTDIR,"p/")
 QUIT
 ;
 ;
ZRO7 ; @TEST $ZROUTINES Shared Object Only
 N ZR S ZR="/home/osehra/lib/gtm/libgtmutil.so"
 N DIRS D PARSEZRO^%ZOSV(.DIRS,ZR)
 N FIRSTDIR S FIRSTDIR=$$ZRO1ST^%ZOSV(.DIRS)
 D CHKEQ^%ut(FIRSTDIR,"")
 Q
 ;
ZRO8 ; @TEST $ZROUTINES No shared object
 N ZR S ZR="/home/osehra/r/V6.0-002_x86_64(/home/osehra/r) /home/osehra/lib/gtm"
 N DIRS D PARSEZRO^%ZOSV(.DIRS,ZR)
 N FIRSTDIR S FIRSTDIR=$$ZRO1ST^%ZOSV(.DIRS)
 D CHKEQ^%ut(FIRSTDIR,"/home/osehra/r/")
 Q
 ;
ZRO9 ; @TEST $ZROUTINES Shared Object First
 N ZR S ZR="/home/osehra/lib/gtm/libgtmutil.so /home/osehra/r/V6.0-002_x86_64(/home/osehra/r)"
 N DIRS D PARSEZRO^%ZOSV(.DIRS,ZR)
 N FIRSTDIR S FIRSTDIR=$$ZRO1ST^%ZOSV(.DIRS)
 D CHKEQ^%ut(FIRSTDIR,"/home/osehra/r/")
 Q
 ;
ZRO10 ; @TEST $ZROUTINES Shared Object First but multiple rtn dirs
 N ZR S ZR="/home/osehra/lib/gtm/libgtmutil.so /home/osehra/p/V6.0-002_x86_64(/home/osehra/p) /home/osehra/s/V6.0-002_x86_64(/home/osehra/s) /home/osehra/r/V6.0-002_x86_64(/home/osehra/r)"
 N DIRS D PARSEZRO^%ZOSV(.DIRS,ZR)
 N FIRSTDIR S FIRSTDIR=$$ZRO1ST^%ZOSV(.DIRS)
 D CHKEQ^%ut(FIRSTDIR,"/home/osehra/p/")
 Q
 ;
ZRO99 ; @TEST $$RTNDIR^%ZOSV Shouldn't be Empty
 N RTNDIR S RTNDIR=$$RTNDIR^%ZOSV
 D CHKTF^%ut(RTNDIR]"")
 QUIT
 ;
ACTJ ; @TEST Default path through ACTJ^ZOSV
 N JOBS,ACTJ
 ; Run the algorithm
 S ACTJ=$$ACTJ^%ZOSV
 D CHKTF^%ut(ACTJ>0,"$$ACTJ^%ZOSV didn't return the correct value")
 Q
 ;
ACTJ0 ; @TEST Force ^XUTL("XUSYS","CNT") to 0 to force algorithm to run
 N JOBS,ACTJ
 ; Read the global to get what the system thinks is the active jobs
 S JOBS=$G(^XUTL("XUSYS","CNT"))
 ; Force algorithm to run
 S ^XUTL("XUSYS","CNT")=0
 ; Run the algorithm
 S ACTJ=$$ACTJ^%ZOSV
 D CHKEQ^%ut(JOBS,ACTJ,"$$ACTJ^%ZOSV is out of sync with jobs on file")
 Q
 ;
DOLRO ; @TEST Ensure symbol table is saved correctly
 N TEST,X
 ; Will check for this variable and value in the open root
 S TEST="TEST1"
 ; DOLRO reads the variable X to figure put where to save the symbol table to
 S X="^TMP(""ZZUTZOSV"","
 ; Save the symbol table
 D DOLRO^%ZOSV
 D CHKEQ^%ut(^TMP("ZZUTZOSV","TEST"),"TEST1","DOLRO^%ZSOV Didn't save the correct variable value")
 ; Debug
 ; ZWR ^TMP("ZZUTZOSV",*)
 ; Kill test variable
 K ^TMP("ZZUTZOSV")
 Q
 ;
TMTRAN ; @TEST Make sure that Taskman is running
 I '$$TM^%ZTLOAD() D FAIL^%ut("Can't run this test. Taskman isn't running.") QUIT
 ;
 N ZTSK D Q^XUTMTZ
 D CHKTF^%ut(ZTSK)
 N TOTALWAIT S TOTALWAIT=0
 F  Q:'$D(^%ZTSK(ZTSK))  H .05 S TOTALWAIT=TOTALWAIT+.05 Q:TOTALWAIT>2
 D CHKTF^%ut(TOTALWAIT<2,"Taskman didn't process task")
 QUIT
