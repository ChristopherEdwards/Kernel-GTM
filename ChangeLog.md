PLEASE NOTE: UNLESS OTHERWISE SPECIFIED, ALL NEW FEATURES REQUIRE GT.M 6.0-000 OR 
HIGHER! GT.M 6.0-000 was released on 27 October 2014. No bug fixes will be
provided for those running an older version of GT.M. Authors are noted in
parentheses.

#XLFIPV (C Edwards)
GT.M IPv6 Support (mainly checks GT.M version and env var gtm_ipv4_only).
Previously, only Cache. GT.M added IPv6 support in version 6.0-003.

#XLFNSLK (C Edwards)
GT.M IPv6 Lookup implmementation using `dig`. Previously, only Cache.

#XQ82 (S Habiel)
Replacement of M95 ^$JOB with $ZGETJPI(%J,"ISPROCALIVE) for GT.M. Cache still
checks $D(^$JOB(%J)). Previously, the ^$J code wasn't even checked for GT.M
as it was recognized that GT.M does not have it.

#XUSHSH (S Habiel)
Implementation of redacted code, but only for GT.M. I don't have access
to the Cache source code from the VA. Previously, all entry points were empty.

 * SHAHASH implemented for GT.M using `shasum`. Conversion to base64 done using
 `xxd` to get the binary from the hex value and then `base64` to encode it.
 * B64ENCD & B64DECD implemented using `base64`
 * RSAENCR & RSADECR implemented using `openssl pkeyutl`
 * AESENCR & AESDECR implemented using `openssl enc -e/-d -aes-256-cbc`

#ZISHGUX (%ZISH) [previously ZISHGTM] (S Habiel)
Many changes throughout routine.
 
OPEN re-implemented:

 * Default is now STREAM:NOWRAP, not VARIABLE:WRAP, which was the previous default. (Actually, it's the GT.M default; and thus inherited.)
 * GT.M does not support WIDTH as a open time parameter. Only with Use. WIDTH uses replaced with RECORDSIZE.
 * Reads with Width specified that would normally be STREAM:NOWRAP are changed to VARIABLE:NOWRAP:RECORDSIZE=#.
 * Binary reads are still FIXED:NOWRAP:RECORDSIZE=#. That has not changed, 
 except for removing the hardcoded recordsize if width is specified.
 If WIDTH isn't specified, then the default RECORDSIZE for binary reads will be
 512 bytes.

$$DEL1 entry point added. Previously it only existed in ZISHONT. Used by KIDS.

$$MV uses a pipe rather than ZSY, which was used previously.

CD PEP/SR added.

$$PWD now works. It previously never worked.

$$DEFDIR now will crash if given a bad directory. Previously, it returned '/'
when given a bad directory, which was a bad bug, as that means the root
directory. We can't return an empty string, because that will be interpreted
by GT.M as no directory, and therefore, a write/read will happen in the current
directory, which is not what a programmer will want. Crashing is the best option
here.

$$QS^DDBRAP and $$QL^DDBRAP (!!!) replaced with $QS and $QL

$$READNXT will not apply global overflows during reads unless the read line
overflows the global's maximum record size. Previously, overflows happened on
any line longer than 255 character. Record size is determined using $VIEW on
the specific global following by a call to ^%DSEWRAP.

$$GTF had a bug where it stopped early if a global wasn't strictly following
an ascending cardinal numeric orders (1, 2, 3, 4). This is now fixed. I have
some concerns that the new algorithm may be slower, but this remains to be seen.

#ZISTCPS (%ZISTCP) (S Habiel)
Implementation of a Multi-process Server in GT.M. Requires GT.M 6.1.

#ZOSV2GTM (%ZOSV2) (S Habiel, KS Bhaskar)
SAVE:

 * Open parameters are now NEWVERSION:NOWRAP:STREAM; previously they were
   newversion:noreadonly:blocksize=2048:recordsize=2044.
 * No tabs are added if they are not in the original source code. Previously,
   tabs were always added, in violation of all M standards.
 * ZLINK suppresses compilation errors now. Previously, it didn't.

DEL: Completely rewritten to recursively delete all routines with the specified
name from all GT.M directories. Object files are deleted too; and the current
process is given a fake empty routine in order to evict the one in the current
process's image. Previous version was much more primitive.

LOAD and LOAD2: Avoid using $INCREMENT as using it with globals results in
unpredictable subscripts upon multiple invocation. Previously used $INCREMENT.

TEST: Reimplemented to use SILENT^%RSEL(RN). Previously used a different 
algorithm that doesn't account for multiple directories.

#ZOSVGUX (%ZOSV) (C Edwards, KS Bhaskar, S Habiel)
$$ACTJ on Linux uses ipcs -mi on the output of mupip ftok to return the number
of processes attached to the shared memory segment accessed by the default
segment of the database. On macOS, since ipcs doesn't support similar
functionality, it uses lsof -t to count the number of processes accessing the
default segment. The result is cached for one hour. In that hour, we rely on
VistA's XUSCNT mechanism to keep track of the number of processes. Previously;
ZSYSTEM with "ps cef -C mumps|wc" onto a file on disk, which was then read back;
was used.

$$RTNDIR is very reliable now. Previously, a whole host of conditions can make
it fail.

$$TEMP has not been updated with a Kernel Patch released a few years ago that
changed the "DEV" node in KSP (8989.3) to be 2 pieced. Now this is fixed.

JOBPAR reads from /proc/$J/comm rather than use ps. NB: Won't work on macOS.

DOLRO was optimized by removing the $DATA check, which is not necessary when
the system just told you that a local variable exists. Another faster algorithm,
which has not been extensively tested, is in the comments after DOLRO. Experiments
show that the difference between the two algorithms is about 6ms.

GETENV %HOST (Box Name) is now obtained from the environment variable gtm_sysid.
Previously, it got the hostname from the operating system. This caused several
problems: many machines change their hostnames dynamically; and making a 
hostname call is expensive for this frequently called API.

$$VERSION API was fixed to correctly return the version number if 0 or nothing
is passed in, and the operating system if 1 is passed in. Like this:

```
GTM>W $$VERSION^%ZOSV(0)
6.3-000A
GTM>W $$VERSION^%ZOSV(1)
Linux x86_64
```

T0, T1, ZHDIF are implemented if you have GT.M greater than v6.2 or you have
the GT.M POSIX plug-in installed. To be honest, I never tested that logic with
the plugin.

DEVOPN was modified to remove CLOSED devices, which ZSHOW "D" keeps.

$$RETURN is now a public API, and it uses a pipe rather than ZSY and then a
read back. A crucial bug that hit multiple users, where the device was closed,
did not return control to the last opened device in IO, resulting in some CPRS
crashes when code won't write to the NULL device anymore. $$RETURN also allows
you to ask whether the command succeeded, rather than what the output is, by
passing in a second parameter: Passing this in, you will get the output of
$ZCLOSE. $ZCLOSE was added to GT.M 6.1. The $ZCLOSE is not guarded by a version
check, since I am hoping that people who use it will specify the minimum
version of their software. $$RETURN is called by %ZISH, XLFNSLK, and XUSHSH.

STRIPCR has been removed. It was not a public API, and was not used in my time
in the VistA community--which prefers the Utility dos2unix. And in any case,
GT.M will support CR's in routines in the next release.

#ZSY & ZUGTM (ZU) (KS Bhaskar, S Habiel)
ZSY was extensively modified:

 * New JOBEXAM section called by ZU; in order to make maintenance of the
   code easier.
 * All VMS entry points removed.
 * Support for $ZMODE (Interactive process vs Background Process)
 * CLOSED devices, $PRINCIPAL, and the ps command are not shown as open devices
   in the process listing. Previously all devices showed up.
 * Removal of Paging. I am sure most people today don't use dumb terminal
   emulators.
 * Now, only processes accessing the current database are shown; rather than
   every single M process on the system in which we are running.
 * Interrupt is done using signal 10 (Linux) or signal 30 (macOS) against all
   processes reported by lsof to be accessing the current default segment of the
   database. Previously, all mumps processes were interrupted.
 * Calls to ps with pids to get other process' information are chunked together in order
   to provide speed when calling ps. The chucks are not larger than 970 characters
   each, in order to accomodate the maximum GT.M pipe length of 1023.
 * Interrupts were done while collecting and printing the data. They have now
   been moved to INTRPT(%J) and INTRPTALL(.procs). The latter returns to you
   the list of processes interrupted, and as such is killing two birds with one
   stone.
 * HALTALL is a new entry point that gracefully exits VistA processes by calling
   a cleanup routine in XUSCLEAN and then calling HALT^ZU.

ZUGTM: JOBEXAM calls NTRUPT^ZSY (Lloyd Milligan's ZSY), or if not, tries 
JOBEXAM^ZSY. If neither of these are present, it will run a default interrupt.

#ZTLOAD1 (C Edwards)
TSTART and TCOMMIT do not comply with the M standard; and have been removed
as GT.M, which implements the M standard in Transaction Processing, did not
accept them.

#ZTM6 (C Edwards)
Same as ZTLOAD1.

#ZTMGRSET (C Edwards and S Habiel)
Maximum patch number changed from 999 to 9999999.

%ZISH routine is now ZISHGUX; previously it was ZISHGTM.

COPY uses OPEN, ZPRINT, and CLOSE, rather than the "cp" command. ZLINK in COPY
suppresses compilation errors. ZLINK's effect on $ZSOURCE is undone so that
your previous $ZSOURCE stays as it is.

$$R fixed for GT.M.

# Unit Tests (C Edwards and S Habiel)
EVERY SINGLE CHANGE HAS A UNIT TEST, except ZTM6, which deals with load
balancers, which GT.M cannot use.

Routines are ZZUTZOSV and ZZUTZOSV2. D ^ZZUTZOSV is the entry point. Coverage calculations
can be done by running COV^ZZUTZOSV. Note that it uses a modified M-Unit that
can accomodate a passed by reference list of routines.

See separate docuemnt for Unit Tests.
