/*
 NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
 This is an automatically generated file by  on Fri Aug 28 16:33:52 AEST 2026

 cmd:    swerv -target=default_mt -unset=assert_on -set=reset_vec=0x80000000 -set=fpga_optimize=1 -set=fast_interrupt_redirect=1 -set=dccm_enable=1 -set=dccm_size=32 -set=dccm_num_banks=4 -set=dccm_offset=0x40000 -set=iccm_enable=1 -set=iccm_size=64 -set=iccm_num_banks=4 -set=iccm_offset=0xe000000 -set=icache_enable=0 -set=pic_offset=0xc0000 -set=pic_total_int=128 -set=ret_stack_size=2 -set=btb_size=16 -set=bht_size=64 -set=lsu_stbuf_depth=4 -set=lsu_num_nbload=2 -set=dma_buf_depth=2 -set=div_bit=1 -snapshot=eh2_nexys_a7_v21 

*/

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text.init .  : { *(.text.init) }
   . = 0xee000000 ;
  .text . : { *(.text) }
  _end = .;
  . = 0xd0580000;
  .data.io .  : { *(.data.io) }
    . = 0xf0040000 ;
  .data  :  ALIGN(0x800) { *(.*data) *(.rodata*) STACK = ALIGN(16) + 0x8000; }
  .bss : { *(.bss) }
    . = 0xfffffff0; .iccm.ctl . : { LONG(0xee000000); LONG(0xee00ffff) }
    . = 0xfffffff8; .data.ctl : { LONG(0xf0040000); LONG(STACK) }
}

