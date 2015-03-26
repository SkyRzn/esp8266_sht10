#!/usr/bin/python

import socket, time


addr = ('192.168.0.66', 8266)
DEEP_SLEEP_TIME = 60
MAX_CONNECTION_ATTEMPTS = 20


def calc_sht(raw_temp, raw_hum):
	D1 = -39.65
	D2 = 0.01

	C1 = -2.0468
	C2 = 0.0367
	C3 = -1.5955e-6
	T1 = 0.01
	T2 = 0.00008

	raw_temp, raw_hum = float(raw_temp), float(raw_hum)

	temp = raw_temp * D2 + D1

	lin_hum = C1 + C2 * raw_hum + C3 * raw_hum * raw_hum
	hum = (temp - 25) * (T1 + T2 * raw_hum) + lin_hum

	return temp, hum


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind(addr)

cnt = 0
while True:
	s, addr = sock.recvfrom(1024)

	data = s.split(',')
	if len(data) != 7:
		print 'Incorrect data: "%s"' % (s)
		continue

	temp, hum, btemp, battery, ds_time, max_conn, conn_time = data
	if not temp:
		temp = -666
	if not hum:
		hum = -666
	if not btemp:
		btemp = -666

	temp, hum = calc_sht(temp, hum)
	btemp = float(btemp)

	battery, ds_time, max_conn, conn_time = int(battery), int(ds_time), int(max_conn), int(conn_time)

	print '%d) %s T=%.2f, H=%.2f%%, BT=%.2f (bat=%d, ds=%d, mc=%d, ct=%d)' % (cnt, time.strftime("%H:%M:%S"), temp, hum, btemp, battery, ds_time, max_conn, conn_time)

	if ds_time != DEEP_SLEEP_TIME or max_conn != MAX_CONNECTION_ATTEMPTS:
		sock.sendto('%d,%d' % (DEEP_SLEEP_TIME, MAX_CONNECTION_ATTEMPTS), addr)
		print '\tSent new settings: ds=%d, mc=%d' % (DEEP_SLEEP_TIME, MAX_CONNECTION_ATTEMPTS)

	cnt += 1


