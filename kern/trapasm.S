/*
 * Trap handler entry and exit code, written in assembly language.
 *
 * Copyright (C) 1997 Massachusetts Institute of Technology
 * See section "MIT License" in the file LICENSES for licensing terms.
 *
 * Derived from the MIT Exokernel and JOS.
 * Adapted for PIOS by Bryan Ford at Yale University.
 */

#include <inc/mmu.h>
#include <inc/trap.h>

#include <kern/cpu.h>



/* The TRAPHANDLER macro defines a globally-visible function for handling
 * a trap.  It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 */ 
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 1: Your code here for generating entry points for the different traps.
 */
//entry points
TRAPHANDLER_NOEC(iv0 ,0)
TRAPHANDLER_NOEC(iv1 ,1)
TRAPHANDLER_NOEC(iv2 ,2)
TRAPHANDLER_NOEC(iv3 ,3)
TRAPHANDLER_NOEC(iv4 ,4)
TRAPHANDLER_NOEC(iv5 ,5)
TRAPHANDLER_NOEC(iv6 ,6)
TRAPHANDLER_NOEC(iv7 ,7)
TRAPHANDLER(iv8 ,8)
TRAPHANDLER_NOEC(iv9 ,9)
TRAPHANDLER(iv10,10)
TRAPHANDLER(iv11,11)
TRAPHANDLER(iv12,12)
TRAPHANDLER(iv13,13)
TRAPHANDLER(iv14,14)
TRAPHANDLER_NOEC(iv15,15)
TRAPHANDLER_NOEC(iv16,16)
TRAPHANDLER(iv17,17)
TRAPHANDLER_NOEC(iv18,18)
TRAPHANDLER_NOEC(iv19,19)

/*
 * Lab 1: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
	pushl %ds
	pushl %es
        pushl %fs
        pushl %gs
        pushal
        // load CPU_GDT_KDATA into %ds and %es
        movw $CPU_GDT_KDATA, %ax
        movw %ax, %es
        movw %ax, %ds
        // pushl %esp to pass a pointer to the trapframe as an argument to trap()
        pushl %esp
        call trap

//
// Trap return code.
// C code in the kernel will call this function to return from a trap,
// providing the 
// Restore the CPU state from a given trapframe struct
// and return from the trap using the processor's 'iret' instruction.
// This function does not return to the caller,
// since the new CPU state this function loads
// replaces the caller's stack pointer and other registers.
//
.globl	trap_return
.type	trap_return,@function
.p2align 4, 0x90		/* 16-byte alignment, nop filled */
trap_return:
/*
 * Lab 1: Your code here for trap_return
 */

	movl 4(%esp), %esp
	popal
	popl %gs
	popl %fs
	popl %ds
	popl %es
	addl $8, %esp
	iret

//interrupt vectors
.data
.globl ivs
ivs:
	.long iv0  // #DE Divide Error
	.long iv1  // #DB RESERVED
	.long iv2  // — NMI Interrupt Interrupt Nonmaskable external interrupt.
	.long iv3  // #BP Breakpoint
	.long iv4  // #OF Overflow
	.long iv5  // #BR BOUND Range Exceeded
	.long iv6  // #UD Invalid Opcode (Undefined Opcode)
	.long iv7  // #NM Device Not Available (Math Coprocessor)
	.long iv8  // #DF Double Fault
	.long iv9  // Coprocessor Segment Overrun (reserved)
	.long iv10 // #TS Invalid TSS
	.long iv11 // #NP Segment Not Present
	.long iv12 // #SS Stack-Segment Fault
	.long iv13 // #GP General Protection
	.long iv14 // #PF Page Fault
	.long iv15 // — (Intel reserved. Do not use.)
	.long iv16 // #MF x87 FPU Floating-Point Error (Math Fault)
	.long iv17 // #AC Alignment Check
	.long iv18 // #MC Machine Check
	.long iv19 // #XF SIMD Floating-Point

