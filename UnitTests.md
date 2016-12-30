Unit Tests are called using ^ZZUTZOSV. There are two routines that contain unit
tests: ZZUTZOSV and ZZUTZOSV2. They test every single change that was made in
this project.

Coverage can be calculated by COV^%ut. Please note that M-Unit was modified in
order for  routines to be examined for coverage by reference in COV^%ut1. This
change has not been published as of the time of this writing.

There are certain tests that may fail. You need to be aware of which ones:

 * TMTRAN - Make sure that Taskman is running. This fails occassionally because
 taskman is given 3 seconds to complete a task and sometimes can't complete it
 in that time.
 * ZSY - It counts processes before stopping them and after. If you didn't have
 any other processes running (i.e. Taskman was also down), you will get a failure
 here. Also, if you have an M process that is zsystemed out into the shell, you
 won't be able to kill it as well. Just keep that in mind.
 * RSAENC - RSA Encryption. This fails on certain versions of openssl. I haven't
 figured out yet which ones; but they ask you for a password when they shouldn't.
 If that happens to you, press CTRL-C, and then type ZC. Your text will be
 repeated, that's okay. To restore sanity, run ZSY "stty sane" when you are done.

Tests:
SETNM - Set Environment Name------------------------------------  [OK] .123ms
ZRO1 - $ZROUTINES Parsing Single Object Multiple dirs.----------  [OK] .103ms
ZRO2 - $ZROUTINES Parsing 2 Single Object Single dir.------------  [OK] .09ms
ZRO3 - $ZROUTINES Parsing Shared Object/Code dir.---------------  [OK] .085ms
ZRO4 - $ZROUTINES Parsing Single Directory by itself.-----------  [OK] .069ms
ZRO5 - $ZROUTINES Parsing Leading Space.------------------------  [OK] .085ms
ZRO7 - $ZROUTINES Shared Object Only.---------------------------  [OK] .069ms
ZRO8 - $ZROUTINES No shared object.-----------------------------  [OK] .073ms
ZRO9 - $ZROUTINES Shared Object First.--------------------------  [OK] .076ms
ZRO10 - $ZROUTINES Shared Object First but multiple rtn dirs.---  [OK] .082ms
ZRO99 - $$RTNDIR^%ZOSV Shouldn't be Empty.----------------------  [OK] .078ms
ACTJ - Default path through ACTJ^ZOSV.--------------------------  [OK] .081ms
ACTJ0 - Force ^XUTL("XUSYS","CNT") to 0 to force algorithm to run...[OK] 18.727ms
AVJ - Available Jobs.-------------------------------------------  [OK] .124ms
DEVOK - Dev Okay..----------------------------------------------  [OK] .067ms
DEVOPN - Show open devices.-------------------------------------  [OK] .071ms
GETPEER - Get Peer.---------------------------------------------  [OK] .055ms
PRGMODE - Prog Mode
.-----------------------------------------------------------  [OK] 3001.927ms
JOBPAR - Job Parameter -- Dummy; doesn't do anything useful..---  [OK] .177ms
LOGRSRC - Turn on Resource Logging------------------------------  [OK] .041ms
ORDER - Order.-------------------------------------------------  [OK] 1.038ms
DOLRO - Ensure symbol table is saved correctly.----------------  [OK] 6.442ms
TMTRAN - Make sure that Taskman is running..-----------------  [OK] 570.948ms
GETENV - Test GETENV.-------------------------------------------  [OK] .104ms
OS - OS.--------------------------------------------------------  [OK] .049ms
VERSION - VERSION...--------------------------------------------  [OK] .062ms
SID - System ID.------------------------------------------------  [OK] .051ms
UCI - Get UCI/Vol.----------------------------------------------  [OK] .048ms
UCICHECK - Noop.------------------------------------------------  [OK] .046ms
PARSIZ - PARSIZE NOOP.------------------------------------------  [OK] .042ms
NOLOG - NOLOG NOOP.---------------------------------------------  [OK] .041ms
SHARELIC - SHARELIC NOOP.----------------------------------------  [OK] .04ms
PRIORITY - PRIORITY NOOP.---------------------------------------  [OK] .042ms
PRIINQ - PRIINQ() NOOP.-----------------------------------------  [OK] .044ms
BAUD - BAUD NOOP.-----------------------------------------------  [OK] .041ms
SETTRM - Set Terminators.---------------------------------------  [OK] .198ms
LGR - Last Global Reference.------------------------------------  [OK] .109ms
EC - $$EC.------------------------------------------------------  [OK] .203ms
ZTMGRSET - ZTMGRSET Renames Routines on GT.M.-----------------  [OK] 23.053ms
ZHOROLOG - $ZHOROLOG Functions.....-----------------------------  [OK] .092ms
TEMP - getting temp directory.----------------------------------  [OK] .167ms
PASS - PASTHRU and NOPASS.---------------------------------------  [OK] .07ms
NSLOOKUP - Test DNS Utilities.......-------------------------  [OK] 168.686ms
IPV6 - Test GT.M support for IPV6.------------------------------  [OK] .113ms
SSVNJOB - Replacement for ^$JOB in XQ82..---------------------  [OK] 16.619ms
OPENH - Read a Text File in w/ Handle
..--------------------------------------------------------------  [OK] 9.66ms
OPENNOH - Read a Text File w/o a Handle
..-------------------------------------------------------------  [OK] 5.061ms
OPENBLOR - Read a File as a binary device (FIXED WIDTH)
..--------------------------------------------------------------  [OK] .696ms
OPENBLOW - Write a File as a binary device (Use Capri zip file in 316.18)
.----------------------------------------------------------------  [OK] .92ms
OPENBLOV - Write and Read a variable record file
.---------------------------------------------------------------  [OK] 7.17ms
OPENDF - Open File from Default HFS Directory.------------------  [OK] .246ms
OPENSUB - Open file with a Specific Subtype....-----------------  [OK] 7.496ms
OPENDLM - Forget delimiter in Path..----------------------------  [OK] 5.518ms
OPENAPP - Open with appending.----------------------------------  [OK] 4.853ms
PWD - Get Current Working Directory.----------------------------  [OK] .061ms
DEFDIR - Default Directory.....----------------------------------  [OK] .22ms
LIST - LIST^%ZISH.....---------------------------------------  [OK] 271.714ms
MV - MV^%ZISH..-------------------------------------------------  [OK] 5.15ms
FTGGTF - $$FTG^%ZISH & $$GTF^%ZISH......------------------------  [OK] 55.865ms
GATF......------------------------------------------------------  [OK] 18.086ms
DEL1......-----------------------------------------------------  [OK] 4.116ms
DEL - Delete files we created in the tests.....---------------  [OK] 13.262ms
DELERR - Delete Error.-------------------------------------------  [OK] .17ms
BROKER - Test the new GT.M MTL Broker.....
-------------------------------------------------------------  [OK] 705.778ms
XUSHSH - Top of XUSHSH.------------------------------------------  [OK] .09ms
SHA - SHA-1 and SHA-256 in Hex and Base64....----------------  [OK] 153.246ms
BASE64 - Base 64 Encode and Decode..---------------------------  [OK] 4.243ms
RSAENC - Test RSA Encryption........-------------------------  [OK] 449.899ms
AESENC - Test AES Encryption.---------------------------------  [OK] 16.151ms
NOOP - Top doesn't do anything..--------------------------------  [OK] .044ms
SAVE1 - Save a Routine normal......-----------------------------  [OK] 1.85ms
SAVE2 - Save a Routine with syntax errors -- should not show..  [OK] 20.367ms
LOAD - Load Routine..------------------------------------------  [OK] 1.581ms
RSUM - Checksums..----------------------------------------------  [OK] .527ms
TESTR - Test existence of routine.------------------------------  [OK] .301ms
DEL - Test Super Duper Deleter..------------------------------  [OK] 13.485ms
ZSY (Not shown -- produces a bunch of garbage to the screen).

Ran 2 Routines, 77 Entry Tags
Checked 152 tests, with 0 failures and encountered 0 errors.

ORIG: 1072
LEFT: 332
COVERAGE PERCENTAGE: 69.03


BY ROUTINE:
%ZISH           98.35%  119 out of 121
%ZOSV           90.34%  131 out of 145
%ZOSV2         100.00%  51 out of 51
XLFIPV          24.68%  39 out of 158
XLFNSLK          9.09%  12 out of 132
XQ82            75.71%  53 out of 70
XUSHSH         100.00%  64 out of 64
ZSY             96.00%  168 out of 175
ZTMGRSET        66.03%  103 out of 156

