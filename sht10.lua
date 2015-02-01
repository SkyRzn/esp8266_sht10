sda = 4 --gpio2
scl = 3 --gpio0


D1 = -40
D2 =  1

function sht_init()
	gpio.mode(sda, gpio.INPUT)
	gpio.mode(scl, gpio.OUTPUT)
end

function clockTick(value)
	gpio.write(scl, value)
	-- 100 ns
	for i = 1,100 do
	end
end
	
function shiftIn(bitNum)
	value = 0
	for i = 1, bitNum do
		clockTick(gpio.HIGH)
		value = value * 2 + gpio.read(sda)
		clockTick(gpio.LOW)
      end
	return value
end
		
function skipCrc()
	--        Skip acknowledge to end trans (no CRC)
-- 	gpio.mode(sda, gpio.OUT)
	gpio.mode(scl, gpio.OUTPUT)
	gpio.write(sda, gpio.HIGH)
	clockTick(gpio.HIGH)
	clockTick(gpio.LOW)
end
		
function waitForResult()
	gpio.mode(sda, gpio.INPUT)

	for i = 1, 100 do
		tmr.delay(10000)
		ack = gpio.read(sda)
		if ack == gpio.LOW then
			break
		end
	end
			
	if ack == gpio.HIGH then
		return -1
	end
	
	return 0
end

function getData16Bit()
	gpio.mode(sda, gpio.INPUT)
	gpio.mode(scl, gpio.OUTPUT)
	
	value = shiftIn(8)
	value = value * 256
	
	--gpio.mode(sda, gpio.OUT)
	gpio.write(sda, gpio.HIGH)
	gpio.write(sda, gpio.LOW)
	clockTick(gpio.HIGH)
	clockTick(gpio.LOW)
	
	--gpio.mode(sda, gpio.IN)
	value = bit.bor(value, shiftIn(8))

	return value
end

function sendCommand(command)
	--Transmission start
-- 	gpio.mode(sda, gpio.OUT)
	gpio.mode(scl, gpio.OUTPUT)

	gpio.write(sda, gpio.HIGH)
	clockTick(gpio.HIGH)
	gpio.write(sda, gpio.LOW)
	clockTick(gpio.LOW)
	clockTick(gpio.HIGH)
	gpio.write(sda, gpio.HIGH)
	clockTick(gpio.LOW)

	for i = 0, 7 do
		cmd = bit.band(command, 2 ^ (7-i))
		if cmd then
			cmd = gpio.HIGH
		else
			cmd = gpio.LOW
		end
		gpio.write(sda, cmd)
		clockTick(gpio.HIGH)
		clockTick(gpio.LOW)     
	end

	clockTick(gpio.HIGH)

-- 	gpio.mode(self.dataPin, gpio.IN)

	ack = gpio.read(sda)
	
-- 	if ack <= gpio.LOW:
-- 	logger.error("nack1")

	clockTick(gpio.LOW)

	ack = gpio.read(sda)
-- 	logger.debug("ack2: %s", ack)
-- 	if ack != gpio.HIGH:
-- 	logger.error("nack2")
end


function read_temperature_C()
	temperatureCommand = 5 --3

	sendCommand(temperatureCommand)
	waitForResult()
	rawTemperature = getData16Bit()
	skipCrc()
-- 	gpio.cleanup()
	return rawTemperature -- * D2 + D1
end


tempval = read_temperature_C()
print("!!!", tempval)
