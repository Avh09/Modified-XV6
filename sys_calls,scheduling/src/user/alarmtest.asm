
user/_alarmtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <periodic>:
}

volatile static int count;

void periodic()
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    count = count + 1;
   8:	00001717          	auipc	a4,0x1
   c:	ff870713          	addi	a4,a4,-8 # 1000 <count>
  10:	00001797          	auipc	a5,0x1
  14:	ff07a783          	lw	a5,-16(a5) # 1000 <count>
  18:	2785                	addiw	a5,a5,1
  1a:	c31c                	sw	a5,0(a4)
    printf("periodic: count=%d\n", count);
  1c:	430c                	lw	a1,0(a4)
  1e:	2581                	sext.w	a1,a1
  20:	00001517          	auipc	a0,0x1
  24:	c2050513          	addi	a0,a0,-992 # c40 <malloc+0xf0>
  28:	00001097          	auipc	ra,0x1
  2c:	a6a080e7          	jalr	-1430(ra) # a92 <printf>
    sigreturn();
  30:	00000097          	auipc	ra,0x0
  34:	77a080e7          	jalr	1914(ra) # 7aa <sigreturn>
}
  38:	60a2                	ld	ra,8(sp)
  3a:	6402                	ld	s0,0(sp)
  3c:	0141                	addi	sp,sp,16
  3e:	8082                	ret

0000000000000040 <slow_handler>:
        printf("test2 passed\n");
    }
}

void slow_handler()
{
  40:	1101                	addi	sp,sp,-32
  42:	ec06                	sd	ra,24(sp)
  44:	e822                	sd	s0,16(sp)
  46:	e426                	sd	s1,8(sp)
  48:	1000                	addi	s0,sp,32
    count++;
  4a:	00001497          	auipc	s1,0x1
  4e:	fb648493          	addi	s1,s1,-74 # 1000 <count>
  52:	00001797          	auipc	a5,0x1
  56:	fae7a783          	lw	a5,-82(a5) # 1000 <count>
  5a:	2785                	addiw	a5,a5,1
  5c:	c09c                	sw	a5,0(s1)
    printf("alarm!\n");
  5e:	00001517          	auipc	a0,0x1
  62:	bfa50513          	addi	a0,a0,-1030 # c58 <malloc+0x108>
  66:	00001097          	auipc	ra,0x1
  6a:	a2c080e7          	jalr	-1492(ra) # a92 <printf>
    if (count > 1)
  6e:	4098                	lw	a4,0(s1)
  70:	2701                	sext.w	a4,a4
  72:	4685                	li	a3,1
  74:	1dcd67b7          	lui	a5,0x1dcd6
  78:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
  7c:	02e6c463          	blt	a3,a4,a4 <slow_handler+0x64>
        printf("test2 failed: alarm handler called more than once\n");
        exit(1);
    }
    for (int i = 0; i < 1000 * 500000; i++)
    {
        asm volatile("nop"); // avoid compiler optimizing away loop
  80:	0001                	nop
    for (int i = 0; i < 1000 * 500000; i++)
  82:	37fd                	addiw	a5,a5,-1
  84:	fff5                	bnez	a5,80 <slow_handler+0x40>
    }
    sigalarm(0, 0);
  86:	4581                	li	a1,0
  88:	4501                	li	a0,0
  8a:	00000097          	auipc	ra,0x0
  8e:	718080e7          	jalr	1816(ra) # 7a2 <sigalarm>
    sigreturn();
  92:	00000097          	auipc	ra,0x0
  96:	718080e7          	jalr	1816(ra) # 7aa <sigreturn>
}
  9a:	60e2                	ld	ra,24(sp)
  9c:	6442                	ld	s0,16(sp)
  9e:	64a2                	ld	s1,8(sp)
  a0:	6105                	addi	sp,sp,32
  a2:	8082                	ret
        printf("test2 failed: alarm handler called more than once\n");
  a4:	00001517          	auipc	a0,0x1
  a8:	bbc50513          	addi	a0,a0,-1092 # c60 <malloc+0x110>
  ac:	00001097          	auipc	ra,0x1
  b0:	9e6080e7          	jalr	-1562(ra) # a92 <printf>
        exit(1);
  b4:	4505                	li	a0,1
  b6:	00000097          	auipc	ra,0x0
  ba:	63c080e7          	jalr	1596(ra) # 6f2 <exit>

00000000000000be <dummy_handler>:

//
// dummy alarm handler; after running immediately uninstall
// itself and finish signal handling
void dummy_handler()
{
  be:	1141                	addi	sp,sp,-16
  c0:	e406                	sd	ra,8(sp)
  c2:	e022                	sd	s0,0(sp)
  c4:	0800                	addi	s0,sp,16
    // printf("DUMMY\n");
    
    sigalarm(0, 0);
  c6:	4581                	li	a1,0
  c8:	4501                	li	a0,0
  ca:	00000097          	auipc	ra,0x0
  ce:	6d8080e7          	jalr	1752(ra) # 7a2 <sigalarm>

    // printf("DUMMY: Disabling alarm\n");
    sigreturn();
  d2:	00000097          	auipc	ra,0x0
  d6:	6d8080e7          	jalr	1752(ra) # 7aa <sigreturn>
    
}
  da:	60a2                	ld	ra,8(sp)
  dc:	6402                	ld	s0,0(sp)
  de:	0141                	addi	sp,sp,16
  e0:	8082                	ret

00000000000000e2 <test0>:
{
  e2:	7139                	addi	sp,sp,-64
  e4:	fc06                	sd	ra,56(sp)
  e6:	f822                	sd	s0,48(sp)
  e8:	f426                	sd	s1,40(sp)
  ea:	f04a                	sd	s2,32(sp)
  ec:	ec4e                	sd	s3,24(sp)
  ee:	e852                	sd	s4,16(sp)
  f0:	e456                	sd	s5,8(sp)
  f2:	0080                	addi	s0,sp,64
    printf("test0 start\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	ba450513          	addi	a0,a0,-1116 # c98 <malloc+0x148>
  fc:	00001097          	auipc	ra,0x1
 100:	996080e7          	jalr	-1642(ra) # a92 <printf>
    count = 0;
 104:	00001797          	auipc	a5,0x1
 108:	ee07ae23          	sw	zero,-260(a5) # 1000 <count>
    sigalarm(2, periodic);
 10c:	00000597          	auipc	a1,0x0
 110:	ef458593          	addi	a1,a1,-268 # 0 <periodic>
 114:	4509                	li	a0,2
 116:	00000097          	auipc	ra,0x0
 11a:	68c080e7          	jalr	1676(ra) # 7a2 <sigalarm>
    for (i = 0; i < 1000 * 500000; i++)
 11e:	4481                	li	s1,0
        if ((i % 1000000) == 0)
 120:	000f4937          	lui	s2,0xf4
 124:	2409091b          	addiw	s2,s2,576
            write(2, ".", 1);
 128:	00001a97          	auipc	s5,0x1
 12c:	b80a8a93          	addi	s5,s5,-1152 # ca8 <malloc+0x158>
        if (count > 0)
 130:	00001a17          	auipc	s4,0x1
 134:	ed0a0a13          	addi	s4,s4,-304 # 1000 <count>
    for (i = 0; i < 1000 * 500000; i++)
 138:	1dcd69b7          	lui	s3,0x1dcd6
 13c:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 140:	a809                	j	152 <test0+0x70>
        if (count > 0)
 142:	000a2783          	lw	a5,0(s4)
 146:	2781                	sext.w	a5,a5
 148:	02f04063          	bgtz	a5,168 <test0+0x86>
    for (i = 0; i < 1000 * 500000; i++)
 14c:	2485                	addiw	s1,s1,1
 14e:	01348d63          	beq	s1,s3,168 <test0+0x86>
        if ((i % 1000000) == 0)
 152:	0324e7bb          	remw	a5,s1,s2
 156:	f7f5                	bnez	a5,142 <test0+0x60>
            write(2, ".", 1);
 158:	4605                	li	a2,1
 15a:	85d6                	mv	a1,s5
 15c:	4509                	li	a0,2
 15e:	00000097          	auipc	ra,0x0
 162:	5b4080e7          	jalr	1460(ra) # 712 <write>
 166:	bff1                	j	142 <test0+0x60>
    sigalarm(0, 0);
 168:	4581                	li	a1,0
 16a:	4501                	li	a0,0
 16c:	00000097          	auipc	ra,0x0
 170:	636080e7          	jalr	1590(ra) # 7a2 <sigalarm>
    if (count > 0)
 174:	00001797          	auipc	a5,0x1
 178:	e8c7a783          	lw	a5,-372(a5) # 1000 <count>
 17c:	02f05363          	blez	a5,1a2 <test0+0xc0>
        printf("test0 passed\n");
 180:	00001517          	auipc	a0,0x1
 184:	b3050513          	addi	a0,a0,-1232 # cb0 <malloc+0x160>
 188:	00001097          	auipc	ra,0x1
 18c:	90a080e7          	jalr	-1782(ra) # a92 <printf>
}
 190:	70e2                	ld	ra,56(sp)
 192:	7442                	ld	s0,48(sp)
 194:	74a2                	ld	s1,40(sp)
 196:	7902                	ld	s2,32(sp)
 198:	69e2                	ld	s3,24(sp)
 19a:	6a42                	ld	s4,16(sp)
 19c:	6aa2                	ld	s5,8(sp)
 19e:	6121                	addi	sp,sp,64
 1a0:	8082                	ret
        printf("\ntest0 failed: the kernel never called the alarm handler\n");
 1a2:	00001517          	auipc	a0,0x1
 1a6:	b1e50513          	addi	a0,a0,-1250 # cc0 <malloc+0x170>
 1aa:	00001097          	auipc	ra,0x1
 1ae:	8e8080e7          	jalr	-1816(ra) # a92 <printf>
}
 1b2:	bff9                	j	190 <test0+0xae>

