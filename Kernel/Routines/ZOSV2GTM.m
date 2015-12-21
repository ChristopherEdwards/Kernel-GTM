%ZOSV2 ;ISF/RWF - More GT.M support routines ;10/18/06  14:29
 ;;8.0;KERNEL;**275,425**;Jul 10, 1995;Build 18
 Q
 ;SAVE: DIE open array reference.
 ;      XCN is the starting value to $O from.
SAVE(RN) ;Save a routine
 N %,%F,%I,%N,SP,$ETRAP
 S $ETRAP="S $ECODE="""" Q"
 S %I=$I,SP=" ",%F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 O %F:(NEWVERSION:NOREADONLY:NOWRAP:STREAM) U %F
 F  S XCN=$O(@(DIE_XCN_")")) Q:XCN'>0  S %=@(DIE_XCN_",0)") Q:$E(%,1)="$"  I $E(%)'=";" W %,!
 C %F ;S %N=$$NULL
 ZLINK RN
 ;C %N
 U %I
 Q
NULL() ;Open and use null to hide talking.  Return open name
 ;Doesn't work for compile errors, which go to stderr
 N %N S %N=$S($ZV["VMS":"NLA0:",1:"/dev/null")
 O %N U %N
 Q %N
 ;
DEL(RN) ;Delete a routine file, both source and object; doesn't work for object files in shared libraries, or for OpenVMS
 N %F,%P,%ZR,$ETRAP
 S $ETRAP="S $ECODE="""" Q",%F=$TR($E(RN,1),"%","_")_$E(RN,2,$L(RN))
 D SILENT^%RSEL(RN) I %ZR S %P=%ZR(RN)_%F_".m" O %P C %P:DELETE
 D SILENT^%RSEL(RN,"OBJ") I %ZR S %P=%ZR(RN)_%F_".o" O %P C %P:DELETE
 Q
 ;LOAD: DIF open array to receive the routine lines.
 ;      XCNP The starting index -1.
LOAD(RN) ;Load a routine
 N %
 S %N=0 F  S %=$T(+$I(%N)^@RN) Q:$L(%)=0  S @(DIF_$I(XCNP)_",0)")=%
 Q
 ;
LOAD2(RN) ;Load a routine
 N %,%1,%F,%N,$ETRAP
 S %I=$I,%F=$$RTNDIR^%ZOSV()_$TR(RN,"%","_")_".m"
 O %F:(READONLY):1 Q:'$T  U %F
 F  R %1 Q:$ZEOF  S @(DIF_$I(XCNP)_",0)")=$TR(%1,$C(9)," ")
 C %F U:$L(%I) %I
 Q
 ;
RSUM(RN) ;Calculate a RSUM value
 N %,DIF,XCNP,%N,Y,$ETRAP K ^TMP("RSUM",$J)
 S $ETRAP="S $ECODE="""" Q"
 S Y=0,DIF="^TMP(""RSUM"",$J,",XCNP=0 D LOAD2(RN)
 F %=1,3:1 S %1=$G(^TMP("RSUM",$J,%,0)),%3=$F(%1," ") Q:'%3  S %3=$S($E(%1,%3)'=";":$L(%1),$E(%1,%3+1)=";":$L(%1),1:%3-2) F %2=1:1:%3 S Y=$A(%1,%2)*%2+Y
 K ^TMP("RSUM",$J)
 Q Y
 ;
RSUM2(RN) ;Calculate a RSUM2 value
 N %,DIF,XCNP,%N,Y,$ETRAP K ^TMP("RSUM",$J)
 S $ETRAP="S $ECODE="""" Q"
 S Y=0,DIF="^TMP(""RSUM"",$J,",XCNP=0 D LOAD2(RN)
 F %=1,3:1 S %1=$G(^TMP("RSUM",$J,%,0)),%3=$F(%1," ") Q:'%3  S %3=$S($E(%1,%3)'=";":$L(%1),$E(%1,%3+1)=";":$L(%1),1:%3-2) F %2=1:1:%3 S Y=$A(%1,%2)*(%2+%)+Y
 K ^TMP("RSUM",$J)
 Q Y
 ;
TEST(RN) ;Special GT.M Test to see if routine is here.
 N %ZR
 D SILENT^%RSEL(RN) Q $S(%ZR:%ZR(RN)_$TR($E(RN,1),"%","_")_$E(RN,2,$L(RN))_".m",1:"")
