systeminfo | findstr /B /C:"System Type"

msiexec /i tightvnc-2.5.2-setup-64bit.msi /log "c:/Windows" /quiet /norestart \
  ADDLOCAL=Server VIEWER_ASSOCIATE_VNC_EXTENSION=0 SET_RUNCONTROLINTERFACE=0 \
  SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 \
  VALUE_OF_PASSWORD=heslo1234