00000000000001b4 <foo>:
{
 1b4:	1101                	addi	sp,sp,-32
 1b6:	ec06                	sd	ra,24(sp)
 1b8:	e822                	sd	s0,16(sp)
 1ba:	e426                	sd	s1,8(sp)
 1bc:	1000                	addi	s0,sp,32
 1be:	84ae                	mv	s1,a1
    if ((i % 2500000) == 0)
 1c0:	002627b7          	lui	a5,0x262
 1c4:	5a07879b          	addiw	a5,a5,1440
 1c8:	02f5653b          	remw	a0,a0,a5
 1cc:	c909                	beqz	a0,1de <foo+0x2a>
    *j += 1;
 1ce:	409c                	lw	a5,0(s1)
 1d0:	2785                	addiw	a5,a5,1
 1d2:	c09c                	sw	a5,0(s1)
}
 1d4:	60e2                	ld	ra,24(sp)
 1d6:	6442                	ld	s0,16(sp)
 1d8:	64a2                	ld	s1,8(sp)
 1da:	6105                	addi	sp,sp,32
 1dc:	8082                	ret
        write(2, ".", 1);
 1de:	4605                	li	a2,1
 1e0:	00001597          	auipc	a1,0x1
 1e4:	ac858593          	addi	a1,a1,-1336 # ca8 <malloc+0x158>
 1e8:	4509                	li	a0,2
 1ea:	00000097          	auipc	ra,0x0
 1ee:	528080e7          	jalr	1320(ra) # 712 <write>
 1f2:	bff1                	j	1ce <foo+0x1a>

00000000000001f4 <test1>:
{
 1f4:	7139                	addi	sp,sp,-64
 1f6:	fc06                	sd	ra,56(sp)
 1f8:	f822                	sd	s0,48(sp)
 1fa:	f426                	sd	s1,40(sp)
 1fc:	f04a                	sd	s2,32(sp)
 1fe:	ec4e                	sd	s3,24(sp)
 200:	e852                	sd	s4,16(sp)
 202:	0080                	addi	s0,sp,64
    printf("test1 start\n");
 204:	00001517          	auipc	a0,0x1
 208:	afc50513          	addi	a0,a0,-1284 # d00 <malloc+0x1b0>
 20c:	00001097          	auipc	ra,0x1
 210:	886080e7          	jalr	-1914(ra) # a92 <printf>
    count = 0;
 214:	00001797          	auipc	a5,0x1
 218:	de07a623          	sw	zero,-532(a5) # 1000 <count>
    j = 0;
 21c:	fc042623          	sw	zero,-52(s0)
    sigalarm(2, periodic);
 220:	00000597          	auipc	a1,0x0
 224:	de058593          	addi	a1,a1,-544 # 0 <periodic>
 228:	4509                	li	a0,2
 22a:	00000097          	auipc	ra,0x0
 22e:	578080e7          	jalr	1400(ra) # 7a2 <sigalarm>
    for (i = 0; i < 500000000; i++)
 232:	4481                	li	s1,0
        if (count >= 10)
 234:	00001a17          	auipc	s4,0x1
 238:	dcca0a13          	addi	s4,s4,-564 # 1000 <count>
 23c:	49a5                	li	s3,9
    for (i = 0; i < 500000000; i++)
 23e:	1dcd6937          	lui	s2,0x1dcd6
 242:	50090913          	addi	s2,s2,1280 # 1dcd6500 <base+0x1dcd54f0>
        if (count >= 10)
 246:	000a2783          	lw	a5,0(s4)
 24a:	2781                	sext.w	a5,a5
 24c:	00f9cc63          	blt	s3,a5,264 <test1+0x70>
        foo(i, &j);
 250:	fcc40593          	addi	a1,s0,-52
 254:	8526                	mv	a0,s1
 256:	00000097          	auipc	ra,0x0
 25a:	f5e080e7          	jalr	-162(ra) # 1b4 <foo>
    for (i = 0; i < 500000000; i++)
 25e:	2485                	addiw	s1,s1,1
 260:	ff2493e3          	bne	s1,s2,246 <test1+0x52>
    if (count < 10)
 264:	00001717          	auipc	a4,0x1
 268:	d9c72703          	lw	a4,-612(a4) # 1000 <count>
 26c:	47a5                	li	a5,9
 26e:	02e7d663          	bge	a5,a4,29a <test1+0xa6>
    else if (i != j)
 272:	fcc42783          	lw	a5,-52(s0)
 276:	02978b63          	beq	a5,s1,2ac <test1+0xb8>
        printf("\ntest1 failed: foo() executed fewer times than it was called\n");
 27a:	00001517          	auipc	a0,0x1
 27e:	ac650513          	addi	a0,a0,-1338 # d40 <malloc+0x1f0>
 282:	00001097          	auipc	ra,0x1
 286:	810080e7          	jalr	-2032(ra) # a92 <printf>
}
 28a:	70e2                	ld	ra,56(sp)
 28c:	7442                	ld	s0,48(sp)
 28e:	74a2                	ld	s1,40(sp)
 290:	7902                	ld	s2,32(sp)
 292:	69e2                	ld	s3,24(sp)
 294:	6a42                	ld	s4,16(sp)
 296:	6121                	addi	sp,sp,64
 298:	8082                	ret
        printf("\ntest1 failed: too few calls to the handler\n");
 29a:	00001517          	auipc	a0,0x1
 29e:	a7650513          	addi	a0,a0,-1418 # d10 <malloc+0x1c0>
 2a2:	00000097          	auipc	ra,0x0
 2a6:	7f0080e7          	jalr	2032(ra) # a92 <printf>
 2aa:	b7c5                	j	28a <test1+0x96>
        printf("test1 passed\n");
 2ac:	00001517          	auipc	a0,0x1
 2b0:	ad450513          	addi	a0,a0,-1324 # d80 <malloc+0x230>
 2b4:	00000097          	auipc	ra,0x0
 2b8:	7de080e7          	jalr	2014(ra) # a92 <printf>
}
 2bc:	b7f9                	j	28a <test1+0x96>

