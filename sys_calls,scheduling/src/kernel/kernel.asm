
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a8010113          	addi	sp,sp,-1408 # 80008a80 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8ee70713          	addi	a4,a4,-1810 # 80008940 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	3cc78793          	addi	a5,a5,972 # 80006430 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd844f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	4aa080e7          	jalr	1194(ra) # 800025d6 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8f650513          	addi	a0,a0,-1802 # 80010a80 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8e648493          	addi	s1,s1,-1818 # 80010a80 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	97690913          	addi	s2,s2,-1674 # 80010b18 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	808080e7          	jalr	-2040(ra) # 800019c8 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	256080e7          	jalr	598(ra) # 8000241e <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	f94080e7          	jalr	-108(ra) # 8000216a <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	36c080e7          	jalr	876(ra) # 8000257e <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	85a50513          	addi	a0,a0,-1958 # 80010a80 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	84450513          	addi	a0,a0,-1980 # 80010a80 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	8af72323          	sw	a5,-1882(a4) # 80010b18 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	7b450513          	addi	a0,a0,1972 # 80010a80 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	33c080e7          	jalr	828(ra) # 8000262e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	78650513          	addi	a0,a0,1926 # 80010a80 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	76270713          	addi	a4,a4,1890 # 80010a80 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	73878793          	addi	a5,a5,1848 # 80010a80 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7a27a783          	lw	a5,1954(a5) # 80010b18 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6f670713          	addi	a4,a4,1782 # 80010a80 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6e648493          	addi	s1,s1,1766 # 80010a80 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	6aa70713          	addi	a4,a4,1706 # 80010a80 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	72f72a23          	sw	a5,1844(a4) # 80010b20 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	66e78793          	addi	a5,a5,1646 # 80010a80 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ec7a323          	sw	a2,1766(a5) # 80010b1c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6da50513          	addi	a0,a0,1754 # 80010b18 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	d88080e7          	jalr	-632(ra) # 800021ce <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	62050513          	addi	a0,a0,1568 # 80010a80 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00025797          	auipc	a5,0x25
    8000047c:	da078793          	addi	a5,a5,-608 # 80025218 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5e07ab23          	sw	zero,1526(a5) # 80010b40 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	38f72123          	sw	a5,898(a4) # 80008900 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	586dad83          	lw	s11,1414(s11) # 80010b40 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	53050513          	addi	a0,a0,1328 # 80010b28 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	3d250513          	addi	a0,a0,978 # 80010b28 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	3b648493          	addi	s1,s1,950 # 80010b28 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	37650513          	addi	a0,a0,886 # 80010b48 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	1027a783          	lw	a5,258(a5) # 80008900 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0d27b783          	ld	a5,210(a5) # 80008908 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0d273703          	ld	a4,210(a4) # 80008910 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2e8a0a13          	addi	s4,s4,744 # 80010b48 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	0a048493          	addi	s1,s1,160 # 80008908 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	0a098993          	addi	s3,s3,160 # 80008910 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	93c080e7          	jalr	-1732(ra) # 800021ce <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	27a50513          	addi	a0,a0,634 # 80010b48 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	0227a783          	lw	a5,34(a5) # 80008900 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	02873703          	ld	a4,40(a4) # 80008910 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	0187b783          	ld	a5,24(a5) # 80008908 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	24c98993          	addi	s3,s3,588 # 80010b48 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	00448493          	addi	s1,s1,4 # 80008908 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	00490913          	addi	s2,s2,4 # 80008910 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00002097          	auipc	ra,0x2
    80000920:	84e080e7          	jalr	-1970(ra) # 8000216a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	21648493          	addi	s1,s1,534 # 80010b48 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	fce7b523          	sd	a4,-54(a5) # 80008910 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	18c48493          	addi	s1,s1,396 # 80010b48 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00026797          	auipc	a5,0x26
    80000a02:	9b278793          	addi	a5,a5,-1614 # 800263b0 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	16290913          	addi	s2,s2,354 # 80010b80 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	0c650513          	addi	a0,a0,198 # 80010b80 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00026517          	auipc	a0,0x26
    80000ad2:	8e250513          	addi	a0,a0,-1822 # 800263b0 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	09048493          	addi	s1,s1,144 # 80010b80 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	07850513          	addi	a0,a0,120 # 80010b80 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	04c50513          	addi	a0,a0,76 # 80010b80 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e3c080e7          	jalr	-452(ra) # 800019ac <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	e0a080e7          	jalr	-502(ra) # 800019ac <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	dfe080e7          	jalr	-514(ra) # 800019ac <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	de6080e7          	jalr	-538(ra) # 800019ac <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	da6080e7          	jalr	-602(ra) # 800019ac <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d7a080e7          	jalr	-646(ra) # 800019ac <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b1c080e7          	jalr	-1252(ra) # 8000199c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a9070713          	addi	a4,a4,-1392 # 80008918 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	b00080e7          	jalr	-1280(ra) # 8000199c <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	a7a080e7          	jalr	-1414(ra) # 80002938 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	5aa080e7          	jalr	1450(ra) # 80006470 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	0ea080e7          	jalr	234(ra) # 80001fb8 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	9b8080e7          	jalr	-1608(ra) # 800018e6 <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	9da080e7          	jalr	-1574(ra) # 80002910 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	9fa080e7          	jalr	-1542(ra) # 80002938 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	514080e7          	jalr	1300(ra) # 8000645a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	522080e7          	jalr	1314(ra) # 80006470 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	6b2080e7          	jalr	1714(ra) # 80003608 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	d56080e7          	jalr	-682(ra) # 80003cb4 <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	cf4080e7          	jalr	-780(ra) # 80004c5a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	60a080e7          	jalr	1546(ra) # 80006578 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	dea080e7          	jalr	-534(ra) # 80001d60 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	98f72a23          	sw	a5,-1644(a4) # 80008918 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9887b783          	ld	a5,-1656(a5) # 80008920 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	622080e7          	jalr	1570(ra) # 80001850 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	6ca7b623          	sd	a0,1740(a5) # 80008920 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <random_number>:
#include "user/syscount.h"

#define NUM_SYSCALLS 25

int random_number(int max)
{
    80001836:	1141                	addi	sp,sp,-16
    80001838:	e422                	sd	s0,8(sp)
    8000183a:	0800                	addi	s0,sp,16
  int seed = 123456789;                              
  seed = (1664525 * seed + 1013904223) % 0x7FFFFFFF; 

  if (max == 0)
    8000183c:	c519                	beqz	a0,8000184a <random_number+0x14>
  {
    return 0; 
  }
  return (seed % max); 
    8000183e:	36dbc7b7          	lui	a5,0x36dbc
    80001842:	b707879b          	addiw	a5,a5,-1168
    80001846:	02a7e53b          	remw	a0,a5,a0
}
    8000184a:	6422                	ld	s0,8(sp)
    8000184c:	0141                	addi	sp,sp,16
    8000184e:	8082                	ret

0000000080001850 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001850:	7139                	addi	sp,sp,-64
    80001852:	fc06                	sd	ra,56(sp)
    80001854:	f822                	sd	s0,48(sp)
    80001856:	f426                	sd	s1,40(sp)
    80001858:	f04a                	sd	s2,32(sp)
    8000185a:	ec4e                	sd	s3,24(sp)
    8000185c:	e852                	sd	s4,16(sp)
    8000185e:	e456                	sd	s5,8(sp)
    80001860:	e05a                	sd	s6,0(sp)
    80001862:	0080                	addi	s0,sp,64
    80001864:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001866:	0000f497          	auipc	s1,0xf
    8000186a:	76a48493          	addi	s1,s1,1898 # 80010fd0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000186e:	8b26                	mv	s6,s1
    80001870:	00006a97          	auipc	s5,0x6
    80001874:	790a8a93          	addi	s5,s5,1936 # 80008000 <etext>
    80001878:	04000937          	lui	s2,0x4000
    8000187c:	197d                	addi	s2,s2,-1
    8000187e:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001880:	00019a17          	auipc	s4,0x19
    80001884:	750a0a13          	addi	s4,s4,1872 # 8001afd0 <tickslock>
    char *pa = kalloc();
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	25e080e7          	jalr	606(ra) # 80000ae6 <kalloc>
    80001890:	862a                	mv	a2,a0
    if (pa == 0)
    80001892:	c131                	beqz	a0,800018d6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001894:	416485b3          	sub	a1,s1,s6
    80001898:	859d                	srai	a1,a1,0x7
    8000189a:	000ab783          	ld	a5,0(s5)
    8000189e:	02f585b3          	mul	a1,a1,a5
    800018a2:	2585                	addiw	a1,a1,1
    800018a4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018a8:	4719                	li	a4,6
    800018aa:	6685                	lui	a3,0x1
    800018ac:	40b905b3          	sub	a1,s2,a1
    800018b0:	854e                	mv	a0,s3
    800018b2:	00000097          	auipc	ra,0x0
    800018b6:	88c080e7          	jalr	-1908(ra) # 8000113e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    800018ba:	28048493          	addi	s1,s1,640
    800018be:	fd4495e3          	bne	s1,s4,80001888 <proc_mapstacks+0x38>
  }
}
    800018c2:	70e2                	ld	ra,56(sp)
    800018c4:	7442                	ld	s0,48(sp)
    800018c6:	74a2                	ld	s1,40(sp)
    800018c8:	7902                	ld	s2,32(sp)
    800018ca:	69e2                	ld	s3,24(sp)
    800018cc:	6a42                	ld	s4,16(sp)
    800018ce:	6aa2                	ld	s5,8(sp)
    800018d0:	6b02                	ld	s6,0(sp)
    800018d2:	6121                	addi	sp,sp,64
    800018d4:	8082                	ret
      panic("kalloc");
    800018d6:	00007517          	auipc	a0,0x7
    800018da:	90250513          	addi	a0,a0,-1790 # 800081d8 <digits+0x198>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	c60080e7          	jalr	-928(ra) # 8000053e <panic>

00000000800018e6 <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018e6:	7139                	addi	sp,sp,-64
    800018e8:	fc06                	sd	ra,56(sp)
    800018ea:	f822                	sd	s0,48(sp)
    800018ec:	f426                	sd	s1,40(sp)
    800018ee:	f04a                	sd	s2,32(sp)
    800018f0:	ec4e                	sd	s3,24(sp)
    800018f2:	e852                	sd	s4,16(sp)
    800018f4:	e456                	sd	s5,8(sp)
    800018f6:	e05a                	sd	s6,0(sp)
    800018f8:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018fa:	00007597          	auipc	a1,0x7
    800018fe:	8e658593          	addi	a1,a1,-1818 # 800081e0 <digits+0x1a0>
    80001902:	0000f517          	auipc	a0,0xf
    80001906:	29e50513          	addi	a0,a0,670 # 80010ba0 <pid_lock>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	23c080e7          	jalr	572(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001912:	00007597          	auipc	a1,0x7
    80001916:	8d658593          	addi	a1,a1,-1834 # 800081e8 <digits+0x1a8>
    8000191a:	0000f517          	auipc	a0,0xf
    8000191e:	29e50513          	addi	a0,a0,670 # 80010bb8 <wait_lock>
    80001922:	fffff097          	auipc	ra,0xfffff
    80001926:	224080e7          	jalr	548(ra) # 80000b46 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000192a:	0000f497          	auipc	s1,0xf
    8000192e:	6a648493          	addi	s1,s1,1702 # 80010fd0 <proc>
  {
    initlock(&p->lock, "proc");
    80001932:	00007b17          	auipc	s6,0x7
    80001936:	8c6b0b13          	addi	s6,s6,-1850 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000193a:	8aa6                	mv	s5,s1
    8000193c:	00006a17          	auipc	s4,0x6
    80001940:	6c4a0a13          	addi	s4,s4,1732 # 80008000 <etext>
    80001944:	04000937          	lui	s2,0x4000
    80001948:	197d                	addi	s2,s2,-1
    8000194a:	0932                	slli	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    8000194c:	00019997          	auipc	s3,0x19
    80001950:	68498993          	addi	s3,s3,1668 # 8001afd0 <tickslock>
    initlock(&p->lock, "proc");
    80001954:	85da                	mv	a1,s6
    80001956:	8526                	mv	a0,s1
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	1ee080e7          	jalr	494(ra) # 80000b46 <initlock>
    p->state = UNUSED;
    80001960:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001964:	415487b3          	sub	a5,s1,s5
    80001968:	879d                	srai	a5,a5,0x7
    8000196a:	000a3703          	ld	a4,0(s4)
    8000196e:	02e787b3          	mul	a5,a5,a4
    80001972:	2785                	addiw	a5,a5,1
    80001974:	00d7979b          	slliw	a5,a5,0xd
    80001978:	40f907b3          	sub	a5,s2,a5
    8000197c:	14f4b423          	sd	a5,328(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    80001980:	28048493          	addi	s1,s1,640
    80001984:	fd3498e3          	bne	s1,s3,80001954 <procinit+0x6e>
    // p->tickets = 1;
    // p->arrival_time = 0;
  }
}
    80001988:	70e2                	ld	ra,56(sp)
    8000198a:	7442                	ld	s0,48(sp)
    8000198c:	74a2                	ld	s1,40(sp)
    8000198e:	7902                	ld	s2,32(sp)
    80001990:	69e2                	ld	s3,24(sp)
    80001992:	6a42                	ld	s4,16(sp)
    80001994:	6aa2                	ld	s5,8(sp)
    80001996:	6b02                	ld	s6,0(sp)
    80001998:	6121                	addi	sp,sp,64
    8000199a:	8082                	ret

000000008000199c <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    8000199c:	1141                	addi	sp,sp,-16
    8000199e:	e422                	sd	s0,8(sp)
    800019a0:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019a2:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019a4:	2501                	sext.w	a0,a0
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    800019ac:	1141                	addi	sp,sp,-16
    800019ae:	e422                	sd	s0,8(sp)
    800019b0:	0800                	addi	s0,sp,16
    800019b2:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019b4:	2781                	sext.w	a5,a5
    800019b6:	079e                	slli	a5,a5,0x7
  return c;
}
    800019b8:	0000f517          	auipc	a0,0xf
    800019bc:	21850513          	addi	a0,a0,536 # 80010bd0 <cpus>
    800019c0:	953e                	add	a0,a0,a5
    800019c2:	6422                	ld	s0,8(sp)
    800019c4:	0141                	addi	sp,sp,16
    800019c6:	8082                	ret

00000000800019c8 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019c8:	1101                	addi	sp,sp,-32
    800019ca:	ec06                	sd	ra,24(sp)
    800019cc:	e822                	sd	s0,16(sp)
    800019ce:	e426                	sd	s1,8(sp)
    800019d0:	1000                	addi	s0,sp,32
  push_off();
    800019d2:	fffff097          	auipc	ra,0xfffff
    800019d6:	1b8080e7          	jalr	440(ra) # 80000b8a <push_off>
    800019da:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019dc:	2781                	sext.w	a5,a5
    800019de:	079e                	slli	a5,a5,0x7
    800019e0:	0000f717          	auipc	a4,0xf
    800019e4:	1c070713          	addi	a4,a4,448 # 80010ba0 <pid_lock>
    800019e8:	97ba                	add	a5,a5,a4
    800019ea:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	23e080e7          	jalr	574(ra) # 80000c2a <pop_off>
  return p;
}
    800019f4:	8526                	mv	a0,s1
    800019f6:	60e2                	ld	ra,24(sp)
    800019f8:	6442                	ld	s0,16(sp)
    800019fa:	64a2                	ld	s1,8(sp)
    800019fc:	6105                	addi	sp,sp,32
    800019fe:	8082                	ret

0000000080001a00 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001a00:	1141                	addi	sp,sp,-16
    80001a02:	e406                	sd	ra,8(sp)
    80001a04:	e022                	sd	s0,0(sp)
    80001a06:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a08:	00000097          	auipc	ra,0x0
    80001a0c:	fc0080e7          	jalr	-64(ra) # 800019c8 <myproc>
    80001a10:	fffff097          	auipc	ra,0xfffff
    80001a14:	27a080e7          	jalr	634(ra) # 80000c8a <release>

  if (first)
    80001a18:	00007797          	auipc	a5,0x7
    80001a1c:	e987a783          	lw	a5,-360(a5) # 800088b0 <first.1>
    80001a20:	eb89                	bnez	a5,80001a32 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a22:	00001097          	auipc	ra,0x1
    80001a26:	f2e080e7          	jalr	-210(ra) # 80002950 <usertrapret>
}
    80001a2a:	60a2                	ld	ra,8(sp)
    80001a2c:	6402                	ld	s0,0(sp)
    80001a2e:	0141                	addi	sp,sp,16
    80001a30:	8082                	ret
    first = 0;
    80001a32:	00007797          	auipc	a5,0x7
    80001a36:	e607af23          	sw	zero,-386(a5) # 800088b0 <first.1>
    fsinit(ROOTDEV);
    80001a3a:	4505                	li	a0,1
    80001a3c:	00002097          	auipc	ra,0x2
    80001a40:	1f8080e7          	jalr	504(ra) # 80003c34 <fsinit>
    80001a44:	bff9                	j	80001a22 <forkret+0x22>

0000000080001a46 <allocpid>:
{
    80001a46:	1101                	addi	sp,sp,-32
    80001a48:	ec06                	sd	ra,24(sp)
    80001a4a:	e822                	sd	s0,16(sp)
    80001a4c:	e426                	sd	s1,8(sp)
    80001a4e:	e04a                	sd	s2,0(sp)
    80001a50:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a52:	0000f917          	auipc	s2,0xf
    80001a56:	14e90913          	addi	s2,s2,334 # 80010ba0 <pid_lock>
    80001a5a:	854a                	mv	a0,s2
    80001a5c:	fffff097          	auipc	ra,0xfffff
    80001a60:	17a080e7          	jalr	378(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a64:	00007797          	auipc	a5,0x7
    80001a68:	e5078793          	addi	a5,a5,-432 # 800088b4 <nextpid>
    80001a6c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a6e:	0014871b          	addiw	a4,s1,1
    80001a72:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a74:	854a                	mv	a0,s2
    80001a76:	fffff097          	auipc	ra,0xfffff
    80001a7a:	214080e7          	jalr	532(ra) # 80000c8a <release>
}
    80001a7e:	8526                	mv	a0,s1
    80001a80:	60e2                	ld	ra,24(sp)
    80001a82:	6442                	ld	s0,16(sp)
    80001a84:	64a2                	ld	s1,8(sp)
    80001a86:	6902                	ld	s2,0(sp)
    80001a88:	6105                	addi	sp,sp,32
    80001a8a:	8082                	ret

0000000080001a8c <proc_pagetable>:
{
    80001a8c:	1101                	addi	sp,sp,-32
    80001a8e:	ec06                	sd	ra,24(sp)
    80001a90:	e822                	sd	s0,16(sp)
    80001a92:	e426                	sd	s1,8(sp)
    80001a94:	e04a                	sd	s2,0(sp)
    80001a96:	1000                	addi	s0,sp,32
    80001a98:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a9a:	00000097          	auipc	ra,0x0
    80001a9e:	88e080e7          	jalr	-1906(ra) # 80001328 <uvmcreate>
    80001aa2:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001aa4:	c121                	beqz	a0,80001ae4 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aa6:	4729                	li	a4,10
    80001aa8:	00005697          	auipc	a3,0x5
    80001aac:	55868693          	addi	a3,a3,1368 # 80007000 <_trampoline>
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	040005b7          	lui	a1,0x4000
    80001ab6:	15fd                	addi	a1,a1,-1
    80001ab8:	05b2                	slli	a1,a1,0xc
    80001aba:	fffff097          	auipc	ra,0xfffff
    80001abe:	5e4080e7          	jalr	1508(ra) # 8000109e <mappages>
    80001ac2:	02054863          	bltz	a0,80001af2 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ac6:	4719                	li	a4,6
    80001ac8:	16093683          	ld	a3,352(s2)
    80001acc:	6605                	lui	a2,0x1
    80001ace:	020005b7          	lui	a1,0x2000
    80001ad2:	15fd                	addi	a1,a1,-1
    80001ad4:	05b6                	slli	a1,a1,0xd
    80001ad6:	8526                	mv	a0,s1
    80001ad8:	fffff097          	auipc	ra,0xfffff
    80001adc:	5c6080e7          	jalr	1478(ra) # 8000109e <mappages>
    80001ae0:	02054163          	bltz	a0,80001b02 <proc_pagetable+0x76>
}
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	60e2                	ld	ra,24(sp)
    80001ae8:	6442                	ld	s0,16(sp)
    80001aea:	64a2                	ld	s1,8(sp)
    80001aec:	6902                	ld	s2,0(sp)
    80001aee:	6105                	addi	sp,sp,32
    80001af0:	8082                	ret
    uvmfree(pagetable, 0);
    80001af2:	4581                	li	a1,0
    80001af4:	8526                	mv	a0,s1
    80001af6:	00000097          	auipc	ra,0x0
    80001afa:	a36080e7          	jalr	-1482(ra) # 8000152c <uvmfree>
    return 0;
    80001afe:	4481                	li	s1,0
    80001b00:	b7d5                	j	80001ae4 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b02:	4681                	li	a3,0
    80001b04:	4605                	li	a2,1
    80001b06:	040005b7          	lui	a1,0x4000
    80001b0a:	15fd                	addi	a1,a1,-1
    80001b0c:	05b2                	slli	a1,a1,0xc
    80001b0e:	8526                	mv	a0,s1
    80001b10:	fffff097          	auipc	ra,0xfffff
    80001b14:	754080e7          	jalr	1876(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b18:	4581                	li	a1,0
    80001b1a:	8526                	mv	a0,s1
    80001b1c:	00000097          	auipc	ra,0x0
    80001b20:	a10080e7          	jalr	-1520(ra) # 8000152c <uvmfree>
    return 0;
    80001b24:	4481                	li	s1,0
    80001b26:	bf7d                	j	80001ae4 <proc_pagetable+0x58>

0000000080001b28 <proc_freepagetable>:
{
    80001b28:	1101                	addi	sp,sp,-32
    80001b2a:	ec06                	sd	ra,24(sp)
    80001b2c:	e822                	sd	s0,16(sp)
    80001b2e:	e426                	sd	s1,8(sp)
    80001b30:	e04a                	sd	s2,0(sp)
    80001b32:	1000                	addi	s0,sp,32
    80001b34:	84aa                	mv	s1,a0
    80001b36:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b38:	4681                	li	a3,0
    80001b3a:	4605                	li	a2,1
    80001b3c:	040005b7          	lui	a1,0x4000
    80001b40:	15fd                	addi	a1,a1,-1
    80001b42:	05b2                	slli	a1,a1,0xc
    80001b44:	fffff097          	auipc	ra,0xfffff
    80001b48:	720080e7          	jalr	1824(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b4c:	4681                	li	a3,0
    80001b4e:	4605                	li	a2,1
    80001b50:	020005b7          	lui	a1,0x2000
    80001b54:	15fd                	addi	a1,a1,-1
    80001b56:	05b6                	slli	a1,a1,0xd
    80001b58:	8526                	mv	a0,s1
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	70a080e7          	jalr	1802(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b62:	85ca                	mv	a1,s2
    80001b64:	8526                	mv	a0,s1
    80001b66:	00000097          	auipc	ra,0x0
    80001b6a:	9c6080e7          	jalr	-1594(ra) # 8000152c <uvmfree>
}
    80001b6e:	60e2                	ld	ra,24(sp)
    80001b70:	6442                	ld	s0,16(sp)
    80001b72:	64a2                	ld	s1,8(sp)
    80001b74:	6902                	ld	s2,0(sp)
    80001b76:	6105                	addi	sp,sp,32
    80001b78:	8082                	ret

0000000080001b7a <freeproc>:
{
    80001b7a:	1101                	addi	sp,sp,-32
    80001b7c:	ec06                	sd	ra,24(sp)
    80001b7e:	e822                	sd	s0,16(sp)
    80001b80:	e426                	sd	s1,8(sp)
    80001b82:	1000                	addi	s0,sp,32
    80001b84:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b86:	16053503          	ld	a0,352(a0)
    80001b8a:	c509                	beqz	a0,80001b94 <freeproc+0x1a>
    kfree((void *)p->trapframe);
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	e5e080e7          	jalr	-418(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b94:	1604b023          	sd	zero,352(s1)
  if (p->pagetable)
    80001b98:	1584b503          	ld	a0,344(s1)
    80001b9c:	c519                	beqz	a0,80001baa <freeproc+0x30>
    proc_freepagetable(p->pagetable, p->sz);
    80001b9e:	1504b583          	ld	a1,336(s1)
    80001ba2:	00000097          	auipc	ra,0x0
    80001ba6:	f86080e7          	jalr	-122(ra) # 80001b28 <proc_freepagetable>
  p->pagetable = 0;
    80001baa:	1404bc23          	sd	zero,344(s1)
  p->sz = 0;
    80001bae:	1404b823          	sd	zero,336(s1)
  p->pid = 0;
    80001bb2:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bb6:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bba:	26048023          	sb	zero,608(s1)
  p->chan = 0;
    80001bbe:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bc2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bc6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bca:	0004ac23          	sw	zero,24(s1)
}
    80001bce:	60e2                	ld	ra,24(sp)
    80001bd0:	6442                	ld	s0,16(sp)
    80001bd2:	64a2                	ld	s1,8(sp)
    80001bd4:	6105                	addi	sp,sp,32
    80001bd6:	8082                	ret

0000000080001bd8 <allocproc>:
{
    80001bd8:	1101                	addi	sp,sp,-32
    80001bda:	ec06                	sd	ra,24(sp)
    80001bdc:	e822                	sd	s0,16(sp)
    80001bde:	e426                	sd	s1,8(sp)
    80001be0:	e04a                	sd	s2,0(sp)
    80001be2:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001be4:	0000f497          	auipc	s1,0xf
    80001be8:	3ec48493          	addi	s1,s1,1004 # 80010fd0 <proc>
    80001bec:	00019917          	auipc	s2,0x19
    80001bf0:	3e490913          	addi	s2,s2,996 # 8001afd0 <tickslock>
    acquire(&p->lock);
    80001bf4:	8526                	mv	a0,s1
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	fe0080e7          	jalr	-32(ra) # 80000bd6 <acquire>
    if (p->state == UNUSED)
    80001bfe:	4c9c                	lw	a5,24(s1)
    80001c00:	cf81                	beqz	a5,80001c18 <allocproc+0x40>
      release(&p->lock);
    80001c02:	8526                	mv	a0,s1
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	086080e7          	jalr	134(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001c0c:	28048493          	addi	s1,s1,640
    80001c10:	ff2492e3          	bne	s1,s2,80001bf4 <allocproc+0x1c>
  return 0;
    80001c14:	4481                	li	s1,0
    80001c16:	a231                	j	80001d22 <allocproc+0x14a>
  p->pid = allocpid();
    80001c18:	00000097          	auipc	ra,0x0
    80001c1c:	e2e080e7          	jalr	-466(ra) # 80001a46 <allocpid>
    80001c20:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c22:	4785                	li	a5,1
    80001c24:	cc9c                	sw	a5,24(s1)
  p->tickets = 1;
    80001c26:	12f4a423          	sw	a5,296(s1)
  p->arrival_time = 0;
    80001c2a:	1204a623          	sw	zero,300(s1)
  p->cur_ticks = 0;
    80001c2e:	0404a623          	sw	zero,76(s1)
  p->ticks = 0;
    80001c32:	0404a423          	sw	zero,72(s1)
  p->handler = 0;
    80001c36:	0404b023          	sd	zero,64(s1)
  p->alarm_tf = 0;
    80001c3a:	0404b823          	sd	zero,80(s1)
  p->alarm_on = 0;
    80001c3e:	0404ac23          	sw	zero,88(s1)
  p->pqno = 0;
    80001c42:	1204a823          	sw	zero,304(s1)
  p->iqno = 0;
    80001c46:	1404a023          	sw	zero,320(s1)
  p->cpu_ticks = 0;
    80001c4a:	1204ae23          	sw	zero,316(s1)
  p->waiting_time = 0;
    80001c4e:	1204ac23          	sw	zero,312(s1)
  p->start_time = ticks;
    80001c52:	00007797          	auipc	a5,0x7
    80001c56:	cde7a783          	lw	a5,-802(a5) # 80008930 <ticks>
    80001c5a:	12f4aa23          	sw	a5,308(s1)
  p->readcount = 0;
    80001c5e:	0404ae23          	sw	zero,92(s1)
  p->writecount = 0;
    80001c62:	0604a023          	sw	zero,96(s1)
  p->forkcount = 0;
    80001c66:	0604a223          	sw	zero,100(s1)
  p->exitcount = 0;
    80001c6a:	0604a423          	sw	zero,104(s1)
  p->waitcount = 0;
    80001c6e:	0604a623          	sw	zero,108(s1)
  p->sleepcount = 0;
    80001c72:	0604a823          	sw	zero,112(s1)
  p->uptimecount = 0;
    80001c76:	0604aa23          	sw	zero,116(s1)
  p->killcount = 0;
    80001c7a:	0604ac23          	sw	zero,120(s1)
  p->sigalarmcount = 0;
    80001c7e:	0604ae23          	sw	zero,124(s1)
  p->sigreturncount = 0;
    80001c82:	0804a023          	sw	zero,128(s1)
  p->chdircount = 0;
    80001c86:	0804a223          	sw	zero,132(s1)
  p->dupcount = 0;
    80001c8a:	0804a423          	sw	zero,136(s1)
  p->getpidcount = 0;
    80001c8e:	0804a623          	sw	zero,140(s1)
  p->sbrkcount = 0;
    80001c92:	0804a823          	sw	zero,144(s1)
  p->opencount = 0;
    80001c96:	0804aa23          	sw	zero,148(s1)
  p->mknodcount = 0;
    80001c9a:	0804ac23          	sw	zero,152(s1)
  p->unlinkcount = 0;
    80001c9e:	0804ae23          	sw	zero,156(s1)
  p->linkcount = 0;
    80001ca2:	0a04a023          	sw	zero,160(s1)
  p->mkdircount = 0;
    80001ca6:	0a04a223          	sw	zero,164(s1)
  p->closecount = 0;
    80001caa:	0a04a423          	sw	zero,168(s1)
  p->waitxcount = 0;
    80001cae:	0a04a623          	sw	zero,172(s1)
  p->getSysCountcount = 0;
    80001cb2:	0a04a823          	sw	zero,176(s1)
  p->pipecount = 0;
    80001cb6:	0a04aa23          	sw	zero,180(s1)
  p->execcount = 0;
    80001cba:	0a04ac23          	sw	zero,184(s1)
  p->fstatcount = 0;
    80001cbe:	0a04ae23          	sw	zero,188(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	e24080e7          	jalr	-476(ra) # 80000ae6 <kalloc>
    80001cca:	892a                	mv	s2,a0
    80001ccc:	16a4b023          	sd	a0,352(s1)
    80001cd0:	c125                	beqz	a0,80001d30 <allocproc+0x158>
  p->pagetable = proc_pagetable(p);
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	00000097          	auipc	ra,0x0
    80001cd8:	db8080e7          	jalr	-584(ra) # 80001a8c <proc_pagetable>
    80001cdc:	892a                	mv	s2,a0
    80001cde:	14a4bc23          	sd	a0,344(s1)
  if (p->pagetable == 0)
    80001ce2:	c13d                	beqz	a0,80001d48 <allocproc+0x170>
  memset(&p->context, 0, sizeof(p->context));
    80001ce4:	07000613          	li	a2,112
    80001ce8:	4581                	li	a1,0
    80001cea:	16848513          	addi	a0,s1,360
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	fe4080e7          	jalr	-28(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001cf6:	00000797          	auipc	a5,0x0
    80001cfa:	d0a78793          	addi	a5,a5,-758 # 80001a00 <forkret>
    80001cfe:	16f4b423          	sd	a5,360(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d02:	1484b783          	ld	a5,328(s1)
    80001d06:	6705                	lui	a4,0x1
    80001d08:	97ba                	add	a5,a5,a4
    80001d0a:	16f4b823          	sd	a5,368(s1)
  p->rtime = 0;
    80001d0e:	2604a823          	sw	zero,624(s1)
  p->etime = 0;
    80001d12:	2604ac23          	sw	zero,632(s1)
  p->ctime = ticks;
    80001d16:	00007797          	auipc	a5,0x7
    80001d1a:	c1a7a783          	lw	a5,-998(a5) # 80008930 <ticks>
    80001d1e:	26f4aa23          	sw	a5,628(s1)
}
    80001d22:	8526                	mv	a0,s1
    80001d24:	60e2                	ld	ra,24(sp)
    80001d26:	6442                	ld	s0,16(sp)
    80001d28:	64a2                	ld	s1,8(sp)
    80001d2a:	6902                	ld	s2,0(sp)
    80001d2c:	6105                	addi	sp,sp,32
    80001d2e:	8082                	ret
    freeproc(p);
    80001d30:	8526                	mv	a0,s1
    80001d32:	00000097          	auipc	ra,0x0
    80001d36:	e48080e7          	jalr	-440(ra) # 80001b7a <freeproc>
    release(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	f4e080e7          	jalr	-178(ra) # 80000c8a <release>
    return 0;
    80001d44:	84ca                	mv	s1,s2
    80001d46:	bff1                	j	80001d22 <allocproc+0x14a>
    freeproc(p);
    80001d48:	8526                	mv	a0,s1
    80001d4a:	00000097          	auipc	ra,0x0
    80001d4e:	e30080e7          	jalr	-464(ra) # 80001b7a <freeproc>
    release(&p->lock);
    80001d52:	8526                	mv	a0,s1
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	f36080e7          	jalr	-202(ra) # 80000c8a <release>
    return 0;
    80001d5c:	84ca                	mv	s1,s2
    80001d5e:	b7d1                	j	80001d22 <allocproc+0x14a>

0000000080001d60 <userinit>:
{
    80001d60:	1101                	addi	sp,sp,-32
    80001d62:	ec06                	sd	ra,24(sp)
    80001d64:	e822                	sd	s0,16(sp)
    80001d66:	e426                	sd	s1,8(sp)
    80001d68:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d6a:	00000097          	auipc	ra,0x0
    80001d6e:	e6e080e7          	jalr	-402(ra) # 80001bd8 <allocproc>
    80001d72:	84aa                	mv	s1,a0
  initproc = p;
    80001d74:	00007797          	auipc	a5,0x7
    80001d78:	baa7ba23          	sd	a0,-1100(a5) # 80008928 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d7c:	03400613          	li	a2,52
    80001d80:	00007597          	auipc	a1,0x7
    80001d84:	b4058593          	addi	a1,a1,-1216 # 800088c0 <initcode>
    80001d88:	15853503          	ld	a0,344(a0)
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	5ca080e7          	jalr	1482(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d94:	6785                	lui	a5,0x1
    80001d96:	14f4b823          	sd	a5,336(s1)
  p->trapframe->epc = 0;     // user program counter
    80001d9a:	1604b703          	ld	a4,352(s1)
    80001d9e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001da2:	1604b703          	ld	a4,352(s1)
    80001da6:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001da8:	4641                	li	a2,16
    80001daa:	00006597          	auipc	a1,0x6
    80001dae:	45658593          	addi	a1,a1,1110 # 80008200 <digits+0x1c0>
    80001db2:	26048513          	addi	a0,s1,608
    80001db6:	fffff097          	auipc	ra,0xfffff
    80001dba:	066080e7          	jalr	102(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001dbe:	00006517          	auipc	a0,0x6
    80001dc2:	45250513          	addi	a0,a0,1106 # 80008210 <digits+0x1d0>
    80001dc6:	00003097          	auipc	ra,0x3
    80001dca:	890080e7          	jalr	-1904(ra) # 80004656 <namei>
    80001dce:	24a4bc23          	sd	a0,600(s1)
  p->pqno = 0;
    80001dd2:	1204a823          	sw	zero,304(s1)
  p->cpu_ticks = 0;
    80001dd6:	1204ae23          	sw	zero,316(s1)
  p->start_time = ticks;
    80001dda:	00007797          	auipc	a5,0x7
    80001dde:	b567a783          	lw	a5,-1194(a5) # 80008930 <ticks>
    80001de2:	12f4aa23          	sw	a5,308(s1)
  p->state = RUNNABLE;
    80001de6:	478d                	li	a5,3
    80001de8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001dea:	8526                	mv	a0,s1
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	e9e080e7          	jalr	-354(ra) # 80000c8a <release>
}
    80001df4:	60e2                	ld	ra,24(sp)
    80001df6:	6442                	ld	s0,16(sp)
    80001df8:	64a2                	ld	s1,8(sp)
    80001dfa:	6105                	addi	sp,sp,32
    80001dfc:	8082                	ret

0000000080001dfe <growproc>:
{
    80001dfe:	1101                	addi	sp,sp,-32
    80001e00:	ec06                	sd	ra,24(sp)
    80001e02:	e822                	sd	s0,16(sp)
    80001e04:	e426                	sd	s1,8(sp)
    80001e06:	e04a                	sd	s2,0(sp)
    80001e08:	1000                	addi	s0,sp,32
    80001e0a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	bbc080e7          	jalr	-1092(ra) # 800019c8 <myproc>
    80001e14:	84aa                	mv	s1,a0
  sz = p->sz;
    80001e16:	15053583          	ld	a1,336(a0)
  if (n > 0)
    80001e1a:	01204d63          	bgtz	s2,80001e34 <growproc+0x36>
  else if (n < 0)
    80001e1e:	02094863          	bltz	s2,80001e4e <growproc+0x50>
  p->sz = sz;
    80001e22:	14b4b823          	sd	a1,336(s1)
  return 0;
    80001e26:	4501                	li	a0,0
}
    80001e28:	60e2                	ld	ra,24(sp)
    80001e2a:	6442                	ld	s0,16(sp)
    80001e2c:	64a2                	ld	s1,8(sp)
    80001e2e:	6902                	ld	s2,0(sp)
    80001e30:	6105                	addi	sp,sp,32
    80001e32:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001e34:	4691                	li	a3,4
    80001e36:	00b90633          	add	a2,s2,a1
    80001e3a:	15853503          	ld	a0,344(a0)
    80001e3e:	fffff097          	auipc	ra,0xfffff
    80001e42:	5d2080e7          	jalr	1490(ra) # 80001410 <uvmalloc>
    80001e46:	85aa                	mv	a1,a0
    80001e48:	fd69                	bnez	a0,80001e22 <growproc+0x24>
      return -1;
    80001e4a:	557d                	li	a0,-1
    80001e4c:	bff1                	j	80001e28 <growproc+0x2a>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e4e:	00b90633          	add	a2,s2,a1
    80001e52:	15853503          	ld	a0,344(a0)
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	572080e7          	jalr	1394(ra) # 800013c8 <uvmdealloc>
    80001e5e:	85aa                	mv	a1,a0
    80001e60:	b7c9                	j	80001e22 <growproc+0x24>

0000000080001e62 <fork>:
{
    80001e62:	7139                	addi	sp,sp,-64
    80001e64:	fc06                	sd	ra,56(sp)
    80001e66:	f822                	sd	s0,48(sp)
    80001e68:	f426                	sd	s1,40(sp)
    80001e6a:	f04a                	sd	s2,32(sp)
    80001e6c:	ec4e                	sd	s3,24(sp)
    80001e6e:	e852                	sd	s4,16(sp)
    80001e70:	e456                	sd	s5,8(sp)
    80001e72:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e74:	00000097          	auipc	ra,0x0
    80001e78:	b54080e7          	jalr	-1196(ra) # 800019c8 <myproc>
    80001e7c:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001e7e:	00000097          	auipc	ra,0x0
    80001e82:	d5a080e7          	jalr	-678(ra) # 80001bd8 <allocproc>
    80001e86:	12050763          	beqz	a0,80001fb4 <fork+0x152>
    80001e8a:	89aa                	mv	s3,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001e8c:	150ab603          	ld	a2,336(s5)
    80001e90:	15853583          	ld	a1,344(a0)
    80001e94:	158ab503          	ld	a0,344(s5)
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	6cc080e7          	jalr	1740(ra) # 80001564 <uvmcopy>
    80001ea0:	04054863          	bltz	a0,80001ef0 <fork+0x8e>
  np->sz = p->sz;
    80001ea4:	150ab783          	ld	a5,336(s5)
    80001ea8:	14f9b823          	sd	a5,336(s3)
  *(np->trapframe) = *(p->trapframe);
    80001eac:	160ab683          	ld	a3,352(s5)
    80001eb0:	87b6                	mv	a5,a3
    80001eb2:	1609b703          	ld	a4,352(s3)
    80001eb6:	12068693          	addi	a3,a3,288
    80001eba:	0007b803          	ld	a6,0(a5)
    80001ebe:	6788                	ld	a0,8(a5)
    80001ec0:	6b8c                	ld	a1,16(a5)
    80001ec2:	6f90                	ld	a2,24(a5)
    80001ec4:	01073023          	sd	a6,0(a4)
    80001ec8:	e708                	sd	a0,8(a4)
    80001eca:	eb0c                	sd	a1,16(a4)
    80001ecc:	ef10                	sd	a2,24(a4)
    80001ece:	02078793          	addi	a5,a5,32
    80001ed2:	02070713          	addi	a4,a4,32
    80001ed6:	fed792e3          	bne	a5,a3,80001eba <fork+0x58>
  np->trapframe->a0 = 0;
    80001eda:	1609b783          	ld	a5,352(s3)
    80001ede:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001ee2:	1d8a8493          	addi	s1,s5,472
    80001ee6:	1d898913          	addi	s2,s3,472
    80001eea:	258a8a13          	addi	s4,s5,600
    80001eee:	a00d                	j	80001f10 <fork+0xae>
    freeproc(np);
    80001ef0:	854e                	mv	a0,s3
    80001ef2:	00000097          	auipc	ra,0x0
    80001ef6:	c88080e7          	jalr	-888(ra) # 80001b7a <freeproc>
    release(&np->lock);
    80001efa:	854e                	mv	a0,s3
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	d8e080e7          	jalr	-626(ra) # 80000c8a <release>
    return -1;
    80001f04:	597d                	li	s2,-1
    80001f06:	a869                	j	80001fa0 <fork+0x13e>
  for (i = 0; i < NOFILE; i++)
    80001f08:	04a1                	addi	s1,s1,8
    80001f0a:	0921                	addi	s2,s2,8
    80001f0c:	01448b63          	beq	s1,s4,80001f22 <fork+0xc0>
    if (p->ofile[i])
    80001f10:	6088                	ld	a0,0(s1)
    80001f12:	d97d                	beqz	a0,80001f08 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f14:	00003097          	auipc	ra,0x3
    80001f18:	dd8080e7          	jalr	-552(ra) # 80004cec <filedup>
    80001f1c:	00a93023          	sd	a0,0(s2)
    80001f20:	b7e5                	j	80001f08 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001f22:	258ab503          	ld	a0,600(s5)
    80001f26:	00002097          	auipc	ra,0x2
    80001f2a:	f4c080e7          	jalr	-180(ra) # 80003e72 <idup>
    80001f2e:	24a9bc23          	sd	a0,600(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f32:	4641                	li	a2,16
    80001f34:	260a8593          	addi	a1,s5,608
    80001f38:	26098513          	addi	a0,s3,608
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	ee0080e7          	jalr	-288(ra) # 80000e1c <safestrcpy>
  np->tickets = p->tickets;
    80001f44:	128aa783          	lw	a5,296(s5)
    80001f48:	12f9a423          	sw	a5,296(s3)
  np->arrival_time = ticks;
    80001f4c:	00007797          	auipc	a5,0x7
    80001f50:	9e47a783          	lw	a5,-1564(a5) # 80008930 <ticks>
    80001f54:	12f9a623          	sw	a5,300(s3)
  pid = np->pid;
    80001f58:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f5c:	854e                	mv	a0,s3
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	d2c080e7          	jalr	-724(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001f66:	0000f497          	auipc	s1,0xf
    80001f6a:	c5248493          	addi	s1,s1,-942 # 80010bb8 <wait_lock>
    80001f6e:	8526                	mv	a0,s1
    80001f70:	fffff097          	auipc	ra,0xfffff
    80001f74:	c66080e7          	jalr	-922(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001f78:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	d0c080e7          	jalr	-756(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001f86:	854e                	mv	a0,s3
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	c4e080e7          	jalr	-946(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001f90:	478d                	li	a5,3
    80001f92:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f96:	854e                	mv	a0,s3
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	cf2080e7          	jalr	-782(ra) # 80000c8a <release>
}
    80001fa0:	854a                	mv	a0,s2
    80001fa2:	70e2                	ld	ra,56(sp)
    80001fa4:	7442                	ld	s0,48(sp)
    80001fa6:	74a2                	ld	s1,40(sp)
    80001fa8:	7902                	ld	s2,32(sp)
    80001faa:	69e2                	ld	s3,24(sp)
    80001fac:	6a42                	ld	s4,16(sp)
    80001fae:	6aa2                	ld	s5,8(sp)
    80001fb0:	6121                	addi	sp,sp,64
    80001fb2:	8082                	ret
    return -1;
    80001fb4:	597d                	li	s2,-1
    80001fb6:	b7ed                	j	80001fa0 <fork+0x13e>

0000000080001fb8 <scheduler>:
{
    80001fb8:	7139                	addi	sp,sp,-64
    80001fba:	fc06                	sd	ra,56(sp)
    80001fbc:	f822                	sd	s0,48(sp)
    80001fbe:	f426                	sd	s1,40(sp)
    80001fc0:	f04a                	sd	s2,32(sp)
    80001fc2:	ec4e                	sd	s3,24(sp)
    80001fc4:	e852                	sd	s4,16(sp)
    80001fc6:	e456                	sd	s5,8(sp)
    80001fc8:	e05a                	sd	s6,0(sp)
    80001fca:	0080                	addi	s0,sp,64
    80001fcc:	8792                	mv	a5,tp
  int id = r_tp();
    80001fce:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fd0:	00779a93          	slli	s5,a5,0x7
    80001fd4:	0000f717          	auipc	a4,0xf
    80001fd8:	bcc70713          	addi	a4,a4,-1076 # 80010ba0 <pid_lock>
    80001fdc:	9756                	add	a4,a4,s5
    80001fde:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fe2:	0000f717          	auipc	a4,0xf
    80001fe6:	bf670713          	addi	a4,a4,-1034 # 80010bd8 <cpus+0x8>
    80001fea:	9aba                	add	s5,s5,a4
      if (p->state == RUNNABLE)
    80001fec:	498d                	li	s3,3
        p->state = RUNNING;
    80001fee:	4b11                	li	s6,4
        c->proc = p;
    80001ff0:	079e                	slli	a5,a5,0x7
    80001ff2:	0000fa17          	auipc	s4,0xf
    80001ff6:	baea0a13          	addi	s4,s4,-1106 # 80010ba0 <pid_lock>
    80001ffa:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001ffc:	00019917          	auipc	s2,0x19
    80002000:	fd490913          	addi	s2,s2,-44 # 8001afd0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002004:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002008:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000200c:	10079073          	csrw	sstatus,a5
    80002010:	0000f497          	auipc	s1,0xf
    80002014:	fc048493          	addi	s1,s1,-64 # 80010fd0 <proc>
    80002018:	a811                	j	8000202c <scheduler+0x74>
      release(&p->lock);
    8000201a:	8526                	mv	a0,s1
    8000201c:	fffff097          	auipc	ra,0xfffff
    80002020:	c6e080e7          	jalr	-914(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002024:	28048493          	addi	s1,s1,640
    80002028:	fd248ee3          	beq	s1,s2,80002004 <scheduler+0x4c>
      acquire(&p->lock);
    8000202c:	8526                	mv	a0,s1
    8000202e:	fffff097          	auipc	ra,0xfffff
    80002032:	ba8080e7          	jalr	-1112(ra) # 80000bd6 <acquire>
      if (p->state == RUNNABLE)
    80002036:	4c9c                	lw	a5,24(s1)
    80002038:	ff3791e3          	bne	a5,s3,8000201a <scheduler+0x62>
        p->state = RUNNING;
    8000203c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002040:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80002044:	16848593          	addi	a1,s1,360
    80002048:	8556                	mv	a0,s5
    8000204a:	00001097          	auipc	ra,0x1
    8000204e:	85c080e7          	jalr	-1956(ra) # 800028a6 <swtch>
        c->proc = 0;
    80002052:	020a3823          	sd	zero,48(s4)
    80002056:	b7d1                	j	8000201a <scheduler+0x62>

0000000080002058 <sched>:
{
    80002058:	7179                	addi	sp,sp,-48
    8000205a:	f406                	sd	ra,40(sp)
    8000205c:	f022                	sd	s0,32(sp)
    8000205e:	ec26                	sd	s1,24(sp)
    80002060:	e84a                	sd	s2,16(sp)
    80002062:	e44e                	sd	s3,8(sp)
    80002064:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002066:	00000097          	auipc	ra,0x0
    8000206a:	962080e7          	jalr	-1694(ra) # 800019c8 <myproc>
    8000206e:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	aec080e7          	jalr	-1300(ra) # 80000b5c <holding>
    80002078:	c93d                	beqz	a0,800020ee <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000207a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000207c:	2781                	sext.w	a5,a5
    8000207e:	079e                	slli	a5,a5,0x7
    80002080:	0000f717          	auipc	a4,0xf
    80002084:	b2070713          	addi	a4,a4,-1248 # 80010ba0 <pid_lock>
    80002088:	97ba                	add	a5,a5,a4
    8000208a:	0a87a703          	lw	a4,168(a5)
    8000208e:	4785                	li	a5,1
    80002090:	06f71763          	bne	a4,a5,800020fe <sched+0xa6>
  if (p->state == RUNNING)
    80002094:	4c98                	lw	a4,24(s1)
    80002096:	4791                	li	a5,4
    80002098:	06f70b63          	beq	a4,a5,8000210e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000209c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020a0:	8b89                	andi	a5,a5,2
  if (intr_get())
    800020a2:	efb5                	bnez	a5,8000211e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020a4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020a6:	0000f917          	auipc	s2,0xf
    800020aa:	afa90913          	addi	s2,s2,-1286 # 80010ba0 <pid_lock>
    800020ae:	2781                	sext.w	a5,a5
    800020b0:	079e                	slli	a5,a5,0x7
    800020b2:	97ca                	add	a5,a5,s2
    800020b4:	0ac7a983          	lw	s3,172(a5)
    800020b8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020ba:	2781                	sext.w	a5,a5
    800020bc:	079e                	slli	a5,a5,0x7
    800020be:	0000f597          	auipc	a1,0xf
    800020c2:	b1a58593          	addi	a1,a1,-1254 # 80010bd8 <cpus+0x8>
    800020c6:	95be                	add	a1,a1,a5
    800020c8:	16848513          	addi	a0,s1,360
    800020cc:	00000097          	auipc	ra,0x0
    800020d0:	7da080e7          	jalr	2010(ra) # 800028a6 <swtch>
    800020d4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020d6:	2781                	sext.w	a5,a5
    800020d8:	079e                	slli	a5,a5,0x7
    800020da:	97ca                	add	a5,a5,s2
    800020dc:	0b37a623          	sw	s3,172(a5)
}
    800020e0:	70a2                	ld	ra,40(sp)
    800020e2:	7402                	ld	s0,32(sp)
    800020e4:	64e2                	ld	s1,24(sp)
    800020e6:	6942                	ld	s2,16(sp)
    800020e8:	69a2                	ld	s3,8(sp)
    800020ea:	6145                	addi	sp,sp,48
    800020ec:	8082                	ret
    panic("sched p->lock");
    800020ee:	00006517          	auipc	a0,0x6
    800020f2:	12a50513          	addi	a0,a0,298 # 80008218 <digits+0x1d8>
    800020f6:	ffffe097          	auipc	ra,0xffffe
    800020fa:	448080e7          	jalr	1096(ra) # 8000053e <panic>
    panic("sched locks");
    800020fe:	00006517          	auipc	a0,0x6
    80002102:	12a50513          	addi	a0,a0,298 # 80008228 <digits+0x1e8>
    80002106:	ffffe097          	auipc	ra,0xffffe
    8000210a:	438080e7          	jalr	1080(ra) # 8000053e <panic>
    panic("sched running");
    8000210e:	00006517          	auipc	a0,0x6
    80002112:	12a50513          	addi	a0,a0,298 # 80008238 <digits+0x1f8>
    80002116:	ffffe097          	auipc	ra,0xffffe
    8000211a:	428080e7          	jalr	1064(ra) # 8000053e <panic>
    panic("sched interruptible");
    8000211e:	00006517          	auipc	a0,0x6
    80002122:	12a50513          	addi	a0,a0,298 # 80008248 <digits+0x208>
    80002126:	ffffe097          	auipc	ra,0xffffe
    8000212a:	418080e7          	jalr	1048(ra) # 8000053e <panic>

000000008000212e <yield>:
{
    8000212e:	1101                	addi	sp,sp,-32
    80002130:	ec06                	sd	ra,24(sp)
    80002132:	e822                	sd	s0,16(sp)
    80002134:	e426                	sd	s1,8(sp)
    80002136:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002138:	00000097          	auipc	ra,0x0
    8000213c:	890080e7          	jalr	-1904(ra) # 800019c8 <myproc>
    80002140:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	a94080e7          	jalr	-1388(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    8000214a:	478d                	li	a5,3
    8000214c:	cc9c                	sw	a5,24(s1)
  sched();
    8000214e:	00000097          	auipc	ra,0x0
    80002152:	f0a080e7          	jalr	-246(ra) # 80002058 <sched>
  release(&p->lock);
    80002156:	8526                	mv	a0,s1
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	b32080e7          	jalr	-1230(ra) # 80000c8a <release>
}
    80002160:	60e2                	ld	ra,24(sp)
    80002162:	6442                	ld	s0,16(sp)
    80002164:	64a2                	ld	s1,8(sp)
    80002166:	6105                	addi	sp,sp,32
    80002168:	8082                	ret

000000008000216a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000216a:	7179                	addi	sp,sp,-48
    8000216c:	f406                	sd	ra,40(sp)
    8000216e:	f022                	sd	s0,32(sp)
    80002170:	ec26                	sd	s1,24(sp)
    80002172:	e84a                	sd	s2,16(sp)
    80002174:	e44e                	sd	s3,8(sp)
    80002176:	1800                	addi	s0,sp,48
    80002178:	89aa                	mv	s3,a0
    8000217a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000217c:	00000097          	auipc	ra,0x0
    80002180:	84c080e7          	jalr	-1972(ra) # 800019c8 <myproc>
    80002184:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	a50080e7          	jalr	-1456(ra) # 80000bd6 <acquire>
  release(lk);
    8000218e:	854a                	mv	a0,s2
    80002190:	fffff097          	auipc	ra,0xfffff
    80002194:	afa080e7          	jalr	-1286(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002198:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000219c:	4789                	li	a5,2
    8000219e:	cc9c                	sw	a5,24(s1)

  sched();
    800021a0:	00000097          	auipc	ra,0x0
    800021a4:	eb8080e7          	jalr	-328(ra) # 80002058 <sched>

  // Tidy up.
  p->chan = 0;
    800021a8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021ac:	8526                	mv	a0,s1
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	adc080e7          	jalr	-1316(ra) # 80000c8a <release>
  acquire(lk);
    800021b6:	854a                	mv	a0,s2
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	a1e080e7          	jalr	-1506(ra) # 80000bd6 <acquire>
}
    800021c0:	70a2                	ld	ra,40(sp)
    800021c2:	7402                	ld	s0,32(sp)
    800021c4:	64e2                	ld	s1,24(sp)
    800021c6:	6942                	ld	s2,16(sp)
    800021c8:	69a2                	ld	s3,8(sp)
    800021ca:	6145                	addi	sp,sp,48
    800021cc:	8082                	ret

00000000800021ce <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    800021ce:	7139                	addi	sp,sp,-64
    800021d0:	fc06                	sd	ra,56(sp)
    800021d2:	f822                	sd	s0,48(sp)
    800021d4:	f426                	sd	s1,40(sp)
    800021d6:	f04a                	sd	s2,32(sp)
    800021d8:	ec4e                	sd	s3,24(sp)
    800021da:	e852                	sd	s4,16(sp)
    800021dc:	e456                	sd	s5,8(sp)
    800021de:	0080                	addi	s0,sp,64
    800021e0:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    800021e2:	0000f497          	auipc	s1,0xf
    800021e6:	dee48493          	addi	s1,s1,-530 # 80010fd0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    800021ea:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    800021ec:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    800021ee:	00019917          	auipc	s2,0x19
    800021f2:	de290913          	addi	s2,s2,-542 # 8001afd0 <tickslock>
    800021f6:	a811                	j	8000220a <wakeup+0x3c>
      }
      release(&p->lock);
    800021f8:	8526                	mv	a0,s1
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	a90080e7          	jalr	-1392(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002202:	28048493          	addi	s1,s1,640
    80002206:	03248663          	beq	s1,s2,80002232 <wakeup+0x64>
    if (p != myproc())
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	7be080e7          	jalr	1982(ra) # 800019c8 <myproc>
    80002212:	fea488e3          	beq	s1,a0,80002202 <wakeup+0x34>
      acquire(&p->lock);
    80002216:	8526                	mv	a0,s1
    80002218:	fffff097          	auipc	ra,0xfffff
    8000221c:	9be080e7          	jalr	-1602(ra) # 80000bd6 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    80002220:	4c9c                	lw	a5,24(s1)
    80002222:	fd379be3          	bne	a5,s3,800021f8 <wakeup+0x2a>
    80002226:	709c                	ld	a5,32(s1)
    80002228:	fd4798e3          	bne	a5,s4,800021f8 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000222c:	0154ac23          	sw	s5,24(s1)
    80002230:	b7e1                	j	800021f8 <wakeup+0x2a>
    }
  }
}
    80002232:	70e2                	ld	ra,56(sp)
    80002234:	7442                	ld	s0,48(sp)
    80002236:	74a2                	ld	s1,40(sp)
    80002238:	7902                	ld	s2,32(sp)
    8000223a:	69e2                	ld	s3,24(sp)
    8000223c:	6a42                	ld	s4,16(sp)
    8000223e:	6aa2                	ld	s5,8(sp)
    80002240:	6121                	addi	sp,sp,64
    80002242:	8082                	ret

0000000080002244 <reparent>:
{
    80002244:	7179                	addi	sp,sp,-48
    80002246:	f406                	sd	ra,40(sp)
    80002248:	f022                	sd	s0,32(sp)
    8000224a:	ec26                	sd	s1,24(sp)
    8000224c:	e84a                	sd	s2,16(sp)
    8000224e:	e44e                	sd	s3,8(sp)
    80002250:	e052                	sd	s4,0(sp)
    80002252:	1800                	addi	s0,sp,48
    80002254:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002256:	0000f497          	auipc	s1,0xf
    8000225a:	d7a48493          	addi	s1,s1,-646 # 80010fd0 <proc>
      pp->parent = initproc;
    8000225e:	00006a17          	auipc	s4,0x6
    80002262:	6caa0a13          	addi	s4,s4,1738 # 80008928 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    80002266:	00019997          	auipc	s3,0x19
    8000226a:	d6a98993          	addi	s3,s3,-662 # 8001afd0 <tickslock>
    8000226e:	a029                	j	80002278 <reparent+0x34>
    80002270:	28048493          	addi	s1,s1,640
    80002274:	01348d63          	beq	s1,s3,8000228e <reparent+0x4a>
    if (pp->parent == p)
    80002278:	7c9c                	ld	a5,56(s1)
    8000227a:	ff279be3          	bne	a5,s2,80002270 <reparent+0x2c>
      pp->parent = initproc;
    8000227e:	000a3503          	ld	a0,0(s4)
    80002282:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002284:	00000097          	auipc	ra,0x0
    80002288:	f4a080e7          	jalr	-182(ra) # 800021ce <wakeup>
    8000228c:	b7d5                	j	80002270 <reparent+0x2c>
}
    8000228e:	70a2                	ld	ra,40(sp)
    80002290:	7402                	ld	s0,32(sp)
    80002292:	64e2                	ld	s1,24(sp)
    80002294:	6942                	ld	s2,16(sp)
    80002296:	69a2                	ld	s3,8(sp)
    80002298:	6a02                	ld	s4,0(sp)
    8000229a:	6145                	addi	sp,sp,48
    8000229c:	8082                	ret

000000008000229e <exit>:
{
    8000229e:	7179                	addi	sp,sp,-48
    800022a0:	f406                	sd	ra,40(sp)
    800022a2:	f022                	sd	s0,32(sp)
    800022a4:	ec26                	sd	s1,24(sp)
    800022a6:	e84a                	sd	s2,16(sp)
    800022a8:	e44e                	sd	s3,8(sp)
    800022aa:	e052                	sd	s4,0(sp)
    800022ac:	1800                	addi	s0,sp,48
    800022ae:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	718080e7          	jalr	1816(ra) # 800019c8 <myproc>
    800022b8:	89aa                	mv	s3,a0
  if (p == initproc)
    800022ba:	00006797          	auipc	a5,0x6
    800022be:	66e7b783          	ld	a5,1646(a5) # 80008928 <initproc>
    800022c2:	1d850493          	addi	s1,a0,472
    800022c6:	25850913          	addi	s2,a0,600
    800022ca:	02a79363          	bne	a5,a0,800022f0 <exit+0x52>
    panic("init exiting");
    800022ce:	00006517          	auipc	a0,0x6
    800022d2:	f9250513          	addi	a0,a0,-110 # 80008260 <digits+0x220>
    800022d6:	ffffe097          	auipc	ra,0xffffe
    800022da:	268080e7          	jalr	616(ra) # 8000053e <panic>
      fileclose(f);
    800022de:	00003097          	auipc	ra,0x3
    800022e2:	a60080e7          	jalr	-1440(ra) # 80004d3e <fileclose>
      p->ofile[fd] = 0;
    800022e6:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    800022ea:	04a1                	addi	s1,s1,8
    800022ec:	01248563          	beq	s1,s2,800022f6 <exit+0x58>
    if (p->ofile[fd])
    800022f0:	6088                	ld	a0,0(s1)
    800022f2:	f575                	bnez	a0,800022de <exit+0x40>
    800022f4:	bfdd                	j	800022ea <exit+0x4c>
  begin_op();
    800022f6:	00002097          	auipc	ra,0x2
    800022fa:	57c080e7          	jalr	1404(ra) # 80004872 <begin_op>
  iput(p->cwd);
    800022fe:	2589b503          	ld	a0,600(s3)
    80002302:	00002097          	auipc	ra,0x2
    80002306:	d68080e7          	jalr	-664(ra) # 8000406a <iput>
  end_op();
    8000230a:	00002097          	auipc	ra,0x2
    8000230e:	5e8080e7          	jalr	1512(ra) # 800048f2 <end_op>
  p->cwd = 0;
    80002312:	2409bc23          	sd	zero,600(s3)
  acquire(&wait_lock);
    80002316:	0000f497          	auipc	s1,0xf
    8000231a:	8a248493          	addi	s1,s1,-1886 # 80010bb8 <wait_lock>
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	8b6080e7          	jalr	-1866(ra) # 80000bd6 <acquire>
  reparent(p);
    80002328:	854e                	mv	a0,s3
    8000232a:	00000097          	auipc	ra,0x0
    8000232e:	f1a080e7          	jalr	-230(ra) # 80002244 <reparent>
  wakeup(p->parent);
    80002332:	0389b503          	ld	a0,56(s3)
    80002336:	00000097          	auipc	ra,0x0
    8000233a:	e98080e7          	jalr	-360(ra) # 800021ce <wakeup>
  acquire(&p->lock);
    8000233e:	854e                	mv	a0,s3
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	896080e7          	jalr	-1898(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002348:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000234c:	4795                	li	a5,5
    8000234e:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    80002352:	00006797          	auipc	a5,0x6
    80002356:	5de7a783          	lw	a5,1502(a5) # 80008930 <ticks>
    8000235a:	26f9ac23          	sw	a5,632(s3)
  release(&wait_lock);
    8000235e:	8526                	mv	a0,s1
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
  sched();
    80002368:	00000097          	auipc	ra,0x0
    8000236c:	cf0080e7          	jalr	-784(ra) # 80002058 <sched>
  panic("zombie exit");
    80002370:	00006517          	auipc	a0,0x6
    80002374:	f0050513          	addi	a0,a0,-256 # 80008270 <digits+0x230>
    80002378:	ffffe097          	auipc	ra,0xffffe
    8000237c:	1c6080e7          	jalr	454(ra) # 8000053e <panic>

0000000080002380 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002380:	7179                	addi	sp,sp,-48
    80002382:	f406                	sd	ra,40(sp)
    80002384:	f022                	sd	s0,32(sp)
    80002386:	ec26                	sd	s1,24(sp)
    80002388:	e84a                	sd	s2,16(sp)
    8000238a:	e44e                	sd	s3,8(sp)
    8000238c:	1800                	addi	s0,sp,48
    8000238e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80002390:	0000f497          	auipc	s1,0xf
    80002394:	c4048493          	addi	s1,s1,-960 # 80010fd0 <proc>
    80002398:	00019997          	auipc	s3,0x19
    8000239c:	c3898993          	addi	s3,s3,-968 # 8001afd0 <tickslock>
  {
    acquire(&p->lock);
    800023a0:	8526                	mv	a0,s1
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	834080e7          	jalr	-1996(ra) # 80000bd6 <acquire>
    if (p->pid == pid)
    800023aa:	589c                	lw	a5,48(s1)
    800023ac:	01278d63          	beq	a5,s2,800023c6 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023b0:	8526                	mv	a0,s1
    800023b2:	fffff097          	auipc	ra,0xfffff
    800023b6:	8d8080e7          	jalr	-1832(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800023ba:	28048493          	addi	s1,s1,640
    800023be:	ff3491e3          	bne	s1,s3,800023a0 <kill+0x20>
  }
  return -1;
    800023c2:	557d                	li	a0,-1
    800023c4:	a829                	j	800023de <kill+0x5e>
      p->killed = 1;
    800023c6:	4785                	li	a5,1
    800023c8:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    800023ca:	4c98                	lw	a4,24(s1)
    800023cc:	4789                	li	a5,2
    800023ce:	00f70f63          	beq	a4,a5,800023ec <kill+0x6c>
      release(&p->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	8b6080e7          	jalr	-1866(ra) # 80000c8a <release>
      return 0;
    800023dc:	4501                	li	a0,0
}
    800023de:	70a2                	ld	ra,40(sp)
    800023e0:	7402                	ld	s0,32(sp)
    800023e2:	64e2                	ld	s1,24(sp)
    800023e4:	6942                	ld	s2,16(sp)
    800023e6:	69a2                	ld	s3,8(sp)
    800023e8:	6145                	addi	sp,sp,48
    800023ea:	8082                	ret
        p->state = RUNNABLE;
    800023ec:	478d                	li	a5,3
    800023ee:	cc9c                	sw	a5,24(s1)
    800023f0:	b7cd                	j	800023d2 <kill+0x52>

00000000800023f2 <setkilled>:

void setkilled(struct proc *p)
{
    800023f2:	1101                	addi	sp,sp,-32
    800023f4:	ec06                	sd	ra,24(sp)
    800023f6:	e822                	sd	s0,16(sp)
    800023f8:	e426                	sd	s1,8(sp)
    800023fa:	1000                	addi	s0,sp,32
    800023fc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023fe:	ffffe097          	auipc	ra,0xffffe
    80002402:	7d8080e7          	jalr	2008(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002406:	4785                	li	a5,1
    80002408:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000240a:	8526                	mv	a0,s1
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	87e080e7          	jalr	-1922(ra) # 80000c8a <release>
}
    80002414:	60e2                	ld	ra,24(sp)
    80002416:	6442                	ld	s0,16(sp)
    80002418:	64a2                	ld	s1,8(sp)
    8000241a:	6105                	addi	sp,sp,32
    8000241c:	8082                	ret

000000008000241e <killed>:

int killed(struct proc *p)
{
    8000241e:	1101                	addi	sp,sp,-32
    80002420:	ec06                	sd	ra,24(sp)
    80002422:	e822                	sd	s0,16(sp)
    80002424:	e426                	sd	s1,8(sp)
    80002426:	e04a                	sd	s2,0(sp)
    80002428:	1000                	addi	s0,sp,32
    8000242a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000242c:	ffffe097          	auipc	ra,0xffffe
    80002430:	7aa080e7          	jalr	1962(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002434:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002438:	8526                	mv	a0,s1
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	850080e7          	jalr	-1968(ra) # 80000c8a <release>
  return k;
}
    80002442:	854a                	mv	a0,s2
    80002444:	60e2                	ld	ra,24(sp)
    80002446:	6442                	ld	s0,16(sp)
    80002448:	64a2                	ld	s1,8(sp)
    8000244a:	6902                	ld	s2,0(sp)
    8000244c:	6105                	addi	sp,sp,32
    8000244e:	8082                	ret

0000000080002450 <wait>:
{
    80002450:	715d                	addi	sp,sp,-80
    80002452:	e486                	sd	ra,72(sp)
    80002454:	e0a2                	sd	s0,64(sp)
    80002456:	fc26                	sd	s1,56(sp)
    80002458:	f84a                	sd	s2,48(sp)
    8000245a:	f44e                	sd	s3,40(sp)
    8000245c:	f052                	sd	s4,32(sp)
    8000245e:	ec56                	sd	s5,24(sp)
    80002460:	e85a                	sd	s6,16(sp)
    80002462:	e45e                	sd	s7,8(sp)
    80002464:	e062                	sd	s8,0(sp)
    80002466:	0880                	addi	s0,sp,80
    80002468:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	55e080e7          	jalr	1374(ra) # 800019c8 <myproc>
    80002472:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002474:	0000e517          	auipc	a0,0xe
    80002478:	74450513          	addi	a0,a0,1860 # 80010bb8 <wait_lock>
    8000247c:	ffffe097          	auipc	ra,0xffffe
    80002480:	75a080e7          	jalr	1882(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002484:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002486:	4a15                	li	s4,5
        havekids = 1;
    80002488:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000248a:	00019997          	auipc	s3,0x19
    8000248e:	b4698993          	addi	s3,s3,-1210 # 8001afd0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002492:	0000ec17          	auipc	s8,0xe
    80002496:	726c0c13          	addi	s8,s8,1830 # 80010bb8 <wait_lock>
    havekids = 0;
    8000249a:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000249c:	0000f497          	auipc	s1,0xf
    800024a0:	b3448493          	addi	s1,s1,-1228 # 80010fd0 <proc>
    800024a4:	a0bd                	j	80002512 <wait+0xc2>
          pid = pp->pid;
    800024a6:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024aa:	000b0e63          	beqz	s6,800024c6 <wait+0x76>
    800024ae:	4691                	li	a3,4
    800024b0:	02c48613          	addi	a2,s1,44
    800024b4:	85da                	mv	a1,s6
    800024b6:	15893503          	ld	a0,344(s2)
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	1ae080e7          	jalr	430(ra) # 80001668 <copyout>
    800024c2:	02054563          	bltz	a0,800024ec <wait+0x9c>
          freeproc(pp);
    800024c6:	8526                	mv	a0,s1
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	6b2080e7          	jalr	1714(ra) # 80001b7a <freeproc>
          release(&pp->lock);
    800024d0:	8526                	mv	a0,s1
    800024d2:	ffffe097          	auipc	ra,0xffffe
    800024d6:	7b8080e7          	jalr	1976(ra) # 80000c8a <release>
          release(&wait_lock);
    800024da:	0000e517          	auipc	a0,0xe
    800024de:	6de50513          	addi	a0,a0,1758 # 80010bb8 <wait_lock>
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	7a8080e7          	jalr	1960(ra) # 80000c8a <release>
          return pid;
    800024ea:	a0b5                	j	80002556 <wait+0x106>
            release(&pp->lock);
    800024ec:	8526                	mv	a0,s1
    800024ee:	ffffe097          	auipc	ra,0xffffe
    800024f2:	79c080e7          	jalr	1948(ra) # 80000c8a <release>
            release(&wait_lock);
    800024f6:	0000e517          	auipc	a0,0xe
    800024fa:	6c250513          	addi	a0,a0,1730 # 80010bb8 <wait_lock>
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	78c080e7          	jalr	1932(ra) # 80000c8a <release>
            return -1;
    80002506:	59fd                	li	s3,-1
    80002508:	a0b9                	j	80002556 <wait+0x106>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000250a:	28048493          	addi	s1,s1,640
    8000250e:	03348463          	beq	s1,s3,80002536 <wait+0xe6>
      if (pp->parent == p)
    80002512:	7c9c                	ld	a5,56(s1)
    80002514:	ff279be3          	bne	a5,s2,8000250a <wait+0xba>
        acquire(&pp->lock);
    80002518:	8526                	mv	a0,s1
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	6bc080e7          	jalr	1724(ra) # 80000bd6 <acquire>
        if (pp->state == ZOMBIE)
    80002522:	4c9c                	lw	a5,24(s1)
    80002524:	f94781e3          	beq	a5,s4,800024a6 <wait+0x56>
        release(&pp->lock);
    80002528:	8526                	mv	a0,s1
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	760080e7          	jalr	1888(ra) # 80000c8a <release>
        havekids = 1;
    80002532:	8756                	mv	a4,s5
    80002534:	bfd9                	j	8000250a <wait+0xba>
    if (!havekids || killed(p))
    80002536:	c719                	beqz	a4,80002544 <wait+0xf4>
    80002538:	854a                	mv	a0,s2
    8000253a:	00000097          	auipc	ra,0x0
    8000253e:	ee4080e7          	jalr	-284(ra) # 8000241e <killed>
    80002542:	c51d                	beqz	a0,80002570 <wait+0x120>
      release(&wait_lock);
    80002544:	0000e517          	auipc	a0,0xe
    80002548:	67450513          	addi	a0,a0,1652 # 80010bb8 <wait_lock>
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	73e080e7          	jalr	1854(ra) # 80000c8a <release>
      return -1;
    80002554:	59fd                	li	s3,-1
}
    80002556:	854e                	mv	a0,s3
    80002558:	60a6                	ld	ra,72(sp)
    8000255a:	6406                	ld	s0,64(sp)
    8000255c:	74e2                	ld	s1,56(sp)
    8000255e:	7942                	ld	s2,48(sp)
    80002560:	79a2                	ld	s3,40(sp)
    80002562:	7a02                	ld	s4,32(sp)
    80002564:	6ae2                	ld	s5,24(sp)
    80002566:	6b42                	ld	s6,16(sp)
    80002568:	6ba2                	ld	s7,8(sp)
    8000256a:	6c02                	ld	s8,0(sp)
    8000256c:	6161                	addi	sp,sp,80
    8000256e:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002570:	85e2                	mv	a1,s8
    80002572:	854a                	mv	a0,s2
    80002574:	00000097          	auipc	ra,0x0
    80002578:	bf6080e7          	jalr	-1034(ra) # 8000216a <sleep>
    havekids = 0;
    8000257c:	bf39                	j	8000249a <wait+0x4a>

000000008000257e <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000257e:	7179                	addi	sp,sp,-48
    80002580:	f406                	sd	ra,40(sp)
    80002582:	f022                	sd	s0,32(sp)
    80002584:	ec26                	sd	s1,24(sp)
    80002586:	e84a                	sd	s2,16(sp)
    80002588:	e44e                	sd	s3,8(sp)
    8000258a:	e052                	sd	s4,0(sp)
    8000258c:	1800                	addi	s0,sp,48
    8000258e:	84aa                	mv	s1,a0
    80002590:	892e                	mv	s2,a1
    80002592:	89b2                	mv	s3,a2
    80002594:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002596:	fffff097          	auipc	ra,0xfffff
    8000259a:	432080e7          	jalr	1074(ra) # 800019c8 <myproc>
  if (user_dst)
    8000259e:	c095                	beqz	s1,800025c2 <either_copyout+0x44>
  {
    return copyout(p->pagetable, dst, src, len);
    800025a0:	86d2                	mv	a3,s4
    800025a2:	864e                	mv	a2,s3
    800025a4:	85ca                	mv	a1,s2
    800025a6:	15853503          	ld	a0,344(a0)
    800025aa:	fffff097          	auipc	ra,0xfffff
    800025ae:	0be080e7          	jalr	190(ra) # 80001668 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025b2:	70a2                	ld	ra,40(sp)
    800025b4:	7402                	ld	s0,32(sp)
    800025b6:	64e2                	ld	s1,24(sp)
    800025b8:	6942                	ld	s2,16(sp)
    800025ba:	69a2                	ld	s3,8(sp)
    800025bc:	6a02                	ld	s4,0(sp)
    800025be:	6145                	addi	sp,sp,48
    800025c0:	8082                	ret
    memmove((char *)dst, src, len);
    800025c2:	000a061b          	sext.w	a2,s4
    800025c6:	85ce                	mv	a1,s3
    800025c8:	854a                	mv	a0,s2
    800025ca:	ffffe097          	auipc	ra,0xffffe
    800025ce:	764080e7          	jalr	1892(ra) # 80000d2e <memmove>
    return 0;
    800025d2:	8526                	mv	a0,s1
    800025d4:	bff9                	j	800025b2 <either_copyout+0x34>

00000000800025d6 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025d6:	7179                	addi	sp,sp,-48
    800025d8:	f406                	sd	ra,40(sp)
    800025da:	f022                	sd	s0,32(sp)
    800025dc:	ec26                	sd	s1,24(sp)
    800025de:	e84a                	sd	s2,16(sp)
    800025e0:	e44e                	sd	s3,8(sp)
    800025e2:	e052                	sd	s4,0(sp)
    800025e4:	1800                	addi	s0,sp,48
    800025e6:	892a                	mv	s2,a0
    800025e8:	84ae                	mv	s1,a1
    800025ea:	89b2                	mv	s3,a2
    800025ec:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ee:	fffff097          	auipc	ra,0xfffff
    800025f2:	3da080e7          	jalr	986(ra) # 800019c8 <myproc>
  if (user_src)
    800025f6:	c095                	beqz	s1,8000261a <either_copyin+0x44>
  {
    return copyin(p->pagetable, dst, src, len);
    800025f8:	86d2                	mv	a3,s4
    800025fa:	864e                	mv	a2,s3
    800025fc:	85ca                	mv	a1,s2
    800025fe:	15853503          	ld	a0,344(a0)
    80002602:	fffff097          	auipc	ra,0xfffff
    80002606:	0f2080e7          	jalr	242(ra) # 800016f4 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000260a:	70a2                	ld	ra,40(sp)
    8000260c:	7402                	ld	s0,32(sp)
    8000260e:	64e2                	ld	s1,24(sp)
    80002610:	6942                	ld	s2,16(sp)
    80002612:	69a2                	ld	s3,8(sp)
    80002614:	6a02                	ld	s4,0(sp)
    80002616:	6145                	addi	sp,sp,48
    80002618:	8082                	ret
    memmove(dst, (char *)src, len);
    8000261a:	000a061b          	sext.w	a2,s4
    8000261e:	85ce                	mv	a1,s3
    80002620:	854a                	mv	a0,s2
    80002622:	ffffe097          	auipc	ra,0xffffe
    80002626:	70c080e7          	jalr	1804(ra) # 80000d2e <memmove>
    return 0;
    8000262a:	8526                	mv	a0,s1
    8000262c:	bff9                	j	8000260a <either_copyin+0x34>

000000008000262e <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    8000262e:	715d                	addi	sp,sp,-80
    80002630:	e486                	sd	ra,72(sp)
    80002632:	e0a2                	sd	s0,64(sp)
    80002634:	fc26                	sd	s1,56(sp)
    80002636:	f84a                	sd	s2,48(sp)
    80002638:	f44e                	sd	s3,40(sp)
    8000263a:	f052                	sd	s4,32(sp)
    8000263c:	ec56                	sd	s5,24(sp)
    8000263e:	e85a                	sd	s6,16(sp)
    80002640:	e45e                	sd	s7,8(sp)
    80002642:	0880                	addi	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002644:	00006517          	auipc	a0,0x6
    80002648:	a8450513          	addi	a0,a0,-1404 # 800080c8 <digits+0x88>
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	f3c080e7          	jalr	-196(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002654:	0000f497          	auipc	s1,0xf
    80002658:	bdc48493          	addi	s1,s1,-1060 # 80011230 <proc+0x260>
    8000265c:	00019917          	auipc	s2,0x19
    80002660:	bd490913          	addi	s2,s2,-1068 # 8001b230 <bcache+0x248>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002664:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002666:	00006997          	auipc	s3,0x6
    8000266a:	c1a98993          	addi	s3,s3,-998 # 80008280 <digits+0x240>
    printf("PID: %d, State: %s (%d), Name: %s, Ctime: %d, Tickets: %d, Arrival time: %d",
    8000266e:	00006a97          	auipc	s5,0x6
    80002672:	c1aa8a93          	addi	s5,s5,-998 # 80008288 <digits+0x248>
           p->pid, state, p->state, p->name, p->ctime, p->tickets, p->arrival_time);
    printf("\n");
    80002676:	00006a17          	auipc	s4,0x6
    8000267a:	a52a0a13          	addi	s4,s4,-1454 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000267e:	00006b97          	auipc	s7,0x6
    80002682:	c8ab8b93          	addi	s7,s7,-886 # 80008308 <states.0>
    80002686:	a035                	j	800026b2 <procdump+0x84>
    printf("PID: %d, State: %s (%d), Name: %s, Ctime: %d, Tickets: %d, Arrival time: %d",
    80002688:	ecc72883          	lw	a7,-308(a4)
    8000268c:	ec872803          	lw	a6,-312(a4)
    80002690:	4b5c                	lw	a5,20(a4)
    80002692:	dd072583          	lw	a1,-560(a4)
    80002696:	8556                	mv	a0,s5
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	ef0080e7          	jalr	-272(ra) # 80000588 <printf>
    printf("\n");
    800026a0:	8552                	mv	a0,s4
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	ee6080e7          	jalr	-282(ra) # 80000588 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800026aa:	28048493          	addi	s1,s1,640
    800026ae:	03248263          	beq	s1,s2,800026d2 <procdump+0xa4>
    if (p->state == UNUSED)
    800026b2:	8726                	mv	a4,s1
    800026b4:	db84a683          	lw	a3,-584(s1)
    800026b8:	daed                	beqz	a3,800026aa <procdump+0x7c>
      state = "???";
    800026ba:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026bc:	fcdb66e3          	bltu	s6,a3,80002688 <procdump+0x5a>
    800026c0:	02069793          	slli	a5,a3,0x20
    800026c4:	9381                	srli	a5,a5,0x20
    800026c6:	078e                	slli	a5,a5,0x3
    800026c8:	97de                	add	a5,a5,s7
    800026ca:	6390                	ld	a2,0(a5)
    800026cc:	fe55                	bnez	a2,80002688 <procdump+0x5a>
      state = "???";
    800026ce:	864e                	mv	a2,s3
    800026d0:	bf65                	j	80002688 <procdump+0x5a>
  }
}
    800026d2:	60a6                	ld	ra,72(sp)
    800026d4:	6406                	ld	s0,64(sp)
    800026d6:	74e2                	ld	s1,56(sp)
    800026d8:	7942                	ld	s2,48(sp)
    800026da:	79a2                	ld	s3,40(sp)
    800026dc:	7a02                	ld	s4,32(sp)
    800026de:	6ae2                	ld	s5,24(sp)
    800026e0:	6b42                	ld	s6,16(sp)
    800026e2:	6ba2                	ld	s7,8(sp)
    800026e4:	6161                	addi	sp,sp,80
    800026e6:	8082                	ret

00000000800026e8 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    800026e8:	711d                	addi	sp,sp,-96
    800026ea:	ec86                	sd	ra,88(sp)
    800026ec:	e8a2                	sd	s0,80(sp)
    800026ee:	e4a6                	sd	s1,72(sp)
    800026f0:	e0ca                	sd	s2,64(sp)
    800026f2:	fc4e                	sd	s3,56(sp)
    800026f4:	f852                	sd	s4,48(sp)
    800026f6:	f456                	sd	s5,40(sp)
    800026f8:	f05a                	sd	s6,32(sp)
    800026fa:	ec5e                	sd	s7,24(sp)
    800026fc:	e862                	sd	s8,16(sp)
    800026fe:	e466                	sd	s9,8(sp)
    80002700:	e06a                	sd	s10,0(sp)
    80002702:	1080                	addi	s0,sp,96
    80002704:	8b2a                	mv	s6,a0
    80002706:	8bae                	mv	s7,a1
    80002708:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    8000270a:	fffff097          	auipc	ra,0xfffff
    8000270e:	2be080e7          	jalr	702(ra) # 800019c8 <myproc>
    80002712:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002714:	0000e517          	auipc	a0,0xe
    80002718:	4a450513          	addi	a0,a0,1188 # 80010bb8 <wait_lock>
    8000271c:	ffffe097          	auipc	ra,0xffffe
    80002720:	4ba080e7          	jalr	1210(ra) # 80000bd6 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    80002724:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    80002726:	4a15                	li	s4,5
        havekids = 1;
    80002728:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    8000272a:	00019997          	auipc	s3,0x19
    8000272e:	8a698993          	addi	s3,s3,-1882 # 8001afd0 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002732:	0000ed17          	auipc	s10,0xe
    80002736:	486d0d13          	addi	s10,s10,1158 # 80010bb8 <wait_lock>
    havekids = 0;
    8000273a:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    8000273c:	0000f497          	auipc	s1,0xf
    80002740:	89448493          	addi	s1,s1,-1900 # 80010fd0 <proc>
    80002744:	a059                	j	800027ca <waitx+0xe2>
          pid = np->pid;
    80002746:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    8000274a:	2704a703          	lw	a4,624(s1)
    8000274e:	00ec2023          	sw	a4,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    80002752:	2744a783          	lw	a5,628(s1)
    80002756:	9f3d                	addw	a4,a4,a5
    80002758:	2784a783          	lw	a5,632(s1)
    8000275c:	9f99                	subw	a5,a5,a4
    8000275e:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002762:	000b0e63          	beqz	s6,8000277e <waitx+0x96>
    80002766:	4691                	li	a3,4
    80002768:	02c48613          	addi	a2,s1,44
    8000276c:	85da                	mv	a1,s6
    8000276e:	15893503          	ld	a0,344(s2)
    80002772:	fffff097          	auipc	ra,0xfffff
    80002776:	ef6080e7          	jalr	-266(ra) # 80001668 <copyout>
    8000277a:	02054563          	bltz	a0,800027a4 <waitx+0xbc>
          freeproc(np);
    8000277e:	8526                	mv	a0,s1
    80002780:	fffff097          	auipc	ra,0xfffff
    80002784:	3fa080e7          	jalr	1018(ra) # 80001b7a <freeproc>
          release(&np->lock);
    80002788:	8526                	mv	a0,s1
    8000278a:	ffffe097          	auipc	ra,0xffffe
    8000278e:	500080e7          	jalr	1280(ra) # 80000c8a <release>
          release(&wait_lock);
    80002792:	0000e517          	auipc	a0,0xe
    80002796:	42650513          	addi	a0,a0,1062 # 80010bb8 <wait_lock>
    8000279a:	ffffe097          	auipc	ra,0xffffe
    8000279e:	4f0080e7          	jalr	1264(ra) # 80000c8a <release>
          return pid;
    800027a2:	a09d                	j	80002808 <waitx+0x120>
            release(&np->lock);
    800027a4:	8526                	mv	a0,s1
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	4e4080e7          	jalr	1252(ra) # 80000c8a <release>
            release(&wait_lock);
    800027ae:	0000e517          	auipc	a0,0xe
    800027b2:	40a50513          	addi	a0,a0,1034 # 80010bb8 <wait_lock>
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	4d4080e7          	jalr	1236(ra) # 80000c8a <release>
            return -1;
    800027be:	59fd                	li	s3,-1
    800027c0:	a0a1                	j	80002808 <waitx+0x120>
    for (np = proc; np < &proc[NPROC]; np++)
    800027c2:	28048493          	addi	s1,s1,640
    800027c6:	03348463          	beq	s1,s3,800027ee <waitx+0x106>
      if (np->parent == p)
    800027ca:	7c9c                	ld	a5,56(s1)
    800027cc:	ff279be3          	bne	a5,s2,800027c2 <waitx+0xda>
        acquire(&np->lock);
    800027d0:	8526                	mv	a0,s1
    800027d2:	ffffe097          	auipc	ra,0xffffe
    800027d6:	404080e7          	jalr	1028(ra) # 80000bd6 <acquire>
        if (np->state == ZOMBIE)
    800027da:	4c9c                	lw	a5,24(s1)
    800027dc:	f74785e3          	beq	a5,s4,80002746 <waitx+0x5e>
        release(&np->lock);
    800027e0:	8526                	mv	a0,s1
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	4a8080e7          	jalr	1192(ra) # 80000c8a <release>
        havekids = 1;
    800027ea:	8756                	mv	a4,s5
    800027ec:	bfd9                	j	800027c2 <waitx+0xda>
    if (!havekids || p->killed)
    800027ee:	c701                	beqz	a4,800027f6 <waitx+0x10e>
    800027f0:	02892783          	lw	a5,40(s2)
    800027f4:	cb8d                	beqz	a5,80002826 <waitx+0x13e>
      release(&wait_lock);
    800027f6:	0000e517          	auipc	a0,0xe
    800027fa:	3c250513          	addi	a0,a0,962 # 80010bb8 <wait_lock>
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	48c080e7          	jalr	1164(ra) # 80000c8a <release>
      return -1;
    80002806:	59fd                	li	s3,-1
  }
}
    80002808:	854e                	mv	a0,s3
    8000280a:	60e6                	ld	ra,88(sp)
    8000280c:	6446                	ld	s0,80(sp)
    8000280e:	64a6                	ld	s1,72(sp)
    80002810:	6906                	ld	s2,64(sp)
    80002812:	79e2                	ld	s3,56(sp)
    80002814:	7a42                	ld	s4,48(sp)
    80002816:	7aa2                	ld	s5,40(sp)
    80002818:	7b02                	ld	s6,32(sp)
    8000281a:	6be2                	ld	s7,24(sp)
    8000281c:	6c42                	ld	s8,16(sp)
    8000281e:	6ca2                	ld	s9,8(sp)
    80002820:	6d02                	ld	s10,0(sp)
    80002822:	6125                	addi	sp,sp,96
    80002824:	8082                	ret
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002826:	85ea                	mv	a1,s10
    80002828:	854a                	mv	a0,s2
    8000282a:	00000097          	auipc	ra,0x0
    8000282e:	940080e7          	jalr	-1728(ra) # 8000216a <sleep>
    havekids = 0;
    80002832:	b721                	j	8000273a <waitx+0x52>

0000000080002834 <update_time>:

void update_time()
{
    80002834:	7179                	addi	sp,sp,-48
    80002836:	f406                	sd	ra,40(sp)
    80002838:	f022                	sd	s0,32(sp)
    8000283a:	ec26                	sd	s1,24(sp)
    8000283c:	e84a                	sd	s2,16(sp)
    8000283e:	e44e                	sd	s3,8(sp)
    80002840:	e052                	sd	s4,0(sp)
    80002842:	1800                	addi	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    80002844:	0000e497          	auipc	s1,0xe
    80002848:	78c48493          	addi	s1,s1,1932 # 80010fd0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    8000284c:	4991                	li	s3,4
    {
      p->rtime++;
    }
    else if(p->state == RUNNABLE)
    8000284e:	4a0d                	li	s4,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002850:	00018917          	auipc	s2,0x18
    80002854:	78090913          	addi	s2,s2,1920 # 8001afd0 <tickslock>
    80002858:	a839                	j	80002876 <update_time+0x42>
      p->rtime++;
    8000285a:	2704a783          	lw	a5,624(s1)
    8000285e:	2785                	addiw	a5,a5,1
    80002860:	26f4a823          	sw	a5,624(s1)
    {
      // printf("Process %d is in runnable state\n", p->pid);
      p->waiting_time++;
      // printf("Process %d waiting time: %d\n", p->pid, p->waiting_time);
    }
    release(&p->lock);
    80002864:	8526                	mv	a0,s1
    80002866:	ffffe097          	auipc	ra,0xffffe
    8000286a:	424080e7          	jalr	1060(ra) # 80000c8a <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000286e:	28048493          	addi	s1,s1,640
    80002872:	03248263          	beq	s1,s2,80002896 <update_time+0x62>
    acquire(&p->lock);
    80002876:	8526                	mv	a0,s1
    80002878:	ffffe097          	auipc	ra,0xffffe
    8000287c:	35e080e7          	jalr	862(ra) # 80000bd6 <acquire>
    if (p->state == RUNNING)
    80002880:	4c9c                	lw	a5,24(s1)
    80002882:	fd378ce3          	beq	a5,s3,8000285a <update_time+0x26>
    else if(p->state == RUNNABLE)
    80002886:	fd479fe3          	bne	a5,s4,80002864 <update_time+0x30>
      p->waiting_time++;
    8000288a:	1384a783          	lw	a5,312(s1)
    8000288e:	2785                	addiw	a5,a5,1
    80002890:	12f4ac23          	sw	a5,312(s1)
    80002894:	bfc1                	j	80002864 <update_time+0x30>
	//   		if (p->state == RUNNABLE || p->state == RUNNING)
	//   			printf("(%d, %d, %d),\n", p->pid, ticks, p->pqno);
	//   	}
	//   }
  // #endif
}
    80002896:	70a2                	ld	ra,40(sp)
    80002898:	7402                	ld	s0,32(sp)
    8000289a:	64e2                	ld	s1,24(sp)
    8000289c:	6942                	ld	s2,16(sp)
    8000289e:	69a2                	ld	s3,8(sp)
    800028a0:	6a02                	ld	s4,0(sp)
    800028a2:	6145                	addi	sp,sp,48
    800028a4:	8082                	ret

00000000800028a6 <swtch>:
    800028a6:	00153023          	sd	ra,0(a0)
    800028aa:	00253423          	sd	sp,8(a0)
    800028ae:	e900                	sd	s0,16(a0)
    800028b0:	ed04                	sd	s1,24(a0)
    800028b2:	03253023          	sd	s2,32(a0)
    800028b6:	03353423          	sd	s3,40(a0)
    800028ba:	03453823          	sd	s4,48(a0)
    800028be:	03553c23          	sd	s5,56(a0)
    800028c2:	05653023          	sd	s6,64(a0)
    800028c6:	05753423          	sd	s7,72(a0)
    800028ca:	05853823          	sd	s8,80(a0)
    800028ce:	05953c23          	sd	s9,88(a0)
    800028d2:	07a53023          	sd	s10,96(a0)
    800028d6:	07b53423          	sd	s11,104(a0)
    800028da:	0005b083          	ld	ra,0(a1)
    800028de:	0085b103          	ld	sp,8(a1)
    800028e2:	6980                	ld	s0,16(a1)
    800028e4:	6d84                	ld	s1,24(a1)
    800028e6:	0205b903          	ld	s2,32(a1)
    800028ea:	0285b983          	ld	s3,40(a1)
    800028ee:	0305ba03          	ld	s4,48(a1)
    800028f2:	0385ba83          	ld	s5,56(a1)
    800028f6:	0405bb03          	ld	s6,64(a1)
    800028fa:	0485bb83          	ld	s7,72(a1)
    800028fe:	0505bc03          	ld	s8,80(a1)
    80002902:	0585bc83          	ld	s9,88(a1)
    80002906:	0605bd03          	ld	s10,96(a1)
    8000290a:	0685bd83          	ld	s11,104(a1)
    8000290e:	8082                	ret

0000000080002910 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002910:	1141                	addi	sp,sp,-16
    80002912:	e406                	sd	ra,8(sp)
    80002914:	e022                	sd	s0,0(sp)
    80002916:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002918:	00006597          	auipc	a1,0x6
    8000291c:	a2058593          	addi	a1,a1,-1504 # 80008338 <states.0+0x30>
    80002920:	00018517          	auipc	a0,0x18
    80002924:	6b050513          	addi	a0,a0,1712 # 8001afd0 <tickslock>
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	21e080e7          	jalr	542(ra) # 80000b46 <initlock>
}
    80002930:	60a2                	ld	ra,8(sp)
    80002932:	6402                	ld	s0,0(sp)
    80002934:	0141                	addi	sp,sp,16
    80002936:	8082                	ret

0000000080002938 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002938:	1141                	addi	sp,sp,-16
    8000293a:	e422                	sd	s0,8(sp)
    8000293c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000293e:	00004797          	auipc	a5,0x4
    80002942:	a6278793          	addi	a5,a5,-1438 # 800063a0 <kernelvec>
    80002946:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000294a:	6422                	ld	s0,8(sp)
    8000294c:	0141                	addi	sp,sp,16
    8000294e:	8082                	ret

0000000080002950 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002950:	1141                	addi	sp,sp,-16
    80002952:	e406                	sd	ra,8(sp)
    80002954:	e022                	sd	s0,0(sp)
    80002956:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002958:	fffff097          	auipc	ra,0xfffff
    8000295c:	070080e7          	jalr	112(ra) # 800019c8 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002960:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002964:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002966:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000296a:	00004617          	auipc	a2,0x4
    8000296e:	69660613          	addi	a2,a2,1686 # 80007000 <_trampoline>
    80002972:	00004697          	auipc	a3,0x4
    80002976:	68e68693          	addi	a3,a3,1678 # 80007000 <_trampoline>
    8000297a:	8e91                	sub	a3,a3,a2
    8000297c:	040007b7          	lui	a5,0x4000
    80002980:	17fd                	addi	a5,a5,-1
    80002982:	07b2                	slli	a5,a5,0xc
    80002984:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002986:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000298a:	16053703          	ld	a4,352(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000298e:	180026f3          	csrr	a3,satp
    80002992:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002994:	16053703          	ld	a4,352(a0)
    80002998:	14853683          	ld	a3,328(a0)
    8000299c:	6585                	lui	a1,0x1
    8000299e:	96ae                	add	a3,a3,a1
    800029a0:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029a2:	16053703          	ld	a4,352(a0)
    800029a6:	00000697          	auipc	a3,0x0
    800029aa:	14468693          	addi	a3,a3,324 # 80002aea <usertrap>
    800029ae:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    800029b0:	16053703          	ld	a4,352(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029b4:	8692                	mv	a3,tp
    800029b6:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b8:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029bc:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029c0:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029c4:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029c8:	16053703          	ld	a4,352(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029cc:	6f18                	ld	a4,24(a4)
    800029ce:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029d2:	15853503          	ld	a0,344(a0)
    800029d6:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800029d8:	00004717          	auipc	a4,0x4
    800029dc:	6c470713          	addi	a4,a4,1732 # 8000709c <userret>
    800029e0:	8f11                	sub	a4,a4,a2
    800029e2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800029e4:	577d                	li	a4,-1
    800029e6:	177e                	slli	a4,a4,0x3f
    800029e8:	8d59                	or	a0,a0,a4
    800029ea:	9782                	jalr	a5
}
    800029ec:	60a2                	ld	ra,8(sp)
    800029ee:	6402                	ld	s0,0(sp)
    800029f0:	0141                	addi	sp,sp,16
    800029f2:	8082                	ret

00000000800029f4 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    800029f4:	1101                	addi	sp,sp,-32
    800029f6:	ec06                	sd	ra,24(sp)
    800029f8:	e822                	sd	s0,16(sp)
    800029fa:	e426                	sd	s1,8(sp)
    800029fc:	e04a                	sd	s2,0(sp)
    800029fe:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a00:	00018917          	auipc	s2,0x18
    80002a04:	5d090913          	addi	s2,s2,1488 # 8001afd0 <tickslock>
    80002a08:	854a                	mv	a0,s2
    80002a0a:	ffffe097          	auipc	ra,0xffffe
    80002a0e:	1cc080e7          	jalr	460(ra) # 80000bd6 <acquire>
  ticks++;
    80002a12:	00006497          	auipc	s1,0x6
    80002a16:	f1e48493          	addi	s1,s1,-226 # 80008930 <ticks>
    80002a1a:	409c                	lw	a5,0(s1)
    80002a1c:	2785                	addiw	a5,a5,1
    80002a1e:	c09c                	sw	a5,0(s1)
  update_time();
    80002a20:	00000097          	auipc	ra,0x0
    80002a24:	e14080e7          	jalr	-492(ra) # 80002834 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002a28:	8526                	mv	a0,s1
    80002a2a:	fffff097          	auipc	ra,0xfffff
    80002a2e:	7a4080e7          	jalr	1956(ra) # 800021ce <wakeup>
  release(&tickslock);
    80002a32:	854a                	mv	a0,s2
    80002a34:	ffffe097          	auipc	ra,0xffffe
    80002a38:	256080e7          	jalr	598(ra) # 80000c8a <release>
}
    80002a3c:	60e2                	ld	ra,24(sp)
    80002a3e:	6442                	ld	s0,16(sp)
    80002a40:	64a2                	ld	s1,8(sp)
    80002a42:	6902                	ld	s2,0(sp)
    80002a44:	6105                	addi	sp,sp,32
    80002a46:	8082                	ret

0000000080002a48 <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002a48:	1101                	addi	sp,sp,-32
    80002a4a:	ec06                	sd	ra,24(sp)
    80002a4c:	e822                	sd	s0,16(sp)
    80002a4e:	e426                	sd	s1,8(sp)
    80002a50:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a52:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002a56:	00074d63          	bltz	a4,80002a70 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002a5a:	57fd                	li	a5,-1
    80002a5c:	17fe                	slli	a5,a5,0x3f
    80002a5e:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002a60:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002a62:	06f70363          	beq	a4,a5,80002ac8 <devintr+0x80>
  }
}
    80002a66:	60e2                	ld	ra,24(sp)
    80002a68:	6442                	ld	s0,16(sp)
    80002a6a:	64a2                	ld	s1,8(sp)
    80002a6c:	6105                	addi	sp,sp,32
    80002a6e:	8082                	ret
      (scause & 0xff) == 9)
    80002a70:	0ff77793          	andi	a5,a4,255
  if ((scause & 0x8000000000000000L) &&
    80002a74:	46a5                	li	a3,9
    80002a76:	fed792e3          	bne	a5,a3,80002a5a <devintr+0x12>
    int irq = plic_claim();
    80002a7a:	00004097          	auipc	ra,0x4
    80002a7e:	a2e080e7          	jalr	-1490(ra) # 800064a8 <plic_claim>
    80002a82:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002a84:	47a9                	li	a5,10
    80002a86:	02f50763          	beq	a0,a5,80002ab4 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002a8a:	4785                	li	a5,1
    80002a8c:	02f50963          	beq	a0,a5,80002abe <devintr+0x76>
    return 1;
    80002a90:	4505                	li	a0,1
    else if (irq)
    80002a92:	d8f1                	beqz	s1,80002a66 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a94:	85a6                	mv	a1,s1
    80002a96:	00006517          	auipc	a0,0x6
    80002a9a:	8aa50513          	addi	a0,a0,-1878 # 80008340 <states.0+0x38>
    80002a9e:	ffffe097          	auipc	ra,0xffffe
    80002aa2:	aea080e7          	jalr	-1302(ra) # 80000588 <printf>
      plic_complete(irq);
    80002aa6:	8526                	mv	a0,s1
    80002aa8:	00004097          	auipc	ra,0x4
    80002aac:	a24080e7          	jalr	-1500(ra) # 800064cc <plic_complete>
    return 1;
    80002ab0:	4505                	li	a0,1
    80002ab2:	bf55                	j	80002a66 <devintr+0x1e>
      uartintr();
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	ee6080e7          	jalr	-282(ra) # 8000099a <uartintr>
    80002abc:	b7ed                	j	80002aa6 <devintr+0x5e>
      virtio_disk_intr();
    80002abe:	00004097          	auipc	ra,0x4
    80002ac2:	eda080e7          	jalr	-294(ra) # 80006998 <virtio_disk_intr>
    80002ac6:	b7c5                	j	80002aa6 <devintr+0x5e>
    if (cpuid() == 0)
    80002ac8:	fffff097          	auipc	ra,0xfffff
    80002acc:	ed4080e7          	jalr	-300(ra) # 8000199c <cpuid>
    80002ad0:	c901                	beqz	a0,80002ae0 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ad2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ad6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ad8:	14479073          	csrw	sip,a5
    return 2;
    80002adc:	4509                	li	a0,2
    80002ade:	b761                	j	80002a66 <devintr+0x1e>
      clockintr();
    80002ae0:	00000097          	auipc	ra,0x0
    80002ae4:	f14080e7          	jalr	-236(ra) # 800029f4 <clockintr>
    80002ae8:	b7ed                	j	80002ad2 <devintr+0x8a>

0000000080002aea <usertrap>:
{
    80002aea:	1101                	addi	sp,sp,-32
    80002aec:	ec06                	sd	ra,24(sp)
    80002aee:	e822                	sd	s0,16(sp)
    80002af0:	e426                	sd	s1,8(sp)
    80002af2:	e04a                	sd	s2,0(sp)
    80002af4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002af6:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002afa:	1007f793          	andi	a5,a5,256
    80002afe:	eba5                	bnez	a5,80002b6e <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b00:	00004797          	auipc	a5,0x4
    80002b04:	8a078793          	addi	a5,a5,-1888 # 800063a0 <kernelvec>
    80002b08:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b0c:	fffff097          	auipc	ra,0xfffff
    80002b10:	ebc080e7          	jalr	-324(ra) # 800019c8 <myproc>
    80002b14:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b16:	16053783          	ld	a5,352(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b1a:	14102773          	csrr	a4,sepc
    80002b1e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b20:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002b24:	47a1                	li	a5,8
    80002b26:	04f70c63          	beq	a4,a5,80002b7e <usertrap+0x94>
  else if ((which_dev = devintr()) != 0)
    80002b2a:	00000097          	auipc	ra,0x0
    80002b2e:	f1e080e7          	jalr	-226(ra) # 80002a48 <devintr>
    80002b32:	892a                	mv	s2,a0
    80002b34:	cd69                	beqz	a0,80002c0e <usertrap+0x124>
    if (which_dev == 2) // Timer interrupt
    80002b36:	4789                	li	a5,2
    80002b38:	06f51863          	bne	a0,a5,80002ba8 <usertrap+0xbe>
      p->cur_ticks++;
    80002b3c:	44fc                	lw	a5,76(s1)
    80002b3e:	2785                	addiw	a5,a5,1
    80002b40:	0007871b          	sext.w	a4,a5
    80002b44:	c4fc                	sw	a5,76(s1)
      if (p->cur_ticks >= p->ticks && p->ticks > 0)
    80002b46:	44bc                	lw	a5,72(s1)
    80002b48:	00f74863          	blt	a4,a5,80002b58 <usertrap+0x6e>
    80002b4c:	00f05663          	blez	a5,80002b58 <usertrap+0x6e>
        if (p->alarm_on == 0)
    80002b50:	4cbc                	lw	a5,88(s1)
    80002b52:	c3c9                	beqz	a5,80002bd4 <usertrap+0xea>
        p->cur_ticks = 0;
    80002b54:	0404a623          	sw	zero,76(s1)
  if (killed(p))
    80002b58:	8526                	mv	a0,s1
    80002b5a:	00000097          	auipc	ra,0x0
    80002b5e:	8c4080e7          	jalr	-1852(ra) # 8000241e <killed>
    80002b62:	ed65                	bnez	a0,80002c5a <usertrap+0x170>
    yield();  // Assuming Round Robin as the default behavior
    80002b64:	fffff097          	auipc	ra,0xfffff
    80002b68:	5ca080e7          	jalr	1482(ra) # 8000212e <yield>
    80002b6c:	a0a1                	j	80002bb4 <usertrap+0xca>
    panic("usertrap: not from user mode");
    80002b6e:	00005517          	auipc	a0,0x5
    80002b72:	7f250513          	addi	a0,a0,2034 # 80008360 <states.0+0x58>
    80002b76:	ffffe097          	auipc	ra,0xffffe
    80002b7a:	9c8080e7          	jalr	-1592(ra) # 8000053e <panic>
    if (killed(p))
    80002b7e:	00000097          	auipc	ra,0x0
    80002b82:	8a0080e7          	jalr	-1888(ra) # 8000241e <killed>
    80002b86:	e129                	bnez	a0,80002bc8 <usertrap+0xde>
    p->trapframe->epc += 4;
    80002b88:	1604b703          	ld	a4,352(s1)
    80002b8c:	6f1c                	ld	a5,24(a4)
    80002b8e:	0791                	addi	a5,a5,4
    80002b90:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b9a:	10079073          	csrw	sstatus,a5
    syscall();
    80002b9e:	00000097          	auipc	ra,0x0
    80002ba2:	324080e7          	jalr	804(ra) # 80002ec2 <syscall>
  int which_dev = 0;
    80002ba6:	4901                	li	s2,0
  if (killed(p))
    80002ba8:	8526                	mv	a0,s1
    80002baa:	00000097          	auipc	ra,0x0
    80002bae:	874080e7          	jalr	-1932(ra) # 8000241e <killed>
    80002bb2:	e959                	bnez	a0,80002c48 <usertrap+0x15e>
  usertrapret();
    80002bb4:	00000097          	auipc	ra,0x0
    80002bb8:	d9c080e7          	jalr	-612(ra) # 80002950 <usertrapret>
}
    80002bbc:	60e2                	ld	ra,24(sp)
    80002bbe:	6442                	ld	s0,16(sp)
    80002bc0:	64a2                	ld	s1,8(sp)
    80002bc2:	6902                	ld	s2,0(sp)
    80002bc4:	6105                	addi	sp,sp,32
    80002bc6:	8082                	ret
      exit(-1);
    80002bc8:	557d                	li	a0,-1
    80002bca:	fffff097          	auipc	ra,0xfffff
    80002bce:	6d4080e7          	jalr	1748(ra) # 8000229e <exit>
    80002bd2:	bf5d                	j	80002b88 <usertrap+0x9e>
          p->alarm_on = 1;
    80002bd4:	4785                	li	a5,1
    80002bd6:	ccbc                	sw	a5,88(s1)
          struct trapframe *tf = kalloc();
    80002bd8:	ffffe097          	auipc	ra,0xffffe
    80002bdc:	f0e080e7          	jalr	-242(ra) # 80000ae6 <kalloc>
    80002be0:	892a                	mv	s2,a0
          if (tf == 0)
    80002be2:	c105                	beqz	a0,80002c02 <usertrap+0x118>
            memmove(tf, p->trapframe, sizeof(*p->trapframe));
    80002be4:	12000613          	li	a2,288
    80002be8:	1604b583          	ld	a1,352(s1)
    80002bec:	ffffe097          	auipc	ra,0xffffe
    80002bf0:	142080e7          	jalr	322(ra) # 80000d2e <memmove>
            p->alarm_tf = tf;
    80002bf4:	0524b823          	sd	s2,80(s1)
            p->trapframe->epc = p->handler;
    80002bf8:	1604b783          	ld	a5,352(s1)
    80002bfc:	60b8                	ld	a4,64(s1)
    80002bfe:	ef98                	sd	a4,24(a5)
    80002c00:	bf91                	j	80002b54 <usertrap+0x6a>
            setkilled(p);
    80002c02:	8526                	mv	a0,s1
    80002c04:	fffff097          	auipc	ra,0xfffff
    80002c08:	7ee080e7          	jalr	2030(ra) # 800023f2 <setkilled>
    80002c0c:	b7a1                	j	80002b54 <usertrap+0x6a>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c0e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c12:	5890                	lw	a2,48(s1)
    80002c14:	00005517          	auipc	a0,0x5
    80002c18:	76c50513          	addi	a0,a0,1900 # 80008380 <states.0+0x78>
    80002c1c:	ffffe097          	auipc	ra,0xffffe
    80002c20:	96c080e7          	jalr	-1684(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c24:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c28:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c2c:	00005517          	auipc	a0,0x5
    80002c30:	78450513          	addi	a0,a0,1924 # 800083b0 <states.0+0xa8>
    80002c34:	ffffe097          	auipc	ra,0xffffe
    80002c38:	954080e7          	jalr	-1708(ra) # 80000588 <printf>
    setkilled(p);
    80002c3c:	8526                	mv	a0,s1
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	7b4080e7          	jalr	1972(ra) # 800023f2 <setkilled>
    80002c46:	b78d                	j	80002ba8 <usertrap+0xbe>
    exit(-1);
    80002c48:	557d                	li	a0,-1
    80002c4a:	fffff097          	auipc	ra,0xfffff
    80002c4e:	654080e7          	jalr	1620(ra) # 8000229e <exit>
  if(which_dev == 2){
    80002c52:	4789                	li	a5,2
    80002c54:	f6f910e3          	bne	s2,a5,80002bb4 <usertrap+0xca>
    80002c58:	b731                	j	80002b64 <usertrap+0x7a>
    exit(-1);
    80002c5a:	557d                	li	a0,-1
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	642080e7          	jalr	1602(ra) # 8000229e <exit>
  if(which_dev == 2){
    80002c64:	b701                	j	80002b64 <usertrap+0x7a>

0000000080002c66 <kerneltrap>:
{
    80002c66:	7179                	addi	sp,sp,-48
    80002c68:	f406                	sd	ra,40(sp)
    80002c6a:	f022                	sd	s0,32(sp)
    80002c6c:	ec26                	sd	s1,24(sp)
    80002c6e:	e84a                	sd	s2,16(sp)
    80002c70:	e44e                	sd	s3,8(sp)
    80002c72:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c74:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c78:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c7c:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002c80:	1004f793          	andi	a5,s1,256
    80002c84:	cb85                	beqz	a5,80002cb4 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c86:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c8a:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002c8c:	ef85                	bnez	a5,80002cc4 <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002c8e:	00000097          	auipc	ra,0x0
    80002c92:	dba080e7          	jalr	-582(ra) # 80002a48 <devintr>
    80002c96:	cd1d                	beqz	a0,80002cd4 <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c98:	4789                	li	a5,2
    80002c9a:	06f50a63          	beq	a0,a5,80002d0e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c9e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ca2:	10049073          	csrw	sstatus,s1
}
    80002ca6:	70a2                	ld	ra,40(sp)
    80002ca8:	7402                	ld	s0,32(sp)
    80002caa:	64e2                	ld	s1,24(sp)
    80002cac:	6942                	ld	s2,16(sp)
    80002cae:	69a2                	ld	s3,8(sp)
    80002cb0:	6145                	addi	sp,sp,48
    80002cb2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cb4:	00005517          	auipc	a0,0x5
    80002cb8:	71c50513          	addi	a0,a0,1820 # 800083d0 <states.0+0xc8>
    80002cbc:	ffffe097          	auipc	ra,0xffffe
    80002cc0:	882080e7          	jalr	-1918(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002cc4:	00005517          	auipc	a0,0x5
    80002cc8:	73450513          	addi	a0,a0,1844 # 800083f8 <states.0+0xf0>
    80002ccc:	ffffe097          	auipc	ra,0xffffe
    80002cd0:	872080e7          	jalr	-1934(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002cd4:	85ce                	mv	a1,s3
    80002cd6:	00005517          	auipc	a0,0x5
    80002cda:	74250513          	addi	a0,a0,1858 # 80008418 <states.0+0x110>
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	8aa080e7          	jalr	-1878(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ce6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cea:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cee:	00005517          	auipc	a0,0x5
    80002cf2:	73a50513          	addi	a0,a0,1850 # 80008428 <states.0+0x120>
    80002cf6:	ffffe097          	auipc	ra,0xffffe
    80002cfa:	892080e7          	jalr	-1902(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002cfe:	00005517          	auipc	a0,0x5
    80002d02:	74250513          	addi	a0,a0,1858 # 80008440 <states.0+0x138>
    80002d06:	ffffe097          	auipc	ra,0xffffe
    80002d0a:	838080e7          	jalr	-1992(ra) # 8000053e <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d0e:	fffff097          	auipc	ra,0xfffff
    80002d12:	cba080e7          	jalr	-838(ra) # 800019c8 <myproc>
    80002d16:	d541                	beqz	a0,80002c9e <kerneltrap+0x38>
    80002d18:	fffff097          	auipc	ra,0xfffff
    80002d1c:	cb0080e7          	jalr	-848(ra) # 800019c8 <myproc>
    80002d20:	4d18                	lw	a4,24(a0)
    80002d22:	4791                	li	a5,4
    80002d24:	f6f71de3          	bne	a4,a5,80002c9e <kerneltrap+0x38>
    yield();
    80002d28:	fffff097          	auipc	ra,0xfffff
    80002d2c:	406080e7          	jalr	1030(ra) # 8000212e <yield>
    80002d30:	b7bd                	j	80002c9e <kerneltrap+0x38>

0000000080002d32 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d32:	1101                	addi	sp,sp,-32
    80002d34:	ec06                	sd	ra,24(sp)
    80002d36:	e822                	sd	s0,16(sp)
    80002d38:	e426                	sd	s1,8(sp)
    80002d3a:	1000                	addi	s0,sp,32
    80002d3c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d3e:	fffff097          	auipc	ra,0xfffff
    80002d42:	c8a080e7          	jalr	-886(ra) # 800019c8 <myproc>
  switch (n) {
    80002d46:	4795                	li	a5,5
    80002d48:	0497e763          	bltu	a5,s1,80002d96 <argraw+0x64>
    80002d4c:	048a                	slli	s1,s1,0x2
    80002d4e:	00005717          	auipc	a4,0x5
    80002d52:	72a70713          	addi	a4,a4,1834 # 80008478 <states.0+0x170>
    80002d56:	94ba                	add	s1,s1,a4
    80002d58:	409c                	lw	a5,0(s1)
    80002d5a:	97ba                	add	a5,a5,a4
    80002d5c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d5e:	16053783          	ld	a5,352(a0)
    80002d62:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d64:	60e2                	ld	ra,24(sp)
    80002d66:	6442                	ld	s0,16(sp)
    80002d68:	64a2                	ld	s1,8(sp)
    80002d6a:	6105                	addi	sp,sp,32
    80002d6c:	8082                	ret
    return p->trapframe->a1;
    80002d6e:	16053783          	ld	a5,352(a0)
    80002d72:	7fa8                	ld	a0,120(a5)
    80002d74:	bfc5                	j	80002d64 <argraw+0x32>
    return p->trapframe->a2;
    80002d76:	16053783          	ld	a5,352(a0)
    80002d7a:	63c8                	ld	a0,128(a5)
    80002d7c:	b7e5                	j	80002d64 <argraw+0x32>
    return p->trapframe->a3;
    80002d7e:	16053783          	ld	a5,352(a0)
    80002d82:	67c8                	ld	a0,136(a5)
    80002d84:	b7c5                	j	80002d64 <argraw+0x32>
    return p->trapframe->a4;
    80002d86:	16053783          	ld	a5,352(a0)
    80002d8a:	6bc8                	ld	a0,144(a5)
    80002d8c:	bfe1                	j	80002d64 <argraw+0x32>
    return p->trapframe->a5;
    80002d8e:	16053783          	ld	a5,352(a0)
    80002d92:	6fc8                	ld	a0,152(a5)
    80002d94:	bfc1                	j	80002d64 <argraw+0x32>
  panic("argraw");
    80002d96:	00005517          	auipc	a0,0x5
    80002d9a:	6ba50513          	addi	a0,a0,1722 # 80008450 <states.0+0x148>
    80002d9e:	ffffd097          	auipc	ra,0xffffd
    80002da2:	7a0080e7          	jalr	1952(ra) # 8000053e <panic>

0000000080002da6 <fetchaddr>:
{
    80002da6:	1101                	addi	sp,sp,-32
    80002da8:	ec06                	sd	ra,24(sp)
    80002daa:	e822                	sd	s0,16(sp)
    80002dac:	e426                	sd	s1,8(sp)
    80002dae:	e04a                	sd	s2,0(sp)
    80002db0:	1000                	addi	s0,sp,32
    80002db2:	84aa                	mv	s1,a0
    80002db4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002db6:	fffff097          	auipc	ra,0xfffff
    80002dba:	c12080e7          	jalr	-1006(ra) # 800019c8 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002dbe:	15053783          	ld	a5,336(a0)
    80002dc2:	02f4f963          	bgeu	s1,a5,80002df4 <fetchaddr+0x4e>
    80002dc6:	00848713          	addi	a4,s1,8
    80002dca:	02e7e763          	bltu	a5,a4,80002df8 <fetchaddr+0x52>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002dce:	46a1                	li	a3,8
    80002dd0:	8626                	mv	a2,s1
    80002dd2:	85ca                	mv	a1,s2
    80002dd4:	15853503          	ld	a0,344(a0)
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	91c080e7          	jalr	-1764(ra) # 800016f4 <copyin>
    80002de0:	00a03533          	snez	a0,a0
    80002de4:	40a00533          	neg	a0,a0
}
    80002de8:	60e2                	ld	ra,24(sp)
    80002dea:	6442                	ld	s0,16(sp)
    80002dec:	64a2                	ld	s1,8(sp)
    80002dee:	6902                	ld	s2,0(sp)
    80002df0:	6105                	addi	sp,sp,32
    80002df2:	8082                	ret
    return -1;
    80002df4:	557d                	li	a0,-1
    80002df6:	bfcd                	j	80002de8 <fetchaddr+0x42>
    80002df8:	557d                	li	a0,-1
    80002dfa:	b7fd                	j	80002de8 <fetchaddr+0x42>

0000000080002dfc <fetchstr>:
{
    80002dfc:	7179                	addi	sp,sp,-48
    80002dfe:	f406                	sd	ra,40(sp)
    80002e00:	f022                	sd	s0,32(sp)
    80002e02:	ec26                	sd	s1,24(sp)
    80002e04:	e84a                	sd	s2,16(sp)
    80002e06:	e44e                	sd	s3,8(sp)
    80002e08:	1800                	addi	s0,sp,48
    80002e0a:	892a                	mv	s2,a0
    80002e0c:	84ae                	mv	s1,a1
    80002e0e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e10:	fffff097          	auipc	ra,0xfffff
    80002e14:	bb8080e7          	jalr	-1096(ra) # 800019c8 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e18:	86ce                	mv	a3,s3
    80002e1a:	864a                	mv	a2,s2
    80002e1c:	85a6                	mv	a1,s1
    80002e1e:	15853503          	ld	a0,344(a0)
    80002e22:	fffff097          	auipc	ra,0xfffff
    80002e26:	960080e7          	jalr	-1696(ra) # 80001782 <copyinstr>
    80002e2a:	00054e63          	bltz	a0,80002e46 <fetchstr+0x4a>
  return strlen(buf);
    80002e2e:	8526                	mv	a0,s1
    80002e30:	ffffe097          	auipc	ra,0xffffe
    80002e34:	01e080e7          	jalr	30(ra) # 80000e4e <strlen>
}
    80002e38:	70a2                	ld	ra,40(sp)
    80002e3a:	7402                	ld	s0,32(sp)
    80002e3c:	64e2                	ld	s1,24(sp)
    80002e3e:	6942                	ld	s2,16(sp)
    80002e40:	69a2                	ld	s3,8(sp)
    80002e42:	6145                	addi	sp,sp,48
    80002e44:	8082                	ret
    return -1;
    80002e46:	557d                	li	a0,-1
    80002e48:	bfc5                	j	80002e38 <fetchstr+0x3c>

0000000080002e4a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e4a:	1101                	addi	sp,sp,-32
    80002e4c:	ec06                	sd	ra,24(sp)
    80002e4e:	e822                	sd	s0,16(sp)
    80002e50:	e426                	sd	s1,8(sp)
    80002e52:	1000                	addi	s0,sp,32
    80002e54:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e56:	00000097          	auipc	ra,0x0
    80002e5a:	edc080e7          	jalr	-292(ra) # 80002d32 <argraw>
    80002e5e:	c088                	sw	a0,0(s1)
}
    80002e60:	60e2                	ld	ra,24(sp)
    80002e62:	6442                	ld	s0,16(sp)
    80002e64:	64a2                	ld	s1,8(sp)
    80002e66:	6105                	addi	sp,sp,32
    80002e68:	8082                	ret

0000000080002e6a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e6a:	1101                	addi	sp,sp,-32
    80002e6c:	ec06                	sd	ra,24(sp)
    80002e6e:	e822                	sd	s0,16(sp)
    80002e70:	e426                	sd	s1,8(sp)
    80002e72:	1000                	addi	s0,sp,32
    80002e74:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e76:	00000097          	auipc	ra,0x0
    80002e7a:	ebc080e7          	jalr	-324(ra) # 80002d32 <argraw>
    80002e7e:	e088                	sd	a0,0(s1)
}
    80002e80:	60e2                	ld	ra,24(sp)
    80002e82:	6442                	ld	s0,16(sp)
    80002e84:	64a2                	ld	s1,8(sp)
    80002e86:	6105                	addi	sp,sp,32
    80002e88:	8082                	ret

0000000080002e8a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e8a:	7179                	addi	sp,sp,-48
    80002e8c:	f406                	sd	ra,40(sp)
    80002e8e:	f022                	sd	s0,32(sp)
    80002e90:	ec26                	sd	s1,24(sp)
    80002e92:	e84a                	sd	s2,16(sp)
    80002e94:	1800                	addi	s0,sp,48
    80002e96:	84ae                	mv	s1,a1
    80002e98:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e9a:	fd840593          	addi	a1,s0,-40
    80002e9e:	00000097          	auipc	ra,0x0
    80002ea2:	fcc080e7          	jalr	-52(ra) # 80002e6a <argaddr>
  return fetchstr(addr, buf, max);
    80002ea6:	864a                	mv	a2,s2
    80002ea8:	85a6                	mv	a1,s1
    80002eaa:	fd843503          	ld	a0,-40(s0)
    80002eae:	00000097          	auipc	ra,0x0
    80002eb2:	f4e080e7          	jalr	-178(ra) # 80002dfc <fetchstr>
}
    80002eb6:	70a2                	ld	ra,40(sp)
    80002eb8:	7402                	ld	s0,32(sp)
    80002eba:	64e2                	ld	s1,24(sp)
    80002ebc:	6942                	ld	s2,16(sp)
    80002ebe:	6145                	addi	sp,sp,48
    80002ec0:	8082                	ret

0000000080002ec2 <syscall>:
[SYS_settickets] sys_settickets,
};

void
syscall(void)
{
    80002ec2:	1101                	addi	sp,sp,-32
    80002ec4:	ec06                	sd	ra,24(sp)
    80002ec6:	e822                	sd	s0,16(sp)
    80002ec8:	e426                	sd	s1,8(sp)
    80002eca:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ecc:	fffff097          	auipc	ra,0xfffff
    80002ed0:	afc080e7          	jalr	-1284(ra) # 800019c8 <myproc>
    80002ed4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ed6:	16053783          	ld	a5,352(a0)
    80002eda:	77dc                	ld	a5,168(a5)
    80002edc:	0007869b          	sext.w	a3,a5
  // }
  // printf("System call %d\n", num);

  // acquire(&wait_lock);
    // p->syscall_count[num]++;
  if (num == SYS_read) {
    80002ee0:	4715                	li	a4,5
    80002ee2:	0ce68363          	beq	a3,a4,80002fa8 <syscall+0xe6>
    if(p->parent) p->parent->readcount++;
}
if (num == SYS_write) {
    80002ee6:	4741                	li	a4,16
    80002ee8:	16e69d63          	bne	a3,a4,80003062 <syscall+0x1a0>
    if(p->parent) p->parent->writecount++;
    80002eec:	7d18                	ld	a4,56(a0)
    80002eee:	c701                	beqz	a4,80002ef6 <syscall+0x34>
    80002ef0:	5330                	lw	a2,96(a4)
    80002ef2:	2605                	addiw	a2,a2,1
    80002ef4:	d330                	sw	a2,96(a4)
    if(p->parent) p->parent->forkcount++;
}
if (num == SYS_exit) {
    if(p->parent) p->parent->exitcount++;
}
if (num == SYS_wait) {
    80002ef6:	470d                	li	a4,3
    80002ef8:	16e69d63          	bne	a3,a4,80003072 <syscall+0x1b0>
    if(p->parent) p->parent->waitcount++;
    80002efc:	7c98                	ld	a4,56(s1)
    80002efe:	c701                	beqz	a4,80002f06 <syscall+0x44>
    80002f00:	5770                	lw	a2,108(a4)
    80002f02:	2605                	addiw	a2,a2,1
    80002f04:	d770                	sw	a2,108(a4)
    if(p->parent) p->parent->sleepcount++;
}
if (num == SYS_uptime) {
    if(p->parent) p->parent->uptimecount++;
}
if (num == SYS_kill) {
    80002f06:	4719                	li	a4,6
    80002f08:	16e69d63          	bne	a3,a4,80003082 <syscall+0x1c0>
    if(p->parent) p->parent->killcount++;
    80002f0c:	7c98                	ld	a4,56(s1)
    80002f0e:	c701                	beqz	a4,80002f16 <syscall+0x54>
    80002f10:	5f30                	lw	a2,120(a4)
    80002f12:	2605                	addiw	a2,a2,1
    80002f14:	df30                	sw	a2,120(a4)
    if(p->parent) p->parent->sigalarmcount++;
}
if (num == SYS_sigreturn) {
    if(p->parent) p->parent->sigreturncount++;
}
if (num == SYS_chdir) {
    80002f16:	4725                	li	a4,9
    80002f18:	16e69d63          	bne	a3,a4,80003092 <syscall+0x1d0>
    if(p->parent) p->parent->chdircount++;
    80002f1c:	7c98                	ld	a4,56(s1)
    80002f1e:	c711                	beqz	a4,80002f2a <syscall+0x68>
    80002f20:	08472603          	lw	a2,132(a4)
    80002f24:	2605                	addiw	a2,a2,1
    80002f26:	08c72223          	sw	a2,132(a4)
    if(p->parent) p->parent->dupcount++;
}
if (num == SYS_getpid) {
    if(p->parent) p->parent->getpidcount++;
}
if (num == SYS_sbrk) {
    80002f2a:	4731                	li	a4,12
    80002f2c:	16e69d63          	bne	a3,a4,800030a6 <syscall+0x1e4>
    if(p->parent) p->parent->sbrkcount++;
    80002f30:	7c98                	ld	a4,56(s1)
    80002f32:	c711                	beqz	a4,80002f3e <syscall+0x7c>
    80002f34:	09072603          	lw	a2,144(a4)
    80002f38:	2605                	addiw	a2,a2,1
    80002f3a:	08c72823          	sw	a2,144(a4)
    }
}
if (num == SYS_mknod) {
    if(p->parent) p->parent->mknodcount++;
}
if (num == SYS_unlink) {
    80002f3e:	4749                	li	a4,18
    80002f40:	16e69d63          	bne	a3,a4,800030ba <syscall+0x1f8>
    if(p->parent) p->parent->unlinkcount++;
    80002f44:	7c98                	ld	a4,56(s1)
    80002f46:	c711                	beqz	a4,80002f52 <syscall+0x90>
    80002f48:	09c72603          	lw	a2,156(a4)
    80002f4c:	2605                	addiw	a2,a2,1
    80002f4e:	08c72e23          	sw	a2,156(a4)
    if(p->parent) p->parent->linkcount++;
}
if (num == SYS_mkdir) {
    if(p->parent) p->parent->mkdircount++;
}
if (num == SYS_close) {
    80002f52:	4755                	li	a4,21
    80002f54:	16e69d63          	bne	a3,a4,800030ce <syscall+0x20c>
    if(p->parent) p->parent->closecount++;
    80002f58:	7c98                	ld	a4,56(s1)
    80002f5a:	c711                	beqz	a4,80002f66 <syscall+0xa4>
    80002f5c:	0a872603          	lw	a2,168(a4)
    80002f60:	2605                	addiw	a2,a2,1
    80002f62:	0ac72423          	sw	a2,168(a4)
    if(p->parent) p->parent->waitxcount++;
}
if (num == SYS_getSysCount) {
    if(p->parent) p->parent->getSysCountcount++;
}
if (num == SYS_pipe) {
    80002f66:	4711                	li	a4,4
    80002f68:	16e69d63          	bne	a3,a4,800030e2 <syscall+0x220>
    if(p->parent) p->parent->pipecount++;
    80002f6c:	7c98                	ld	a4,56(s1)
    80002f6e:	c711                	beqz	a4,80002f7a <syscall+0xb8>
    80002f70:	0b472603          	lw	a2,180(a4)
    80002f74:	2605                	addiw	a2,a2,1
    80002f76:	0ac72a23          	sw	a2,180(a4)
    if(p->parent) p->parent->execcount++;
}
if (num == SYS_fstat) {
    if(p->parent) p->parent->fstatcount++;
}
if(num == SYS_settickets){
    80002f7a:	4769                	li	a4,26
    80002f7c:	16e69d63          	bne	a3,a4,800030f6 <syscall+0x234>
  if(p->parent) p->parent->setticketscount++;  
    80002f80:	7c98                	ld	a4,56(s1)
    80002f82:	c711                	beqz	a4,80002f8e <syscall+0xcc>
    80002f84:	0c072603          	lw	a2,192(a4)
    80002f88:	2605                	addiw	a2,a2,1
    80002f8a:	0cc72023          	sw	a2,192(a4)
}


    // release(&initlock);
  
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002f8e:	37fd                	addiw	a5,a5,-1
    80002f90:	4665                	li	a2,25
    80002f92:	00000717          	auipc	a4,0x0
    80002f96:	61c70713          	addi	a4,a4,1564 # 800035ae <sys_settickets>
    80002f9a:	16f66c63          	bltu	a2,a5,80003112 <syscall+0x250>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    
    p->trapframe->a0 = syscalls[num]();
    80002f9e:	1604b483          	ld	s1,352(s1)
    80002fa2:	9702                	jalr	a4
    80002fa4:	f8a8                	sd	a0,112(s1)
    80002fa6:	a269                	j	80003130 <syscall+0x26e>
    if(p->parent) p->parent->readcount++;
    80002fa8:	7d18                	ld	a4,56(a0)
    80002faa:	c701                	beqz	a4,80002fb2 <syscall+0xf0>
    80002fac:	4f70                	lw	a2,92(a4)
    80002fae:	2605                	addiw	a2,a2,1
    80002fb0:	cf70                	sw	a2,92(a4)
if (num == SYS_exit) {
    80002fb2:	4709                	li	a4,2
    80002fb4:	f4e691e3          	bne	a3,a4,80002ef6 <syscall+0x34>
    if(p->parent) p->parent->exitcount++;
    80002fb8:	7c98                	ld	a4,56(s1)
    80002fba:	c701                	beqz	a4,80002fc2 <syscall+0x100>
    80002fbc:	5730                	lw	a2,104(a4)
    80002fbe:	2605                	addiw	a2,a2,1
    80002fc0:	d730                	sw	a2,104(a4)
if (num == SYS_uptime) {
    80002fc2:	4739                	li	a4,14
    80002fc4:	f4e691e3          	bne	a3,a4,80002f06 <syscall+0x44>
    if(p->parent) p->parent->uptimecount++;
    80002fc8:	7c98                	ld	a4,56(s1)
    80002fca:	c701                	beqz	a4,80002fd2 <syscall+0x110>
    80002fcc:	5b70                	lw	a2,116(a4)
    80002fce:	2605                	addiw	a2,a2,1
    80002fd0:	db70                	sw	a2,116(a4)
if (num == SYS_sigreturn) {
    80002fd2:	4765                	li	a4,25
    80002fd4:	f4e691e3          	bne	a3,a4,80002f16 <syscall+0x54>
    if(p->parent) p->parent->sigreturncount++;
    80002fd8:	7c98                	ld	a4,56(s1)
    80002fda:	c711                	beqz	a4,80002fe6 <syscall+0x124>
    80002fdc:	08072603          	lw	a2,128(a4)
    80002fe0:	2605                	addiw	a2,a2,1
    80002fe2:	08c72023          	sw	a2,128(a4)
if (num == SYS_getpid) {
    80002fe6:	472d                	li	a4,11
    80002fe8:	f4e691e3          	bne	a3,a4,80002f2a <syscall+0x68>
    if(p->parent) p->parent->getpidcount++;
    80002fec:	7c98                	ld	a4,56(s1)
    80002fee:	c711                	beqz	a4,80002ffa <syscall+0x138>
    80002ff0:	08c72603          	lw	a2,140(a4)
    80002ff4:	2605                	addiw	a2,a2,1
    80002ff6:	08c72623          	sw	a2,140(a4)
if (num == SYS_mknod) {
    80002ffa:	4745                	li	a4,17
    80002ffc:	f4e691e3          	bne	a3,a4,80002f3e <syscall+0x7c>
    if(p->parent) p->parent->mknodcount++;
    80003000:	7c98                	ld	a4,56(s1)
    80003002:	c711                	beqz	a4,8000300e <syscall+0x14c>
    80003004:	09872603          	lw	a2,152(a4)
    80003008:	2605                	addiw	a2,a2,1
    8000300a:	08c72c23          	sw	a2,152(a4)
if (num == SYS_mkdir) {
    8000300e:	4751                	li	a4,20
    80003010:	f4e691e3          	bne	a3,a4,80002f52 <syscall+0x90>
    if(p->parent) p->parent->mkdircount++;
    80003014:	7c98                	ld	a4,56(s1)
    80003016:	c711                	beqz	a4,80003022 <syscall+0x160>
    80003018:	0a472603          	lw	a2,164(a4)
    8000301c:	2605                	addiw	a2,a2,1
    8000301e:	0ac72223          	sw	a2,164(a4)
if (num == SYS_getSysCount) {
    80003022:	475d                	li	a4,23
    80003024:	f4e691e3          	bne	a3,a4,80002f66 <syscall+0xa4>
    if(p->parent) p->parent->getSysCountcount++;
    80003028:	7c98                	ld	a4,56(s1)
    8000302a:	c711                	beqz	a4,80003036 <syscall+0x174>
    8000302c:	0b072603          	lw	a2,176(a4)
    80003030:	2605                	addiw	a2,a2,1
    80003032:	0ac72823          	sw	a2,176(a4)
if (num == SYS_fstat) {
    80003036:	4721                	li	a4,8
    80003038:	f4e691e3          	bne	a3,a4,80002f7a <syscall+0xb8>
    if(p->parent) p->parent->fstatcount++;
    8000303c:	7c98                	ld	a4,56(s1)
    8000303e:	c711                	beqz	a4,8000304a <syscall+0x188>
    80003040:	0bc72603          	lw	a2,188(a4)
    80003044:	2605                	addiw	a2,a2,1
    80003046:	0ac72e23          	sw	a2,188(a4)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000304a:	37fd                	addiw	a5,a5,-1
    8000304c:	4765                	li	a4,25
    8000304e:	0cf76263          	bltu	a4,a5,80003112 <syscall+0x250>
    80003052:	068e                	slli	a3,a3,0x3
    80003054:	00005797          	auipc	a5,0x5
    80003058:	43c78793          	addi	a5,a5,1084 # 80008490 <syscalls>
    8000305c:	96be                	add	a3,a3,a5
    8000305e:	6298                	ld	a4,0(a3)
    80003060:	bf3d                	j	80002f9e <syscall+0xdc>
if (num == SYS_fork) {
    80003062:	4705                	li	a4,1
    80003064:	f4e697e3          	bne	a3,a4,80002fb2 <syscall+0xf0>
    if(p->parent) p->parent->forkcount++;
    80003068:	7d18                	ld	a4,56(a0)
    8000306a:	c701                	beqz	a4,80003072 <syscall+0x1b0>
    8000306c:	5370                	lw	a2,100(a4)
    8000306e:	2605                	addiw	a2,a2,1
    80003070:	d370                	sw	a2,100(a4)
if (num == SYS_sleep) {
    80003072:	4735                	li	a4,13
    80003074:	f4e697e3          	bne	a3,a4,80002fc2 <syscall+0x100>
    if(p->parent) p->parent->sleepcount++;
    80003078:	7c98                	ld	a4,56(s1)
    8000307a:	c701                	beqz	a4,80003082 <syscall+0x1c0>
    8000307c:	5b30                	lw	a2,112(a4)
    8000307e:	2605                	addiw	a2,a2,1
    80003080:	db30                	sw	a2,112(a4)
if (num == SYS_sigalarm) {
    80003082:	4761                	li	a4,24
    80003084:	f4e697e3          	bne	a3,a4,80002fd2 <syscall+0x110>
    if(p->parent) p->parent->sigalarmcount++;
    80003088:	7c98                	ld	a4,56(s1)
    8000308a:	c701                	beqz	a4,80003092 <syscall+0x1d0>
    8000308c:	5f70                	lw	a2,124(a4)
    8000308e:	2605                	addiw	a2,a2,1
    80003090:	df70                	sw	a2,124(a4)
if (num == SYS_dup) {
    80003092:	4729                	li	a4,10
    80003094:	f4e699e3          	bne	a3,a4,80002fe6 <syscall+0x124>
    if(p->parent) p->parent->dupcount++;
    80003098:	7c98                	ld	a4,56(s1)
    8000309a:	c711                	beqz	a4,800030a6 <syscall+0x1e4>
    8000309c:	08872603          	lw	a2,136(a4)
    800030a0:	2605                	addiw	a2,a2,1
    800030a2:	08c72423          	sw	a2,136(a4)
if (num == SYS_open) {
    800030a6:	473d                	li	a4,15
    800030a8:	f4e699e3          	bne	a3,a4,80002ffa <syscall+0x138>
    if(p->parent) {
    800030ac:	7c98                	ld	a4,56(s1)
    800030ae:	c711                	beqz	a4,800030ba <syscall+0x1f8>
        p->parent->opencount++;
    800030b0:	09472603          	lw	a2,148(a4)
    800030b4:	2605                	addiw	a2,a2,1
    800030b6:	08c72a23          	sw	a2,148(a4)
if (num == SYS_link) {
    800030ba:	474d                	li	a4,19
    800030bc:	f4e699e3          	bne	a3,a4,8000300e <syscall+0x14c>
    if(p->parent) p->parent->linkcount++;
    800030c0:	7c98                	ld	a4,56(s1)
    800030c2:	c711                	beqz	a4,800030ce <syscall+0x20c>
    800030c4:	0a072603          	lw	a2,160(a4)
    800030c8:	2605                	addiw	a2,a2,1
    800030ca:	0ac72023          	sw	a2,160(a4)
if (num == SYS_waitx) {
    800030ce:	4759                	li	a4,22
    800030d0:	f4e699e3          	bne	a3,a4,80003022 <syscall+0x160>
    if(p->parent) p->parent->waitxcount++;
    800030d4:	7c98                	ld	a4,56(s1)
    800030d6:	c711                	beqz	a4,800030e2 <syscall+0x220>
    800030d8:	0ac72603          	lw	a2,172(a4)
    800030dc:	2605                	addiw	a2,a2,1
    800030de:	0ac72623          	sw	a2,172(a4)
if (num == SYS_exec) {
    800030e2:	471d                	li	a4,7
    800030e4:	f4e699e3          	bne	a3,a4,80003036 <syscall+0x174>
    if(p->parent) p->parent->execcount++;
    800030e8:	7c98                	ld	a4,56(s1)
    800030ea:	c711                	beqz	a4,800030f6 <syscall+0x234>
    800030ec:	0b872603          	lw	a2,184(a4)
    800030f0:	2605                	addiw	a2,a2,1
    800030f2:	0ac72c23          	sw	a2,184(a4)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800030f6:	37fd                	addiw	a5,a5,-1
    800030f8:	4765                	li	a4,25
    800030fa:	00f76c63          	bltu	a4,a5,80003112 <syscall+0x250>
    800030fe:	00369713          	slli	a4,a3,0x3
    80003102:	00005797          	auipc	a5,0x5
    80003106:	38e78793          	addi	a5,a5,910 # 80008490 <syscalls>
    8000310a:	97ba                	add	a5,a5,a4
    8000310c:	6398                	ld	a4,0(a5)
    8000310e:	e80718e3          	bnez	a4,80002f9e <syscall+0xdc>
    // printf("System call %d count: %d\n", num, p->syscall_count[num]); // Debugging statement
    // if (num < NUM_SYSCALLS) {
    //   sysCount[num]++; // Increment the count for the system call
    // }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003112:	26048613          	addi	a2,s1,608
    80003116:	588c                	lw	a1,48(s1)
    80003118:	00005517          	auipc	a0,0x5
    8000311c:	34050513          	addi	a0,a0,832 # 80008458 <states.0+0x150>
    80003120:	ffffd097          	auipc	ra,0xffffd
    80003124:	468080e7          	jalr	1128(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003128:	1604b783          	ld	a5,352(s1)
    8000312c:	577d                	li	a4,-1
    8000312e:	fbb8                	sd	a4,112(a5)
  }
}
    80003130:	60e2                	ld	ra,24(sp)
    80003132:	6442                	ld	s0,16(sp)
    80003134:	64a2                	ld	s1,8(sp)
    80003136:	6105                	addi	sp,sp,32
    80003138:	8082                	ret

000000008000313a <sys_exit>:

extern int sysnum;

uint64
sys_exit(void)
{
    8000313a:	1101                	addi	sp,sp,-32
    8000313c:	ec06                	sd	ra,24(sp)
    8000313e:	e822                	sd	s0,16(sp)
    80003140:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80003142:	fec40593          	addi	a1,s0,-20
    80003146:	4501                	li	a0,0
    80003148:	00000097          	auipc	ra,0x0
    8000314c:	d02080e7          	jalr	-766(ra) # 80002e4a <argint>
  exit(n);
    80003150:	fec42503          	lw	a0,-20(s0)
    80003154:	fffff097          	auipc	ra,0xfffff
    80003158:	14a080e7          	jalr	330(ra) # 8000229e <exit>
  return 0; // not reached
}
    8000315c:	4501                	li	a0,0
    8000315e:	60e2                	ld	ra,24(sp)
    80003160:	6442                	ld	s0,16(sp)
    80003162:	6105                	addi	sp,sp,32
    80003164:	8082                	ret

0000000080003166 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003166:	1141                	addi	sp,sp,-16
    80003168:	e406                	sd	ra,8(sp)
    8000316a:	e022                	sd	s0,0(sp)
    8000316c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000316e:	fffff097          	auipc	ra,0xfffff
    80003172:	85a080e7          	jalr	-1958(ra) # 800019c8 <myproc>
}
    80003176:	5908                	lw	a0,48(a0)
    80003178:	60a2                	ld	ra,8(sp)
    8000317a:	6402                	ld	s0,0(sp)
    8000317c:	0141                	addi	sp,sp,16
    8000317e:	8082                	ret

0000000080003180 <sys_fork>:

uint64
sys_fork(void)
{
    80003180:	1141                	addi	sp,sp,-16
    80003182:	e406                	sd	ra,8(sp)
    80003184:	e022                	sd	s0,0(sp)
    80003186:	0800                	addi	s0,sp,16
  return fork();
    80003188:	fffff097          	auipc	ra,0xfffff
    8000318c:	cda080e7          	jalr	-806(ra) # 80001e62 <fork>
}
    80003190:	60a2                	ld	ra,8(sp)
    80003192:	6402                	ld	s0,0(sp)
    80003194:	0141                	addi	sp,sp,16
    80003196:	8082                	ret

0000000080003198 <sys_wait>:

uint64
sys_wait(void)
{
    80003198:	1101                	addi	sp,sp,-32
    8000319a:	ec06                	sd	ra,24(sp)
    8000319c:	e822                	sd	s0,16(sp)
    8000319e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800031a0:	fe840593          	addi	a1,s0,-24
    800031a4:	4501                	li	a0,0
    800031a6:	00000097          	auipc	ra,0x0
    800031aa:	cc4080e7          	jalr	-828(ra) # 80002e6a <argaddr>
  return wait(p);
    800031ae:	fe843503          	ld	a0,-24(s0)
    800031b2:	fffff097          	auipc	ra,0xfffff
    800031b6:	29e080e7          	jalr	670(ra) # 80002450 <wait>
}
    800031ba:	60e2                	ld	ra,24(sp)
    800031bc:	6442                	ld	s0,16(sp)
    800031be:	6105                	addi	sp,sp,32
    800031c0:	8082                	ret

00000000800031c2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800031c2:	7179                	addi	sp,sp,-48
    800031c4:	f406                	sd	ra,40(sp)
    800031c6:	f022                	sd	s0,32(sp)
    800031c8:	ec26                	sd	s1,24(sp)
    800031ca:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800031cc:	fdc40593          	addi	a1,s0,-36
    800031d0:	4501                	li	a0,0
    800031d2:	00000097          	auipc	ra,0x0
    800031d6:	c78080e7          	jalr	-904(ra) # 80002e4a <argint>
  addr = myproc()->sz;
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	7ee080e7          	jalr	2030(ra) # 800019c8 <myproc>
    800031e2:	15053483          	ld	s1,336(a0)
  if (growproc(n) < 0)
    800031e6:	fdc42503          	lw	a0,-36(s0)
    800031ea:	fffff097          	auipc	ra,0xfffff
    800031ee:	c14080e7          	jalr	-1004(ra) # 80001dfe <growproc>
    800031f2:	00054863          	bltz	a0,80003202 <sys_sbrk+0x40>
    return -1;
  return addr;
}
    800031f6:	8526                	mv	a0,s1
    800031f8:	70a2                	ld	ra,40(sp)
    800031fa:	7402                	ld	s0,32(sp)
    800031fc:	64e2                	ld	s1,24(sp)
    800031fe:	6145                	addi	sp,sp,48
    80003200:	8082                	ret
    return -1;
    80003202:	54fd                	li	s1,-1
    80003204:	bfcd                	j	800031f6 <sys_sbrk+0x34>

0000000080003206 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003206:	7139                	addi	sp,sp,-64
    80003208:	fc06                	sd	ra,56(sp)
    8000320a:	f822                	sd	s0,48(sp)
    8000320c:	f426                	sd	s1,40(sp)
    8000320e:	f04a                	sd	s2,32(sp)
    80003210:	ec4e                	sd	s3,24(sp)
    80003212:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003214:	fcc40593          	addi	a1,s0,-52
    80003218:	4501                	li	a0,0
    8000321a:	00000097          	auipc	ra,0x0
    8000321e:	c30080e7          	jalr	-976(ra) # 80002e4a <argint>
  acquire(&tickslock);
    80003222:	00018517          	auipc	a0,0x18
    80003226:	dae50513          	addi	a0,a0,-594 # 8001afd0 <tickslock>
    8000322a:	ffffe097          	auipc	ra,0xffffe
    8000322e:	9ac080e7          	jalr	-1620(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80003232:	00005917          	auipc	s2,0x5
    80003236:	6fe92903          	lw	s2,1790(s2) # 80008930 <ticks>
  while (ticks - ticks0 < n)
    8000323a:	fcc42783          	lw	a5,-52(s0)
    8000323e:	cf9d                	beqz	a5,8000327c <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003240:	00018997          	auipc	s3,0x18
    80003244:	d9098993          	addi	s3,s3,-624 # 8001afd0 <tickslock>
    80003248:	00005497          	auipc	s1,0x5
    8000324c:	6e848493          	addi	s1,s1,1768 # 80008930 <ticks>
    if (killed(myproc()))
    80003250:	ffffe097          	auipc	ra,0xffffe
    80003254:	778080e7          	jalr	1912(ra) # 800019c8 <myproc>
    80003258:	fffff097          	auipc	ra,0xfffff
    8000325c:	1c6080e7          	jalr	454(ra) # 8000241e <killed>
    80003260:	ed15                	bnez	a0,8000329c <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80003262:	85ce                	mv	a1,s3
    80003264:	8526                	mv	a0,s1
    80003266:	fffff097          	auipc	ra,0xfffff
    8000326a:	f04080e7          	jalr	-252(ra) # 8000216a <sleep>
  while (ticks - ticks0 < n)
    8000326e:	409c                	lw	a5,0(s1)
    80003270:	412787bb          	subw	a5,a5,s2
    80003274:	fcc42703          	lw	a4,-52(s0)
    80003278:	fce7ece3          	bltu	a5,a4,80003250 <sys_sleep+0x4a>
  }
  release(&tickslock);
    8000327c:	00018517          	auipc	a0,0x18
    80003280:	d5450513          	addi	a0,a0,-684 # 8001afd0 <tickslock>
    80003284:	ffffe097          	auipc	ra,0xffffe
    80003288:	a06080e7          	jalr	-1530(ra) # 80000c8a <release>
  return 0;
    8000328c:	4501                	li	a0,0
}
    8000328e:	70e2                	ld	ra,56(sp)
    80003290:	7442                	ld	s0,48(sp)
    80003292:	74a2                	ld	s1,40(sp)
    80003294:	7902                	ld	s2,32(sp)
    80003296:	69e2                	ld	s3,24(sp)
    80003298:	6121                	addi	sp,sp,64
    8000329a:	8082                	ret
      release(&tickslock);
    8000329c:	00018517          	auipc	a0,0x18
    800032a0:	d3450513          	addi	a0,a0,-716 # 8001afd0 <tickslock>
    800032a4:	ffffe097          	auipc	ra,0xffffe
    800032a8:	9e6080e7          	jalr	-1562(ra) # 80000c8a <release>
      return -1;
    800032ac:	557d                	li	a0,-1
    800032ae:	b7c5                	j	8000328e <sys_sleep+0x88>

00000000800032b0 <sys_kill>:

uint64
sys_kill(void)
{
    800032b0:	1101                	addi	sp,sp,-32
    800032b2:	ec06                	sd	ra,24(sp)
    800032b4:	e822                	sd	s0,16(sp)
    800032b6:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800032b8:	fec40593          	addi	a1,s0,-20
    800032bc:	4501                	li	a0,0
    800032be:	00000097          	auipc	ra,0x0
    800032c2:	b8c080e7          	jalr	-1140(ra) # 80002e4a <argint>
  return kill(pid);
    800032c6:	fec42503          	lw	a0,-20(s0)
    800032ca:	fffff097          	auipc	ra,0xfffff
    800032ce:	0b6080e7          	jalr	182(ra) # 80002380 <kill>
}
    800032d2:	60e2                	ld	ra,24(sp)
    800032d4:	6442                	ld	s0,16(sp)
    800032d6:	6105                	addi	sp,sp,32
    800032d8:	8082                	ret

00000000800032da <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800032da:	1101                	addi	sp,sp,-32
    800032dc:	ec06                	sd	ra,24(sp)
    800032de:	e822                	sd	s0,16(sp)
    800032e0:	e426                	sd	s1,8(sp)
    800032e2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800032e4:	00018517          	auipc	a0,0x18
    800032e8:	cec50513          	addi	a0,a0,-788 # 8001afd0 <tickslock>
    800032ec:	ffffe097          	auipc	ra,0xffffe
    800032f0:	8ea080e7          	jalr	-1814(ra) # 80000bd6 <acquire>
  xticks = ticks;
    800032f4:	00005497          	auipc	s1,0x5
    800032f8:	63c4a483          	lw	s1,1596(s1) # 80008930 <ticks>
  release(&tickslock);
    800032fc:	00018517          	auipc	a0,0x18
    80003300:	cd450513          	addi	a0,a0,-812 # 8001afd0 <tickslock>
    80003304:	ffffe097          	auipc	ra,0xffffe
    80003308:	986080e7          	jalr	-1658(ra) # 80000c8a <release>
  return xticks;
}
    8000330c:	02049513          	slli	a0,s1,0x20
    80003310:	9101                	srli	a0,a0,0x20
    80003312:	60e2                	ld	ra,24(sp)
    80003314:	6442                	ld	s0,16(sp)
    80003316:	64a2                	ld	s1,8(sp)
    80003318:	6105                	addi	sp,sp,32
    8000331a:	8082                	ret

000000008000331c <sys_waitx>:

uint64
sys_waitx(void)
{
    8000331c:	7139                	addi	sp,sp,-64
    8000331e:	fc06                	sd	ra,56(sp)
    80003320:	f822                	sd	s0,48(sp)
    80003322:	f426                	sd	s1,40(sp)
    80003324:	f04a                	sd	s2,32(sp)
    80003326:	0080                	addi	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    80003328:	fd840593          	addi	a1,s0,-40
    8000332c:	4501                	li	a0,0
    8000332e:	00000097          	auipc	ra,0x0
    80003332:	b3c080e7          	jalr	-1220(ra) # 80002e6a <argaddr>
  argaddr(1, &addr1); // user virtual memory
    80003336:	fd040593          	addi	a1,s0,-48
    8000333a:	4505                	li	a0,1
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	b2e080e7          	jalr	-1234(ra) # 80002e6a <argaddr>
  argaddr(2, &addr2);
    80003344:	fc840593          	addi	a1,s0,-56
    80003348:	4509                	li	a0,2
    8000334a:	00000097          	auipc	ra,0x0
    8000334e:	b20080e7          	jalr	-1248(ra) # 80002e6a <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003352:	fc040613          	addi	a2,s0,-64
    80003356:	fc440593          	addi	a1,s0,-60
    8000335a:	fd843503          	ld	a0,-40(s0)
    8000335e:	fffff097          	auipc	ra,0xfffff
    80003362:	38a080e7          	jalr	906(ra) # 800026e8 <waitx>
    80003366:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80003368:	ffffe097          	auipc	ra,0xffffe
    8000336c:	660080e7          	jalr	1632(ra) # 800019c8 <myproc>
    80003370:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003372:	4691                	li	a3,4
    80003374:	fc440613          	addi	a2,s0,-60
    80003378:	fd043583          	ld	a1,-48(s0)
    8000337c:	15853503          	ld	a0,344(a0)
    80003380:	ffffe097          	auipc	ra,0xffffe
    80003384:	2e8080e7          	jalr	744(ra) # 80001668 <copyout>
    return -1;
    80003388:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000338a:	02054063          	bltz	a0,800033aa <sys_waitx+0x8e>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    8000338e:	4691                	li	a3,4
    80003390:	fc040613          	addi	a2,s0,-64
    80003394:	fc843583          	ld	a1,-56(s0)
    80003398:	1584b503          	ld	a0,344(s1)
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	2cc080e7          	jalr	716(ra) # 80001668 <copyout>
    800033a4:	00054a63          	bltz	a0,800033b8 <sys_waitx+0x9c>
    return -1;
  return ret;
    800033a8:	87ca                	mv	a5,s2
}
    800033aa:	853e                	mv	a0,a5
    800033ac:	70e2                	ld	ra,56(sp)
    800033ae:	7442                	ld	s0,48(sp)
    800033b0:	74a2                	ld	s1,40(sp)
    800033b2:	7902                	ld	s2,32(sp)
    800033b4:	6121                	addi	sp,sp,64
    800033b6:	8082                	ret
    return -1;
    800033b8:	57fd                	li	a5,-1
    800033ba:	bfc5                	j	800033aa <sys_waitx+0x8e>

00000000800033bc <sys_getSysCount>:
//   }

//   return -1;
// }

uint64 sys_getSysCount(void){
    800033bc:	7179                	addi	sp,sp,-48
    800033be:	f406                	sd	ra,40(sp)
    800033c0:	f022                	sd	s0,32(sp)
    800033c2:	ec26                	sd	s1,24(sp)
    800033c4:	1800                	addi	s0,sp,48

  struct proc *p = myproc();
    800033c6:	ffffe097          	auipc	ra,0xffffe
    800033ca:	602080e7          	jalr	1538(ra) # 800019c8 <myproc>
    800033ce:	84aa                	mv	s1,a0

  // int arg1;  // Variable to store the argument (arg[1])
  int arg1;
    
    // Fetch the first argument passed to the syscall (arg[1])
    argint(0, &arg1);
    800033d0:	fdc40593          	addi	a1,s0,-36
    800033d4:	4501                	li	a0,0
    800033d6:	00000097          	auipc	ra,0x0
    800033da:	a74080e7          	jalr	-1420(ra) # 80002e4a <argint>
  //   position++;
  // }

  // int mask = position;
  // printf("sysnum value in sysproc.c : %d\n",sysnum);
  p->yo = arg1;
    800033de:	fdc42783          	lw	a5,-36(s0)
    800033e2:	0cf4a223          	sw	a5,196(s1)
  // printf("Masked value of arg1 assigned to p->yo: %d\n", p->yo);
  

  // printf("p->yo %d\n", p->yo);
  // p->yo = 15;
  if (p->yo == 1) {
    800033e6:	4705                	li	a4,1
    800033e8:	0ae78163          	beq	a5,a4,8000348a <sys_getSysCount+0xce>
        return p->forkcount;
    } else if (p->yo == 2) {
    800033ec:	4709                	li	a4,2
    800033ee:	0ae78463          	beq	a5,a4,80003496 <sys_getSysCount+0xda>
        return p->exitcount;
    } else if (p->yo == 3) {
    800033f2:	470d                	li	a4,3
    800033f4:	0ae78363          	beq	a5,a4,8000349a <sys_getSysCount+0xde>
        return p->waitcount;
    } else if (p->yo == 4) {
    800033f8:	4711                	li	a4,4
    800033fa:	0ae78263          	beq	a5,a4,8000349e <sys_getSysCount+0xe2>
        return p->pipecount;
    } else if (p->yo == 5) {
    800033fe:	4715                	li	a4,5
    80003400:	0ae78263          	beq	a5,a4,800034a4 <sys_getSysCount+0xe8>
        return p->readcount;
    } else if (p->yo == 6) {
    80003404:	4719                	li	a4,6
    80003406:	0ae78163          	beq	a5,a4,800034a8 <sys_getSysCount+0xec>
        return p->killcount;
    } else if (p->yo == 7) {
    8000340a:	471d                	li	a4,7
    8000340c:	0ae78063          	beq	a5,a4,800034ac <sys_getSysCount+0xf0>
        return p->execcount;
    } else if (p->yo == 8) {
    80003410:	4721                	li	a4,8
    80003412:	0ae78063          	beq	a5,a4,800034b2 <sys_getSysCount+0xf6>
        return p->fstatcount;
    } else if (p->yo == 9) {
    80003416:	4725                	li	a4,9
    80003418:	0ae78063          	beq	a5,a4,800034b8 <sys_getSysCount+0xfc>
        return p->chdircount;
    } else if (p->yo == 10) {
    8000341c:	4729                	li	a4,10
    8000341e:	0ae78063          	beq	a5,a4,800034be <sys_getSysCount+0x102>
        return p->dupcount;
    } else if (p->yo == 11) {
    80003422:	472d                	li	a4,11
    80003424:	0ae78063          	beq	a5,a4,800034c4 <sys_getSysCount+0x108>
        return p->getpidcount;
    } else if (p->yo == 12) {
    80003428:	4731                	li	a4,12
    8000342a:	0ae78063          	beq	a5,a4,800034ca <sys_getSysCount+0x10e>
        return p->sbrkcount;
    } else if (p->yo == 13) {
    8000342e:	4735                	li	a4,13
    80003430:	0ae78063          	beq	a5,a4,800034d0 <sys_getSysCount+0x114>
        return p->sleepcount;
    } else if (p->yo == 14) {
    80003434:	4739                	li	a4,14
    80003436:	08e78f63          	beq	a5,a4,800034d4 <sys_getSysCount+0x118>
        return p->uptimecount;
    } else if (p->yo == 15) {
    8000343a:	473d                	li	a4,15
    8000343c:	08e78e63          	beq	a5,a4,800034d8 <sys_getSysCount+0x11c>
      // printf("pid of p %d\n", p->pid);
        return p->opencount;
    } else if (p->yo == 16) {
    80003440:	4741                	li	a4,16
    80003442:	08e78e63          	beq	a5,a4,800034de <sys_getSysCount+0x122>
        return p->writecount;
    } else if (p->yo == 17) {
    80003446:	4745                	li	a4,17
    80003448:	08e78d63          	beq	a5,a4,800034e2 <sys_getSysCount+0x126>
        return p->mknodcount;
    } else if (p->yo == 18) {
    8000344c:	4749                	li	a4,18
    8000344e:	08e78d63          	beq	a5,a4,800034e8 <sys_getSysCount+0x12c>
        return p->unlinkcount;
    } else if (p->yo == 19) {
    80003452:	474d                	li	a4,19
    80003454:	08e78d63          	beq	a5,a4,800034ee <sys_getSysCount+0x132>
        return p->linkcount;
    } else if (p->yo == 20) {
    80003458:	4751                	li	a4,20
    8000345a:	08e78d63          	beq	a5,a4,800034f4 <sys_getSysCount+0x138>
        return p->mkdircount;
    } else if (p->yo == 21) {
    8000345e:	4755                	li	a4,21
    80003460:	08e78d63          	beq	a5,a4,800034fa <sys_getSysCount+0x13e>
        return p->closecount;
    } else if (p->yo == 22) {
    80003464:	4759                	li	a4,22
    80003466:	08e78d63          	beq	a5,a4,80003500 <sys_getSysCount+0x144>
        return p->waitxcount;
    } else if (p->yo == 23) {
    8000346a:	475d                	li	a4,23
    8000346c:	08e78d63          	beq	a5,a4,80003506 <sys_getSysCount+0x14a>
        return p->getSysCountcount;
    } else if (p->yo == 24) {
    80003470:	4761                	li	a4,24
    80003472:	08e78d63          	beq	a5,a4,8000350c <sys_getSysCount+0x150>
        return p->sigalarmcount;
    } else if (p->yo == 25) {
    80003476:	4765                	li	a4,25
    80003478:	08e78c63          	beq	a5,a4,80003510 <sys_getSysCount+0x154>
        return p->sigreturncount;
    } else if (p->yo == 26) {
    8000347c:	4769                	li	a4,26
        return p->setticketscount;
    } 

    // If p->yo is not recognized, return 0 or an appropriate error value
    return 0;
    8000347e:	4501                	li	a0,0
    } else if (p->yo == 26) {
    80003480:	00e79663          	bne	a5,a4,8000348c <sys_getSysCount+0xd0>
        return p->setticketscount;
    80003484:	0c04a503          	lw	a0,192(s1)
    80003488:	a011                	j	8000348c <sys_getSysCount+0xd0>
        return p->forkcount;
    8000348a:	50e8                	lw	a0,100(s1)

}
    8000348c:	70a2                	ld	ra,40(sp)
    8000348e:	7402                	ld	s0,32(sp)
    80003490:	64e2                	ld	s1,24(sp)
    80003492:	6145                	addi	sp,sp,48
    80003494:	8082                	ret
        return p->exitcount;
    80003496:	54a8                	lw	a0,104(s1)
    80003498:	bfd5                	j	8000348c <sys_getSysCount+0xd0>
        return p->waitcount;
    8000349a:	54e8                	lw	a0,108(s1)
    8000349c:	bfc5                	j	8000348c <sys_getSysCount+0xd0>
        return p->pipecount;
    8000349e:	0b44a503          	lw	a0,180(s1)
    800034a2:	b7ed                	j	8000348c <sys_getSysCount+0xd0>
        return p->readcount;
    800034a4:	4ce8                	lw	a0,92(s1)
    800034a6:	b7dd                	j	8000348c <sys_getSysCount+0xd0>
        return p->killcount;
    800034a8:	5ca8                	lw	a0,120(s1)
    800034aa:	b7cd                	j	8000348c <sys_getSysCount+0xd0>
        return p->execcount;
    800034ac:	0b84a503          	lw	a0,184(s1)
    800034b0:	bff1                	j	8000348c <sys_getSysCount+0xd0>
        return p->fstatcount;
    800034b2:	0bc4a503          	lw	a0,188(s1)
    800034b6:	bfd9                	j	8000348c <sys_getSysCount+0xd0>
        return p->chdircount;
    800034b8:	0844a503          	lw	a0,132(s1)
    800034bc:	bfc1                	j	8000348c <sys_getSysCount+0xd0>
        return p->dupcount;
    800034be:	0884a503          	lw	a0,136(s1)
    800034c2:	b7e9                	j	8000348c <sys_getSysCount+0xd0>
        return p->getpidcount;
    800034c4:	08c4a503          	lw	a0,140(s1)
    800034c8:	b7d1                	j	8000348c <sys_getSysCount+0xd0>
        return p->sbrkcount;
    800034ca:	0904a503          	lw	a0,144(s1)
    800034ce:	bf7d                	j	8000348c <sys_getSysCount+0xd0>
        return p->sleepcount;
    800034d0:	58a8                	lw	a0,112(s1)
    800034d2:	bf6d                	j	8000348c <sys_getSysCount+0xd0>
        return p->uptimecount;
    800034d4:	58e8                	lw	a0,116(s1)
    800034d6:	bf5d                	j	8000348c <sys_getSysCount+0xd0>
        return p->opencount;
    800034d8:	0944a503          	lw	a0,148(s1)
    800034dc:	bf45                	j	8000348c <sys_getSysCount+0xd0>
        return p->writecount;
    800034de:	50a8                	lw	a0,96(s1)
    800034e0:	b775                	j	8000348c <sys_getSysCount+0xd0>
        return p->mknodcount;
    800034e2:	0984a503          	lw	a0,152(s1)
    800034e6:	b75d                	j	8000348c <sys_getSysCount+0xd0>
        return p->unlinkcount;
    800034e8:	09c4a503          	lw	a0,156(s1)
    800034ec:	b745                	j	8000348c <sys_getSysCount+0xd0>
        return p->linkcount;
    800034ee:	0a04a503          	lw	a0,160(s1)
    800034f2:	bf69                	j	8000348c <sys_getSysCount+0xd0>
        return p->mkdircount;
    800034f4:	0a44a503          	lw	a0,164(s1)
    800034f8:	bf51                	j	8000348c <sys_getSysCount+0xd0>
        return p->closecount;
    800034fa:	0a84a503          	lw	a0,168(s1)
    800034fe:	b779                	j	8000348c <sys_getSysCount+0xd0>
        return p->waitxcount;
    80003500:	0ac4a503          	lw	a0,172(s1)
    80003504:	b761                	j	8000348c <sys_getSysCount+0xd0>
        return p->getSysCountcount;
    80003506:	0b04a503          	lw	a0,176(s1)
    8000350a:	b749                	j	8000348c <sys_getSysCount+0xd0>
        return p->sigalarmcount;
    8000350c:	5ce8                	lw	a0,124(s1)
    8000350e:	bfbd                	j	8000348c <sys_getSysCount+0xd0>
        return p->sigreturncount;
    80003510:	0804a503          	lw	a0,128(s1)
    80003514:	bfa5                	j	8000348c <sys_getSysCount+0xd0>

0000000080003516 <sys_sigalarm>:

uint64 sys_sigalarm(void)
{
    80003516:	1101                	addi	sp,sp,-32
    80003518:	ec06                	sd	ra,24(sp)
    8000351a:	e822                	sd	s0,16(sp)
    8000351c:	1000                	addi	s0,sp,32
  uint64 addr;
  int ticks;

  argint(0, &ticks);
    8000351e:	fe440593          	addi	a1,s0,-28
    80003522:	4501                	li	a0,0
    80003524:	00000097          	auipc	ra,0x0
    80003528:	926080e7          	jalr	-1754(ra) # 80002e4a <argint>
  argaddr(1, &addr);
    8000352c:	fe840593          	addi	a1,s0,-24
    80003530:	4505                	li	a0,1
    80003532:	00000097          	auipc	ra,0x0
    80003536:	938080e7          	jalr	-1736(ra) # 80002e6a <argaddr>
  // if(argaddr(1, &addr) < 0)
  //   return -1;

  // myproc()->ticks = ticks;
  // myproc()->handler = addr;
  struct proc *p = myproc();
    8000353a:	ffffe097          	auipc	ra,0xffffe
    8000353e:	48e080e7          	jalr	1166(ra) # 800019c8 <myproc>
  p->ticks = ticks;
    80003542:	fe442783          	lw	a5,-28(s0)
    80003546:	c53c                	sw	a5,72(a0)
  p->handler = addr;
    80003548:	fe843783          	ld	a5,-24(s0)
    8000354c:	e13c                	sd	a5,64(a0)

  // printf("sys_sigalarm: ticks=%d, handler=%p\n", ticks, addr); // Debugging statement

  return 0;
}
    8000354e:	4501                	li	a0,0
    80003550:	60e2                	ld	ra,24(sp)
    80003552:	6442                	ld	s0,16(sp)
    80003554:	6105                	addi	sp,sp,32
    80003556:	8082                	ret

0000000080003558 <sys_sigreturn>:

uint64 sys_sigreturn(void)
{
    80003558:	1101                	addi	sp,sp,-32
    8000355a:	ec06                	sd	ra,24(sp)
    8000355c:	e822                	sd	s0,16(sp)
    8000355e:	e426                	sd	s1,8(sp)
    80003560:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003562:	ffffe097          	auipc	ra,0xffffe
    80003566:	466080e7          	jalr	1126(ra) # 800019c8 <myproc>
  if (p->alarm_tf == 0)
    8000356a:	692c                	ld	a1,80(a0)
    8000356c:	cd9d                	beqz	a1,800035aa <sys_sigreturn+0x52>
    8000356e:	84aa                	mv	s1,a0
    return -1; // No saved trap frame
  // printf("sys_sigreturn: restoring trapframe\n"); // Debugging statement
  memmove(p->trapframe, p->alarm_tf, sizeof(struct trapframe));
    80003570:	12000613          	li	a2,288
    80003574:	16053503          	ld	a0,352(a0)
    80003578:	ffffd097          	auipc	ra,0xffffd
    8000357c:	7b6080e7          	jalr	1974(ra) # 80000d2e <memmove>

  kfree(p->alarm_tf);
    80003580:	68a8                	ld	a0,80(s1)
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	468080e7          	jalr	1128(ra) # 800009ea <kfree>
  p->alarm_tf = 0;
    8000358a:	0404b823          	sd	zero,80(s1)
  p->alarm_on = 0;
    8000358e:	0404ac23          	sw	zero,88(s1)
  p->cur_ticks = 0;
    80003592:	0404a623          	sw	zero,76(s1)
  usertrapret();
    80003596:	fffff097          	auipc	ra,0xfffff
    8000359a:	3ba080e7          	jalr	954(ra) # 80002950 <usertrapret>
  return 0;
    8000359e:	4501                	li	a0,0
}
    800035a0:	60e2                	ld	ra,24(sp)
    800035a2:	6442                	ld	s0,16(sp)
    800035a4:	64a2                	ld	s1,8(sp)
    800035a6:	6105                	addi	sp,sp,32
    800035a8:	8082                	ret
    return -1; // No saved trap frame
    800035aa:	557d                	li	a0,-1
    800035ac:	bfd5                	j	800035a0 <sys_sigreturn+0x48>

00000000800035ae <sys_settickets>:

int sys_settickets(int n){
    800035ae:	7179                	addi	sp,sp,-48
    800035b0:	f406                	sd	ra,40(sp)
    800035b2:	f022                	sd	s0,32(sp)
    800035b4:	ec26                	sd	s1,24(sp)
    800035b6:	1800                	addi	s0,sp,48
    800035b8:	fca42e23          	sw	a0,-36(s0)
  // int n;
  argint(0, &n);
    800035bc:	fdc40593          	addi	a1,s0,-36
    800035c0:	4501                	li	a0,0
    800035c2:	00000097          	auipc	ra,0x0
    800035c6:	888080e7          	jalr	-1912(ra) # 80002e4a <argint>
  if(n < 1)
    800035ca:	fdc42783          	lw	a5,-36(s0)
    800035ce:	02f05b63          	blez	a5,80003604 <sys_settickets+0x56>
    return -1;
  struct proc *p = myproc();
    800035d2:	ffffe097          	auipc	ra,0xffffe
    800035d6:	3f6080e7          	jalr	1014(ra) # 800019c8 <myproc>
    800035da:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	5fa080e7          	jalr	1530(ra) # 80000bd6 <acquire>
  p->tickets = n;
    800035e4:	fdc42783          	lw	a5,-36(s0)
    800035e8:	12f4a423          	sw	a5,296(s1)
  release(&p->lock);
    800035ec:	8526                	mv	a0,s1
    800035ee:	ffffd097          	auipc	ra,0xffffd
    800035f2:	69c080e7          	jalr	1692(ra) # 80000c8a <release>
  return n;
    800035f6:	fdc42503          	lw	a0,-36(s0)
}
    800035fa:	70a2                	ld	ra,40(sp)
    800035fc:	7402                	ld	s0,32(sp)
    800035fe:	64e2                	ld	s1,24(sp)
    80003600:	6145                	addi	sp,sp,48
    80003602:	8082                	ret
    return -1;
    80003604:	557d                	li	a0,-1
    80003606:	bfd5                	j	800035fa <sys_settickets+0x4c>

0000000080003608 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003608:	7179                	addi	sp,sp,-48
    8000360a:	f406                	sd	ra,40(sp)
    8000360c:	f022                	sd	s0,32(sp)
    8000360e:	ec26                	sd	s1,24(sp)
    80003610:	e84a                	sd	s2,16(sp)
    80003612:	e44e                	sd	s3,8(sp)
    80003614:	e052                	sd	s4,0(sp)
    80003616:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003618:	00005597          	auipc	a1,0x5
    8000361c:	f5058593          	addi	a1,a1,-176 # 80008568 <syscalls+0xd8>
    80003620:	00018517          	auipc	a0,0x18
    80003624:	9c850513          	addi	a0,a0,-1592 # 8001afe8 <bcache>
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	51e080e7          	jalr	1310(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003630:	00020797          	auipc	a5,0x20
    80003634:	9b878793          	addi	a5,a5,-1608 # 80022fe8 <bcache+0x8000>
    80003638:	00020717          	auipc	a4,0x20
    8000363c:	c1870713          	addi	a4,a4,-1000 # 80023250 <bcache+0x8268>
    80003640:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003644:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003648:	00018497          	auipc	s1,0x18
    8000364c:	9b848493          	addi	s1,s1,-1608 # 8001b000 <bcache+0x18>
    b->next = bcache.head.next;
    80003650:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003652:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003654:	00005a17          	auipc	s4,0x5
    80003658:	f1ca0a13          	addi	s4,s4,-228 # 80008570 <syscalls+0xe0>
    b->next = bcache.head.next;
    8000365c:	2b893783          	ld	a5,696(s2)
    80003660:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003662:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003666:	85d2                	mv	a1,s4
    80003668:	01048513          	addi	a0,s1,16
    8000366c:	00001097          	auipc	ra,0x1
    80003670:	4c4080e7          	jalr	1220(ra) # 80004b30 <initsleeplock>
    bcache.head.next->prev = b;
    80003674:	2b893783          	ld	a5,696(s2)
    80003678:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000367a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000367e:	45848493          	addi	s1,s1,1112
    80003682:	fd349de3          	bne	s1,s3,8000365c <binit+0x54>
  }
}
    80003686:	70a2                	ld	ra,40(sp)
    80003688:	7402                	ld	s0,32(sp)
    8000368a:	64e2                	ld	s1,24(sp)
    8000368c:	6942                	ld	s2,16(sp)
    8000368e:	69a2                	ld	s3,8(sp)
    80003690:	6a02                	ld	s4,0(sp)
    80003692:	6145                	addi	sp,sp,48
    80003694:	8082                	ret

0000000080003696 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003696:	7179                	addi	sp,sp,-48
    80003698:	f406                	sd	ra,40(sp)
    8000369a:	f022                	sd	s0,32(sp)
    8000369c:	ec26                	sd	s1,24(sp)
    8000369e:	e84a                	sd	s2,16(sp)
    800036a0:	e44e                	sd	s3,8(sp)
    800036a2:	1800                	addi	s0,sp,48
    800036a4:	892a                	mv	s2,a0
    800036a6:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800036a8:	00018517          	auipc	a0,0x18
    800036ac:	94050513          	addi	a0,a0,-1728 # 8001afe8 <bcache>
    800036b0:	ffffd097          	auipc	ra,0xffffd
    800036b4:	526080e7          	jalr	1318(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800036b8:	00020497          	auipc	s1,0x20
    800036bc:	be84b483          	ld	s1,-1048(s1) # 800232a0 <bcache+0x82b8>
    800036c0:	00020797          	auipc	a5,0x20
    800036c4:	b9078793          	addi	a5,a5,-1136 # 80023250 <bcache+0x8268>
    800036c8:	02f48f63          	beq	s1,a5,80003706 <bread+0x70>
    800036cc:	873e                	mv	a4,a5
    800036ce:	a021                	j	800036d6 <bread+0x40>
    800036d0:	68a4                	ld	s1,80(s1)
    800036d2:	02e48a63          	beq	s1,a4,80003706 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800036d6:	449c                	lw	a5,8(s1)
    800036d8:	ff279ce3          	bne	a5,s2,800036d0 <bread+0x3a>
    800036dc:	44dc                	lw	a5,12(s1)
    800036de:	ff3799e3          	bne	a5,s3,800036d0 <bread+0x3a>
      b->refcnt++;
    800036e2:	40bc                	lw	a5,64(s1)
    800036e4:	2785                	addiw	a5,a5,1
    800036e6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036e8:	00018517          	auipc	a0,0x18
    800036ec:	90050513          	addi	a0,a0,-1792 # 8001afe8 <bcache>
    800036f0:	ffffd097          	auipc	ra,0xffffd
    800036f4:	59a080e7          	jalr	1434(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800036f8:	01048513          	addi	a0,s1,16
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	46e080e7          	jalr	1134(ra) # 80004b6a <acquiresleep>
      return b;
    80003704:	a8b9                	j	80003762 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003706:	00020497          	auipc	s1,0x20
    8000370a:	b924b483          	ld	s1,-1134(s1) # 80023298 <bcache+0x82b0>
    8000370e:	00020797          	auipc	a5,0x20
    80003712:	b4278793          	addi	a5,a5,-1214 # 80023250 <bcache+0x8268>
    80003716:	00f48863          	beq	s1,a5,80003726 <bread+0x90>
    8000371a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000371c:	40bc                	lw	a5,64(s1)
    8000371e:	cf81                	beqz	a5,80003736 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003720:	64a4                	ld	s1,72(s1)
    80003722:	fee49de3          	bne	s1,a4,8000371c <bread+0x86>
  panic("bget: no buffers");
    80003726:	00005517          	auipc	a0,0x5
    8000372a:	e5250513          	addi	a0,a0,-430 # 80008578 <syscalls+0xe8>
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	e10080e7          	jalr	-496(ra) # 8000053e <panic>
      b->dev = dev;
    80003736:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000373a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000373e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003742:	4785                	li	a5,1
    80003744:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003746:	00018517          	auipc	a0,0x18
    8000374a:	8a250513          	addi	a0,a0,-1886 # 8001afe8 <bcache>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	53c080e7          	jalr	1340(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003756:	01048513          	addi	a0,s1,16
    8000375a:	00001097          	auipc	ra,0x1
    8000375e:	410080e7          	jalr	1040(ra) # 80004b6a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003762:	409c                	lw	a5,0(s1)
    80003764:	cb89                	beqz	a5,80003776 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003766:	8526                	mv	a0,s1
    80003768:	70a2                	ld	ra,40(sp)
    8000376a:	7402                	ld	s0,32(sp)
    8000376c:	64e2                	ld	s1,24(sp)
    8000376e:	6942                	ld	s2,16(sp)
    80003770:	69a2                	ld	s3,8(sp)
    80003772:	6145                	addi	sp,sp,48
    80003774:	8082                	ret
    virtio_disk_rw(b, 0);
    80003776:	4581                	li	a1,0
    80003778:	8526                	mv	a0,s1
    8000377a:	00003097          	auipc	ra,0x3
    8000377e:	fea080e7          	jalr	-22(ra) # 80006764 <virtio_disk_rw>
    b->valid = 1;
    80003782:	4785                	li	a5,1
    80003784:	c09c                	sw	a5,0(s1)
  return b;
    80003786:	b7c5                	j	80003766 <bread+0xd0>

0000000080003788 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003788:	1101                	addi	sp,sp,-32
    8000378a:	ec06                	sd	ra,24(sp)
    8000378c:	e822                	sd	s0,16(sp)
    8000378e:	e426                	sd	s1,8(sp)
    80003790:	1000                	addi	s0,sp,32
    80003792:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003794:	0541                	addi	a0,a0,16
    80003796:	00001097          	auipc	ra,0x1
    8000379a:	46e080e7          	jalr	1134(ra) # 80004c04 <holdingsleep>
    8000379e:	cd01                	beqz	a0,800037b6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800037a0:	4585                	li	a1,1
    800037a2:	8526                	mv	a0,s1
    800037a4:	00003097          	auipc	ra,0x3
    800037a8:	fc0080e7          	jalr	-64(ra) # 80006764 <virtio_disk_rw>
}
    800037ac:	60e2                	ld	ra,24(sp)
    800037ae:	6442                	ld	s0,16(sp)
    800037b0:	64a2                	ld	s1,8(sp)
    800037b2:	6105                	addi	sp,sp,32
    800037b4:	8082                	ret
    panic("bwrite");
    800037b6:	00005517          	auipc	a0,0x5
    800037ba:	dda50513          	addi	a0,a0,-550 # 80008590 <syscalls+0x100>
    800037be:	ffffd097          	auipc	ra,0xffffd
    800037c2:	d80080e7          	jalr	-640(ra) # 8000053e <panic>

00000000800037c6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800037c6:	1101                	addi	sp,sp,-32
    800037c8:	ec06                	sd	ra,24(sp)
    800037ca:	e822                	sd	s0,16(sp)
    800037cc:	e426                	sd	s1,8(sp)
    800037ce:	e04a                	sd	s2,0(sp)
    800037d0:	1000                	addi	s0,sp,32
    800037d2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800037d4:	01050913          	addi	s2,a0,16
    800037d8:	854a                	mv	a0,s2
    800037da:	00001097          	auipc	ra,0x1
    800037de:	42a080e7          	jalr	1066(ra) # 80004c04 <holdingsleep>
    800037e2:	c92d                	beqz	a0,80003854 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800037e4:	854a                	mv	a0,s2
    800037e6:	00001097          	auipc	ra,0x1
    800037ea:	3da080e7          	jalr	986(ra) # 80004bc0 <releasesleep>

  acquire(&bcache.lock);
    800037ee:	00017517          	auipc	a0,0x17
    800037f2:	7fa50513          	addi	a0,a0,2042 # 8001afe8 <bcache>
    800037f6:	ffffd097          	auipc	ra,0xffffd
    800037fa:	3e0080e7          	jalr	992(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800037fe:	40bc                	lw	a5,64(s1)
    80003800:	37fd                	addiw	a5,a5,-1
    80003802:	0007871b          	sext.w	a4,a5
    80003806:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003808:	eb05                	bnez	a4,80003838 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000380a:	68bc                	ld	a5,80(s1)
    8000380c:	64b8                	ld	a4,72(s1)
    8000380e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003810:	64bc                	ld	a5,72(s1)
    80003812:	68b8                	ld	a4,80(s1)
    80003814:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003816:	0001f797          	auipc	a5,0x1f
    8000381a:	7d278793          	addi	a5,a5,2002 # 80022fe8 <bcache+0x8000>
    8000381e:	2b87b703          	ld	a4,696(a5)
    80003822:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003824:	00020717          	auipc	a4,0x20
    80003828:	a2c70713          	addi	a4,a4,-1492 # 80023250 <bcache+0x8268>
    8000382c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000382e:	2b87b703          	ld	a4,696(a5)
    80003832:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003834:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003838:	00017517          	auipc	a0,0x17
    8000383c:	7b050513          	addi	a0,a0,1968 # 8001afe8 <bcache>
    80003840:	ffffd097          	auipc	ra,0xffffd
    80003844:	44a080e7          	jalr	1098(ra) # 80000c8a <release>
}
    80003848:	60e2                	ld	ra,24(sp)
    8000384a:	6442                	ld	s0,16(sp)
    8000384c:	64a2                	ld	s1,8(sp)
    8000384e:	6902                	ld	s2,0(sp)
    80003850:	6105                	addi	sp,sp,32
    80003852:	8082                	ret
    panic("brelse");
    80003854:	00005517          	auipc	a0,0x5
    80003858:	d4450513          	addi	a0,a0,-700 # 80008598 <syscalls+0x108>
    8000385c:	ffffd097          	auipc	ra,0xffffd
    80003860:	ce2080e7          	jalr	-798(ra) # 8000053e <panic>

0000000080003864 <bpin>:

void
bpin(struct buf *b) {
    80003864:	1101                	addi	sp,sp,-32
    80003866:	ec06                	sd	ra,24(sp)
    80003868:	e822                	sd	s0,16(sp)
    8000386a:	e426                	sd	s1,8(sp)
    8000386c:	1000                	addi	s0,sp,32
    8000386e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003870:	00017517          	auipc	a0,0x17
    80003874:	77850513          	addi	a0,a0,1912 # 8001afe8 <bcache>
    80003878:	ffffd097          	auipc	ra,0xffffd
    8000387c:	35e080e7          	jalr	862(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003880:	40bc                	lw	a5,64(s1)
    80003882:	2785                	addiw	a5,a5,1
    80003884:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003886:	00017517          	auipc	a0,0x17
    8000388a:	76250513          	addi	a0,a0,1890 # 8001afe8 <bcache>
    8000388e:	ffffd097          	auipc	ra,0xffffd
    80003892:	3fc080e7          	jalr	1020(ra) # 80000c8a <release>
}
    80003896:	60e2                	ld	ra,24(sp)
    80003898:	6442                	ld	s0,16(sp)
    8000389a:	64a2                	ld	s1,8(sp)
    8000389c:	6105                	addi	sp,sp,32
    8000389e:	8082                	ret

00000000800038a0 <bunpin>:

void
bunpin(struct buf *b) {
    800038a0:	1101                	addi	sp,sp,-32
    800038a2:	ec06                	sd	ra,24(sp)
    800038a4:	e822                	sd	s0,16(sp)
    800038a6:	e426                	sd	s1,8(sp)
    800038a8:	1000                	addi	s0,sp,32
    800038aa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800038ac:	00017517          	auipc	a0,0x17
    800038b0:	73c50513          	addi	a0,a0,1852 # 8001afe8 <bcache>
    800038b4:	ffffd097          	auipc	ra,0xffffd
    800038b8:	322080e7          	jalr	802(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800038bc:	40bc                	lw	a5,64(s1)
    800038be:	37fd                	addiw	a5,a5,-1
    800038c0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800038c2:	00017517          	auipc	a0,0x17
    800038c6:	72650513          	addi	a0,a0,1830 # 8001afe8 <bcache>
    800038ca:	ffffd097          	auipc	ra,0xffffd
    800038ce:	3c0080e7          	jalr	960(ra) # 80000c8a <release>
}
    800038d2:	60e2                	ld	ra,24(sp)
    800038d4:	6442                	ld	s0,16(sp)
    800038d6:	64a2                	ld	s1,8(sp)
    800038d8:	6105                	addi	sp,sp,32
    800038da:	8082                	ret

00000000800038dc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800038dc:	1101                	addi	sp,sp,-32
    800038de:	ec06                	sd	ra,24(sp)
    800038e0:	e822                	sd	s0,16(sp)
    800038e2:	e426                	sd	s1,8(sp)
    800038e4:	e04a                	sd	s2,0(sp)
    800038e6:	1000                	addi	s0,sp,32
    800038e8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800038ea:	00d5d59b          	srliw	a1,a1,0xd
    800038ee:	00020797          	auipc	a5,0x20
    800038f2:	dd67a783          	lw	a5,-554(a5) # 800236c4 <sb+0x1c>
    800038f6:	9dbd                	addw	a1,a1,a5
    800038f8:	00000097          	auipc	ra,0x0
    800038fc:	d9e080e7          	jalr	-610(ra) # 80003696 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003900:	0074f713          	andi	a4,s1,7
    80003904:	4785                	li	a5,1
    80003906:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000390a:	14ce                	slli	s1,s1,0x33
    8000390c:	90d9                	srli	s1,s1,0x36
    8000390e:	00950733          	add	a4,a0,s1
    80003912:	05874703          	lbu	a4,88(a4)
    80003916:	00e7f6b3          	and	a3,a5,a4
    8000391a:	c69d                	beqz	a3,80003948 <bfree+0x6c>
    8000391c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000391e:	94aa                	add	s1,s1,a0
    80003920:	fff7c793          	not	a5,a5
    80003924:	8ff9                	and	a5,a5,a4
    80003926:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000392a:	00001097          	auipc	ra,0x1
    8000392e:	120080e7          	jalr	288(ra) # 80004a4a <log_write>
  brelse(bp);
    80003932:	854a                	mv	a0,s2
    80003934:	00000097          	auipc	ra,0x0
    80003938:	e92080e7          	jalr	-366(ra) # 800037c6 <brelse>
}
    8000393c:	60e2                	ld	ra,24(sp)
    8000393e:	6442                	ld	s0,16(sp)
    80003940:	64a2                	ld	s1,8(sp)
    80003942:	6902                	ld	s2,0(sp)
    80003944:	6105                	addi	sp,sp,32
    80003946:	8082                	ret
    panic("freeing free block");
    80003948:	00005517          	auipc	a0,0x5
    8000394c:	c5850513          	addi	a0,a0,-936 # 800085a0 <syscalls+0x110>
    80003950:	ffffd097          	auipc	ra,0xffffd
    80003954:	bee080e7          	jalr	-1042(ra) # 8000053e <panic>

0000000080003958 <balloc>:
{
    80003958:	711d                	addi	sp,sp,-96
    8000395a:	ec86                	sd	ra,88(sp)
    8000395c:	e8a2                	sd	s0,80(sp)
    8000395e:	e4a6                	sd	s1,72(sp)
    80003960:	e0ca                	sd	s2,64(sp)
    80003962:	fc4e                	sd	s3,56(sp)
    80003964:	f852                	sd	s4,48(sp)
    80003966:	f456                	sd	s5,40(sp)
    80003968:	f05a                	sd	s6,32(sp)
    8000396a:	ec5e                	sd	s7,24(sp)
    8000396c:	e862                	sd	s8,16(sp)
    8000396e:	e466                	sd	s9,8(sp)
    80003970:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003972:	00020797          	auipc	a5,0x20
    80003976:	d3a7a783          	lw	a5,-710(a5) # 800236ac <sb+0x4>
    8000397a:	10078163          	beqz	a5,80003a7c <balloc+0x124>
    8000397e:	8baa                	mv	s7,a0
    80003980:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003982:	00020b17          	auipc	s6,0x20
    80003986:	d26b0b13          	addi	s6,s6,-730 # 800236a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000398a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000398c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000398e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003990:	6c89                	lui	s9,0x2
    80003992:	a061                	j	80003a1a <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003994:	974a                	add	a4,a4,s2
    80003996:	8fd5                	or	a5,a5,a3
    80003998:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000399c:	854a                	mv	a0,s2
    8000399e:	00001097          	auipc	ra,0x1
    800039a2:	0ac080e7          	jalr	172(ra) # 80004a4a <log_write>
        brelse(bp);
    800039a6:	854a                	mv	a0,s2
    800039a8:	00000097          	auipc	ra,0x0
    800039ac:	e1e080e7          	jalr	-482(ra) # 800037c6 <brelse>
  bp = bread(dev, bno);
    800039b0:	85a6                	mv	a1,s1
    800039b2:	855e                	mv	a0,s7
    800039b4:	00000097          	auipc	ra,0x0
    800039b8:	ce2080e7          	jalr	-798(ra) # 80003696 <bread>
    800039bc:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800039be:	40000613          	li	a2,1024
    800039c2:	4581                	li	a1,0
    800039c4:	05850513          	addi	a0,a0,88
    800039c8:	ffffd097          	auipc	ra,0xffffd
    800039cc:	30a080e7          	jalr	778(ra) # 80000cd2 <memset>
  log_write(bp);
    800039d0:	854a                	mv	a0,s2
    800039d2:	00001097          	auipc	ra,0x1
    800039d6:	078080e7          	jalr	120(ra) # 80004a4a <log_write>
  brelse(bp);
    800039da:	854a                	mv	a0,s2
    800039dc:	00000097          	auipc	ra,0x0
    800039e0:	dea080e7          	jalr	-534(ra) # 800037c6 <brelse>
}
    800039e4:	8526                	mv	a0,s1
    800039e6:	60e6                	ld	ra,88(sp)
    800039e8:	6446                	ld	s0,80(sp)
    800039ea:	64a6                	ld	s1,72(sp)
    800039ec:	6906                	ld	s2,64(sp)
    800039ee:	79e2                	ld	s3,56(sp)
    800039f0:	7a42                	ld	s4,48(sp)
    800039f2:	7aa2                	ld	s5,40(sp)
    800039f4:	7b02                	ld	s6,32(sp)
    800039f6:	6be2                	ld	s7,24(sp)
    800039f8:	6c42                	ld	s8,16(sp)
    800039fa:	6ca2                	ld	s9,8(sp)
    800039fc:	6125                	addi	sp,sp,96
    800039fe:	8082                	ret
    brelse(bp);
    80003a00:	854a                	mv	a0,s2
    80003a02:	00000097          	auipc	ra,0x0
    80003a06:	dc4080e7          	jalr	-572(ra) # 800037c6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003a0a:	015c87bb          	addw	a5,s9,s5
    80003a0e:	00078a9b          	sext.w	s5,a5
    80003a12:	004b2703          	lw	a4,4(s6)
    80003a16:	06eaf363          	bgeu	s5,a4,80003a7c <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003a1a:	41fad79b          	sraiw	a5,s5,0x1f
    80003a1e:	0137d79b          	srliw	a5,a5,0x13
    80003a22:	015787bb          	addw	a5,a5,s5
    80003a26:	40d7d79b          	sraiw	a5,a5,0xd
    80003a2a:	01cb2583          	lw	a1,28(s6)
    80003a2e:	9dbd                	addw	a1,a1,a5
    80003a30:	855e                	mv	a0,s7
    80003a32:	00000097          	auipc	ra,0x0
    80003a36:	c64080e7          	jalr	-924(ra) # 80003696 <bread>
    80003a3a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a3c:	004b2503          	lw	a0,4(s6)
    80003a40:	000a849b          	sext.w	s1,s5
    80003a44:	8662                	mv	a2,s8
    80003a46:	faa4fde3          	bgeu	s1,a0,80003a00 <balloc+0xa8>
      m = 1 << (bi % 8);
    80003a4a:	41f6579b          	sraiw	a5,a2,0x1f
    80003a4e:	01d7d69b          	srliw	a3,a5,0x1d
    80003a52:	00c6873b          	addw	a4,a3,a2
    80003a56:	00777793          	andi	a5,a4,7
    80003a5a:	9f95                	subw	a5,a5,a3
    80003a5c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003a60:	4037571b          	sraiw	a4,a4,0x3
    80003a64:	00e906b3          	add	a3,s2,a4
    80003a68:	0586c683          	lbu	a3,88(a3)
    80003a6c:	00d7f5b3          	and	a1,a5,a3
    80003a70:	d195                	beqz	a1,80003994 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003a72:	2605                	addiw	a2,a2,1
    80003a74:	2485                	addiw	s1,s1,1
    80003a76:	fd4618e3          	bne	a2,s4,80003a46 <balloc+0xee>
    80003a7a:	b759                	j	80003a00 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003a7c:	00005517          	auipc	a0,0x5
    80003a80:	b3c50513          	addi	a0,a0,-1220 # 800085b8 <syscalls+0x128>
    80003a84:	ffffd097          	auipc	ra,0xffffd
    80003a88:	b04080e7          	jalr	-1276(ra) # 80000588 <printf>
  return 0;
    80003a8c:	4481                	li	s1,0
    80003a8e:	bf99                	j	800039e4 <balloc+0x8c>

0000000080003a90 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a90:	7179                	addi	sp,sp,-48
    80003a92:	f406                	sd	ra,40(sp)
    80003a94:	f022                	sd	s0,32(sp)
    80003a96:	ec26                	sd	s1,24(sp)
    80003a98:	e84a                	sd	s2,16(sp)
    80003a9a:	e44e                	sd	s3,8(sp)
    80003a9c:	e052                	sd	s4,0(sp)
    80003a9e:	1800                	addi	s0,sp,48
    80003aa0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003aa2:	47ad                	li	a5,11
    80003aa4:	02b7e763          	bltu	a5,a1,80003ad2 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003aa8:	02059493          	slli	s1,a1,0x20
    80003aac:	9081                	srli	s1,s1,0x20
    80003aae:	048a                	slli	s1,s1,0x2
    80003ab0:	94aa                	add	s1,s1,a0
    80003ab2:	0504a903          	lw	s2,80(s1)
    80003ab6:	06091e63          	bnez	s2,80003b32 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003aba:	4108                	lw	a0,0(a0)
    80003abc:	00000097          	auipc	ra,0x0
    80003ac0:	e9c080e7          	jalr	-356(ra) # 80003958 <balloc>
    80003ac4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003ac8:	06090563          	beqz	s2,80003b32 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003acc:	0524a823          	sw	s2,80(s1)
    80003ad0:	a08d                	j	80003b32 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003ad2:	ff45849b          	addiw	s1,a1,-12
    80003ad6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003ada:	0ff00793          	li	a5,255
    80003ade:	08e7e563          	bltu	a5,a4,80003b68 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003ae2:	08052903          	lw	s2,128(a0)
    80003ae6:	00091d63          	bnez	s2,80003b00 <bmap+0x70>
      addr = balloc(ip->dev);
    80003aea:	4108                	lw	a0,0(a0)
    80003aec:	00000097          	auipc	ra,0x0
    80003af0:	e6c080e7          	jalr	-404(ra) # 80003958 <balloc>
    80003af4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003af8:	02090d63          	beqz	s2,80003b32 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003afc:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003b00:	85ca                	mv	a1,s2
    80003b02:	0009a503          	lw	a0,0(s3)
    80003b06:	00000097          	auipc	ra,0x0
    80003b0a:	b90080e7          	jalr	-1136(ra) # 80003696 <bread>
    80003b0e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003b10:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003b14:	02049593          	slli	a1,s1,0x20
    80003b18:	9181                	srli	a1,a1,0x20
    80003b1a:	058a                	slli	a1,a1,0x2
    80003b1c:	00b784b3          	add	s1,a5,a1
    80003b20:	0004a903          	lw	s2,0(s1)
    80003b24:	02090063          	beqz	s2,80003b44 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003b28:	8552                	mv	a0,s4
    80003b2a:	00000097          	auipc	ra,0x0
    80003b2e:	c9c080e7          	jalr	-868(ra) # 800037c6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003b32:	854a                	mv	a0,s2
    80003b34:	70a2                	ld	ra,40(sp)
    80003b36:	7402                	ld	s0,32(sp)
    80003b38:	64e2                	ld	s1,24(sp)
    80003b3a:	6942                	ld	s2,16(sp)
    80003b3c:	69a2                	ld	s3,8(sp)
    80003b3e:	6a02                	ld	s4,0(sp)
    80003b40:	6145                	addi	sp,sp,48
    80003b42:	8082                	ret
      addr = balloc(ip->dev);
    80003b44:	0009a503          	lw	a0,0(s3)
    80003b48:	00000097          	auipc	ra,0x0
    80003b4c:	e10080e7          	jalr	-496(ra) # 80003958 <balloc>
    80003b50:	0005091b          	sext.w	s2,a0
      if(addr){
    80003b54:	fc090ae3          	beqz	s2,80003b28 <bmap+0x98>
        a[bn] = addr;
    80003b58:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003b5c:	8552                	mv	a0,s4
    80003b5e:	00001097          	auipc	ra,0x1
    80003b62:	eec080e7          	jalr	-276(ra) # 80004a4a <log_write>
    80003b66:	b7c9                	j	80003b28 <bmap+0x98>
  panic("bmap: out of range");
    80003b68:	00005517          	auipc	a0,0x5
    80003b6c:	a6850513          	addi	a0,a0,-1432 # 800085d0 <syscalls+0x140>
    80003b70:	ffffd097          	auipc	ra,0xffffd
    80003b74:	9ce080e7          	jalr	-1586(ra) # 8000053e <panic>

0000000080003b78 <iget>:
{
    80003b78:	7179                	addi	sp,sp,-48
    80003b7a:	f406                	sd	ra,40(sp)
    80003b7c:	f022                	sd	s0,32(sp)
    80003b7e:	ec26                	sd	s1,24(sp)
    80003b80:	e84a                	sd	s2,16(sp)
    80003b82:	e44e                	sd	s3,8(sp)
    80003b84:	e052                	sd	s4,0(sp)
    80003b86:	1800                	addi	s0,sp,48
    80003b88:	89aa                	mv	s3,a0
    80003b8a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b8c:	00020517          	auipc	a0,0x20
    80003b90:	b3c50513          	addi	a0,a0,-1220 # 800236c8 <itable>
    80003b94:	ffffd097          	auipc	ra,0xffffd
    80003b98:	042080e7          	jalr	66(ra) # 80000bd6 <acquire>
  empty = 0;
    80003b9c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b9e:	00020497          	auipc	s1,0x20
    80003ba2:	b4248493          	addi	s1,s1,-1214 # 800236e0 <itable+0x18>
    80003ba6:	00021697          	auipc	a3,0x21
    80003baa:	5ca68693          	addi	a3,a3,1482 # 80025170 <log>
    80003bae:	a039                	j	80003bbc <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003bb0:	02090b63          	beqz	s2,80003be6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003bb4:	08848493          	addi	s1,s1,136
    80003bb8:	02d48a63          	beq	s1,a3,80003bec <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003bbc:	449c                	lw	a5,8(s1)
    80003bbe:	fef059e3          	blez	a5,80003bb0 <iget+0x38>
    80003bc2:	4098                	lw	a4,0(s1)
    80003bc4:	ff3716e3          	bne	a4,s3,80003bb0 <iget+0x38>
    80003bc8:	40d8                	lw	a4,4(s1)
    80003bca:	ff4713e3          	bne	a4,s4,80003bb0 <iget+0x38>
      ip->ref++;
    80003bce:	2785                	addiw	a5,a5,1
    80003bd0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003bd2:	00020517          	auipc	a0,0x20
    80003bd6:	af650513          	addi	a0,a0,-1290 # 800236c8 <itable>
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	0b0080e7          	jalr	176(ra) # 80000c8a <release>
      return ip;
    80003be2:	8926                	mv	s2,s1
    80003be4:	a03d                	j	80003c12 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003be6:	f7f9                	bnez	a5,80003bb4 <iget+0x3c>
    80003be8:	8926                	mv	s2,s1
    80003bea:	b7e9                	j	80003bb4 <iget+0x3c>
  if(empty == 0)
    80003bec:	02090c63          	beqz	s2,80003c24 <iget+0xac>
  ip->dev = dev;
    80003bf0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003bf4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003bf8:	4785                	li	a5,1
    80003bfa:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003bfe:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003c02:	00020517          	auipc	a0,0x20
    80003c06:	ac650513          	addi	a0,a0,-1338 # 800236c8 <itable>
    80003c0a:	ffffd097          	auipc	ra,0xffffd
    80003c0e:	080080e7          	jalr	128(ra) # 80000c8a <release>
}
    80003c12:	854a                	mv	a0,s2
    80003c14:	70a2                	ld	ra,40(sp)
    80003c16:	7402                	ld	s0,32(sp)
    80003c18:	64e2                	ld	s1,24(sp)
    80003c1a:	6942                	ld	s2,16(sp)
    80003c1c:	69a2                	ld	s3,8(sp)
    80003c1e:	6a02                	ld	s4,0(sp)
    80003c20:	6145                	addi	sp,sp,48
    80003c22:	8082                	ret
    panic("iget: no inodes");
    80003c24:	00005517          	auipc	a0,0x5
    80003c28:	9c450513          	addi	a0,a0,-1596 # 800085e8 <syscalls+0x158>
    80003c2c:	ffffd097          	auipc	ra,0xffffd
    80003c30:	912080e7          	jalr	-1774(ra) # 8000053e <panic>

0000000080003c34 <fsinit>:
fsinit(int dev) {
    80003c34:	7179                	addi	sp,sp,-48
    80003c36:	f406                	sd	ra,40(sp)
    80003c38:	f022                	sd	s0,32(sp)
    80003c3a:	ec26                	sd	s1,24(sp)
    80003c3c:	e84a                	sd	s2,16(sp)
    80003c3e:	e44e                	sd	s3,8(sp)
    80003c40:	1800                	addi	s0,sp,48
    80003c42:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003c44:	4585                	li	a1,1
    80003c46:	00000097          	auipc	ra,0x0
    80003c4a:	a50080e7          	jalr	-1456(ra) # 80003696 <bread>
    80003c4e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003c50:	00020997          	auipc	s3,0x20
    80003c54:	a5898993          	addi	s3,s3,-1448 # 800236a8 <sb>
    80003c58:	02000613          	li	a2,32
    80003c5c:	05850593          	addi	a1,a0,88
    80003c60:	854e                	mv	a0,s3
    80003c62:	ffffd097          	auipc	ra,0xffffd
    80003c66:	0cc080e7          	jalr	204(ra) # 80000d2e <memmove>
  brelse(bp);
    80003c6a:	8526                	mv	a0,s1
    80003c6c:	00000097          	auipc	ra,0x0
    80003c70:	b5a080e7          	jalr	-1190(ra) # 800037c6 <brelse>
  if(sb.magic != FSMAGIC)
    80003c74:	0009a703          	lw	a4,0(s3)
    80003c78:	102037b7          	lui	a5,0x10203
    80003c7c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c80:	02f71263          	bne	a4,a5,80003ca4 <fsinit+0x70>
  initlog(dev, &sb);
    80003c84:	00020597          	auipc	a1,0x20
    80003c88:	a2458593          	addi	a1,a1,-1500 # 800236a8 <sb>
    80003c8c:	854a                	mv	a0,s2
    80003c8e:	00001097          	auipc	ra,0x1
    80003c92:	b40080e7          	jalr	-1216(ra) # 800047ce <initlog>
}
    80003c96:	70a2                	ld	ra,40(sp)
    80003c98:	7402                	ld	s0,32(sp)
    80003c9a:	64e2                	ld	s1,24(sp)
    80003c9c:	6942                	ld	s2,16(sp)
    80003c9e:	69a2                	ld	s3,8(sp)
    80003ca0:	6145                	addi	sp,sp,48
    80003ca2:	8082                	ret
    panic("invalid file system");
    80003ca4:	00005517          	auipc	a0,0x5
    80003ca8:	95450513          	addi	a0,a0,-1708 # 800085f8 <syscalls+0x168>
    80003cac:	ffffd097          	auipc	ra,0xffffd
    80003cb0:	892080e7          	jalr	-1902(ra) # 8000053e <panic>

0000000080003cb4 <iinit>:
{
    80003cb4:	7179                	addi	sp,sp,-48
    80003cb6:	f406                	sd	ra,40(sp)
    80003cb8:	f022                	sd	s0,32(sp)
    80003cba:	ec26                	sd	s1,24(sp)
    80003cbc:	e84a                	sd	s2,16(sp)
    80003cbe:	e44e                	sd	s3,8(sp)
    80003cc0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003cc2:	00005597          	auipc	a1,0x5
    80003cc6:	94e58593          	addi	a1,a1,-1714 # 80008610 <syscalls+0x180>
    80003cca:	00020517          	auipc	a0,0x20
    80003cce:	9fe50513          	addi	a0,a0,-1538 # 800236c8 <itable>
    80003cd2:	ffffd097          	auipc	ra,0xffffd
    80003cd6:	e74080e7          	jalr	-396(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003cda:	00020497          	auipc	s1,0x20
    80003cde:	a1648493          	addi	s1,s1,-1514 # 800236f0 <itable+0x28>
    80003ce2:	00021997          	auipc	s3,0x21
    80003ce6:	49e98993          	addi	s3,s3,1182 # 80025180 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003cea:	00005917          	auipc	s2,0x5
    80003cee:	92e90913          	addi	s2,s2,-1746 # 80008618 <syscalls+0x188>
    80003cf2:	85ca                	mv	a1,s2
    80003cf4:	8526                	mv	a0,s1
    80003cf6:	00001097          	auipc	ra,0x1
    80003cfa:	e3a080e7          	jalr	-454(ra) # 80004b30 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003cfe:	08848493          	addi	s1,s1,136
    80003d02:	ff3498e3          	bne	s1,s3,80003cf2 <iinit+0x3e>
}
    80003d06:	70a2                	ld	ra,40(sp)
    80003d08:	7402                	ld	s0,32(sp)
    80003d0a:	64e2                	ld	s1,24(sp)
    80003d0c:	6942                	ld	s2,16(sp)
    80003d0e:	69a2                	ld	s3,8(sp)
    80003d10:	6145                	addi	sp,sp,48
    80003d12:	8082                	ret

0000000080003d14 <ialloc>:
{
    80003d14:	715d                	addi	sp,sp,-80
    80003d16:	e486                	sd	ra,72(sp)
    80003d18:	e0a2                	sd	s0,64(sp)
    80003d1a:	fc26                	sd	s1,56(sp)
    80003d1c:	f84a                	sd	s2,48(sp)
    80003d1e:	f44e                	sd	s3,40(sp)
    80003d20:	f052                	sd	s4,32(sp)
    80003d22:	ec56                	sd	s5,24(sp)
    80003d24:	e85a                	sd	s6,16(sp)
    80003d26:	e45e                	sd	s7,8(sp)
    80003d28:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d2a:	00020717          	auipc	a4,0x20
    80003d2e:	98a72703          	lw	a4,-1654(a4) # 800236b4 <sb+0xc>
    80003d32:	4785                	li	a5,1
    80003d34:	04e7fa63          	bgeu	a5,a4,80003d88 <ialloc+0x74>
    80003d38:	8aaa                	mv	s5,a0
    80003d3a:	8bae                	mv	s7,a1
    80003d3c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003d3e:	00020a17          	auipc	s4,0x20
    80003d42:	96aa0a13          	addi	s4,s4,-1686 # 800236a8 <sb>
    80003d46:	00048b1b          	sext.w	s6,s1
    80003d4a:	0044d793          	srli	a5,s1,0x4
    80003d4e:	018a2583          	lw	a1,24(s4)
    80003d52:	9dbd                	addw	a1,a1,a5
    80003d54:	8556                	mv	a0,s5
    80003d56:	00000097          	auipc	ra,0x0
    80003d5a:	940080e7          	jalr	-1728(ra) # 80003696 <bread>
    80003d5e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003d60:	05850993          	addi	s3,a0,88
    80003d64:	00f4f793          	andi	a5,s1,15
    80003d68:	079a                	slli	a5,a5,0x6
    80003d6a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003d6c:	00099783          	lh	a5,0(s3)
    80003d70:	c3a1                	beqz	a5,80003db0 <ialloc+0x9c>
    brelse(bp);
    80003d72:	00000097          	auipc	ra,0x0
    80003d76:	a54080e7          	jalr	-1452(ra) # 800037c6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003d7a:	0485                	addi	s1,s1,1
    80003d7c:	00ca2703          	lw	a4,12(s4)
    80003d80:	0004879b          	sext.w	a5,s1
    80003d84:	fce7e1e3          	bltu	a5,a4,80003d46 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003d88:	00005517          	auipc	a0,0x5
    80003d8c:	89850513          	addi	a0,a0,-1896 # 80008620 <syscalls+0x190>
    80003d90:	ffffc097          	auipc	ra,0xffffc
    80003d94:	7f8080e7          	jalr	2040(ra) # 80000588 <printf>
  return 0;
    80003d98:	4501                	li	a0,0
}
    80003d9a:	60a6                	ld	ra,72(sp)
    80003d9c:	6406                	ld	s0,64(sp)
    80003d9e:	74e2                	ld	s1,56(sp)
    80003da0:	7942                	ld	s2,48(sp)
    80003da2:	79a2                	ld	s3,40(sp)
    80003da4:	7a02                	ld	s4,32(sp)
    80003da6:	6ae2                	ld	s5,24(sp)
    80003da8:	6b42                	ld	s6,16(sp)
    80003daa:	6ba2                	ld	s7,8(sp)
    80003dac:	6161                	addi	sp,sp,80
    80003dae:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003db0:	04000613          	li	a2,64
    80003db4:	4581                	li	a1,0
    80003db6:	854e                	mv	a0,s3
    80003db8:	ffffd097          	auipc	ra,0xffffd
    80003dbc:	f1a080e7          	jalr	-230(ra) # 80000cd2 <memset>
      dip->type = type;
    80003dc0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003dc4:	854a                	mv	a0,s2
    80003dc6:	00001097          	auipc	ra,0x1
    80003dca:	c84080e7          	jalr	-892(ra) # 80004a4a <log_write>
      brelse(bp);
    80003dce:	854a                	mv	a0,s2
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	9f6080e7          	jalr	-1546(ra) # 800037c6 <brelse>
      return iget(dev, inum);
    80003dd8:	85da                	mv	a1,s6
    80003dda:	8556                	mv	a0,s5
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	d9c080e7          	jalr	-612(ra) # 80003b78 <iget>
    80003de4:	bf5d                	j	80003d9a <ialloc+0x86>

0000000080003de6 <iupdate>:
{
    80003de6:	1101                	addi	sp,sp,-32
    80003de8:	ec06                	sd	ra,24(sp)
    80003dea:	e822                	sd	s0,16(sp)
    80003dec:	e426                	sd	s1,8(sp)
    80003dee:	e04a                	sd	s2,0(sp)
    80003df0:	1000                	addi	s0,sp,32
    80003df2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003df4:	415c                	lw	a5,4(a0)
    80003df6:	0047d79b          	srliw	a5,a5,0x4
    80003dfa:	00020597          	auipc	a1,0x20
    80003dfe:	8c65a583          	lw	a1,-1850(a1) # 800236c0 <sb+0x18>
    80003e02:	9dbd                	addw	a1,a1,a5
    80003e04:	4108                	lw	a0,0(a0)
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	890080e7          	jalr	-1904(ra) # 80003696 <bread>
    80003e0e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e10:	05850793          	addi	a5,a0,88
    80003e14:	40c8                	lw	a0,4(s1)
    80003e16:	893d                	andi	a0,a0,15
    80003e18:	051a                	slli	a0,a0,0x6
    80003e1a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003e1c:	04449703          	lh	a4,68(s1)
    80003e20:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003e24:	04649703          	lh	a4,70(s1)
    80003e28:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003e2c:	04849703          	lh	a4,72(s1)
    80003e30:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003e34:	04a49703          	lh	a4,74(s1)
    80003e38:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003e3c:	44f8                	lw	a4,76(s1)
    80003e3e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003e40:	03400613          	li	a2,52
    80003e44:	05048593          	addi	a1,s1,80
    80003e48:	0531                	addi	a0,a0,12
    80003e4a:	ffffd097          	auipc	ra,0xffffd
    80003e4e:	ee4080e7          	jalr	-284(ra) # 80000d2e <memmove>
  log_write(bp);
    80003e52:	854a                	mv	a0,s2
    80003e54:	00001097          	auipc	ra,0x1
    80003e58:	bf6080e7          	jalr	-1034(ra) # 80004a4a <log_write>
  brelse(bp);
    80003e5c:	854a                	mv	a0,s2
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	968080e7          	jalr	-1688(ra) # 800037c6 <brelse>
}
    80003e66:	60e2                	ld	ra,24(sp)
    80003e68:	6442                	ld	s0,16(sp)
    80003e6a:	64a2                	ld	s1,8(sp)
    80003e6c:	6902                	ld	s2,0(sp)
    80003e6e:	6105                	addi	sp,sp,32
    80003e70:	8082                	ret

0000000080003e72 <idup>:
{
    80003e72:	1101                	addi	sp,sp,-32
    80003e74:	ec06                	sd	ra,24(sp)
    80003e76:	e822                	sd	s0,16(sp)
    80003e78:	e426                	sd	s1,8(sp)
    80003e7a:	1000                	addi	s0,sp,32
    80003e7c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e7e:	00020517          	auipc	a0,0x20
    80003e82:	84a50513          	addi	a0,a0,-1974 # 800236c8 <itable>
    80003e86:	ffffd097          	auipc	ra,0xffffd
    80003e8a:	d50080e7          	jalr	-688(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003e8e:	449c                	lw	a5,8(s1)
    80003e90:	2785                	addiw	a5,a5,1
    80003e92:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e94:	00020517          	auipc	a0,0x20
    80003e98:	83450513          	addi	a0,a0,-1996 # 800236c8 <itable>
    80003e9c:	ffffd097          	auipc	ra,0xffffd
    80003ea0:	dee080e7          	jalr	-530(ra) # 80000c8a <release>
}
    80003ea4:	8526                	mv	a0,s1
    80003ea6:	60e2                	ld	ra,24(sp)
    80003ea8:	6442                	ld	s0,16(sp)
    80003eaa:	64a2                	ld	s1,8(sp)
    80003eac:	6105                	addi	sp,sp,32
    80003eae:	8082                	ret

0000000080003eb0 <ilock>:
{
    80003eb0:	1101                	addi	sp,sp,-32
    80003eb2:	ec06                	sd	ra,24(sp)
    80003eb4:	e822                	sd	s0,16(sp)
    80003eb6:	e426                	sd	s1,8(sp)
    80003eb8:	e04a                	sd	s2,0(sp)
    80003eba:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ebc:	c115                	beqz	a0,80003ee0 <ilock+0x30>
    80003ebe:	84aa                	mv	s1,a0
    80003ec0:	451c                	lw	a5,8(a0)
    80003ec2:	00f05f63          	blez	a5,80003ee0 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ec6:	0541                	addi	a0,a0,16
    80003ec8:	00001097          	auipc	ra,0x1
    80003ecc:	ca2080e7          	jalr	-862(ra) # 80004b6a <acquiresleep>
  if(ip->valid == 0){
    80003ed0:	40bc                	lw	a5,64(s1)
    80003ed2:	cf99                	beqz	a5,80003ef0 <ilock+0x40>
}
    80003ed4:	60e2                	ld	ra,24(sp)
    80003ed6:	6442                	ld	s0,16(sp)
    80003ed8:	64a2                	ld	s1,8(sp)
    80003eda:	6902                	ld	s2,0(sp)
    80003edc:	6105                	addi	sp,sp,32
    80003ede:	8082                	ret
    panic("ilock");
    80003ee0:	00004517          	auipc	a0,0x4
    80003ee4:	75850513          	addi	a0,a0,1880 # 80008638 <syscalls+0x1a8>
    80003ee8:	ffffc097          	auipc	ra,0xffffc
    80003eec:	656080e7          	jalr	1622(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ef0:	40dc                	lw	a5,4(s1)
    80003ef2:	0047d79b          	srliw	a5,a5,0x4
    80003ef6:	0001f597          	auipc	a1,0x1f
    80003efa:	7ca5a583          	lw	a1,1994(a1) # 800236c0 <sb+0x18>
    80003efe:	9dbd                	addw	a1,a1,a5
    80003f00:	4088                	lw	a0,0(s1)
    80003f02:	fffff097          	auipc	ra,0xfffff
    80003f06:	794080e7          	jalr	1940(ra) # 80003696 <bread>
    80003f0a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003f0c:	05850593          	addi	a1,a0,88
    80003f10:	40dc                	lw	a5,4(s1)
    80003f12:	8bbd                	andi	a5,a5,15
    80003f14:	079a                	slli	a5,a5,0x6
    80003f16:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003f18:	00059783          	lh	a5,0(a1)
    80003f1c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003f20:	00259783          	lh	a5,2(a1)
    80003f24:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003f28:	00459783          	lh	a5,4(a1)
    80003f2c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003f30:	00659783          	lh	a5,6(a1)
    80003f34:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003f38:	459c                	lw	a5,8(a1)
    80003f3a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003f3c:	03400613          	li	a2,52
    80003f40:	05b1                	addi	a1,a1,12
    80003f42:	05048513          	addi	a0,s1,80
    80003f46:	ffffd097          	auipc	ra,0xffffd
    80003f4a:	de8080e7          	jalr	-536(ra) # 80000d2e <memmove>
    brelse(bp);
    80003f4e:	854a                	mv	a0,s2
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	876080e7          	jalr	-1930(ra) # 800037c6 <brelse>
    ip->valid = 1;
    80003f58:	4785                	li	a5,1
    80003f5a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003f5c:	04449783          	lh	a5,68(s1)
    80003f60:	fbb5                	bnez	a5,80003ed4 <ilock+0x24>
      panic("ilock: no type");
    80003f62:	00004517          	auipc	a0,0x4
    80003f66:	6de50513          	addi	a0,a0,1758 # 80008640 <syscalls+0x1b0>
    80003f6a:	ffffc097          	auipc	ra,0xffffc
    80003f6e:	5d4080e7          	jalr	1492(ra) # 8000053e <panic>

0000000080003f72 <iunlock>:
{
    80003f72:	1101                	addi	sp,sp,-32
    80003f74:	ec06                	sd	ra,24(sp)
    80003f76:	e822                	sd	s0,16(sp)
    80003f78:	e426                	sd	s1,8(sp)
    80003f7a:	e04a                	sd	s2,0(sp)
    80003f7c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f7e:	c905                	beqz	a0,80003fae <iunlock+0x3c>
    80003f80:	84aa                	mv	s1,a0
    80003f82:	01050913          	addi	s2,a0,16
    80003f86:	854a                	mv	a0,s2
    80003f88:	00001097          	auipc	ra,0x1
    80003f8c:	c7c080e7          	jalr	-900(ra) # 80004c04 <holdingsleep>
    80003f90:	cd19                	beqz	a0,80003fae <iunlock+0x3c>
    80003f92:	449c                	lw	a5,8(s1)
    80003f94:	00f05d63          	blez	a5,80003fae <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f98:	854a                	mv	a0,s2
    80003f9a:	00001097          	auipc	ra,0x1
    80003f9e:	c26080e7          	jalr	-986(ra) # 80004bc0 <releasesleep>
}
    80003fa2:	60e2                	ld	ra,24(sp)
    80003fa4:	6442                	ld	s0,16(sp)
    80003fa6:	64a2                	ld	s1,8(sp)
    80003fa8:	6902                	ld	s2,0(sp)
    80003faa:	6105                	addi	sp,sp,32
    80003fac:	8082                	ret
    panic("iunlock");
    80003fae:	00004517          	auipc	a0,0x4
    80003fb2:	6a250513          	addi	a0,a0,1698 # 80008650 <syscalls+0x1c0>
    80003fb6:	ffffc097          	auipc	ra,0xffffc
    80003fba:	588080e7          	jalr	1416(ra) # 8000053e <panic>

0000000080003fbe <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003fbe:	7179                	addi	sp,sp,-48
    80003fc0:	f406                	sd	ra,40(sp)
    80003fc2:	f022                	sd	s0,32(sp)
    80003fc4:	ec26                	sd	s1,24(sp)
    80003fc6:	e84a                	sd	s2,16(sp)
    80003fc8:	e44e                	sd	s3,8(sp)
    80003fca:	e052                	sd	s4,0(sp)
    80003fcc:	1800                	addi	s0,sp,48
    80003fce:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003fd0:	05050493          	addi	s1,a0,80
    80003fd4:	08050913          	addi	s2,a0,128
    80003fd8:	a021                	j	80003fe0 <itrunc+0x22>
    80003fda:	0491                	addi	s1,s1,4
    80003fdc:	01248d63          	beq	s1,s2,80003ff6 <itrunc+0x38>
    if(ip->addrs[i]){
    80003fe0:	408c                	lw	a1,0(s1)
    80003fe2:	dde5                	beqz	a1,80003fda <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003fe4:	0009a503          	lw	a0,0(s3)
    80003fe8:	00000097          	auipc	ra,0x0
    80003fec:	8f4080e7          	jalr	-1804(ra) # 800038dc <bfree>
      ip->addrs[i] = 0;
    80003ff0:	0004a023          	sw	zero,0(s1)
    80003ff4:	b7dd                	j	80003fda <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ff6:	0809a583          	lw	a1,128(s3)
    80003ffa:	e185                	bnez	a1,8000401a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ffc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004000:	854e                	mv	a0,s3
    80004002:	00000097          	auipc	ra,0x0
    80004006:	de4080e7          	jalr	-540(ra) # 80003de6 <iupdate>
}
    8000400a:	70a2                	ld	ra,40(sp)
    8000400c:	7402                	ld	s0,32(sp)
    8000400e:	64e2                	ld	s1,24(sp)
    80004010:	6942                	ld	s2,16(sp)
    80004012:	69a2                	ld	s3,8(sp)
    80004014:	6a02                	ld	s4,0(sp)
    80004016:	6145                	addi	sp,sp,48
    80004018:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000401a:	0009a503          	lw	a0,0(s3)
    8000401e:	fffff097          	auipc	ra,0xfffff
    80004022:	678080e7          	jalr	1656(ra) # 80003696 <bread>
    80004026:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004028:	05850493          	addi	s1,a0,88
    8000402c:	45850913          	addi	s2,a0,1112
    80004030:	a021                	j	80004038 <itrunc+0x7a>
    80004032:	0491                	addi	s1,s1,4
    80004034:	01248b63          	beq	s1,s2,8000404a <itrunc+0x8c>
      if(a[j])
    80004038:	408c                	lw	a1,0(s1)
    8000403a:	dde5                	beqz	a1,80004032 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000403c:	0009a503          	lw	a0,0(s3)
    80004040:	00000097          	auipc	ra,0x0
    80004044:	89c080e7          	jalr	-1892(ra) # 800038dc <bfree>
    80004048:	b7ed                	j	80004032 <itrunc+0x74>
    brelse(bp);
    8000404a:	8552                	mv	a0,s4
    8000404c:	fffff097          	auipc	ra,0xfffff
    80004050:	77a080e7          	jalr	1914(ra) # 800037c6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004054:	0809a583          	lw	a1,128(s3)
    80004058:	0009a503          	lw	a0,0(s3)
    8000405c:	00000097          	auipc	ra,0x0
    80004060:	880080e7          	jalr	-1920(ra) # 800038dc <bfree>
    ip->addrs[NDIRECT] = 0;
    80004064:	0809a023          	sw	zero,128(s3)
    80004068:	bf51                	j	80003ffc <itrunc+0x3e>

000000008000406a <iput>:
{
    8000406a:	1101                	addi	sp,sp,-32
    8000406c:	ec06                	sd	ra,24(sp)
    8000406e:	e822                	sd	s0,16(sp)
    80004070:	e426                	sd	s1,8(sp)
    80004072:	e04a                	sd	s2,0(sp)
    80004074:	1000                	addi	s0,sp,32
    80004076:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004078:	0001f517          	auipc	a0,0x1f
    8000407c:	65050513          	addi	a0,a0,1616 # 800236c8 <itable>
    80004080:	ffffd097          	auipc	ra,0xffffd
    80004084:	b56080e7          	jalr	-1194(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004088:	4498                	lw	a4,8(s1)
    8000408a:	4785                	li	a5,1
    8000408c:	02f70363          	beq	a4,a5,800040b2 <iput+0x48>
  ip->ref--;
    80004090:	449c                	lw	a5,8(s1)
    80004092:	37fd                	addiw	a5,a5,-1
    80004094:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004096:	0001f517          	auipc	a0,0x1f
    8000409a:	63250513          	addi	a0,a0,1586 # 800236c8 <itable>
    8000409e:	ffffd097          	auipc	ra,0xffffd
    800040a2:	bec080e7          	jalr	-1044(ra) # 80000c8a <release>
}
    800040a6:	60e2                	ld	ra,24(sp)
    800040a8:	6442                	ld	s0,16(sp)
    800040aa:	64a2                	ld	s1,8(sp)
    800040ac:	6902                	ld	s2,0(sp)
    800040ae:	6105                	addi	sp,sp,32
    800040b0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800040b2:	40bc                	lw	a5,64(s1)
    800040b4:	dff1                	beqz	a5,80004090 <iput+0x26>
    800040b6:	04a49783          	lh	a5,74(s1)
    800040ba:	fbf9                	bnez	a5,80004090 <iput+0x26>
    acquiresleep(&ip->lock);
    800040bc:	01048913          	addi	s2,s1,16
    800040c0:	854a                	mv	a0,s2
    800040c2:	00001097          	auipc	ra,0x1
    800040c6:	aa8080e7          	jalr	-1368(ra) # 80004b6a <acquiresleep>
    release(&itable.lock);
    800040ca:	0001f517          	auipc	a0,0x1f
    800040ce:	5fe50513          	addi	a0,a0,1534 # 800236c8 <itable>
    800040d2:	ffffd097          	auipc	ra,0xffffd
    800040d6:	bb8080e7          	jalr	-1096(ra) # 80000c8a <release>
    itrunc(ip);
    800040da:	8526                	mv	a0,s1
    800040dc:	00000097          	auipc	ra,0x0
    800040e0:	ee2080e7          	jalr	-286(ra) # 80003fbe <itrunc>
    ip->type = 0;
    800040e4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800040e8:	8526                	mv	a0,s1
    800040ea:	00000097          	auipc	ra,0x0
    800040ee:	cfc080e7          	jalr	-772(ra) # 80003de6 <iupdate>
    ip->valid = 0;
    800040f2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800040f6:	854a                	mv	a0,s2
    800040f8:	00001097          	auipc	ra,0x1
    800040fc:	ac8080e7          	jalr	-1336(ra) # 80004bc0 <releasesleep>
    acquire(&itable.lock);
    80004100:	0001f517          	auipc	a0,0x1f
    80004104:	5c850513          	addi	a0,a0,1480 # 800236c8 <itable>
    80004108:	ffffd097          	auipc	ra,0xffffd
    8000410c:	ace080e7          	jalr	-1330(ra) # 80000bd6 <acquire>
    80004110:	b741                	j	80004090 <iput+0x26>

0000000080004112 <iunlockput>:
{
    80004112:	1101                	addi	sp,sp,-32
    80004114:	ec06                	sd	ra,24(sp)
    80004116:	e822                	sd	s0,16(sp)
    80004118:	e426                	sd	s1,8(sp)
    8000411a:	1000                	addi	s0,sp,32
    8000411c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000411e:	00000097          	auipc	ra,0x0
    80004122:	e54080e7          	jalr	-428(ra) # 80003f72 <iunlock>
  iput(ip);
    80004126:	8526                	mv	a0,s1
    80004128:	00000097          	auipc	ra,0x0
    8000412c:	f42080e7          	jalr	-190(ra) # 8000406a <iput>
}
    80004130:	60e2                	ld	ra,24(sp)
    80004132:	6442                	ld	s0,16(sp)
    80004134:	64a2                	ld	s1,8(sp)
    80004136:	6105                	addi	sp,sp,32
    80004138:	8082                	ret

000000008000413a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000413a:	1141                	addi	sp,sp,-16
    8000413c:	e422                	sd	s0,8(sp)
    8000413e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004140:	411c                	lw	a5,0(a0)
    80004142:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004144:	415c                	lw	a5,4(a0)
    80004146:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004148:	04451783          	lh	a5,68(a0)
    8000414c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004150:	04a51783          	lh	a5,74(a0)
    80004154:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004158:	04c56783          	lwu	a5,76(a0)
    8000415c:	e99c                	sd	a5,16(a1)
}
    8000415e:	6422                	ld	s0,8(sp)
    80004160:	0141                	addi	sp,sp,16
    80004162:	8082                	ret

0000000080004164 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004164:	457c                	lw	a5,76(a0)
    80004166:	0ed7e963          	bltu	a5,a3,80004258 <readi+0xf4>
{
    8000416a:	7159                	addi	sp,sp,-112
    8000416c:	f486                	sd	ra,104(sp)
    8000416e:	f0a2                	sd	s0,96(sp)
    80004170:	eca6                	sd	s1,88(sp)
    80004172:	e8ca                	sd	s2,80(sp)
    80004174:	e4ce                	sd	s3,72(sp)
    80004176:	e0d2                	sd	s4,64(sp)
    80004178:	fc56                	sd	s5,56(sp)
    8000417a:	f85a                	sd	s6,48(sp)
    8000417c:	f45e                	sd	s7,40(sp)
    8000417e:	f062                	sd	s8,32(sp)
    80004180:	ec66                	sd	s9,24(sp)
    80004182:	e86a                	sd	s10,16(sp)
    80004184:	e46e                	sd	s11,8(sp)
    80004186:	1880                	addi	s0,sp,112
    80004188:	8b2a                	mv	s6,a0
    8000418a:	8bae                	mv	s7,a1
    8000418c:	8a32                	mv	s4,a2
    8000418e:	84b6                	mv	s1,a3
    80004190:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004192:	9f35                	addw	a4,a4,a3
    return 0;
    80004194:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004196:	0ad76063          	bltu	a4,a3,80004236 <readi+0xd2>
  if(off + n > ip->size)
    8000419a:	00e7f463          	bgeu	a5,a4,800041a2 <readi+0x3e>
    n = ip->size - off;
    8000419e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041a2:	0a0a8963          	beqz	s5,80004254 <readi+0xf0>
    800041a6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800041a8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800041ac:	5c7d                	li	s8,-1
    800041ae:	a82d                	j	800041e8 <readi+0x84>
    800041b0:	020d1d93          	slli	s11,s10,0x20
    800041b4:	020ddd93          	srli	s11,s11,0x20
    800041b8:	05890793          	addi	a5,s2,88
    800041bc:	86ee                	mv	a3,s11
    800041be:	963e                	add	a2,a2,a5
    800041c0:	85d2                	mv	a1,s4
    800041c2:	855e                	mv	a0,s7
    800041c4:	ffffe097          	auipc	ra,0xffffe
    800041c8:	3ba080e7          	jalr	954(ra) # 8000257e <either_copyout>
    800041cc:	05850d63          	beq	a0,s8,80004226 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800041d0:	854a                	mv	a0,s2
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	5f4080e7          	jalr	1524(ra) # 800037c6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041da:	013d09bb          	addw	s3,s10,s3
    800041de:	009d04bb          	addw	s1,s10,s1
    800041e2:	9a6e                	add	s4,s4,s11
    800041e4:	0559f763          	bgeu	s3,s5,80004232 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800041e8:	00a4d59b          	srliw	a1,s1,0xa
    800041ec:	855a                	mv	a0,s6
    800041ee:	00000097          	auipc	ra,0x0
    800041f2:	8a2080e7          	jalr	-1886(ra) # 80003a90 <bmap>
    800041f6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800041fa:	cd85                	beqz	a1,80004232 <readi+0xce>
    bp = bread(ip->dev, addr);
    800041fc:	000b2503          	lw	a0,0(s6)
    80004200:	fffff097          	auipc	ra,0xfffff
    80004204:	496080e7          	jalr	1174(ra) # 80003696 <bread>
    80004208:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000420a:	3ff4f613          	andi	a2,s1,1023
    8000420e:	40cc87bb          	subw	a5,s9,a2
    80004212:	413a873b          	subw	a4,s5,s3
    80004216:	8d3e                	mv	s10,a5
    80004218:	2781                	sext.w	a5,a5
    8000421a:	0007069b          	sext.w	a3,a4
    8000421e:	f8f6f9e3          	bgeu	a3,a5,800041b0 <readi+0x4c>
    80004222:	8d3a                	mv	s10,a4
    80004224:	b771                	j	800041b0 <readi+0x4c>
      brelse(bp);
    80004226:	854a                	mv	a0,s2
    80004228:	fffff097          	auipc	ra,0xfffff
    8000422c:	59e080e7          	jalr	1438(ra) # 800037c6 <brelse>
      tot = -1;
    80004230:	59fd                	li	s3,-1
  }
  return tot;
    80004232:	0009851b          	sext.w	a0,s3
}
    80004236:	70a6                	ld	ra,104(sp)
    80004238:	7406                	ld	s0,96(sp)
    8000423a:	64e6                	ld	s1,88(sp)
    8000423c:	6946                	ld	s2,80(sp)
    8000423e:	69a6                	ld	s3,72(sp)
    80004240:	6a06                	ld	s4,64(sp)
    80004242:	7ae2                	ld	s5,56(sp)
    80004244:	7b42                	ld	s6,48(sp)
    80004246:	7ba2                	ld	s7,40(sp)
    80004248:	7c02                	ld	s8,32(sp)
    8000424a:	6ce2                	ld	s9,24(sp)
    8000424c:	6d42                	ld	s10,16(sp)
    8000424e:	6da2                	ld	s11,8(sp)
    80004250:	6165                	addi	sp,sp,112
    80004252:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004254:	89d6                	mv	s3,s5
    80004256:	bff1                	j	80004232 <readi+0xce>
    return 0;
    80004258:	4501                	li	a0,0
}
    8000425a:	8082                	ret

000000008000425c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000425c:	457c                	lw	a5,76(a0)
    8000425e:	10d7e863          	bltu	a5,a3,8000436e <writei+0x112>
{
    80004262:	7159                	addi	sp,sp,-112
    80004264:	f486                	sd	ra,104(sp)
    80004266:	f0a2                	sd	s0,96(sp)
    80004268:	eca6                	sd	s1,88(sp)
    8000426a:	e8ca                	sd	s2,80(sp)
    8000426c:	e4ce                	sd	s3,72(sp)
    8000426e:	e0d2                	sd	s4,64(sp)
    80004270:	fc56                	sd	s5,56(sp)
    80004272:	f85a                	sd	s6,48(sp)
    80004274:	f45e                	sd	s7,40(sp)
    80004276:	f062                	sd	s8,32(sp)
    80004278:	ec66                	sd	s9,24(sp)
    8000427a:	e86a                	sd	s10,16(sp)
    8000427c:	e46e                	sd	s11,8(sp)
    8000427e:	1880                	addi	s0,sp,112
    80004280:	8aaa                	mv	s5,a0
    80004282:	8bae                	mv	s7,a1
    80004284:	8a32                	mv	s4,a2
    80004286:	8936                	mv	s2,a3
    80004288:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000428a:	00e687bb          	addw	a5,a3,a4
    8000428e:	0ed7e263          	bltu	a5,a3,80004372 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004292:	00043737          	lui	a4,0x43
    80004296:	0ef76063          	bltu	a4,a5,80004376 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000429a:	0c0b0863          	beqz	s6,8000436a <writei+0x10e>
    8000429e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800042a0:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800042a4:	5c7d                	li	s8,-1
    800042a6:	a091                	j	800042ea <writei+0x8e>
    800042a8:	020d1d93          	slli	s11,s10,0x20
    800042ac:	020ddd93          	srli	s11,s11,0x20
    800042b0:	05848793          	addi	a5,s1,88
    800042b4:	86ee                	mv	a3,s11
    800042b6:	8652                	mv	a2,s4
    800042b8:	85de                	mv	a1,s7
    800042ba:	953e                	add	a0,a0,a5
    800042bc:	ffffe097          	auipc	ra,0xffffe
    800042c0:	31a080e7          	jalr	794(ra) # 800025d6 <either_copyin>
    800042c4:	07850263          	beq	a0,s8,80004328 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800042c8:	8526                	mv	a0,s1
    800042ca:	00000097          	auipc	ra,0x0
    800042ce:	780080e7          	jalr	1920(ra) # 80004a4a <log_write>
    brelse(bp);
    800042d2:	8526                	mv	a0,s1
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	4f2080e7          	jalr	1266(ra) # 800037c6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042dc:	013d09bb          	addw	s3,s10,s3
    800042e0:	012d093b          	addw	s2,s10,s2
    800042e4:	9a6e                	add	s4,s4,s11
    800042e6:	0569f663          	bgeu	s3,s6,80004332 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800042ea:	00a9559b          	srliw	a1,s2,0xa
    800042ee:	8556                	mv	a0,s5
    800042f0:	fffff097          	auipc	ra,0xfffff
    800042f4:	7a0080e7          	jalr	1952(ra) # 80003a90 <bmap>
    800042f8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800042fc:	c99d                	beqz	a1,80004332 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800042fe:	000aa503          	lw	a0,0(s5)
    80004302:	fffff097          	auipc	ra,0xfffff
    80004306:	394080e7          	jalr	916(ra) # 80003696 <bread>
    8000430a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000430c:	3ff97513          	andi	a0,s2,1023
    80004310:	40ac87bb          	subw	a5,s9,a0
    80004314:	413b073b          	subw	a4,s6,s3
    80004318:	8d3e                	mv	s10,a5
    8000431a:	2781                	sext.w	a5,a5
    8000431c:	0007069b          	sext.w	a3,a4
    80004320:	f8f6f4e3          	bgeu	a3,a5,800042a8 <writei+0x4c>
    80004324:	8d3a                	mv	s10,a4
    80004326:	b749                	j	800042a8 <writei+0x4c>
      brelse(bp);
    80004328:	8526                	mv	a0,s1
    8000432a:	fffff097          	auipc	ra,0xfffff
    8000432e:	49c080e7          	jalr	1180(ra) # 800037c6 <brelse>
  }

  if(off > ip->size)
    80004332:	04caa783          	lw	a5,76(s5)
    80004336:	0127f463          	bgeu	a5,s2,8000433e <writei+0xe2>
    ip->size = off;
    8000433a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000433e:	8556                	mv	a0,s5
    80004340:	00000097          	auipc	ra,0x0
    80004344:	aa6080e7          	jalr	-1370(ra) # 80003de6 <iupdate>

  return tot;
    80004348:	0009851b          	sext.w	a0,s3
}
    8000434c:	70a6                	ld	ra,104(sp)
    8000434e:	7406                	ld	s0,96(sp)
    80004350:	64e6                	ld	s1,88(sp)
    80004352:	6946                	ld	s2,80(sp)
    80004354:	69a6                	ld	s3,72(sp)
    80004356:	6a06                	ld	s4,64(sp)
    80004358:	7ae2                	ld	s5,56(sp)
    8000435a:	7b42                	ld	s6,48(sp)
    8000435c:	7ba2                	ld	s7,40(sp)
    8000435e:	7c02                	ld	s8,32(sp)
    80004360:	6ce2                	ld	s9,24(sp)
    80004362:	6d42                	ld	s10,16(sp)
    80004364:	6da2                	ld	s11,8(sp)
    80004366:	6165                	addi	sp,sp,112
    80004368:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000436a:	89da                	mv	s3,s6
    8000436c:	bfc9                	j	8000433e <writei+0xe2>
    return -1;
    8000436e:	557d                	li	a0,-1
}
    80004370:	8082                	ret
    return -1;
    80004372:	557d                	li	a0,-1
    80004374:	bfe1                	j	8000434c <writei+0xf0>
    return -1;
    80004376:	557d                	li	a0,-1
    80004378:	bfd1                	j	8000434c <writei+0xf0>

000000008000437a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000437a:	1141                	addi	sp,sp,-16
    8000437c:	e406                	sd	ra,8(sp)
    8000437e:	e022                	sd	s0,0(sp)
    80004380:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004382:	4639                	li	a2,14
    80004384:	ffffd097          	auipc	ra,0xffffd
    80004388:	a1e080e7          	jalr	-1506(ra) # 80000da2 <strncmp>
}
    8000438c:	60a2                	ld	ra,8(sp)
    8000438e:	6402                	ld	s0,0(sp)
    80004390:	0141                	addi	sp,sp,16
    80004392:	8082                	ret

0000000080004394 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004394:	7139                	addi	sp,sp,-64
    80004396:	fc06                	sd	ra,56(sp)
    80004398:	f822                	sd	s0,48(sp)
    8000439a:	f426                	sd	s1,40(sp)
    8000439c:	f04a                	sd	s2,32(sp)
    8000439e:	ec4e                	sd	s3,24(sp)
    800043a0:	e852                	sd	s4,16(sp)
    800043a2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800043a4:	04451703          	lh	a4,68(a0)
    800043a8:	4785                	li	a5,1
    800043aa:	00f71a63          	bne	a4,a5,800043be <dirlookup+0x2a>
    800043ae:	892a                	mv	s2,a0
    800043b0:	89ae                	mv	s3,a1
    800043b2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800043b4:	457c                	lw	a5,76(a0)
    800043b6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800043b8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043ba:	e79d                	bnez	a5,800043e8 <dirlookup+0x54>
    800043bc:	a8a5                	j	80004434 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800043be:	00004517          	auipc	a0,0x4
    800043c2:	29a50513          	addi	a0,a0,666 # 80008658 <syscalls+0x1c8>
    800043c6:	ffffc097          	auipc	ra,0xffffc
    800043ca:	178080e7          	jalr	376(ra) # 8000053e <panic>
      panic("dirlookup read");
    800043ce:	00004517          	auipc	a0,0x4
    800043d2:	2a250513          	addi	a0,a0,674 # 80008670 <syscalls+0x1e0>
    800043d6:	ffffc097          	auipc	ra,0xffffc
    800043da:	168080e7          	jalr	360(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043de:	24c1                	addiw	s1,s1,16
    800043e0:	04c92783          	lw	a5,76(s2)
    800043e4:	04f4f763          	bgeu	s1,a5,80004432 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043e8:	4741                	li	a4,16
    800043ea:	86a6                	mv	a3,s1
    800043ec:	fc040613          	addi	a2,s0,-64
    800043f0:	4581                	li	a1,0
    800043f2:	854a                	mv	a0,s2
    800043f4:	00000097          	auipc	ra,0x0
    800043f8:	d70080e7          	jalr	-656(ra) # 80004164 <readi>
    800043fc:	47c1                	li	a5,16
    800043fe:	fcf518e3          	bne	a0,a5,800043ce <dirlookup+0x3a>
    if(de.inum == 0)
    80004402:	fc045783          	lhu	a5,-64(s0)
    80004406:	dfe1                	beqz	a5,800043de <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004408:	fc240593          	addi	a1,s0,-62
    8000440c:	854e                	mv	a0,s3
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	f6c080e7          	jalr	-148(ra) # 8000437a <namecmp>
    80004416:	f561                	bnez	a0,800043de <dirlookup+0x4a>
      if(poff)
    80004418:	000a0463          	beqz	s4,80004420 <dirlookup+0x8c>
        *poff = off;
    8000441c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004420:	fc045583          	lhu	a1,-64(s0)
    80004424:	00092503          	lw	a0,0(s2)
    80004428:	fffff097          	auipc	ra,0xfffff
    8000442c:	750080e7          	jalr	1872(ra) # 80003b78 <iget>
    80004430:	a011                	j	80004434 <dirlookup+0xa0>
  return 0;
    80004432:	4501                	li	a0,0
}
    80004434:	70e2                	ld	ra,56(sp)
    80004436:	7442                	ld	s0,48(sp)
    80004438:	74a2                	ld	s1,40(sp)
    8000443a:	7902                	ld	s2,32(sp)
    8000443c:	69e2                	ld	s3,24(sp)
    8000443e:	6a42                	ld	s4,16(sp)
    80004440:	6121                	addi	sp,sp,64
    80004442:	8082                	ret

0000000080004444 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004444:	711d                	addi	sp,sp,-96
    80004446:	ec86                	sd	ra,88(sp)
    80004448:	e8a2                	sd	s0,80(sp)
    8000444a:	e4a6                	sd	s1,72(sp)
    8000444c:	e0ca                	sd	s2,64(sp)
    8000444e:	fc4e                	sd	s3,56(sp)
    80004450:	f852                	sd	s4,48(sp)
    80004452:	f456                	sd	s5,40(sp)
    80004454:	f05a                	sd	s6,32(sp)
    80004456:	ec5e                	sd	s7,24(sp)
    80004458:	e862                	sd	s8,16(sp)
    8000445a:	e466                	sd	s9,8(sp)
    8000445c:	1080                	addi	s0,sp,96
    8000445e:	84aa                	mv	s1,a0
    80004460:	8aae                	mv	s5,a1
    80004462:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004464:	00054703          	lbu	a4,0(a0)
    80004468:	02f00793          	li	a5,47
    8000446c:	02f70363          	beq	a4,a5,80004492 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004470:	ffffd097          	auipc	ra,0xffffd
    80004474:	558080e7          	jalr	1368(ra) # 800019c8 <myproc>
    80004478:	25853503          	ld	a0,600(a0)
    8000447c:	00000097          	auipc	ra,0x0
    80004480:	9f6080e7          	jalr	-1546(ra) # 80003e72 <idup>
    80004484:	89aa                	mv	s3,a0
  while(*path == '/')
    80004486:	02f00913          	li	s2,47
  len = path - s;
    8000448a:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000448c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000448e:	4b85                	li	s7,1
    80004490:	a865                	j	80004548 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004492:	4585                	li	a1,1
    80004494:	4505                	li	a0,1
    80004496:	fffff097          	auipc	ra,0xfffff
    8000449a:	6e2080e7          	jalr	1762(ra) # 80003b78 <iget>
    8000449e:	89aa                	mv	s3,a0
    800044a0:	b7dd                	j	80004486 <namex+0x42>
      iunlockput(ip);
    800044a2:	854e                	mv	a0,s3
    800044a4:	00000097          	auipc	ra,0x0
    800044a8:	c6e080e7          	jalr	-914(ra) # 80004112 <iunlockput>
      return 0;
    800044ac:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800044ae:	854e                	mv	a0,s3
    800044b0:	60e6                	ld	ra,88(sp)
    800044b2:	6446                	ld	s0,80(sp)
    800044b4:	64a6                	ld	s1,72(sp)
    800044b6:	6906                	ld	s2,64(sp)
    800044b8:	79e2                	ld	s3,56(sp)
    800044ba:	7a42                	ld	s4,48(sp)
    800044bc:	7aa2                	ld	s5,40(sp)
    800044be:	7b02                	ld	s6,32(sp)
    800044c0:	6be2                	ld	s7,24(sp)
    800044c2:	6c42                	ld	s8,16(sp)
    800044c4:	6ca2                	ld	s9,8(sp)
    800044c6:	6125                	addi	sp,sp,96
    800044c8:	8082                	ret
      iunlock(ip);
    800044ca:	854e                	mv	a0,s3
    800044cc:	00000097          	auipc	ra,0x0
    800044d0:	aa6080e7          	jalr	-1370(ra) # 80003f72 <iunlock>
      return ip;
    800044d4:	bfe9                	j	800044ae <namex+0x6a>
      iunlockput(ip);
    800044d6:	854e                	mv	a0,s3
    800044d8:	00000097          	auipc	ra,0x0
    800044dc:	c3a080e7          	jalr	-966(ra) # 80004112 <iunlockput>
      return 0;
    800044e0:	89e6                	mv	s3,s9
    800044e2:	b7f1                	j	800044ae <namex+0x6a>
  len = path - s;
    800044e4:	40b48633          	sub	a2,s1,a1
    800044e8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800044ec:	099c5463          	bge	s8,s9,80004574 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800044f0:	4639                	li	a2,14
    800044f2:	8552                	mv	a0,s4
    800044f4:	ffffd097          	auipc	ra,0xffffd
    800044f8:	83a080e7          	jalr	-1990(ra) # 80000d2e <memmove>
  while(*path == '/')
    800044fc:	0004c783          	lbu	a5,0(s1)
    80004500:	01279763          	bne	a5,s2,8000450e <namex+0xca>
    path++;
    80004504:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004506:	0004c783          	lbu	a5,0(s1)
    8000450a:	ff278de3          	beq	a5,s2,80004504 <namex+0xc0>
    ilock(ip);
    8000450e:	854e                	mv	a0,s3
    80004510:	00000097          	auipc	ra,0x0
    80004514:	9a0080e7          	jalr	-1632(ra) # 80003eb0 <ilock>
    if(ip->type != T_DIR){
    80004518:	04499783          	lh	a5,68(s3)
    8000451c:	f97793e3          	bne	a5,s7,800044a2 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004520:	000a8563          	beqz	s5,8000452a <namex+0xe6>
    80004524:	0004c783          	lbu	a5,0(s1)
    80004528:	d3cd                	beqz	a5,800044ca <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000452a:	865a                	mv	a2,s6
    8000452c:	85d2                	mv	a1,s4
    8000452e:	854e                	mv	a0,s3
    80004530:	00000097          	auipc	ra,0x0
    80004534:	e64080e7          	jalr	-412(ra) # 80004394 <dirlookup>
    80004538:	8caa                	mv	s9,a0
    8000453a:	dd51                	beqz	a0,800044d6 <namex+0x92>
    iunlockput(ip);
    8000453c:	854e                	mv	a0,s3
    8000453e:	00000097          	auipc	ra,0x0
    80004542:	bd4080e7          	jalr	-1068(ra) # 80004112 <iunlockput>
    ip = next;
    80004546:	89e6                	mv	s3,s9
  while(*path == '/')
    80004548:	0004c783          	lbu	a5,0(s1)
    8000454c:	05279763          	bne	a5,s2,8000459a <namex+0x156>
    path++;
    80004550:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004552:	0004c783          	lbu	a5,0(s1)
    80004556:	ff278de3          	beq	a5,s2,80004550 <namex+0x10c>
  if(*path == 0)
    8000455a:	c79d                	beqz	a5,80004588 <namex+0x144>
    path++;
    8000455c:	85a6                	mv	a1,s1
  len = path - s;
    8000455e:	8cda                	mv	s9,s6
    80004560:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004562:	01278963          	beq	a5,s2,80004574 <namex+0x130>
    80004566:	dfbd                	beqz	a5,800044e4 <namex+0xa0>
    path++;
    80004568:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000456a:	0004c783          	lbu	a5,0(s1)
    8000456e:	ff279ce3          	bne	a5,s2,80004566 <namex+0x122>
    80004572:	bf8d                	j	800044e4 <namex+0xa0>
    memmove(name, s, len);
    80004574:	2601                	sext.w	a2,a2
    80004576:	8552                	mv	a0,s4
    80004578:	ffffc097          	auipc	ra,0xffffc
    8000457c:	7b6080e7          	jalr	1974(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004580:	9cd2                	add	s9,s9,s4
    80004582:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004586:	bf9d                	j	800044fc <namex+0xb8>
  if(nameiparent){
    80004588:	f20a83e3          	beqz	s5,800044ae <namex+0x6a>
    iput(ip);
    8000458c:	854e                	mv	a0,s3
    8000458e:	00000097          	auipc	ra,0x0
    80004592:	adc080e7          	jalr	-1316(ra) # 8000406a <iput>
    return 0;
    80004596:	4981                	li	s3,0
    80004598:	bf19                	j	800044ae <namex+0x6a>
  if(*path == 0)
    8000459a:	d7fd                	beqz	a5,80004588 <namex+0x144>
  while(*path != '/' && *path != 0)
    8000459c:	0004c783          	lbu	a5,0(s1)
    800045a0:	85a6                	mv	a1,s1
    800045a2:	b7d1                	j	80004566 <namex+0x122>

00000000800045a4 <dirlink>:
{
    800045a4:	7139                	addi	sp,sp,-64
    800045a6:	fc06                	sd	ra,56(sp)
    800045a8:	f822                	sd	s0,48(sp)
    800045aa:	f426                	sd	s1,40(sp)
    800045ac:	f04a                	sd	s2,32(sp)
    800045ae:	ec4e                	sd	s3,24(sp)
    800045b0:	e852                	sd	s4,16(sp)
    800045b2:	0080                	addi	s0,sp,64
    800045b4:	892a                	mv	s2,a0
    800045b6:	8a2e                	mv	s4,a1
    800045b8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800045ba:	4601                	li	a2,0
    800045bc:	00000097          	auipc	ra,0x0
    800045c0:	dd8080e7          	jalr	-552(ra) # 80004394 <dirlookup>
    800045c4:	e93d                	bnez	a0,8000463a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045c6:	04c92483          	lw	s1,76(s2)
    800045ca:	c49d                	beqz	s1,800045f8 <dirlink+0x54>
    800045cc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800045ce:	4741                	li	a4,16
    800045d0:	86a6                	mv	a3,s1
    800045d2:	fc040613          	addi	a2,s0,-64
    800045d6:	4581                	li	a1,0
    800045d8:	854a                	mv	a0,s2
    800045da:	00000097          	auipc	ra,0x0
    800045de:	b8a080e7          	jalr	-1142(ra) # 80004164 <readi>
    800045e2:	47c1                	li	a5,16
    800045e4:	06f51163          	bne	a0,a5,80004646 <dirlink+0xa2>
    if(de.inum == 0)
    800045e8:	fc045783          	lhu	a5,-64(s0)
    800045ec:	c791                	beqz	a5,800045f8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800045ee:	24c1                	addiw	s1,s1,16
    800045f0:	04c92783          	lw	a5,76(s2)
    800045f4:	fcf4ede3          	bltu	s1,a5,800045ce <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800045f8:	4639                	li	a2,14
    800045fa:	85d2                	mv	a1,s4
    800045fc:	fc240513          	addi	a0,s0,-62
    80004600:	ffffc097          	auipc	ra,0xffffc
    80004604:	7de080e7          	jalr	2014(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004608:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000460c:	4741                	li	a4,16
    8000460e:	86a6                	mv	a3,s1
    80004610:	fc040613          	addi	a2,s0,-64
    80004614:	4581                	li	a1,0
    80004616:	854a                	mv	a0,s2
    80004618:	00000097          	auipc	ra,0x0
    8000461c:	c44080e7          	jalr	-956(ra) # 8000425c <writei>
    80004620:	1541                	addi	a0,a0,-16
    80004622:	00a03533          	snez	a0,a0
    80004626:	40a00533          	neg	a0,a0
}
    8000462a:	70e2                	ld	ra,56(sp)
    8000462c:	7442                	ld	s0,48(sp)
    8000462e:	74a2                	ld	s1,40(sp)
    80004630:	7902                	ld	s2,32(sp)
    80004632:	69e2                	ld	s3,24(sp)
    80004634:	6a42                	ld	s4,16(sp)
    80004636:	6121                	addi	sp,sp,64
    80004638:	8082                	ret
    iput(ip);
    8000463a:	00000097          	auipc	ra,0x0
    8000463e:	a30080e7          	jalr	-1488(ra) # 8000406a <iput>
    return -1;
    80004642:	557d                	li	a0,-1
    80004644:	b7dd                	j	8000462a <dirlink+0x86>
      panic("dirlink read");
    80004646:	00004517          	auipc	a0,0x4
    8000464a:	03a50513          	addi	a0,a0,58 # 80008680 <syscalls+0x1f0>
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	ef0080e7          	jalr	-272(ra) # 8000053e <panic>

0000000080004656 <namei>:

struct inode*
namei(char *path)
{
    80004656:	1101                	addi	sp,sp,-32
    80004658:	ec06                	sd	ra,24(sp)
    8000465a:	e822                	sd	s0,16(sp)
    8000465c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000465e:	fe040613          	addi	a2,s0,-32
    80004662:	4581                	li	a1,0
    80004664:	00000097          	auipc	ra,0x0
    80004668:	de0080e7          	jalr	-544(ra) # 80004444 <namex>
}
    8000466c:	60e2                	ld	ra,24(sp)
    8000466e:	6442                	ld	s0,16(sp)
    80004670:	6105                	addi	sp,sp,32
    80004672:	8082                	ret

0000000080004674 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004674:	1141                	addi	sp,sp,-16
    80004676:	e406                	sd	ra,8(sp)
    80004678:	e022                	sd	s0,0(sp)
    8000467a:	0800                	addi	s0,sp,16
    8000467c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000467e:	4585                	li	a1,1
    80004680:	00000097          	auipc	ra,0x0
    80004684:	dc4080e7          	jalr	-572(ra) # 80004444 <namex>
}
    80004688:	60a2                	ld	ra,8(sp)
    8000468a:	6402                	ld	s0,0(sp)
    8000468c:	0141                	addi	sp,sp,16
    8000468e:	8082                	ret

0000000080004690 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004690:	1101                	addi	sp,sp,-32
    80004692:	ec06                	sd	ra,24(sp)
    80004694:	e822                	sd	s0,16(sp)
    80004696:	e426                	sd	s1,8(sp)
    80004698:	e04a                	sd	s2,0(sp)
    8000469a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000469c:	00021917          	auipc	s2,0x21
    800046a0:	ad490913          	addi	s2,s2,-1324 # 80025170 <log>
    800046a4:	01892583          	lw	a1,24(s2)
    800046a8:	02892503          	lw	a0,40(s2)
    800046ac:	fffff097          	auipc	ra,0xfffff
    800046b0:	fea080e7          	jalr	-22(ra) # 80003696 <bread>
    800046b4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800046b6:	02c92683          	lw	a3,44(s2)
    800046ba:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800046bc:	02d05763          	blez	a3,800046ea <write_head+0x5a>
    800046c0:	00021797          	auipc	a5,0x21
    800046c4:	ae078793          	addi	a5,a5,-1312 # 800251a0 <log+0x30>
    800046c8:	05c50713          	addi	a4,a0,92
    800046cc:	36fd                	addiw	a3,a3,-1
    800046ce:	1682                	slli	a3,a3,0x20
    800046d0:	9281                	srli	a3,a3,0x20
    800046d2:	068a                	slli	a3,a3,0x2
    800046d4:	00021617          	auipc	a2,0x21
    800046d8:	ad060613          	addi	a2,a2,-1328 # 800251a4 <log+0x34>
    800046dc:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800046de:	4390                	lw	a2,0(a5)
    800046e0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800046e2:	0791                	addi	a5,a5,4
    800046e4:	0711                	addi	a4,a4,4
    800046e6:	fed79ce3          	bne	a5,a3,800046de <write_head+0x4e>
  }
  bwrite(buf);
    800046ea:	8526                	mv	a0,s1
    800046ec:	fffff097          	auipc	ra,0xfffff
    800046f0:	09c080e7          	jalr	156(ra) # 80003788 <bwrite>
  brelse(buf);
    800046f4:	8526                	mv	a0,s1
    800046f6:	fffff097          	auipc	ra,0xfffff
    800046fa:	0d0080e7          	jalr	208(ra) # 800037c6 <brelse>
}
    800046fe:	60e2                	ld	ra,24(sp)
    80004700:	6442                	ld	s0,16(sp)
    80004702:	64a2                	ld	s1,8(sp)
    80004704:	6902                	ld	s2,0(sp)
    80004706:	6105                	addi	sp,sp,32
    80004708:	8082                	ret

000000008000470a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000470a:	00021797          	auipc	a5,0x21
    8000470e:	a927a783          	lw	a5,-1390(a5) # 8002519c <log+0x2c>
    80004712:	0af05d63          	blez	a5,800047cc <install_trans+0xc2>
{
    80004716:	7139                	addi	sp,sp,-64
    80004718:	fc06                	sd	ra,56(sp)
    8000471a:	f822                	sd	s0,48(sp)
    8000471c:	f426                	sd	s1,40(sp)
    8000471e:	f04a                	sd	s2,32(sp)
    80004720:	ec4e                	sd	s3,24(sp)
    80004722:	e852                	sd	s4,16(sp)
    80004724:	e456                	sd	s5,8(sp)
    80004726:	e05a                	sd	s6,0(sp)
    80004728:	0080                	addi	s0,sp,64
    8000472a:	8b2a                	mv	s6,a0
    8000472c:	00021a97          	auipc	s5,0x21
    80004730:	a74a8a93          	addi	s5,s5,-1420 # 800251a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004734:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004736:	00021997          	auipc	s3,0x21
    8000473a:	a3a98993          	addi	s3,s3,-1478 # 80025170 <log>
    8000473e:	a00d                	j	80004760 <install_trans+0x56>
    brelse(lbuf);
    80004740:	854a                	mv	a0,s2
    80004742:	fffff097          	auipc	ra,0xfffff
    80004746:	084080e7          	jalr	132(ra) # 800037c6 <brelse>
    brelse(dbuf);
    8000474a:	8526                	mv	a0,s1
    8000474c:	fffff097          	auipc	ra,0xfffff
    80004750:	07a080e7          	jalr	122(ra) # 800037c6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004754:	2a05                	addiw	s4,s4,1
    80004756:	0a91                	addi	s5,s5,4
    80004758:	02c9a783          	lw	a5,44(s3)
    8000475c:	04fa5e63          	bge	s4,a5,800047b8 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004760:	0189a583          	lw	a1,24(s3)
    80004764:	014585bb          	addw	a1,a1,s4
    80004768:	2585                	addiw	a1,a1,1
    8000476a:	0289a503          	lw	a0,40(s3)
    8000476e:	fffff097          	auipc	ra,0xfffff
    80004772:	f28080e7          	jalr	-216(ra) # 80003696 <bread>
    80004776:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004778:	000aa583          	lw	a1,0(s5)
    8000477c:	0289a503          	lw	a0,40(s3)
    80004780:	fffff097          	auipc	ra,0xfffff
    80004784:	f16080e7          	jalr	-234(ra) # 80003696 <bread>
    80004788:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000478a:	40000613          	li	a2,1024
    8000478e:	05890593          	addi	a1,s2,88
    80004792:	05850513          	addi	a0,a0,88
    80004796:	ffffc097          	auipc	ra,0xffffc
    8000479a:	598080e7          	jalr	1432(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    8000479e:	8526                	mv	a0,s1
    800047a0:	fffff097          	auipc	ra,0xfffff
    800047a4:	fe8080e7          	jalr	-24(ra) # 80003788 <bwrite>
    if(recovering == 0)
    800047a8:	f80b1ce3          	bnez	s6,80004740 <install_trans+0x36>
      bunpin(dbuf);
    800047ac:	8526                	mv	a0,s1
    800047ae:	fffff097          	auipc	ra,0xfffff
    800047b2:	0f2080e7          	jalr	242(ra) # 800038a0 <bunpin>
    800047b6:	b769                	j	80004740 <install_trans+0x36>
}
    800047b8:	70e2                	ld	ra,56(sp)
    800047ba:	7442                	ld	s0,48(sp)
    800047bc:	74a2                	ld	s1,40(sp)
    800047be:	7902                	ld	s2,32(sp)
    800047c0:	69e2                	ld	s3,24(sp)
    800047c2:	6a42                	ld	s4,16(sp)
    800047c4:	6aa2                	ld	s5,8(sp)
    800047c6:	6b02                	ld	s6,0(sp)
    800047c8:	6121                	addi	sp,sp,64
    800047ca:	8082                	ret
    800047cc:	8082                	ret

00000000800047ce <initlog>:
{
    800047ce:	7179                	addi	sp,sp,-48
    800047d0:	f406                	sd	ra,40(sp)
    800047d2:	f022                	sd	s0,32(sp)
    800047d4:	ec26                	sd	s1,24(sp)
    800047d6:	e84a                	sd	s2,16(sp)
    800047d8:	e44e                	sd	s3,8(sp)
    800047da:	1800                	addi	s0,sp,48
    800047dc:	892a                	mv	s2,a0
    800047de:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800047e0:	00021497          	auipc	s1,0x21
    800047e4:	99048493          	addi	s1,s1,-1648 # 80025170 <log>
    800047e8:	00004597          	auipc	a1,0x4
    800047ec:	ea858593          	addi	a1,a1,-344 # 80008690 <syscalls+0x200>
    800047f0:	8526                	mv	a0,s1
    800047f2:	ffffc097          	auipc	ra,0xffffc
    800047f6:	354080e7          	jalr	852(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800047fa:	0149a583          	lw	a1,20(s3)
    800047fe:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004800:	0109a783          	lw	a5,16(s3)
    80004804:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004806:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000480a:	854a                	mv	a0,s2
    8000480c:	fffff097          	auipc	ra,0xfffff
    80004810:	e8a080e7          	jalr	-374(ra) # 80003696 <bread>
  log.lh.n = lh->n;
    80004814:	4d34                	lw	a3,88(a0)
    80004816:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004818:	02d05563          	blez	a3,80004842 <initlog+0x74>
    8000481c:	05c50793          	addi	a5,a0,92
    80004820:	00021717          	auipc	a4,0x21
    80004824:	98070713          	addi	a4,a4,-1664 # 800251a0 <log+0x30>
    80004828:	36fd                	addiw	a3,a3,-1
    8000482a:	1682                	slli	a3,a3,0x20
    8000482c:	9281                	srli	a3,a3,0x20
    8000482e:	068a                	slli	a3,a3,0x2
    80004830:	06050613          	addi	a2,a0,96
    80004834:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004836:	4390                	lw	a2,0(a5)
    80004838:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000483a:	0791                	addi	a5,a5,4
    8000483c:	0711                	addi	a4,a4,4
    8000483e:	fed79ce3          	bne	a5,a3,80004836 <initlog+0x68>
  brelse(buf);
    80004842:	fffff097          	auipc	ra,0xfffff
    80004846:	f84080e7          	jalr	-124(ra) # 800037c6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000484a:	4505                	li	a0,1
    8000484c:	00000097          	auipc	ra,0x0
    80004850:	ebe080e7          	jalr	-322(ra) # 8000470a <install_trans>
  log.lh.n = 0;
    80004854:	00021797          	auipc	a5,0x21
    80004858:	9407a423          	sw	zero,-1720(a5) # 8002519c <log+0x2c>
  write_head(); // clear the log
    8000485c:	00000097          	auipc	ra,0x0
    80004860:	e34080e7          	jalr	-460(ra) # 80004690 <write_head>
}
    80004864:	70a2                	ld	ra,40(sp)
    80004866:	7402                	ld	s0,32(sp)
    80004868:	64e2                	ld	s1,24(sp)
    8000486a:	6942                	ld	s2,16(sp)
    8000486c:	69a2                	ld	s3,8(sp)
    8000486e:	6145                	addi	sp,sp,48
    80004870:	8082                	ret

0000000080004872 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004872:	1101                	addi	sp,sp,-32
    80004874:	ec06                	sd	ra,24(sp)
    80004876:	e822                	sd	s0,16(sp)
    80004878:	e426                	sd	s1,8(sp)
    8000487a:	e04a                	sd	s2,0(sp)
    8000487c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000487e:	00021517          	auipc	a0,0x21
    80004882:	8f250513          	addi	a0,a0,-1806 # 80025170 <log>
    80004886:	ffffc097          	auipc	ra,0xffffc
    8000488a:	350080e7          	jalr	848(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    8000488e:	00021497          	auipc	s1,0x21
    80004892:	8e248493          	addi	s1,s1,-1822 # 80025170 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004896:	4979                	li	s2,30
    80004898:	a039                	j	800048a6 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000489a:	85a6                	mv	a1,s1
    8000489c:	8526                	mv	a0,s1
    8000489e:	ffffe097          	auipc	ra,0xffffe
    800048a2:	8cc080e7          	jalr	-1844(ra) # 8000216a <sleep>
    if(log.committing){
    800048a6:	50dc                	lw	a5,36(s1)
    800048a8:	fbed                	bnez	a5,8000489a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800048aa:	509c                	lw	a5,32(s1)
    800048ac:	0017871b          	addiw	a4,a5,1
    800048b0:	0007069b          	sext.w	a3,a4
    800048b4:	0027179b          	slliw	a5,a4,0x2
    800048b8:	9fb9                	addw	a5,a5,a4
    800048ba:	0017979b          	slliw	a5,a5,0x1
    800048be:	54d8                	lw	a4,44(s1)
    800048c0:	9fb9                	addw	a5,a5,a4
    800048c2:	00f95963          	bge	s2,a5,800048d4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800048c6:	85a6                	mv	a1,s1
    800048c8:	8526                	mv	a0,s1
    800048ca:	ffffe097          	auipc	ra,0xffffe
    800048ce:	8a0080e7          	jalr	-1888(ra) # 8000216a <sleep>
    800048d2:	bfd1                	j	800048a6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800048d4:	00021517          	auipc	a0,0x21
    800048d8:	89c50513          	addi	a0,a0,-1892 # 80025170 <log>
    800048dc:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800048de:	ffffc097          	auipc	ra,0xffffc
    800048e2:	3ac080e7          	jalr	940(ra) # 80000c8a <release>
      break;
    }
  }
}
    800048e6:	60e2                	ld	ra,24(sp)
    800048e8:	6442                	ld	s0,16(sp)
    800048ea:	64a2                	ld	s1,8(sp)
    800048ec:	6902                	ld	s2,0(sp)
    800048ee:	6105                	addi	sp,sp,32
    800048f0:	8082                	ret

00000000800048f2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800048f2:	7139                	addi	sp,sp,-64
    800048f4:	fc06                	sd	ra,56(sp)
    800048f6:	f822                	sd	s0,48(sp)
    800048f8:	f426                	sd	s1,40(sp)
    800048fa:	f04a                	sd	s2,32(sp)
    800048fc:	ec4e                	sd	s3,24(sp)
    800048fe:	e852                	sd	s4,16(sp)
    80004900:	e456                	sd	s5,8(sp)
    80004902:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004904:	00021497          	auipc	s1,0x21
    80004908:	86c48493          	addi	s1,s1,-1940 # 80025170 <log>
    8000490c:	8526                	mv	a0,s1
    8000490e:	ffffc097          	auipc	ra,0xffffc
    80004912:	2c8080e7          	jalr	712(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004916:	509c                	lw	a5,32(s1)
    80004918:	37fd                	addiw	a5,a5,-1
    8000491a:	0007891b          	sext.w	s2,a5
    8000491e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004920:	50dc                	lw	a5,36(s1)
    80004922:	e7b9                	bnez	a5,80004970 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004924:	04091e63          	bnez	s2,80004980 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004928:	00021497          	auipc	s1,0x21
    8000492c:	84848493          	addi	s1,s1,-1976 # 80025170 <log>
    80004930:	4785                	li	a5,1
    80004932:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004934:	8526                	mv	a0,s1
    80004936:	ffffc097          	auipc	ra,0xffffc
    8000493a:	354080e7          	jalr	852(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000493e:	54dc                	lw	a5,44(s1)
    80004940:	06f04763          	bgtz	a5,800049ae <end_op+0xbc>
    acquire(&log.lock);
    80004944:	00021497          	auipc	s1,0x21
    80004948:	82c48493          	addi	s1,s1,-2004 # 80025170 <log>
    8000494c:	8526                	mv	a0,s1
    8000494e:	ffffc097          	auipc	ra,0xffffc
    80004952:	288080e7          	jalr	648(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004956:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000495a:	8526                	mv	a0,s1
    8000495c:	ffffe097          	auipc	ra,0xffffe
    80004960:	872080e7          	jalr	-1934(ra) # 800021ce <wakeup>
    release(&log.lock);
    80004964:	8526                	mv	a0,s1
    80004966:	ffffc097          	auipc	ra,0xffffc
    8000496a:	324080e7          	jalr	804(ra) # 80000c8a <release>
}
    8000496e:	a03d                	j	8000499c <end_op+0xaa>
    panic("log.committing");
    80004970:	00004517          	auipc	a0,0x4
    80004974:	d2850513          	addi	a0,a0,-728 # 80008698 <syscalls+0x208>
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	bc6080e7          	jalr	-1082(ra) # 8000053e <panic>
    wakeup(&log);
    80004980:	00020497          	auipc	s1,0x20
    80004984:	7f048493          	addi	s1,s1,2032 # 80025170 <log>
    80004988:	8526                	mv	a0,s1
    8000498a:	ffffe097          	auipc	ra,0xffffe
    8000498e:	844080e7          	jalr	-1980(ra) # 800021ce <wakeup>
  release(&log.lock);
    80004992:	8526                	mv	a0,s1
    80004994:	ffffc097          	auipc	ra,0xffffc
    80004998:	2f6080e7          	jalr	758(ra) # 80000c8a <release>
}
    8000499c:	70e2                	ld	ra,56(sp)
    8000499e:	7442                	ld	s0,48(sp)
    800049a0:	74a2                	ld	s1,40(sp)
    800049a2:	7902                	ld	s2,32(sp)
    800049a4:	69e2                	ld	s3,24(sp)
    800049a6:	6a42                	ld	s4,16(sp)
    800049a8:	6aa2                	ld	s5,8(sp)
    800049aa:	6121                	addi	sp,sp,64
    800049ac:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800049ae:	00020a97          	auipc	s5,0x20
    800049b2:	7f2a8a93          	addi	s5,s5,2034 # 800251a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800049b6:	00020a17          	auipc	s4,0x20
    800049ba:	7baa0a13          	addi	s4,s4,1978 # 80025170 <log>
    800049be:	018a2583          	lw	a1,24(s4)
    800049c2:	012585bb          	addw	a1,a1,s2
    800049c6:	2585                	addiw	a1,a1,1
    800049c8:	028a2503          	lw	a0,40(s4)
    800049cc:	fffff097          	auipc	ra,0xfffff
    800049d0:	cca080e7          	jalr	-822(ra) # 80003696 <bread>
    800049d4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800049d6:	000aa583          	lw	a1,0(s5)
    800049da:	028a2503          	lw	a0,40(s4)
    800049de:	fffff097          	auipc	ra,0xfffff
    800049e2:	cb8080e7          	jalr	-840(ra) # 80003696 <bread>
    800049e6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800049e8:	40000613          	li	a2,1024
    800049ec:	05850593          	addi	a1,a0,88
    800049f0:	05848513          	addi	a0,s1,88
    800049f4:	ffffc097          	auipc	ra,0xffffc
    800049f8:	33a080e7          	jalr	826(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800049fc:	8526                	mv	a0,s1
    800049fe:	fffff097          	auipc	ra,0xfffff
    80004a02:	d8a080e7          	jalr	-630(ra) # 80003788 <bwrite>
    brelse(from);
    80004a06:	854e                	mv	a0,s3
    80004a08:	fffff097          	auipc	ra,0xfffff
    80004a0c:	dbe080e7          	jalr	-578(ra) # 800037c6 <brelse>
    brelse(to);
    80004a10:	8526                	mv	a0,s1
    80004a12:	fffff097          	auipc	ra,0xfffff
    80004a16:	db4080e7          	jalr	-588(ra) # 800037c6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004a1a:	2905                	addiw	s2,s2,1
    80004a1c:	0a91                	addi	s5,s5,4
    80004a1e:	02ca2783          	lw	a5,44(s4)
    80004a22:	f8f94ee3          	blt	s2,a5,800049be <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004a26:	00000097          	auipc	ra,0x0
    80004a2a:	c6a080e7          	jalr	-918(ra) # 80004690 <write_head>
    install_trans(0); // Now install writes to home locations
    80004a2e:	4501                	li	a0,0
    80004a30:	00000097          	auipc	ra,0x0
    80004a34:	cda080e7          	jalr	-806(ra) # 8000470a <install_trans>
    log.lh.n = 0;
    80004a38:	00020797          	auipc	a5,0x20
    80004a3c:	7607a223          	sw	zero,1892(a5) # 8002519c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004a40:	00000097          	auipc	ra,0x0
    80004a44:	c50080e7          	jalr	-944(ra) # 80004690 <write_head>
    80004a48:	bdf5                	j	80004944 <end_op+0x52>

0000000080004a4a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004a4a:	1101                	addi	sp,sp,-32
    80004a4c:	ec06                	sd	ra,24(sp)
    80004a4e:	e822                	sd	s0,16(sp)
    80004a50:	e426                	sd	s1,8(sp)
    80004a52:	e04a                	sd	s2,0(sp)
    80004a54:	1000                	addi	s0,sp,32
    80004a56:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004a58:	00020917          	auipc	s2,0x20
    80004a5c:	71890913          	addi	s2,s2,1816 # 80025170 <log>
    80004a60:	854a                	mv	a0,s2
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	174080e7          	jalr	372(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004a6a:	02c92603          	lw	a2,44(s2)
    80004a6e:	47f5                	li	a5,29
    80004a70:	06c7c563          	blt	a5,a2,80004ada <log_write+0x90>
    80004a74:	00020797          	auipc	a5,0x20
    80004a78:	7187a783          	lw	a5,1816(a5) # 8002518c <log+0x1c>
    80004a7c:	37fd                	addiw	a5,a5,-1
    80004a7e:	04f65e63          	bge	a2,a5,80004ada <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a82:	00020797          	auipc	a5,0x20
    80004a86:	70e7a783          	lw	a5,1806(a5) # 80025190 <log+0x20>
    80004a8a:	06f05063          	blez	a5,80004aea <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a8e:	4781                	li	a5,0
    80004a90:	06c05563          	blez	a2,80004afa <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a94:	44cc                	lw	a1,12(s1)
    80004a96:	00020717          	auipc	a4,0x20
    80004a9a:	70a70713          	addi	a4,a4,1802 # 800251a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004a9e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004aa0:	4314                	lw	a3,0(a4)
    80004aa2:	04b68c63          	beq	a3,a1,80004afa <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004aa6:	2785                	addiw	a5,a5,1
    80004aa8:	0711                	addi	a4,a4,4
    80004aaa:	fef61be3          	bne	a2,a5,80004aa0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004aae:	0621                	addi	a2,a2,8
    80004ab0:	060a                	slli	a2,a2,0x2
    80004ab2:	00020797          	auipc	a5,0x20
    80004ab6:	6be78793          	addi	a5,a5,1726 # 80025170 <log>
    80004aba:	963e                	add	a2,a2,a5
    80004abc:	44dc                	lw	a5,12(s1)
    80004abe:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004ac0:	8526                	mv	a0,s1
    80004ac2:	fffff097          	auipc	ra,0xfffff
    80004ac6:	da2080e7          	jalr	-606(ra) # 80003864 <bpin>
    log.lh.n++;
    80004aca:	00020717          	auipc	a4,0x20
    80004ace:	6a670713          	addi	a4,a4,1702 # 80025170 <log>
    80004ad2:	575c                	lw	a5,44(a4)
    80004ad4:	2785                	addiw	a5,a5,1
    80004ad6:	d75c                	sw	a5,44(a4)
    80004ad8:	a835                	j	80004b14 <log_write+0xca>
    panic("too big a transaction");
    80004ada:	00004517          	auipc	a0,0x4
    80004ade:	bce50513          	addi	a0,a0,-1074 # 800086a8 <syscalls+0x218>
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	a5c080e7          	jalr	-1444(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004aea:	00004517          	auipc	a0,0x4
    80004aee:	bd650513          	addi	a0,a0,-1066 # 800086c0 <syscalls+0x230>
    80004af2:	ffffc097          	auipc	ra,0xffffc
    80004af6:	a4c080e7          	jalr	-1460(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004afa:	00878713          	addi	a4,a5,8
    80004afe:	00271693          	slli	a3,a4,0x2
    80004b02:	00020717          	auipc	a4,0x20
    80004b06:	66e70713          	addi	a4,a4,1646 # 80025170 <log>
    80004b0a:	9736                	add	a4,a4,a3
    80004b0c:	44d4                	lw	a3,12(s1)
    80004b0e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004b10:	faf608e3          	beq	a2,a5,80004ac0 <log_write+0x76>
  }
  release(&log.lock);
    80004b14:	00020517          	auipc	a0,0x20
    80004b18:	65c50513          	addi	a0,a0,1628 # 80025170 <log>
    80004b1c:	ffffc097          	auipc	ra,0xffffc
    80004b20:	16e080e7          	jalr	366(ra) # 80000c8a <release>
}
    80004b24:	60e2                	ld	ra,24(sp)
    80004b26:	6442                	ld	s0,16(sp)
    80004b28:	64a2                	ld	s1,8(sp)
    80004b2a:	6902                	ld	s2,0(sp)
    80004b2c:	6105                	addi	sp,sp,32
    80004b2e:	8082                	ret

0000000080004b30 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004b30:	1101                	addi	sp,sp,-32
    80004b32:	ec06                	sd	ra,24(sp)
    80004b34:	e822                	sd	s0,16(sp)
    80004b36:	e426                	sd	s1,8(sp)
    80004b38:	e04a                	sd	s2,0(sp)
    80004b3a:	1000                	addi	s0,sp,32
    80004b3c:	84aa                	mv	s1,a0
    80004b3e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004b40:	00004597          	auipc	a1,0x4
    80004b44:	ba058593          	addi	a1,a1,-1120 # 800086e0 <syscalls+0x250>
    80004b48:	0521                	addi	a0,a0,8
    80004b4a:	ffffc097          	auipc	ra,0xffffc
    80004b4e:	ffc080e7          	jalr	-4(ra) # 80000b46 <initlock>
  lk->name = name;
    80004b52:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004b56:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b5a:	0204a423          	sw	zero,40(s1)
}
    80004b5e:	60e2                	ld	ra,24(sp)
    80004b60:	6442                	ld	s0,16(sp)
    80004b62:	64a2                	ld	s1,8(sp)
    80004b64:	6902                	ld	s2,0(sp)
    80004b66:	6105                	addi	sp,sp,32
    80004b68:	8082                	ret

0000000080004b6a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004b6a:	1101                	addi	sp,sp,-32
    80004b6c:	ec06                	sd	ra,24(sp)
    80004b6e:	e822                	sd	s0,16(sp)
    80004b70:	e426                	sd	s1,8(sp)
    80004b72:	e04a                	sd	s2,0(sp)
    80004b74:	1000                	addi	s0,sp,32
    80004b76:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b78:	00850913          	addi	s2,a0,8
    80004b7c:	854a                	mv	a0,s2
    80004b7e:	ffffc097          	auipc	ra,0xffffc
    80004b82:	058080e7          	jalr	88(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004b86:	409c                	lw	a5,0(s1)
    80004b88:	cb89                	beqz	a5,80004b9a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b8a:	85ca                	mv	a1,s2
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	ffffd097          	auipc	ra,0xffffd
    80004b92:	5dc080e7          	jalr	1500(ra) # 8000216a <sleep>
  while (lk->locked) {
    80004b96:	409c                	lw	a5,0(s1)
    80004b98:	fbed                	bnez	a5,80004b8a <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004b9a:	4785                	li	a5,1
    80004b9c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b9e:	ffffd097          	auipc	ra,0xffffd
    80004ba2:	e2a080e7          	jalr	-470(ra) # 800019c8 <myproc>
    80004ba6:	591c                	lw	a5,48(a0)
    80004ba8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004baa:	854a                	mv	a0,s2
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	0de080e7          	jalr	222(ra) # 80000c8a <release>
}
    80004bb4:	60e2                	ld	ra,24(sp)
    80004bb6:	6442                	ld	s0,16(sp)
    80004bb8:	64a2                	ld	s1,8(sp)
    80004bba:	6902                	ld	s2,0(sp)
    80004bbc:	6105                	addi	sp,sp,32
    80004bbe:	8082                	ret

0000000080004bc0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004bc0:	1101                	addi	sp,sp,-32
    80004bc2:	ec06                	sd	ra,24(sp)
    80004bc4:	e822                	sd	s0,16(sp)
    80004bc6:	e426                	sd	s1,8(sp)
    80004bc8:	e04a                	sd	s2,0(sp)
    80004bca:	1000                	addi	s0,sp,32
    80004bcc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004bce:	00850913          	addi	s2,a0,8
    80004bd2:	854a                	mv	a0,s2
    80004bd4:	ffffc097          	auipc	ra,0xffffc
    80004bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004bdc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004be0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004be4:	8526                	mv	a0,s1
    80004be6:	ffffd097          	auipc	ra,0xffffd
    80004bea:	5e8080e7          	jalr	1512(ra) # 800021ce <wakeup>
  release(&lk->lk);
    80004bee:	854a                	mv	a0,s2
    80004bf0:	ffffc097          	auipc	ra,0xffffc
    80004bf4:	09a080e7          	jalr	154(ra) # 80000c8a <release>
}
    80004bf8:	60e2                	ld	ra,24(sp)
    80004bfa:	6442                	ld	s0,16(sp)
    80004bfc:	64a2                	ld	s1,8(sp)
    80004bfe:	6902                	ld	s2,0(sp)
    80004c00:	6105                	addi	sp,sp,32
    80004c02:	8082                	ret

0000000080004c04 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004c04:	7179                	addi	sp,sp,-48
    80004c06:	f406                	sd	ra,40(sp)
    80004c08:	f022                	sd	s0,32(sp)
    80004c0a:	ec26                	sd	s1,24(sp)
    80004c0c:	e84a                	sd	s2,16(sp)
    80004c0e:	e44e                	sd	s3,8(sp)
    80004c10:	1800                	addi	s0,sp,48
    80004c12:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004c14:	00850913          	addi	s2,a0,8
    80004c18:	854a                	mv	a0,s2
    80004c1a:	ffffc097          	auipc	ra,0xffffc
    80004c1e:	fbc080e7          	jalr	-68(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c22:	409c                	lw	a5,0(s1)
    80004c24:	ef99                	bnez	a5,80004c42 <holdingsleep+0x3e>
    80004c26:	4481                	li	s1,0
  release(&lk->lk);
    80004c28:	854a                	mv	a0,s2
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	060080e7          	jalr	96(ra) # 80000c8a <release>
  return r;
}
    80004c32:	8526                	mv	a0,s1
    80004c34:	70a2                	ld	ra,40(sp)
    80004c36:	7402                	ld	s0,32(sp)
    80004c38:	64e2                	ld	s1,24(sp)
    80004c3a:	6942                	ld	s2,16(sp)
    80004c3c:	69a2                	ld	s3,8(sp)
    80004c3e:	6145                	addi	sp,sp,48
    80004c40:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004c42:	0284a983          	lw	s3,40(s1)
    80004c46:	ffffd097          	auipc	ra,0xffffd
    80004c4a:	d82080e7          	jalr	-638(ra) # 800019c8 <myproc>
    80004c4e:	5904                	lw	s1,48(a0)
    80004c50:	413484b3          	sub	s1,s1,s3
    80004c54:	0014b493          	seqz	s1,s1
    80004c58:	bfc1                	j	80004c28 <holdingsleep+0x24>

0000000080004c5a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004c5a:	1141                	addi	sp,sp,-16
    80004c5c:	e406                	sd	ra,8(sp)
    80004c5e:	e022                	sd	s0,0(sp)
    80004c60:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004c62:	00004597          	auipc	a1,0x4
    80004c66:	a8e58593          	addi	a1,a1,-1394 # 800086f0 <syscalls+0x260>
    80004c6a:	00020517          	auipc	a0,0x20
    80004c6e:	64e50513          	addi	a0,a0,1614 # 800252b8 <ftable>
    80004c72:	ffffc097          	auipc	ra,0xffffc
    80004c76:	ed4080e7          	jalr	-300(ra) # 80000b46 <initlock>
}
    80004c7a:	60a2                	ld	ra,8(sp)
    80004c7c:	6402                	ld	s0,0(sp)
    80004c7e:	0141                	addi	sp,sp,16
    80004c80:	8082                	ret

0000000080004c82 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c82:	1101                	addi	sp,sp,-32
    80004c84:	ec06                	sd	ra,24(sp)
    80004c86:	e822                	sd	s0,16(sp)
    80004c88:	e426                	sd	s1,8(sp)
    80004c8a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c8c:	00020517          	auipc	a0,0x20
    80004c90:	62c50513          	addi	a0,a0,1580 # 800252b8 <ftable>
    80004c94:	ffffc097          	auipc	ra,0xffffc
    80004c98:	f42080e7          	jalr	-190(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c9c:	00020497          	auipc	s1,0x20
    80004ca0:	63448493          	addi	s1,s1,1588 # 800252d0 <ftable+0x18>
    80004ca4:	00021717          	auipc	a4,0x21
    80004ca8:	5cc70713          	addi	a4,a4,1484 # 80026270 <disk>
    if(f->ref == 0){
    80004cac:	40dc                	lw	a5,4(s1)
    80004cae:	cf99                	beqz	a5,80004ccc <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004cb0:	02848493          	addi	s1,s1,40
    80004cb4:	fee49ce3          	bne	s1,a4,80004cac <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004cb8:	00020517          	auipc	a0,0x20
    80004cbc:	60050513          	addi	a0,a0,1536 # 800252b8 <ftable>
    80004cc0:	ffffc097          	auipc	ra,0xffffc
    80004cc4:	fca080e7          	jalr	-54(ra) # 80000c8a <release>
  return 0;
    80004cc8:	4481                	li	s1,0
    80004cca:	a819                	j	80004ce0 <filealloc+0x5e>
      f->ref = 1;
    80004ccc:	4785                	li	a5,1
    80004cce:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004cd0:	00020517          	auipc	a0,0x20
    80004cd4:	5e850513          	addi	a0,a0,1512 # 800252b8 <ftable>
    80004cd8:	ffffc097          	auipc	ra,0xffffc
    80004cdc:	fb2080e7          	jalr	-78(ra) # 80000c8a <release>
}
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	60e2                	ld	ra,24(sp)
    80004ce4:	6442                	ld	s0,16(sp)
    80004ce6:	64a2                	ld	s1,8(sp)
    80004ce8:	6105                	addi	sp,sp,32
    80004cea:	8082                	ret

0000000080004cec <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004cec:	1101                	addi	sp,sp,-32
    80004cee:	ec06                	sd	ra,24(sp)
    80004cf0:	e822                	sd	s0,16(sp)
    80004cf2:	e426                	sd	s1,8(sp)
    80004cf4:	1000                	addi	s0,sp,32
    80004cf6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004cf8:	00020517          	auipc	a0,0x20
    80004cfc:	5c050513          	addi	a0,a0,1472 # 800252b8 <ftable>
    80004d00:	ffffc097          	auipc	ra,0xffffc
    80004d04:	ed6080e7          	jalr	-298(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004d08:	40dc                	lw	a5,4(s1)
    80004d0a:	02f05263          	blez	a5,80004d2e <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004d0e:	2785                	addiw	a5,a5,1
    80004d10:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004d12:	00020517          	auipc	a0,0x20
    80004d16:	5a650513          	addi	a0,a0,1446 # 800252b8 <ftable>
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	f70080e7          	jalr	-144(ra) # 80000c8a <release>
  return f;
}
    80004d22:	8526                	mv	a0,s1
    80004d24:	60e2                	ld	ra,24(sp)
    80004d26:	6442                	ld	s0,16(sp)
    80004d28:	64a2                	ld	s1,8(sp)
    80004d2a:	6105                	addi	sp,sp,32
    80004d2c:	8082                	ret
    panic("filedup");
    80004d2e:	00004517          	auipc	a0,0x4
    80004d32:	9ca50513          	addi	a0,a0,-1590 # 800086f8 <syscalls+0x268>
    80004d36:	ffffc097          	auipc	ra,0xffffc
    80004d3a:	808080e7          	jalr	-2040(ra) # 8000053e <panic>

0000000080004d3e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004d3e:	7139                	addi	sp,sp,-64
    80004d40:	fc06                	sd	ra,56(sp)
    80004d42:	f822                	sd	s0,48(sp)
    80004d44:	f426                	sd	s1,40(sp)
    80004d46:	f04a                	sd	s2,32(sp)
    80004d48:	ec4e                	sd	s3,24(sp)
    80004d4a:	e852                	sd	s4,16(sp)
    80004d4c:	e456                	sd	s5,8(sp)
    80004d4e:	0080                	addi	s0,sp,64
    80004d50:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004d52:	00020517          	auipc	a0,0x20
    80004d56:	56650513          	addi	a0,a0,1382 # 800252b8 <ftable>
    80004d5a:	ffffc097          	auipc	ra,0xffffc
    80004d5e:	e7c080e7          	jalr	-388(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004d62:	40dc                	lw	a5,4(s1)
    80004d64:	06f05163          	blez	a5,80004dc6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004d68:	37fd                	addiw	a5,a5,-1
    80004d6a:	0007871b          	sext.w	a4,a5
    80004d6e:	c0dc                	sw	a5,4(s1)
    80004d70:	06e04363          	bgtz	a4,80004dd6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004d74:	0004a903          	lw	s2,0(s1)
    80004d78:	0094ca83          	lbu	s5,9(s1)
    80004d7c:	0104ba03          	ld	s4,16(s1)
    80004d80:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d84:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d88:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d8c:	00020517          	auipc	a0,0x20
    80004d90:	52c50513          	addi	a0,a0,1324 # 800252b8 <ftable>
    80004d94:	ffffc097          	auipc	ra,0xffffc
    80004d98:	ef6080e7          	jalr	-266(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004d9c:	4785                	li	a5,1
    80004d9e:	04f90d63          	beq	s2,a5,80004df8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004da2:	3979                	addiw	s2,s2,-2
    80004da4:	4785                	li	a5,1
    80004da6:	0527e063          	bltu	a5,s2,80004de6 <fileclose+0xa8>
    begin_op();
    80004daa:	00000097          	auipc	ra,0x0
    80004dae:	ac8080e7          	jalr	-1336(ra) # 80004872 <begin_op>
    iput(ff.ip);
    80004db2:	854e                	mv	a0,s3
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	2b6080e7          	jalr	694(ra) # 8000406a <iput>
    end_op();
    80004dbc:	00000097          	auipc	ra,0x0
    80004dc0:	b36080e7          	jalr	-1226(ra) # 800048f2 <end_op>
    80004dc4:	a00d                	j	80004de6 <fileclose+0xa8>
    panic("fileclose");
    80004dc6:	00004517          	auipc	a0,0x4
    80004dca:	93a50513          	addi	a0,a0,-1734 # 80008700 <syscalls+0x270>
    80004dce:	ffffb097          	auipc	ra,0xffffb
    80004dd2:	770080e7          	jalr	1904(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004dd6:	00020517          	auipc	a0,0x20
    80004dda:	4e250513          	addi	a0,a0,1250 # 800252b8 <ftable>
    80004dde:	ffffc097          	auipc	ra,0xffffc
    80004de2:	eac080e7          	jalr	-340(ra) # 80000c8a <release>
  }
}
    80004de6:	70e2                	ld	ra,56(sp)
    80004de8:	7442                	ld	s0,48(sp)
    80004dea:	74a2                	ld	s1,40(sp)
    80004dec:	7902                	ld	s2,32(sp)
    80004dee:	69e2                	ld	s3,24(sp)
    80004df0:	6a42                	ld	s4,16(sp)
    80004df2:	6aa2                	ld	s5,8(sp)
    80004df4:	6121                	addi	sp,sp,64
    80004df6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004df8:	85d6                	mv	a1,s5
    80004dfa:	8552                	mv	a0,s4
    80004dfc:	00000097          	auipc	ra,0x0
    80004e00:	34c080e7          	jalr	844(ra) # 80005148 <pipeclose>
    80004e04:	b7cd                	j	80004de6 <fileclose+0xa8>

0000000080004e06 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004e06:	715d                	addi	sp,sp,-80
    80004e08:	e486                	sd	ra,72(sp)
    80004e0a:	e0a2                	sd	s0,64(sp)
    80004e0c:	fc26                	sd	s1,56(sp)
    80004e0e:	f84a                	sd	s2,48(sp)
    80004e10:	f44e                	sd	s3,40(sp)
    80004e12:	0880                	addi	s0,sp,80
    80004e14:	84aa                	mv	s1,a0
    80004e16:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004e18:	ffffd097          	auipc	ra,0xffffd
    80004e1c:	bb0080e7          	jalr	-1104(ra) # 800019c8 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004e20:	409c                	lw	a5,0(s1)
    80004e22:	37f9                	addiw	a5,a5,-2
    80004e24:	4705                	li	a4,1
    80004e26:	04f76763          	bltu	a4,a5,80004e74 <filestat+0x6e>
    80004e2a:	892a                	mv	s2,a0
    ilock(f->ip);
    80004e2c:	6c88                	ld	a0,24(s1)
    80004e2e:	fffff097          	auipc	ra,0xfffff
    80004e32:	082080e7          	jalr	130(ra) # 80003eb0 <ilock>
    stati(f->ip, &st);
    80004e36:	fb840593          	addi	a1,s0,-72
    80004e3a:	6c88                	ld	a0,24(s1)
    80004e3c:	fffff097          	auipc	ra,0xfffff
    80004e40:	2fe080e7          	jalr	766(ra) # 8000413a <stati>
    iunlock(f->ip);
    80004e44:	6c88                	ld	a0,24(s1)
    80004e46:	fffff097          	auipc	ra,0xfffff
    80004e4a:	12c080e7          	jalr	300(ra) # 80003f72 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004e4e:	46e1                	li	a3,24
    80004e50:	fb840613          	addi	a2,s0,-72
    80004e54:	85ce                	mv	a1,s3
    80004e56:	15893503          	ld	a0,344(s2)
    80004e5a:	ffffd097          	auipc	ra,0xffffd
    80004e5e:	80e080e7          	jalr	-2034(ra) # 80001668 <copyout>
    80004e62:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004e66:	60a6                	ld	ra,72(sp)
    80004e68:	6406                	ld	s0,64(sp)
    80004e6a:	74e2                	ld	s1,56(sp)
    80004e6c:	7942                	ld	s2,48(sp)
    80004e6e:	79a2                	ld	s3,40(sp)
    80004e70:	6161                	addi	sp,sp,80
    80004e72:	8082                	ret
  return -1;
    80004e74:	557d                	li	a0,-1
    80004e76:	bfc5                	j	80004e66 <filestat+0x60>

0000000080004e78 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e78:	7179                	addi	sp,sp,-48
    80004e7a:	f406                	sd	ra,40(sp)
    80004e7c:	f022                	sd	s0,32(sp)
    80004e7e:	ec26                	sd	s1,24(sp)
    80004e80:	e84a                	sd	s2,16(sp)
    80004e82:	e44e                	sd	s3,8(sp)
    80004e84:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e86:	00854783          	lbu	a5,8(a0)
    80004e8a:	c3d5                	beqz	a5,80004f2e <fileread+0xb6>
    80004e8c:	84aa                	mv	s1,a0
    80004e8e:	89ae                	mv	s3,a1
    80004e90:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e92:	411c                	lw	a5,0(a0)
    80004e94:	4705                	li	a4,1
    80004e96:	04e78963          	beq	a5,a4,80004ee8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e9a:	470d                	li	a4,3
    80004e9c:	04e78d63          	beq	a5,a4,80004ef6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ea0:	4709                	li	a4,2
    80004ea2:	06e79e63          	bne	a5,a4,80004f1e <fileread+0xa6>
    ilock(f->ip);
    80004ea6:	6d08                	ld	a0,24(a0)
    80004ea8:	fffff097          	auipc	ra,0xfffff
    80004eac:	008080e7          	jalr	8(ra) # 80003eb0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004eb0:	874a                	mv	a4,s2
    80004eb2:	5094                	lw	a3,32(s1)
    80004eb4:	864e                	mv	a2,s3
    80004eb6:	4585                	li	a1,1
    80004eb8:	6c88                	ld	a0,24(s1)
    80004eba:	fffff097          	auipc	ra,0xfffff
    80004ebe:	2aa080e7          	jalr	682(ra) # 80004164 <readi>
    80004ec2:	892a                	mv	s2,a0
    80004ec4:	00a05563          	blez	a0,80004ece <fileread+0x56>
      f->off += r;
    80004ec8:	509c                	lw	a5,32(s1)
    80004eca:	9fa9                	addw	a5,a5,a0
    80004ecc:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004ece:	6c88                	ld	a0,24(s1)
    80004ed0:	fffff097          	auipc	ra,0xfffff
    80004ed4:	0a2080e7          	jalr	162(ra) # 80003f72 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004ed8:	854a                	mv	a0,s2
    80004eda:	70a2                	ld	ra,40(sp)
    80004edc:	7402                	ld	s0,32(sp)
    80004ede:	64e2                	ld	s1,24(sp)
    80004ee0:	6942                	ld	s2,16(sp)
    80004ee2:	69a2                	ld	s3,8(sp)
    80004ee4:	6145                	addi	sp,sp,48
    80004ee6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ee8:	6908                	ld	a0,16(a0)
    80004eea:	00000097          	auipc	ra,0x0
    80004eee:	3c6080e7          	jalr	966(ra) # 800052b0 <piperead>
    80004ef2:	892a                	mv	s2,a0
    80004ef4:	b7d5                	j	80004ed8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004ef6:	02451783          	lh	a5,36(a0)
    80004efa:	03079693          	slli	a3,a5,0x30
    80004efe:	92c1                	srli	a3,a3,0x30
    80004f00:	4725                	li	a4,9
    80004f02:	02d76863          	bltu	a4,a3,80004f32 <fileread+0xba>
    80004f06:	0792                	slli	a5,a5,0x4
    80004f08:	00020717          	auipc	a4,0x20
    80004f0c:	31070713          	addi	a4,a4,784 # 80025218 <devsw>
    80004f10:	97ba                	add	a5,a5,a4
    80004f12:	639c                	ld	a5,0(a5)
    80004f14:	c38d                	beqz	a5,80004f36 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004f16:	4505                	li	a0,1
    80004f18:	9782                	jalr	a5
    80004f1a:	892a                	mv	s2,a0
    80004f1c:	bf75                	j	80004ed8 <fileread+0x60>
    panic("fileread");
    80004f1e:	00003517          	auipc	a0,0x3
    80004f22:	7f250513          	addi	a0,a0,2034 # 80008710 <syscalls+0x280>
    80004f26:	ffffb097          	auipc	ra,0xffffb
    80004f2a:	618080e7          	jalr	1560(ra) # 8000053e <panic>
    return -1;
    80004f2e:	597d                	li	s2,-1
    80004f30:	b765                	j	80004ed8 <fileread+0x60>
      return -1;
    80004f32:	597d                	li	s2,-1
    80004f34:	b755                	j	80004ed8 <fileread+0x60>
    80004f36:	597d                	li	s2,-1
    80004f38:	b745                	j	80004ed8 <fileread+0x60>

0000000080004f3a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004f3a:	715d                	addi	sp,sp,-80
    80004f3c:	e486                	sd	ra,72(sp)
    80004f3e:	e0a2                	sd	s0,64(sp)
    80004f40:	fc26                	sd	s1,56(sp)
    80004f42:	f84a                	sd	s2,48(sp)
    80004f44:	f44e                	sd	s3,40(sp)
    80004f46:	f052                	sd	s4,32(sp)
    80004f48:	ec56                	sd	s5,24(sp)
    80004f4a:	e85a                	sd	s6,16(sp)
    80004f4c:	e45e                	sd	s7,8(sp)
    80004f4e:	e062                	sd	s8,0(sp)
    80004f50:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004f52:	00954783          	lbu	a5,9(a0)
    80004f56:	10078663          	beqz	a5,80005062 <filewrite+0x128>
    80004f5a:	892a                	mv	s2,a0
    80004f5c:	8aae                	mv	s5,a1
    80004f5e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004f60:	411c                	lw	a5,0(a0)
    80004f62:	4705                	li	a4,1
    80004f64:	02e78263          	beq	a5,a4,80004f88 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004f68:	470d                	li	a4,3
    80004f6a:	02e78663          	beq	a5,a4,80004f96 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004f6e:	4709                	li	a4,2
    80004f70:	0ee79163          	bne	a5,a4,80005052 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004f74:	0ac05d63          	blez	a2,8000502e <filewrite+0xf4>
    int i = 0;
    80004f78:	4981                	li	s3,0
    80004f7a:	6b05                	lui	s6,0x1
    80004f7c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004f80:	6b85                	lui	s7,0x1
    80004f82:	c00b8b9b          	addiw	s7,s7,-1024
    80004f86:	a861                	j	8000501e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004f88:	6908                	ld	a0,16(a0)
    80004f8a:	00000097          	auipc	ra,0x0
    80004f8e:	22e080e7          	jalr	558(ra) # 800051b8 <pipewrite>
    80004f92:	8a2a                	mv	s4,a0
    80004f94:	a045                	j	80005034 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f96:	02451783          	lh	a5,36(a0)
    80004f9a:	03079693          	slli	a3,a5,0x30
    80004f9e:	92c1                	srli	a3,a3,0x30
    80004fa0:	4725                	li	a4,9
    80004fa2:	0cd76263          	bltu	a4,a3,80005066 <filewrite+0x12c>
    80004fa6:	0792                	slli	a5,a5,0x4
    80004fa8:	00020717          	auipc	a4,0x20
    80004fac:	27070713          	addi	a4,a4,624 # 80025218 <devsw>
    80004fb0:	97ba                	add	a5,a5,a4
    80004fb2:	679c                	ld	a5,8(a5)
    80004fb4:	cbdd                	beqz	a5,8000506a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004fb6:	4505                	li	a0,1
    80004fb8:	9782                	jalr	a5
    80004fba:	8a2a                	mv	s4,a0
    80004fbc:	a8a5                	j	80005034 <filewrite+0xfa>
    80004fbe:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004fc2:	00000097          	auipc	ra,0x0
    80004fc6:	8b0080e7          	jalr	-1872(ra) # 80004872 <begin_op>
      ilock(f->ip);
    80004fca:	01893503          	ld	a0,24(s2)
    80004fce:	fffff097          	auipc	ra,0xfffff
    80004fd2:	ee2080e7          	jalr	-286(ra) # 80003eb0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004fd6:	8762                	mv	a4,s8
    80004fd8:	02092683          	lw	a3,32(s2)
    80004fdc:	01598633          	add	a2,s3,s5
    80004fe0:	4585                	li	a1,1
    80004fe2:	01893503          	ld	a0,24(s2)
    80004fe6:	fffff097          	auipc	ra,0xfffff
    80004fea:	276080e7          	jalr	630(ra) # 8000425c <writei>
    80004fee:	84aa                	mv	s1,a0
    80004ff0:	00a05763          	blez	a0,80004ffe <filewrite+0xc4>
        f->off += r;
    80004ff4:	02092783          	lw	a5,32(s2)
    80004ff8:	9fa9                	addw	a5,a5,a0
    80004ffa:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ffe:	01893503          	ld	a0,24(s2)
    80005002:	fffff097          	auipc	ra,0xfffff
    80005006:	f70080e7          	jalr	-144(ra) # 80003f72 <iunlock>
      end_op();
    8000500a:	00000097          	auipc	ra,0x0
    8000500e:	8e8080e7          	jalr	-1816(ra) # 800048f2 <end_op>

      if(r != n1){
    80005012:	009c1f63          	bne	s8,s1,80005030 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005016:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000501a:	0149db63          	bge	s3,s4,80005030 <filewrite+0xf6>
      int n1 = n - i;
    8000501e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005022:	84be                	mv	s1,a5
    80005024:	2781                	sext.w	a5,a5
    80005026:	f8fb5ce3          	bge	s6,a5,80004fbe <filewrite+0x84>
    8000502a:	84de                	mv	s1,s7
    8000502c:	bf49                	j	80004fbe <filewrite+0x84>
    int i = 0;
    8000502e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005030:	013a1f63          	bne	s4,s3,8000504e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005034:	8552                	mv	a0,s4
    80005036:	60a6                	ld	ra,72(sp)
    80005038:	6406                	ld	s0,64(sp)
    8000503a:	74e2                	ld	s1,56(sp)
    8000503c:	7942                	ld	s2,48(sp)
    8000503e:	79a2                	ld	s3,40(sp)
    80005040:	7a02                	ld	s4,32(sp)
    80005042:	6ae2                	ld	s5,24(sp)
    80005044:	6b42                	ld	s6,16(sp)
    80005046:	6ba2                	ld	s7,8(sp)
    80005048:	6c02                	ld	s8,0(sp)
    8000504a:	6161                	addi	sp,sp,80
    8000504c:	8082                	ret
    ret = (i == n ? n : -1);
    8000504e:	5a7d                	li	s4,-1
    80005050:	b7d5                	j	80005034 <filewrite+0xfa>
    panic("filewrite");
    80005052:	00003517          	auipc	a0,0x3
    80005056:	6ce50513          	addi	a0,a0,1742 # 80008720 <syscalls+0x290>
    8000505a:	ffffb097          	auipc	ra,0xffffb
    8000505e:	4e4080e7          	jalr	1252(ra) # 8000053e <panic>
    return -1;
    80005062:	5a7d                	li	s4,-1
    80005064:	bfc1                	j	80005034 <filewrite+0xfa>
      return -1;
    80005066:	5a7d                	li	s4,-1
    80005068:	b7f1                	j	80005034 <filewrite+0xfa>
    8000506a:	5a7d                	li	s4,-1
    8000506c:	b7e1                	j	80005034 <filewrite+0xfa>

000000008000506e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000506e:	7179                	addi	sp,sp,-48
    80005070:	f406                	sd	ra,40(sp)
    80005072:	f022                	sd	s0,32(sp)
    80005074:	ec26                	sd	s1,24(sp)
    80005076:	e84a                	sd	s2,16(sp)
    80005078:	e44e                	sd	s3,8(sp)
    8000507a:	e052                	sd	s4,0(sp)
    8000507c:	1800                	addi	s0,sp,48
    8000507e:	84aa                	mv	s1,a0
    80005080:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005082:	0005b023          	sd	zero,0(a1)
    80005086:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000508a:	00000097          	auipc	ra,0x0
    8000508e:	bf8080e7          	jalr	-1032(ra) # 80004c82 <filealloc>
    80005092:	e088                	sd	a0,0(s1)
    80005094:	c551                	beqz	a0,80005120 <pipealloc+0xb2>
    80005096:	00000097          	auipc	ra,0x0
    8000509a:	bec080e7          	jalr	-1044(ra) # 80004c82 <filealloc>
    8000509e:	00aa3023          	sd	a0,0(s4)
    800050a2:	c92d                	beqz	a0,80005114 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	a42080e7          	jalr	-1470(ra) # 80000ae6 <kalloc>
    800050ac:	892a                	mv	s2,a0
    800050ae:	c125                	beqz	a0,8000510e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800050b0:	4985                	li	s3,1
    800050b2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800050b6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800050ba:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800050be:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800050c2:	00003597          	auipc	a1,0x3
    800050c6:	66e58593          	addi	a1,a1,1646 # 80008730 <syscalls+0x2a0>
    800050ca:	ffffc097          	auipc	ra,0xffffc
    800050ce:	a7c080e7          	jalr	-1412(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    800050d2:	609c                	ld	a5,0(s1)
    800050d4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800050d8:	609c                	ld	a5,0(s1)
    800050da:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800050de:	609c                	ld	a5,0(s1)
    800050e0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800050e4:	609c                	ld	a5,0(s1)
    800050e6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800050ea:	000a3783          	ld	a5,0(s4)
    800050ee:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800050f2:	000a3783          	ld	a5,0(s4)
    800050f6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800050fa:	000a3783          	ld	a5,0(s4)
    800050fe:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005102:	000a3783          	ld	a5,0(s4)
    80005106:	0127b823          	sd	s2,16(a5)
  return 0;
    8000510a:	4501                	li	a0,0
    8000510c:	a025                	j	80005134 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000510e:	6088                	ld	a0,0(s1)
    80005110:	e501                	bnez	a0,80005118 <pipealloc+0xaa>
    80005112:	a039                	j	80005120 <pipealloc+0xb2>
    80005114:	6088                	ld	a0,0(s1)
    80005116:	c51d                	beqz	a0,80005144 <pipealloc+0xd6>
    fileclose(*f0);
    80005118:	00000097          	auipc	ra,0x0
    8000511c:	c26080e7          	jalr	-986(ra) # 80004d3e <fileclose>
  if(*f1)
    80005120:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005124:	557d                	li	a0,-1
  if(*f1)
    80005126:	c799                	beqz	a5,80005134 <pipealloc+0xc6>
    fileclose(*f1);
    80005128:	853e                	mv	a0,a5
    8000512a:	00000097          	auipc	ra,0x0
    8000512e:	c14080e7          	jalr	-1004(ra) # 80004d3e <fileclose>
  return -1;
    80005132:	557d                	li	a0,-1
}
    80005134:	70a2                	ld	ra,40(sp)
    80005136:	7402                	ld	s0,32(sp)
    80005138:	64e2                	ld	s1,24(sp)
    8000513a:	6942                	ld	s2,16(sp)
    8000513c:	69a2                	ld	s3,8(sp)
    8000513e:	6a02                	ld	s4,0(sp)
    80005140:	6145                	addi	sp,sp,48
    80005142:	8082                	ret
  return -1;
    80005144:	557d                	li	a0,-1
    80005146:	b7fd                	j	80005134 <pipealloc+0xc6>

0000000080005148 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005148:	1101                	addi	sp,sp,-32
    8000514a:	ec06                	sd	ra,24(sp)
    8000514c:	e822                	sd	s0,16(sp)
    8000514e:	e426                	sd	s1,8(sp)
    80005150:	e04a                	sd	s2,0(sp)
    80005152:	1000                	addi	s0,sp,32
    80005154:	84aa                	mv	s1,a0
    80005156:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005158:	ffffc097          	auipc	ra,0xffffc
    8000515c:	a7e080e7          	jalr	-1410(ra) # 80000bd6 <acquire>
  if(writable){
    80005160:	02090d63          	beqz	s2,8000519a <pipeclose+0x52>
    pi->writeopen = 0;
    80005164:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005168:	21848513          	addi	a0,s1,536
    8000516c:	ffffd097          	auipc	ra,0xffffd
    80005170:	062080e7          	jalr	98(ra) # 800021ce <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005174:	2204b783          	ld	a5,544(s1)
    80005178:	eb95                	bnez	a5,800051ac <pipeclose+0x64>
    release(&pi->lock);
    8000517a:	8526                	mv	a0,s1
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	b0e080e7          	jalr	-1266(ra) # 80000c8a <release>
    kfree((char*)pi);
    80005184:	8526                	mv	a0,s1
    80005186:	ffffc097          	auipc	ra,0xffffc
    8000518a:	864080e7          	jalr	-1948(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    8000518e:	60e2                	ld	ra,24(sp)
    80005190:	6442                	ld	s0,16(sp)
    80005192:	64a2                	ld	s1,8(sp)
    80005194:	6902                	ld	s2,0(sp)
    80005196:	6105                	addi	sp,sp,32
    80005198:	8082                	ret
    pi->readopen = 0;
    8000519a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000519e:	21c48513          	addi	a0,s1,540
    800051a2:	ffffd097          	auipc	ra,0xffffd
    800051a6:	02c080e7          	jalr	44(ra) # 800021ce <wakeup>
    800051aa:	b7e9                	j	80005174 <pipeclose+0x2c>
    release(&pi->lock);
    800051ac:	8526                	mv	a0,s1
    800051ae:	ffffc097          	auipc	ra,0xffffc
    800051b2:	adc080e7          	jalr	-1316(ra) # 80000c8a <release>
}
    800051b6:	bfe1                	j	8000518e <pipeclose+0x46>

00000000800051b8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800051b8:	711d                	addi	sp,sp,-96
    800051ba:	ec86                	sd	ra,88(sp)
    800051bc:	e8a2                	sd	s0,80(sp)
    800051be:	e4a6                	sd	s1,72(sp)
    800051c0:	e0ca                	sd	s2,64(sp)
    800051c2:	fc4e                	sd	s3,56(sp)
    800051c4:	f852                	sd	s4,48(sp)
    800051c6:	f456                	sd	s5,40(sp)
    800051c8:	f05a                	sd	s6,32(sp)
    800051ca:	ec5e                	sd	s7,24(sp)
    800051cc:	e862                	sd	s8,16(sp)
    800051ce:	1080                	addi	s0,sp,96
    800051d0:	84aa                	mv	s1,a0
    800051d2:	8aae                	mv	s5,a1
    800051d4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800051d6:	ffffc097          	auipc	ra,0xffffc
    800051da:	7f2080e7          	jalr	2034(ra) # 800019c8 <myproc>
    800051de:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800051e0:	8526                	mv	a0,s1
    800051e2:	ffffc097          	auipc	ra,0xffffc
    800051e6:	9f4080e7          	jalr	-1548(ra) # 80000bd6 <acquire>
  while(i < n){
    800051ea:	0b405663          	blez	s4,80005296 <pipewrite+0xde>
  int i = 0;
    800051ee:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051f0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800051f2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800051f6:	21c48b93          	addi	s7,s1,540
    800051fa:	a089                	j	8000523c <pipewrite+0x84>
      release(&pi->lock);
    800051fc:	8526                	mv	a0,s1
    800051fe:	ffffc097          	auipc	ra,0xffffc
    80005202:	a8c080e7          	jalr	-1396(ra) # 80000c8a <release>
      return -1;
    80005206:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005208:	854a                	mv	a0,s2
    8000520a:	60e6                	ld	ra,88(sp)
    8000520c:	6446                	ld	s0,80(sp)
    8000520e:	64a6                	ld	s1,72(sp)
    80005210:	6906                	ld	s2,64(sp)
    80005212:	79e2                	ld	s3,56(sp)
    80005214:	7a42                	ld	s4,48(sp)
    80005216:	7aa2                	ld	s5,40(sp)
    80005218:	7b02                	ld	s6,32(sp)
    8000521a:	6be2                	ld	s7,24(sp)
    8000521c:	6c42                	ld	s8,16(sp)
    8000521e:	6125                	addi	sp,sp,96
    80005220:	8082                	ret
      wakeup(&pi->nread);
    80005222:	8562                	mv	a0,s8
    80005224:	ffffd097          	auipc	ra,0xffffd
    80005228:	faa080e7          	jalr	-86(ra) # 800021ce <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000522c:	85a6                	mv	a1,s1
    8000522e:	855e                	mv	a0,s7
    80005230:	ffffd097          	auipc	ra,0xffffd
    80005234:	f3a080e7          	jalr	-198(ra) # 8000216a <sleep>
  while(i < n){
    80005238:	07495063          	bge	s2,s4,80005298 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    8000523c:	2204a783          	lw	a5,544(s1)
    80005240:	dfd5                	beqz	a5,800051fc <pipewrite+0x44>
    80005242:	854e                	mv	a0,s3
    80005244:	ffffd097          	auipc	ra,0xffffd
    80005248:	1da080e7          	jalr	474(ra) # 8000241e <killed>
    8000524c:	f945                	bnez	a0,800051fc <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000524e:	2184a783          	lw	a5,536(s1)
    80005252:	21c4a703          	lw	a4,540(s1)
    80005256:	2007879b          	addiw	a5,a5,512
    8000525a:	fcf704e3          	beq	a4,a5,80005222 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000525e:	4685                	li	a3,1
    80005260:	01590633          	add	a2,s2,s5
    80005264:	faf40593          	addi	a1,s0,-81
    80005268:	1589b503          	ld	a0,344(s3)
    8000526c:	ffffc097          	auipc	ra,0xffffc
    80005270:	488080e7          	jalr	1160(ra) # 800016f4 <copyin>
    80005274:	03650263          	beq	a0,s6,80005298 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005278:	21c4a783          	lw	a5,540(s1)
    8000527c:	0017871b          	addiw	a4,a5,1
    80005280:	20e4ae23          	sw	a4,540(s1)
    80005284:	1ff7f793          	andi	a5,a5,511
    80005288:	97a6                	add	a5,a5,s1
    8000528a:	faf44703          	lbu	a4,-81(s0)
    8000528e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005292:	2905                	addiw	s2,s2,1
    80005294:	b755                	j	80005238 <pipewrite+0x80>
  int i = 0;
    80005296:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005298:	21848513          	addi	a0,s1,536
    8000529c:	ffffd097          	auipc	ra,0xffffd
    800052a0:	f32080e7          	jalr	-206(ra) # 800021ce <wakeup>
  release(&pi->lock);
    800052a4:	8526                	mv	a0,s1
    800052a6:	ffffc097          	auipc	ra,0xffffc
    800052aa:	9e4080e7          	jalr	-1564(ra) # 80000c8a <release>
  return i;
    800052ae:	bfa9                	j	80005208 <pipewrite+0x50>

00000000800052b0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800052b0:	715d                	addi	sp,sp,-80
    800052b2:	e486                	sd	ra,72(sp)
    800052b4:	e0a2                	sd	s0,64(sp)
    800052b6:	fc26                	sd	s1,56(sp)
    800052b8:	f84a                	sd	s2,48(sp)
    800052ba:	f44e                	sd	s3,40(sp)
    800052bc:	f052                	sd	s4,32(sp)
    800052be:	ec56                	sd	s5,24(sp)
    800052c0:	e85a                	sd	s6,16(sp)
    800052c2:	0880                	addi	s0,sp,80
    800052c4:	84aa                	mv	s1,a0
    800052c6:	892e                	mv	s2,a1
    800052c8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800052ca:	ffffc097          	auipc	ra,0xffffc
    800052ce:	6fe080e7          	jalr	1790(ra) # 800019c8 <myproc>
    800052d2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800052d4:	8526                	mv	a0,s1
    800052d6:	ffffc097          	auipc	ra,0xffffc
    800052da:	900080e7          	jalr	-1792(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052de:	2184a703          	lw	a4,536(s1)
    800052e2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800052e6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800052ea:	02f71763          	bne	a4,a5,80005318 <piperead+0x68>
    800052ee:	2244a783          	lw	a5,548(s1)
    800052f2:	c39d                	beqz	a5,80005318 <piperead+0x68>
    if(killed(pr)){
    800052f4:	8552                	mv	a0,s4
    800052f6:	ffffd097          	auipc	ra,0xffffd
    800052fa:	128080e7          	jalr	296(ra) # 8000241e <killed>
    800052fe:	e941                	bnez	a0,8000538e <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005300:	85a6                	mv	a1,s1
    80005302:	854e                	mv	a0,s3
    80005304:	ffffd097          	auipc	ra,0xffffd
    80005308:	e66080e7          	jalr	-410(ra) # 8000216a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000530c:	2184a703          	lw	a4,536(s1)
    80005310:	21c4a783          	lw	a5,540(s1)
    80005314:	fcf70de3          	beq	a4,a5,800052ee <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005318:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000531a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000531c:	05505363          	blez	s5,80005362 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80005320:	2184a783          	lw	a5,536(s1)
    80005324:	21c4a703          	lw	a4,540(s1)
    80005328:	02f70d63          	beq	a4,a5,80005362 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000532c:	0017871b          	addiw	a4,a5,1
    80005330:	20e4ac23          	sw	a4,536(s1)
    80005334:	1ff7f793          	andi	a5,a5,511
    80005338:	97a6                	add	a5,a5,s1
    8000533a:	0187c783          	lbu	a5,24(a5)
    8000533e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005342:	4685                	li	a3,1
    80005344:	fbf40613          	addi	a2,s0,-65
    80005348:	85ca                	mv	a1,s2
    8000534a:	158a3503          	ld	a0,344(s4)
    8000534e:	ffffc097          	auipc	ra,0xffffc
    80005352:	31a080e7          	jalr	794(ra) # 80001668 <copyout>
    80005356:	01650663          	beq	a0,s6,80005362 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000535a:	2985                	addiw	s3,s3,1
    8000535c:	0905                	addi	s2,s2,1
    8000535e:	fd3a91e3          	bne	s5,s3,80005320 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005362:	21c48513          	addi	a0,s1,540
    80005366:	ffffd097          	auipc	ra,0xffffd
    8000536a:	e68080e7          	jalr	-408(ra) # 800021ce <wakeup>
  release(&pi->lock);
    8000536e:	8526                	mv	a0,s1
    80005370:	ffffc097          	auipc	ra,0xffffc
    80005374:	91a080e7          	jalr	-1766(ra) # 80000c8a <release>
  return i;
}
    80005378:	854e                	mv	a0,s3
    8000537a:	60a6                	ld	ra,72(sp)
    8000537c:	6406                	ld	s0,64(sp)
    8000537e:	74e2                	ld	s1,56(sp)
    80005380:	7942                	ld	s2,48(sp)
    80005382:	79a2                	ld	s3,40(sp)
    80005384:	7a02                	ld	s4,32(sp)
    80005386:	6ae2                	ld	s5,24(sp)
    80005388:	6b42                	ld	s6,16(sp)
    8000538a:	6161                	addi	sp,sp,80
    8000538c:	8082                	ret
      release(&pi->lock);
    8000538e:	8526                	mv	a0,s1
    80005390:	ffffc097          	auipc	ra,0xffffc
    80005394:	8fa080e7          	jalr	-1798(ra) # 80000c8a <release>
      return -1;
    80005398:	59fd                	li	s3,-1
    8000539a:	bff9                	j	80005378 <piperead+0xc8>

000000008000539c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000539c:	1141                	addi	sp,sp,-16
    8000539e:	e422                	sd	s0,8(sp)
    800053a0:	0800                	addi	s0,sp,16
    800053a2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800053a4:	8905                	andi	a0,a0,1
    800053a6:	c111                	beqz	a0,800053aa <flags2perm+0xe>
      perm = PTE_X;
    800053a8:	4521                	li	a0,8
    if(flags & 0x2)
    800053aa:	8b89                	andi	a5,a5,2
    800053ac:	c399                	beqz	a5,800053b2 <flags2perm+0x16>
      perm |= PTE_W;
    800053ae:	00456513          	ori	a0,a0,4
    return perm;
}
    800053b2:	6422                	ld	s0,8(sp)
    800053b4:	0141                	addi	sp,sp,16
    800053b6:	8082                	ret

00000000800053b8 <exec>:

int
exec(char *path, char **argv)
{
    800053b8:	de010113          	addi	sp,sp,-544
    800053bc:	20113c23          	sd	ra,536(sp)
    800053c0:	20813823          	sd	s0,528(sp)
    800053c4:	20913423          	sd	s1,520(sp)
    800053c8:	21213023          	sd	s2,512(sp)
    800053cc:	ffce                	sd	s3,504(sp)
    800053ce:	fbd2                	sd	s4,496(sp)
    800053d0:	f7d6                	sd	s5,488(sp)
    800053d2:	f3da                	sd	s6,480(sp)
    800053d4:	efde                	sd	s7,472(sp)
    800053d6:	ebe2                	sd	s8,464(sp)
    800053d8:	e7e6                	sd	s9,456(sp)
    800053da:	e3ea                	sd	s10,448(sp)
    800053dc:	ff6e                	sd	s11,440(sp)
    800053de:	1400                	addi	s0,sp,544
    800053e0:	892a                	mv	s2,a0
    800053e2:	dea43423          	sd	a0,-536(s0)
    800053e6:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800053ea:	ffffc097          	auipc	ra,0xffffc
    800053ee:	5de080e7          	jalr	1502(ra) # 800019c8 <myproc>
    800053f2:	84aa                	mv	s1,a0

  begin_op();
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	47e080e7          	jalr	1150(ra) # 80004872 <begin_op>

  if((ip = namei(path)) == 0){
    800053fc:	854a                	mv	a0,s2
    800053fe:	fffff097          	auipc	ra,0xfffff
    80005402:	258080e7          	jalr	600(ra) # 80004656 <namei>
    80005406:	c93d                	beqz	a0,8000547c <exec+0xc4>
    80005408:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000540a:	fffff097          	auipc	ra,0xfffff
    8000540e:	aa6080e7          	jalr	-1370(ra) # 80003eb0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005412:	04000713          	li	a4,64
    80005416:	4681                	li	a3,0
    80005418:	e5040613          	addi	a2,s0,-432
    8000541c:	4581                	li	a1,0
    8000541e:	8556                	mv	a0,s5
    80005420:	fffff097          	auipc	ra,0xfffff
    80005424:	d44080e7          	jalr	-700(ra) # 80004164 <readi>
    80005428:	04000793          	li	a5,64
    8000542c:	00f51a63          	bne	a0,a5,80005440 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80005430:	e5042703          	lw	a4,-432(s0)
    80005434:	464c47b7          	lui	a5,0x464c4
    80005438:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000543c:	04f70663          	beq	a4,a5,80005488 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005440:	8556                	mv	a0,s5
    80005442:	fffff097          	auipc	ra,0xfffff
    80005446:	cd0080e7          	jalr	-816(ra) # 80004112 <iunlockput>
    end_op();
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	4a8080e7          	jalr	1192(ra) # 800048f2 <end_op>
  }
  return -1;
    80005452:	557d                	li	a0,-1
}
    80005454:	21813083          	ld	ra,536(sp)
    80005458:	21013403          	ld	s0,528(sp)
    8000545c:	20813483          	ld	s1,520(sp)
    80005460:	20013903          	ld	s2,512(sp)
    80005464:	79fe                	ld	s3,504(sp)
    80005466:	7a5e                	ld	s4,496(sp)
    80005468:	7abe                	ld	s5,488(sp)
    8000546a:	7b1e                	ld	s6,480(sp)
    8000546c:	6bfe                	ld	s7,472(sp)
    8000546e:	6c5e                	ld	s8,464(sp)
    80005470:	6cbe                	ld	s9,456(sp)
    80005472:	6d1e                	ld	s10,448(sp)
    80005474:	7dfa                	ld	s11,440(sp)
    80005476:	22010113          	addi	sp,sp,544
    8000547a:	8082                	ret
    end_op();
    8000547c:	fffff097          	auipc	ra,0xfffff
    80005480:	476080e7          	jalr	1142(ra) # 800048f2 <end_op>
    return -1;
    80005484:	557d                	li	a0,-1
    80005486:	b7f9                	j	80005454 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005488:	8526                	mv	a0,s1
    8000548a:	ffffc097          	auipc	ra,0xffffc
    8000548e:	602080e7          	jalr	1538(ra) # 80001a8c <proc_pagetable>
    80005492:	8b2a                	mv	s6,a0
    80005494:	d555                	beqz	a0,80005440 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005496:	e7042783          	lw	a5,-400(s0)
    8000549a:	e8845703          	lhu	a4,-376(s0)
    8000549e:	c735                	beqz	a4,8000550a <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800054a0:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800054a2:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800054a6:	6a05                	lui	s4,0x1
    800054a8:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800054ac:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800054b0:	6d85                	lui	s11,0x1
    800054b2:	7d7d                	lui	s10,0xfffff
    800054b4:	a481                	j	800056f4 <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800054b6:	00003517          	auipc	a0,0x3
    800054ba:	28250513          	addi	a0,a0,642 # 80008738 <syscalls+0x2a8>
    800054be:	ffffb097          	auipc	ra,0xffffb
    800054c2:	080080e7          	jalr	128(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800054c6:	874a                	mv	a4,s2
    800054c8:	009c86bb          	addw	a3,s9,s1
    800054cc:	4581                	li	a1,0
    800054ce:	8556                	mv	a0,s5
    800054d0:	fffff097          	auipc	ra,0xfffff
    800054d4:	c94080e7          	jalr	-876(ra) # 80004164 <readi>
    800054d8:	2501                	sext.w	a0,a0
    800054da:	1aa91a63          	bne	s2,a0,8000568e <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    800054de:	009d84bb          	addw	s1,s11,s1
    800054e2:	013d09bb          	addw	s3,s10,s3
    800054e6:	1f74f763          	bgeu	s1,s7,800056d4 <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    800054ea:	02049593          	slli	a1,s1,0x20
    800054ee:	9181                	srli	a1,a1,0x20
    800054f0:	95e2                	add	a1,a1,s8
    800054f2:	855a                	mv	a0,s6
    800054f4:	ffffc097          	auipc	ra,0xffffc
    800054f8:	b68080e7          	jalr	-1176(ra) # 8000105c <walkaddr>
    800054fc:	862a                	mv	a2,a0
    if(pa == 0)
    800054fe:	dd45                	beqz	a0,800054b6 <exec+0xfe>
      n = PGSIZE;
    80005500:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005502:	fd49f2e3          	bgeu	s3,s4,800054c6 <exec+0x10e>
      n = sz - i;
    80005506:	894e                	mv	s2,s3
    80005508:	bf7d                	j	800054c6 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000550a:	4901                	li	s2,0
  iunlockput(ip);
    8000550c:	8556                	mv	a0,s5
    8000550e:	fffff097          	auipc	ra,0xfffff
    80005512:	c04080e7          	jalr	-1020(ra) # 80004112 <iunlockput>
  end_op();
    80005516:	fffff097          	auipc	ra,0xfffff
    8000551a:	3dc080e7          	jalr	988(ra) # 800048f2 <end_op>
  p = myproc();
    8000551e:	ffffc097          	auipc	ra,0xffffc
    80005522:	4aa080e7          	jalr	1194(ra) # 800019c8 <myproc>
    80005526:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005528:	15053d03          	ld	s10,336(a0)
  sz = PGROUNDUP(sz);
    8000552c:	6785                	lui	a5,0x1
    8000552e:	17fd                	addi	a5,a5,-1
    80005530:	993e                	add	s2,s2,a5
    80005532:	77fd                	lui	a5,0xfffff
    80005534:	00f977b3          	and	a5,s2,a5
    80005538:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000553c:	4691                	li	a3,4
    8000553e:	6609                	lui	a2,0x2
    80005540:	963e                	add	a2,a2,a5
    80005542:	85be                	mv	a1,a5
    80005544:	855a                	mv	a0,s6
    80005546:	ffffc097          	auipc	ra,0xffffc
    8000554a:	eca080e7          	jalr	-310(ra) # 80001410 <uvmalloc>
    8000554e:	8c2a                	mv	s8,a0
  ip = 0;
    80005550:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005552:	12050e63          	beqz	a0,8000568e <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005556:	75f9                	lui	a1,0xffffe
    80005558:	95aa                	add	a1,a1,a0
    8000555a:	855a                	mv	a0,s6
    8000555c:	ffffc097          	auipc	ra,0xffffc
    80005560:	0da080e7          	jalr	218(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80005564:	7afd                	lui	s5,0xfffff
    80005566:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005568:	df043783          	ld	a5,-528(s0)
    8000556c:	6388                	ld	a0,0(a5)
    8000556e:	c925                	beqz	a0,800055de <exec+0x226>
    80005570:	e9040993          	addi	s3,s0,-368
    80005574:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005578:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000557a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000557c:	ffffc097          	auipc	ra,0xffffc
    80005580:	8d2080e7          	jalr	-1838(ra) # 80000e4e <strlen>
    80005584:	0015079b          	addiw	a5,a0,1
    80005588:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000558c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005590:	13596663          	bltu	s2,s5,800056bc <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005594:	df043d83          	ld	s11,-528(s0)
    80005598:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000559c:	8552                	mv	a0,s4
    8000559e:	ffffc097          	auipc	ra,0xffffc
    800055a2:	8b0080e7          	jalr	-1872(ra) # 80000e4e <strlen>
    800055a6:	0015069b          	addiw	a3,a0,1
    800055aa:	8652                	mv	a2,s4
    800055ac:	85ca                	mv	a1,s2
    800055ae:	855a                	mv	a0,s6
    800055b0:	ffffc097          	auipc	ra,0xffffc
    800055b4:	0b8080e7          	jalr	184(ra) # 80001668 <copyout>
    800055b8:	10054663          	bltz	a0,800056c4 <exec+0x30c>
    ustack[argc] = sp;
    800055bc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800055c0:	0485                	addi	s1,s1,1
    800055c2:	008d8793          	addi	a5,s11,8
    800055c6:	def43823          	sd	a5,-528(s0)
    800055ca:	008db503          	ld	a0,8(s11)
    800055ce:	c911                	beqz	a0,800055e2 <exec+0x22a>
    if(argc >= MAXARG)
    800055d0:	09a1                	addi	s3,s3,8
    800055d2:	fb3c95e3          	bne	s9,s3,8000557c <exec+0x1c4>
  sz = sz1;
    800055d6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800055da:	4a81                	li	s5,0
    800055dc:	a84d                	j	8000568e <exec+0x2d6>
  sp = sz;
    800055de:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800055e0:	4481                	li	s1,0
  ustack[argc] = 0;
    800055e2:	00349793          	slli	a5,s1,0x3
    800055e6:	f9040713          	addi	a4,s0,-112
    800055ea:	97ba                	add	a5,a5,a4
    800055ec:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffd8b50>
  sp -= (argc+1) * sizeof(uint64);
    800055f0:	00148693          	addi	a3,s1,1
    800055f4:	068e                	slli	a3,a3,0x3
    800055f6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800055fa:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800055fe:	01597663          	bgeu	s2,s5,8000560a <exec+0x252>
  sz = sz1;
    80005602:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005606:	4a81                	li	s5,0
    80005608:	a059                	j	8000568e <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000560a:	e9040613          	addi	a2,s0,-368
    8000560e:	85ca                	mv	a1,s2
    80005610:	855a                	mv	a0,s6
    80005612:	ffffc097          	auipc	ra,0xffffc
    80005616:	056080e7          	jalr	86(ra) # 80001668 <copyout>
    8000561a:	0a054963          	bltz	a0,800056cc <exec+0x314>
  p->trapframe->a1 = sp;
    8000561e:	160bb783          	ld	a5,352(s7) # 1160 <_entry-0x7fffeea0>
    80005622:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005626:	de843783          	ld	a5,-536(s0)
    8000562a:	0007c703          	lbu	a4,0(a5)
    8000562e:	cf11                	beqz	a4,8000564a <exec+0x292>
    80005630:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005632:	02f00693          	li	a3,47
    80005636:	a039                	j	80005644 <exec+0x28c>
      last = s+1;
    80005638:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    8000563c:	0785                	addi	a5,a5,1
    8000563e:	fff7c703          	lbu	a4,-1(a5)
    80005642:	c701                	beqz	a4,8000564a <exec+0x292>
    if(*s == '/')
    80005644:	fed71ce3          	bne	a4,a3,8000563c <exec+0x284>
    80005648:	bfc5                	j	80005638 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    8000564a:	4641                	li	a2,16
    8000564c:	de843583          	ld	a1,-536(s0)
    80005650:	260b8513          	addi	a0,s7,608
    80005654:	ffffb097          	auipc	ra,0xffffb
    80005658:	7c8080e7          	jalr	1992(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000565c:	158bb503          	ld	a0,344(s7)
  p->pagetable = pagetable;
    80005660:	156bbc23          	sd	s6,344(s7)
  p->sz = sz;
    80005664:	158bb823          	sd	s8,336(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005668:	160bb783          	ld	a5,352(s7)
    8000566c:	e6843703          	ld	a4,-408(s0)
    80005670:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005672:	160bb783          	ld	a5,352(s7)
    80005676:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000567a:	85ea                	mv	a1,s10
    8000567c:	ffffc097          	auipc	ra,0xffffc
    80005680:	4ac080e7          	jalr	1196(ra) # 80001b28 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005684:	0004851b          	sext.w	a0,s1
    80005688:	b3f1                	j	80005454 <exec+0x9c>
    8000568a:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000568e:	df843583          	ld	a1,-520(s0)
    80005692:	855a                	mv	a0,s6
    80005694:	ffffc097          	auipc	ra,0xffffc
    80005698:	494080e7          	jalr	1172(ra) # 80001b28 <proc_freepagetable>
  if(ip){
    8000569c:	da0a92e3          	bnez	s5,80005440 <exec+0x88>
  return -1;
    800056a0:	557d                	li	a0,-1
    800056a2:	bb4d                	j	80005454 <exec+0x9c>
    800056a4:	df243c23          	sd	s2,-520(s0)
    800056a8:	b7dd                	j	8000568e <exec+0x2d6>
    800056aa:	df243c23          	sd	s2,-520(s0)
    800056ae:	b7c5                	j	8000568e <exec+0x2d6>
    800056b0:	df243c23          	sd	s2,-520(s0)
    800056b4:	bfe9                	j	8000568e <exec+0x2d6>
    800056b6:	df243c23          	sd	s2,-520(s0)
    800056ba:	bfd1                	j	8000568e <exec+0x2d6>
  sz = sz1;
    800056bc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056c0:	4a81                	li	s5,0
    800056c2:	b7f1                	j	8000568e <exec+0x2d6>
  sz = sz1;
    800056c4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056c8:	4a81                	li	s5,0
    800056ca:	b7d1                	j	8000568e <exec+0x2d6>
  sz = sz1;
    800056cc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800056d0:	4a81                	li	s5,0
    800056d2:	bf75                	j	8000568e <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800056d4:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056d8:	e0843783          	ld	a5,-504(s0)
    800056dc:	0017869b          	addiw	a3,a5,1
    800056e0:	e0d43423          	sd	a3,-504(s0)
    800056e4:	e0043783          	ld	a5,-512(s0)
    800056e8:	0387879b          	addiw	a5,a5,56
    800056ec:	e8845703          	lhu	a4,-376(s0)
    800056f0:	e0e6dee3          	bge	a3,a4,8000550c <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800056f4:	2781                	sext.w	a5,a5
    800056f6:	e0f43023          	sd	a5,-512(s0)
    800056fa:	03800713          	li	a4,56
    800056fe:	86be                	mv	a3,a5
    80005700:	e1840613          	addi	a2,s0,-488
    80005704:	4581                	li	a1,0
    80005706:	8556                	mv	a0,s5
    80005708:	fffff097          	auipc	ra,0xfffff
    8000570c:	a5c080e7          	jalr	-1444(ra) # 80004164 <readi>
    80005710:	03800793          	li	a5,56
    80005714:	f6f51be3          	bne	a0,a5,8000568a <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80005718:	e1842783          	lw	a5,-488(s0)
    8000571c:	4705                	li	a4,1
    8000571e:	fae79de3          	bne	a5,a4,800056d8 <exec+0x320>
    if(ph.memsz < ph.filesz)
    80005722:	e4043483          	ld	s1,-448(s0)
    80005726:	e3843783          	ld	a5,-456(s0)
    8000572a:	f6f4ede3          	bltu	s1,a5,800056a4 <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000572e:	e2843783          	ld	a5,-472(s0)
    80005732:	94be                	add	s1,s1,a5
    80005734:	f6f4ebe3          	bltu	s1,a5,800056aa <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80005738:	de043703          	ld	a4,-544(s0)
    8000573c:	8ff9                	and	a5,a5,a4
    8000573e:	fbad                	bnez	a5,800056b0 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005740:	e1c42503          	lw	a0,-484(s0)
    80005744:	00000097          	auipc	ra,0x0
    80005748:	c58080e7          	jalr	-936(ra) # 8000539c <flags2perm>
    8000574c:	86aa                	mv	a3,a0
    8000574e:	8626                	mv	a2,s1
    80005750:	85ca                	mv	a1,s2
    80005752:	855a                	mv	a0,s6
    80005754:	ffffc097          	auipc	ra,0xffffc
    80005758:	cbc080e7          	jalr	-836(ra) # 80001410 <uvmalloc>
    8000575c:	dea43c23          	sd	a0,-520(s0)
    80005760:	d939                	beqz	a0,800056b6 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005762:	e2843c03          	ld	s8,-472(s0)
    80005766:	e2042c83          	lw	s9,-480(s0)
    8000576a:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000576e:	f60b83e3          	beqz	s7,800056d4 <exec+0x31c>
    80005772:	89de                	mv	s3,s7
    80005774:	4481                	li	s1,0
    80005776:	bb95                	j	800054ea <exec+0x132>

0000000080005778 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005778:	7179                	addi	sp,sp,-48
    8000577a:	f406                	sd	ra,40(sp)
    8000577c:	f022                	sd	s0,32(sp)
    8000577e:	ec26                	sd	s1,24(sp)
    80005780:	e84a                	sd	s2,16(sp)
    80005782:	1800                	addi	s0,sp,48
    80005784:	892e                	mv	s2,a1
    80005786:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005788:	fdc40593          	addi	a1,s0,-36
    8000578c:	ffffd097          	auipc	ra,0xffffd
    80005790:	6be080e7          	jalr	1726(ra) # 80002e4a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005794:	fdc42703          	lw	a4,-36(s0)
    80005798:	47bd                	li	a5,15
    8000579a:	02e7eb63          	bltu	a5,a4,800057d0 <argfd+0x58>
    8000579e:	ffffc097          	auipc	ra,0xffffc
    800057a2:	22a080e7          	jalr	554(ra) # 800019c8 <myproc>
    800057a6:	fdc42703          	lw	a4,-36(s0)
    800057aa:	03a70793          	addi	a5,a4,58
    800057ae:	078e                	slli	a5,a5,0x3
    800057b0:	953e                	add	a0,a0,a5
    800057b2:	651c                	ld	a5,8(a0)
    800057b4:	c385                	beqz	a5,800057d4 <argfd+0x5c>
    return -1;
  if(pfd)
    800057b6:	00090463          	beqz	s2,800057be <argfd+0x46>
    *pfd = fd;
    800057ba:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800057be:	4501                	li	a0,0
  if(pf)
    800057c0:	c091                	beqz	s1,800057c4 <argfd+0x4c>
    *pf = f;
    800057c2:	e09c                	sd	a5,0(s1)
}
    800057c4:	70a2                	ld	ra,40(sp)
    800057c6:	7402                	ld	s0,32(sp)
    800057c8:	64e2                	ld	s1,24(sp)
    800057ca:	6942                	ld	s2,16(sp)
    800057cc:	6145                	addi	sp,sp,48
    800057ce:	8082                	ret
    return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	bfcd                	j	800057c4 <argfd+0x4c>
    800057d4:	557d                	li	a0,-1
    800057d6:	b7fd                	j	800057c4 <argfd+0x4c>

00000000800057d8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800057d8:	1101                	addi	sp,sp,-32
    800057da:	ec06                	sd	ra,24(sp)
    800057dc:	e822                	sd	s0,16(sp)
    800057de:	e426                	sd	s1,8(sp)
    800057e0:	1000                	addi	s0,sp,32
    800057e2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800057e4:	ffffc097          	auipc	ra,0xffffc
    800057e8:	1e4080e7          	jalr	484(ra) # 800019c8 <myproc>
    800057ec:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800057ee:	1d850793          	addi	a5,a0,472
    800057f2:	4501                	li	a0,0
    800057f4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800057f6:	6398                	ld	a4,0(a5)
    800057f8:	cb19                	beqz	a4,8000580e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800057fa:	2505                	addiw	a0,a0,1
    800057fc:	07a1                	addi	a5,a5,8
    800057fe:	fed51ce3          	bne	a0,a3,800057f6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005802:	557d                	li	a0,-1
}
    80005804:	60e2                	ld	ra,24(sp)
    80005806:	6442                	ld	s0,16(sp)
    80005808:	64a2                	ld	s1,8(sp)
    8000580a:	6105                	addi	sp,sp,32
    8000580c:	8082                	ret
      p->ofile[fd] = f;
    8000580e:	03a50793          	addi	a5,a0,58
    80005812:	078e                	slli	a5,a5,0x3
    80005814:	963e                	add	a2,a2,a5
    80005816:	e604                	sd	s1,8(a2)
      return fd;
    80005818:	b7f5                	j	80005804 <fdalloc+0x2c>

000000008000581a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000581a:	715d                	addi	sp,sp,-80
    8000581c:	e486                	sd	ra,72(sp)
    8000581e:	e0a2                	sd	s0,64(sp)
    80005820:	fc26                	sd	s1,56(sp)
    80005822:	f84a                	sd	s2,48(sp)
    80005824:	f44e                	sd	s3,40(sp)
    80005826:	f052                	sd	s4,32(sp)
    80005828:	ec56                	sd	s5,24(sp)
    8000582a:	e85a                	sd	s6,16(sp)
    8000582c:	0880                	addi	s0,sp,80
    8000582e:	8b2e                	mv	s6,a1
    80005830:	89b2                	mv	s3,a2
    80005832:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005834:	fb040593          	addi	a1,s0,-80
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	e3c080e7          	jalr	-452(ra) # 80004674 <nameiparent>
    80005840:	84aa                	mv	s1,a0
    80005842:	14050f63          	beqz	a0,800059a0 <create+0x186>
    return 0;

  ilock(dp);
    80005846:	ffffe097          	auipc	ra,0xffffe
    8000584a:	66a080e7          	jalr	1642(ra) # 80003eb0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000584e:	4601                	li	a2,0
    80005850:	fb040593          	addi	a1,s0,-80
    80005854:	8526                	mv	a0,s1
    80005856:	fffff097          	auipc	ra,0xfffff
    8000585a:	b3e080e7          	jalr	-1218(ra) # 80004394 <dirlookup>
    8000585e:	8aaa                	mv	s5,a0
    80005860:	c931                	beqz	a0,800058b4 <create+0x9a>
    iunlockput(dp);
    80005862:	8526                	mv	a0,s1
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	8ae080e7          	jalr	-1874(ra) # 80004112 <iunlockput>
    ilock(ip);
    8000586c:	8556                	mv	a0,s5
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	642080e7          	jalr	1602(ra) # 80003eb0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005876:	000b059b          	sext.w	a1,s6
    8000587a:	4789                	li	a5,2
    8000587c:	02f59563          	bne	a1,a5,800058a6 <create+0x8c>
    80005880:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffd8c94>
    80005884:	37f9                	addiw	a5,a5,-2
    80005886:	17c2                	slli	a5,a5,0x30
    80005888:	93c1                	srli	a5,a5,0x30
    8000588a:	4705                	li	a4,1
    8000588c:	00f76d63          	bltu	a4,a5,800058a6 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005890:	8556                	mv	a0,s5
    80005892:	60a6                	ld	ra,72(sp)
    80005894:	6406                	ld	s0,64(sp)
    80005896:	74e2                	ld	s1,56(sp)
    80005898:	7942                	ld	s2,48(sp)
    8000589a:	79a2                	ld	s3,40(sp)
    8000589c:	7a02                	ld	s4,32(sp)
    8000589e:	6ae2                	ld	s5,24(sp)
    800058a0:	6b42                	ld	s6,16(sp)
    800058a2:	6161                	addi	sp,sp,80
    800058a4:	8082                	ret
    iunlockput(ip);
    800058a6:	8556                	mv	a0,s5
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	86a080e7          	jalr	-1942(ra) # 80004112 <iunlockput>
    return 0;
    800058b0:	4a81                	li	s5,0
    800058b2:	bff9                	j	80005890 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800058b4:	85da                	mv	a1,s6
    800058b6:	4088                	lw	a0,0(s1)
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	45c080e7          	jalr	1116(ra) # 80003d14 <ialloc>
    800058c0:	8a2a                	mv	s4,a0
    800058c2:	c539                	beqz	a0,80005910 <create+0xf6>
  ilock(ip);
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	5ec080e7          	jalr	1516(ra) # 80003eb0 <ilock>
  ip->major = major;
    800058cc:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800058d0:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800058d4:	4905                	li	s2,1
    800058d6:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800058da:	8552                	mv	a0,s4
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	50a080e7          	jalr	1290(ra) # 80003de6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800058e4:	000b059b          	sext.w	a1,s6
    800058e8:	03258b63          	beq	a1,s2,8000591e <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800058ec:	004a2603          	lw	a2,4(s4)
    800058f0:	fb040593          	addi	a1,s0,-80
    800058f4:	8526                	mv	a0,s1
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	cae080e7          	jalr	-850(ra) # 800045a4 <dirlink>
    800058fe:	06054f63          	bltz	a0,8000597c <create+0x162>
  iunlockput(dp);
    80005902:	8526                	mv	a0,s1
    80005904:	fffff097          	auipc	ra,0xfffff
    80005908:	80e080e7          	jalr	-2034(ra) # 80004112 <iunlockput>
  return ip;
    8000590c:	8ad2                	mv	s5,s4
    8000590e:	b749                	j	80005890 <create+0x76>
    iunlockput(dp);
    80005910:	8526                	mv	a0,s1
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	800080e7          	jalr	-2048(ra) # 80004112 <iunlockput>
    return 0;
    8000591a:	8ad2                	mv	s5,s4
    8000591c:	bf95                	j	80005890 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000591e:	004a2603          	lw	a2,4(s4)
    80005922:	00003597          	auipc	a1,0x3
    80005926:	e3658593          	addi	a1,a1,-458 # 80008758 <syscalls+0x2c8>
    8000592a:	8552                	mv	a0,s4
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	c78080e7          	jalr	-904(ra) # 800045a4 <dirlink>
    80005934:	04054463          	bltz	a0,8000597c <create+0x162>
    80005938:	40d0                	lw	a2,4(s1)
    8000593a:	00003597          	auipc	a1,0x3
    8000593e:	e2658593          	addi	a1,a1,-474 # 80008760 <syscalls+0x2d0>
    80005942:	8552                	mv	a0,s4
    80005944:	fffff097          	auipc	ra,0xfffff
    80005948:	c60080e7          	jalr	-928(ra) # 800045a4 <dirlink>
    8000594c:	02054863          	bltz	a0,8000597c <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80005950:	004a2603          	lw	a2,4(s4)
    80005954:	fb040593          	addi	a1,s0,-80
    80005958:	8526                	mv	a0,s1
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	c4a080e7          	jalr	-950(ra) # 800045a4 <dirlink>
    80005962:	00054d63          	bltz	a0,8000597c <create+0x162>
    dp->nlink++;  // for ".."
    80005966:	04a4d783          	lhu	a5,74(s1)
    8000596a:	2785                	addiw	a5,a5,1
    8000596c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005970:	8526                	mv	a0,s1
    80005972:	ffffe097          	auipc	ra,0xffffe
    80005976:	474080e7          	jalr	1140(ra) # 80003de6 <iupdate>
    8000597a:	b761                	j	80005902 <create+0xe8>
  ip->nlink = 0;
    8000597c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005980:	8552                	mv	a0,s4
    80005982:	ffffe097          	auipc	ra,0xffffe
    80005986:	464080e7          	jalr	1124(ra) # 80003de6 <iupdate>
  iunlockput(ip);
    8000598a:	8552                	mv	a0,s4
    8000598c:	ffffe097          	auipc	ra,0xffffe
    80005990:	786080e7          	jalr	1926(ra) # 80004112 <iunlockput>
  iunlockput(dp);
    80005994:	8526                	mv	a0,s1
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	77c080e7          	jalr	1916(ra) # 80004112 <iunlockput>
  return 0;
    8000599e:	bdcd                	j	80005890 <create+0x76>
    return 0;
    800059a0:	8aaa                	mv	s5,a0
    800059a2:	b5fd                	j	80005890 <create+0x76>

00000000800059a4 <sys_dup>:
{
    800059a4:	7179                	addi	sp,sp,-48
    800059a6:	f406                	sd	ra,40(sp)
    800059a8:	f022                	sd	s0,32(sp)
    800059aa:	ec26                	sd	s1,24(sp)
    800059ac:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800059ae:	fd840613          	addi	a2,s0,-40
    800059b2:	4581                	li	a1,0
    800059b4:	4501                	li	a0,0
    800059b6:	00000097          	auipc	ra,0x0
    800059ba:	dc2080e7          	jalr	-574(ra) # 80005778 <argfd>
    return -1;
    800059be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800059c0:	02054363          	bltz	a0,800059e6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800059c4:	fd843503          	ld	a0,-40(s0)
    800059c8:	00000097          	auipc	ra,0x0
    800059cc:	e10080e7          	jalr	-496(ra) # 800057d8 <fdalloc>
    800059d0:	84aa                	mv	s1,a0
    return -1;
    800059d2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800059d4:	00054963          	bltz	a0,800059e6 <sys_dup+0x42>
  filedup(f);
    800059d8:	fd843503          	ld	a0,-40(s0)
    800059dc:	fffff097          	auipc	ra,0xfffff
    800059e0:	310080e7          	jalr	784(ra) # 80004cec <filedup>
  return fd;
    800059e4:	87a6                	mv	a5,s1
}
    800059e6:	853e                	mv	a0,a5
    800059e8:	70a2                	ld	ra,40(sp)
    800059ea:	7402                	ld	s0,32(sp)
    800059ec:	64e2                	ld	s1,24(sp)
    800059ee:	6145                	addi	sp,sp,48
    800059f0:	8082                	ret

00000000800059f2 <sys_read>:
{
    800059f2:	7179                	addi	sp,sp,-48
    800059f4:	f406                	sd	ra,40(sp)
    800059f6:	f022                	sd	s0,32(sp)
    800059f8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800059fa:	fd840593          	addi	a1,s0,-40
    800059fe:	4505                	li	a0,1
    80005a00:	ffffd097          	auipc	ra,0xffffd
    80005a04:	46a080e7          	jalr	1130(ra) # 80002e6a <argaddr>
  argint(2, &n);
    80005a08:	fe440593          	addi	a1,s0,-28
    80005a0c:	4509                	li	a0,2
    80005a0e:	ffffd097          	auipc	ra,0xffffd
    80005a12:	43c080e7          	jalr	1084(ra) # 80002e4a <argint>
  if(argfd(0, 0, &f) < 0)
    80005a16:	fe840613          	addi	a2,s0,-24
    80005a1a:	4581                	li	a1,0
    80005a1c:	4501                	li	a0,0
    80005a1e:	00000097          	auipc	ra,0x0
    80005a22:	d5a080e7          	jalr	-678(ra) # 80005778 <argfd>
    80005a26:	87aa                	mv	a5,a0
    return -1;
    80005a28:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a2a:	0007cc63          	bltz	a5,80005a42 <sys_read+0x50>
  return fileread(f, p, n);
    80005a2e:	fe442603          	lw	a2,-28(s0)
    80005a32:	fd843583          	ld	a1,-40(s0)
    80005a36:	fe843503          	ld	a0,-24(s0)
    80005a3a:	fffff097          	auipc	ra,0xfffff
    80005a3e:	43e080e7          	jalr	1086(ra) # 80004e78 <fileread>
}
    80005a42:	70a2                	ld	ra,40(sp)
    80005a44:	7402                	ld	s0,32(sp)
    80005a46:	6145                	addi	sp,sp,48
    80005a48:	8082                	ret

0000000080005a4a <sys_write>:
{
    80005a4a:	7179                	addi	sp,sp,-48
    80005a4c:	f406                	sd	ra,40(sp)
    80005a4e:	f022                	sd	s0,32(sp)
    80005a50:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005a52:	fd840593          	addi	a1,s0,-40
    80005a56:	4505                	li	a0,1
    80005a58:	ffffd097          	auipc	ra,0xffffd
    80005a5c:	412080e7          	jalr	1042(ra) # 80002e6a <argaddr>
  argint(2, &n);
    80005a60:	fe440593          	addi	a1,s0,-28
    80005a64:	4509                	li	a0,2
    80005a66:	ffffd097          	auipc	ra,0xffffd
    80005a6a:	3e4080e7          	jalr	996(ra) # 80002e4a <argint>
  if(argfd(0, 0, &f) < 0)
    80005a6e:	fe840613          	addi	a2,s0,-24
    80005a72:	4581                	li	a1,0
    80005a74:	4501                	li	a0,0
    80005a76:	00000097          	auipc	ra,0x0
    80005a7a:	d02080e7          	jalr	-766(ra) # 80005778 <argfd>
    80005a7e:	87aa                	mv	a5,a0
    return -1;
    80005a80:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a82:	0007cc63          	bltz	a5,80005a9a <sys_write+0x50>
  return filewrite(f, p, n);
    80005a86:	fe442603          	lw	a2,-28(s0)
    80005a8a:	fd843583          	ld	a1,-40(s0)
    80005a8e:	fe843503          	ld	a0,-24(s0)
    80005a92:	fffff097          	auipc	ra,0xfffff
    80005a96:	4a8080e7          	jalr	1192(ra) # 80004f3a <filewrite>
}
    80005a9a:	70a2                	ld	ra,40(sp)
    80005a9c:	7402                	ld	s0,32(sp)
    80005a9e:	6145                	addi	sp,sp,48
    80005aa0:	8082                	ret

0000000080005aa2 <sys_close>:
{
    80005aa2:	1101                	addi	sp,sp,-32
    80005aa4:	ec06                	sd	ra,24(sp)
    80005aa6:	e822                	sd	s0,16(sp)
    80005aa8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005aaa:	fe040613          	addi	a2,s0,-32
    80005aae:	fec40593          	addi	a1,s0,-20
    80005ab2:	4501                	li	a0,0
    80005ab4:	00000097          	auipc	ra,0x0
    80005ab8:	cc4080e7          	jalr	-828(ra) # 80005778 <argfd>
    return -1;
    80005abc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005abe:	02054563          	bltz	a0,80005ae8 <sys_close+0x46>
  myproc()->ofile[fd] = 0;
    80005ac2:	ffffc097          	auipc	ra,0xffffc
    80005ac6:	f06080e7          	jalr	-250(ra) # 800019c8 <myproc>
    80005aca:	fec42783          	lw	a5,-20(s0)
    80005ace:	03a78793          	addi	a5,a5,58
    80005ad2:	078e                	slli	a5,a5,0x3
    80005ad4:	97aa                	add	a5,a5,a0
    80005ad6:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005ada:	fe043503          	ld	a0,-32(s0)
    80005ade:	fffff097          	auipc	ra,0xfffff
    80005ae2:	260080e7          	jalr	608(ra) # 80004d3e <fileclose>
  return 0;
    80005ae6:	4781                	li	a5,0
}
    80005ae8:	853e                	mv	a0,a5
    80005aea:	60e2                	ld	ra,24(sp)
    80005aec:	6442                	ld	s0,16(sp)
    80005aee:	6105                	addi	sp,sp,32
    80005af0:	8082                	ret

0000000080005af2 <sys_fstat>:
{
    80005af2:	1101                	addi	sp,sp,-32
    80005af4:	ec06                	sd	ra,24(sp)
    80005af6:	e822                	sd	s0,16(sp)
    80005af8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005afa:	fe040593          	addi	a1,s0,-32
    80005afe:	4505                	li	a0,1
    80005b00:	ffffd097          	auipc	ra,0xffffd
    80005b04:	36a080e7          	jalr	874(ra) # 80002e6a <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005b08:	fe840613          	addi	a2,s0,-24
    80005b0c:	4581                	li	a1,0
    80005b0e:	4501                	li	a0,0
    80005b10:	00000097          	auipc	ra,0x0
    80005b14:	c68080e7          	jalr	-920(ra) # 80005778 <argfd>
    80005b18:	87aa                	mv	a5,a0
    return -1;
    80005b1a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b1c:	0007ca63          	bltz	a5,80005b30 <sys_fstat+0x3e>
  return filestat(f, st);
    80005b20:	fe043583          	ld	a1,-32(s0)
    80005b24:	fe843503          	ld	a0,-24(s0)
    80005b28:	fffff097          	auipc	ra,0xfffff
    80005b2c:	2de080e7          	jalr	734(ra) # 80004e06 <filestat>
}
    80005b30:	60e2                	ld	ra,24(sp)
    80005b32:	6442                	ld	s0,16(sp)
    80005b34:	6105                	addi	sp,sp,32
    80005b36:	8082                	ret

0000000080005b38 <sys_link>:
{
    80005b38:	7169                	addi	sp,sp,-304
    80005b3a:	f606                	sd	ra,296(sp)
    80005b3c:	f222                	sd	s0,288(sp)
    80005b3e:	ee26                	sd	s1,280(sp)
    80005b40:	ea4a                	sd	s2,272(sp)
    80005b42:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b44:	08000613          	li	a2,128
    80005b48:	ed040593          	addi	a1,s0,-304
    80005b4c:	4501                	li	a0,0
    80005b4e:	ffffd097          	auipc	ra,0xffffd
    80005b52:	33c080e7          	jalr	828(ra) # 80002e8a <argstr>
    return -1;
    80005b56:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b58:	10054e63          	bltz	a0,80005c74 <sys_link+0x13c>
    80005b5c:	08000613          	li	a2,128
    80005b60:	f5040593          	addi	a1,s0,-176
    80005b64:	4505                	li	a0,1
    80005b66:	ffffd097          	auipc	ra,0xffffd
    80005b6a:	324080e7          	jalr	804(ra) # 80002e8a <argstr>
    return -1;
    80005b6e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005b70:	10054263          	bltz	a0,80005c74 <sys_link+0x13c>
  begin_op();
    80005b74:	fffff097          	auipc	ra,0xfffff
    80005b78:	cfe080e7          	jalr	-770(ra) # 80004872 <begin_op>
  if((ip = namei(old)) == 0){
    80005b7c:	ed040513          	addi	a0,s0,-304
    80005b80:	fffff097          	auipc	ra,0xfffff
    80005b84:	ad6080e7          	jalr	-1322(ra) # 80004656 <namei>
    80005b88:	84aa                	mv	s1,a0
    80005b8a:	c551                	beqz	a0,80005c16 <sys_link+0xde>
  ilock(ip);
    80005b8c:	ffffe097          	auipc	ra,0xffffe
    80005b90:	324080e7          	jalr	804(ra) # 80003eb0 <ilock>
  if(ip->type == T_DIR){
    80005b94:	04449703          	lh	a4,68(s1)
    80005b98:	4785                	li	a5,1
    80005b9a:	08f70463          	beq	a4,a5,80005c22 <sys_link+0xea>
  ip->nlink++;
    80005b9e:	04a4d783          	lhu	a5,74(s1)
    80005ba2:	2785                	addiw	a5,a5,1
    80005ba4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005ba8:	8526                	mv	a0,s1
    80005baa:	ffffe097          	auipc	ra,0xffffe
    80005bae:	23c080e7          	jalr	572(ra) # 80003de6 <iupdate>
  iunlock(ip);
    80005bb2:	8526                	mv	a0,s1
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	3be080e7          	jalr	958(ra) # 80003f72 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005bbc:	fd040593          	addi	a1,s0,-48
    80005bc0:	f5040513          	addi	a0,s0,-176
    80005bc4:	fffff097          	auipc	ra,0xfffff
    80005bc8:	ab0080e7          	jalr	-1360(ra) # 80004674 <nameiparent>
    80005bcc:	892a                	mv	s2,a0
    80005bce:	c935                	beqz	a0,80005c42 <sys_link+0x10a>
  ilock(dp);
    80005bd0:	ffffe097          	auipc	ra,0xffffe
    80005bd4:	2e0080e7          	jalr	736(ra) # 80003eb0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005bd8:	00092703          	lw	a4,0(s2)
    80005bdc:	409c                	lw	a5,0(s1)
    80005bde:	04f71d63          	bne	a4,a5,80005c38 <sys_link+0x100>
    80005be2:	40d0                	lw	a2,4(s1)
    80005be4:	fd040593          	addi	a1,s0,-48
    80005be8:	854a                	mv	a0,s2
    80005bea:	fffff097          	auipc	ra,0xfffff
    80005bee:	9ba080e7          	jalr	-1606(ra) # 800045a4 <dirlink>
    80005bf2:	04054363          	bltz	a0,80005c38 <sys_link+0x100>
  iunlockput(dp);
    80005bf6:	854a                	mv	a0,s2
    80005bf8:	ffffe097          	auipc	ra,0xffffe
    80005bfc:	51a080e7          	jalr	1306(ra) # 80004112 <iunlockput>
  iput(ip);
    80005c00:	8526                	mv	a0,s1
    80005c02:	ffffe097          	auipc	ra,0xffffe
    80005c06:	468080e7          	jalr	1128(ra) # 8000406a <iput>
  end_op();
    80005c0a:	fffff097          	auipc	ra,0xfffff
    80005c0e:	ce8080e7          	jalr	-792(ra) # 800048f2 <end_op>
  return 0;
    80005c12:	4781                	li	a5,0
    80005c14:	a085                	j	80005c74 <sys_link+0x13c>
    end_op();
    80005c16:	fffff097          	auipc	ra,0xfffff
    80005c1a:	cdc080e7          	jalr	-804(ra) # 800048f2 <end_op>
    return -1;
    80005c1e:	57fd                	li	a5,-1
    80005c20:	a891                	j	80005c74 <sys_link+0x13c>
    iunlockput(ip);
    80005c22:	8526                	mv	a0,s1
    80005c24:	ffffe097          	auipc	ra,0xffffe
    80005c28:	4ee080e7          	jalr	1262(ra) # 80004112 <iunlockput>
    end_op();
    80005c2c:	fffff097          	auipc	ra,0xfffff
    80005c30:	cc6080e7          	jalr	-826(ra) # 800048f2 <end_op>
    return -1;
    80005c34:	57fd                	li	a5,-1
    80005c36:	a83d                	j	80005c74 <sys_link+0x13c>
    iunlockput(dp);
    80005c38:	854a                	mv	a0,s2
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	4d8080e7          	jalr	1240(ra) # 80004112 <iunlockput>
  ilock(ip);
    80005c42:	8526                	mv	a0,s1
    80005c44:	ffffe097          	auipc	ra,0xffffe
    80005c48:	26c080e7          	jalr	620(ra) # 80003eb0 <ilock>
  ip->nlink--;
    80005c4c:	04a4d783          	lhu	a5,74(s1)
    80005c50:	37fd                	addiw	a5,a5,-1
    80005c52:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005c56:	8526                	mv	a0,s1
    80005c58:	ffffe097          	auipc	ra,0xffffe
    80005c5c:	18e080e7          	jalr	398(ra) # 80003de6 <iupdate>
  iunlockput(ip);
    80005c60:	8526                	mv	a0,s1
    80005c62:	ffffe097          	auipc	ra,0xffffe
    80005c66:	4b0080e7          	jalr	1200(ra) # 80004112 <iunlockput>
  end_op();
    80005c6a:	fffff097          	auipc	ra,0xfffff
    80005c6e:	c88080e7          	jalr	-888(ra) # 800048f2 <end_op>
  return -1;
    80005c72:	57fd                	li	a5,-1
}
    80005c74:	853e                	mv	a0,a5
    80005c76:	70b2                	ld	ra,296(sp)
    80005c78:	7412                	ld	s0,288(sp)
    80005c7a:	64f2                	ld	s1,280(sp)
    80005c7c:	6952                	ld	s2,272(sp)
    80005c7e:	6155                	addi	sp,sp,304
    80005c80:	8082                	ret

0000000080005c82 <sys_unlink>:
{
    80005c82:	7151                	addi	sp,sp,-240
    80005c84:	f586                	sd	ra,232(sp)
    80005c86:	f1a2                	sd	s0,224(sp)
    80005c88:	eda6                	sd	s1,216(sp)
    80005c8a:	e9ca                	sd	s2,208(sp)
    80005c8c:	e5ce                	sd	s3,200(sp)
    80005c8e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c90:	08000613          	li	a2,128
    80005c94:	f3040593          	addi	a1,s0,-208
    80005c98:	4501                	li	a0,0
    80005c9a:	ffffd097          	auipc	ra,0xffffd
    80005c9e:	1f0080e7          	jalr	496(ra) # 80002e8a <argstr>
    80005ca2:	18054163          	bltz	a0,80005e24 <sys_unlink+0x1a2>
  begin_op();
    80005ca6:	fffff097          	auipc	ra,0xfffff
    80005caa:	bcc080e7          	jalr	-1076(ra) # 80004872 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005cae:	fb040593          	addi	a1,s0,-80
    80005cb2:	f3040513          	addi	a0,s0,-208
    80005cb6:	fffff097          	auipc	ra,0xfffff
    80005cba:	9be080e7          	jalr	-1602(ra) # 80004674 <nameiparent>
    80005cbe:	84aa                	mv	s1,a0
    80005cc0:	c979                	beqz	a0,80005d96 <sys_unlink+0x114>
  ilock(dp);
    80005cc2:	ffffe097          	auipc	ra,0xffffe
    80005cc6:	1ee080e7          	jalr	494(ra) # 80003eb0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005cca:	00003597          	auipc	a1,0x3
    80005cce:	a8e58593          	addi	a1,a1,-1394 # 80008758 <syscalls+0x2c8>
    80005cd2:	fb040513          	addi	a0,s0,-80
    80005cd6:	ffffe097          	auipc	ra,0xffffe
    80005cda:	6a4080e7          	jalr	1700(ra) # 8000437a <namecmp>
    80005cde:	14050a63          	beqz	a0,80005e32 <sys_unlink+0x1b0>
    80005ce2:	00003597          	auipc	a1,0x3
    80005ce6:	a7e58593          	addi	a1,a1,-1410 # 80008760 <syscalls+0x2d0>
    80005cea:	fb040513          	addi	a0,s0,-80
    80005cee:	ffffe097          	auipc	ra,0xffffe
    80005cf2:	68c080e7          	jalr	1676(ra) # 8000437a <namecmp>
    80005cf6:	12050e63          	beqz	a0,80005e32 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005cfa:	f2c40613          	addi	a2,s0,-212
    80005cfe:	fb040593          	addi	a1,s0,-80
    80005d02:	8526                	mv	a0,s1
    80005d04:	ffffe097          	auipc	ra,0xffffe
    80005d08:	690080e7          	jalr	1680(ra) # 80004394 <dirlookup>
    80005d0c:	892a                	mv	s2,a0
    80005d0e:	12050263          	beqz	a0,80005e32 <sys_unlink+0x1b0>
  ilock(ip);
    80005d12:	ffffe097          	auipc	ra,0xffffe
    80005d16:	19e080e7          	jalr	414(ra) # 80003eb0 <ilock>
  if(ip->nlink < 1)
    80005d1a:	04a91783          	lh	a5,74(s2)
    80005d1e:	08f05263          	blez	a5,80005da2 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005d22:	04491703          	lh	a4,68(s2)
    80005d26:	4785                	li	a5,1
    80005d28:	08f70563          	beq	a4,a5,80005db2 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005d2c:	4641                	li	a2,16
    80005d2e:	4581                	li	a1,0
    80005d30:	fc040513          	addi	a0,s0,-64
    80005d34:	ffffb097          	auipc	ra,0xffffb
    80005d38:	f9e080e7          	jalr	-98(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d3c:	4741                	li	a4,16
    80005d3e:	f2c42683          	lw	a3,-212(s0)
    80005d42:	fc040613          	addi	a2,s0,-64
    80005d46:	4581                	li	a1,0
    80005d48:	8526                	mv	a0,s1
    80005d4a:	ffffe097          	auipc	ra,0xffffe
    80005d4e:	512080e7          	jalr	1298(ra) # 8000425c <writei>
    80005d52:	47c1                	li	a5,16
    80005d54:	0af51563          	bne	a0,a5,80005dfe <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005d58:	04491703          	lh	a4,68(s2)
    80005d5c:	4785                	li	a5,1
    80005d5e:	0af70863          	beq	a4,a5,80005e0e <sys_unlink+0x18c>
  iunlockput(dp);
    80005d62:	8526                	mv	a0,s1
    80005d64:	ffffe097          	auipc	ra,0xffffe
    80005d68:	3ae080e7          	jalr	942(ra) # 80004112 <iunlockput>
  ip->nlink--;
    80005d6c:	04a95783          	lhu	a5,74(s2)
    80005d70:	37fd                	addiw	a5,a5,-1
    80005d72:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005d76:	854a                	mv	a0,s2
    80005d78:	ffffe097          	auipc	ra,0xffffe
    80005d7c:	06e080e7          	jalr	110(ra) # 80003de6 <iupdate>
  iunlockput(ip);
    80005d80:	854a                	mv	a0,s2
    80005d82:	ffffe097          	auipc	ra,0xffffe
    80005d86:	390080e7          	jalr	912(ra) # 80004112 <iunlockput>
  end_op();
    80005d8a:	fffff097          	auipc	ra,0xfffff
    80005d8e:	b68080e7          	jalr	-1176(ra) # 800048f2 <end_op>
  return 0;
    80005d92:	4501                	li	a0,0
    80005d94:	a84d                	j	80005e46 <sys_unlink+0x1c4>
    end_op();
    80005d96:	fffff097          	auipc	ra,0xfffff
    80005d9a:	b5c080e7          	jalr	-1188(ra) # 800048f2 <end_op>
    return -1;
    80005d9e:	557d                	li	a0,-1
    80005da0:	a05d                	j	80005e46 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005da2:	00003517          	auipc	a0,0x3
    80005da6:	9c650513          	addi	a0,a0,-1594 # 80008768 <syscalls+0x2d8>
    80005daa:	ffffa097          	auipc	ra,0xffffa
    80005dae:	794080e7          	jalr	1940(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005db2:	04c92703          	lw	a4,76(s2)
    80005db6:	02000793          	li	a5,32
    80005dba:	f6e7f9e3          	bgeu	a5,a4,80005d2c <sys_unlink+0xaa>
    80005dbe:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005dc2:	4741                	li	a4,16
    80005dc4:	86ce                	mv	a3,s3
    80005dc6:	f1840613          	addi	a2,s0,-232
    80005dca:	4581                	li	a1,0
    80005dcc:	854a                	mv	a0,s2
    80005dce:	ffffe097          	auipc	ra,0xffffe
    80005dd2:	396080e7          	jalr	918(ra) # 80004164 <readi>
    80005dd6:	47c1                	li	a5,16
    80005dd8:	00f51b63          	bne	a0,a5,80005dee <sys_unlink+0x16c>
    if(de.inum != 0)
    80005ddc:	f1845783          	lhu	a5,-232(s0)
    80005de0:	e7a1                	bnez	a5,80005e28 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005de2:	29c1                	addiw	s3,s3,16
    80005de4:	04c92783          	lw	a5,76(s2)
    80005de8:	fcf9ede3          	bltu	s3,a5,80005dc2 <sys_unlink+0x140>
    80005dec:	b781                	j	80005d2c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005dee:	00003517          	auipc	a0,0x3
    80005df2:	99250513          	addi	a0,a0,-1646 # 80008780 <syscalls+0x2f0>
    80005df6:	ffffa097          	auipc	ra,0xffffa
    80005dfa:	748080e7          	jalr	1864(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005dfe:	00003517          	auipc	a0,0x3
    80005e02:	99a50513          	addi	a0,a0,-1638 # 80008798 <syscalls+0x308>
    80005e06:	ffffa097          	auipc	ra,0xffffa
    80005e0a:	738080e7          	jalr	1848(ra) # 8000053e <panic>
    dp->nlink--;
    80005e0e:	04a4d783          	lhu	a5,74(s1)
    80005e12:	37fd                	addiw	a5,a5,-1
    80005e14:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005e18:	8526                	mv	a0,s1
    80005e1a:	ffffe097          	auipc	ra,0xffffe
    80005e1e:	fcc080e7          	jalr	-52(ra) # 80003de6 <iupdate>
    80005e22:	b781                	j	80005d62 <sys_unlink+0xe0>
    return -1;
    80005e24:	557d                	li	a0,-1
    80005e26:	a005                	j	80005e46 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005e28:	854a                	mv	a0,s2
    80005e2a:	ffffe097          	auipc	ra,0xffffe
    80005e2e:	2e8080e7          	jalr	744(ra) # 80004112 <iunlockput>
  iunlockput(dp);
    80005e32:	8526                	mv	a0,s1
    80005e34:	ffffe097          	auipc	ra,0xffffe
    80005e38:	2de080e7          	jalr	734(ra) # 80004112 <iunlockput>
  end_op();
    80005e3c:	fffff097          	auipc	ra,0xfffff
    80005e40:	ab6080e7          	jalr	-1354(ra) # 800048f2 <end_op>
  return -1;
    80005e44:	557d                	li	a0,-1
}
    80005e46:	70ae                	ld	ra,232(sp)
    80005e48:	740e                	ld	s0,224(sp)
    80005e4a:	64ee                	ld	s1,216(sp)
    80005e4c:	694e                	ld	s2,208(sp)
    80005e4e:	69ae                	ld	s3,200(sp)
    80005e50:	616d                	addi	sp,sp,240
    80005e52:	8082                	ret

0000000080005e54 <sys_open>:

uint64
sys_open(void)
{
    80005e54:	7131                	addi	sp,sp,-192
    80005e56:	fd06                	sd	ra,184(sp)
    80005e58:	f922                	sd	s0,176(sp)
    80005e5a:	f526                	sd	s1,168(sp)
    80005e5c:	f14a                	sd	s2,160(sp)
    80005e5e:	ed4e                	sd	s3,152(sp)
    80005e60:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005e62:	f4c40593          	addi	a1,s0,-180
    80005e66:	4505                	li	a0,1
    80005e68:	ffffd097          	auipc	ra,0xffffd
    80005e6c:	fe2080e7          	jalr	-30(ra) # 80002e4a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e70:	08000613          	li	a2,128
    80005e74:	f5040593          	addi	a1,s0,-176
    80005e78:	4501                	li	a0,0
    80005e7a:	ffffd097          	auipc	ra,0xffffd
    80005e7e:	010080e7          	jalr	16(ra) # 80002e8a <argstr>
    80005e82:	87aa                	mv	a5,a0
    return -1;
    80005e84:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e86:	0a07c963          	bltz	a5,80005f38 <sys_open+0xe4>

  begin_op();
    80005e8a:	fffff097          	auipc	ra,0xfffff
    80005e8e:	9e8080e7          	jalr	-1560(ra) # 80004872 <begin_op>

  if(omode & O_CREATE){
    80005e92:	f4c42783          	lw	a5,-180(s0)
    80005e96:	2007f793          	andi	a5,a5,512
    80005e9a:	cfc5                	beqz	a5,80005f52 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005e9c:	4681                	li	a3,0
    80005e9e:	4601                	li	a2,0
    80005ea0:	4589                	li	a1,2
    80005ea2:	f5040513          	addi	a0,s0,-176
    80005ea6:	00000097          	auipc	ra,0x0
    80005eaa:	974080e7          	jalr	-1676(ra) # 8000581a <create>
    80005eae:	84aa                	mv	s1,a0
    if(ip == 0){
    80005eb0:	c959                	beqz	a0,80005f46 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005eb2:	04449703          	lh	a4,68(s1)
    80005eb6:	478d                	li	a5,3
    80005eb8:	00f71763          	bne	a4,a5,80005ec6 <sys_open+0x72>
    80005ebc:	0464d703          	lhu	a4,70(s1)
    80005ec0:	47a5                	li	a5,9
    80005ec2:	0ce7ed63          	bltu	a5,a4,80005f9c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005ec6:	fffff097          	auipc	ra,0xfffff
    80005eca:	dbc080e7          	jalr	-580(ra) # 80004c82 <filealloc>
    80005ece:	89aa                	mv	s3,a0
    80005ed0:	10050363          	beqz	a0,80005fd6 <sys_open+0x182>
    80005ed4:	00000097          	auipc	ra,0x0
    80005ed8:	904080e7          	jalr	-1788(ra) # 800057d8 <fdalloc>
    80005edc:	892a                	mv	s2,a0
    80005ede:	0e054763          	bltz	a0,80005fcc <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ee2:	04449703          	lh	a4,68(s1)
    80005ee6:	478d                	li	a5,3
    80005ee8:	0cf70563          	beq	a4,a5,80005fb2 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005eec:	4789                	li	a5,2
    80005eee:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ef2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ef6:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005efa:	f4c42783          	lw	a5,-180(s0)
    80005efe:	0017c713          	xori	a4,a5,1
    80005f02:	8b05                	andi	a4,a4,1
    80005f04:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f08:	0037f713          	andi	a4,a5,3
    80005f0c:	00e03733          	snez	a4,a4
    80005f10:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005f14:	4007f793          	andi	a5,a5,1024
    80005f18:	c791                	beqz	a5,80005f24 <sys_open+0xd0>
    80005f1a:	04449703          	lh	a4,68(s1)
    80005f1e:	4789                	li	a5,2
    80005f20:	0af70063          	beq	a4,a5,80005fc0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005f24:	8526                	mv	a0,s1
    80005f26:	ffffe097          	auipc	ra,0xffffe
    80005f2a:	04c080e7          	jalr	76(ra) # 80003f72 <iunlock>
  end_op();
    80005f2e:	fffff097          	auipc	ra,0xfffff
    80005f32:	9c4080e7          	jalr	-1596(ra) # 800048f2 <end_op>

  return fd;
    80005f36:	854a                	mv	a0,s2
}
    80005f38:	70ea                	ld	ra,184(sp)
    80005f3a:	744a                	ld	s0,176(sp)
    80005f3c:	74aa                	ld	s1,168(sp)
    80005f3e:	790a                	ld	s2,160(sp)
    80005f40:	69ea                	ld	s3,152(sp)
    80005f42:	6129                	addi	sp,sp,192
    80005f44:	8082                	ret
      end_op();
    80005f46:	fffff097          	auipc	ra,0xfffff
    80005f4a:	9ac080e7          	jalr	-1620(ra) # 800048f2 <end_op>
      return -1;
    80005f4e:	557d                	li	a0,-1
    80005f50:	b7e5                	j	80005f38 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005f52:	f5040513          	addi	a0,s0,-176
    80005f56:	ffffe097          	auipc	ra,0xffffe
    80005f5a:	700080e7          	jalr	1792(ra) # 80004656 <namei>
    80005f5e:	84aa                	mv	s1,a0
    80005f60:	c905                	beqz	a0,80005f90 <sys_open+0x13c>
    ilock(ip);
    80005f62:	ffffe097          	auipc	ra,0xffffe
    80005f66:	f4e080e7          	jalr	-178(ra) # 80003eb0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005f6a:	04449703          	lh	a4,68(s1)
    80005f6e:	4785                	li	a5,1
    80005f70:	f4f711e3          	bne	a4,a5,80005eb2 <sys_open+0x5e>
    80005f74:	f4c42783          	lw	a5,-180(s0)
    80005f78:	d7b9                	beqz	a5,80005ec6 <sys_open+0x72>
      iunlockput(ip);
    80005f7a:	8526                	mv	a0,s1
    80005f7c:	ffffe097          	auipc	ra,0xffffe
    80005f80:	196080e7          	jalr	406(ra) # 80004112 <iunlockput>
      end_op();
    80005f84:	fffff097          	auipc	ra,0xfffff
    80005f88:	96e080e7          	jalr	-1682(ra) # 800048f2 <end_op>
      return -1;
    80005f8c:	557d                	li	a0,-1
    80005f8e:	b76d                	j	80005f38 <sys_open+0xe4>
      end_op();
    80005f90:	fffff097          	auipc	ra,0xfffff
    80005f94:	962080e7          	jalr	-1694(ra) # 800048f2 <end_op>
      return -1;
    80005f98:	557d                	li	a0,-1
    80005f9a:	bf79                	j	80005f38 <sys_open+0xe4>
    iunlockput(ip);
    80005f9c:	8526                	mv	a0,s1
    80005f9e:	ffffe097          	auipc	ra,0xffffe
    80005fa2:	174080e7          	jalr	372(ra) # 80004112 <iunlockput>
    end_op();
    80005fa6:	fffff097          	auipc	ra,0xfffff
    80005faa:	94c080e7          	jalr	-1716(ra) # 800048f2 <end_op>
    return -1;
    80005fae:	557d                	li	a0,-1
    80005fb0:	b761                	j	80005f38 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005fb2:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005fb6:	04649783          	lh	a5,70(s1)
    80005fba:	02f99223          	sh	a5,36(s3)
    80005fbe:	bf25                	j	80005ef6 <sys_open+0xa2>
    itrunc(ip);
    80005fc0:	8526                	mv	a0,s1
    80005fc2:	ffffe097          	auipc	ra,0xffffe
    80005fc6:	ffc080e7          	jalr	-4(ra) # 80003fbe <itrunc>
    80005fca:	bfa9                	j	80005f24 <sys_open+0xd0>
      fileclose(f);
    80005fcc:	854e                	mv	a0,s3
    80005fce:	fffff097          	auipc	ra,0xfffff
    80005fd2:	d70080e7          	jalr	-656(ra) # 80004d3e <fileclose>
    iunlockput(ip);
    80005fd6:	8526                	mv	a0,s1
    80005fd8:	ffffe097          	auipc	ra,0xffffe
    80005fdc:	13a080e7          	jalr	314(ra) # 80004112 <iunlockput>
    end_op();
    80005fe0:	fffff097          	auipc	ra,0xfffff
    80005fe4:	912080e7          	jalr	-1774(ra) # 800048f2 <end_op>
    return -1;
    80005fe8:	557d                	li	a0,-1
    80005fea:	b7b9                	j	80005f38 <sys_open+0xe4>

0000000080005fec <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005fec:	7175                	addi	sp,sp,-144
    80005fee:	e506                	sd	ra,136(sp)
    80005ff0:	e122                	sd	s0,128(sp)
    80005ff2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005ff4:	fffff097          	auipc	ra,0xfffff
    80005ff8:	87e080e7          	jalr	-1922(ra) # 80004872 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ffc:	08000613          	li	a2,128
    80006000:	f7040593          	addi	a1,s0,-144
    80006004:	4501                	li	a0,0
    80006006:	ffffd097          	auipc	ra,0xffffd
    8000600a:	e84080e7          	jalr	-380(ra) # 80002e8a <argstr>
    8000600e:	02054963          	bltz	a0,80006040 <sys_mkdir+0x54>
    80006012:	4681                	li	a3,0
    80006014:	4601                	li	a2,0
    80006016:	4585                	li	a1,1
    80006018:	f7040513          	addi	a0,s0,-144
    8000601c:	fffff097          	auipc	ra,0xfffff
    80006020:	7fe080e7          	jalr	2046(ra) # 8000581a <create>
    80006024:	cd11                	beqz	a0,80006040 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006026:	ffffe097          	auipc	ra,0xffffe
    8000602a:	0ec080e7          	jalr	236(ra) # 80004112 <iunlockput>
  end_op();
    8000602e:	fffff097          	auipc	ra,0xfffff
    80006032:	8c4080e7          	jalr	-1852(ra) # 800048f2 <end_op>
  return 0;
    80006036:	4501                	li	a0,0
}
    80006038:	60aa                	ld	ra,136(sp)
    8000603a:	640a                	ld	s0,128(sp)
    8000603c:	6149                	addi	sp,sp,144
    8000603e:	8082                	ret
    end_op();
    80006040:	fffff097          	auipc	ra,0xfffff
    80006044:	8b2080e7          	jalr	-1870(ra) # 800048f2 <end_op>
    return -1;
    80006048:	557d                	li	a0,-1
    8000604a:	b7fd                	j	80006038 <sys_mkdir+0x4c>

000000008000604c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000604c:	7135                	addi	sp,sp,-160
    8000604e:	ed06                	sd	ra,152(sp)
    80006050:	e922                	sd	s0,144(sp)
    80006052:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006054:	fffff097          	auipc	ra,0xfffff
    80006058:	81e080e7          	jalr	-2018(ra) # 80004872 <begin_op>
  argint(1, &major);
    8000605c:	f6c40593          	addi	a1,s0,-148
    80006060:	4505                	li	a0,1
    80006062:	ffffd097          	auipc	ra,0xffffd
    80006066:	de8080e7          	jalr	-536(ra) # 80002e4a <argint>
  argint(2, &minor);
    8000606a:	f6840593          	addi	a1,s0,-152
    8000606e:	4509                	li	a0,2
    80006070:	ffffd097          	auipc	ra,0xffffd
    80006074:	dda080e7          	jalr	-550(ra) # 80002e4a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006078:	08000613          	li	a2,128
    8000607c:	f7040593          	addi	a1,s0,-144
    80006080:	4501                	li	a0,0
    80006082:	ffffd097          	auipc	ra,0xffffd
    80006086:	e08080e7          	jalr	-504(ra) # 80002e8a <argstr>
    8000608a:	02054b63          	bltz	a0,800060c0 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000608e:	f6841683          	lh	a3,-152(s0)
    80006092:	f6c41603          	lh	a2,-148(s0)
    80006096:	458d                	li	a1,3
    80006098:	f7040513          	addi	a0,s0,-144
    8000609c:	fffff097          	auipc	ra,0xfffff
    800060a0:	77e080e7          	jalr	1918(ra) # 8000581a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800060a4:	cd11                	beqz	a0,800060c0 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060a6:	ffffe097          	auipc	ra,0xffffe
    800060aa:	06c080e7          	jalr	108(ra) # 80004112 <iunlockput>
  end_op();
    800060ae:	fffff097          	auipc	ra,0xfffff
    800060b2:	844080e7          	jalr	-1980(ra) # 800048f2 <end_op>
  return 0;
    800060b6:	4501                	li	a0,0
}
    800060b8:	60ea                	ld	ra,152(sp)
    800060ba:	644a                	ld	s0,144(sp)
    800060bc:	610d                	addi	sp,sp,160
    800060be:	8082                	ret
    end_op();
    800060c0:	fffff097          	auipc	ra,0xfffff
    800060c4:	832080e7          	jalr	-1998(ra) # 800048f2 <end_op>
    return -1;
    800060c8:	557d                	li	a0,-1
    800060ca:	b7fd                	j	800060b8 <sys_mknod+0x6c>

00000000800060cc <sys_chdir>:

uint64
sys_chdir(void)
{
    800060cc:	7135                	addi	sp,sp,-160
    800060ce:	ed06                	sd	ra,152(sp)
    800060d0:	e922                	sd	s0,144(sp)
    800060d2:	e526                	sd	s1,136(sp)
    800060d4:	e14a                	sd	s2,128(sp)
    800060d6:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800060d8:	ffffc097          	auipc	ra,0xffffc
    800060dc:	8f0080e7          	jalr	-1808(ra) # 800019c8 <myproc>
    800060e0:	892a                	mv	s2,a0
  
  begin_op();
    800060e2:	ffffe097          	auipc	ra,0xffffe
    800060e6:	790080e7          	jalr	1936(ra) # 80004872 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800060ea:	08000613          	li	a2,128
    800060ee:	f6040593          	addi	a1,s0,-160
    800060f2:	4501                	li	a0,0
    800060f4:	ffffd097          	auipc	ra,0xffffd
    800060f8:	d96080e7          	jalr	-618(ra) # 80002e8a <argstr>
    800060fc:	04054b63          	bltz	a0,80006152 <sys_chdir+0x86>
    80006100:	f6040513          	addi	a0,s0,-160
    80006104:	ffffe097          	auipc	ra,0xffffe
    80006108:	552080e7          	jalr	1362(ra) # 80004656 <namei>
    8000610c:	84aa                	mv	s1,a0
    8000610e:	c131                	beqz	a0,80006152 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006110:	ffffe097          	auipc	ra,0xffffe
    80006114:	da0080e7          	jalr	-608(ra) # 80003eb0 <ilock>
  if(ip->type != T_DIR){
    80006118:	04449703          	lh	a4,68(s1)
    8000611c:	4785                	li	a5,1
    8000611e:	04f71063          	bne	a4,a5,8000615e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006122:	8526                	mv	a0,s1
    80006124:	ffffe097          	auipc	ra,0xffffe
    80006128:	e4e080e7          	jalr	-434(ra) # 80003f72 <iunlock>
  iput(p->cwd);
    8000612c:	25893503          	ld	a0,600(s2)
    80006130:	ffffe097          	auipc	ra,0xffffe
    80006134:	f3a080e7          	jalr	-198(ra) # 8000406a <iput>
  end_op();
    80006138:	ffffe097          	auipc	ra,0xffffe
    8000613c:	7ba080e7          	jalr	1978(ra) # 800048f2 <end_op>
  p->cwd = ip;
    80006140:	24993c23          	sd	s1,600(s2)
  return 0;
    80006144:	4501                	li	a0,0
}
    80006146:	60ea                	ld	ra,152(sp)
    80006148:	644a                	ld	s0,144(sp)
    8000614a:	64aa                	ld	s1,136(sp)
    8000614c:	690a                	ld	s2,128(sp)
    8000614e:	610d                	addi	sp,sp,160
    80006150:	8082                	ret
    end_op();
    80006152:	ffffe097          	auipc	ra,0xffffe
    80006156:	7a0080e7          	jalr	1952(ra) # 800048f2 <end_op>
    return -1;
    8000615a:	557d                	li	a0,-1
    8000615c:	b7ed                	j	80006146 <sys_chdir+0x7a>
    iunlockput(ip);
    8000615e:	8526                	mv	a0,s1
    80006160:	ffffe097          	auipc	ra,0xffffe
    80006164:	fb2080e7          	jalr	-78(ra) # 80004112 <iunlockput>
    end_op();
    80006168:	ffffe097          	auipc	ra,0xffffe
    8000616c:	78a080e7          	jalr	1930(ra) # 800048f2 <end_op>
    return -1;
    80006170:	557d                	li	a0,-1
    80006172:	bfd1                	j	80006146 <sys_chdir+0x7a>

0000000080006174 <sys_exec>:

uint64
sys_exec(void)
{
    80006174:	7145                	addi	sp,sp,-464
    80006176:	e786                	sd	ra,456(sp)
    80006178:	e3a2                	sd	s0,448(sp)
    8000617a:	ff26                	sd	s1,440(sp)
    8000617c:	fb4a                	sd	s2,432(sp)
    8000617e:	f74e                	sd	s3,424(sp)
    80006180:	f352                	sd	s4,416(sp)
    80006182:	ef56                	sd	s5,408(sp)
    80006184:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80006186:	e3840593          	addi	a1,s0,-456
    8000618a:	4505                	li	a0,1
    8000618c:	ffffd097          	auipc	ra,0xffffd
    80006190:	cde080e7          	jalr	-802(ra) # 80002e6a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006194:	08000613          	li	a2,128
    80006198:	f4040593          	addi	a1,s0,-192
    8000619c:	4501                	li	a0,0
    8000619e:	ffffd097          	auipc	ra,0xffffd
    800061a2:	cec080e7          	jalr	-788(ra) # 80002e8a <argstr>
    800061a6:	87aa                	mv	a5,a0
    return -1;
    800061a8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800061aa:	0c07c263          	bltz	a5,8000626e <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800061ae:	10000613          	li	a2,256
    800061b2:	4581                	li	a1,0
    800061b4:	e4040513          	addi	a0,s0,-448
    800061b8:	ffffb097          	auipc	ra,0xffffb
    800061bc:	b1a080e7          	jalr	-1254(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800061c0:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800061c4:	89a6                	mv	s3,s1
    800061c6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800061c8:	02000a13          	li	s4,32
    800061cc:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061d0:	00391793          	slli	a5,s2,0x3
    800061d4:	e3040593          	addi	a1,s0,-464
    800061d8:	e3843503          	ld	a0,-456(s0)
    800061dc:	953e                	add	a0,a0,a5
    800061de:	ffffd097          	auipc	ra,0xffffd
    800061e2:	bc8080e7          	jalr	-1080(ra) # 80002da6 <fetchaddr>
    800061e6:	02054a63          	bltz	a0,8000621a <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800061ea:	e3043783          	ld	a5,-464(s0)
    800061ee:	c3b9                	beqz	a5,80006234 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800061f0:	ffffb097          	auipc	ra,0xffffb
    800061f4:	8f6080e7          	jalr	-1802(ra) # 80000ae6 <kalloc>
    800061f8:	85aa                	mv	a1,a0
    800061fa:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800061fe:	cd11                	beqz	a0,8000621a <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006200:	6605                	lui	a2,0x1
    80006202:	e3043503          	ld	a0,-464(s0)
    80006206:	ffffd097          	auipc	ra,0xffffd
    8000620a:	bf6080e7          	jalr	-1034(ra) # 80002dfc <fetchstr>
    8000620e:	00054663          	bltz	a0,8000621a <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80006212:	0905                	addi	s2,s2,1
    80006214:	09a1                	addi	s3,s3,8
    80006216:	fb491be3          	bne	s2,s4,800061cc <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000621a:	10048913          	addi	s2,s1,256
    8000621e:	6088                	ld	a0,0(s1)
    80006220:	c531                	beqz	a0,8000626c <sys_exec+0xf8>
    kfree(argv[i]);
    80006222:	ffffa097          	auipc	ra,0xffffa
    80006226:	7c8080e7          	jalr	1992(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000622a:	04a1                	addi	s1,s1,8
    8000622c:	ff2499e3          	bne	s1,s2,8000621e <sys_exec+0xaa>
  return -1;
    80006230:	557d                	li	a0,-1
    80006232:	a835                	j	8000626e <sys_exec+0xfa>
      argv[i] = 0;
    80006234:	0a8e                	slli	s5,s5,0x3
    80006236:	fc040793          	addi	a5,s0,-64
    8000623a:	9abe                	add	s5,s5,a5
    8000623c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006240:	e4040593          	addi	a1,s0,-448
    80006244:	f4040513          	addi	a0,s0,-192
    80006248:	fffff097          	auipc	ra,0xfffff
    8000624c:	170080e7          	jalr	368(ra) # 800053b8 <exec>
    80006250:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006252:	10048993          	addi	s3,s1,256
    80006256:	6088                	ld	a0,0(s1)
    80006258:	c901                	beqz	a0,80006268 <sys_exec+0xf4>
    kfree(argv[i]);
    8000625a:	ffffa097          	auipc	ra,0xffffa
    8000625e:	790080e7          	jalr	1936(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006262:	04a1                	addi	s1,s1,8
    80006264:	ff3499e3          	bne	s1,s3,80006256 <sys_exec+0xe2>
  return ret;
    80006268:	854a                	mv	a0,s2
    8000626a:	a011                	j	8000626e <sys_exec+0xfa>
  return -1;
    8000626c:	557d                	li	a0,-1
}
    8000626e:	60be                	ld	ra,456(sp)
    80006270:	641e                	ld	s0,448(sp)
    80006272:	74fa                	ld	s1,440(sp)
    80006274:	795a                	ld	s2,432(sp)
    80006276:	79ba                	ld	s3,424(sp)
    80006278:	7a1a                	ld	s4,416(sp)
    8000627a:	6afa                	ld	s5,408(sp)
    8000627c:	6179                	addi	sp,sp,464
    8000627e:	8082                	ret

0000000080006280 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006280:	7139                	addi	sp,sp,-64
    80006282:	fc06                	sd	ra,56(sp)
    80006284:	f822                	sd	s0,48(sp)
    80006286:	f426                	sd	s1,40(sp)
    80006288:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000628a:	ffffb097          	auipc	ra,0xffffb
    8000628e:	73e080e7          	jalr	1854(ra) # 800019c8 <myproc>
    80006292:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006294:	fd840593          	addi	a1,s0,-40
    80006298:	4501                	li	a0,0
    8000629a:	ffffd097          	auipc	ra,0xffffd
    8000629e:	bd0080e7          	jalr	-1072(ra) # 80002e6a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800062a2:	fc840593          	addi	a1,s0,-56
    800062a6:	fd040513          	addi	a0,s0,-48
    800062aa:	fffff097          	auipc	ra,0xfffff
    800062ae:	dc4080e7          	jalr	-572(ra) # 8000506e <pipealloc>
    return -1;
    800062b2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800062b4:	0c054963          	bltz	a0,80006386 <sys_pipe+0x106>
  fd0 = -1;
    800062b8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800062bc:	fd043503          	ld	a0,-48(s0)
    800062c0:	fffff097          	auipc	ra,0xfffff
    800062c4:	518080e7          	jalr	1304(ra) # 800057d8 <fdalloc>
    800062c8:	fca42223          	sw	a0,-60(s0)
    800062cc:	0a054063          	bltz	a0,8000636c <sys_pipe+0xec>
    800062d0:	fc843503          	ld	a0,-56(s0)
    800062d4:	fffff097          	auipc	ra,0xfffff
    800062d8:	504080e7          	jalr	1284(ra) # 800057d8 <fdalloc>
    800062dc:	fca42023          	sw	a0,-64(s0)
    800062e0:	06054c63          	bltz	a0,80006358 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062e4:	4691                	li	a3,4
    800062e6:	fc440613          	addi	a2,s0,-60
    800062ea:	fd843583          	ld	a1,-40(s0)
    800062ee:	1584b503          	ld	a0,344(s1)
    800062f2:	ffffb097          	auipc	ra,0xffffb
    800062f6:	376080e7          	jalr	886(ra) # 80001668 <copyout>
    800062fa:	02054163          	bltz	a0,8000631c <sys_pipe+0x9c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800062fe:	4691                	li	a3,4
    80006300:	fc040613          	addi	a2,s0,-64
    80006304:	fd843583          	ld	a1,-40(s0)
    80006308:	0591                	addi	a1,a1,4
    8000630a:	1584b503          	ld	a0,344(s1)
    8000630e:	ffffb097          	auipc	ra,0xffffb
    80006312:	35a080e7          	jalr	858(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006316:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006318:	06055763          	bgez	a0,80006386 <sys_pipe+0x106>
    p->ofile[fd0] = 0;
    8000631c:	fc442783          	lw	a5,-60(s0)
    80006320:	03a78793          	addi	a5,a5,58
    80006324:	078e                	slli	a5,a5,0x3
    80006326:	97a6                	add	a5,a5,s1
    80006328:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    8000632c:	fc042503          	lw	a0,-64(s0)
    80006330:	03a50513          	addi	a0,a0,58
    80006334:	050e                	slli	a0,a0,0x3
    80006336:	94aa                	add	s1,s1,a0
    80006338:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000633c:	fd043503          	ld	a0,-48(s0)
    80006340:	fffff097          	auipc	ra,0xfffff
    80006344:	9fe080e7          	jalr	-1538(ra) # 80004d3e <fileclose>
    fileclose(wf);
    80006348:	fc843503          	ld	a0,-56(s0)
    8000634c:	fffff097          	auipc	ra,0xfffff
    80006350:	9f2080e7          	jalr	-1550(ra) # 80004d3e <fileclose>
    return -1;
    80006354:	57fd                	li	a5,-1
    80006356:	a805                	j	80006386 <sys_pipe+0x106>
    if(fd0 >= 0)
    80006358:	fc442783          	lw	a5,-60(s0)
    8000635c:	0007c863          	bltz	a5,8000636c <sys_pipe+0xec>
      p->ofile[fd0] = 0;
    80006360:	03a78793          	addi	a5,a5,58
    80006364:	078e                	slli	a5,a5,0x3
    80006366:	94be                	add	s1,s1,a5
    80006368:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    8000636c:	fd043503          	ld	a0,-48(s0)
    80006370:	fffff097          	auipc	ra,0xfffff
    80006374:	9ce080e7          	jalr	-1586(ra) # 80004d3e <fileclose>
    fileclose(wf);
    80006378:	fc843503          	ld	a0,-56(s0)
    8000637c:	fffff097          	auipc	ra,0xfffff
    80006380:	9c2080e7          	jalr	-1598(ra) # 80004d3e <fileclose>
    return -1;
    80006384:	57fd                	li	a5,-1
}
    80006386:	853e                	mv	a0,a5
    80006388:	70e2                	ld	ra,56(sp)
    8000638a:	7442                	ld	s0,48(sp)
    8000638c:	74a2                	ld	s1,40(sp)
    8000638e:	6121                	addi	sp,sp,64
    80006390:	8082                	ret
	...

00000000800063a0 <kernelvec>:
    800063a0:	7111                	addi	sp,sp,-256
    800063a2:	e006                	sd	ra,0(sp)
    800063a4:	e40a                	sd	sp,8(sp)
    800063a6:	e80e                	sd	gp,16(sp)
    800063a8:	ec12                	sd	tp,24(sp)
    800063aa:	f016                	sd	t0,32(sp)
    800063ac:	f41a                	sd	t1,40(sp)
    800063ae:	f81e                	sd	t2,48(sp)
    800063b0:	fc22                	sd	s0,56(sp)
    800063b2:	e0a6                	sd	s1,64(sp)
    800063b4:	e4aa                	sd	a0,72(sp)
    800063b6:	e8ae                	sd	a1,80(sp)
    800063b8:	ecb2                	sd	a2,88(sp)
    800063ba:	f0b6                	sd	a3,96(sp)
    800063bc:	f4ba                	sd	a4,104(sp)
    800063be:	f8be                	sd	a5,112(sp)
    800063c0:	fcc2                	sd	a6,120(sp)
    800063c2:	e146                	sd	a7,128(sp)
    800063c4:	e54a                	sd	s2,136(sp)
    800063c6:	e94e                	sd	s3,144(sp)
    800063c8:	ed52                	sd	s4,152(sp)
    800063ca:	f156                	sd	s5,160(sp)
    800063cc:	f55a                	sd	s6,168(sp)
    800063ce:	f95e                	sd	s7,176(sp)
    800063d0:	fd62                	sd	s8,184(sp)
    800063d2:	e1e6                	sd	s9,192(sp)
    800063d4:	e5ea                	sd	s10,200(sp)
    800063d6:	e9ee                	sd	s11,208(sp)
    800063d8:	edf2                	sd	t3,216(sp)
    800063da:	f1f6                	sd	t4,224(sp)
    800063dc:	f5fa                	sd	t5,232(sp)
    800063de:	f9fe                	sd	t6,240(sp)
    800063e0:	887fc0ef          	jal	ra,80002c66 <kerneltrap>
    800063e4:	6082                	ld	ra,0(sp)
    800063e6:	6122                	ld	sp,8(sp)
    800063e8:	61c2                	ld	gp,16(sp)
    800063ea:	7282                	ld	t0,32(sp)
    800063ec:	7322                	ld	t1,40(sp)
    800063ee:	73c2                	ld	t2,48(sp)
    800063f0:	7462                	ld	s0,56(sp)
    800063f2:	6486                	ld	s1,64(sp)
    800063f4:	6526                	ld	a0,72(sp)
    800063f6:	65c6                	ld	a1,80(sp)
    800063f8:	6666                	ld	a2,88(sp)
    800063fa:	7686                	ld	a3,96(sp)
    800063fc:	7726                	ld	a4,104(sp)
    800063fe:	77c6                	ld	a5,112(sp)
    80006400:	7866                	ld	a6,120(sp)
    80006402:	688a                	ld	a7,128(sp)
    80006404:	692a                	ld	s2,136(sp)
    80006406:	69ca                	ld	s3,144(sp)
    80006408:	6a6a                	ld	s4,152(sp)
    8000640a:	7a8a                	ld	s5,160(sp)
    8000640c:	7b2a                	ld	s6,168(sp)
    8000640e:	7bca                	ld	s7,176(sp)
    80006410:	7c6a                	ld	s8,184(sp)
    80006412:	6c8e                	ld	s9,192(sp)
    80006414:	6d2e                	ld	s10,200(sp)
    80006416:	6dce                	ld	s11,208(sp)
    80006418:	6e6e                	ld	t3,216(sp)
    8000641a:	7e8e                	ld	t4,224(sp)
    8000641c:	7f2e                	ld	t5,232(sp)
    8000641e:	7fce                	ld	t6,240(sp)
    80006420:	6111                	addi	sp,sp,256
    80006422:	10200073          	sret
    80006426:	00000013          	nop
    8000642a:	00000013          	nop
    8000642e:	0001                	nop

0000000080006430 <timervec>:
    80006430:	34051573          	csrrw	a0,mscratch,a0
    80006434:	e10c                	sd	a1,0(a0)
    80006436:	e510                	sd	a2,8(a0)
    80006438:	e914                	sd	a3,16(a0)
    8000643a:	6d0c                	ld	a1,24(a0)
    8000643c:	7110                	ld	a2,32(a0)
    8000643e:	6194                	ld	a3,0(a1)
    80006440:	96b2                	add	a3,a3,a2
    80006442:	e194                	sd	a3,0(a1)
    80006444:	4589                	li	a1,2
    80006446:	14459073          	csrw	sip,a1
    8000644a:	6914                	ld	a3,16(a0)
    8000644c:	6510                	ld	a2,8(a0)
    8000644e:	610c                	ld	a1,0(a0)
    80006450:	34051573          	csrrw	a0,mscratch,a0
    80006454:	30200073          	mret
	...

000000008000645a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000645a:	1141                	addi	sp,sp,-16
    8000645c:	e422                	sd	s0,8(sp)
    8000645e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006460:	0c0007b7          	lui	a5,0xc000
    80006464:	4705                	li	a4,1
    80006466:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006468:	c3d8                	sw	a4,4(a5)
}
    8000646a:	6422                	ld	s0,8(sp)
    8000646c:	0141                	addi	sp,sp,16
    8000646e:	8082                	ret

0000000080006470 <plicinithart>:

void
plicinithart(void)
{
    80006470:	1141                	addi	sp,sp,-16
    80006472:	e406                	sd	ra,8(sp)
    80006474:	e022                	sd	s0,0(sp)
    80006476:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006478:	ffffb097          	auipc	ra,0xffffb
    8000647c:	524080e7          	jalr	1316(ra) # 8000199c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006480:	0085171b          	slliw	a4,a0,0x8
    80006484:	0c0027b7          	lui	a5,0xc002
    80006488:	97ba                	add	a5,a5,a4
    8000648a:	40200713          	li	a4,1026
    8000648e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006492:	00d5151b          	slliw	a0,a0,0xd
    80006496:	0c2017b7          	lui	a5,0xc201
    8000649a:	953e                	add	a0,a0,a5
    8000649c:	00052023          	sw	zero,0(a0)
}
    800064a0:	60a2                	ld	ra,8(sp)
    800064a2:	6402                	ld	s0,0(sp)
    800064a4:	0141                	addi	sp,sp,16
    800064a6:	8082                	ret

00000000800064a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800064a8:	1141                	addi	sp,sp,-16
    800064aa:	e406                	sd	ra,8(sp)
    800064ac:	e022                	sd	s0,0(sp)
    800064ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800064b0:	ffffb097          	auipc	ra,0xffffb
    800064b4:	4ec080e7          	jalr	1260(ra) # 8000199c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800064b8:	00d5179b          	slliw	a5,a0,0xd
    800064bc:	0c201537          	lui	a0,0xc201
    800064c0:	953e                	add	a0,a0,a5
  return irq;
}
    800064c2:	4148                	lw	a0,4(a0)
    800064c4:	60a2                	ld	ra,8(sp)
    800064c6:	6402                	ld	s0,0(sp)
    800064c8:	0141                	addi	sp,sp,16
    800064ca:	8082                	ret

00000000800064cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800064cc:	1101                	addi	sp,sp,-32
    800064ce:	ec06                	sd	ra,24(sp)
    800064d0:	e822                	sd	s0,16(sp)
    800064d2:	e426                	sd	s1,8(sp)
    800064d4:	1000                	addi	s0,sp,32
    800064d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800064d8:	ffffb097          	auipc	ra,0xffffb
    800064dc:	4c4080e7          	jalr	1220(ra) # 8000199c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800064e0:	00d5151b          	slliw	a0,a0,0xd
    800064e4:	0c2017b7          	lui	a5,0xc201
    800064e8:	97aa                	add	a5,a5,a0
    800064ea:	c3c4                	sw	s1,4(a5)
}
    800064ec:	60e2                	ld	ra,24(sp)
    800064ee:	6442                	ld	s0,16(sp)
    800064f0:	64a2                	ld	s1,8(sp)
    800064f2:	6105                	addi	sp,sp,32
    800064f4:	8082                	ret

00000000800064f6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800064f6:	1141                	addi	sp,sp,-16
    800064f8:	e406                	sd	ra,8(sp)
    800064fa:	e022                	sd	s0,0(sp)
    800064fc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800064fe:	479d                	li	a5,7
    80006500:	04a7cc63          	blt	a5,a0,80006558 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006504:	00020797          	auipc	a5,0x20
    80006508:	d6c78793          	addi	a5,a5,-660 # 80026270 <disk>
    8000650c:	97aa                	add	a5,a5,a0
    8000650e:	0187c783          	lbu	a5,24(a5)
    80006512:	ebb9                	bnez	a5,80006568 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006514:	00451613          	slli	a2,a0,0x4
    80006518:	00020797          	auipc	a5,0x20
    8000651c:	d5878793          	addi	a5,a5,-680 # 80026270 <disk>
    80006520:	6394                	ld	a3,0(a5)
    80006522:	96b2                	add	a3,a3,a2
    80006524:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006528:	6398                	ld	a4,0(a5)
    8000652a:	9732                	add	a4,a4,a2
    8000652c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006530:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006534:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006538:	953e                	add	a0,a0,a5
    8000653a:	4785                	li	a5,1
    8000653c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006540:	00020517          	auipc	a0,0x20
    80006544:	d4850513          	addi	a0,a0,-696 # 80026288 <disk+0x18>
    80006548:	ffffc097          	auipc	ra,0xffffc
    8000654c:	c86080e7          	jalr	-890(ra) # 800021ce <wakeup>
}
    80006550:	60a2                	ld	ra,8(sp)
    80006552:	6402                	ld	s0,0(sp)
    80006554:	0141                	addi	sp,sp,16
    80006556:	8082                	ret
    panic("free_desc 1");
    80006558:	00002517          	auipc	a0,0x2
    8000655c:	25050513          	addi	a0,a0,592 # 800087a8 <syscalls+0x318>
    80006560:	ffffa097          	auipc	ra,0xffffa
    80006564:	fde080e7          	jalr	-34(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006568:	00002517          	auipc	a0,0x2
    8000656c:	25050513          	addi	a0,a0,592 # 800087b8 <syscalls+0x328>
    80006570:	ffffa097          	auipc	ra,0xffffa
    80006574:	fce080e7          	jalr	-50(ra) # 8000053e <panic>

0000000080006578 <virtio_disk_init>:
{
    80006578:	1101                	addi	sp,sp,-32
    8000657a:	ec06                	sd	ra,24(sp)
    8000657c:	e822                	sd	s0,16(sp)
    8000657e:	e426                	sd	s1,8(sp)
    80006580:	e04a                	sd	s2,0(sp)
    80006582:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006584:	00002597          	auipc	a1,0x2
    80006588:	24458593          	addi	a1,a1,580 # 800087c8 <syscalls+0x338>
    8000658c:	00020517          	auipc	a0,0x20
    80006590:	e0c50513          	addi	a0,a0,-500 # 80026398 <disk+0x128>
    80006594:	ffffa097          	auipc	ra,0xffffa
    80006598:	5b2080e7          	jalr	1458(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000659c:	100017b7          	lui	a5,0x10001
    800065a0:	4398                	lw	a4,0(a5)
    800065a2:	2701                	sext.w	a4,a4
    800065a4:	747277b7          	lui	a5,0x74727
    800065a8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800065ac:	14f71c63          	bne	a4,a5,80006704 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065b0:	100017b7          	lui	a5,0x10001
    800065b4:	43dc                	lw	a5,4(a5)
    800065b6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800065b8:	4709                	li	a4,2
    800065ba:	14e79563          	bne	a5,a4,80006704 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065be:	100017b7          	lui	a5,0x10001
    800065c2:	479c                	lw	a5,8(a5)
    800065c4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800065c6:	12e79f63          	bne	a5,a4,80006704 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800065ca:	100017b7          	lui	a5,0x10001
    800065ce:	47d8                	lw	a4,12(a5)
    800065d0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800065d2:	554d47b7          	lui	a5,0x554d4
    800065d6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800065da:	12f71563          	bne	a4,a5,80006704 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065de:	100017b7          	lui	a5,0x10001
    800065e2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800065e6:	4705                	li	a4,1
    800065e8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065ea:	470d                	li	a4,3
    800065ec:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800065ee:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800065f0:	c7ffe737          	lui	a4,0xc7ffe
    800065f4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd83af>
    800065f8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800065fa:	2701                	sext.w	a4,a4
    800065fc:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800065fe:	472d                	li	a4,11
    80006600:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006602:	5bbc                	lw	a5,112(a5)
    80006604:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006608:	8ba1                	andi	a5,a5,8
    8000660a:	10078563          	beqz	a5,80006714 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000660e:	100017b7          	lui	a5,0x10001
    80006612:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006616:	43fc                	lw	a5,68(a5)
    80006618:	2781                	sext.w	a5,a5
    8000661a:	10079563          	bnez	a5,80006724 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000661e:	100017b7          	lui	a5,0x10001
    80006622:	5bdc                	lw	a5,52(a5)
    80006624:	2781                	sext.w	a5,a5
  if(max == 0)
    80006626:	10078763          	beqz	a5,80006734 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000662a:	471d                	li	a4,7
    8000662c:	10f77c63          	bgeu	a4,a5,80006744 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006630:	ffffa097          	auipc	ra,0xffffa
    80006634:	4b6080e7          	jalr	1206(ra) # 80000ae6 <kalloc>
    80006638:	00020497          	auipc	s1,0x20
    8000663c:	c3848493          	addi	s1,s1,-968 # 80026270 <disk>
    80006640:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006642:	ffffa097          	auipc	ra,0xffffa
    80006646:	4a4080e7          	jalr	1188(ra) # 80000ae6 <kalloc>
    8000664a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000664c:	ffffa097          	auipc	ra,0xffffa
    80006650:	49a080e7          	jalr	1178(ra) # 80000ae6 <kalloc>
    80006654:	87aa                	mv	a5,a0
    80006656:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006658:	6088                	ld	a0,0(s1)
    8000665a:	cd6d                	beqz	a0,80006754 <virtio_disk_init+0x1dc>
    8000665c:	00020717          	auipc	a4,0x20
    80006660:	c1c73703          	ld	a4,-996(a4) # 80026278 <disk+0x8>
    80006664:	cb65                	beqz	a4,80006754 <virtio_disk_init+0x1dc>
    80006666:	c7fd                	beqz	a5,80006754 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006668:	6605                	lui	a2,0x1
    8000666a:	4581                	li	a1,0
    8000666c:	ffffa097          	auipc	ra,0xffffa
    80006670:	666080e7          	jalr	1638(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006674:	00020497          	auipc	s1,0x20
    80006678:	bfc48493          	addi	s1,s1,-1028 # 80026270 <disk>
    8000667c:	6605                	lui	a2,0x1
    8000667e:	4581                	li	a1,0
    80006680:	6488                	ld	a0,8(s1)
    80006682:	ffffa097          	auipc	ra,0xffffa
    80006686:	650080e7          	jalr	1616(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000668a:	6605                	lui	a2,0x1
    8000668c:	4581                	li	a1,0
    8000668e:	6888                	ld	a0,16(s1)
    80006690:	ffffa097          	auipc	ra,0xffffa
    80006694:	642080e7          	jalr	1602(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006698:	100017b7          	lui	a5,0x10001
    8000669c:	4721                	li	a4,8
    8000669e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800066a0:	4098                	lw	a4,0(s1)
    800066a2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800066a6:	40d8                	lw	a4,4(s1)
    800066a8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800066ac:	6498                	ld	a4,8(s1)
    800066ae:	0007069b          	sext.w	a3,a4
    800066b2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800066b6:	9701                	srai	a4,a4,0x20
    800066b8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800066bc:	6898                	ld	a4,16(s1)
    800066be:	0007069b          	sext.w	a3,a4
    800066c2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800066c6:	9701                	srai	a4,a4,0x20
    800066c8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800066cc:	4705                	li	a4,1
    800066ce:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800066d0:	00e48c23          	sb	a4,24(s1)
    800066d4:	00e48ca3          	sb	a4,25(s1)
    800066d8:	00e48d23          	sb	a4,26(s1)
    800066dc:	00e48da3          	sb	a4,27(s1)
    800066e0:	00e48e23          	sb	a4,28(s1)
    800066e4:	00e48ea3          	sb	a4,29(s1)
    800066e8:	00e48f23          	sb	a4,30(s1)
    800066ec:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800066f0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800066f4:	0727a823          	sw	s2,112(a5)
}
    800066f8:	60e2                	ld	ra,24(sp)
    800066fa:	6442                	ld	s0,16(sp)
    800066fc:	64a2                	ld	s1,8(sp)
    800066fe:	6902                	ld	s2,0(sp)
    80006700:	6105                	addi	sp,sp,32
    80006702:	8082                	ret
    panic("could not find virtio disk");
    80006704:	00002517          	auipc	a0,0x2
    80006708:	0d450513          	addi	a0,a0,212 # 800087d8 <syscalls+0x348>
    8000670c:	ffffa097          	auipc	ra,0xffffa
    80006710:	e32080e7          	jalr	-462(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006714:	00002517          	auipc	a0,0x2
    80006718:	0e450513          	addi	a0,a0,228 # 800087f8 <syscalls+0x368>
    8000671c:	ffffa097          	auipc	ra,0xffffa
    80006720:	e22080e7          	jalr	-478(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006724:	00002517          	auipc	a0,0x2
    80006728:	0f450513          	addi	a0,a0,244 # 80008818 <syscalls+0x388>
    8000672c:	ffffa097          	auipc	ra,0xffffa
    80006730:	e12080e7          	jalr	-494(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006734:	00002517          	auipc	a0,0x2
    80006738:	10450513          	addi	a0,a0,260 # 80008838 <syscalls+0x3a8>
    8000673c:	ffffa097          	auipc	ra,0xffffa
    80006740:	e02080e7          	jalr	-510(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006744:	00002517          	auipc	a0,0x2
    80006748:	11450513          	addi	a0,a0,276 # 80008858 <syscalls+0x3c8>
    8000674c:	ffffa097          	auipc	ra,0xffffa
    80006750:	df2080e7          	jalr	-526(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006754:	00002517          	auipc	a0,0x2
    80006758:	12450513          	addi	a0,a0,292 # 80008878 <syscalls+0x3e8>
    8000675c:	ffffa097          	auipc	ra,0xffffa
    80006760:	de2080e7          	jalr	-542(ra) # 8000053e <panic>

0000000080006764 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006764:	7119                	addi	sp,sp,-128
    80006766:	fc86                	sd	ra,120(sp)
    80006768:	f8a2                	sd	s0,112(sp)
    8000676a:	f4a6                	sd	s1,104(sp)
    8000676c:	f0ca                	sd	s2,96(sp)
    8000676e:	ecce                	sd	s3,88(sp)
    80006770:	e8d2                	sd	s4,80(sp)
    80006772:	e4d6                	sd	s5,72(sp)
    80006774:	e0da                	sd	s6,64(sp)
    80006776:	fc5e                	sd	s7,56(sp)
    80006778:	f862                	sd	s8,48(sp)
    8000677a:	f466                	sd	s9,40(sp)
    8000677c:	f06a                	sd	s10,32(sp)
    8000677e:	ec6e                	sd	s11,24(sp)
    80006780:	0100                	addi	s0,sp,128
    80006782:	8aaa                	mv	s5,a0
    80006784:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006786:	00c52d03          	lw	s10,12(a0)
    8000678a:	001d1d1b          	slliw	s10,s10,0x1
    8000678e:	1d02                	slli	s10,s10,0x20
    80006790:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006794:	00020517          	auipc	a0,0x20
    80006798:	c0450513          	addi	a0,a0,-1020 # 80026398 <disk+0x128>
    8000679c:	ffffa097          	auipc	ra,0xffffa
    800067a0:	43a080e7          	jalr	1082(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800067a4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800067a6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800067a8:	00020b97          	auipc	s7,0x20
    800067ac:	ac8b8b93          	addi	s7,s7,-1336 # 80026270 <disk>
  for(int i = 0; i < 3; i++){
    800067b0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800067b2:	00020c97          	auipc	s9,0x20
    800067b6:	be6c8c93          	addi	s9,s9,-1050 # 80026398 <disk+0x128>
    800067ba:	a08d                	j	8000681c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800067bc:	00fb8733          	add	a4,s7,a5
    800067c0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800067c4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800067c6:	0207c563          	bltz	a5,800067f0 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800067ca:	2905                	addiw	s2,s2,1
    800067cc:	0611                	addi	a2,a2,4
    800067ce:	05690c63          	beq	s2,s6,80006826 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800067d2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800067d4:	00020717          	auipc	a4,0x20
    800067d8:	a9c70713          	addi	a4,a4,-1380 # 80026270 <disk>
    800067dc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800067de:	01874683          	lbu	a3,24(a4)
    800067e2:	fee9                	bnez	a3,800067bc <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800067e4:	2785                	addiw	a5,a5,1
    800067e6:	0705                	addi	a4,a4,1
    800067e8:	fe979be3          	bne	a5,s1,800067de <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800067ec:	57fd                	li	a5,-1
    800067ee:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800067f0:	01205d63          	blez	s2,8000680a <virtio_disk_rw+0xa6>
    800067f4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800067f6:	000a2503          	lw	a0,0(s4)
    800067fa:	00000097          	auipc	ra,0x0
    800067fe:	cfc080e7          	jalr	-772(ra) # 800064f6 <free_desc>
      for(int j = 0; j < i; j++)
    80006802:	2d85                	addiw	s11,s11,1
    80006804:	0a11                	addi	s4,s4,4
    80006806:	ffb918e3          	bne	s2,s11,800067f6 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000680a:	85e6                	mv	a1,s9
    8000680c:	00020517          	auipc	a0,0x20
    80006810:	a7c50513          	addi	a0,a0,-1412 # 80026288 <disk+0x18>
    80006814:	ffffc097          	auipc	ra,0xffffc
    80006818:	956080e7          	jalr	-1706(ra) # 8000216a <sleep>
  for(int i = 0; i < 3; i++){
    8000681c:	f8040a13          	addi	s4,s0,-128
{
    80006820:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006822:	894e                	mv	s2,s3
    80006824:	b77d                	j	800067d2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006826:	f8042583          	lw	a1,-128(s0)
    8000682a:	00a58793          	addi	a5,a1,10
    8000682e:	0792                	slli	a5,a5,0x4

  if(write)
    80006830:	00020617          	auipc	a2,0x20
    80006834:	a4060613          	addi	a2,a2,-1472 # 80026270 <disk>
    80006838:	00f60733          	add	a4,a2,a5
    8000683c:	018036b3          	snez	a3,s8
    80006840:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006842:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006846:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000684a:	f6078693          	addi	a3,a5,-160
    8000684e:	6218                	ld	a4,0(a2)
    80006850:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006852:	00878513          	addi	a0,a5,8
    80006856:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006858:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000685a:	6208                	ld	a0,0(a2)
    8000685c:	96aa                	add	a3,a3,a0
    8000685e:	4741                	li	a4,16
    80006860:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006862:	4705                	li	a4,1
    80006864:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006868:	f8442703          	lw	a4,-124(s0)
    8000686c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006870:	0712                	slli	a4,a4,0x4
    80006872:	953a                	add	a0,a0,a4
    80006874:	058a8693          	addi	a3,s5,88
    80006878:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000687a:	6208                	ld	a0,0(a2)
    8000687c:	972a                	add	a4,a4,a0
    8000687e:	40000693          	li	a3,1024
    80006882:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006884:	001c3c13          	seqz	s8,s8
    80006888:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000688a:	001c6c13          	ori	s8,s8,1
    8000688e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006892:	f8842603          	lw	a2,-120(s0)
    80006896:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000689a:	00020697          	auipc	a3,0x20
    8000689e:	9d668693          	addi	a3,a3,-1578 # 80026270 <disk>
    800068a2:	00258713          	addi	a4,a1,2
    800068a6:	0712                	slli	a4,a4,0x4
    800068a8:	9736                	add	a4,a4,a3
    800068aa:	587d                	li	a6,-1
    800068ac:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800068b0:	0612                	slli	a2,a2,0x4
    800068b2:	9532                	add	a0,a0,a2
    800068b4:	f9078793          	addi	a5,a5,-112
    800068b8:	97b6                	add	a5,a5,a3
    800068ba:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800068bc:	629c                	ld	a5,0(a3)
    800068be:	97b2                	add	a5,a5,a2
    800068c0:	4605                	li	a2,1
    800068c2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800068c4:	4509                	li	a0,2
    800068c6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800068ca:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800068ce:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800068d2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800068d6:	6698                	ld	a4,8(a3)
    800068d8:	00275783          	lhu	a5,2(a4)
    800068dc:	8b9d                	andi	a5,a5,7
    800068de:	0786                	slli	a5,a5,0x1
    800068e0:	97ba                	add	a5,a5,a4
    800068e2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800068e6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800068ea:	6698                	ld	a4,8(a3)
    800068ec:	00275783          	lhu	a5,2(a4)
    800068f0:	2785                	addiw	a5,a5,1
    800068f2:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800068f6:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800068fa:	100017b7          	lui	a5,0x10001
    800068fe:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006902:	004aa783          	lw	a5,4(s5)
    80006906:	02c79163          	bne	a5,a2,80006928 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000690a:	00020917          	auipc	s2,0x20
    8000690e:	a8e90913          	addi	s2,s2,-1394 # 80026398 <disk+0x128>
  while(b->disk == 1) {
    80006912:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006914:	85ca                	mv	a1,s2
    80006916:	8556                	mv	a0,s5
    80006918:	ffffc097          	auipc	ra,0xffffc
    8000691c:	852080e7          	jalr	-1966(ra) # 8000216a <sleep>
  while(b->disk == 1) {
    80006920:	004aa783          	lw	a5,4(s5)
    80006924:	fe9788e3          	beq	a5,s1,80006914 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006928:	f8042903          	lw	s2,-128(s0)
    8000692c:	00290793          	addi	a5,s2,2
    80006930:	00479713          	slli	a4,a5,0x4
    80006934:	00020797          	auipc	a5,0x20
    80006938:	93c78793          	addi	a5,a5,-1732 # 80026270 <disk>
    8000693c:	97ba                	add	a5,a5,a4
    8000693e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006942:	00020997          	auipc	s3,0x20
    80006946:	92e98993          	addi	s3,s3,-1746 # 80026270 <disk>
    8000694a:	00491713          	slli	a4,s2,0x4
    8000694e:	0009b783          	ld	a5,0(s3)
    80006952:	97ba                	add	a5,a5,a4
    80006954:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006958:	854a                	mv	a0,s2
    8000695a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000695e:	00000097          	auipc	ra,0x0
    80006962:	b98080e7          	jalr	-1128(ra) # 800064f6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006966:	8885                	andi	s1,s1,1
    80006968:	f0ed                	bnez	s1,8000694a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000696a:	00020517          	auipc	a0,0x20
    8000696e:	a2e50513          	addi	a0,a0,-1490 # 80026398 <disk+0x128>
    80006972:	ffffa097          	auipc	ra,0xffffa
    80006976:	318080e7          	jalr	792(ra) # 80000c8a <release>
}
    8000697a:	70e6                	ld	ra,120(sp)
    8000697c:	7446                	ld	s0,112(sp)
    8000697e:	74a6                	ld	s1,104(sp)
    80006980:	7906                	ld	s2,96(sp)
    80006982:	69e6                	ld	s3,88(sp)
    80006984:	6a46                	ld	s4,80(sp)
    80006986:	6aa6                	ld	s5,72(sp)
    80006988:	6b06                	ld	s6,64(sp)
    8000698a:	7be2                	ld	s7,56(sp)
    8000698c:	7c42                	ld	s8,48(sp)
    8000698e:	7ca2                	ld	s9,40(sp)
    80006990:	7d02                	ld	s10,32(sp)
    80006992:	6de2                	ld	s11,24(sp)
    80006994:	6109                	addi	sp,sp,128
    80006996:	8082                	ret

0000000080006998 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006998:	1101                	addi	sp,sp,-32
    8000699a:	ec06                	sd	ra,24(sp)
    8000699c:	e822                	sd	s0,16(sp)
    8000699e:	e426                	sd	s1,8(sp)
    800069a0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800069a2:	00020497          	auipc	s1,0x20
    800069a6:	8ce48493          	addi	s1,s1,-1842 # 80026270 <disk>
    800069aa:	00020517          	auipc	a0,0x20
    800069ae:	9ee50513          	addi	a0,a0,-1554 # 80026398 <disk+0x128>
    800069b2:	ffffa097          	auipc	ra,0xffffa
    800069b6:	224080e7          	jalr	548(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800069ba:	10001737          	lui	a4,0x10001
    800069be:	533c                	lw	a5,96(a4)
    800069c0:	8b8d                	andi	a5,a5,3
    800069c2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800069c4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800069c8:	689c                	ld	a5,16(s1)
    800069ca:	0204d703          	lhu	a4,32(s1)
    800069ce:	0027d783          	lhu	a5,2(a5)
    800069d2:	04f70863          	beq	a4,a5,80006a22 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800069d6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800069da:	6898                	ld	a4,16(s1)
    800069dc:	0204d783          	lhu	a5,32(s1)
    800069e0:	8b9d                	andi	a5,a5,7
    800069e2:	078e                	slli	a5,a5,0x3
    800069e4:	97ba                	add	a5,a5,a4
    800069e6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800069e8:	00278713          	addi	a4,a5,2
    800069ec:	0712                	slli	a4,a4,0x4
    800069ee:	9726                	add	a4,a4,s1
    800069f0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800069f4:	e721                	bnez	a4,80006a3c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800069f6:	0789                	addi	a5,a5,2
    800069f8:	0792                	slli	a5,a5,0x4
    800069fa:	97a6                	add	a5,a5,s1
    800069fc:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800069fe:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006a02:	ffffb097          	auipc	ra,0xffffb
    80006a06:	7cc080e7          	jalr	1996(ra) # 800021ce <wakeup>

    disk.used_idx += 1;
    80006a0a:	0204d783          	lhu	a5,32(s1)
    80006a0e:	2785                	addiw	a5,a5,1
    80006a10:	17c2                	slli	a5,a5,0x30
    80006a12:	93c1                	srli	a5,a5,0x30
    80006a14:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006a18:	6898                	ld	a4,16(s1)
    80006a1a:	00275703          	lhu	a4,2(a4)
    80006a1e:	faf71ce3          	bne	a4,a5,800069d6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006a22:	00020517          	auipc	a0,0x20
    80006a26:	97650513          	addi	a0,a0,-1674 # 80026398 <disk+0x128>
    80006a2a:	ffffa097          	auipc	ra,0xffffa
    80006a2e:	260080e7          	jalr	608(ra) # 80000c8a <release>
}
    80006a32:	60e2                	ld	ra,24(sp)
    80006a34:	6442                	ld	s0,16(sp)
    80006a36:	64a2                	ld	s1,8(sp)
    80006a38:	6105                	addi	sp,sp,32
    80006a3a:	8082                	ret
      panic("virtio_disk_intr status");
    80006a3c:	00002517          	auipc	a0,0x2
    80006a40:	e5450513          	addi	a0,a0,-428 # 80008890 <syscalls+0x400>
    80006a44:	ffffa097          	auipc	ra,0xffffa
    80006a48:	afa080e7          	jalr	-1286(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
