import uasyncio as asyncio

from machine import Pin, PWM
from pimoroni import Button


class PowerCycleButton:
    def __init__(self, remote, pin_number):
        self.button = Button(pin_number)
        self.remote = remote

    def tap(self):
        self.remote.set_power(self.remote.get_next_power_level())

    async def listen(self):
        while True:
            if self.button.read():
                self.tap()
            await asyncio.sleep_ms(100)


class FanControl:
    pwm_max = 65535

    def __init__(self, relay_pin_number, pwm_pin_number):
        self.pin_pwm = Pin(pwm_pin_number, Pin.OUT)
        self.pin_relay = Pin(relay_pin_number, Pin.OUT)
        self.pwm = PWM(self.pin_pwm)
        self.pwm.freq(25000)

    def on(self, power=None):
        self.pin_relay.on()
        if power:
            self.set_power(power)

    def off(self):
        self.pin_relay.off()
        self.set_power(0)

    def set_power(self, power):
        self.pwm.duty_u16(round(self.pwm_max / 100 * power))


class Remote:
    power = 25
    power_initial = 25
    fan_pins = (0, 1)
    fans = []
    presets = [100, 75, 50, 25, 0]

    def __init__(self, fans, power_button_pin=None):
        super().__init__()
        if power_button_pin:
            self.power_button = PowerCycleButton(self, power_button_pin)
        self.fans = fans

    def set_power(self, power):
        self.power = power
        self.all_fans(lambda fan: fan.set_power(power))
        print(f"Power: {self.power} %")

    def get_next_power_level(self):
        if self.power in self.presets:
            index = self.presets.index(self.power)
            return self.presets[(index - 1) % len(self.presets)]
        return 0

    def all_fans(self, fn):
        for fan in self.fans:
            fn(fan)

    async def blink_task(self):
        led = Pin("LED", Pin.OUT)
        toggle = True
        while True:
            if self.power == 0:
                led.value(False)
            else:
                led.value(toggle)
            toggle = not toggle
            await asyncio.sleep_ms(self.power * 10)

    async def start(self):
        self.all_fans(lambda fan: fan.on(self.power))
        tasks = [
            asyncio.create_task(self.power_button.listen()),
            asyncio.create_task(self.blink_task()),
        ]
        await asyncio.gather(*tasks)


async def main():
    fans = [
        FanControl(0, 1),
    ]
    remote = Remote(fans, power_button_pin=2)
    await remote.start()


asyncio.run(main())