00000000000002be <test2>:
{
 2be:	715d                	addi	sp,sp,-80
 2c0:	e486                	sd	ra,72(sp)
 2c2:	e0a2                	sd	s0,64(sp)
 2c4:	fc26                	sd	s1,56(sp)
 2c6:	f84a                	sd	s2,48(sp)
 2c8:	f44e                	sd	s3,40(sp)
 2ca:	f052                	sd	s4,32(sp)
 2cc:	ec56                	sd	s5,24(sp)
 2ce:	0880                	addi	s0,sp,80
    printf("test2 start\n");
 2d0:	00001517          	auipc	a0,0x1
 2d4:	ac050513          	addi	a0,a0,-1344 # d90 <malloc+0x240>
 2d8:	00000097          	auipc	ra,0x0
 2dc:	7ba080e7          	jalr	1978(ra) # a92 <printf>
    if ((pid = fork()) < 0)
 2e0:	00000097          	auipc	ra,0x0
 2e4:	40a080e7          	jalr	1034(ra) # 6ea <fork>
 2e8:	04054263          	bltz	a0,32c <test2+0x6e>
 2ec:	84aa                	mv	s1,a0
    if (pid == 0)
 2ee:	e539                	bnez	a0,33c <test2+0x7e>
        count = 0;
 2f0:	00001797          	auipc	a5,0x1
 2f4:	d007a823          	sw	zero,-752(a5) # 1000 <count>
        sigalarm(2, slow_handler);
 2f8:	00000597          	auipc	a1,0x0
 2fc:	d4858593          	addi	a1,a1,-696 # 40 <slow_handler>
 300:	4509                	li	a0,2
 302:	00000097          	auipc	ra,0x0
 306:	4a0080e7          	jalr	1184(ra) # 7a2 <sigalarm>
            if ((i % 1000000) == 0)
 30a:	000f4937          	lui	s2,0xf4
 30e:	2409091b          	addiw	s2,s2,576
                write(2, ".", 1);
 312:	00001a97          	auipc	s5,0x1
 316:	996a8a93          	addi	s5,s5,-1642 # ca8 <malloc+0x158>
            if (count > 0)
 31a:	00001a17          	auipc	s4,0x1
 31e:	ce6a0a13          	addi	s4,s4,-794 # 1000 <count>
        for (i = 0; i < 1000 * 500000; i++)
 322:	1dcd69b7          	lui	s3,0x1dcd6
 326:	50098993          	addi	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 32a:	a099                	j	370 <test2+0xb2>
        printf("test2: fork failed\n");
 32c:	00001517          	auipc	a0,0x1
 330:	a7450513          	addi	a0,a0,-1420 # da0 <malloc+0x250>
 334:	00000097          	auipc	ra,0x0
 338:	75e080e7          	jalr	1886(ra) # a92 <printf>
    wait(&status);
 33c:	fbc40513          	addi	a0,s0,-68
 340:	00000097          	auipc	ra,0x0
 344:	3ba080e7          	jalr	954(ra) # 6fa <wait>
    if (status == 0)
 348:	fbc42783          	lw	a5,-68(s0)
 34c:	c7a5                	beqz	a5,3b4 <test2+0xf6>
}
 34e:	60a6                	ld	ra,72(sp)
 350:	6406                	ld	s0,64(sp)
 352:	74e2                	ld	s1,56(sp)
 354:	7942                	ld	s2,48(sp)
 356:	79a2                	ld	s3,40(sp)
 358:	7a02                	ld	s4,32(sp)
 35a:	6ae2                	ld	s5,24(sp)
 35c:	6161                	addi	sp,sp,80
 35e:	8082                	ret
            if (count > 0)
 360:	000a2783          	lw	a5,0(s4)
 364:	2781                	sext.w	a5,a5
 366:	02f04063          	bgtz	a5,386 <test2+0xc8>
        for (i = 0; i < 1000 * 500000; i++)
 36a:	2485                	addiw	s1,s1,1
 36c:	01348d63          	beq	s1,s3,386 <test2+0xc8>
            if ((i % 1000000) == 0)
 370:	0324e7bb          	remw	a5,s1,s2
 374:	f7f5                	bnez	a5,360 <test2+0xa2>
                write(2, ".", 1);
 376:	4605                	li	a2,1
 378:	85d6                	mv	a1,s5
 37a:	4509                	li	a0,2
 37c:	00000097          	auipc	ra,0x0
 380:	396080e7          	jalr	918(ra) # 712 <write>
 384:	bff1                	j	360 <test2+0xa2>
        if (count == 0)
 386:	00001797          	auipc	a5,0x1
 38a:	c7a7a783          	lw	a5,-902(a5) # 1000 <count>
 38e:	ef91                	bnez	a5,3aa <test2+0xec>
            printf("\ntest2 failed: alarm not called\n");
 390:	00001517          	auipc	a0,0x1
 394:	a2850513          	addi	a0,a0,-1496 # db8 <malloc+0x268>
 398:	00000097          	auipc	ra,0x0
 39c:	6fa080e7          	jalr	1786(ra) # a92 <printf>
            exit(1);
 3a0:	4505                	li	a0,1
 3a2:	00000097          	auipc	ra,0x0
 3a6:	350080e7          	jalr	848(ra) # 6f2 <exit>
        exit(0);
 3aa:	4501                	li	a0,0
 3ac:	00000097          	auipc	ra,0x0
 3b0:	346080e7          	jalr	838(ra) # 6f2 <exit>
        printf("test2 passed\n");
 3b4:	00001517          	auipc	a0,0x1
 3b8:	a2c50513          	addi	a0,a0,-1492 # de0 <malloc+0x290>
 3bc:	00000097          	auipc	ra,0x0
 3c0:	6d6080e7          	jalr	1750(ra) # a92 <printf>
}
 3c4:	b769                	j	34e <test2+0x90>

00000000000003c6 <test3>:

