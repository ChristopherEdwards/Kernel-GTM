Introduction
============

The following APIs are new:

 | API Name           | Released In    | Brief Description                           | Allowed Callers                   |
 | ------------------ | -------------- | ------------------------------------------------------------------------------- |
 | $$RTNDIR^%ZOSV()   | XU\*8.0\*10001 | Returns the VistA Routine Directory in GT.M | Kernel Applications Only          |
 | $$RETURN^%ZOSV()   | XU\*8.0\*10001 | Executes an OS command                      | Kernel Applications Only          |
 | $$DEL1^%ZISH()     | XU\*8.0\*10001 | Simplified file deletion API                | Public                            |
 | $$SIZE^%ZISH()     | XU\*8.0\*10002 | Get size of a file                          | Public                            |
 | $$MKDIR^%ZISH()    | XU\*8.0\*10002 | Create a directory                          | Public                            |
 | $$WGETSYNC^%ZISH() | XU\*8.0\*10002 | Sync an http/https remote directory with a local directory | Public             |

API Listing
===========

$$RTNDIR^%ZOSV(): Returns the VistA Routine Directory in GT.M
-------------------------------------------------------------
Reference Type: Private, Category: OS, Integration Agreement: Sam's List

### Description
This API returns the first writable Routine directory from $ZROUTINES (i.e. $gtmroutines). This is used to save new routines. This API should ONLY be used by Kernel utilities. Other APIs are used internally to decompose $gtmroutines.

### Format
`$$RTNDIR^ZOSV()`

### Input Parameters
None

### Output
Routine directory

### Example
```
>W $$RTNDIR^%ZOSV()
/var/db/wv201602//r/
```
$$RETURN^%ZOSV(): Execute an OS command
---------------------------------------
Reference Type: Private, Category: OS, Integration Agreement: Sam's List

### Description
This API runs an operating system command and returns either the first line of the output or returns the status. This API is extensively used by Kernel APIs on GT.M to provide various OS services. This API should not be used outside the Kernel. Please consult the hardhats list if you need to that; this usually means that the Kernel doesn't provide an API that should be provided.

### Format
`$$RETURN^%ZOSV(os command,boolReturnStatusOnly)`

### Input Parameters
 * `os command` - The opeating system command to run.
 * `boolReturnStatusOnly` - Return only the status, not the command output

### Output
Either the first line of the output; or the OS status code.

### Examples
Example 1: Get Google's IP address
```
>W $$RETURN^%ZOSV("dig +short google.com")
216.58.217.142
```

Example 2: Create a directory, and see if we were successful
```
>W $$RETURN^%ZOSV("mkdir /var/boo",1)
1
```

$$DEL1^%ZOSV(): Delete a file, easy way
---------------------------------------
Reference Type: Supported, Category: Host Files, Integration Agreement: 2320

### Description
An easy way to delete a file, rather than using the `$$DEL^%ZISH(), which takes multiple steps to use.

### Format
`$$DEL1^%ZISH("/path/to/file")`

### Input Parameters
Path to file.

### Output
1 for success; 0 for failure.

### Example
```
>W $$RETURN^%ZOSV("touch /tmp/boo",1)
0
>W $$DEL1^%ZISH("/tmp/boo")
1
```

$$SIZE^%ZOSV(): Byte size of a file on the operating system
-----------------------------------------------------------
Reference Type: Supported, Category: Host Files, Integration Agreement: Sam's List

### Description
This API returns the size of a file on the filesystem in bytes (not the sector size returned by `ls`).

### Format
`$$SIZE^%ZISH("/path/to/directory","file name")`

### Input Parameters
As above

### Output
Integer size

### Example
Note that in the example below, Linux adds 0x0a ($C(10)). Linux always add that to the end of files.
```
>D OPEN^%ZISH("F1","/tmp/","boo","W") Q:POP  U IO W "BOO" D CLOSE^%ZISH("F1")

