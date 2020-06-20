## verilog mandelbrot fractal generator
It is verilog implementation of mandelbrot fractal generator.
Code tested on Artix-7 XC7A35T FPGA board.

## Design
- For vga frame buffer used onboard ddr3 256MB ram with xilinx mig7 memory controller
- Fractal size and vga resolution is 1024 X 768
- Fractal frame is generated one time untill next zoom
- Max iteration for fractal generation is 500