//
// tests that the return from sys_sigreturn() does not
// modify the a0 register
void test3()
{
 3c6:	1141                	addi	sp,sp,-16
 3c8:	e406                	sd	ra,8(sp)
 3ca:	e022                	sd	s0,0(sp)
 3cc:	0800                	addi	s0,sp,16
    uint64 a0;

    sigalarm(1, dummy_handler);
 3ce:	00000597          	auipc	a1,0x0
 3d2:	cf058593          	addi	a1,a1,-784 # be <dummy_handler>
 3d6:	4505                	li	a0,1
 3d8:	00000097          	auipc	ra,0x0
 3dc:	3ca080e7          	jalr	970(ra) # 7a2 <sigalarm>
    printf("test3 start\n");
 3e0:	00001517          	auipc	a0,0x1
 3e4:	a1050513          	addi	a0,a0,-1520 # df0 <malloc+0x2a0>
 3e8:	00000097          	auipc	ra,0x0
 3ec:	6aa080e7          	jalr	1706(ra) # a92 <printf>

    asm volatile("lui a5, 0");
 3f0:	000007b7          	lui	a5,0x0
    asm volatile("addi a0, a5, 0xac" : : : "a0");
 3f4:	0ac78513          	addi	a0,a5,172 # ac <slow_handler+0x6c>
 3f8:	1dcd67b7          	lui	a5,0x1dcd6
 3fc:	50078793          	addi	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
    for (int i = 0; i < 500000000; i++);
 400:	37fd                	addiw	a5,a5,-1
 402:	fffd                	bnez	a5,400 <test3+0x3a>
    asm volatile("mv %0, a0" : "=r"(a0));
 404:	872a                	mv	a4,a0

    if (a0 != 0xac)
 406:	0ac00793          	li	a5,172
 40a:	00f70e63          	beq	a4,a5,426 <test3+0x60>
        printf("test3 failed: register a0 changed\n");
 40e:	00001517          	auipc	a0,0x1
 412:	9f250513          	addi	a0,a0,-1550 # e00 <malloc+0x2b0>
 416:	00000097          	auipc	ra,0x0
 41a:	67c080e7          	jalr	1660(ra) # a92 <printf>
    else
        printf("test3 passed\n");
 41e:	60a2                	ld	ra,8(sp)
 420:	6402                	ld	s0,0(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret
        printf("test3 passed\n");
 426:	00001517          	auipc	a0,0x1
 42a:	a0250513          	addi	a0,a0,-1534 # e28 <malloc+0x2d8>
 42e:	00000097          	auipc	ra,0x0
 432:	664080e7          	jalr	1636(ra) # a92 <printf>
 436:	b7e5                	j	41e <test3+0x58>

0000000000000438 <main>:
{
 438:	1141                	addi	sp,sp,-16
 43a:	e406                	sd	ra,8(sp)
 43c:	e022                	sd	s0,0(sp)
 43e:	0800                	addi	s0,sp,16
    test0();
 440:	00000097          	auipc	ra,0x0
 444:	ca2080e7          	jalr	-862(ra) # e2 <test0>
    test1();
 448:	00000097          	auipc	ra,0x0
 44c:	dac080e7          	jalr	-596(ra) # 1f4 <test1>
    test2();
 450:	00000097          	auipc	ra,0x0
 454:	e6e080e7          	jalr	-402(ra) # 2be <test2>
    test3();
 458:	00000097          	auipc	ra,0x0
 45c:	f6e080e7          	jalr	-146(ra) # 3c6 <test3>
    exit(0);
 460:	4501                	li	a0,0
 462:	00000097          	auipc	ra,0x0
 466:	290080e7          	jalr	656(ra) # 6f2 <exit>

000000000000046a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 46a:	1141                	addi	sp,sp,-16
 46c:	e406                	sd	ra,8(sp)
 46e:	e022                	sd	s0,0(sp)
 470:	0800                	addi	s0,sp,16
  extern int main();
  main();
 472:	00000097          	auipc	ra,0x0
 476:	fc6080e7          	jalr	-58(ra) # 438 <main>
  exit(0);
 47a:	4501                	li	a0,0
 47c:	00000097          	auipc	ra,0x0
 480:	276080e7          	jalr	630(ra) # 6f2 <exit>

0000000000000484 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 484:	1141                	addi	sp,sp,-16
 486:	e422                	sd	s0,8(sp)
 488:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 48a:	87aa                	mv	a5,a0
 48c:	0585                	addi	a1,a1,1
 48e:	0785                	addi	a5,a5,1
 490:	fff5c703          	lbu	a4,-1(a1)
 494:	fee78fa3          	sb	a4,-1(a5)
 498:	fb75                	bnez	a4,48c <strcpy+0x8>
    ;
  return os;
}
 49a:	6422                	ld	s0,8(sp)
 49c:	0141                	addi	sp,sp,16
 49e:	8082                	ret

00000000000004a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4a0:	1141                	addi	sp,sp,-16
 4a2:	e422                	sd	s0,8(sp)
 4a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4a6:	00054783          	lbu	a5,0(a0)
 4aa:	cb91                	beqz	a5,4be <strcmp+0x1e>
 4ac:	0005c703          	lbu	a4,0(a1)
 4b0:	00f71763          	bne	a4,a5,4be <strcmp+0x1e>
    p++, q++;
 4b4:	0505                	addi	a0,a0,1
 4b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4b8:	00054783          	lbu	a5,0(a0)
 4bc:	fbe5                	bnez	a5,4ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4be:	0005c503          	lbu	a0,0(a1)
}
 4c2:	40a7853b          	subw	a0,a5,a0
 4c6:	6422                	ld	s0,8(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret

00000000000004cc <strlen>:

uint
strlen(const char *s)
{
 4cc:	1141                	addi	sp,sp,-16
 4ce:	e422                	sd	s0,8(sp)
 4d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4d2:	00054783          	lbu	a5,0(a0)
 4d6:	cf91                	beqz	a5,4f2 <strlen+0x26>
 4d8:	0505                	addi	a0,a0,1
 4da:	87aa                	mv	a5,a0
 4dc:	4685                	li	a3,1
 4de:	9e89                	subw	a3,a3,a0
 4e0:	00f6853b          	addw	a0,a3,a5
 4e4:	0785                	addi	a5,a5,1
 4e6:	fff7c703          	lbu	a4,-1(a5)
 4ea:	fb7d                	bnez	a4,4e0 <strlen+0x14>
    ;
  return n;
}
 4ec:	6422                	ld	s0,8(sp)
 4ee:	0141                	addi	sp,sp,16
 4f0:	8082                	ret
  for(n = 0; s[n]; n++)
 4f2:	4501                	li	a0,0
 4f4:	bfe5                	j	4ec <strlen+0x20>

00000000000004f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4f6:	1141                	addi	sp,sp,-16
 4f8:	e422                	sd	s0,8(sp)
 4fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4fc:	ca19                	beqz	a2,512 <memset+0x1c>
 4fe:	87aa                	mv	a5,a0
 500:	1602                	slli	a2,a2,0x20
 502:	9201                	srli	a2,a2,0x20
 504:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 508:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 50c:	0785                	addi	a5,a5,1
 50e:	fee79de3          	bne	a5,a4,508 <memset+0x12>
  }
  return dst;
}
 512:	6422                	ld	s0,8(sp)
 514:	0141                	addi	sp,sp,16
 516:	8082                	ret

0000000000000518 <strchr>:

char*
strchr(const char *s, char c)
{
 518:	1141                	addi	sp,sp,-16
 51a:	e422                	sd	s0,8(sp)
 51c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 51e:	00054783          	lbu	a5,0(a0)
 522:	cb99                	beqz	a5,538 <strchr+0x20>
    if(*s == c)
 524:	00f58763          	beq	a1,a5,532 <strchr+0x1a>
  for(; *s; s++)
 528:	0505                	addi	a0,a0,1
 52a:	00054783          	lbu	a5,0(a0)
 52e:	fbfd                	bnez	a5,524 <strchr+0xc>
      return (char*)s;
  return 0;
 530:	4501                	li	a0,0
}
 532:	6422                	ld	s0,8(sp)
 534:	0141                	addi	sp,sp,16
 536:	8082                	ret
  return 0;
 538:	4501                	li	a0,0
 53a:	bfe5                	j	532 <strchr+0x1a>

000000000000053c <gets>:

