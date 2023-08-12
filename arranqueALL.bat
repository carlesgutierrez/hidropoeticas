@Echo off
Echo Hidropoeticas Arranque START!
START C:\Users\hidropc\Documents\develop\hidropoeticas\sonido\ThereminHidro2StandardProject\ThereminHidro2Standard.als
Echo Ableton up!
PING -n 10 127.0.0.1>nul
cd C:\Users\hidropc\Documents\develop\hidropoeticas\hidropoeticas_FFTTheremin\windows-amd64
START hidropoeticas_FFTTheremin.exe
Echo Theremin up!
PING -n 2 127.0.0.1>nul
cd C:\Users\hidropc\Documents\develop\hidropoeticas\hidropoeticas_FFTHidrofono\windows-amd64
START hidropoeticas_FFTHidrofono.exe
Echo Hidrofono up!
PING -n 2 127.0.0.1>nul
START C:\Users\hidropc\Documents\develop\hidropoeticas\hidropoeticasVostell_EQ1.avc
Echo Weather Vostell up!
PING -n 2 127.0.0.1>nul
cd C:\Users\hidropc\Documents\develop\hidropoeticas\weatherSpout\windows-amd64
START weatherSpout.exe
Echo Hidropoeticas Arranque END!