XUSAML ;ISD/HGW Kernel SAML Token Implementation ;07/05/17  12:53
 ;;8.0;KERNEL;**655,659,630**;Jul 10, 1995;Build 13
 ;Per VA Directive 6402, this routine should not be modified.
 ;
 ; Implements the Kernel SAML Token message framework for the Identification and
 ; Access Management (IAM) Single Sign-On (SSO) security model.
 ;
 ; External References:
 ;     ^%DT                Supported ICR #10003
 ;     $$ATTRIB^MXMLDOM    Supported ICR #3561
 ;     $$CHILD^MXMLDOM     Supported ICR #3561
 ;     $$EN^MXMLDOM        Supported ICR #3561
 ;     $$NAME^MXMLDOM      Supported ICR #3561
 ;     $$SIBLING^MXMLDOM   Supported ICR #3561
 ;     $$TEXT^MXMLDOM      Supported ICR #3561
 ;     $$VALUE^MXMLDOM     Supported ICR #3561
 ;     DELETE^MXMLDOM      Supported ICR #3561
 ;     TEXT^MXMLDOM        Supported ICR #3561
 ;     $$FMADD^XLFDT       Supported ICR #10103
 ;     $$NOW^XLFDT         Supported ICR #10103
 ;     $$TZ^XLFDT          Supported ICR #10103
 ;     $$TITLE^XLFSTR      Supported ICR #10104
 ;     $$LOW^XLFSTR        Supported ICR #10104
 ;     $$INVERT^XLFSTR     Supported ICR #10104
 ;     $$UP^XLFSTR         Supported ICR #10104
 ;     $$VALIDATE^XUCERT   Private (XU to XU)
 ;     $$AUTH^XUESSO2      Private (XU to XU)
 ;
 Q
EN(DOC) ;Function. Main entry point
 ;This function parses and processes the VA Identity and Access Management (IAM) STS SAML token
 ; (version 2.0) and returns the DUZ of the user, if found. It does not log the user into VistA.
 ; Input:     DOC     = Closed reference to global root containing XML document (loaded STS SAML Token)
 ;                      Example: S Y=$$EN^XUSAML($NA(^TMP($J,1)))
 ; Return:    Fail    = "-1^Error Message"
 ;            Success = DUZ
 ;ZEXCEPT: XOBDATA ;environment variable
 N HDL,XASSRT,XUPN,Y
 K ^TMP("XUSAML",$J)
 S Y="-1^Error parsing STS SAML Token",XUPN="",XASSRT=""
 S XOBDATA("XOB RPC","SECURITY","STATE")="notauthenticated"
 S XOBDATA("XOB RPC","SAML","ASSERTION")="notvalidated"
 ;--- Call parser
 S HDL=$$EN^MXMLDOM(DOC,"W")
 I HDL>0 D
 . D ND(HDL,1,1,.XUPN,.XASSRT) ;Traverse and process document
 . S Y="-1^Invalid SAML assertion"
  . D VALASSRT(.XASSRT,DOC) ;Validate SAML assertion
  . I $G(XOBDATA("XOB RPC","SAML","ASSERTION"))="validated" D
  . . S Y=$$FINDUSER()
 . D DELETE^MXMLDOM(HDL)
 I +Y>0 S XOBDATA("XOB RPC","SECURITY","STATE")="authenticated"
 K ^TMP("XUSAML",$J)
 Q Y
ND(HDL,ND,FS,XUPN,XASSRT) ;SR. Traverse tree
 N CH,SIB,TX
 D SH(HDL,ND,.XUPN,.XASSRT)
 S CH=0
 S CH=$$CHILD^MXMLDOM(HDL,ND,CH)
 I CH D ND(HDL,CH,1,.XUPN,.XASSRT)
 Q:'FS  ;Don't follow the siblings of siblings
 S SIB=ND
 F  S SIB=$$SIBLING^MXMLDOM(HDL,SIB) Q:'SIB  D ND(HDL,SIB,0,.XUPN,.XASSRT)
 Q