char*
gets(char *buf, int max)
{
 53c:	711d                	addi	sp,sp,-96
 53e:	ec86                	sd	ra,88(sp)
 540:	e8a2                	sd	s0,80(sp)
 542:	e4a6                	sd	s1,72(sp)
 544:	e0ca                	sd	s2,64(sp)
 546:	fc4e                	sd	s3,56(sp)
 548:	f852                	sd	s4,48(sp)
 54a:	f456                	sd	s5,40(sp)
 54c:	f05a                	sd	s6,32(sp)
 54e:	ec5e                	sd	s7,24(sp)
 550:	1080                	addi	s0,sp,96
 552:	8baa                	mv	s7,a0
 554:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 556:	892a                	mv	s2,a0
 558:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 55a:	4aa9                	li	s5,10
 55c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 55e:	89a6                	mv	s3,s1
 560:	2485                	addiw	s1,s1,1
 562:	0344d863          	bge	s1,s4,592 <gets+0x56>
    cc = read(0, &c, 1);
 566:	4605                	li	a2,1
 568:	faf40593          	addi	a1,s0,-81
 56c:	4501                	li	a0,0
 56e:	00000097          	auipc	ra,0x0
 572:	19c080e7          	jalr	412(ra) # 70a <read>
    if(cc < 1)
 576:	00a05e63          	blez	a0,592 <gets+0x56>
    buf[i++] = c;
 57a:	faf44783          	lbu	a5,-81(s0)
 57e:	00f90023          	sb	a5,0(s2) # f4000 <base+0xf2ff0>
    if(c == '\n' || c == '\r')
 582:	01578763          	beq	a5,s5,590 <gets+0x54>
 586:	0905                	addi	s2,s2,1
 588:	fd679be3          	bne	a5,s6,55e <gets+0x22>
  for(i=0; i+1 < max; ){
 58c:	89a6                	mv	s3,s1
 58e:	a011                	j	592 <gets+0x56>
 590:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 592:	99de                	add	s3,s3,s7
 594:	00098023          	sb	zero,0(s3)
  return buf;
}
 598:	855e                	mv	a0,s7
 59a:	60e6                	ld	ra,88(sp)
 59c:	6446                	ld	s0,80(sp)
 59e:	64a6                	ld	s1,72(sp)
 5a0:	6906                	ld	s2,64(sp)
 5a2:	79e2                	ld	s3,56(sp)
 5a4:	7a42                	ld	s4,48(sp)
 5a6:	7aa2                	ld	s5,40(sp)
 5a8:	7b02                	ld	s6,32(sp)
 5aa:	6be2                	ld	s7,24(sp)
 5ac:	6125                	addi	sp,sp,96
 5ae:	8082                	ret

00000000000005b0 <stat>:

int
stat(const char *n, struct stat *st)
{
 5b0:	1101                	addi	sp,sp,-32
 5b2:	ec06                	sd	ra,24(sp)
 5b4:	e822                	sd	s0,16(sp)
 5b6:	e426                	sd	s1,8(sp)
 5b8:	e04a                	sd	s2,0(sp)
 5ba:	1000                	addi	s0,sp,32
 5bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5be:	4581                	li	a1,0
 5c0:	00000097          	auipc	ra,0x0
 5c4:	172080e7          	jalr	370(ra) # 732 <open>
  if(fd < 0)
 5c8:	02054563          	bltz	a0,5f2 <stat+0x42>
 5cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5ce:	85ca                	mv	a1,s2
 5d0:	00000097          	auipc	ra,0x0
 5d4:	17a080e7          	jalr	378(ra) # 74a <fstat>
 5d8:	892a                	mv	s2,a0
  close(fd);
 5da:	8526                	mv	a0,s1
 5dc:	00000097          	auipc	ra,0x0
 5e0:	13e080e7          	jalr	318(ra) # 71a <close>
  return r;
}
 5e4:	854a                	mv	a0,s2
 5e6:	60e2                	ld	ra,24(sp)
 5e8:	6442                	ld	s0,16(sp)
 5ea:	64a2                	ld	s1,8(sp)
 5ec:	6902                	ld	s2,0(sp)
 5ee:	6105                	addi	sp,sp,32
 5f0:	8082                	ret
    return -1;
 5f2:	597d                	li	s2,-1
 5f4:	bfc5                	j	5e4 <stat+0x34>

00000000000005f6 <atoi>:

int
atoi(const char *s)
{
 5f6:	1141                	addi	sp,sp,-16
 5f8:	e422                	sd	s0,8(sp)
 5fa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5fc:	00054603          	lbu	a2,0(a0)
 600:	fd06079b          	addiw	a5,a2,-48
 604:	0ff7f793          	andi	a5,a5,255
 608:	4725                	li	a4,9
 60a:	02f76963          	bltu	a4,a5,63c <atoi+0x46>
 60e:	86aa                	mv	a3,a0
  n = 0;
 610:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 612:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 614:	0685                	addi	a3,a3,1
 616:	0025179b          	slliw	a5,a0,0x2
 61a:	9fa9                	addw	a5,a5,a0
 61c:	0017979b          	slliw	a5,a5,0x1
 620:	9fb1                	addw	a5,a5,a2
 622:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 626:	0006c603          	lbu	a2,0(a3)
 62a:	fd06071b          	addiw	a4,a2,-48
 62e:	0ff77713          	andi	a4,a4,255
 632:	fee5f1e3          	bgeu	a1,a4,614 <atoi+0x1e>
  return n;
}
 636:	6422                	ld	s0,8(sp)
 638:	0141                	addi	sp,sp,16
 63a:	8082                	ret
  n = 0;
 63c:	4501                	li	a0,0
 63e:	bfe5                	j	636 <atoi+0x40>

0000000000000640 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 640:	1141                	addi	sp,sp,-16
 642:	e422                	sd	s0,8(sp)
 644:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 646:	02b57463          	bgeu	a0,a1,66e <memmove+0x2e>
    while(n-- > 0)
 64a:	00c05f63          	blez	a2,668 <memmove+0x28>
 64e:	1602                	slli	a2,a2,0x20
 650:	9201                	srli	a2,a2,0x20
 652:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 656:	872a                	mv	a4,a0
      *dst++ = *src++;
 658:	0585                	addi	a1,a1,1
 65a:	0705                	addi	a4,a4,1
 65c:	fff5c683          	lbu	a3,-1(a1)
 660:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 664:	fee79ae3          	bne	a5,a4,658 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 668:	6422                	ld	s0,8(sp)
 66a:	0141                	addi	sp,sp,16
 66c:	8082                	ret
    dst += n;
 66e:	00c50733          	add	a4,a0,a2
    src += n;
 672:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 674:	fec05ae3          	blez	a2,668 <memmove+0x28>
 678:	fff6079b          	addiw	a5,a2,-1
 67c:	1782                	slli	a5,a5,0x20
 67e:	9381                	srli	a5,a5,0x20
 680:	fff7c793          	not	a5,a5
 684:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 686:	15fd                	addi	a1,a1,-1
 688:	177d                	addi	a4,a4,-1
 68a:	0005c683          	lbu	a3,0(a1)
 68e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 692:	fee79ae3          	bne	a5,a4,686 <memmove+0x46>
 696:	bfc9                	j	668 <memmove+0x28>

0000000000000698 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 698:	1141                	addi	sp,sp,-16
 69a:	e422                	sd	s0,8(sp)
 69c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 69e:	ca05                	beqz	a2,6ce <memcmp+0x36>
 6a0:	fff6069b          	addiw	a3,a2,-1
 6a4:	1682                	slli	a3,a3,0x20
 6a6:	9281                	srli	a3,a3,0x20
 6a8:	0685                	addi	a3,a3,1
 6aa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6ac:	00054783          	lbu	a5,0(a0)
 6b0:	0005c703          	lbu	a4,0(a1)
 6b4:	00e79863          	bne	a5,a4,6c4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6b8:	0505                	addi	a0,a0,1
    p2++;
 6ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6bc:	fed518e3          	bne	a0,a3,6ac <memcmp+0x14>
  }
  return 0;
 6c0:	4501                	li	a0,0
 6c2:	a019                	j	6c8 <memcmp+0x30>
      return *p1 - *p2;
 6c4:	40e7853b          	subw	a0,a5,a4
}
 6c8:	6422                	ld	s0,8(sp)
 6ca:	0141                	addi	sp,sp,16
 6cc:	8082                	ret
  return 0;
 6ce:	4501                	li	a0,0
 6d0:	bfe5                	j	6c8 <memcmp+0x30>

00000000000006d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6d2:	1141                	addi	sp,sp,-16
 6d4:	e406                	sd	ra,8(sp)
 6d6:	e022                	sd	s0,0(sp)
 6d8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 6da:	00000097          	auipc	ra,0x0
 6de:	f66080e7          	jalr	-154(ra) # 640 <memmove>
}
 6e2:	60a2                	ld	ra,8(sp)
 6e4:	6402                	ld	s0,0(sp)
 6e6:	0141                	addi	sp,sp,16
 6e8:	8082                	ret

00000000000006ea <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6ea:	4885                	li	a7,1
 ecall
 6ec:	00000073          	ecall
 ret
 6f0:	8082                	ret

00000000000006f2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 6f2:	4889                	li	a7,2
 ecall
 6f4:	00000073          	ecall
 ret
 6f8:	8082                	ret

00000000000006fa <wait>:
.global wait
wait:
 li a7, SYS_wait
 6fa:	488d                	li	a7,3
 ecall
 6fc:	00000073          	ecall
 ret
 700:	8082                	ret

0000000000000702 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 702:	4891                	li	a7,4
 ecall
 704:	00000073          	ecall
 ret
 708:	8082                	ret

000000000000070a <read>:
.global read
read:
 li a7, SYS_read
 70a:	4895                	li	a7,5
 ecall
 70c:	00000073          	ecall
 ret
 710:	8082                	ret

0000000000000712 <write>:
.global write
write:
 li a7, SYS_write
 712:	48c1                	li	a7,16
 ecall
 714:	00000073          	ecall
 ret
 718:	8082                	ret

000000000000071a <close>:
.global close
close:
 li a7, SYS_close
 71a:	48d5                	li	a7,21
 ecall
 71c:	00000073          	ecall
 ret
 720:	8082                	ret

0000000000000722 <kill>:
.global kill
kill:
 li a7, SYS_kill
 722:	4899                	li	a7,6
 ecall
 724:	00000073          	ecall
 ret
 728:	8082                	ret

000000000000072a <exec>:
.global exec
exec:
 li a7, SYS_exec
 72a:	489d                	li	a7,7
 ecall
 72c:	00000073          	ecall
 ret
 730:	8082                	ret

0000000000000732 <open>:
.global open
open:
 li a7, SYS_open
 732:	48bd                	li	a7,15
 ecall
 734:	00000073          	ecall
 ret
 738:	8082                	ret

000000000000073a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 73a:	48c5                	li	a7,17
 ecall
 73c:	00000073          	ecall
 ret
 740:	8082                	ret

