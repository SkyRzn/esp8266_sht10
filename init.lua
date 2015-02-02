wifi.setmode(wifi.STATION)
wifi.sta.config("lolcat", "1234567890")
wifi.sta.autoconnect(1)
--tmr.alarm(4000, 0, function() dofile("interupt.lua") end)

print("Started")

