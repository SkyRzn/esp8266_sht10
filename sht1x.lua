local sda = 4
local scl = 3

function sht_init()
	gpio.mode(sda, gpio.INPUT)
	gpio.mode(scl, gpio.OUTPUT)
end

function dl()
	gpio.write(sda, gpio.LOW)
	gpio.mode(sda, gpio.OUTPUT)
end

function dh()
	gpio.mode(sda, gpio.INPUT)
	gpio.write(sda, gpio.HIGH)
end

function cl()
	gpio.write(scl, gpio.LOW)
end

function ch()
	gpio.write(scl, gpio.HIGH)
end

function dr()
	gpio.mode(sda, gpio.INPUT)
	return gpio.read(sda)
end

function sendCmd(cmd)
	dh(); ch(); dl(); cl(); ch(); dh(); cl()

	for i = 0, 7 do
		if bit.band(cmd, 2 ^ (7-i)) == 0 then
			dl()
		else
			dh()
		end
		ch(); cl()
	end

	ch(); cl()
end

function waitRes()
-- 	dh()
	for i = 1, 100 do
		tmr.delay(10000)
		if dr() == gpio.LOW then
			break
		end
	end
	return ack
end

function shiftIn()
	local val = 0
	for i = 0, 7 do
		ch()
		val = val * 2 + dr()
		cl()
	end
	return val
end

function readData()
	dh()
	local val = shiftIn()
	dh(); dl(); ch(); cl(); dh()
	return val  * 256 + shiftIn()
end

function readCmdData(cmd)
	sendCmd(cmd)
	waitRes()
	local val = readData()
	dh(); ch(); cl()
	return val
end

function readRawData()
	sht_init()
	local temp = readCmdData(3)
	local hum = readCmdData(5)
	return {temp, hum}
end

