/* Internal header file for <setjmp.h>. riscv version.
*/

#ifndef _SETJMPP_H
#define _SETJMPP_H    1

#include <bits/types/__sigset_t.h>
#include <libc-pointer-arith.h>
#include <sigsetops.h>

//TODO common maximum sigset for i386, x32 and x86-64 is 12 bytes
// should know what its meaning for.
/* Number of bits per long.  */
#define _JUMP_BUF_SIGSET_BITS_PER_WORD (8 * sizeof (unsigned long int))
/* The biggest signal number.  As of kernel 4.14, x86 _NSIG is 64. The
   common maximum sigset for i386, x32 and x86-64 is 12 bytes (96 bits).
   Define it to 96 to leave some rooms for future use.  */
#define _JUMP_BUF_SIGSET_NSIG 96
/* Number of longs to hold all signals.  */
#define _JUMP_BUF_SIGSET_NWORDS \
  (ALIGN_UP (_JUMP_BUF_SIGSET_NSIG, _JUMP_BUF_SIGSET_BITS_PER_WORD) \
   / _JUMP_BUF_SIGSET_BITS_PER_WORD)

typedef struct {
  unsigned long int __val[_JUMP_BUF_SIGSET_NWORDS];
} __jmp_buf_sigset_t;

typedef union {
  __sigset_t __saved_mask_compat;
  struct {
    __jmp_buf_sigset_t __saved_mask;
    /* Used for shadow stack pointer.  NB: Shadow stack pointer
       must have the same alignment as __saved_mask.  Otherwise
       offset of __saved_mask will be changed.  */
    unsigned long int __shadow_stack_pointer;
  } __saved;
} __jmpbuf_arch_t;

#undef __sigset_t
#define __sigset_t __jmpbuf_arch_t
#include <setjmp.h>
#undef __saved_mask
#define __saved_mask __saved_mask.__saved.__saved_mask

/*#include <signal.h>

typedef struct {
  unsigned long int __val[__NSIG_WORDS];
} __sigprocmask_sigset_t;

extern jmp_buf ___buf;
extern  __typeof (___buf[0].__saved_mask) ___saved_mask;
_Static_assert (sizeof (___saved_mask) >= sizeof (__sigprocmask_sigset_t),
    "size of ___saved_mask < size of __sigprocmask_sigset_t");*/

#endif /* setjmpP.h  */
