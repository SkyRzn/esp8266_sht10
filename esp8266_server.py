#!/usr/bin/python


import socket


def calcData(data):
	D1 = -40.0  # for 14 Bit @ 5V
	D2 =  0.01 # for 14 Bit DEGC

	C1 = -2.0468       # for 12 Bit
	C2 =  0.0367       # for 12 Bit
	C3 = -0.0000015955 # for 12 Bit
	T1 =  0.01      # for 14 Bit @ 5V
	T2 =  0.00008   # for 14 Bit @ 5V

	rawTemp, rawHum = data
	rawTemp = float(rawTemp)
	rawHum = float(rawHum)

	temp = rawTemp * D2 + D1

	linHum = C1 + C2 * rawHum + C3 * rawHum * rawHum
	hum = (temp - 25.0) * (T1 + T2 * rawHum) + linHum

	return (temp, hum)


addr = ('192.168.0.66', 8266)

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(addr)



while True:
	data, addr = sock.recvfrom(1024)
	print 'addr:', addr
	print 'received message:', data

	data = data.split(':')
	if len(data) != 2:
		continue

	temp, hum = calcData(data)

	print 'T=%.2f, H=%.2f%%' % (temp, hum)


