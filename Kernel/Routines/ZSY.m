ZSY ;ISF/RWF,VEN/SMH - GT.M/VA system status display ;2018-01-08  9:38 PM
 ;;8.0;KERNEL;**349,10001,10002**;Jul 10, 1995;Build 11
 ; Submitted to OSEHRA in 2017 by Sam Habiel for OSEHRA
 ; Original Routine of unknown provenance -- was in unreleased VA patch XU*8.0*349 and thus perhaps in the public domain.
 ; Rewritten by KS Bhaskar and Sam Habiel 2005-2015
 ; Sam: JOBEXAM, WORK, USHOW, UNIX, UNIXLSOF, INTRPT, INTRPTALL, HALTALL, ZJOB
 ; Bhaskar provided pipe implementations of various commands.
 ;GT.M/VA %SY utility - status display
 ;
EN ; [Public] Main Entry Point
 ;From the top just show by PID
 N MODE
 L +^XUTL("XUSYS","COMMAND"):1 I '$T G LW
 S MODE=0 D WORK
 Q
 ;
QUERY ; [Public] Alternate Entry Point
 N MODE,X
 L +^XUTL("XUSYS","COMMAND"):1 I '$T G LW
 S X=$$ASK W ! I X=-1 L -^XUTL("XUSYS","COMMAND") Q
 S MODE=+X D WORK
 Q
 ;
