#!/bin/bash
# Run Router Simulation

iverilog -o router_tb router.v router_tb.v
vvp router_tb