SH(HDL,ND,XUPN,XASSRT) ;SR. Process node elements
 ;ZEXCEPT: XOBDATA ;environment variable
 N ELE,I,NM,V,VV,XCHILD,XERR,XTEXT,XVALUE
 S ELE=$$NAME^MXMLDOM(HDL,ND)
 ; --------------------  saml:Subject Event Processing  ---------------------------
 I (ELE="Subject")!(ELE="saml:Subject")!(ELE="ns2:Subject") D  Q  ;Subject element is required
 . S XASSRT("Subject")="yes"
 ;
 ; --------------------  saml:Subject Confirmation Data Event Processing  ----------
 I (ELE="SubjectConfirmationData")!(ELE="saml:SubjectConfirmationData")!(ELE="ns2:SubjectConfirmationData") D  Q
 . D EL(HDL,ND,.NM,.XUPN)
 . S XASSRT("Recipient")=$O(^TMP("XUSAML",$J,"Recipient",""))
 . S XASSRT("Address")=$O(^TMP("XUSAML",$J,"Address",""))
 ;
 ; --------------------  saml:Conditions Event Processing  -------------------------
 I (ELE="Conditions")!(ELE="saml:Conditions")!(ELE="ns2:Conditions") D  Q
 . D EL(HDL,ND,.NM,.XUPN)
 . S XASSRT("NotBefore")=$O(^TMP("XUSAML",$J,"NotBefore",""))
 . S XASSRT("NotOnOrAfter")=$O(^TMP("XUSAML",$J,"NotOnOrAfter",""))
 ;
 ; --------------------  saml:AuthnStatement Event Processing  ---------------------
 I (ELE="AuthnStatement")!(ELE="saml:AuthnStatement")!(ELE="ns2:AuthnStatement") D  Q
 . D EL(HDL,ND,.NM,.XUPN)
 . S XASSRT("AuthnInstant")=$O(^TMP("XUSAML",$J,"AuthnInstant",""))
 I (ELE="AuthnContextClassRef")!(ELE="saml:AuthnContextClassRef")!(ELE="ns2:AuthnContextClassRef") D  Q
 . S XUPN="AuthnContextClassRef"
 . D CH(HDL,ND,XUPN)
 . S XASSRT("AuthnContextClassRef")=$G(^TMP("XUSAML",$J,"AuthnContextClassRef"))
 ;
 ; --------------------  saml:Attribute Event Processing  --------------------------
 I (ELE="Attribute")!(ELE="saml:Attribute")!(ELE="ns2:Attribute") D  Q
 . S XCHILD=$$CHILD^MXMLDOM(HDL,ND) ;Identify child (AttributeValue) of node ND
 . S XTEXT="" S XERR=$$TEXT^MXMLDOM(HDL,XCHILD,$NA(VV)) ;Get text of AttributeValue
 . I XERR=1 F I=1:1 Q:'$D(VV(I))  S XTEXT=XTEXT_VV(I)
 . S NM=""
 . F  S NM=$$ATTRIB^MXMLDOM(HDL,ND,NM) Q:'$L(NM)  D  ;Get name of Attribute
 . . I $G(NM)="Name" D
 . . . S XVALUE=$$VALUE^MXMLDOM(HDL,ND,NM)
 . . . S ^TMP("XUSAML",$J,NM,XVALUE)=XTEXT ;Set up the ^TMP global for the Attribute
 Q
CH(HDL,ND,XUPN) ;SR. Process text node
 N I,VV,Y
 I $G(XUPN)'="" D
 . S Y=""
 . D TEXT^MXMLDOM(HDL,ND,$NA(VV))
 . I $D(VV)>2 F I=1:1 Q:'$D(VV(I))  S Y=Y_VV(I)
 . I $P(XUPN,"^",2)="" D
 . . S ^TMP("XUSAML",$J,$P(XUPN,"^",1))=Y
 . E  D
 . . S ^TMP("XUSAML",$J,$P(XUPN,"^",1),$P(XUPN,"^",2))=Y
 Q
EL(HDL,ND,NM,XUPN) ;SR. Process element
 K XUPN S (NM,XUPN)=""
 F  S NM=$$ATTRIB^MXMLDOM(HDL,ND,NM) Q:'$L(NM)  D
 . I $L(NM) S XUPN=NM_"^"_$$VALUE^MXMLDOM(HDL,ND,NM)
 . I $P(XUPN,"^",2)="" D
 . . S ^TMP("XUSAML",$J,$P(XUPN,"^",1))=""
 . E  D
 . . S ^TMP("XUSAML",$J,$P(XUPN,"^",1),$P(XUPN,"^",2))=""
 Q
