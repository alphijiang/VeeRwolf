# VeeR EH2 1.4 on Nexys A7 / Nexys 4 DDR

Package revision: **V21**.

All paths in this document are relative to the VeeRwolf repository root (the
directory that contains `veerwolf.core`). Do not copy the EH2 files into the
Cores-VeeR-EH2 repository.

## File placement

```text
VeeRwolf/
├── veerwolf.core                         # modified
├── README.md                             # modified
├── sw/
│   ├── boot_main.S                       # modified, SW-selected ICCM boot
│   └── bootloader.vh                     # matching prebuilt Boot ROM image
├── rtl/
│   ├── clk_gen_nexys.v                   # modified, EH2 40 MHz/reset release
│   ├── veerwolf_core.v                   # modified, shared AXI ID adaptation
│   ├── veerwolf_nexys.v                  # modified, external common JTAG
│   └── veer_eh2_wrapper.sv               # new
├── cores/
│   ├── veer_eh2.core                     # new
│   ├── litedram/litedram.xdc              # modified, DDR2 VREF correction
│   └── config/
│       └── eh2_nexys_a7/
│           ├── common_defines.vh         # new
│           ├── eh2_pdef.vh               # new
│           ├── eh2_param.vh              # new
│           ├── link.ld                    # generated
│           ├── pic_map_auto.h            # new
│           └── vivado.tcl                 # new
├── data/
│   ├── veerwolf_nexys.xdc                # modified, external JTAG/CDC
│   ├── vivado_waiver.tcl                  # upstream EH1/EL2 rules, unchanged
│   └── veerwolf_nexys_eh2_debug.cfg      # new
├── docs/
│   ├── c232hm-nexys4-jtag-wiring.svg     # new
│   ├── c232hm-nexys4-jtag-wiring.png     # new
│   ├── veerwolf-eh2-system-block-diagram.svg
│   ├── veerwolf-eh2-system-block-diagram.png
│   ├── veerwolf-eh2-architecture-reference.svg
│   └── veerwolf-eh2-architecture-reference.png
└── zephyr/boards/riscv/veerwolf_nexys/
    ├── veerwolf_nexys_eh2.conf            # optional 40 MHz override
    └── veerwolf_nexys_eh2.overlay         # optional 40 MHz override
```

The `cores/veer_eh2.core` provider downloads the official Cores-VeeR-EH2 1.4
RTL at commit `fd2bc651393e47b3170ac6f7142725dbef20e99a`. The generated headers
under `cores/config/eh2_nexys_a7/` belong to VeeRwolf and must remain at the
paths shown above.

## One-time host setup

Install FuseSoC and the host build tools:

```bash
python3 -m pip install --user fusesoc
sudo apt-get install git make verilator
```

Install Vivado with Artix-7 device support, then load its environment before
building. Change the path/version to match the local installation:

```bash
source /tools/Xilinx/Vivado/2024.2/settings64.sh
vivado -version
```

## Register the local source tree

The following example assumes this complete repository is extracted as
`$PWD/VeeRwolf`:

```bash
mkdir -p veerwolf-eh2-work
cd veerwolf-eh2-work

export VEERWOLF_ROOT="$(realpath ../VeeRwolf)"

fusesoc library add fusesoc-cores https://github.com/fusesoc/fusesoc-cores
fusesoc library add veerwolf-eh2 "$VEERWOLF_ROOT"

fusesoc core show veerwolf
```

Only one VeeRwolf source tree should be registered with FuseSoC. If the
unmodified upstream VeeRwolf library is already registered, use a clean
FuseSoC workspace/config or remove that library before adding this local tree.

## Build the FPGA image

Run this command from `veerwolf-eh2-work`, not from inside
`Cores-VeeR-EH2`:

```bash
fusesoc run --target=nexys_a7 --flag=cpu_eh2 veerwolf
```

V21 keeps the common VeeRwolf reset vector at the upstream Boot ROM address
`0x80000000`. It removes the experimental hardware reset-vector selector from
V18; EH1, EH2 and EL2 therefore retain the same first-stage boot architecture.
The common Boot ROM uses SW15:SW14=`11` to continue at ICCM address
`0xEE000000`; it does not change the hardware reset vector or copy an image.

