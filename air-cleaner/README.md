# Parametric Air Cleaner (WIP)

This model is designed to pull air trough light porous dust filter
and activated carbon pellets using fan of chosen size. In theory, it should
filter out dust and small particles from the room.

## Project target

Create Bluetooth controlled smart home appliance. Currently in progress

## Project status (TODOs)

I have a working prototype, but there is still a lot of work unfinished.

* Thinner the walls to save material
* Design wiring holes for the fan
* Design the pellet lid, so the activated carbon does not fall trough the top when the PAC is tilted
* Design better controls holder in the main wall frame
* Research, specify and list additional hardware used (button, power converter, wiring)
* Finish programming the Bluetooth control
* Wire the 12 V power, so it can be reused for the RPI
* Design housing for the RPI

## Variants

1. Standalone with 12 V input
2. Buddy variant witth 4 pin fan connector, to be controlled by a single RPI

## Hardware

The model should reliably resize to the specified fan size.

### Control

* Raspberry Pi Pico W for [remote control](./control)
* Simple toggle switch for haptic control

### Fan

  Any 12 V DC fan controlled by PWM (4pin connector). I used [18 cm SilverStone Air Penetrator](https://www.amazon.de/-/en/dp/B09FSWDP4R?ref=ppx_yo2ov_dt_b_fed_asin_title)

### Filters

* Activated carbon pellets as particle filter
* Porous foam for dust filter

### Power

* Any 12 V DC power adapter for main power
* 12 V DC relay 

### Structure

* 3 mm screws and nuts (need to specify). The screws are optional, because the box holds together nicely.
* PETG/PLA 625 g
