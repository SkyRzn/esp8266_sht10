gpio.mode(5, gpio.OUTPUT)
gpio.write(5, gpio.HIGH)

gpio.mode(6, gpio.OUTPUT)
gpio.write(6, gpio.LOW)
tmr.delay(100000)
gpio.write(5, gpio.LOW)
gpio.mode(6, gpio.INPUT)
local cnt = 0
while (gpio.read(6) == 0) do
	cnt = cnt + 1
	if cnt > 4000 then
		break
	end
	tmr.delay(1000)
end
return cnt
