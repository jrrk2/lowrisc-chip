.SUFFIXES:

include sources.inc

REMOTE=lowrisc5.sm
export BOARD=nexys4_ddr
export CPU=rocket
export RISCV=/opt/riscv
export HOST=riscv64-unknown-linux-gnu
export CROSS_COMPILE=$(RISCV)/bin/$(HOST)-
export BUILDROOT_VER=buildroot-2019.11.1-lowrisc
BUILDROOT=$(PWD)/$(BUILDROOT_VER)/mainfs/images/rootfs.tar
ZROOT=$(PWD)/lowrisc-quickstart/rootfs.tar.zstd
RESCUECPIO=$(BUILDROOT_VER)/rescuefs/images/rootfs.cpio
export RISCV=$(PWD)/$(BUILDROOT_VER)/mainfs/host
export HOST=riscv64-buildroot-linux-gnu
export UBOOT=$(PWD)/$(BUILDROOT_VER)/mainfs/images/u-boot
export MAINKERNEL=lowrisc-quickstart/boot.bin
export RESCUEKERNEL=lowrisc-quickstart/rescue.bin
MD5=$(shell md5sum $(MAINKERNEL) | cut -d\  -f1)

default: nexys4_ddr_ariane

all: nexys4_ddr_ariane nexys4_ddr_rocket genesys2_ariane genesys2_rocket \
	nexys4_ddr_ariane_new nexys4_ddr_rocket_new genesys2_ariane_new genesys2_rocket_new
	for j in bit mcs; do for i in `cd fpga/work-fpga; find . -name \*.$$j`; do cp fpga/work-fpga/$$i lowrisc-quickstart/`echo $$i|sed -e 's=ariane/ariane=ariane=' -e 's=rocket/rocket=rocket='`; done; done

tftp: $(MAINKERNEL)
	md5sum $<
	echo -e bin \\n put $< $(MD5) \\n | tftp $(REMOTE)

$(MAINKERNEL): $(BUILDROOT_VER)/rescuefs/images/bbl
	cp $< $@

$(BUILDROOT_VER)/rescuefs/images/bbl $(BUILDROOT_VER)/mainfs/images/bbl: $(BUILDROOT)

$(RESCUEKERNEL): $(BUILDROOT_VER)/mainfs/images/bbl
	cp $< $@

fpga/src/etherboot/$(BOARD)_$(CPU).sv: fpga/src/generic.dts
	make -C fpga/src/etherboot BOARD=$(BOARD) CPU=$(CPU) VENDOR=$(VENDOR) MEMSIZE=$(MEMSIZE) PATH=$(RISCV)/bin:/usr/local/bin:/usr/bin:/bin

fpga/work-fpga/$(BOARD)_ariane/ariane_xilinx.mcs: $(ariane_pkg) $(util) $(src) $(fpga_src) \
        fpga/src/etherboot/$(BOARD)_$(CPU).sv
	@echo "[FPGA] Generate source list"
	@echo read_verilog -sv { $(ariane_pkg) $(filter-out $(fpga_filter), $(util) $(src)) $(fpga_src) $(open_src) $(addprefix $(root-dir)/,fpga/src/etherboot/$(BOARD)_$(CPU).sv) } > fpga/scripts/add_sources.tcl
	@echo "[FPGA] Generate Bitstream"
	make -C fpga mcs BOARD=$(BOARD) BITSIZE=$(BITSIZE) XILINX_PART=$(XILINX_PART) XILINX_BOARD=$(XILINX_BOARD) CPU=$(CPU) CLK_PERIOD_NS="20"

fpga/work-fpga/$(BOARD)_rocket/rocket_xilinx.mcs: $(ariane_pkg) $(util) $(src) $(fpga_src) \
	$(rocket_src) fpga/src/etherboot/$(BOARD)_$(CPU).sv
	@echo "[FPGA] Generate source list"
	@echo read_verilog -sv { $(ariane_pkg) $(filter-out $(fpga_filter), $(util) $(src)) $(fpga_src) $(open_src) $(rocket_src) $(addprefix $(root-dir)/,fpga/src/etherboot/$(BOARD)_$(CPU).sv) } > fpga/scripts/add_sources.tcl
	@echo "[FPGA] Generate Bitstream"
	make -C fpga mcs BOARD=$(BOARD) BITSIZE=$(BITSIZE) XILINX_PART=$(XILINX_PART) XILINX_BOARD=$(XILINX_BOARD) CPU=$(CPU) CLK_PERIOD_NS="20"

