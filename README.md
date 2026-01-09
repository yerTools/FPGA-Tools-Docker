[![Build tools](https://github.com/yertools/FPGA-Tools-Docker/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/yertools/FPGA-Tools-Docker/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yertools/FPGA-Tools-Docker/blob/master/LICENSE.txt)

# Docker Container with FPGA tools

## About tools:

### Simulation & Synthesis

- [Iverilog](https://github.com/steveicarus/iverilog.git) - Tool for compiling ALL of the Verilog HDL, as described in the IEEE-1364 standard.
- [Yosys](https://github.com/YosysHQ/yosys.git) - Open SYnthesis Suite.
- [Verilator](https://github.com/verilator/verilator.git) - Open-source SystemVerilog simulator and lint system.
- [Verible](https://github.com/chipsalliance/verible.git) - Suite of SystemVerilog developer tools, including a parser, style-linter, formatter and language server.

### Verification & Testing

- [Cocotb](https://github.com/cocotb/cocotb.git) - Coroutine based cosimulation library for writing VHDL and Verilog testbenches in Python.
- [PyUVM](https://github.com/pyuvm/pyuvm.git) - The UVM written in Python.
- [MyHDL](https://github.com/myhdl/myhdl.git) - Package for using Python as a hardware description and verification language.
- [UVM-Python](https://github.com/tpoikela/uvm-python.git) - Python and cocotb-based port of the SystemVerilog Universal Verification Methodology (UVM) 1.2.
- [VUnit](https://github.com/VUnit/vunit.git) - Unit testing framework for VHDL/SystemVerilog.

### FPGA Vendor Tools

- [Gowin IDE](https://www.gowinsemi.com/) - Official IDE for Gowin FPGAs (Education Edition).

### Programming & Debugging

- [openFPGALoader](https://github.com/trabucayre/openFPGALoader.git) - Universal utility for programming FPGAs. Compatible with many boards including Sipeed Tang series.
- [PulseView](https://sigrok.org/wiki/PulseView) - Qt-based logic analyzer, oscilloscope and MSO GUI for sigrok.
- [sigrok-cli](https://sigrok.org/wiki/Sigrok-cli) - Command-line frontend for sigrok. Supports logic analyzers like the Sipeed SLogic16U3.

## Installation

### Clone repository and build image:

```bash
git clone https://github.com/yertools/FPGA-Tools-Docker.git
cd FPGA-Tools-Docker
docker build -t ghcr.io/yertools/fpga-tools-docker:latest .
```

### Or pull image:

```bash
docker pull ghcr.io/yertools/fpga-tools-docker:latest
```

### Run container:

```bash
docker run -it ghcr.io/yertools/fpga-tools-docker:latest
```

## Usage with Distrobox

This container is optimized for use with [Distrobox](https://github.com/89luca89/distrobox), allowing seamless integration with your Linux desktop.

### Create a Distrobox container:

```bash
distrobox create --image ghcr.io/yertools/fpga-tools-docker:latest --name fpga-tools
distrobox enter fpga-tools
```

### Export desktop applications (Gowin IDE, PulseView):

```bash
distrobox enter fpga-tools
distrobox-export --app gw_ide
distrobox-export --app pulseview
```

### USB Device Access

For USB device access (FPGA programmers, logic analyzers), reload udev rules on your host system:

```bash
# Reload udev rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# Add your user to the plugdev group
sudo usermod -aG plugdev $USER
```

You may need to log out and back in for group changes to take effect.