ASK() ;Ask sort item
 ; ZEXCEPT: %utAnswer
 I $D(%utAnswer) Q %utAnswer
 N RES,X,GROUP
 S RES=0,GROUP=2
 W !,"1 pid",!,"2 cpu time"
 F  R !,"1// ",X:600 S:X="" X=1 Q:X["^"  Q:(X>0)&(X<3)  W " not valid"
 Q:X["^" -1
 S X=X-1,RES=(X#GROUP)_"~"_(X\GROUP)
 Q RES
 ;
 ;
JOBEXAM(%ZPOS) ; [Public; Called by ^ZU]
 ; Preserve old state for process
 N OLDIO S OLDIO=$IO
 N %reference S %reference=$REFERENCE
 ;
 ; Save these
 S ^XUTL("XUSYS",$J,0)=$H
 S ^XUTL("XUSYS",$J,"INTERRUPT")=$G(%ZPOS)
 S ^XUTL("XUSYS",$J,"ZMODE")=$ZMODE ; SMH - INTERACTIVE or OTHER
 I %ZPOS'["GTM$DMOD" S ^XUTL("XUSYS",$J,"codeline")=$T(@%ZPOS)
 K ^XUTL("XUSYS",$J,"JE")
 ;
 ; Halt the Job if requested
 I $G(^XUTL("XUSYS",$J,"CMD"))="HALT" D H2^XUSCLEAN G HALT^ZU
 ;
 ;
 ; Default System Status.
 ; S -> Stack
 ; D -> Devices
 ; G -> Global Stats
 I '$D(^XUTL("XUSYS",$J,"CMD")) ZSHOW "SGD":^XUTL("XUSYS",$J,"JE") ; Default case -- most of the time this is what happens.
 ;
 ; Examine the Job
 ; ZSHOW "*" is "BDGILRV"
 ; B is break points
 ; D is Devices
 ; G are global stats
 ; I is ISVs
 ; L is Locks
 ; R is Routines with Hash (similar to S)
 ; V is Variables
 ; ZSHOW "*" does not include:
 ; A -> Autorelink information
 ; C -> External programs that are loaded (presumable with D &)
 ; S -> Stack (use R instead)
 I $G(^XUTL("XUSYS",$J,"CMD"))="EXAM" ZSHOW "*":^XUTL("XUSYS",$J,"JE")
 ;
 ; ^XUTL("XUSYS",8563,"JE","G",0)="GLD:*,REG:*,SET:25610,KIL:593,GET:12284,...
 ; Just grab the default region only. Decreases the stats as a side effect from this utility
 N GLOSTAT
 N I F I=0:0 S I=$O(^XUTL("XUSYS",$J,"JE","G",I)) Q:'I  I ^(I)[$ZGLD,^(I)["DEFAULT" S GLOSTAT=^(I)
 I GLOSTAT]"" N I F I=1:1:$L(GLOSTAT,",") D
 . N EACHSTAT S EACHSTAT=$P(GLOSTAT,",",I)
 . N SUB,OBJ S SUB=$P(EACHSTAT,":"),OBJ=$P(EACHSTAT,":",2)
 . S ^XUTL("XUSYS",$J,"JE","GSTAT",SUB)=OBJ
 ;
 ; Capture IO statistics for this process
 ; ZEXCEPT: READONLY, REWIND
 I $ZV["Linux" D
 . N F S F="/proc/"_$J_"/io"
 . O F:(READONLY:REWIND):0 E  Q
 . U F
 . N DONE S DONE=0 ; $ZEOF doesn't seem to work (https://github.com/YottaDB/YottaDB/issues/120)
 . N X,ZEOF F  R X:0 U F D  Q:DONE
 .. I X["read_bytes"  S ^XUTL("XUSYS",$J,"JE","RBYTE")=$P(X,": ",2)
 .. I X["write_bytes" S ^XUTL("XUSYS",$J,"JE","WBYTE")=$P(X,": ",2) S DONE=1
 . C F
 ;
 ; Done. We can tell others we are ready
 SET ^XUTL("XUSYS",$J,"JE","COMPLETE")=1
 ;
 ; TODO: DEBUG
 ;
 ; Restore old IO and $R
 U OLDIO
 I %reference
 Q 1
 ;
WORK ; [Private] Main driver, Will release lock
 N ACCESS,USERS,GROUP,JTYPE,MEMBER,PROCID
 N TNAME,I,SORT,TAB
 N $ES,$ET
 n STATE,%PS,RTN,%OS,DONE
 ;
 ;Save $ZINTERRUPT, set new one
 N OLDINT
 S OLDINT=$ZINTERRUPT,$ZINTERRUPT="I $$JOBEXAM^ZU($ZPOSITION) S DONE=1"
 ;
 ;Clear old data
 S ^XUTL("XUSYS","COMMAND")="Status"
 ;
 S I=0 F  S I=$O(^XUTL("XUSYS",I)) Q:'I  K ^XUTL("XUSYS",I,"CMD"),^("INTERRUPT"),^("JE"),^("ZMODE"),^("codeline")
 ;
 ; Counts; Turn on Ctrl-C.
 N USERS S USERS=0
 U $P:CTRAP=$C(3)
 ;
 ;Go get the data
 D UNIX
 ;
 ;Now show the results
 I USERS D
 . D HEADER(.TAB),USHOW(.TAB,.SORT)
 . W !!,"Total ",USERS," user",$S(USERS>1:"s.",1:"."),!
 . Q
 E  W !,"No current GT.M users.",!
 ;
 ;
EXIT ;
 L -^XUTL("XUSYS","COMMAND") ;Release lock and let others in
 I $L($G(OLDINT)) S $ZINTERRUPT=OLDINT
 U $P:CTRAP=""
 Q
 ;
ERR ;
 U $P W !,$P($ZS,",",2,99),!
 D EXIT
 Q
 ;
LW ;Lock wait
 W !,"Someone else is running the System status now."
 Q
 ;
HEADER(TAB) ;Display Header
 ; ZEXCEPT: AB
 W #
 S IOM=+$$AUTOMARG
 W !,"GT.M System Status users on ",$$DATETIME($H)," - (stats reflect accessing DEFAULT region ONLY)"
 S TAB(0)=0,TAB(1)=9,TAB(2)=25,TAB(3)=29,TAB(4)=38,TAB(5)=57,TAB(6)=66
 S TAB(7)=75,TAB(8)=85,TAB(9)=100,TAB(10)=115,TAB(11)=123,TAB(12)=132
 S TAB(13)=141
 U 0:FILTER="ESCAPE"
 W !
 D EACHHEADER("PID",TAB(0))
 D EACHHEADER("Name",TAB(1))
 D EACHHEADER("PS",TAB(2))
 D EACHHEADER("Device",TAB(3))
 D EACHHEADER("Routine",TAB(4))
 D EACHHEADER("Mode",TAB(5))
 D EACHHEADER("CPU Time",TAB(6))
 I IOM>80 D
 . D EACHHEADER("OP/READ",TAB(7))
 . D EACHHEADER("NTR/NTW",TAB(8))
 . 
 I IOM>80 W ?TAB(9),"NR0123",?TAB(10),"%LSUCC",?TAB(11),"%CFAIL"
 I IOM>130 w ?TAB(12),"R MB",?TAB(13),"W MB"
 W !,"--------",?TAB(1),"---------------",?TAB(2),"---",?TAB(3),"--------",?TAB(4),"--------",?TAB(5),"-------",?TAB(6),"--------"
 I IOM>80 W ?TAB(7),"---------",?TAB(8),"-----------",?TAB(9),"-----------",?TAB(10),"-------",?TAB(11),"--------"
 I IOM>130 W ?TAB(12),"--------",?TAB(13),"--------"
 Q
EACHHEADER(H,TAB) ; [Internal]
 ; ZEXCEPT: AB
 N BOLD S BOLD=$C(27,91,49,109)
 N RESET S RESET=$C(27,91,109)
 W ?TAB,BOLD,H,RESET
 QUIT
USHOW(TAB,SORT) ;Display job info, sorted by pid
 ; ZEXCEPT: AB
 N SI,I
 S SI=""
 F  S SI=$ORDER(SORT(SI)) Q:SI=""  F I=1:1:SORT(SI) D
 . N X,TNAME,PROCID,JTYPE,CTIME,PS,PID,UNAME,RTN
 . S X=SORT(SI,I)
 . S TNAME=$P(X,"~",4),PROCID=$P(X,"~",1) ; TNAME is Terminal Name, i.e. the device.
 . S JTYPE=$P(X,"~",5),CTIME=$P(X,"~",6)
 . S PS=$P(X,"~",3)
 . S PID=$P(X,"~",8),UNAME=$P(X,"~",2)
 . S RTN=$G(^XUTL("XUSYS",PID,"INTERRUPT"))
 . I $G(^XUTL("XUSYS",PID,"ZMODE"))="OTHER" S TNAME="BG JOB"
 . W !,PROCID,?TAB(1),UNAME,?TAB(2),$G(STATE(PS),PS),?TAB(3),TNAME,?TAB(4),RTN,?TAB(5),ACCESS(JTYPE),?TAB(6),$J(CTIME,6)
 . I IOM>80 D
 .. I '$D(^XUTL("XUSYS",PID,"JE","GSTAT","DRD")) W ?TAB(7),"PROCESS NOT RESPONDING" QUIT
 .. N DRD,DTA,GET,ORD,ZPR,QRY
 .. S DRD=^XUTL("XUSYS",PID,"JE","GSTAT","DRD"),DTA=^("DTA"),GET=^("GET"),ORD=^("ORD"),ZPR=^("ZPR"),QRY=^("QRY")
 .. N opPerRead
 .. i DRD=0 s opPerRead=0
 .. e  S opPerRead=(DTA+GET+ORD+ZPR+QRY)/DRD
 .. W ?TAB(7),$J(opPerRead,"",2)
 .. W ?TAB(8),^XUTL("XUSYS",PID,"JE","GSTAT","NTR"),"/",^("NTW")
 .. W ?TAB(9),^XUTL("XUSYS",PID,"JE","GSTAT","NR0"),"/",^("NR1"),"/",^("NR2"),"/",^("NR3")
 .. N LKS,LKF S LKS=^XUTL("XUSYS",PID,"JE","GSTAT","LKS"),LKF=^("LKF")
 .. N lockSuccess
 .. I LKS+LKF'=0 S lockSuccess=LKS/(LKS+LKF)
 .. e  s lockSuccess=0
 .. W ?TAB(10),$J(lockSuccess*100,"",2)_"%"
 .. N CFE,CAT S CFE=^XUTL("XUSYS",PID,"JE","GSTAT","CFE"),CAT=^("CAT")
 .. N critSectionAcqFailure
 .. I CFE+CAT'=0 S critSectionAcqFailure=CFE/(CFE+CAT)
 .. e  s critSectionAcqFailure=0
 .. W ?TAB(11),$J(critSectionAcqFailure*100,"",2)_"%"
 . I IOM>130 D
 .. W ?TAB(12),$J($G(^XUTL("XUSYS",PID,"JE","RBYTE"))/(1024*1024),"",2)
 .. W ?TAB(13),$J($G(^XUTL("XUSYS",PID,"JE","WBYTE"))/(1024*1024),"",2)
 . ;
 . ; Device processing
 . N DEV
 . N DI F DI=1:1 Q:'$D(^XUTL("XUSYS",PID,"JE","D",DI))  S X=^(DI) D
 .. I X["CLOSED" QUIT  ; Don't print closed devices
 .. I PID=$J,$E(X,1,2)="ps" QUIT  ; Don't print our ps device
 .. I $E(X)=0 QUIT  ; Don't print default principal devices
 .. I X[TNAME QUIT  ; Don't include ttys/pts
 .. S DEV(DI)=$$TRIM(X) ; Remove extra spaces
 .. I $E(X)=" " S DEV(DI)=" "_DEV(DI) ; but add one if we had to trim it.
 . ;
 . ; Device print
 . I $O(DEV("")) D
 .. W !
 .. I IOM>130 W " " F DI=0:0 S DI=$O(DEV(DI)) Q:'DI  W DEV(DI)
 .. E         F DI=0:0 S DI=$O(DEV(DI)) Q:'DI  D
 ... W:$E(DEV(DI))=" " !
 ... W ?TAB(1),DEV(DI)
 Q
 ;
TRIM(STR) ; [Private] Trim spaces
 N OUT,I,NOTSP
 F I=1:1:$L(STR)  I $E(STR,I)'=" " S OUT=$E(STR,I,$L(STR)) QUIT
 F I=$L(OUT):-1:1 I $E(OUT,I)'=" " S OUT=$E(OUT,1,I) QUIT
 QUIT OUT
 ;
DATETIME(HOROLOG) ;
 Q $ZDATE(HOROLOG,"DD-MON-YY 24:60:SS")
 ;
UNIX ;PUG/TOAD,FIS/KSB,VEN/SMH - Kernel System Status Report for GT.M
 N %I,U,$ET,$ES
 S $ET="D UERR^ZSY"
 S %I=$I,U="^"
 n procs
 D INTRPTALL(.procs)
 H .205 ; 200ms for TCP Read processes; 5ms b/c I am nice.
 n procgrps
 n done s done=0
 n j s j=1
 n i f i=1:1 q:'$d(procs(i))  d
 . s procgrps(j)=$g(procgrps(j))_procs(i)_" "
 . i $l(procgrps(j))>220 s j=j+1 ; Max GT.M pipe len is 255
 f j=1:1 q:'$d(procgrps(j))  d
 . N %LINE,%TEXT,CMD
 . I $ZV["Linux" S CMD="ps o pid,tty,stat,time,cmd -p"_procgrps(j)
 . I $ZV["Darwin" S CMD="ps o pid,tty,stat,time,args -p"_procgrps(j)
 . I $ZV["CYGWIN" S CMD="for p in "_procgrps(j)_"; do ps -p $p; done | awk '{print $1"" ""$5"" n/a ""$7"" ""$8"" n/a ""}'"
 . ; ZEXCEPT: COMMAND,READONLY,SHELL
 . O "ps":(SHELL="/bin/sh":COMMAND=CMD:READONLY)::"PIPE" U "ps"
 . F  R %TEXT Q:$ZEO  D
 .. S %LINE=$$VPE(%TEXT," ",U) ; parse each line of the ps output
 .. Q:$P(%LINE,U)="PID"  ; header line
 .. D JOBSET(%LINE)
 . U %I C "ps"
 Q
 ;
UERR ;Linux Error
 N ZE S ZE=$ZS,$EC="" U $P
 ZSHOW "*"
 Q  ;halt
 ;
JOBSET(%LINE) ;Get data from a Linux job
 N %J
 N UNAME,PS,TNAME,JTYPE,CTIME,RTN
 S (UNAME,PS,TNAME,JTYPE,CTIME,RTN)=""
 S (%J,PID,PROCID)=$P(%LINE,U)
 S TNAME=$P(%LINE,U,2) S:TNAME="?" TNAME="" ; TTY, ? if none
 S PS=$P(%LINE,U,3) ; process STATE
 S CTIME=$P(%LINE,U,4) ;cpu time
 N PROCNAME S PROCNAME=$P(%LINE,U,5) ; process name
 I PROCNAME["/" S PROCNAME=$P(PROCNAME,"/",$L(PROCNAME,"/")) ; get actual image name if path
 I PROCNAME'="mumps" S JTYPE=PROCNAME ; If not mumps, then make that the job type
 E  S JTYPE=$P(%LINE,U,6)             ; else, job type is the mumps -dir/-run etc.
 S ACCESS(JTYPE)=JTYPE
 I $D(^XUTL("XUSYS",%J)) S UNAME=$G(^XUTL("XUSYS",%J,"NM"))
 E  S UNAME="unknown"
 S RTN="" ; Routine, get at display time
 S SI=$S(MODE=0:PID,MODE=1:CTIME,1:PID)
 N I
 S I=$GET(SORT(SI))+1,SORT(SI)=I,SORT(SI,I)=PROCID_"~"_UNAME_"~"_PS_"~"_TNAME_"~"_JTYPE_"~"_CTIME_"~"_""_"~"_PID
 S USERS=USERS+1
 Q
 ;
VPE(%OLDSTR,%OLDDEL,%NEWDEL) ; $PIECE extract based on variable length delimiter
 N %LEN,%PIECE,%NEWSTR
 S %OLDDEL=$G(%OLDDEL) I %OLDDEL="" S %OLDDEL=" "
 S %LEN=$L(%OLDDEL)
 ; each %OLDDEL-sized chunk of %OLDSTR that might be delimiter
 S %NEWDEL=$G(%NEWDEL) I %NEWDEL="" S %NEWDEL="^"
 ; each piece of the old string
 S %NEWSTR="" ; new reformatted string to retun
 F  Q:%OLDSTR=""  D
 . S %PIECE=$P(%OLDSTR,%OLDDEL)
 . S $P(%OLDSTR,%OLDDEL)=""
 . S %NEWSTR=%NEWSTR_$S(%NEWSTR="":"",1:%NEWDEL)_%PIECE
 . F  Q:%OLDDEL'=$E(%OLDSTR,1,%LEN)  S $E(%OLDSTR,1,%LEN)=""
 Q %NEWSTR
 ;
 ; Sam's entry points
UNIXLSOF(procs) ; [Public] - Get all processes accessing THIS database (only!)
 ; (return) .procs(n)=unix process number
 ; ZEXCEPT: shell
 n %cmd s %cmd="lsof -t "_$view("gvfile","DEFAULT")
 i $ZV["CYGWIN" s %cmd="ps -a | grep mumps | grep -v grep | awk '{print $1}'"
 n oldio s oldio=$IO
 o "lsof":(shell="/bin/bash":command=%cmd)::"pipe"
 u "lsof"
 n i f i=1:1 q:$ZEOF  r procs(i):1  i procs(i)="" k procs(i)
 u oldio c "lsof"
 quit:$Q i-2 quit
 ;
INTRPT(%J) ; [Public] Send mupip interrupt (currently SIGUSR1)
 N SIGUSR1
 I $ZV["Linux" S SIGUSR1=10
 I $ZV["Darwin" S SIGUSR1=30
 I $ZV["CYGWIN" S SIGUSR1=30
 N % S %=$ZSIGPROC(%J,SIGUSR1)
 QUIT
 ;
INTRPTALL(procs) ; [Public] Send mupip interrupt to every single database process
 N SIGUSR1
 I $ZV["Linux" S SIGUSR1=10
 I $ZV["Darwin" S SIGUSR1=30
 I $ZV["CYGWIN" S SIGUSR1=30
 ; Collect processes
 D UNIXLSOF(.procs)
 ; Signal all processes
 N i,% F i=1:1 q:'$d(procs(i))  S %=$ZSIGPROC(procs(i),SIGUSR1)
 QUIT
 ;
HALTALL ; [Public] Gracefully halt all jobs accessing current database
 ; Calls ^XUSCLEAN then HALT^ZU
 ;Clear old data
 S ^XUTL("XUSYS","COMMAND")="Status"
 N I F I=0:0 S I=$O(^XUTL("XUSYS",I)) Q:'I  K ^XUTL("XUSYS",I,"JE"),^("INTERUPT")
 ;
 ; Get jobs accessing this database
 n procs d UNIXLSOF(.procs)
 ;
 ; Tell them to stop
 n i f i=1:1 q:'$d(procs(i))  s ^XUTL("XUSYS",procs(i),"CMD")="HALT"
 K ^XUTL("XUSYS",$J,"CMD")  ; but not us
 ;
 ; Sayonara
 N J F J=0:0 S J=$O(^XUTL("XUSYS",J)) Q:'J  D INTRPT(J)
 ;
 ; Wait; Long hang for TCP jobs that can't receive interrupts for .2 seconds
 H .25
 ;
 ; Check that they are all dead. If not, kill it "softly".
 ; Need to do this for node and java processes that won't respond normally.
 N J F J=0:0 S J=$O(^XUTL("XUSYS",J)) Q:'J  I $zgetjpi(J,"isprocalive"),J'=$J D KILL(J)
 ;
 quit
 ;
HALTONE(%J) ; [Public] Halt a single process
 S ^XUTL("XUSYS",%J,"CMD")="HALT"
 D INTRPT(%J)
 H .25 ; Long hang for TCP jobs that can't receive interrupts
 I $zgetjpi(%J,"isprocalive") D KILL(%J)
 QUIT
 ;
KILL(%J) ; [Private] Kill %J
 ; ZEXCEPT: shell
 n %cmd s %cmd="kill "_%J
 o "kill":(shell="/bin/sh":command=%cmd)::"pipe" u "kill" c "kill"
 quit
 ;
ZJOB ; [Public, Interactive] Examine a specific job -- written by OSEHRA/SMH
EXAMJOB ;
VIEWJOB ;
JOBVIEW ;
 D ^ZSY
 N X,DONE
 S DONE=0
 ; Nasty read loop. I hate read loops
 F  R !,"Enter a job number to examine (? for more; ^ to quit): ",X:$G(DTIME,300) D  Q:DONE
 . E  S DONE=1 QUIT
 . I X="^" S DONE=1 QUIT
 . I X="" D ^ZSY QUIT
 . I X["?" D ^ZSY QUIT
 . ;
 . N DONEONE S DONEONE=0
 . N EXAMREAD
 . I X?1.N,$zgetjpi(X,"isprocalive") F  D  Q:DONEONE  ; This is an inner read loop to refresh a process.
 .. N % S %=$$EXAMINEJOBBYPID(X)
 .. I %'=0 W !,"The job didn't respond to examination for 500 ms. You may try again." S DONEONE=1 QUIT
 .. D PRINTEXAMDATA(X,$G(EXAMREAD))
 .. W "Enter to Refersh, V for variables, I for ISVs, K to kill",!
 .. R "L to load variables into your ST and quit, ^ to go back: ",EXAMREAD:$G(DTIME,300)
 .. E  S DONEONE=1
 .. I EXAMREAD="^" S DONEONE=1
 .. I $TR(EXAMREAD,"k","K")="K" D HALTONE(X) S DONEONE=1
 .. I DONEONE W # D ^ZSY
 . Q:DONEONE
 . ;
 . W !,"No such job found. Double check your number"
 QUIT
 ;
EXAMINEJOBBYPID(%J) ; [$$, Public, Silent] Examine Job by PID; Non-zero output failure
 Q:'$ZGETJPI(X,"isprocalive") -1
 K ^XUTL("XUSYS",%J,"CMD"),^("INTERRUPT"),^("JE"),^("ZMODE"),^("codeline")
 S ^XUTL("XUSYS",%J,"CMD")="EXAM"
 D INTRPT(%J)
 N I F I=1:1:5 H .001 Q:$G(^XUTL("XUSYS",%J,"JE","COMPLETE"))
 I '$G(^XUTL("XUSYS",%J,"JE","COMPLETE")) H .2
 I '$G(^XUTL("XUSYS",%J,"JE","COMPLETE")) Q -1
 QUIT 0
 ;
PRINTEXAMDATA(%J,FLAG) ; [Private] Print the exam data
 ; ^XUTL("XUSYS",8563,"INTERRUPT")="GETTASK+3^%ZTMS1"
 ; ^XUTL("XUSYS",8563,"JE","G",0)="GLD:*,REG:*,SET:25610,KIL:593,GET:12284,...
 ; ^XUTL("XUSYS",8563,"ZMODE")="OTHER"
 N ZSY M ZSY=^XUTL("XUSYS",%J)
 ;
 N BOLD S BOLD=$C(27,91,49,109)
 N RESET S RESET=$C(27,91,109)
 N UNDER S UNDER=$C(27,91,52,109)
 N DIM S DIM=$$AUTOMARG()
 ;
 ; List Variables?
 I $TR(FLAG,"v","V")="V" D  QUIT
 . W !!,BOLD,"Variables: ",RESET,!
 . N V F V=0:0 S V=$O(ZSY("JE","V",V)) Q:'V  W ZSY("JE","V",V),!
 ;
 ; Load Variables into my Symbol Table?
 ; ZGOTO pops the stack and drops you to direct mode ($ZLEVEL is 2 to exit one above direct mode)
 I $TR(FLAG,"l","L")="L" D  ZGOTO 2:LOADST
 . K ^TMP("ZSY",$J)
 . M ^TMP("ZSY",$J)=ZSY("JE","V")
 ;
 ; List ISVs?
 I $TR(FLAG,"i","I")="I" D  QUIT
 . W !!,BOLD,"ISVs: ",RESET,!
 . N I F I=0:0 S I=$O(ZSY("JE","I",I)) Q:'I  W ZSY("JE","I",I),!
 ;
 ; Normal Display: Job Info, Stack, Locks, Devices
 W !
 W UNDER,"JOB INFORMATION FOR "_%J," (",$ZDATE(ZSY(0),"YYYY-MON-DD 24:60:SS"),")",RESET,!
 W BOLD,"AT: ",RESET,ZSY("INTERRUPT"),": ",ZSY("codeline"),!!
 ;
 N CNT S CNT=1
 W BOLD,"Stack: ",RESET,!
 ; Stack is funny -- print just to $ZINTERRUPT
 N S F S=$O(ZSY("JE","R"," "),-1):-1:1 Q:ZSY("JE","R",S)["$ZINTERRUPT"  D
 . N PLACE S PLACE=$P(ZSY("JE","R",S),":")
 . I $E(PLACE)=" " QUIT  ; GTM adds an extra level sometimes for display -- messes me up
 . W CNT,". "
 . I PLACE'["GTM$DMOD" W PLACE,?40,$T(@PLACE)
 . W !
 . S CNT=CNT+1
 W CNT,". ",ZSY("INTERRUPT"),":",?40,ZSY("codeline"),!
 ;
 W !
 W BOLD,"Locks: ",RESET,!
 N L F L=0:0 S L=$O(ZSY("JE","L",L)) Q:'L  W ZSY("JE","L",L),!
 ;
 W !
 W BOLD,"Devices: ",RESET,!
 N D F D=0:0 S D=$O(ZSY("JE","D",D)) Q:'D  W ZSY("JE","D",D),!
 QUIT
 ;
LOADST ; [Private] Load the symbol table into the current process
 KILL
 N V F V=0:0 S V=$O(^TMP("ZSY",$J,V)) Q:'V  S @^(V)
 K ^TMP("ZSY",$J)
 QUIT
 ;
AUTOMARG() ;RETURNS IOM^IOSL IF IT CAN and resets terminal to those dimensions; GT.M
 ; ZEXCEPT: APC,TERM,NOECHO,WIDTH
 U $PRINCIPAL:(WIDTH=0)
 N %I,%T,ESC,DIM S %I=$I,%T=$T D
 . ; resize terminal to match actual dimensions
 . S ESC=$C(27)
 . U $P:(TERM="R":NOECHO)
 . W ESC,"7",ESC,"[r",ESC,"[999;999H",ESC,"[6n"
 . R DIM:1 E  Q
 . W ESC,"8"
 . I DIM?.APC U $P:(TERM="":ECHO) Q
 . I $L($G(DIM)) S DIM=+$P(DIM,";",2)_"^"_+$P(DIM,"[",2)
 . U $P:(TERM="":ECHO:WIDTH=+$P(DIM,";",2):LENGTH=+$P(DIM,"[",2))
 ; restore state
 U %I I %T
 ; Extra just for ^ZJOB - don't wrap
 U $PRINCIPAL:(WIDTH=0)
 Q:$Q $S($G(DIM):DIM,1:"") Q
