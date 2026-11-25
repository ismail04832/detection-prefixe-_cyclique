# OFDM cyclic-prefix detection metric

The [SystemVerilog datapath](corr_symbole.sv) compares each real-valued input sample with the sample received one FFT length earlier. It accumulates the absolute differences over a sliding guard interval. A low output indicates that the two windows resemble each other, as expected when a cyclic prefix repeats the end of an OFDM symbol.

| Parameter | Default | Meaning |
|---|---:|---|
| `gBits` | 14 | Signed input sample width |
| `gFFT_length` | 256 | Delay between the samples being compared |
| `gGard_length` | 32 | Number of differences in the sliding sum |

## Inspect the waveform

Run the [testbench](test.sv) from the repository root so it can open [the input samples](in_re5_chan2.txt). It drives `In_re` and writes `dump.vcd`. Compare `Corr_symbole` with `Enable` after the delay line has filled. The output is a running metric that a downstream detector can evaluate.

## Related RTL projects

[RISC-V processor](https://github.com/ismail04832/risc-v) · [Pipelined AES-128](https://github.com/ismail04832/AES128-pipelined-vhdl) · [Bus encoding and assertions](https://github.com/ismail04832/CRT) · [Dual-clock FIFO](https://github.com/ismail04832/asynch_fifo) · [RTL exercises](https://github.com/ismail04832/Training)
