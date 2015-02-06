require "main"

wifi.setmode(wifi.STATION)
wifi.sta.config("lolcat2", "1234567890")
wifi.sta.connect()

tmr.alarm(0, 1000, 1, run)

