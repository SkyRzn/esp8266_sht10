local pin = 6

local function read()
	local data, crc, t, t1, t2, res, sign = ""
	ow.setup(pin)
	ow.reset(pin)
	ow.skip(pin)
	ow.reset(pin)
	ow.write(pin, 0x44, 1)
	tmr.wdclr()
	tmr.delay(7500000)
	tmr.wdclr()
	ow.write(pin,0xBE,1)
	data = string.char(ow.read(pin))
	for i = 1, 8 do
		data = data .. string.char(ow.read(pin))
	end
	crc = ow.crc8(string.sub(data,1,8))
	if (crc == data:byte(9)) then
		t = data:byte(1) + data:byte(2) * 256
		if t > 0x8000 then
			t = (0x10000 - t) * 625
			sign = "-"
		else
			t = t * 625
		end
		t1 = t / 10000
		t2 = t % 10000
		res = sign..t1.."."..string.format("%04u", t2)
		return res
	end
	tmr.wdclr()
	return ""
end

local res = read()

return res