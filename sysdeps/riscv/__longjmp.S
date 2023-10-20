/* longjmp, RISC-V version.
   Copyright (C) 1996-2023 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <https://www.gnu.org/licenses/>.  */

#include <sysdep.h>
#include <sys/asm.h>
#include <jmp_buf-ssp.h>

/*#if !Zicfiss_ENABLED
# undef SHADOW_STACK_POINTER_OFFSET
#endif*/

ENTRY (__longjmp)
	REG_L ra,  0*SZREG(a0)
	REG_L s0,  1*SZREG(a0)
	REG_L s1,  2*SZREG(a0)
	REG_L s2,  3*SZREG(a0)
	REG_L s3,  4*SZREG(a0)
	REG_L s4,  5*SZREG(a0)
	REG_L s5,  6*SZREG(a0)
	REG_L s6,  7*SZREG(a0)
	REG_L s7,  8*SZREG(a0)
	REG_L s8,  9*SZREG(a0)
	REG_L s9, 10*SZREG(a0)
	REG_L s10,11*SZREG(a0)
	REG_L s11,12*SZREG(a0)
	REG_L sp, 13*SZREG(a0)

#ifndef __riscv_float_abi_soft
	FREG_L fs0, 14*SZREG+ 0*SZFREG(a0)
	FREG_L fs1, 14*SZREG+ 1*SZFREG(a0)
	FREG_L fs2, 14*SZREG+ 2*SZFREG(a0)
	FREG_L fs3, 14*SZREG+ 3*SZFREG(a0)
	FREG_L fs4, 14*SZREG+ 4*SZFREG(a0)
	FREG_L fs5, 14*SZREG+ 5*SZFREG(a0)
	FREG_L fs6, 14*SZREG+ 6*SZFREG(a0)
	FREG_L fs7, 14*SZREG+ 7*SZFREG(a0)
	FREG_L fs8, 14*SZREG+ 8*SZFREG(a0)
	FREG_L fs9, 14*SZREG+ 9*SZFREG(a0)
	FREG_L fs10,14*SZREG+10*SZFREG(a0)
	FREG_L fs11,14*SZREG+11*SZFREG(a0)
#endif

#ifdef SHADOW_STACK_POINTER_OFFSET
  /* t1 is current ssp
     t2 is jmp_buf->saved_ssp */
  ssrdp t1
  beqz t1, L(skip_ssp)
  REG_L t2, SHADOW_STACK_POINTER_OFFSET(a0)

  /* following assembly C code

    // ssp: ssrdp t1 (current_ssp)
    // saved_ssp: jmp_buf->saved_ssp
    while(saved_ssp > ssp) {
      ssp = ((saved_ssp - ssp) >= 4096) ? ssp + 4096 : saved_ssp;
      asm volatile("csrw 0x20, %0": : "r"(ssp));
    }

  */
  bge t1, t2, L(skip_ssp)
  li t3, 4096
  li t4, 4095
L(advance_ssp):

#if __riscv_xlen == 64
  subw t5, t2, t1
#elif __riscv_xlen == 32
  sub t5, t2, t1
#endif
  blt t4, t5, L(add_4096)
  mv t1, t2
  j L(update_ssp)

L(add_4096):
#if __riscv_xlen == 64
  addw t1, t1, t3
#elif __riscv_xlen == 32
  add t1, t1, t3
#endif
L(update_ssp):
  csrw 0x20, t1
#if __riscv_xlen == 64
  ssld t0
#elif __riscv_xlen == 32
  sslw t0
#endif
  blt t1, t2, L(advance_ssp)

L(skip_ssp):
#endif

	seqz a0, a1
	add  a0, a0, a1   # a0 = (a1 == 0) ? 1 : a1
	ret

END (__longjmp)