nexys4_ddr_ariane: $(RESCUEKERNEL)
	make fpga/work-fpga/nexys4_ddr_ariane/ariane_xilinx.mcs BOARD="nexys4_ddr" CPU="ariane" BITSIZE=0x400000 XILINX_PART=xc7a100tcsg324-1 XILINX_BOARD="digilentinc.com:nexys4_ddr:part0:1.1" VENDOR="ethz" MEMSIZE="0x8000000" BBL=$(root-dir)$< |& tee nexys4_ddr_ariane.log

nexys4_ddr_rocket: $(RESCUEKERNEL)
	make fpga/work-fpga/nexys4_ddr_rocket/rocket_xilinx.mcs BOARD="nexys4_ddr" CPU="rocket" BITSIZE=0x400000 XILINX_PART="xc7a100tcsg324-1" XILINX_BOARD="digilentinc.com:nexys4_ddr:part0:1.1" VENDOR="sifive" MEMSIZE="0x8000000" BBL=$(root-dir)$< |& tee nexys4_ddr_rocket.log

nexys_video_ariane: $(RESCUEKERNEL)
	make fpga/work-fpga/nexys4_video_ariane/ariane_xilinx.mcs BOARD="nexys_video" CPU="ariane" BITSIZE=0x800000 XILINX_PART="xc7a200tsbg484-1" XILINX_BOARD="digilentinc.com:nexys_video:part0:1.1" VENDOR="ethz" MEMSIZE="0x20000000" BBL=$(root-dir)$< |& tee nexys_video_ariane.log

nexys_video_rocket: $(RESCUEKERNEL)
	make fpga/work-fpga/nexys4_video_rocket/rocket_xilinx.mcs BOARD="nexys_video" CPU="rocket" BITSIZE=0x800000 XILINX_PART="xc7a200tsbg484-1" XILINX_BOARD="digilentinc.com:nexys_video:part0:1.1" VENDOR="sifive" MEMSIZE="0x20000000" BBL=$(root-dir)$< |& tee nexys_video_rocket.log

genesys2_ariane: $(RESCUEKERNEL)
	make fpga/work-fpga/genesys2_ariane/ariane_xilinx.mcs BOARD="genesys2" CPU="ariane" BITSIZE=0xB00000 XILINX_PART="xc7k325tffg900-2" XILINX_BOARD="digilentinc.com:genesys2:part0:1.1" VENDOR="ethz" MEMSIZE="0x40000000" BBL=$(root-dir)$< |& tee genesys2_ariane.log

genesys2_rocket: $(RESCUEKERNEL)
	make fpga/work-fpga/genesys2_rocket/rocket_xilinx.mcs BOARD="genesys2" CPU="rocket" BITSIZE=0xB00000 XILINX_PART="xc7k325tffg900-2" XILINX_BOARD="digilentinc.com:genesys2:part0:1.1" VENDOR="sifive" MEMSIZE="0x40000000" BBL=$(root-dir)$< |& tee genesys2_rocket.log

$(rocket_src): rocket-chip/vsim/Makefile
	make -C rocket-chip/vsim verilog

rocket-chip/vsim/Makefile:
	git submodule update --init --recursive rocket-chip

genesys2_ariane_new: $(RESCUEKERNEL)
	make -C fpga BOARD=genesys2 BITSIZE=0xB00000 CPU=ariane VENDOR=ethz MEMSIZE=0x40000000 BBL=$(root-dir)$< new newmcs

genesys2_rocket_new: $(RESCUEKERNEL)
	make -C fpga BOARD=genesys2 BITSIZE=0xB00000 CPU=rocket VENDOR=sifive MEMSIZE=0x40000000 BBL=$(root-dir)$< new newmcs

nexys4_ddr_ariane_new: $(RESCUEKERNEL)
	make -C fpga BOARD=nexys4_ddr BITSIZE=0x400000 CPU=ariane VENDOR=ethz MEMSIZE=0x8000000 BBL=$(root-dir)$< new newmcs

