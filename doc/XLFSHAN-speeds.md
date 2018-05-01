Initial run, using pipe implementation of sha in YDB.

YDB:
```
 ---------------------------------- XLFSHAN ----------------------------------
 T1 - $$SHAN w/ null string.....-------------------------------  [OK]   16.150ms
 T2 - $$SHAN w/ string of abc.....-----------------------------  [OK]   17.940ms
 T3 - $$SHAN w/ long string.....-------------------------------  [OK]   16.768ms
 T4 - $$SHAN w/ even longer string.....------------------------  [OK]   17.914ms
 T5 - $$LSHAN w/ 1MiB str of 'a'.....--------------------------  [OK] 3951.217ms
```

YDB w/ OpenSSL C Callout plugin:
```
 ---------------------------------- XLFSHAN ----------------------------------
 T1 - $$SHAN w/ null string.....-------------------------------  [OK]    0.294ms
 T2 - $$SHAN w/ string of abc.....-----------------------------  [OK]    0.220ms
 T3 - $$SHAN w/ long string.....-------------------------------  [OK]    0.215ms
 T4 - $$SHAN w/ even longer string.....------------------------  [OK]    0.217ms
 T5 - $$LSHAN w/ 1MiB str of 'a'.....--------------------------  [OK]  229.312ms
```

Cache:
```
 ---------------------------------- XLFSHAN ----------------------------------
 T1 - $$SHAN w/ null string.....-------------------------------  [OK]    2.043ms
 T2 - $$SHAN w/ string of abc.....-----------------------------  [OK]    1.415ms
 T3 - $$SHAN w/ long string.....-------------------------------  [OK]    0.855ms
 T4 - $$SHAN w/ even longer string.....------------------------  [OK]    0.851ms
 T5 - $$LSHAN w/ 1MiB str of 'a'.....--------------------------  [OK]  382.511ms
```
