# pokebot

<br>
<br>

### references

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

### scrcpy commands

* [install scrcpy](https://github.com/Genymobile/scrcpy/blob/master/doc/linux.md)

* start up scrcpy on app

```bash
./scrcpy --start-app=jp.pokemon.pokemontcgp
```

```bash
--start-app=<package>  # start the app with the given package
--stay-awake           # prevent the device from sleeping
--turn-screen-off

-Sw # stay-awake + turn-screen-off = prevent device from sleeping

--show-touches         # show touches

```

<br>
<br>