>W $$SIZE^%ZISH("/tmp/","boo")
4
>zsy "xxd  /tmp/boo"
00000000: 424f 4f0a                                BOO.
```
$$MKDIR^%ZISH(): Create a directory on the host operating system
----------------------------------------------------------------
Reference Type: Supported, Category: Host Files, Integration Agreement: Sam's List

### Description
Create a directory on the host operating system.

### Format
`$$MKDIR^%ZISH("/path/to/directory")`

### Input Parameters
As above

### Output
0 for success; 1 for failure

### Example
```
>W $$MKDIR^%ZISH("/tmp/coo/foo")
0
```

$$WGETSYNC^%ZISH(): Sync an http/https remote directory with a local directory
------------------------------------------------------------------------------
Reference Type: Supported, Category: Host Files, Integration Agreement: Sam's List

### Description
Synchronize a remote http/https file share with a local directory. Using http is not recommended as there is no way to assure that files are downloaded without errors.

### Format
`$$WGETSYNC^%ZISH(server,remoteDir,localDir,filePatt,port,isTLS)`

### Input Parameters

 * `server` - Server name or ip address. Don't put http or https in front of it.
 * `remoteDir` - Path to the file directory
 * `localDir` - local path where to save the files
 * `filePatt` - which files to download
 * `port` - (optional) port number on which the http/https server is running. Default 443.
 * `isTLS` - (optional) Is this https? Default is yes.

### Output
0 for success, 1 for failure

### Example
Download all the recent Kernel KIDS patches
```
>W $$MKDIR^%ZISH("/tmp/patches")
0
>W $$WGETSYNC^%ZISH("foia-vista.osehra.org","Patches_By_Application/XU-KERNEL/","/tmp/patches","*.kid") 
0
>W $$WGETSYNC^%ZISH("foia-vista.osehra.org","Patches_By_Application/XU-KERNEL/","/tmp/patches","*.kids")
0
>W $$WGETSYNC^%ZISH("foia-vista.osehra.org","Patches_By_Application/XU-KERNEL/","/tmp/patches","*.KID") 
0
>W $$WGETSYNC^%ZISH("foia-vista.osehra.org","Patches_By_Application/XU-KERNEL/","/tmp/patches","*.KIDS")
0
>zsy "ls /tmp/patches"
xu-8_seq-385_pat-484.kid  xu-8_seq-406_pat-491.kid  xu-8_seq-425_pat-494.kid  XU-8_SEQ-444_PAT-548.KID	XU-8_SEQ-467_PAT-535.KID  XU-8_SEQ-488_PAT-559.KID   XU-8_SEQ-524_PAT-674.KIDS
xu-8_seq-386_pat-365.kid  xu-8_seq-407_pat-499.kid  xu-8_seq-426_pat-519.kid  XU-8_SEQ-448_PAT-551.KID	XU-8_SEQ-468_PAT-573.KID  XU-8_SEQ-493_PAT-522.KID   XU-8_SEQ-525_PAT-664.KIDS
xu-8_seq-387_pat-486.kid  xu-8_seq-408_pat-512.kid  xu-8_seq-427_pat-525.kid  XU-8_SEQ-449_PAT-537.KID	XU-8_SEQ-469_PAT-574.KID  XU-8_SEQ-494_PAT-602.KID   XU-8_SEQ-526_PAT-665.KIDS
xu-8_seq-388_pat-487.kid  xu-8_seq-409_pat-497.kid  xu-8_seq-428_pat-514.kid  XU-8_SEQ-451_PAT-567.KID	XU-8_SEQ-470_PAT-566.KID  XU-8_SEQ-495_PAT-588.KID   XU-8_SEQ-527_PAT-666.KIDS
xu-8_seq-389_pat-483.kid  xu-8_seq-410_pat-507.kid  xu-8_seq-429_pat-540.kid  XU-8_SEQ-452_PAT-504.KID	XU-8_SEQ-471_PAT-591.KID  XU-8_SEQ-496_PAT-616.KID   XU-8_SEQ-528_PAT-676.KIDS
xu-8_seq-390_pat-490.kid  xu-8_seq-411_pat-479.kid  xu-8_seq-430_pat-474.kid  XU-8_SEQ-453_PAT-431.KID	XU-8_SEQ-472_PAT-582.KID  XU-8_SEQ-497_PAT-614.KID   XU-8_SEQ-529_PAT-675.KIDS
xu-8_seq-391_pat-440.kid  xu-8_seq-412_pat-511.kid  xu-8_seq-431_pat-531.kid  XU-8_SEQ-454_PAT-553.KID	XU-8_SEQ-473_PAT-513.KID  XU-8_SEQ-498_PAT-580.KID   XU-8_SEQ-530_PAT-680.KIDS
xu-8_seq-392_pat-488.kid  xu-8_seq-413_pat-509.kid  xu-8_seq-432_pat-536.kid  XU-8_SEQ-455_PAT-560.KID	XU-8_SEQ-474_PAT-595.KID  XU-8_SEQ-500_PAT-605.KIDS  XU-8_SEQ-531_PAT-678.KIDS
xu-8_seq-394_pat-443.kid  xu-8_seq-414_pat-451.kid  xu-8_seq-433_pat-523.kid  XU-8_SEQ-456_PAT-554.KID	XU-8_SEQ-475_PAT-590.KID  XU-8_SEQ-501_PAT-632.KIDS  XU-8_SEQ-532_PAT-657.kids
xu-8_seq-395_pat-478.kid  xu-8_seq-415_pat-517.kid  xu-8_seq-434_pat-524.kid  XU-8_SEQ-457_PAT-571.KID	XU-8_SEQ-476_PAT-601.KID  XU-8_SEQ-502_PAT-629.KIDS  XU-8_SEQ-533_PAT-677.kids
xu-8_seq-396_pat-503.kid  xu-8_seq-416_pat-489.kid  xu-8_seq-435_pat-541.kid  XU-8_SEQ-458_PAT-557.KID	XU-8_SEQ-477_PAT-502.KID  XU-8_SEQ-504_PAT-552.KIDS  XU-8_SEQ-534_PAT-671.kids
xu-8_seq-397_pat-501.kid  xu-8_seq-417_pat-506.kid  xu-8_seq-436_pat-538.kid  XU-8_SEQ-459_PAT-569.KID	XU-8_SEQ-478_PAT-547.KID  XU-8_SEQ-506_PAT-634.KIDS  XU-8_SEQ-535_PAT-683.kids
xu-8_seq-398_pat-480.kid  xu-8_seq-418_pat-446.kid  xu-8_seq-437_pat-542.kid  XU-8_SEQ-460_PAT-581.KID	XU-8_SEQ-479_PAT-587.KID  XU-8_SEQ-508_PAT-627.KIDS  XU-8_SEQ-536_PAT-682.kids
xu-8_seq-399_pat-498.kid  xu-8_seq-419_pat-469.kid  xu-8_seq-438_pat-534.kid  XU-8_SEQ-461_PAT-543.KID	XU-8_SEQ-480_PAT-596.KID  XU-8_SEQ-509_PAT-645.KIDS  XU-8_SEQ-537_PAT-630.kids
xu-8_seq-400_pat-481.kid  xu-8_seq-420_pat-466.kid  xu-8_seq-439_pat-539.kid  XU-8_SEQ-462_PAT-572.KID	XU-8_SEQ-481_PAT-599.KID  XU-8_SEQ-511_PAT-631.KIDS  XU-8_SEQ-538_PAT-686.kids
xu-8_seq-402_pat-508.kid  xu-8_seq-421_pat-475.kid  xu-8_seq-440_pat-528.kid  XU-8_SEQ-463_PAT-570.KID	XU-8_SEQ-482_PAT-593.KID  XU-8_SEQ-513_PAT-650.KIDS
xu-8_seq-403_pat-399.kid  xu-8_seq-422_pat-518.kid  XU-8_SEQ-441_PAT-545.KID  XU-8_SEQ-464_PAT-586.KID	XU-8_SEQ-483_PAT-604.KID  XU-8_SEQ-514_PAT-625.KIDS
xu-8_seq-404_pat-510.kid  xu-8_seq-423_pat-527.kid  XU-8_SEQ-442_PAT-546.KID  XU-8_SEQ-465_PAT-555.KID	XU-8_SEQ-485_PAT-585.KID  XU-8_SEQ-516_PAT-638.KIDS
xu-8_seq-405_pat-401.kid  xu-8_seq-424_pat-520.kid  XU-8_SEQ-443_PAT-549.KID  XU-8_SEQ-466_PAT-594.KID	XU-8_SEQ-487_PAT-598.KID  XU-8_SEQ-517_PAT-654.KIDS
```
