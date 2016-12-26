ZSY	;ISF/RWF,VEN/SMH - GT.M/VA system status display ;8/15/07  10:39
 ;;8.0;KERNEL;**349**;Jul 10, 1995;Build 2
 ;GT.M/VA %SY utility - status display
 ;From the top just show by PID
 N IMAGE,MODE
 W !,"GT.M system status "
 L +^XUTL("XUSYS","COMMAND"):1 I '$T G LW
 S IMAGE=0,MODE=0 D WORK
 Q
 ;
QUERY	N IMAGE,MODE,X
 L +^XUTL("XUSYS","COMMAND"):1 I '$T G LW
 S X=$$ASK W ! I X=-1 L -^XUTL("XUSYS","COMMAND") Q
 S IMAGE=$P(X,"~",2),MODE=+X D WORK
 Q
IMAGE	N IMAGE,MODE
 L +^XUTL("XUSYS","COMMAND"):1 I '$T G LW
 S IMAGE=1,MODE=0 D WORK
 Q
WORK	;Main driver, Will release lock
 N NOPRIV,LOCK,PID,ACCESS,USERS,CTIME,GROUP,JTYPE,LTIME,MEMBER,PROCID
 N TNAME,UNAME,INAME,I,SORT,OLDPRIV,TAB
 N $ES,$ET,STATE,%PS,RTN,%OS,RETVAL,%T,SYSNAME,OLDINT,DONE
 ;
 ;Save $ZINTERRUPT, set new one
 S OLDINT=$ZINTERRUPT,$ZINTERRUPT="I $$JOBEXAM^ZU($ZPOSITION) S DONE=1"
 ;
 ;Clear old data
 S ^XUTL("XUSYS","COMMAND")="Status"
 S I=0 F  S I=$O(^XUTL("XUSYS",I)) Q:'I  K ^XUTL("XUSYS",I,"JE"),^("INTERUPT")
 ;
 ; Counts; Turn on Ctrl-C.
 S (LOCK,NOPRIV,USERS)=0
 U $P:CTRAP=$C(3)
 ;
 ;Go get the data
 D UNIX ; OSEHRA/SMH - Cygwin may be different, Now we support Linux and Mac
 ;
 ;Now show the results
 I USERS D
 . D HEADER,ISHOW:IMAGE,USHOW:'IMAGE
 . W !!,"Total ",USERS," user",$S(USERS>1:"s.",1:"."),!
 . Q
 E  W !,"No current GT.M users.",!
 I NOPRIV W !,"Insufficient privileges to examine ",NOPRIV," process",$S(NOPRIV>1:"es.",1:"."),!
 ;
 ;
EXIT	;
 L -^XUTL("XUSYS","COMMAND") ;Release lock and let others in
 I $L($G(OLDINT)) S $ZINTERRUPT=OLDINT
 U $P:CTRAP=""
 Q
 ;
ERR	;
 U $P W !,$P($ZS,",",2,99),!
 D EXIT
 Q
 ;
LW	;Lock wait
 W !,"Someone else is running the System status now."
 Q
 ;
HEADER	;Display Header
 W # S ($X,$Y)=0
 S TAB(1)=9,TAB(2)=25,TAB(3)=29,TAB(4)=38,TAB(5)=57,TAB(6)=66
 W !,"GT.M Mumps users on ",$$DATETIME($H),!
 W !,"Proc. id",?TAB(1),"Proc. name",?TAB(2),"PS",?TAB(3),"Device",?TAB(4),"Routine",?TAB(5),"MODE",?TAB(6),"CPU time"
 W !,"--------",?TAB(1),"---------------",?TAB(2),"---",?TAB(3),"--------",?TAB(4),"--------",?TAB(5),"-------",?TAB(6)
 Q
