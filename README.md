# FourLEDs

Invoke the package manager with `]` in the REPL and use
```julia
add https://github.com/yakir12/FourLEDs
```

To control the LEDs, connect your computer with a USB (connector type mini B) to the Arduino-end of the LED strip. 
Siimply run 
```julia
using FourLEDs
```
and to open the window with the slider to control the LEDs run:
```
main()
```

You can close that window and run `main()` again as many times as you like. 