0000000000000742 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 742:	48c9                	li	a7,18
 ecall
 744:	00000073          	ecall
 ret
 748:	8082                	ret

000000000000074a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 74a:	48a1                	li	a7,8
 ecall
 74c:	00000073          	ecall
 ret
 750:	8082                	ret

0000000000000752 <link>:
.global link
link:
 li a7, SYS_link
 752:	48cd                	li	a7,19
 ecall
 754:	00000073          	ecall
 ret
 758:	8082                	ret

000000000000075a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 75a:	48d1                	li	a7,20
 ecall
 75c:	00000073          	ecall
 ret
 760:	8082                	ret

0000000000000762 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 762:	48a5                	li	a7,9
 ecall
 764:	00000073          	ecall
 ret
 768:	8082                	ret

000000000000076a <dup>:
.global dup
dup:
 li a7, SYS_dup
 76a:	48a9                	li	a7,10
 ecall
 76c:	00000073          	ecall
 ret
 770:	8082                	ret

0000000000000772 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 772:	48ad                	li	a7,11
 ecall
 774:	00000073          	ecall
 ret
 778:	8082                	ret

000000000000077a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 77a:	48b1                	li	a7,12
 ecall
 77c:	00000073          	ecall
 ret
 780:	8082                	ret

0000000000000782 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 782:	48b5                	li	a7,13
 ecall
 784:	00000073          	ecall
 ret
 788:	8082                	ret

000000000000078a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 78a:	48b9                	li	a7,14
 ecall
 78c:	00000073          	ecall
 ret
 790:	8082                	ret

0000000000000792 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 792:	48d9                	li	a7,22
 ecall
 794:	00000073          	ecall
 ret
 798:	8082                	ret

000000000000079a <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 79a:	48dd                	li	a7,23
 ecall
 79c:	00000073          	ecall
 ret
 7a0:	8082                	ret

00000000000007a2 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 7a2:	48e1                	li	a7,24
 ecall
 7a4:	00000073          	ecall
 ret
 7a8:	8082                	ret

00000000000007aa <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 7aa:	48e5                	li	a7,25
 ecall
 7ac:	00000073          	ecall
 ret
 7b0:	8082                	ret

00000000000007b2 <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 7b2:	48e9                	li	a7,26
 ecall
 7b4:	00000073          	ecall
 ret
 7b8:	8082                	ret

00000000000007ba <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7ba:	1101                	addi	sp,sp,-32
 7bc:	ec06                	sd	ra,24(sp)
 7be:	e822                	sd	s0,16(sp)
 7c0:	1000                	addi	s0,sp,32
 7c2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7c6:	4605                	li	a2,1
 7c8:	fef40593          	addi	a1,s0,-17
 7cc:	00000097          	auipc	ra,0x0
 7d0:	f46080e7          	jalr	-186(ra) # 712 <write>
}
 7d4:	60e2                	ld	ra,24(sp)
 7d6:	6442                	ld	s0,16(sp)
 7d8:	6105                	addi	sp,sp,32
 7da:	8082                	ret

00000000000007dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7dc:	7139                	addi	sp,sp,-64
 7de:	fc06                	sd	ra,56(sp)
 7e0:	f822                	sd	s0,48(sp)
 7e2:	f426                	sd	s1,40(sp)
 7e4:	f04a                	sd	s2,32(sp)
 7e6:	ec4e                	sd	s3,24(sp)
 7e8:	0080                	addi	s0,sp,64
 7ea:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7ec:	c299                	beqz	a3,7f2 <printint+0x16>
 7ee:	0805c863          	bltz	a1,87e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7f2:	2581                	sext.w	a1,a1
  neg = 0;
 7f4:	4881                	li	a7,0
 7f6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 7fa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7fc:	2601                	sext.w	a2,a2
 7fe:	00000517          	auipc	a0,0x0
 802:	64250513          	addi	a0,a0,1602 # e40 <digits>
 806:	883a                	mv	a6,a4
 808:	2705                	addiw	a4,a4,1
 80a:	02c5f7bb          	remuw	a5,a1,a2
 80e:	1782                	slli	a5,a5,0x20
 810:	9381                	srli	a5,a5,0x20
 812:	97aa                	add	a5,a5,a0
 814:	0007c783          	lbu	a5,0(a5)
 818:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 81c:	0005879b          	sext.w	a5,a1
 820:	02c5d5bb          	divuw	a1,a1,a2
 824:	0685                	addi	a3,a3,1
 826:	fec7f0e3          	bgeu	a5,a2,806 <printint+0x2a>
  if(neg)
 82a:	00088b63          	beqz	a7,840 <printint+0x64>
    buf[i++] = '-';
 82e:	fd040793          	addi	a5,s0,-48
 832:	973e                	add	a4,a4,a5
 834:	02d00793          	li	a5,45
 838:	fef70823          	sb	a5,-16(a4)
 83c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 840:	02e05863          	blez	a4,870 <printint+0x94>
 844:	fc040793          	addi	a5,s0,-64
 848:	00e78933          	add	s2,a5,a4
 84c:	fff78993          	addi	s3,a5,-1
 850:	99ba                	add	s3,s3,a4
 852:	377d                	addiw	a4,a4,-1
 854:	1702                	slli	a4,a4,0x20
 856:	9301                	srli	a4,a4,0x20
 858:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 85c:	fff94583          	lbu	a1,-1(s2)
 860:	8526                	mv	a0,s1
 862:	00000097          	auipc	ra,0x0
 866:	f58080e7          	jalr	-168(ra) # 7ba <putc>
  while(--i >= 0)
 86a:	197d                	addi	s2,s2,-1
 86c:	ff3918e3          	bne	s2,s3,85c <printint+0x80>
}
 870:	70e2                	ld	ra,56(sp)
 872:	7442                	ld	s0,48(sp)
 874:	74a2                	ld	s1,40(sp)
 876:	7902                	ld	s2,32(sp)
 878:	69e2                	ld	s3,24(sp)
 87a:	6121                	addi	sp,sp,64
 87c:	8082                	ret
    x = -xx;
 87e:	40b005bb          	negw	a1,a1
    neg = 1;
 882:	4885                	li	a7,1
    x = -xx;
 884:	bf8d                	j	7f6 <printint+0x1a>

