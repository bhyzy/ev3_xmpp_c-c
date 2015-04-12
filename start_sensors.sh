#!/bin/bash

python fake_sensor.py -j test3@localhost -p test -r sensor1@muc.localhost -n sensor1 -q &
python fake_sensor.py -j test3@localhost -p test -r sensor2@muc.localhost -n sensor2 -q &
python fake_sensor.py -j test3@localhost -p test -r sensor3@muc.localhost -n sensor3 -q &
