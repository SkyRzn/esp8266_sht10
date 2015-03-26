local sda = 4
local scl = 3

local function dl()
	gpio.write(sda, gpio.LOW)
	gpio.mode(sda, gpio.OUTPUT)
end

local function dh()
	gpio.mode(sda, gpio.INPUT)
	gpio.write(sda, gpio.HIGH)
end

local function cl()
	gpio.write(scl, gpio.LOW)
end

local function ch()
	gpio.write(scl, gpio.HIGH)
end

-- get SDA value
local function dr()
	gpio.mode(sda, gpio.INPUT)
	return gpio.read(sda)
end

local function wait()
	for i = 1, 100 do
		tmr.wdclr()
		tmr.delay(10000)
		if dr() == gpio.LOW then
			return true --FIXME
		end
	end
	return false --FIXME
end

local function read_byte()
	local val = 0
	for i = 0, 7 do
		ch()
		val = val * 2 + dr()
		cl()
	end
	return val
end

local function write_byte(val)
	for i = 0, 7 do
		if bit.band(val, 2 ^ (7-i)) == 0 then
			dl()
		else
			dh()
		end
		ch(); cl()
	end
end

local function read_cmd(cmd)
	dh() ch() dl() cl() ch() dh() cl() -- transmission start sequence

	write_byte(cmd)

	ch(); cl()

	if not wait() then --FIXME
		return nil --FIXME
	end

	dh()
	local val = read_byte()

	dh() dl() ch() cl() dh() -- ackhowledge

	val = val * 256 + read_byte()

	dh() ch() cl() -- skip crc
	return val
end

gpio.mode(sda, gpio.INPUT)
gpio.mode(scl, gpio.OUTPUT)

local temp = read_cmd(3)
local hum = read_cmd(5)

return {temp, hum}