FuseSoC performs these operations automatically:

1. Resolves the VeeRwolf and `fusesoc-cores` dependencies.
2. Downloads the pinned Cores-VeeR-EH2 1.4 RTL.
3. Generates the AXI and Wishbone interconnects.
4. Invokes Vivado for `xc7a100tcsg324-1`.
5. Produces the bitstream under the FuseSoC `build/` directory.

The EH2 targets intentionally do not invoke VeeRwolf's optional `gitversion`
generator. This allows the ZIP/source archive to build without a `.git`
directory; `veerwolf_syscon.v` supplies its built-in fallback version fields.
The checked-in `sw/bootloader.vh` already matches `sw/boot_main.S`. If the
Boot ROM source is edited again, regenerate it on Linux before FPGA synthesis:

```bash
make -C sw bootloader.vh
```

The EH2 Vivado Tcl file marks `common_defines.vh` and `eh2_pdef.vh` as global
includes so every separately elaborated EH2 source sees the same macros and
the `eh2_param_t` type.
The Nexys target keeps both harts, atomic instructions and fast interrupt
redirect. It uses 64 KiB ICCM at `0xEE000000`, 32 KiB DCCM at `0xF0040000`,
and a 128-source PIC at `0xF00C0000`. The instruction cache is disabled on
Nexys A7 because the official 8 KiB cache configuration failed physical
placement; external DDR2 instruction fetches are therefore uncached. ICCM is
the intended high-speed instruction memory for this target. FPGA-sized predictor and queue
depths are retained: 16-entry BTB, 64-entry BHT, and
a 4-entry LSU store buffer with 2 non-blocking loads and a 2-entry DMA buffer.
The store-buffer depth must remain at least four in the dual-hart build;
depth two makes EH2's per-thread `DEPTH-2` full threshold zero and blocks all
stores immediately after reset.

`LOAD_TO_USE_BUS_PLUS1=1` and `LOAD_TO_USE_PLUS1=0` are the official
`default_mt` generator results. The similarly named parameters control two
different paths. RTL inspection shows that `LOAD_TO_USE_PLUS1=1` adds a DCCM
BRAM-output register stage, moves load data by one cycle, and selects matching
ECC, store-forward, dependency bypass and hazard-stall logic. Both values have
complete RTL implementations and neither branch is conditioned on
`NUM_THREADS`. It must therefore remain zero unless a post-route report shows
that the DCCM bank-output/mux path itself needs the extra pipeline stage. The
V14 timing violation was in the 40/100 MHz AXI CDC path, so it is not evidence
for changing DCCM load latency.

The EH2 PLL output is 40 MHz and the syscon clock-frequency register reports
`40,000,000`. The official generator's `CLOCK_PERIOD=100` definition is
retained unchanged because it is testbench/configuration metadata, not the
Nexys hardware clock constraint. The hardware period is derived by Vivado
from `clk_gen_nexys.v` and the board XDC.
The Nexys constraints set Bank 34 `INTERNAL_VREF` to `0.900 V` for SSTL18_II
DDR2 and set `CFGBVS=VCCO`, `CONFIG_VOLTAGE=3.3` for the configuration bank.

Locate the generated bitstream with:

```bash
find build -type f -name '*.bit'
```

After implementation, open the routed design and generate expanded DRC, CDC,
methodology, clock-interaction and timing qualification reports in the Vivado
Tcl console:

```tcl
open_run impl_1
set_property MAX_MESSAGES 50000 [get_drc_checks REQP-1839]
set_property MAX_MESSAGES 50000 [get_drc_checks REQP-1840]
report_drc -file veerwolf_nexys_a7_drc_full_routed.rpt
report_drc -checks {REQP-1839 REQP-1840} -file veerwolf_nexys_a7_drc_async_bram_routed.rpt
report_cdc -details -file veerwolf_nexys_a7_cdc_routed.rpt
report_methodology -file veerwolf_nexys_a7_methodology_routed.rpt
report_clock_interaction -file veerwolf_nexys_a7_clock_interaction_routed.rpt
report_timing_summary -report_unconstrained -check_timing_verbose \
    -file veerwolf_nexys_a7_timing_summary_routed.rpt
```