0000000000000886 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 886:	7119                	addi	sp,sp,-128
 888:	fc86                	sd	ra,120(sp)
 88a:	f8a2                	sd	s0,112(sp)
 88c:	f4a6                	sd	s1,104(sp)
 88e:	f0ca                	sd	s2,96(sp)
 890:	ecce                	sd	s3,88(sp)
 892:	e8d2                	sd	s4,80(sp)
 894:	e4d6                	sd	s5,72(sp)
 896:	e0da                	sd	s6,64(sp)
 898:	fc5e                	sd	s7,56(sp)
 89a:	f862                	sd	s8,48(sp)
 89c:	f466                	sd	s9,40(sp)
 89e:	f06a                	sd	s10,32(sp)
 8a0:	ec6e                	sd	s11,24(sp)
 8a2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8a4:	0005c903          	lbu	s2,0(a1)
 8a8:	18090f63          	beqz	s2,a46 <vprintf+0x1c0>
 8ac:	8aaa                	mv	s5,a0
 8ae:	8b32                	mv	s6,a2
 8b0:	00158493          	addi	s1,a1,1
  state = 0;
 8b4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8b6:	02500a13          	li	s4,37
      if(c == 'd'){
 8ba:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 8be:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 8c2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 8c6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8ca:	00000b97          	auipc	s7,0x0
 8ce:	576b8b93          	addi	s7,s7,1398 # e40 <digits>
 8d2:	a839                	j	8f0 <vprintf+0x6a>
        putc(fd, c);
 8d4:	85ca                	mv	a1,s2
 8d6:	8556                	mv	a0,s5
 8d8:	00000097          	auipc	ra,0x0
 8dc:	ee2080e7          	jalr	-286(ra) # 7ba <putc>
 8e0:	a019                	j	8e6 <vprintf+0x60>
    } else if(state == '%'){
 8e2:	01498f63          	beq	s3,s4,900 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 8e6:	0485                	addi	s1,s1,1
 8e8:	fff4c903          	lbu	s2,-1(s1)
 8ec:	14090d63          	beqz	s2,a46 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 8f0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 8f4:	fe0997e3          	bnez	s3,8e2 <vprintf+0x5c>
      if(c == '%'){
 8f8:	fd479ee3          	bne	a5,s4,8d4 <vprintf+0x4e>
        state = '%';
 8fc:	89be                	mv	s3,a5
 8fe:	b7e5                	j	8e6 <vprintf+0x60>
      if(c == 'd'){
 900:	05878063          	beq	a5,s8,940 <vprintf+0xba>
      } else if(c == 'l') {
 904:	05978c63          	beq	a5,s9,95c <vprintf+0xd6>
      } else if(c == 'x') {
 908:	07a78863          	beq	a5,s10,978 <vprintf+0xf2>
      } else if(c == 'p') {
 90c:	09b78463          	beq	a5,s11,994 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 910:	07300713          	li	a4,115
 914:	0ce78663          	beq	a5,a4,9e0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 918:	06300713          	li	a4,99
 91c:	0ee78e63          	beq	a5,a4,a18 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 920:	11478863          	beq	a5,s4,a30 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 924:	85d2                	mv	a1,s4
 926:	8556                	mv	a0,s5
 928:	00000097          	auipc	ra,0x0
 92c:	e92080e7          	jalr	-366(ra) # 7ba <putc>
        putc(fd, c);
 930:	85ca                	mv	a1,s2
 932:	8556                	mv	a0,s5
 934:	00000097          	auipc	ra,0x0
 938:	e86080e7          	jalr	-378(ra) # 7ba <putc>
      }
      state = 0;
 93c:	4981                	li	s3,0
 93e:	b765                	j	8e6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 940:	008b0913          	addi	s2,s6,8
 944:	4685                	li	a3,1
 946:	4629                	li	a2,10
 948:	000b2583          	lw	a1,0(s6)
 94c:	8556                	mv	a0,s5
 94e:	00000097          	auipc	ra,0x0
 952:	e8e080e7          	jalr	-370(ra) # 7dc <printint>
 956:	8b4a                	mv	s6,s2
      state = 0;
 958:	4981                	li	s3,0
 95a:	b771                	j	8e6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 95c:	008b0913          	addi	s2,s6,8
 960:	4681                	li	a3,0
 962:	4629                	li	a2,10
 964:	000b2583          	lw	a1,0(s6)
 968:	8556                	mv	a0,s5
 96a:	00000097          	auipc	ra,0x0
 96e:	e72080e7          	jalr	-398(ra) # 7dc <printint>
 972:	8b4a                	mv	s6,s2
      state = 0;
 974:	4981                	li	s3,0
 976:	bf85                	j	8e6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 978:	008b0913          	addi	s2,s6,8
 97c:	4681                	li	a3,0
 97e:	4641                	li	a2,16
 980:	000b2583          	lw	a1,0(s6)
 984:	8556                	mv	a0,s5
 986:	00000097          	auipc	ra,0x0
 98a:	e56080e7          	jalr	-426(ra) # 7dc <printint>
 98e:	8b4a                	mv	s6,s2
      state = 0;
 990:	4981                	li	s3,0
 992:	bf91                	j	8e6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 994:	008b0793          	addi	a5,s6,8
 998:	f8f43423          	sd	a5,-120(s0)
 99c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 9a0:	03000593          	li	a1,48
 9a4:	8556                	mv	a0,s5
 9a6:	00000097          	auipc	ra,0x0
 9aa:	e14080e7          	jalr	-492(ra) # 7ba <putc>
  putc(fd, 'x');
 9ae:	85ea                	mv	a1,s10
 9b0:	8556                	mv	a0,s5
 9b2:	00000097          	auipc	ra,0x0
 9b6:	e08080e7          	jalr	-504(ra) # 7ba <putc>
 9ba:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9bc:	03c9d793          	srli	a5,s3,0x3c
 9c0:	97de                	add	a5,a5,s7
 9c2:	0007c583          	lbu	a1,0(a5)
 9c6:	8556                	mv	a0,s5
 9c8:	00000097          	auipc	ra,0x0
 9cc:	df2080e7          	jalr	-526(ra) # 7ba <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9d0:	0992                	slli	s3,s3,0x4
 9d2:	397d                	addiw	s2,s2,-1
 9d4:	fe0914e3          	bnez	s2,9bc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 9d8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 9dc:	4981                	li	s3,0
 9de:	b721                	j	8e6 <vprintf+0x60>
        s = va_arg(ap, char*);
 9e0:	008b0993          	addi	s3,s6,8
 9e4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 9e8:	02090163          	beqz	s2,a0a <vprintf+0x184>
        while(*s != 0){
 9ec:	00094583          	lbu	a1,0(s2)
 9f0:	c9a1                	beqz	a1,a40 <vprintf+0x1ba>
          putc(fd, *s);
 9f2:	8556                	mv	a0,s5
 9f4:	00000097          	auipc	ra,0x0
 9f8:	dc6080e7          	jalr	-570(ra) # 7ba <putc>
          s++;
 9fc:	0905                	addi	s2,s2,1
        while(*s != 0){
 9fe:	00094583          	lbu	a1,0(s2)
 a02:	f9e5                	bnez	a1,9f2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 a04:	8b4e                	mv	s6,s3
      state = 0;
 a06:	4981                	li	s3,0
 a08:	bdf9                	j	8e6 <vprintf+0x60>
          s = "(null)";
 a0a:	00000917          	auipc	s2,0x0
 a0e:	42e90913          	addi	s2,s2,1070 # e38 <malloc+0x2e8>
        while(*s != 0){
 a12:	02800593          	li	a1,40
 a16:	bff1                	j	9f2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a18:	008b0913          	addi	s2,s6,8
 a1c:	000b4583          	lbu	a1,0(s6)
 a20:	8556                	mv	a0,s5
 a22:	00000097          	auipc	ra,0x0
 a26:	d98080e7          	jalr	-616(ra) # 7ba <putc>
 a2a:	8b4a                	mv	s6,s2
      state = 0;
 a2c:	4981                	li	s3,0
 a2e:	bd65                	j	8e6 <vprintf+0x60>
        putc(fd, c);
 a30:	85d2                	mv	a1,s4
 a32:	8556                	mv	a0,s5
 a34:	00000097          	auipc	ra,0x0
 a38:	d86080e7          	jalr	-634(ra) # 7ba <putc>
      state = 0;
 a3c:	4981                	li	s3,0
 a3e:	b565                	j	8e6 <vprintf+0x60>
        s = va_arg(ap, char*);
 a40:	8b4e                	mv	s6,s3
      state = 0;
 a42:	4981                	li	s3,0
 a44:	b54d                	j	8e6 <vprintf+0x60>
    }
  }
}
 a46:	70e6                	ld	ra,120(sp)
 a48:	7446                	ld	s0,112(sp)
 a4a:	74a6                	ld	s1,104(sp)
 a4c:	7906                	ld	s2,96(sp)
 a4e:	69e6                	ld	s3,88(sp)
 a50:	6a46                	ld	s4,80(sp)
 a52:	6aa6                	ld	s5,72(sp)
 a54:	6b06                	ld	s6,64(sp)
 a56:	7be2                	ld	s7,56(sp)
 a58:	7c42                	ld	s8,48(sp)
 a5a:	7ca2                	ld	s9,40(sp)
 a5c:	7d02                	ld	s10,32(sp)
 a5e:	6de2                	ld	s11,24(sp)
 a60:	6109                	addi	sp,sp,128
 a62:	8082                	ret

0000000000000a64 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a64:	715d                	addi	sp,sp,-80
 a66:	ec06                	sd	ra,24(sp)
 a68:	e822                	sd	s0,16(sp)
 a6a:	1000                	addi	s0,sp,32
 a6c:	e010                	sd	a2,0(s0)
 a6e:	e414                	sd	a3,8(s0)
 a70:	e818                	sd	a4,16(s0)
 a72:	ec1c                	sd	a5,24(s0)
 a74:	03043023          	sd	a6,32(s0)
 a78:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a7c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a80:	8622                	mv	a2,s0
 a82:	00000097          	auipc	ra,0x0
 a86:	e04080e7          	jalr	-508(ra) # 886 <vprintf>
}
 a8a:	60e2                	ld	ra,24(sp)
 a8c:	6442                	ld	s0,16(sp)
 a8e:	6161                	addi	sp,sp,80
 a90:	8082                	ret

0000000000000a92 <printf>:

void
printf(const char *fmt, ...)
{
 a92:	711d                	addi	sp,sp,-96
 a94:	ec06                	sd	ra,24(sp)
 a96:	e822                	sd	s0,16(sp)
 a98:	1000                	addi	s0,sp,32
 a9a:	e40c                	sd	a1,8(s0)
 a9c:	e810                	sd	a2,16(s0)
 a9e:	ec14                	sd	a3,24(s0)
 aa0:	f018                	sd	a4,32(s0)
 aa2:	f41c                	sd	a5,40(s0)
 aa4:	03043823          	sd	a6,48(s0)
 aa8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 aac:	00840613          	addi	a2,s0,8
 ab0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ab4:	85aa                	mv	a1,a0
 ab6:	4505                	li	a0,1
 ab8:	00000097          	auipc	ra,0x0
 abc:	dce080e7          	jalr	-562(ra) # 886 <vprintf>
}
 ac0:	60e2                	ld	ra,24(sp)
 ac2:	6442                	ld	s0,16(sp)
 ac4:	6125                	addi	sp,sp,96
 ac6:	8082                	ret

0000000000000ac8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ac8:	1141                	addi	sp,sp,-16
 aca:	e422                	sd	s0,8(sp)
 acc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ace:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ad2:	00000797          	auipc	a5,0x0
 ad6:	5367b783          	ld	a5,1334(a5) # 1008 <freep>
 ada:	a805                	j	b0a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 adc:	4618                	lw	a4,8(a2)
 ade:	9db9                	addw	a1,a1,a4
 ae0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ae4:	6398                	ld	a4,0(a5)
 ae6:	6318                	ld	a4,0(a4)
 ae8:	fee53823          	sd	a4,-16(a0)
 aec:	a091                	j	b30 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 aee:	ff852703          	lw	a4,-8(a0)
 af2:	9e39                	addw	a2,a2,a4
 af4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 af6:	ff053703          	ld	a4,-16(a0)
 afa:	e398                	sd	a4,0(a5)
 afc:	a099                	j	b42 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 afe:	6398                	ld	a4,0(a5)
 b00:	00e7e463          	bltu	a5,a4,b08 <free+0x40>
 b04:	00e6ea63          	bltu	a3,a4,b18 <free+0x50>
{
 b08:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b0a:	fed7fae3          	bgeu	a5,a3,afe <free+0x36>
 b0e:	6398                	ld	a4,0(a5)
 b10:	00e6e463          	bltu	a3,a4,b18 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b14:	fee7eae3          	bltu	a5,a4,b08 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b18:	ff852583          	lw	a1,-8(a0)
 b1c:	6390                	ld	a2,0(a5)
 b1e:	02059713          	slli	a4,a1,0x20
 b22:	9301                	srli	a4,a4,0x20
 b24:	0712                	slli	a4,a4,0x4
 b26:	9736                	add	a4,a4,a3
 b28:	fae60ae3          	beq	a2,a4,adc <free+0x14>
    bp->s.ptr = p->s.ptr;
 b2c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b30:	4790                	lw	a2,8(a5)
 b32:	02061713          	slli	a4,a2,0x20
 b36:	9301                	srli	a4,a4,0x20
 b38:	0712                	slli	a4,a4,0x4
 b3a:	973e                	add	a4,a4,a5
 b3c:	fae689e3          	beq	a3,a4,aee <free+0x26>
  } else
    p->s.ptr = bp;
 b40:	e394                	sd	a3,0(a5)
  freep = p;
 b42:	00000717          	auipc	a4,0x0
 b46:	4cf73323          	sd	a5,1222(a4) # 1008 <freep>
}
 b4a:	6422                	ld	s0,8(sp)
 b4c:	0141                	addi	sp,sp,16
 b4e:	8082                	ret

