IEEE754MULT	stmed	r13!, {r0-r1,r3-r12}
			mov		r2, #0
			lsl		r3, r0, #1
			lsl		r4, r1, #1
			ldr		r7, =0xFF800000
			cmp		r3, r7 ;checks whether r0 is QNan
			ldrhs	r2, =0x7FC00001
			bhs		sign
			cmp		r4, r7 ;checks whether r1 is QNan
			ldrhs	r2, =0x7FC00001
			bhs		sign
			ldr		r7, =0xFF000000
			cmp		r3, r7 ;checks whether r0 is SNan
			ldrhs	r2, =0x7F800001
			cmphs	r4, #0 ;checks whether r0 is Snan and r1 is zero
			ldrhs	r2, =0x7FC00001
			cmp		r3, r7
			bhs		sign
			ldr		r7, =0xFF000000
			cmp		r4, r7 ;checks whether r1 is SNan
			ldrhs	r2, =0x7F800001
			cmphs	r4, #0 ;checks whether r0 is SNan and r1 is zero
			ldrhs	r2, =0x7FC00001
			cmp		r4, r7
			bhs		sign
			ldr		r7, =0xFF000000
			cmp		r3, r7 ;checks whether r0 is infinity
			ldrhs	r2, =0x7F800001 ;if r0 is greater than infinty but less than qNan it must be a sNan
			movhs	r2, r7
			cmphs	r4, #0 ;checks whether r0 is infinity and r1 is zero
			ldrhs	r2, =0x7FC00001
			cmp		r3, r7
			bhs		sign
			cmp		r4, r7 ;checks whether r1 is infinity
			ldrhs	r2, =0x7F800001 ;if r1 is greater than infinty but less than qNan it must be a sNan
			movhs	r2, r7
			cmphs	r3, #0 ;checks whether r1 is infinity and r0 is zero
			ldrhs	r2, =0x7FC00001
			cmp		r4, r7
			bhs		sign
			mov		r3, #0
			lsl		r3, r0, #1
			lsr		r3, r3, #24
			mov		r4, #0
			lsl		r4, r1, #1
			lsr		r4, r4, #24
			lsl		r5, r0, #9
			lsr		r5, r5, #9
			mov		r8, #1
			cmp		r3, #0
			stmed	r13!, {lr}
			bleq		denormalized1
			ldmed	r13!, {lr}
			add		r5, r5, r8, lsl #23
			lsl		r6, r1, #9
			lsr		r6, r6, #9
			mov		r8, #1
			cmp		r4, #0
			stmed	r13!, {lr}
			bleq		denormalized2
			ldmed	r13!, {lr}
			sub		r3, r3, #127 ;adjust the exponents
			sub		r4, r4, #127 ;adjust the exponents
			add		r6, r6, r8, lsl #23
			mov		r7, #0
			add		r7, r7, #1
LOOP2		lsrs		r5, r5, #1
			subcs	r7, r7, #1
			lslcs	r5, r5, #1
			addcs	r5, r5, #1
			bcs		skip
			addcc	r7, r7, #1
			bcc		LOOP2
skip			add		r7, r7, #1
LOOP3		lsrs		r6, r6, #1
			subcs	r7, r7, #1
			lslcs	r6, r6, #1
			addcs	r6, r6, #1
			bcs		skip2
			addcc	r7, r7, #1
			bcc		LOOP3
skip2		rsb		r11, r7, #46
MUL24X24		mov		r8, #0
			mov		r9, #0
			mov		r10, #0
LOOP			lsrs		r6, r6, #1
			rsbcs	r7, r10, #32
			addcs	r9, r9, r5, lsr r7
			addscs	r8,r8,r5, lsl r10
			adccs	r9, r9, #0
			add		r10, r10, #1
			cmp		r10, #24
			bne		LOOP ;by the time this loop does not break the mantissas are multiplied
skip4		stmed	r13!, {r8-r9}
			mov		r10, #0
			cmp		r9, #0
			beq		LOOP5
LOOP4		lsls		r9, r9, #1
			addcc	r10, r10, #1
			bcc		LOOP4
			rsb		r10, r10, #32
			mov		r12, #0
			add		r12, r10, #32
			b		skip3
LOOP5		lsls		r8, r8, #1
			addcc	r10, r10, #1
			bcc		LOOP5
			rsb		r12, r10, #32
			ldmed	r13!, {r8-r9}
			sub		r6, r12, r11
			sub		r6, r6, #1
			add		r3, r3, r4 ;add the two initial exponent
			add		r3, r3, r6 ;calculate final exponent
			cmp		r3, #-149 ;check for underflow
			movlt	r2, #0
			blt		finish
			cmp		r3, #127 ; check for overflow
			ldrgt	r2, =0x7F800001
			bgt		sign
			add		r10, r10, #1
			lsl		r8, r8, r10
			lsr		r8, r8, r10
			rsb		r11, r10, #32
			rsb		r11, r11, #24
			add		r2, r2, r8, lsl r11
			b		continue
skip3
			ldmed	r13!, {r8-r9}
			sub		r6, r12, r11
			sub		r6, r6, #1
			add		r3, r3, r4 ;add the two initial exponent
			add		r3, r3, r6 ;calculate final exponent
			cmp		r3, #-149 ;check for underflow
			movlt	r2, #0
			blt		finish
			cmp		r3, #127 ; check for overflow
			ldrgt	r2, =0x7F800001
			bgt		sign
			sub		r10, r10, #1
			rsb		r5, r10, #32
			lsl		r9, r9, r5
			lsr		r9, r9, r5
			rsb		r10, r10, #24 ; changes the
			rsb		r11, r10, #32
			add		r2, r2, r9, lsl r10
			add		r2, r2, r8, lsr r11
continue		lsrs		r2, r2, #1
			adc		r2, r2, #0
			cmp		r2, #0
			beq		exp
			cmp		r3, #-127
			bgt		exp
			add		r7, r3, #126
			rsb		r7, r7, #0
			add		r2, r2, #0x800000
			lsrs		r2, r2, r7
			adccs	r2, r2, #0
			mov		r3, #-127
exp			add		r3, r3, #127 ;add bias to the final exponent
			add		r2, r2, r3, lsl #23 ;place the exponent into the asnwer
sign			lsr		r0, r0, #31 ;find the sign of r0
			lsr		r1, r1, #31 ;find the sign of r1
			add		r0, r0, r1
			add		r2, r2, r0, lsl #31 ;place sign in answer
finish		ldmed	r13!, {r0-r1,r3-r12}
			mov		pc, lr
			
denormalized1	mov		r7, #0
IN1			cmp		r7, #24
			moveq	pc, lr
			lsls		r5, r5, #10
			addcc	r7, r7, #1
			subcc	r3, r3, #1
			lsr		r5, r5, #9
			bcc		IN1
			mov		pc, lr
			
			
denormalized2	mov		r7, #0
IN2			cmp		r7, #24
			moveq	pc, lr
			lsls		r6, r6, #10
			addcc	r7, r7, #1
			subcc	r4, r4, #1
			lsr		r6, r6, #9
			bcc		IN2
			mov		pc, lr
