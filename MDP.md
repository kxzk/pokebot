<h3 align="center">MDP</h3>

<br>
<br>

### (s) state

<br>

* battle -> capture essential observable information

<br>
<br>

### (a) action

<br>

* allowable moves in the game

<br>
<br>

### (r) reward

<br>

```bash
reward = win/loss outcome + λ1 * (prizes_taken) – λ2 * (prizes_given up) + λ3 * (other factors).

for example: +10 for win, -10 for loss, +2 per opponent ko, -2 per your pokémon ko, and perhaps +0.1 per 10 damage dealt.
```

<br>
<br>

### (t) transition model

<br>

* model-free approach -> execute actions through ADB and parse resulting screenshots into updated states

<br>
<br>

### references
