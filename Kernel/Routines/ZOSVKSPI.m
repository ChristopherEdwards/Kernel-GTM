ZOSVKSPI ;BP/RAK/JML - Post install routine ;9/1/2015
 ;;8.0;KERNEL;**568**;Jul 26, 2004;Build 48
 ;
EN ;-- entry point for post-install
 ;
 D BMES^XPDUTL(" Begin Post-Install...")
 D SAVE
 D MES^XPDUTL(" Post-Install complete!")
 ;
 Q
 ;
SAVE ;-save correct files as '%' routines 
 ;
 N %D,%S,SCR,ZTOS
 S ZTOS=$$OSNUM^ZTMGRSET
 ; if not supported
 I ZTOS'=3 D  Q
 .D MES^XPDUTL(" "_$P($T(@ZTOS^ZTMGRSET),";",3)_" is not supported.  No routine saved!")
 ; supported
 ; - don't need to send/recompile all 
 ;   S %D="%ZOSVKSE^%ZOSVKSS^%ZOSVKSD^%ZOSVKR",%S="ZOSVKSOE^ZOSVKSOS^ZOSVKSD^ZOSVKRO",SCR="I 1"
 S %D="%ZOSVKSE^%ZOSVKSD^%ZOSVKR",%S="ZOSVKSOE^ZOSVKSD^ZOSVKRO",SCR="I 1"
 D MOVE^ZTMGRSET
 D MES^XPDUTL("          for "_$P($T(@ZTOS^ZTMGRSET),";",3)_".")
 ;
 Q
 ;
