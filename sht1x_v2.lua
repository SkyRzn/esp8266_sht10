--------------------------------------------------------------------------------
-- SHT1x module for NODEMCU
-- LICENCE: http://opensource.org/licenses/GPL-2.0
-- Alexandr "Sky" Ivanov <alexandr.sky@gmail.com>
--------------------------------------------------------------------------------

-- DHT1x SDA/SCL pins, defaults GPIO2/GPIO0
local sda = 4
local scl = 3

-- DHT1x temperature coefficients for 14b@3.3V multiplied by TM (x1000)
local TM = 1000 -- multiply coeff
local D1C = -39700
local D2C = 10
local D1F = -39400
local D2F = 18

-- DHT1x humidity coefficients for 12b multiplied by HM (x100000)
local HM = 100000
local C1 = -204680
local C2 = 3670
local C3 = -15955 -- multiply coeff is x10000000000
local T0 = 25 * TM
local T1 = 1000
local T2 = 8

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

-- initialize bus
local function init()
	gpio.mode(sda, gpio.INPUT)
	gpio.mode(scl, gpio.OUTPUT)
end

local function wait()
	for i = 1, 100 do
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

local function num_to_str(val, mult)
	local sign = ""
	if val < 0 then
		val = -val
		sign = "-"
	end
	local v1 = val/mult
	local v2 = (val/(mult/1000))%1000
	local res = string.format("%d.%03d", v1, v2)
	return sign..res
end

-- get temperature in raw format
local function get_raw_temperature()
	return read_cmd(3)
end

-- get humidity in raw format
local function get_raw_humidity()
	return read_cmd(5)
end

-- get temperature in in degrees Celsius
local function temperature_C(raw_temp)
	if raw_temp == nil then return "" end
	local temp = raw_temp * D2C + D1C
	return num_to_str(temp, TM)
end

-- get temperature in in degrees Fahrenheit
local function temperature_F(raw_temp)
	if raw_temp == nil then return "" end
	local temp = raw_temp * D2F + D1F
	return num_to_str(temp, TM)
end

-- get relative humidity in percents
local function get_humidity(raw_temp)
	if raw_temp == nil then return "" end
	local raw_hum = get_raw_humidity()
	local temp = raw_temp * D2C + D1C
	local lin_hum = C1 + C2 * raw_hum + C3 * raw_hum * raw_hum / HM
	local hum = (temp - T0) * (T1 + T2 * raw_hum)/TM + lin_hum
	return num_to_str(hum, HM)
end

init()
local raw_temp = get_raw_temperature()
local temp = temperature_C(raw_temp)
local hum = get_humidity(raw_temp)

return {temp, hum}
