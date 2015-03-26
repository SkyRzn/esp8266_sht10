local pin = 7

local function read()
	gpio.mode(pin, gpio.INPUT, gpio.PULLUP)
	ow.setup(pin)
	ow.reset(pin)
	ow.skip(pin)
	ow.write(pin, 0x44)
	ow.reset(pin)
	tmr.wdclr()
	tmr.delay(750000)
	tmr.wdclr()
	ow.reset(pin)
	ow.skip(pin)
	ow.write(pin, 0xBE)

	local data = ""
	for i = 1, 9 do
		data = data .. string.char(ow.read(pin))
	end
	local crc = ow.crc8(string.sub(data,1,8))
	--if (crc == data:byte(9)) then
	if (crc == crc) then
		local t = data:byte(1) + data:byte(2) * 256
		local sign = ""
		if t > 0x8000 then
			t = 0x10000 - t
			sign = "-"
		end
		t = t * 625
		local t1 = t / 10000
		local t2 = t % 10000
		local res = sign..t1.."."..string.format("%04u", t2)
		return res
	end

	return ""
end

local res = read()
return res
