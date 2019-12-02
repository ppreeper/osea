del /f /s /q %HOMEPATH%\AppData\Local\Microsoft\Temporary Internet Files\*.*
del \Windows\Temp\cab_*
del \Windows\Logs\CBS\CbsPersist_*
powercfg.exe -h off