0000000000000b50 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b50:	7139                	addi	sp,sp,-64
 b52:	fc06                	sd	ra,56(sp)
 b54:	f822                	sd	s0,48(sp)
 b56:	f426                	sd	s1,40(sp)
 b58:	f04a                	sd	s2,32(sp)
 b5a:	ec4e                	sd	s3,24(sp)
 b5c:	e852                	sd	s4,16(sp)
 b5e:	e456                	sd	s5,8(sp)
 b60:	e05a                	sd	s6,0(sp)
 b62:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b64:	02051493          	slli	s1,a0,0x20
 b68:	9081                	srli	s1,s1,0x20
 b6a:	04bd                	addi	s1,s1,15
 b6c:	8091                	srli	s1,s1,0x4
 b6e:	0014899b          	addiw	s3,s1,1
 b72:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b74:	00000517          	auipc	a0,0x0
 b78:	49453503          	ld	a0,1172(a0) # 1008 <freep>
 b7c:	c515                	beqz	a0,ba8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b7e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b80:	4798                	lw	a4,8(a5)
 b82:	02977f63          	bgeu	a4,s1,bc0 <malloc+0x70>
 b86:	8a4e                	mv	s4,s3
 b88:	0009871b          	sext.w	a4,s3
 b8c:	6685                	lui	a3,0x1
 b8e:	00d77363          	bgeu	a4,a3,b94 <malloc+0x44>
 b92:	6a05                	lui	s4,0x1
 b94:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b98:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b9c:	00000917          	auipc	s2,0x0
 ba0:	46c90913          	addi	s2,s2,1132 # 1008 <freep>
  if(p == (char*)-1)
 ba4:	5afd                	li	s5,-1
 ba6:	a88d                	j	c18 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 ba8:	00000797          	auipc	a5,0x0
 bac:	46878793          	addi	a5,a5,1128 # 1010 <base>
 bb0:	00000717          	auipc	a4,0x0
 bb4:	44f73c23          	sd	a5,1112(a4) # 1008 <freep>
 bb8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bba:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bbe:	b7e1                	j	b86 <malloc+0x36>
      if(p->s.size == nunits)
 bc0:	02e48b63          	beq	s1,a4,bf6 <malloc+0xa6>
        p->s.size -= nunits;
 bc4:	4137073b          	subw	a4,a4,s3
 bc8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bca:	1702                	slli	a4,a4,0x20
 bcc:	9301                	srli	a4,a4,0x20
 bce:	0712                	slli	a4,a4,0x4
 bd0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bd2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bd6:	00000717          	auipc	a4,0x0
 bda:	42a73923          	sd	a0,1074(a4) # 1008 <freep>
      return (void*)(p + 1);
 bde:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 be2:	70e2                	ld	ra,56(sp)
 be4:	7442                	ld	s0,48(sp)
 be6:	74a2                	ld	s1,40(sp)
 be8:	7902                	ld	s2,32(sp)
 bea:	69e2                	ld	s3,24(sp)
 bec:	6a42                	ld	s4,16(sp)
 bee:	6aa2                	ld	s5,8(sp)
 bf0:	6b02                	ld	s6,0(sp)
 bf2:	6121                	addi	sp,sp,64
 bf4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 bf6:	6398                	ld	a4,0(a5)
 bf8:	e118                	sd	a4,0(a0)
 bfa:	bff1                	j	bd6 <malloc+0x86>
  hp->s.size = nu;
 bfc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c00:	0541                	addi	a0,a0,16
 c02:	00000097          	auipc	ra,0x0
 c06:	ec6080e7          	jalr	-314(ra) # ac8 <free>
  return freep;
 c0a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c0e:	d971                	beqz	a0,be2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c10:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c12:	4798                	lw	a4,8(a5)
 c14:	fa9776e3          	bgeu	a4,s1,bc0 <malloc+0x70>
    if(p == freep)
 c18:	00093703          	ld	a4,0(s2)
 c1c:	853e                	mv	a0,a5
 c1e:	fef719e3          	bne	a4,a5,c10 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 c22:	8552                	mv	a0,s4
 c24:	00000097          	auipc	ra,0x0
 c28:	b56080e7          	jalr	-1194(ra) # 77a <sbrk>
  if(p == (char*)-1)
 c2c:	fd5518e3          	bne	a0,s5,bfc <malloc+0xac>
        return 0;
 c30:	4501                	li	a0,0
 c32:	bf45                	j	be2 <malloc+0x92>
