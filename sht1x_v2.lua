--------------------------------------------------------------------------------
-- SHT1x module for NODEMCU
-- LICENCE: http://opensource.org/licenses/GPL-2.0
-- Alexandr "Sky" Ivanov <alexandr.sky@gmail.com>
--------------------------------------------------------------------------------

local moduleName = ...
local M = {}
_G[moduleName] = M

-- DHT1x SDA/SCL pins, defaults GPIO2/GPIO0
local sda = 4
local scl = 3

-- DHT1x temperature coefficients for 14b@3.3V multiplied by TM (1000)
local TM = 1000 -- multiply coeff
local D1C = -39700
local D2C = 10
local D1F = -39400
local D2F = 18

-- DHT1x humidity coefficients for 12b multiplied by HM (100000)
local HM = 100000
local C1 = -204680
local C2 = 3670
local C3 = -15955 -- multiply coeff ^ 2
local T0 = 25 * TM
local T1 = 1000
local T2 = 8

-- set SDA LOW
function dl()
	gpio.write(sda, gpio.LOW)
	gpio.mode(sda, gpio.OUTPUT)
end

-- set SDA HIGH
function dh()
	gpio.mode(sda, gpio.INPUT)
	gpio.write(sda, gpio.HIGH)
end

-- set SCL LOW
function cl()
	gpio.write(scl, gpio.LOW)
end

-- set SCL HIGH
function ch()
	gpio.write(scl, gpio.HIGH)
end

-- get SDA value
function dr()
	gpio.mode(sda, gpio.INPUT)
	return gpio.read(sda)
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

function wait()
	for i = 1, 100 do
		tmr.delay(10000)
		if dr() == gpio.LOW then
			return true --FIXME
		end
	end
	return false --FIXME
end

function read_byte()
	local val = 0
	for i = 0, 7 do
		ch()
		val = val * 2 + dr()
		cl()
	end
	return val
end

function write_byte(val)
	for i = 0, 7 do
		if bit.band(val, 2 ^ (7-i)) == 0 then
			dl()
		else
			dh()
		end
		ch(); cl()
	end
end

function read_cmd(cmd)
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

function num_to_str(val, mult)
	local v1 = val/mult
	local v2 = val/(mult/100) - v1*100
	return string.format("%d.%02d", v1, v2)
end

-- get temperature in raw format
function M.get_raw_temperature()
	return read_cmd(3)
end

-- get humidity in raw format
function M.get_raw_humidity()
	return read_cmd(5)
end

-- get temperature in in degrees Celsius
function M.get_temperature_C()
	local raw_temp = M.get_raw_temperature()
	if raw_temp == nil then return nil end
	temp = raw_temp * D2C + D1C
	return num_to_str(temp, TM)
end

-- get temperature in in degrees Fahrenheit
function M.get_temperature_F()
	local raw_temp = M.get_raw_temperature()
	if raw_temp == nil then return nil end
	temp = raw_temp * D2F + D1F
	return num_to_str(temp, TM)
end

-- get relative humidity in percents
function M.get_humidity()
	local raw_temp = M.get_raw_temperature()
	local raw_hum = M.get_raw_humidity()
	temp = raw_temp * D2C + D1C
	lin_hum = C1 + C2 * raw_hum + C3 * raw_hum * raw_hum / HM
	hum = (temp - T0) * (T1 + T2 * raw_hum)/TM + lin_hum
	return num_to_str(hum, HM)
end

return M