ZZUTZOSV ;KRM/CJE - ZOSV2 unit tests ;2016-01-16  12:48 PM; 3/14/14 3:53P
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
 ;
OSOUT ; @TEST Test Call Out to OS to get hostname via GETUCI^%ZOSV
 N HOSTNAME
 O "/etc/hostname":readonly U "/etc/hostname" R HOSTNAME:0 C "/etc/hostname"
 N Y D GETENV^%ZOSV
 D CHKEQ^%ut($P(Y,"^",3),HOSTNAME)
 QUIT
 ;
OS ; @TEST OS
 D CHKEQ^%ut($$OS^%ZOSV(),"UNIX")
 QUIT
 ;
VERSION ; @TEST VERSION
 N V0 S V0=$$VERSION^%ZOSV(0)
 N OS S OS=$$VERSION^%ZOSV(1)
 D CHKTF^%ut(V0,"Must be positive")
 D CHKTF^%ut($L(V0,"-")=2,"Must be in xx.xxxx")
 D CHKTF^%ut(OS["nux"!(OS["nix")!(OS["BSD"))
 QUIT
 ;
PARSIZ ; @TEST PARSIZE NOOP
 N X
 D PARSIZ^%ZOSV
 D SUCCEED^%ut
 QUIT
NOLOG ; @TEST NOLOG NOOP
 N Y
 D PARSIZ^%ZOSV
 D SUCCEED^%ut
 QUIT
 ;
SHARELIC ; @TEST SHARELIC NOOP
 D SHARELIC^%ZOSV()
 D SUCCEED^%ut
 QUIT
 ;
PRIORITY ; @TEST PRIORITY NOOP
 D PRIORITY^%ZOSV
 D SUCCEED^%ut
 QUIT
 ;
PRIINQ ; @TEST PRIINQ() NOOP
 N % S %=$$PRIINQ^%ZOSV()
 D SUCCEED^%ut
 QUIT
 ;
BAUD ; @TEST BAUD NOOP
 N X D BAUD^%ZOSV
 D SUCCEED^%ut
 S X="UNKNOWN"
 QUIT
 ;
LGR ; @TEST Last Global Reference
 S ^TMP($J)=""
 I ^TMP($J)
 N R S R=$$LGR^%ZOSV()
 D CHKEQ^%ut(R,$NA(^TMP($J)))
 K ^TMP($J)
 QUIT
 ;
EC ; @TEST $$EC
 N A,%
 N $ET S $ET="S A=$$EC^%ZOSV,$EC="""" G EC1"
 S %=1/0
EC1 ;
 D CHKTF^%ut(A["divide")
 QUIT
 ;
ZTMGRSET ; @TEST ZTMGRSET Renames Routines on GT.M
 ;ZEXCEPT: shell
 N %ZR
 N RTNFS S RTNFS="_ZTLOAD1.o"
 D SILENT^%RSEL("%ZTLOAD1","OBJ")
 N FILE S FILE=%ZR("%ZTLOAD1")_RTNFS
 N COMM S COMM="stat -c %X "_FILE
 O "P":(shell="/bin/sh":comm=COMM)::"pipe"
 U "P" N %Y R %Y:1 C "P"
 N ZTOS S ZTOS=$$OSNUM^ZTMGRSET()
 N SCR S SCR="I 0"
 N ZTMODE S ZTMODE=2
 N IOP S IOP="NULL" D ^%ZIS U IO
 D DOIT^ZTMGRSET
 D ^%ZISC
 D SILENT^%RSEL("%ZTLOAD1","OBJ")
 N FILE S FILE=%ZR("%ZTLOAD1")_RTNFS
 N COMM S COMM="stat -c %X "_FILE
 O "P":(shell="/bin/sh":comm=COMM)::"pipe"
 U "P" N %YY R %YY:1 C "P"
 D CHKTF^%ut(%YY'<%Y)
 QUIT
ZHOROLOG ; @TEST $ZHOROLOG Functions
 Q:$$VERSION^%ZOSV<6.3
 N %ZH0,%ZH1,%ZH2
 D T0^%ZOSV
 D CHKTF^%ut(%ZH0)
 D CHKTF^%ut($L(%ZH0,",")=4)
 D T1^%ZOSV
 D CHKTF^%ut(%ZH1)
 D CHKTF^%ut($L(%ZH1,",")=4)
 D ZHDIF^%ZOSV
 D CHKTF^%ut(%ZH2<.001,"%ZH2 is "_%ZH2)
 QUIT
STRIPCR ; @TEST Strip CR
 N %ZR
 D SILENT^%RSEL("ZTLOAD1","SRC")
 D STRIPCR^ZOSVGUX(%ZR("ZTLOAD1"))
 D SUCCEED^%ut
 QUIT
 ;
TEMP ; @TEST getting temp directory
 N TMP S TMP=$$TEMP^%ZOSV()
 N FN S FN=TMP_"/test.txt"
 O FN:newvesrion
 U FN
 W "TEST",!
 C FN:delete
 D SUCCEED^%ut
 QUIT
 ;
PASS ; @TEST PASTHRU and NOPASS
 D PASSALL^%ZOSV
 D NOPASS^%ZOSV
 D SUCCEED^%ut
 QUIT
 ;
NSLOOKUP ; @TEST Test DNS Utilities
 ; REVERSE DNS
 N % S %=$$HOST^XLFNSLK("208.67.220.220")
 D CHKTF^%ut(%["opendns")
 N % S %=$$HOST^XLFNSLK("2607:F8B0:400D:0C01:0000:0000:0000:0066")
 D CHKTF^%ut(%["1e100")
 N % S %=$$HOST^XLFNSLK("")
 D SUCCEED^%ut
 N % S %=$$HOST^XLFNSLK("93.184.216.34") ; example.com doesn't have reverse dns
 D CHKTF^%ut(%="")
 ;
 ; FORWARD DNS
 N IPV6 S IPV6=$$VERSION^XLFIPV
 I IPV6 D CHKEQ^%ut($$ADDRESS^XLFNSLK("localhost"),"0000:0000:0000:0000:0000:0000:0000:0001") I 1
 E  D CHKEQ^%ut($$ADDRESS^XLFNSLK("localhost"),"127.0.0.1")
 D CHKEQ^%ut($$ADDRESS^XLFNSLK("localhost","A"),"127.0.0.1")
 D CHKEQ^%ut($$ADDRESS^XLFNSLK("localhost","AAAA"),"0000:0000:0000:0000:0000:0000:0000:0001")
 QUIT
 ;
IPV6 ; @TEST Test GT.M support for IPV6
 D CHKEQ^%ut($$VERSION^XLFIPV(),1)
 QUIT