nexys4_ddr_rocket_new: $(RESCUEKERNEL)
	make -C fpga BOARD=nexys4_ddr BITSIZE=0x400000 CPU=rocket VENDOR=sifive MEMSIZE=0x8000000 BBL=$(root-dir)$< new newmcs

genesys2_ariane_program: $(RESCUEKERNEL)
	make -C fpga BOARD=genesys2 CPU=ariane JTAG_PART="xc7k325t_0" program

genesys2_rocket_program: $(RESCUEKERNEL)
	make -C fpga BOARD=genesys2 CPU=rocket JTAG_PART="xc7k325t_0" program

nexys4_ddr_ariane_program: $(RESCUEKERNEL)
	make -C fpga BOARD=nexys4_ddr CPU=ariane JTAG_PART="xc7a100t_0" program

nexys4_ddr_rocket_program: $(RESCUEKERNEL)
	make -C fpga BOARD=nexys4_ddr CPU=rocket JTAG_PART="xc7a100t_0" program

genesys2_ariane_cfgmem: $(RESCUEKERNEL)
	make -C fpga BOARD=genesys2 BITSIZE=0xB00000 XILINX_PART="xc7k325tffg900-2" XILINX_BOARD="digilentinc.com:genesys2:part0:1.1" CPU=ariane JTAG_PART="xc7k325t_0" JTAG_MEMORY="s25fl256sxxxxxx0-spi-x1_x2_x4" BBL=$(root-dir)$< cfgmem

genesys2_rocket_cfgmem: $(RESCUEKERNEL)
	make -C fpga BOARD=genesys2 BITSIZE=0xB00000 XILINX_PART="xc7k325tffg900-2" XILINX_BOARD="digilentinc.com:genesys2:part0:1.1" CPU=rocket JTAG_PART="xc7k325t_0" JTAG_MEMORY="s25fl256sxxxxxx0-spi-x1_x2_x4" BBL=$(root-dir)$< cfgmem

nexys4_ddr_ariane_cfgmem: $(RESCUEKERNEL)
	make -C fpga BOARD=nexys4_ddr BITSIZE=0x400000 XILINX_PART=xc7a100tcsg324-1 XILINX_BOARD="digilentinc.com:nexys4_ddr:part0:1.1" CPU=ariane JTAG_PART="xc7a100t_0" JTAG_MEMORY="s25fl128sxxxxxx0-spi-x1_x2_x4" BBL=$(root-dir)$< cfgmem

nexys4_ddr_rocket_cfgmem: $(RESCUEKERNEL)
	make -C fpga BOARD=nexys4_ddr BITSIZE=0x400000 XILINX_PART=xc7a100tcsg324-1 XILINX_BOARD="digilentinc.com:nexys4_ddr:part0:1.1" CPU=rocket JTAG_PART="xc7a100t_0" JTAG_MEMORY="s25fl128sxxxxxx0-spi-x1_x2_x4" BBL=$(root-dir)$< cfgmem

genesys2_ariane_cfgmem_new: $(RESCUEKERNEL)
	make -C fpga BOARD=genesys2  BITSIZE=0xB00000 XILINX_PART="xc7k325tffg900-2" XILINX_BOARD="digilentinc.com:genesys2:part0:1.1" CPU=ariane JTAG_PART="xc7k325t_0" JTAG_MEMORY="s25fl256sxxxxxx0-spi-x1_x2_x4" BBL=$(root-dir)$< cfgmem_new

genesys2_rocket_cfgmem_new: $(RESCUEKERNEL)
	make -C fpga BOARD=genesys2 BITSIZE=0xB00000 XILINX_PART="xc7k325tffg900-2" XILINX_BOARD="digilentinc.com:genesys2:part0:1.1" CPU=rocket JTAG_PART="xc7k325t_0" JTAG_MEMORY="s25fl256sxxxxxx0-spi-x1_x2_x4" BBL=$(root-dir)$< cfgmem_new

