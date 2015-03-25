local pin = 7

local function read()
	local count = 0
	local addr
	
	ow.setup(pin)
	
	ow.reset_search(pin)
	repeat
		count = count + 1
		addr = ow.search(pin)
		tmr.wdclr()
	until((addr ~= nil) or (count > 100))
	ow.reset_search(pin)
	
	if(addr == nil) then
		return result
	end
	local crc = ow.crc8(string.sub(addr,1,7))
	if (crc == addr:byte(8)) then
		if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
			ow.reset(pin)
			ow.select(pin, addr)
			ow.write(pin, 0x44, 1)
			tmr.delay(10000)
			present = ow.reset(pin)
			ow.select(pin, addr)
			ow.write(pin,0xBE,1)
			local data = string.char(ow.read(pin))
			for i = 1, 8 do
				data = data .. string.char(ow.read(pin))
			end
			crc = ow.crc8(string.sub(data,1,8))
			if (crc == data:byte(9)) then
				local t = (data:byte(1) + data:byte(2) * 256) * 625
				local t1 = t / 10000
				local t2 = t % 10000
				if t1 < -50 or t1 > 50 then return nil end
				return t1.."."..string.format("%04u", t2)
			end
			tmr.wdclr()
		end
	end
	return nil
end


local res
local i
for i = 1,20 do
	res = read()
	if res ~= nil then return res end
end
return ""

