Pipe implementation of sha in YDB.

YDB 1.1:
```
 ---------------------------------- XLFSHAN ----------------------------------
 T1 - $$SHAN w/ null string.....-------------------------------  [OK]   16.150ms
 T2 - $$SHAN w/ string of abc.....-----------------------------  [OK]   17.940ms
 T3 - $$SHAN w/ long string.....-------------------------------  [OK]   16.768ms
 T4 - $$SHAN w/ even longer string.....------------------------  [OK]   17.914ms
 T5 - $$LSHAN w/ 1MiB str of 'a'.....--------------------------  [OK] 3951.217ms
```

YDB 1.1 w/ OpenSSL C Callout plugin:
```
 ---------------------------------- XLFSHAN ----------------------------------
T1 - $$SHAN w/ null string.....-------------------------------  [OK]    0.403ms
T2 - $$SHAN w/ string of abc.....-----------------------------  [OK]    0.346ms
T3 - $$SHAN w/ long string.....-------------------------------  [OK]    0.345ms
T4 - $$SHAN w/ even longer string.....------------------------  [OK]    0.347ms
T5 - $$LSHAN w/ 1MiB str of 'a'.....--------------------------  [OK]  486.852ms
```

Cache 2014:
```
 ---------------------------------- XLFSHAN ----------------------------------
T1 - $$SHAN w/ null string.....-------------------------------  [OK]    0.976ms
T2 - $$SHAN w/ string of abc.....-----------------------------  [OK]    0.964ms
T3 - $$SHAN w/ long string.....-------------------------------  [OK]    1.333ms
T4 - $$SHAN w/ even longer string.....------------------------  [OK]    1.195ms
T5 - $$LSHAN w/ 1MiB str of 'a'.....--------------------------  [OK]  377.149ms
```
