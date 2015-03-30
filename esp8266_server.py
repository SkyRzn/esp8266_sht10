#!/usr/bin/python

import socket, time


addr = ('192.168.8.66', 8266)
DEEP_SLEEP_TIME = 60
MAX_CONNECTION_ATTEMPTS = 20


acc_table = [(682, 2.93), (691, 2.91), (694, 2.9), (696, 2.89), (700, 2.88), (720, 2.84), (727, 2.81), (737, 2.79), (740, 2.78), (745, 2.77), (750, 2.76), (759, 2.74), (763, 2.73), (780, 2.69), (786, 2.68), (796, 2.65), (800, 2.64), (808, 2.63), (815, 2.62), (828, 2.6), (833, 2.59), (840, 2.58), (846, 2.57), (853, 2.56), (858, 2.55), (865, 2.54), (872, 2.53), (880, 2.52), (886, 2.51), (894, 2.5), (932, 2.44), (973, 2.41), (1021, 2.35), (1031, 2.34), (1042, 2.33), (1050, 2.32)]


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

def cnt2u(cnt):
	c1, c2 = 0, 0
	u1, u2 = 0, 0
	for c, u in acc_table:
		if c < cnt:
			c1 = c
			u1 = u
		elif c == cnt:
			return u
		elif c > cnt:
			c2 = c
			u2 = u
			break

	if not (c1 or c2):
		return 0

	if not c2:
		c1, u1 = acc_table[-2]
		c2, u2 = acc_table[-1]
	elif not c1:
		c1, u1 = acc_table[0]
		c2, u2 = acc_table[1]

	du = (u2-u1)/(c2-c1)

	return (float(cnt) - c1)*du + u1


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

	battery = cnt2u(battery)
	ds_time, max_conn, conn_time = int(ds_time), int(max_conn), int(conn_time)

	print '%d) %s T=%.2f, H=%.2f%%, BT=%.2f (bat=%d, ds=%d, mc=%d, ct=%d)' % (cnt, time.strftime("%H:%M:%S"), temp, hum, btemp, battery, ds_time, max_conn, conn_time)

	if ds_time != DEEP_SLEEP_TIME or max_conn != MAX_CONNECTION_ATTEMPTS:
		sock.sendto('%d,%d' % (DEEP_SLEEP_TIME, MAX_CONNECTION_ATTEMPTS), addr)
		print '\tSent new settings: ds=%d, mc=%d' % (DEEP_SLEEP_TIME, MAX_CONNECTION_ATTEMPTS)

	cnt += 1