nexys4_ddr_ariane_cfgmem_new: $(RESCUEKERNEL)
	make -C fpga BOARD=nexys4_ddr BITSIZE=0x400000 XILINX_PART="xc7a100tcsg324-1" XILINX_BOARD="digilentinc.com:nexys4_ddr:part0:1.1" CPU=ariane JTAG_PART="xc7a100t_0" JTAG_MEMORY="s25fl128sxxxxxx0-spi-x1_x2_x4" BBL=$(root-dir)$< cfgmem_new

nexys4_ddr_rocket_cfgmem_new: $(RESCUEKERNEL)
	make -C fpga BOARD=nexys4_ddr BITSIZE=0x400000 XILINX_PART="xc7a100tcsg324-1" XILINX_BOARD="digilentinc.com:nexys4_ddr:part0:1.1" CPU=rocket JTAG_PART="xc7a100t_0" JTAG_MEMORY="s25fl128sxxxxxx0-spi-x1_x2_x4" BBL=$(root-dir)$< cfgmem_new

sdcard-install: $(ZROOT)
	make -C lowrisc-quickstart/ install USB=$(USB) ROOTFS=$<

sdcard-install-debian: $(PWD)/lowrisc-quickstart/rootfs.tar.xz
	make -C lowrisc-quickstart/ install-debian USB=$(USB) ROOTFS=$<

$(PWD)/lowrisc-quickstart/rootfs.tar.xz: debian-riscv64/work/makefile.inc
	make -C debian-riscv64

debian-riscv64/work/makefile.inc:
	git clone -b ariane-v0.7 https://github.com/lowRISC/debian-riscv64.git

firmware:
	make -B -C fpga/src/etherboot BOARD=nexys4_ddr BITSIZE=0x400000 XILINX_PART=xc7a100tcsg324-1 XILINX_BOARD=digilentinc.com:nexys4_ddr:part0:1.1 CPU=rocket VENDOR=sifive MEMSIZE=0x8000000 CLK_PERIOD_NS="20" PATH=$(RISCV)/bin:/usr/local/bin:/usr/bin:/bin
	make -B -C fpga/src/etherboot BOARD=nexys4_ddr BITSIZE=0x400000 XILINX_PART=xc7a100tcsg324-1 XILINX_BOARD=digilentinc.com:nexys4_ddr:part0:1.1 CPU=ariane VENDOR=ethz MEMSIZE=0x8000000 CLK_PERIOD_NS="20" PATH=$(RISCV)/bin:/usr/local/bin:/usr/bin:/bin

gdb: fpga/src/etherboot/$(BOARD)_$(CPU).elf
	$(BUILDROOT_VER)/mainfs/host/bin/riscv64-buildroot-linux-gnu-gdb -tui $<

debug:
	make -C lowrisc-quickstart debug

# Because of hidden dependencies, we build the normal dependency free kernel in the rescuefs tree,
# and the rescue kernel in the main tree, after the rootfs.cpio has been build in the rescuefs tree...

buildroot: $(BUILDROOT)

buildroot-clean: mainfs-clean rescuefs-clean

$(BUILDROOT_VER)/rescuefs/.config: buildroot-rescueconfig $(BUILDROOT_VER)/Makefile
	mkdir -p $(BUILDROOT_VER)/rescuefs
	cp $< $@
	make -C $(BUILDROOT_VER) O=rescuefs oldconfig

$(RESCUECPIO): $(BUILDROOT_VER)/rescuefs/.config
	make -C $(BUILDROOT_VER)/rescuefs

rescuefs-clean: $(BUILDROOT_VER)/rescuefs/.config
	make -C $(BUILDROOT_VER)/rescuefs clean

$(BUILDROOT_VER)/mainfs/.config: buildroot-defconfig buildroot-rescue-overlay/rdinit $(BUILDROOT_VER)/Makefile
	mkdir -p $(BUILDROOT_VER)/mainfs
	cp $< $@
	make -C $(BUILDROOT_VER) O=mainfs oldconfig

$(BUILDROOT): $(BUILDROOT_VER)/mainfs/.config $(RESCUECPIO)
	make -C $(BUILDROOT_VER)/mainfs

$(ZROOT): $(BUILDROOT)
	zstd -f $(BUILDROOT) -c > $@

mainfs-clean: $(BUILDROOT_VER)/mainfs/.config
	make -C $(BUILDROOT_VER)/mainfs clean