The earlier 50- and 1000-message settings are insufficient for this EH2
configuration; a full report can contain more than 10000 instances of each
REQP check before grouping identical targets. Do not suppress these checks or
create path-wide waivers merely because normal firmware boots successfully.
The CDC and clock-interaction reports are also required before qualifying the
official DMI wrapper's external-JTAG integration. The PULP AXI CDC between
the 40 MHz core and 100 MHz LiteDRAM domains is constrained according to its
official Gray-FIFO requirement: both directions retain a 10 ns datapath upper
bound (the shorter clock period), while only asynchronous hold checks are
disabled. LiteDRAM `init_done` and `init_error` pass through explicit two-FF
core-clock synchronizers. V21 contains no replacement DMI handshake.

## Compatibility with upstream board targets

The common VeeRwolf SoC interface remains shared by EH1, EH2 and EL2. The
external Nexys Pmod JTAG transport is intentionally available to all three
cores because their official packages expose the same `dmi_wrapper` ports.
Only `nexys_a7 --flag=cpu_eh2` selects the new EH2 wrapper and generated EH2
configuration; Agilex 5, Basys 3, Arty A7 and Nexys Video retain their
upstream target files, CPU choices, clocks and board constraints.

The shared `veerwolf_core.v` does not name the EH2-only
`dec_tlu_mhartstart` wrapper port. Named-port omission is deliberate: EH2 may
leave that status output unused, while EH1 and EL2 wrappers continue to
elaborate without an unknown-port error.

## Dual-hart integration and qualification

The generated EH2 configuration has `NUM_THREADS=2`. Its reset/start behavior
follows EH2 PRM 1.4:

1. Hart0 starts from the reset vector with `mhartid=0`.
2. Hart0 prepares separate hart1 stack and per-hart state.
3. Hart0 writes `MHARTSTART.start1`, CSR `0x7FC` bit 1.
4. Hart1 starts from the same reset vector with `mhartid=1` and branches to
   its own startup path.

