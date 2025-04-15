<h3 align="center">
    <a href="https://tcgpocket.pokemon.com/en-us/" target="_blank">
        <img src="./images/header.png"/>
    </a>
</h3>

<br>
<br>

### phone

<br>

* [Galaxy A16 5G](https://www.telcel.com/tienda/producto/telefonos-y-smartphones/galaxy-a16-gris-128gb/71001512)

<br>

```bash
screen_size: 1080x2340
```

<br>
<br>

### references

<br>

* limitless tcg deck builder

```bash
https://my.limitlesstcg.com/builder
```

* scrape all card data

```bash
# GET
https://api.dotgg.gg/cgfw/getcards?game=pokepocket&mode=indexed&cache={cache_idx}
```

* scrape all card image data

```bash
https://ptcgpocket.gg/cards/
```

* static URL for card images

```bash
https://static.dotgg.gg/pokepocket/card/{card_number}.webp
```

* name of app

```bash
jp.pokemon.pokemontcgp
```

<br>
<br>

### openai models

<br>

```bash
# (if share, increased free token limits)
# ** - supports image upload
gpt-4.1-nano-2025-04-14** -> (0.1 per 1M)
gpt-4.1-mini-2025-04-14** -> (0.4 per 1M)
gpt-4o** -> (10 per 1M)
gpt-4o-mini** -> (0.60 per 1M))
gpt-4.5-preview** -> (150 per 1M)
o3-mini -> (4.40 per 1M)
```

<br>
<br>

### scrcpy

<br>

* [install scrcpy](https://github.com/Genymobile/scrcpy/blob/master/doc/linux.md)

```bash
./scrcpy --start-app=jp.pokemon.pokemontcgp
```

```bash
-Sw # stay-awake + turn-screen-off = prevent device from sleeping

--show-touches         # show touches
```

<br>
<br>

### adb

<br>

```bash
adb shell pidof -s jp.pokemon.pokemontcgp # get pid
adb logcat --pid=<pid> # get logcat for pid

adb shell getevent -lt > touches.log # get touch events

adb shell ls # list files in device
adb shell rm # remove files in device

# screenshots
adb exec-out screencap -p > screen.png
adb shell screencap /sdcard/test.png
adb pull /sdcard/test.png test.png

adb shell wm size # get current resolution
adb shell input tap <X> <Y>           # tap
adb shell input swipe <X1> <Y1> <X2> <Y2> <duration> # swipe
adb shell input text 'Charmander' # type text

adb shell settings get system show_touches # get show_touches values
```

<br>
<br>
