-- SHT1x module for NODEMCU
-- LICENCE: http://opensource.org/licenses/GPL-2.0
-- Alexandr "Sky" Ivanov <alexandr.sky@gmail.com>

local moduleName = ...
local M = {}
_G[moduleName] = M

-- DHT1x SDA/SCL pins, defaults GPIO2/GPIO0
local sda = 4
local scl = 3

-- set SDA LOW
local function dl()
	gpio.write(sda, gpio.LOW)
	gpio.mode(sda, gpio.OUTPUT)
end

-- set SDA HIGH
local function dh()
	gpio.mode(sda, gpio.INPUT)
	gpio.write(sda, gpio.HIGH)
end

-- set SCL LOW
local function cl()
	gpio.write(scl, gpio.LOW)
end

-- set SCL HIGH
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
		tmr.delay(10000)
		if dr() == gpio.LOW then
			return true
		end
	end
	return false
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

	if not wait() then
		return nil
	end

	dh()
	local val = read_byte()

	dh() dl() ch() cl() dh() -- ackhowledge

	val = val * 256 + read_byte()

	dh() ch() cl() -- skip crc
	return val
end

-- initialize bus
--parameters:
--d: sda
--l: scl
function M.init(d, l)
	if d ~= nil then
		sda = d
	end
	if l ~= nil then
		scl = l
	end
	gpio.mode(sda, gpio.INPUT)
	gpio.mode(scl, gpio.OUTPUT)
	print("SHT1x init done")
end

-- get temperature in raw format
function M.get_raw_temperature()
	return read_cmd(3)
end

-- get humidity in raw format
function M.get_raw_humidity()
	return read_cmd(5)
end

return M