Writing `1` to this CSR does **not** start hart1; bit 0 is the read-only hart0
status. Use `0x2` (or the upstream EH2 tests' equivalent value `0x3`). The
OpenOCD helper in `data/veerwolf_nexys_eh2_debug.cfg` writes `0x2`.

The upstream VeeRwolf CPU interface exposes one timer interrupt and scalar
PMU/MPC controls. The EH2 wrapper therefore connects the timer to both
per-hart timer inputs and replicates the scalar PMU/MPC controls to both
harts. This is required for the unused `mpc_reset_run_req[1:0]` interface,
which the EH2 PRM requires to be tied high. The timer is shared: each hart has
its own `mie.mtie` mask, but firmware must coordinate access to and clearing
of the single syscon timer source.

EH2 contains one multi-thread-aware PIC. Each external source can be delegated
to either hart through the thread-specific PIC configuration; no second PIC
instance is required. The current VeeRwolf platform has no two-bit MSI MMIO
block, so `soft_int[1:0]` are intentionally inactive. Do not remap syscon
`sw_irq3/sw_irq4` to `soft_int`: those are existing PIC qualification sources
and changing their meaning would break upstream VeeRwolf behavior.

A hardware dual-hart qualification firmware must, at minimum:

- use a separate stack for each `mhartid` before either hart calls C code;
- have hart0 write CSR `0x7FC` bit 1 and observe hart1 reach a shared DCCM or
  DDR rendezvous flag;
- have both harts perform atomic increments in shared DCCM and verify the
  exact final count;
- delegate one PIC source to hart0 and a different source to hart1, then
  verify the corresponding per-hart interrupt counters;
- enable and mask the shared timer independently on each hart, while allowing
  only one owner to clear/rearm the platform timer;
- attach GDB to both OpenOCD targets and verify `mhartid`, independent PC,
  register access, halt, resume and hardware breakpoints.

Static RTL/configuration checks can prove that both harts are instantiated and
wired, but they cannot replace this board test. Do not claim dual-hart hardware
qualification until all of the checks above have passed on the generated V21
bitstream.

The 8 KiB instruction-cache experiment introduced in V19 was removed in V21.
The generated cache structure was valid, but Vivado reported that the design
needed 14,530 slices while only 14,351 were available for placement. Relative
to the previous placed design, the cached build added approximately 5,945 LUTs,
4,434 flip-flops, 68 control sets and eight RAMB36 blocks. Placement directives
cannot create the missing logic or packing capacity, and reducing ICCM/DCCM
would primarily save BRAM rather than the limiting LUT/slice resources. Keep
`ICACHE_ENABLE=0` for Nexys A7; re-enable and qualify the cache only on a larger
FPGA target.

If the board was not programmed during the build, program it without
rebuilding:

```bash
fusesoc run --target=nexys_a7 --flag=cpu_eh2 --run veerwolf
```

## RTL lint and simulation

```bash
fusesoc run --target=lint_eh2 veerwolf
fusesoc run --target=sim_eh2 veerwolf
```

## Optional Zephyr clock override

The upstream `veerwolf_nexys` board files remain unchanged for EH1/EL2. When
building Zephyr for the 40 MHz EH2 image, opt in to the two EH2 clock override
files explicitly:

```bash
west build -b veerwolf_nexys /path/to/application -- \
  -DEXTRA_CONF_FILE="$VEERWOLF_ROOT/zephyr/boards/riscv/veerwolf_nexys/veerwolf_nexys_eh2.conf" \
  -DDTC_OVERLAY_FILE="$VEERWOLF_ROOT/zephyr/boards/riscv/veerwolf_nexys/veerwolf_nexys_eh2.overlay"
```

This preserves the official board name and file structure. It does not create
an unregistered board variant or change the default EH1/EL2 clock metadata.

## Program with OpenOCD and connect to both harts

Programming with OpenOCD avoids leaving the Vivado hardware manager holding
the JTAG interface:

```bash
BITFILE="$(find build -type f -name '*.bit' -print -quit)"
openocd -c "set BITFILE $BITFILE" \
    -f "$VEERWOLF_ROOT/data/veerwolf_nexys_program.cfg"
```

Connect an FT232H MPSSE adapter to Pmod JC (`ADBUS0/JC1=TCK`,
`ADBUS1/JC2=TDI`, `ADBUS2/JC3=TDO`, `ADBUS3/JC4=TMS`, plus GND), then start
the EH2 SMP debug server with the
[alphijiang OpenOCD fork](https://github.com/alphijiang/openocd):

![C232HM-DDHSL-0 to Nexys 4 DDR Pmod JC JTAG wiring](docs/c232hm-nexys4-jtag-wiring.svg)

Use the 3.3 V `C232HM-DDHSL-0` variant. Connect its black ground lead to JC5
or JC11, and leave the red VCC lead disconnected while the Nexys board is
powered from its normal supply.

```bash
openocd -f "$VEERWOLF_ROOT/data/veerwolf_nexys_eh2_debug.cfg"
```

The default command exposes hart0 only. To ask the debugger to set
`MHARTSTART.start1`, examine hart1 and form an SMP target group, start OpenOCD
with:

```bash
openocd -c "set EH2_START_HART1 1" \
    -f "$VEERWOLF_ROOT/data/veerwolf_nexys_eh2_debug.cfg"
```

Firmware-driven startup is preferable for the final application because it
can initialize hart1's stack and per-hart data before setting `start1`.

This target uses the EH2 direct 5-bit JTAG DTM. It does not use the Xilinx
`BSCANE2` tunnel or its USER instruction opcodes.

The standard system bus reaches VeeRwolf DDR and peripherals. The modified
OpenOCD EH2 abstract-memory path supports 8-, 16- and 32-bit ICCM reads and
writes, with ICCM range `0xEE000000` through `0xEE00FFFF` and DCCM range
`0xF0040000` through `0xF0047FFF`. This is an OpenOCD-side compatibility
change for memory inspection and software-breakpoint insertion/restoration;
the EH2 ICCM RTL remains unchanged and the Debug Module still has
`progbufsize=0`.