FINDUSER() ;Function. Identify user
 ;ZEXCEPT: XOBDATA ;environment variable
 N VISTAID,X,XARRY,XAUTH,XCTXT,XDUZ,XEDIPI,XPASS,XC,XT,XUHOME,XUIAM,Z
 I '$$AUTH^XUESSO2() Q "-1^Not an authorized calling routine"
 S Y="-1^User could not be identified"
 S XERR=""
 S DUZ("REMAPP")=""
 S XUIAM=1 ;Do not trigger IAM updates
 S XARRY(1)=$$TITLE^XLFSTR($E($G(^TMP("XUSAML",$J,"Name","urn:oasis:names:tc:xspa:1.0:subject:organization")),1,50)) ;Subject Organization
 S XARRY(2)=$$LOW^XLFSTR($E($G(^TMP("XUSAML",$J,"Name","urn:oasis:names:tc:xspa:1.0:subject:organization-id")),1,50)) ;Subject Organization ID
 S XARRY(3)=$G(^TMP("XUSAML",$J,"Name","uniqueUserId")) ;Unique User ID
 S XARRY(4)=$G(^TMP("XUSAML",$J,"Name","urn:oasis:names:tc:xspa:1.0:subject:subject-id")) ;Subject ID
 S XPASS=$$IDPASS($G(XASSRT("Recipient"))) ;Application ID
 I $G(XPASS)'="" D
 . S XT=$$GETCNTXT^XUESSO2(XPASS)
 . I +XT>0 D
 . . S DUZ("REMAPP")=XT_"^"_$P($G(^XWB(8994.5,XT,0)),U)  ;Identify remote application
 . . S XCTXT=$P($G(^XWB(8994.5,XT,0)),U,2)
 . . I $G(XCTXT)'="" S XARRY(5)=XPASS
 E  S XARRY(5)="" ;Application ID
 S XARRY(6)=$G(^TMP("XUSAML",$J,"Name","urn:va:ad:samaccountname")) ;Network Username
 S XARRY(7)=$G(^TMP("XUSAML",$J,"Name","urn:va:vrm:iam:secid")) ;SecID
 S XARRY(8)=$G(^TMP("XUSAML",$J,"Name","urn:oasis:names:tc:xspa:2.0:subject:npi")) ;NPI
 ;S XARRY(9)=$G(^TMP("XUSAML",$J,"Name","SSN")) ;SSN is not part of STS Token specification v2.0
 S XARRY(10)=$G(^TMP("XUSAML",$J,"Name","upn")) ;Active Directory User Principle Name (UPN)
 S XARRY(11)=$G(^TMP("XUSAML",$J,"Name","email")) ;E-Mail Address
 ;S ???=$G(^TMP("XUSAML",$J,"Name","urn:oasis:names:tc:xacml:2.0:subject:role")) ;Role-based access is not yet implemented
 S XAUTH=$$LOW^XLFSTR($G(^TMP("XUSAML",$J,"Name","authnsystem"))) ;SSOi, SSOe, or Other authentication
 S XUHOME=$$LOW^XLFSTR($G(^TMP("XUSAML",$J,"Name","urn:nhin:names:saml:homeCommunityId"))) ;Home Community ID
 S XEDIPI=$G(^TMP("XUSAML",$J,"Name","edipi")) ;DoD CAC card identifier
 S DUZ("MVIICN")=$G(^TMP("XUSAML",$J,"Name","urn:va:vrn:iam:mviicn")) ;ICN
 ;
 I (XUHOME=$P($G(^XTV(8989.3,1,200)),U,3))&(XAUTH="ssoi") D  ;SSOi
 . S XARRY(3)=XARRY(7) ;UID=SecID
 . S XDUZ=$$FINDUSER^XUESSO2(.XARRY) ;Identify existing user
 . ;Do not add new SSOi user on the fly (by design). Use IAM Provisioning application.
 . S DUZ("AUTHENTICATION")="SSOI"
 E  I (XUHOME=$P($G(^XTV(8989.3,1,200)),U,3))&(XAUTH="ssoe") D  ;SSOe
 . I ($L($G(XARRY(1)))<3)!($L($G(XARRY(2)))<3) S XDUZ="-1^Invalid SORG or SORGID" Q
 . S XARRY(3)=XARRY(7) ;UID=SecID
 . I +DUZ("REMAPP")>0 D
 . . S XDUZ=$$FINDUSER^XUESSO2(.XARRY) ;Identify existing user
 . . I (+XDUZ<0)&($G(XARRY(5))'="") S XDUZ=$$ADDUSER^XUESSO2(.XARRY) ;Add new user on the fly
 . . S DUZ("AUTHENTICATION")="SSOE"
 E  I (XARRY(2)["http://")!(XARRY(2)["https://")!((XARRY(2)["urn:oid:")&(XARRY(2)'=$P($G(^XTV(8989.3,1,200)),U,3))) D  ; NHIN
 . I (+DUZ("REMAPP")>0)&(XAUTH="nhin") D
 . . I $G(XARRY(3))="" S XARRY(3)=XARRY(8) ;NHIN: UID is NPI if available (preferred)
 . . I $G(XARRY(3))="" S XARRY(3)=XEDIPI ;NHIN: DoD CAC card identifier
 . . I $G(XARRY(3))="" S XARRY(3)=XARRY(11) ;NHIN: UID is e-mail if available (alternative to NPI)
 . . S XDUZ=$$FINDUSER^XUESSO2(.XARRY) ;Identify user by NPI or Unique User ID
 . . I +XDUZ<0 D
 . . . S XARRY(8)=""
 . . . S XDUZ=$$FINDUSER^XUESSO2(.XARRY) ;Identify user by Unique User ID only
 . . I (+XDUZ<0)&($G(XARRY(5))'="") S XDUZ=$$ADDUSER^XUESSO2(.XARRY) ;Add new user on the fly
 . . S DUZ("AUTHENTICATION")="NHIN"
 Q XDUZ
VALASSRT(XASSRT,DOC) ;Intrinsic Subroutine. Validate SAML assertion
 ;ZEXCEPT: XOBDATA ;environment variable
 N XAUTH,XD,XNOW,XPROOF,XQ
 S XOBDATA("XOB RPC","SAML","AUTHENTICATION TYPE")=$G(^TMP("XUSAML",$J,"Name","authenticationtype"))
 S XOBDATA("XOB RPC","SAML","PROOFING AUTHORITY")=$G(^TMP("XUSAML",$J,"Name","proofingauthority"))
 S XAUTH=$$LOW^XLFSTR($G(^TMP("XUSAML",$J,"Name","authnsystem")))
 S XPROOF=XOBDATA("XOB RPC","SAML","PROOFING AUTHORITY")
 ; Verify Level of Assurance (VA requires LOA-1 through LOA-3, but higher levels are accepted)
 K XOBDATA("XOB RPC","SAML","ASSURANCE LEVEL")
 S XD=$G(^TMP("XUSAML",$J,"Name","assurancelevel")) I (+XD<1)!(+XD="") S XD=1
 S XOBDATA("XOB RPC","SAML","ASSURANCE LEVEL")=XD
 S DUZ("LOA")=XD ;Set LOA environment variable for SIGN-ON log and permissions
 I (XAUTH'="nhin")&(XPROOF'="VA-JLV") D  Q:XQ  ;temporary for pre-SSOe JLV non-VA users
 . S XQ=0
 . ;Validate time stamps (e.g., NotBefore, NotOnOrAfter)
 . S XNOW=$$NOW^XLFDT
 . S XD=$$CONVTIME($G(XASSRT("AuthnInstant"))) I XD=-1 D  Q  ;invalid time stamp
 . . S XQ=1
 . S XD=$$CONVTIME($G(XASSRT("NotBefore"))) I (XD=-1)!(XD>XNOW) D  Q  ;token not valid yet
 . . S XQ=1
 . S XD=$$CONVTIME($G(XASSRT("NotOnOrAfter"))) I (XD=-1)!(XD'>XNOW) D  Q  ;token expired
 . . S XQ=1
 . I '$D(XASSRT("AuthnContextClassRef")) D  Q
 . . S XQ=1
 . ;Validate Digital Signature
 . I '$$VALIDATE^XUCERT(DOC) D  Q
 . . S XQ=1
 . ;Validate Token Issuer (Subject of X509 Certificate used to sign token)
 . I '($G(XOBDATA("XOB RPC","SAML","ISSUER"))[$P($G(^XTV(8989.3,1,200)),U,1)) D  Q
 . . S XQ=1
 . ;Token has been validated
 S XOBDATA("XOB RPC","SAML","ASSERTION")="validated"
 Q
IDPASS(XUA) ;Intrinsic Function. Extract Application ID
 N RETURN,XTD,XTE
 S RETURN=$P($G(XUA),"/",4,99)
 S XTD=$$DT^XLFDT
 S XTE=$$FMADD^XLFDT(XTD,7)
 I $G(RETURN)'="" D
 . S ^XTMP("XUSAMLAPPID",0)=XTE_"^"_XTD_"^SAML Application ID" ;capture and log application ID from SAML token
 . S ^XTMP("XUSAMLAPPID",0,RETURN)=""
 . S RETURN=$$LOW^XLFSTR(RETURN)
 Q RETURN
CONVTIME(TIME) ;Intrinsic Function. Convert XML time to FileMan format
 ;ZEXCEPT: %DT ;environment variable
 N X,XD,XOUT,XT,XZ,Y
 S XZ=0 I $G(TIME)["Z" S XZ=1 ;Zulu time (GMT)
 S XD=$P($G(TIME),"T",1) ;Date
 S XD=$P(XD,"-",2)_"/"_$P(XD,"-",3)_"/"_$P(XD,"-",1) ;Convert date to MM/DD/YYYY
 S XT=$P($G(TIME),"T",2) ;Time
 I XZ=1 S XT=$P(XT,"Z",1) ;Strip "Z" from time
 S X=XD_"@"_XT S %DT="RTS"
 D ^%DT S XOUT=Y
 I XOUT=-1 Q XOUT ;Invalid date/time
 I XZ=1 S XOUT=$$FMADD^XLFDT(XOUT,0,+$E($$TZ^XLFDT,1,3),0,0) ;Adjust from GMT
 K %DT(0)
 Q XOUT