USHOW	;Display job info, sorted by pid
 N SI,X,EXIT,DEV
 S SI="",EXIT=0
 F  S SI=$ORDER(SORT(SI)) Q:SI=""!EXIT  F I=1:1:SORT(SI) D  Q:EXIT
 . S X=SORT(SI,I)
 . S TNAME=$P(X,"~",4),PROCID=$P(X,"~",1) ; TNAME is Terminal Name, i.e. the device.
 . S JTYPE=$P(X,"~",5),CTIME=$P(X,"~",6)
 . S LTIME=$P(X,"~",7),PS=$P(X,"~",3)
 . S PID=$P(X,"~",8),UNAME=$P(X,"~",2)
 . S RTN=$G(^XUTL("XUSYS",PID,"INTERRUPT"))
 . I $G(^XUTL("XUSYS",PID,"ZMODE"))="OTHER" S TNAME="BG JOB"
 . W !,PROCID,?TAB(1),UNAME,?TAB(2),$G(STATE(PS),PS),?TAB(3),TNAME,?TAB(4),RTN,?TAB(5),ACCESS(JTYPE),?TAB(6),$J(CTIME,6)
 . K DEV
 . F DI=1:1 Q:'$D(^XUTL("XUSYS",PID,"JE","D",DI))  D
 .. S X=^(DI),X=$P(X,":")_":" ; VEN/SMH - No clue what that does.
 .. I X["CLOSED" QUIT  ; Don't print closed devices
 .. I PID=$J,$E(X,1,2)="ps" QUIT  ; Don't print our ps device
 .. I $E(X)=0 QUIT  ; Don't print default principal devices
 .. I X'[TNAME S DEV(DI)=X
 . S DI=0 F  S DI=$O(DEV(DI)) Q:DI'>0  W !,?TAB(3),$E(DEV(DI),1,79-$X)
 Q
ISHOW	;Show process sorted by IMAGE
 N SI,X
 S INAME="",EXIT=0
 F  S INAME=$ORDER(SORT(INAME)) Q:INAME=""!EXIT  D
 . W !,"IMAGE  : ",INAME S SI=""
 . F  S SI=$ORDER(SORT(INAME,SI)) Q:SI=""!EXIT  F I=1:1:SORT(INAME,SI) D  Q:EXIT
 . . S X=SORT(INAME,SI,I)
 . . S TNAME=$P(X,"~",4),PROCID=$P(X,"~",1) ; TNAME is Terminal Name, i.e. the device.
 . . S PS=$P(X,"~",3),RTN=$P(X,"~",8)
 . . S JTYPE=$P(X,"~",5),CTIME=$P(X,"~",6)
 . . S LTIME=$P(X,"~",7),UNAME=$P(X,"~",2)
 . . S RTN=$G(^XUTL("XUSYS",RTN,"INTERRUPT"))
 . . I $G(^XUTL("XUSYS",PROCID,"ZMODE"))="OTHER" S TNAME="BG JOB"
 . . W !,PROCID,?TAB(1),UNAME,?TAB(2),$G(STATE(PS),PS),?TAB(3),TNAME,?TAB(4),RTN,?TAB(5),ACCESS(JTYPE),?TAB(6),CTIME
 . W !
 Q
 ;
WAIT	;Page break
 N Y
 S Y=0 W !,"Press Return to continue '^' to stop: " R Y:300
 I $E(Y)="^" S EXIT=1
 E  D HEADER
 Q
 ;
DATETIME(HOROLOG)	;
 Q $ZDATE(HOROLOG,"DD-MON-YY 24:60:SS","Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec")
 ;
CPUTIME(S)	;
 N T,S,M,H,D
 S T=S#100,S=S\100 S:$L(T)=1 T="0"_T
 S S=S#60,S=S\60 S:$L(S)=1 S="0"_S
 S M=S#60,S=S\60 S:$L(M)=1 M="0"_M
 S H=S#24,D=S\24 S:$L(H)=1 H="0"_H
 Q D_" "_H_":"_M_":"_S_"."_T
 ;
BLINDPID	;
 N ZE S ZE=$ZS,$EC=""
 I ZE["NOPRIV" S NOPRIV=NOPRIV+1
 Q
ASK()	;Ask sort item
 N RES,X,GROUP
 S RES=0,GROUP=2
 W !,"1 pid",!,"2 cpu time",!,"3 IMAGE/pid",!,"4 IMAGE/cpu"
 F  R !,"1// ",X:600 S:X="" X=1 Q:X["^"  Q:(X>0)&(X<5)  W " not valid"
 Q:X["^" -1
 S X=X-1,RES=(X#GROUP)_"~"_(X\GROUP)
 Q RES
 ;
UNIX	;PUG/TOAD,FIS/KSB,VEN/SMH - Kernel System Status Report for GT.M
 N %LINE,%TEXT,%I,U,%J,STATE,$ET,$ES
 S $ET="D UERR^ZSY"
 S %I=$I,U="^"
 n procs
 D UNIXLSOF(.procs)
 n i f i=1:1 q:'$d(procs(i))  D
 . I $ZV["Linux" S CMD="ps o pid,tty,stat,time,cmd -p"_procs(i)
 . I $ZV["Darwin" S CMD="ps o pid,tty,stat,time,args -p"_procs(i)
 . O "ps":(SHELL="/bin/sh":COMMAND=CMD:READONLY)::"PIPE" U "ps"
 . F  R %TEXT Q:$ZEO  D
 .. S %LINE=$$VPE(%TEXT," ",U) ; parse each line of the ps output
 .. Q:$P(%LINE,U)="PID"  ; header line
 .. D JOBSET
 . U %I C "ps"
 Q
 ;
UERR	;Linux Error
 N ZE S ZE=$ZS,$EC="" U $P
 ZSHOW "*"
 Q  ;halt
 ;
JOBSET	;Get data from a Linux job
 S (IMAGE,INAME,UNAME,PS,TNAME,JTYPE,CTIME,LTIME,RTN)=""
 S (%J,PID,PROCID)=$P(%LINE,U)
 S TNAME=$P(%LINE,U,2) S:TNAME="?" TNAME="" ; TTY, ? if none
 S PS=$P(%LINE,U,3) ; process STATE
 S PS=$S(PS="D":"lef",PS="R":"com",PS="S":"hib",1:PS)
 S CTIME=$P(%LINE,U,4) ;cpu time
 S JTYPE=$P(%LINE,U,6),ACCESS(JTYPE)=JTYPE
 D INTRPT(%J)
 I $D(^XUTL("XUSYS",%J)) S UNAME=$G(^XUTL("XUSYS",%J,"NM"))
 E  S UNAME="unknown"
 S RTN="" ; Routine, get at display time
 S SI=$S(MODE=0:PID,MODE=1:CTIME,1:PID)
 I IMAGE D
 . S INAME="mumps",I=$GET(SORT(INAME,SI))+1,SORT(INAME,SI)=I
 . S SORT(INAME,SI,I)=PROCID_"~"_UNAME_"~"_PS_"~"_TNAME_"~"_JTYPE_"~"_CTIME_"~"_LTIME_"~"_PID_"~"_INAME
 E  S I=$GET(SORT(SI))+1,SORT(SI)=I,SORT(SI,I)=PROCID_"~"_UNAME_"~"_PS_"~"_TNAME_"~"_JTYPE_"~"_CTIME_"~"_LTIME_"~"_PID
 S USERS=USERS+1
 Q
 ;
VPE(%OLDSTR,%OLDDEL,%NEWDEL) ; $PIECE extract based on variable length delimiter
 N %LEN,%PIECE,%NEWSTR
 S %STRING=$G(%STRING)
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
 n %cmd s %cmd="lsof -t "_$view("gvfile","default")
 n oldio s oldio=$io
 o "lsof":(shell="/bin/bash":command=%cmd)::"pipe"
 u "lsof"
 n i f i=1:1 q:$zeof  r procs(i):1  i procs(i)="" k procs(i)
 u oldio c "lsof"
 quit
 ;
INTRPT(%J) ; [Public] Send mupip interrupt (currently SIGUSR1) using $gtm_dist/mupip
 N %CMD S %CMD="$gtm_dist/mupip intrpt "_%J
 n oldio s oldio=$io
 o "intrpt":(shell="/bin/sh":command=%CMD)::"pipe" u "intrpt",oldio c "intrpt"
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
 f i=1:1 q:'$d(procs(i))  s ^XUTL("XUSYS",procs(i),"CMD")="HALT"
 K ^XUTL("XUSYS",$J,"CMD")  ; but not us
 ;
 ; Sayonara
 N J F J=0:0 S J=$O(^XUTL("XUSYS",J)) Q:'J  D INTRPT(J)
 quit
 ;
