#!/usr/bin/env python3

import json
import urllib.parse
import urllib.request


class Py3status:
    """
    Current weather from Open-Meteo.

    Configuration parameters:
        cache_timeout: Refresh interval in seconds (default 600)
        format: Display format (default "[ {icon} {temperature}°C ]")
        latitude: Latitude (default 50.1109)
        longitude: Longitude (default 8.6821)
        request_timeout: HTTP timeout in seconds (default 5)

    Format placeholders:
        {icon}: Weather icon
        {temperature}: Current temperature in °C
        {weather}: Weather description
    """

    cache_timeout = 600
    format = "[ {icon} {temperature}°C ]"
    latitude = 50.1109
    longitude = 8.6821
    request_timeout = 5

    def post_config_hook(self):
        self._temperature = None
        self._weather = "unknown"
        self._icon = "?"
        self._error = False

    def _weather_info(self, code, is_day):
        if code == 0:
            return ("☀" if is_day else "☾", "Clear")

        if code in (1, 2, 3):
            return ("⛅" if is_day else "☾", "Cloudy")

        if code in (45, 48):
            return ("🌫", "Fog")

        if code in (51, 53, 55, 56, 57):
            return ("🌦", "Drizzle")

        if code in (61, 63, 65, 66, 67):
            return ("🌧", "Rain")

        if code in (71, 73, 75, 77):
            return ("❄", "Snow")

        if code in (80, 81, 82):
            return ("🌦", "Showers")

        if code in (85, 86):
            return ("🌨", "Snow showers")

        if code in (95, 96, 99):
            return ("⛈", "Thunderstorm")

        return ("?", "Unknown")

    def _get_data(self):
        params = {
            "latitude": self.latitude,
            "longitude": self.longitude,
            "current": "temperature_2m,weather_code,is_day",
            "timezone": "Europe/Berlin",
        }

        url = (
            "https://api.open-meteo.com/v1/forecast?"
            + urllib.parse.urlencode(params)
        )

        request = urllib.request.Request(
            url,
            headers={"User-Agent": "py3status-weather/1.0"},
        )

        with urllib.request.urlopen(
            request,
            timeout=self.request_timeout,
        ) as response:
            return json.loads(response.read().decode("utf-8"))

    def weather_open_meteo(self):
        try:
            data = self._get_data()

            current = data["current"]

            temperature = round(float(current["temperature_2m"]))
            code = int(current["weather_code"])
            is_day = bool(current["is_day"])

            icon, weather = self._weather_info(code, is_day)

            self._temperature = temperature
            self._icon = icon
            self._weather = weather
            self._error = False

            full_text = self.py3.safe_format(
                self.format,
                {
                    "icon": icon,
                    "temperature": temperature,
                    "weather": weather,
                },
            )

            return {
                "full_text": full_text,
                "cached_until": self.py3.time_in(self.cache_timeout),
            }

        except Exception as err:
            self._error = True

            self.py3.log(
                "weather_open_meteo: {}".format(err),
                level="error",
            )

            return {
                "full_text": "[ 🌡 --°C ]",
                "color": self.py3.COLOR_BAD,
                "cached_until": self.py3.time_in(60),
            }


if __name__ == "__main__":
    from py3status.module_test import module_test

    module_test(Py3status)