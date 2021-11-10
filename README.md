![Boot-Sect-Pong](https://user-images.githubusercontent.com/50764330/141022453-34baa6fb-ddf0-4f30-82a0-5c2bec7b3022.png)
<br />
[![GitHub license](https://img.shields.io/github/license/VexisMorlock/Boot-sect-Pong)](https://github.com/VexisMorlock/Boot-sect-Pong/blob/main/LICENSE)
[![self](https://img.shields.io/badge/Boot--Sect--Pong-1.02-purple)](https://github.com/VexisMorlock/Boot-sect-Pong)
[![FASM](https://img.shields.io/badge/FASM-1.73.28-purple)](https://flatassembler.net/)

Boot sector pong game built using flatassembler(FASM) running in 16 bit Real Mode
Started by following a build done by: Queso Fuego
https://www.youtube.com/watch?v=mYPzJlqQ3XI

## Recommended Usage
- I used qemu to emulate this and it runs fine. I have got it to run on my older dell latatude 1521 via usb.
- I failed to run this on a 2016 macbook pro and ryzen 2600k

## Controls:
- W: Move player up
- S: Move player down
- C: Change color
- R: Reset game

## Known bugs:
- When changing color, the game lets you change the foreground color to background color making everything invisible.
- The keyboard repeat delay isn't set well, but I can't really fix with size restraints.
- Visual glitches with ball when it hits the screen limit.
 
## Future updates:
- Want to add support for joysticks and fix keyboard repeat delay to add to more natural controls.
- Run in a different mode to allow for larger game size.
  
  
  
