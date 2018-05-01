XLFSHAN ;ISL/PKR SHA secure hash routines. ;2018-05-01  9:24 AM
 ;;8.0;KERNEL;**657**;Jul 10, 1995;Build 9
 ;Per VA Directive 6402, this routine should not be modified.
 Q
 ;=============================
AND(X,Y) ;Bitwise logical AND, 32 bits. IA #6157
 Q $ZBOOLEAN(X,Y,1) ;Cache
 ;N IND,XA
 ;S XA=0
 ;F IND=1:1:32 S XA=(XA\2)+((((X#2)+(Y#2))\2)*2147483648),X=X\2,Y=Y\2
 ;Q XA
 ;
 ;=============================
CHASHLEN(HASHLEN) ;Make sure the hash length is one of the acceptable
 ;values.
 I HASHLEN=160 Q 1
 I HASHLEN=224 Q 1
 I HASHLEN=256 Q 1
 I HASHLEN=384 Q 1
 I HASHLEN=512 Q 1
 Q 0
 ;
 ;=============================
CPUTIME() ;Returns two comma-delimited pieces, "system" CPU time and "user"
 ;CPU time (except on VMS where no separate times are available).
 ;Time is returned as milliseconds of CPU time.
 ; ZEXCEPT: Process,GetCPUTime
 I ^%ZOSF("OS")["OpenM" Q $SYSTEM.Process.GetCPUTime()
 I ^%ZOSF("OS")["GT.M" Q $ZGETJPI("","CPUTIM")*10
 S $EC=",U-UNIMPLEMENTED,"
 ;
 ;
 ;=============================
ETIMEMS(START,END) ;Calculate and return the elapsed time in milliseconds.
 ;START and STOP times are set by calling $$CPUTIME.
 N ETIME,TEXT
 S END=$P(END,",",2)
 S START=$P(START,",",2)
 S ETIME=END-START
 S TEXT=ETIME_" milliseconds"
 Q TEXT
 ;
 ;=============================
FILE(HASHLEN,FILENUM,IEN,FIELD,FLAGS) ;Return a SHA hash for the specified
 ;file entry. IA #6157
 I '$$CHASHLEN(HASHLEN) Q -1
 N IENS,IND,FIELDNUM,FNUM,HASH,MSG,NBLOCKS,NL,TARGET,TEMP,TEXT,WPI,WPZN
 K ^TMP($J,"XLFDIQ"),^TMP($J,"XLFMSG")
 S TARGET=$NA(^TMP($J,"XLFDIQ"))
 S WPI=$P(TARGET,")",1)
 S FLAGS=$G(FLAGS)
 S WPZN=$S(FLAGS["Z":1,1:0)
 I $G(FIELD)="" S FIELD="**"
 D GETS^DIQ(FILENUM,IEN,FIELD,FLAGS,TARGET,"XLFMSG")
 I $D(MSG) Q 0
 ;Build the message array
 S NBLOCKS=0,(FNUM,TEMP)=""
 F  S FNUM=$O(^TMP($J,"XLFDIQ",FNUM)) Q:FNUM=""  D
 . S IENS=""
 . F  S IENS=$O(^TMP($J,"XLFDIQ",FNUM,IENS)) Q:IENS=""  D
 .. S FIELDNUM=""
 .. F  S FIELDNUM=$O(^TMP($J,"XLFDIQ",FNUM,IENS,FIELDNUM)) Q:FIELDNUM=""  D
 ... S TEXT(0)=$G(^TMP($J,"XLFDIQ",FNUM,IENS,FIELDNUM))
 ... S TEXT("E")=$G(^TMP($J,"XLFDIQ",FNUM,IENS,FIELDNUM,"E"))
 ... S TEXT("I")=$G(^TMP($J,"XLFDIQ",FNUM,IENS,FIELDNUM,"I"))
 ... N JND F JND=0,"E","I" D
 .... I TEXT(JND)="" Q
 .... S TEXT=TEXT(JND)
 ....;Do not include the word-processing field indicator.
 .... I TEXT'[WPI D
 ..... F IND=1:1:$L(TEXT) D
 ...... S TEMP=TEMP_$E(TEXT,IND)
 ...... I $L(TEMP)=1024 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP,TEMP=""
 .... I TEXT[WPI D
 ..... S NL=0
 ..... F  S NL=+$O(^TMP($J,"XLFDIQ",FNUM,IENS,FIELDNUM,NL)) Q:NL=0  D
 ...... I WPZN S TEXT=^TMP($J,"XLFDIQ",FNUM,IENS,FIELDNUM,NL,0)
 ...... E  S TEXT=^TMP($J,"XLFDIQ",FNUM,IENS,FIELDNUM,NL)
 ...... F IND=1:1:$L(TEXT) D
 ....... S TEMP=TEMP_$E(TEXT,IND)
 ....... I $L(TEMP)=1024 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP,TEMP=""
 I $L(TEMP)>0 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP
 K ^TMP($J,"XLFDIQ")
 S HASH=$$LSHAN(HASHLEN,"XLFMSG",NBLOCKS)
 K ^TMP($J,"XLFMSG")
 Q HASH
 ;
 ;=============================
GENAREF(HASHLEN,AREF,DATAONLY) ;Return an SHA hash for a general array. AREF
 ;is the starting array reference, for example ABC or ^TMP($J,"XX").
 ;IA #6157
 I '$$CHASHLEN(HASHLEN) Q -1
 N DONE,HASH,IND,LEN,NBLOCKS,PROOT,ROOT,START,TEMP,TEXT
 I AREF="" Q 0
 S PROOT=$P(AREF,")",1)
 S TEMP=$NA(@AREF)
 S ROOT=$P(TEMP,")",1)
 S AREF=$Q(@AREF)
 I AREF'[ROOT Q 0
 S TEMP=""
 S (DONE,NBLOCKS)=0
 F  Q:(AREF="")!(DONE)  D
 . S START=$F(AREF,ROOT)
 . I DATAONLY S TEXT=@AREF
 . E  S LEN=$L(AREF),IND=$E(AREF,START,LEN),TEXT=PROOT_IND_"="_@AREF
 . F IND=1:1:$L(TEXT) D
 .. S TEMP=TEMP_$E(TEXT,IND)
 .. I $L(TEMP)=1024 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP,TEMP=""
 . S AREF=$Q(@AREF)
 . I AREF'[ROOT S DONE=1
 I $L(TEMP)>0 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP
 S HASH=$$LSHAN(HASHLEN,"XLFMSG",NBLOCKS)
 K ^TMP($J,"XLFMSG")
 Q HASH
 ;
 ;=============================
GLOBAL(HASHLEN,FILENUM,DATAONLY) ;Return an SHA hash for a global. IA #6157
 I '$$CHASHLEN(HASHLEN) Q -1
 N DONE,HASH,IND,NBLOCKS,ROOT,ROOTN,TEMP,TEXT
 S ROOT=$$ROOT^DILFD(FILENUM)
 I ROOT="" Q 0
 S ROOTN=$TR(ROOT,",",")")
 S TEMP=$L(ROOTN)
 I $E(ROOTN,TEMP)="(" S ROOTN=$E(ROOTN,1,(TEMP-1))
 K ^TMP($J,"XLFMSG")
 S NBLOCKS=0,TEMP=""
 S DONE=0
 F  Q:DONE  D
 . S ROOTN=$Q(@ROOTN)
 . I (ROOTN="")!(ROOTN'[ROOT) S DONE=1 Q
 . I DATAONLY S TEXT=@ROOTN
 . E  S TEXT=ROOTN_"="_@ROOTN
 . F IND=1:1:$L(TEXT) D
 .. S TEMP=TEMP_$E(TEXT,IND)
 .. I $L(TEMP)=1024 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP,TEMP=""
 I $L(TEMP)>0 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP
 S HASH=$$LSHAN(HASHLEN,"XLFMSG",NBLOCKS)
 K ^TMP($J,"XLFMSG")
 Q HASH
 ;
 ;=============================
HOSTFILE(HASHLEN,PATH,FILENAME) ;Return a SHA hash for a host file. IA #6157
 I '$$CHASHLEN(HASHLEN) Q -1
 N GBLZISH,HASH,IND,LN,OVFLN,NBLOCKS,SUCCESS,TEMP,TEXT
 K ^TMP($J,"HF")
 S GBLZISH="^TMP($J,""HF"",1)"
 S GBLZISH=$NA(@GBLZISH)
 S SUCCESS=$$FTG^%ZISH(PATH,FILENAME,GBLZISH,3)
 I 'SUCCESS Q 0
 S (NBLOCKS,LN)=0,TEMP=""
 F  S LN=+$O(^TMP($J,"HF",LN)) Q:LN=0  D
 . S TEXT=^TMP($J,"HF",LN)
 . F IND=1:1:$L(TEXT) D
 .. S TEMP=TEMP_$E(TEXT,IND)
 .. I $L(TEMP)=1024 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP,TEMP=""
 .;Check for overflow lines
 . I '$D(^TMP($J,"HF",LN,"OVF")) Q
 . S OVFLN=0
 . F  S OVFLN=+$O(^TMP($J,"HF",LN,"OVF",OVFLN)) Q:OVFLN=0  D
 .. S TEXT=^TMP($J,"HF",LN,"OVF",OVFLN)
 .. F IND=1:1:$L(TEXT) D
 ... S TEMP=TEMP_$E(TEXT,IND)
 ... I $L(TEMP)=1024 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP,TEMP=""
 I $L(TEMP)>0 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP
 K ^TMP($J,"HF")
 S HASH=$$LSHAN(HASHLEN,"XLFMSG",NBLOCKS)
 K ^TMP($J,"XLFMSG")
 Q HASH
 ;
 ;=============================
LSHAN(HASHLEN,MSUB,NBLOCKS) ;SHA hash for a message too long for a single
 ;string. Cache objects version. IA #6157
 ;The message is in ^TMP($J,MSUB,N) where N goes from 1 to NBLOCKS.
 ;
 I ^%ZOSF("OS")["OpenM" G LSHANONT
 I ^%ZOSF("OS")["GT.M" G LSHANGUX
 S $EC=",U-UNIMPLMENTED,"
 ;
 ;
LSHANONT ; [Private, Cache]
 ; ZEXCEPT: %New,%Save,%Stream,Encryption,GlobalCharacter,LineTerminator,SHAHashStream,WriteLine,class
 ; ZEXCEPT: HASHLEN,MSUB,NBLOCKS
 N CHAR,COHASH,HASH,IND,LOCATION,STATUS,STREAM
 K ^TMP($J,"STREAM")
 ;Put the message into a stream global.
 S LOCATION=$NA(^TMP($J,"STREAM"))
 S STREAM=##class(%Stream.GlobalCharacter).%New(LOCATION)
 S STREAM.LineTerminator=""
 F IND=1:1:NBLOCKS S STATUS=STREAM.WriteLine(^TMP($J,"XLFMSG",IND))
 S STATUS=STREAM.%Save()
 S COHASH=$SYSTEM.Encryption.SHAHashStream(HASHLEN,STREAM)
 ;Convert the string to hex.
 S HASH=""
 F IND=1:1:$L(COHASH) D
 . S CHAR=$A(COHASH,IND)
 . S HASH=HASH_$$RJ^XLFSTR($$CNV^XLFUTL(CHAR,16),2,"0")
 K ^TMP($J,"STREAM")
 Q HASH
 ;
LSHANGUX ; [Private, GT.M] Contributed K.S. Bhaskar. IA #6157
 ; ZEXCEPT: HASHLEN,MSUB,NBLOCKS
 N OLDIO,IND,SHA
 S OLDIO=$IO
 S:HASHLEN=160 HASHLEN=1
 ;name of program for 160 bit hash is sha1sum; other names use actual
 ;hash size
 ; 
 ; ZEXCEPT: SHELL,COMMAND,STREAM,NOWRAP,EOF
 i $ztrnlnm("GTMXC_openssl")'="" d  quit SHA
 . d &openssl.init("sha"_HASHLEN)
 . F IND=1:1:NBLOCKS d &openssl.add(^TMP($J,MSUB,IND))
 . d &openssl.finish(.SHA)
 ;
 ; command line way - takes 5 seconds
 O "SHA":(SHELL="/bin/sh":COMMAND="sha"_HASHLEN_"sum":STREAM:NOWRAP)::"PIPE" U "SHA"
 F IND=1:1:NBLOCKS W ^TMP($J,MSUB,IND) S $X=0
 W /EOF R SHA
 U OLDIO C "SHA"
 Q $$UP^XLFSTR($P(SHA," ",1))
 ;
 ;=============================
OR(X,Y) ;Bitwise logical OR, 32 bits. IA #6157
 Q $ZBOOLEAN(X,Y,7) ;Cache
 ;N BOR,IND,XO
 ;S XO=0
 ;F IND=1:1:32 S BOR=$S(((X#2)+(Y#2))>0:1,1:0),XO=(XO\2)+(BOR*2147483648),X=X\2,Y=Y\2
 ;Q XO
 ;
 ;=============================
ROUTINE(HASHLEN,ROUTINE) ;Return a SHA hash for a routine. IA #6157
 I '$$CHASHLEN(HASHLEN) Q -1
 N DIF,HASH,IND,LN,NBLOCKS,RA,TEMP,X,XCNP
 K ^TMP($J,"XLFMSG")
 S XCNP=0
 S DIF="RA("
 S X=ROUTINE
 ;Make sure the routine exists.
 X ^%ZOSF("TEST")
 I '$T Q 0
 X ^%ZOSF("LOAD")
 S NBLOCKS=0,TEMP=""
 F LN=1:1:(XCNP-1) D
 . F IND=1:1:$L(RA(LN,0)) D
 .. S TEMP=TEMP_$E(RA(LN,0),IND)
 .. I $L(TEMP)=1024 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP,TEMP=""
 I $L(TEMP)>0 S NBLOCKS=NBLOCKS+1,^TMP($J,"XLFMSG",NBLOCKS)=TEMP
 S HASH=$$LSHAN(HASHLEN,"XLFMSG",NBLOCKS)
 K ^TMP($J,"XLFMSG")
 Q HASH
 ;
 ;=============================
SHAN(HASHLEN,MESSAGE) ;SHA hash for a message that can be passed as a single
 ;string. IA #6157
 ; ZEXCEPT: Encryption,SHAHash
 I '$$CHASHLEN(HASHLEN) Q -1
 I ^%ZOSF("OS")["OpenM" G SHANONT
 I ^%ZOSF("OS")["GT.M" G SHANGUX
 S $EC=",U-UNIMPLMENTED,"
 ;
SHANONT ; [Private, Cache]
 ; ZEXCEPT: HASHLEN,MESSAGE
 N CHAR,COHASH,HASH,IND
 S COHASH=$SYSTEM.Encryption.SHAHash(HASHLEN,MESSAGE)
 ;Convert the string to hex.
 S HASH=""
 F IND=1:1:$L(COHASH) D
 . S CHAR=$A(COHASH,IND)
 . S HASH=HASH_$$RJ^XLFSTR($$CNV^XLFUTL(CHAR,16),2,"0")
 Q HASH
 ;
SHANGUX ; [Private, GT.M] - Contributed by KS Bhaskar
 ; ZEXCEPT: HASHLEN,MESSAGE
 ; ZEXCEPT: STREAM,NOWRAP,SHELL,COMMAND,EOF
 S:HASHLEN=160 HASHLEN=1 ; name of program for 160 bit hash is sha1sum
 N SHA
 i $ztrnlnm("GTMXC_openssl")'="" d  quit SHA
 . d &openssl.md(MESSAGE,"sha"_HASHLEN,.SHA)
 N OLDIO S OLDIO=$IO
 ;other names use actual hash size
 O "SHA":(SHELL="/bin/sh":COMMAND="sha"_HASHLEN_"sum":STREAM:NOWRAP)::"PIPE" U "SHA"
 W MESSAGE S $X=0 W /EOF R SHA
 U OLDIO C "SHA"
 Q $$UP^XLFSTR($P(SHA," ",1))
 ;
 ;=============================
XOR(X,Y) ;Bitwise logical XOR, 32 bits. IA #6157
 Q $ZBOOLEAN(X,Y,6) ;Cache
 ;N IND,XO
 ;S XO=0
 ;F IND=1:1:32 S XO=(XO\2)+(((X+Y)#2)*2147483648),X=X\2,Y=Y\2
 ;Q XO
 ;
 ;=============================
 ;Tests
 ;Test vectors from http://www.di-mgt.com.au/sha_testvectors.html
 ;Format is msg:message:reps
 ;Followed by hash:hash length:HASH
 ;=============================
TEST I $T(^%ut)]"" D EN^%ut($t(+0),3) QUIT
 ;
T1 ; @TEST $$SHAN w/ null string
 N DATA S DATA=$T(TDATA1+1),DATA=$P(DATA,";;",2)
 N STR,REPS
 S STR=$P(DATA,":",2),REPS=$P(DATA,":",3)
 ;
 N L160 S L160=$T(TDATA1+2),L160=$P(L160,";;",2)
 N H160 S H160=$P(L160,":",2)
 N R160 S R160=$P(L160,":",3),R160=$TR(R160," ")
 D CHKEQ^%ut(R160,$$SHAN(H160,STR))
 ;
 N L224 S L224=$T(TDATA1+3),L224=$P(L224,";;",2)
 N H224 S H224=$P(L224,":",2)
 N R224 S R224=$P(L224,":",3),R224=$TR(R224," ")
 D CHKEQ^%ut(R224,$$SHAN(H224,STR))
 ;
 N L256 S L256=$T(TDATA1+4),L256=$P(L256,";;",2)
 N H256 S H256=$P(L256,":",2)
 N R256 S R256=$P(L256,":",3),R256=$TR(R256," ")
 D CHKEQ^%ut(R256,$$SHAN(H256,STR))
 ;
 N L384 S L384=$T(TDATA1+5),L384=$P(L384,";;",2)
 N H384 S H384=$P(L384,":",2)
 N R384 S R384=$P(L384,":",3),R384=$TR(R384," ")
 D CHKEQ^%ut(R384,$$SHAN(H384,STR))
 ;
 N L512 S L512=$T(TDATA1+6),L512=$P(L512,";;",2)
 N H512 S H512=$P(L512,":",2)
 N R512 S R512=$P(L512,":",3),R512=$TR(R512," ")
 D CHKEQ^%ut(R512,$$SHAN(H512,STR))
 ;
 QUIT
 ;
TDATA1 ; @DATA
 ;;msg::1
 ;;hash:160:DA39A3EE 5E6B4B0D 3255BFEF 95601890 AFD80709
 ;;hash:224:D14A028C 2A3A2BC9 476102BB 288234C4 15A2B01F 828EA62A C5B3E42F
 ;;hash:256:E3B0C442 98FC1C14 9AFBF4C8 996FB924 27AE41E4 649B934C A495991B 7852B855
 ;;hash:384:38B060A7 51AC9638 4CD9327E B1B1E36A 21FDB711 14BE0743 4C0CC7BF 63F6E1DA 274EDEBF E76F65FB D51AD2F1 4898B95B
 ;;hash:512:CF83E135 7EEFB8BD F1542850 D66D8007 D620E405 0B5715DC 83F4A921 D36CE9CE 47D0D13C 5D85F2B0 FF8318D2 877EEC2F 63B931BD 47417A81 A538327A F927DA3E
 ;;-1
 ;
T2 ; @TEST $$SHAN w/ string of abc
 N DATA S DATA=$T(TDATA2+1),DATA=$P(DATA,";;",2)
 N STR,REPS
 S STR=$P(DATA,":",2),REPS=$P(DATA,":",3)
 ;
 N L160 S L160=$T(TDATA2+2),L160=$P(L160,";;",2)
 N H160 S H160=$P(L160,":",2)
 N R160 S R160=$P(L160,":",3),R160=$TR(R160," ")
 D CHKEQ^%ut(R160,$$SHAN(H160,STR))
 ;
 N L224 S L224=$T(TDATA2+3),L224=$P(L224,";;",2)
 N H224 S H224=$P(L224,":",2)
 N R224 S R224=$P(L224,":",3),R224=$TR(R224," ")
 D CHKEQ^%ut(R224,$$SHAN(H224,STR))
 ;
 N L256 S L256=$T(TDATA2+4),L256=$P(L256,";;",2)
 N H256 S H256=$P(L256,":",2)
 N R256 S R256=$P(L256,":",3),R256=$TR(R256," ")
 D CHKEQ^%ut(R256,$$SHAN(H256,STR))
 ;
 N L384 S L384=$T(TDATA2+5),L384=$P(L384,";;",2)
 N H384 S H384=$P(L384,":",2)
 N R384 S R384=$P(L384,":",3),R384=$TR(R384," ")
 D CHKEQ^%ut(R384,$$SHAN(H384,STR))
 ;
 N L512 S L512=$T(TDATA2+6),L512=$P(L512,";;",2)
 N H512 S H512=$P(L512,":",2)
 N R512 S R512=$P(L512,":",3),R512=$TR(R512," ")
 D CHKEQ^%ut(R512,$$SHAN(H512,STR))
 QUIT
 ;
TDATA2 ; @DATA
 ;;msg:abc:1
 ;;hash:160:A9993E36 4706816A BA3E2571 7850C26C 9CD0D89D
 ;;hash:224:23097D22 3405D822 8642A477 BDA255B3 2AADBCE4 BDA0B3F7 E36C9DA7
 ;;hash:256:BA7816BF 8F01CFEA 414140DE 5DAE2223 B00361A3 96177A9C B410FF61 F20015AD
 ;;hash:384:CB00753F 45A35E8B B5A03D69 9AC65007 272C32AB 0EDED163 1A8B605A 43FF5BED 8086072B A1E7CC23 58BAECA1 34C825A7
 ;;hash:512:DDAF35A1 93617ABA CC417349 AE204131 12E6FA4E 89A97EA2 0A9EEEE6 4B55D39A 2192992A 274FC1A8 36BA3C23 A3FEEBBD 454D4423 643CE80E 2A9AC94F A54CA49F
 ;;-1
 ;
T3 ; @TEST $$SHAN w/ long string
 N DATA S DATA=$T(TDATA3+1),DATA=$P(DATA,";;",2)
 N STR,REPS
 S STR=$P(DATA,":",2),REPS=$P(DATA,":",3)
 ;
 N L160 S L160=$T(TDATA3+2),L160=$P(L160,";;",2)
 N H160 S H160=$P(L160,":",2)
 N R160 S R160=$P(L160,":",3),R160=$TR(R160," ")
 D CHKEQ^%ut(R160,$$SHAN(H160,STR))
 ;
 N L224 S L224=$T(TDATA3+3),L224=$P(L224,";;",2)
 N H224 S H224=$P(L224,":",2)
 N R224 S R224=$P(L224,":",3),R224=$TR(R224," ")
 D CHKEQ^%ut(R224,$$SHAN(H224,STR))
 ;
 N L256 S L256=$T(TDATA3+4),L256=$P(L256,";;",2)
 N H256 S H256=$P(L256,":",2)
 N R256 S R256=$P(L256,":",3),R256=$TR(R256," ")
 D CHKEQ^%ut(R256,$$SHAN(H256,STR))
 ;
 N L384 S L384=$T(TDATA3+5),L384=$P(L384,";;",2)
 N H384 S H384=$P(L384,":",2)
 N R384 S R384=$P(L384,":",3),R384=$TR(R384," ")
 D CHKEQ^%ut(R384,$$SHAN(H384,STR))
 ;
 N L512 S L512=$T(TDATA3+6),L512=$P(L512,";;",2)
 N H512 S H512=$P(L512,":",2)
 N R512 S R512=$P(L512,":",3),R512=$TR(R512," ")
 D CHKEQ^%ut(R512,$$SHAN(H512,STR))
 QUIT
 ;
TDATA3 ; @DATA
 ;;msg:abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq:1
 ;;hash:160:84983E44 1C3BD26E BAAE4AA1 F95129E5 E54670F1
 ;;hash:224:75388B16 512776CC 5DBA5DA1 FD890150 B0C6455C B4F58B19 52522525
 ;;hash:256:248D6A61 D20638B8 E5C02693 0C3E6039 A33CE459 64FF2167 F6ECEDD4 19DB06C1
 ;;hash:384:3391FDDD FC8DC739 3707A65B 1B470939 7CF8B1D1 62AF05AB FE8F450D E5F36BC6 B0455A85 20BC4E6F 5FE95B1F E3C8452B
 ;;hash:512:204A8FC6 DDA82F0A 0CED7BEB 8E08A416 57C16EF4 68B228A8 279BE331 A703C335 96FD15C1 3B1B07F9 AA1D3BEA 57789CA0 31AD85C7 A71DD703 54EC6312 38CA3445
 ;;-1
 ;
T4 ; @TEST $$SHAN w/ even longer string
 N DATA S DATA=$T(TDATA4+1),DATA=$P(DATA,";;",2)
 N STR,REPS
 S STR=$P(DATA,":",2),REPS=$P(DATA,":",3)
 ;
 N L160 S L160=$T(TDATA4+2),L160=$P(L160,";;",2)
 N H160 S H160=$P(L160,":",2)
 N R160 S R160=$P(L160,":",3),R160=$TR(R160," ")
 D CHKEQ^%ut(R160,$$SHAN(H160,STR))
 ;
 N L224 S L224=$T(TDATA4+3),L224=$P(L224,";;",2)
 N H224 S H224=$P(L224,":",2)
 N R224 S R224=$P(L224,":",3),R224=$TR(R224," ")
 D CHKEQ^%ut(R224,$$SHAN(H224,STR))
 ;
 N L256 S L256=$T(TDATA4+4),L256=$P(L256,";;",2)
 N H256 S H256=$P(L256,":",2)
 N R256 S R256=$P(L256,":",3),R256=$TR(R256," ")
 D CHKEQ^%ut(R256,$$SHAN(H256,STR))
 ;
 N L384 S L384=$T(TDATA4+5),L384=$P(L384,";;",2)
 N H384 S H384=$P(L384,":",2)
 N R384 S R384=$P(L384,":",3),R384=$TR(R384," ")
 D CHKEQ^%ut(R384,$$SHAN(H384,STR))
 ;
 N L512 S L512=$T(TDATA4+6),L512=$P(L512,";;",2)
 N H512 S H512=$P(L512,":",2)
 N R512 S R512=$P(L512,":",3),R512=$TR(R512," ")
 D CHKEQ^%ut(R512,$$SHAN(H512,STR))
 QUIT
 ;
TDATA4 ; @DATA
 ;;msg:abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu:1
 ;;hash:160:A49B2446 A02C645B F419F995 B6709125 3A04A259
 ;;hash:224:C97CA9A5 59850CE9 7A04A96D EF6D99A9 E0E0E2AB 14E6B8DF 265FC0B3
 ;;hash:256:CF5B16A7 78AF8380 036CE59E 7B049237 0B249B11 E8F07A51 AFAC4503 7AFEE9D1
 ;;hash:384:09330C33 F71147E8 3D192FC7 82CD1B47 53111B17 3B3B05D2 2FA08086 E3B0F712 FCC7C71A 557E2DB9 66C3E9FA 91746039
 ;;hash:512:8E959B75 DAE313DA 8CF4F728 14FC143F 8F7779C6 EB9F7FA1 7299AEAD B6889018 501D289E 4900F7E4 331B99DE C4B5433A C7D329EE B6DD2654 5E96E55B 874BE909
 ;;-1
T5 ; @TEST $$LSHAN w/ 1MiB str of 'a'
 N DATA S DATA=$T(TDATA5+1),DATA=$P(DATA,";;",2)
 N STR,REPS
 S STR=$P(DATA,":",2),REPS=$P(DATA,":",3)
 N NBLOCKS
 D TMPLOAD("XLFMSG",1024,STR,REPS,.NBLOCKS)
 ;
 N L160 S L160=$T(TDATA5+2),L160=$P(L160,";;",2)
 N H160 S H160=$P(L160,":",2)
 N R160 S R160=$P(L160,":",3),R160=$TR(R160," ")
 D CHKEQ^%ut(R160,$$LSHAN(H160,"XLFMSG",NBLOCKS))
 ;
 N L224 S L224=$T(TDATA5+3),L224=$P(L224,";;",2)
 N H224 S H224=$P(L224,":",2)
 N R224 S R224=$P(L224,":",3),R224=$TR(R224," ")
 D CHKEQ^%ut(R224,$$LSHAN(H224,"XLFMSG",NBLOCKS))
 ;
 N L256 S L256=$T(TDATA5+4),L256=$P(L256,";;",2)
 N H256 S H256=$P(L256,":",2)
 N R256 S R256=$P(L256,":",3),R256=$TR(R256," ")
 D CHKEQ^%ut(R256,$$LSHAN(H256,"XLFMSG",NBLOCKS))
 ;
 N L384 S L384=$T(TDATA5+5),L384=$P(L384,";;",2)
 N H384 S H384=$P(L384,":",2)
 N R384 S R384=$P(L384,":",3),R384=$TR(R384," ")
 D CHKEQ^%ut(R384,$$LSHAN(H384,"XLFMSG",NBLOCKS))
 ;
 N L512 S L512=$T(TDATA5+6),L512=$P(L512,";;",2)
 N H512 S H512=$P(L512,":",2)
 N R512 S R512=$P(L512,":",3),R512=$TR(R512," ")
 D CHKEQ^%ut(R512,$$LSHAN(H512,"XLFMSG",NBLOCKS))
 QUIT
 ;
TDATA5 ; @DATA
 ;;msg:a:1000000
 ;;hash:160:34AA973C D4C4DAA4 F61EEB2B DBAD2731 6534016F
 ;;hash:224:20794655 980C91D8 BBB4C1EA 97618A4B F03F4258 1948B2EE 4EE7AD67
 ;;hash:256:CDC76E5C 9914FB92 81A1C7E2 84D73E67 F1809A48 A497200E 046D39CC C7112CD0
 ;;hash:384:9D0E1809 716474CB 086E834E 310A4A1C ED149E9C 00F24852 7972CEC5 704C2A5B 07B8B3DC 38ECC4EB AE97DDD8 7F3D8985
 ;;hash:512:E718483D 0CE76964 4E2E42C7 BC15B463 8E1F98B1 3B204428 5632A803 AFA973EB DE0FF244 877EA60A 4CB0432C E577C31B EB009C5C 2C49AA2E 4EADB217 AD8CC09B
 ;;-1
 ;
 ;=============================
TMPLOAD(SUB,BLKSIZE,STR,REPS,NBLOCKS) ;Load the ^TMP global.
 N STRLEN
 K ^TMP($J,SUB)
 S STRLEN=$L(STR)
 N LEN S LEN=STRLEN*REPS
 I LEN'>BLKSIZE S ^TMP($J,SUB,1)=STR,NBLOCKS=1 Q
 N IND,JND,TEMP
 S NBLOCKS=0,TEMP=""
 F IND=1:1:REPS D
 . F JND=1:1:STRLEN D
 .. S TEMP=TEMP_$E(STR,JND)
 .. I $L(TEMP)=BLKSIZE S NBLOCKS=NBLOCKS+1,^TMP($J,SUB,NBLOCKS)=TEMP,TEMP=""
 I $L(TEMP)>0 S NBLOCKS=NBLOCKS+1,^TMP($J,SUB,NBLOCKS)=TEMP
 Q
 ;
