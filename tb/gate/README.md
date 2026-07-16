# MTS functional gate smoke

This directory contains one external-port-only signature test compiled
unchanged against either the standalone VHDL synthesis top or the Quartus 18.1
post-fit Verilog netlist. The test does not override DUT generics and does not
reference internal hierarchy.

Run the RTL form without invoking Quartus:

```bash
make run_rtl
```

After a current-source standalone fit has completed, export and run the Arria V
functional netlist:

```bash
make gate_netlist
make run_gate
```

Compare the deterministic external signature from both representations with:

```bash
make compare
```

The netlist target rejects a fit summary older than any fit input. Quartus 18.1
produces a zero-delay functional model for this flow, so the comparison is
structural and cycle-functional evidence. Setup and hold closure remain owned by
the TimeQuest reports from the standalone compile.
