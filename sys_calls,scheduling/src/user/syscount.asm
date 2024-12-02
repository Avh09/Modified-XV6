
user/_syscount:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find_highest_set_bit>:
//     exit(1);
//   }

//   exit(0);
// }
int find_highest_set_bit(int num) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  int position = 0;
  
  while (num > 1) {
   6:	4705                	li	a4,1
   8:	00a75c63          	bge	a4,a0,20 <find_highest_set_bit+0x20>
   c:	87aa                	mv	a5,a0
  int position = 0;
   e:	4501                	li	a0,0
    num >>= 1;  // Shift right by 1 bit
  10:	4017d79b          	sraiw	a5,a5,0x1
    position++;
  14:	2505                	addiw	a0,a0,1
  while (num > 1) {
  16:	fef74de3          	blt	a4,a5,10 <find_highest_set_bit+0x10>
  }
  
  return position;
}
  1a:	6422                	ld	s0,8(sp)
  1c:	0141                	addi	sp,sp,16
  1e:	8082                	ret
  int position = 0;
  20:	4501                	li	a0,0
  22:	bfe5                	j	1a <find_highest_set_bit+0x1a>

0000000000000024 <main>:

int main(int argc, char *argv[]) {
  24:	1101                	addi	sp,sp,-32
  26:	ec06                	sd	ra,24(sp)
  28:	e822                	sd	s0,16(sp)
  2a:	e426                	sd	s1,8(sp)
  2c:	1000                	addi	s0,sp,32
  2e:	84ae                	mv	s1,a1
  int count;
  if (argc < 3) {
  30:	4789                	li	a5,2
  32:	02a7c063          	blt	a5,a0,52 <main+0x2e>
    printf("Usage: %s <pid> <syscall_number>\n", argv[0]);
  36:	618c                	ld	a1,0(a1)
  38:	00001517          	auipc	a0,0x1
  3c:	8d850513          	addi	a0,a0,-1832 # 910 <malloc+0xe8>
  40:	00000097          	auipc	ra,0x0
  44:	72a080e7          	jalr	1834(ra) # 76a <printf>
    exit(1);
  48:	4505                	li	a0,1
  4a:	00000097          	auipc	ra,0x0
  4e:	380080e7          	jalr	896(ra) # 3ca <exit>
  }

  int num = atoi(argv[1]);  // Convert the syscall number argument to an integer
  52:	6588                	ld	a0,8(a1)
  54:	00000097          	auipc	ra,0x0
  58:	27a080e7          	jalr	634(ra) # 2ce <atoi>
  // printf("num: %d\n", num);
  sysnum = find_highest_set_bit(num);
  5c:	00000097          	auipc	ra,0x0
  60:	fa4080e7          	jalr	-92(ra) # 0 <find_highest_set_bit>
  64:	00001797          	auipc	a5,0x1
  68:	f8a7ae23          	sw	a0,-100(a5) # 1000 <sysnum>
  // printf("sysNum: %d\n", sysnum);

  // printf("arg[2]: %s\n", argv[2]);
  int pid = fork();
  6c:	00000097          	auipc	ra,0x0
  70:	356080e7          	jalr	854(ra) # 3c2 <fork>
  if (pid == 0) {
  74:	c535                	beqz	a0,e0 <main+0xbc>
    exec(argv[2], &argv[2]);
    fprintf(2, "exec %s failed\n", argv[2]);
    exit(1);
  } else if (pid > 0) {
  76:	08a05b63          	blez	a0,10c <main+0xe8>
    wait(0);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	356080e7          	jalr	854(ra) # 3d2 <wait>
    // printf("sysnum in syscount: %d\n", sysnum);
    // myproc()->yo = sysnum;
    count = getSysCount(sysnum);
  84:	00001517          	auipc	a0,0x1
  88:	f7c52503          	lw	a0,-132(a0) # 1000 <sysnum>
  8c:	00000097          	auipc	ra,0x0
  90:	3e6080e7          	jalr	998(ra) # 472 <getSysCount>
  94:	84aa                	mv	s1,a0
  } else {
    fprintf(2, "fork failed\n");
    exit(1);
  }

  if (count >= 0 && sysnum > 0 && sysnum < 26) {
  96:	08054963          	bltz	a0,128 <main+0x104>
  9a:	00001797          	auipc	a5,0x1
  9e:	f667a783          	lw	a5,-154(a5) # 1000 <sysnum>
  a2:	37fd                	addiw	a5,a5,-1
  a4:	4761                	li	a4,24
  a6:	08f76163          	bltu	a4,a5,128 <main+0x104>
    printf("PID %d called %s %d times.\n", getpid(), syscall_names[sysnum], count);
  aa:	00000097          	auipc	ra,0x0
  ae:	3a0080e7          	jalr	928(ra) # 44a <getpid>
  b2:	85aa                	mv	a1,a0
  b4:	00001797          	auipc	a5,0x1
  b8:	f4c7a783          	lw	a5,-180(a5) # 1000 <sysnum>
  bc:	00379713          	slli	a4,a5,0x3
  c0:	00001797          	auipc	a5,0x1
  c4:	9b878793          	addi	a5,a5,-1608 # a78 <syscall_names>
  c8:	97ba                	add	a5,a5,a4
  ca:	86a6                	mv	a3,s1
  cc:	6390                	ld	a2,0(a5)
  ce:	00001517          	auipc	a0,0x1
  d2:	88a50513          	addi	a0,a0,-1910 # 958 <malloc+0x130>
  d6:	00000097          	auipc	ra,0x0
  da:	694080e7          	jalr	1684(ra) # 76a <printf>
  de:	a8a9                	j	138 <main+0x114>
    exec(argv[2], &argv[2]);
  e0:	01048593          	addi	a1,s1,16
  e4:	6888                	ld	a0,16(s1)
  e6:	00000097          	auipc	ra,0x0
  ea:	31c080e7          	jalr	796(ra) # 402 <exec>
    fprintf(2, "exec %s failed\n", argv[2]);
  ee:	6890                	ld	a2,16(s1)
  f0:	00001597          	auipc	a1,0x1
  f4:	84858593          	addi	a1,a1,-1976 # 938 <malloc+0x110>
  f8:	4509                	li	a0,2
  fa:	00000097          	auipc	ra,0x0
  fe:	642080e7          	jalr	1602(ra) # 73c <fprintf>
    exit(1);
 102:	4505                	li	a0,1
 104:	00000097          	auipc	ra,0x0
 108:	2c6080e7          	jalr	710(ra) # 3ca <exit>
    fprintf(2, "fork failed\n");
 10c:	00001597          	auipc	a1,0x1
 110:	83c58593          	addi	a1,a1,-1988 # 948 <malloc+0x120>
 114:	4509                	li	a0,2
 116:	00000097          	auipc	ra,0x0
 11a:	626080e7          	jalr	1574(ra) # 73c <fprintf>
    exit(1);
 11e:	4505                	li	a0,1
 120:	00000097          	auipc	ra,0x0
 124:	2aa080e7          	jalr	682(ra) # 3ca <exit>
  } else {
    printf("Invalid system call number.\n");
 128:	00001517          	auipc	a0,0x1
 12c:	85050513          	addi	a0,a0,-1968 # 978 <malloc+0x150>
 130:	00000097          	auipc	ra,0x0
 134:	63a080e7          	jalr	1594(ra) # 76a <printf>
  }

  exit(0);
 138:	4501                	li	a0,0
 13a:	00000097          	auipc	ra,0x0
 13e:	290080e7          	jalr	656(ra) # 3ca <exit>

0000000000000142 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 142:	1141                	addi	sp,sp,-16
 144:	e406                	sd	ra,8(sp)
 146:	e022                	sd	s0,0(sp)
 148:	0800                	addi	s0,sp,16
  extern int main();
  main();
 14a:	00000097          	auipc	ra,0x0
 14e:	eda080e7          	jalr	-294(ra) # 24 <main>
  exit(0);
 152:	4501                	li	a0,0
 154:	00000097          	auipc	ra,0x0
 158:	276080e7          	jalr	630(ra) # 3ca <exit>

000000000000015c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e422                	sd	s0,8(sp)
 160:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 162:	87aa                	mv	a5,a0
 164:	0585                	addi	a1,a1,1
 166:	0785                	addi	a5,a5,1
 168:	fff5c703          	lbu	a4,-1(a1)
 16c:	fee78fa3          	sb	a4,-1(a5)
 170:	fb75                	bnez	a4,164 <strcpy+0x8>
    ;
  return os;
}
 172:	6422                	ld	s0,8(sp)
 174:	0141                	addi	sp,sp,16
 176:	8082                	ret

0000000000000178 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 178:	1141                	addi	sp,sp,-16
 17a:	e422                	sd	s0,8(sp)
 17c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 17e:	00054783          	lbu	a5,0(a0)
 182:	cb91                	beqz	a5,196 <strcmp+0x1e>
 184:	0005c703          	lbu	a4,0(a1)
 188:	00f71763          	bne	a4,a5,196 <strcmp+0x1e>
    p++, q++;
 18c:	0505                	addi	a0,a0,1
 18e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 190:	00054783          	lbu	a5,0(a0)
 194:	fbe5                	bnez	a5,184 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 196:	0005c503          	lbu	a0,0(a1)
}
 19a:	40a7853b          	subw	a0,a5,a0
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strlen>:

uint
strlen(const char *s)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	cf91                	beqz	a5,1ca <strlen+0x26>
 1b0:	0505                	addi	a0,a0,1
 1b2:	87aa                	mv	a5,a0
 1b4:	4685                	li	a3,1
 1b6:	9e89                	subw	a3,a3,a0
 1b8:	00f6853b          	addw	a0,a3,a5
 1bc:	0785                	addi	a5,a5,1
 1be:	fff7c703          	lbu	a4,-1(a5)
 1c2:	fb7d                	bnez	a4,1b8 <strlen+0x14>
    ;
  return n;
}
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret
  for(n = 0; s[n]; n++)
 1ca:	4501                	li	a0,0
 1cc:	bfe5                	j	1c4 <strlen+0x20>

00000000000001ce <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ce:	1141                	addi	sp,sp,-16
 1d0:	e422                	sd	s0,8(sp)
 1d2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1d4:	ca19                	beqz	a2,1ea <memset+0x1c>
 1d6:	87aa                	mv	a5,a0
 1d8:	1602                	slli	a2,a2,0x20
 1da:	9201                	srli	a2,a2,0x20
 1dc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1e0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1e4:	0785                	addi	a5,a5,1
 1e6:	fee79de3          	bne	a5,a4,1e0 <memset+0x12>
  }
  return dst;
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret

00000000000001f0 <strchr>:

char*
strchr(const char *s, char c)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1f6:	00054783          	lbu	a5,0(a0)
 1fa:	cb99                	beqz	a5,210 <strchr+0x20>
    if(*s == c)
 1fc:	00f58763          	beq	a1,a5,20a <strchr+0x1a>
  for(; *s; s++)
 200:	0505                	addi	a0,a0,1
 202:	00054783          	lbu	a5,0(a0)
 206:	fbfd                	bnez	a5,1fc <strchr+0xc>
      return (char*)s;
  return 0;
 208:	4501                	li	a0,0
}
 20a:	6422                	ld	s0,8(sp)
 20c:	0141                	addi	sp,sp,16
 20e:	8082                	ret
  return 0;
 210:	4501                	li	a0,0
 212:	bfe5                	j	20a <strchr+0x1a>

0000000000000214 <gets>:

char*
gets(char *buf, int max)
{
 214:	711d                	addi	sp,sp,-96
 216:	ec86                	sd	ra,88(sp)
 218:	e8a2                	sd	s0,80(sp)
 21a:	e4a6                	sd	s1,72(sp)
 21c:	e0ca                	sd	s2,64(sp)
 21e:	fc4e                	sd	s3,56(sp)
 220:	f852                	sd	s4,48(sp)
 222:	f456                	sd	s5,40(sp)
 224:	f05a                	sd	s6,32(sp)
 226:	ec5e                	sd	s7,24(sp)
 228:	1080                	addi	s0,sp,96
 22a:	8baa                	mv	s7,a0
 22c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 22e:	892a                	mv	s2,a0
 230:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 232:	4aa9                	li	s5,10
 234:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 236:	89a6                	mv	s3,s1
 238:	2485                	addiw	s1,s1,1
 23a:	0344d863          	bge	s1,s4,26a <gets+0x56>
    cc = read(0, &c, 1);
 23e:	4605                	li	a2,1
 240:	faf40593          	addi	a1,s0,-81
 244:	4501                	li	a0,0
 246:	00000097          	auipc	ra,0x0
 24a:	19c080e7          	jalr	412(ra) # 3e2 <read>
    if(cc < 1)
 24e:	00a05e63          	blez	a0,26a <gets+0x56>
    buf[i++] = c;
 252:	faf44783          	lbu	a5,-81(s0)
 256:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 25a:	01578763          	beq	a5,s5,268 <gets+0x54>
 25e:	0905                	addi	s2,s2,1
 260:	fd679be3          	bne	a5,s6,236 <gets+0x22>
  for(i=0; i+1 < max; ){
 264:	89a6                	mv	s3,s1
 266:	a011                	j	26a <gets+0x56>
 268:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 26a:	99de                	add	s3,s3,s7
 26c:	00098023          	sb	zero,0(s3)
  return buf;
}
 270:	855e                	mv	a0,s7
 272:	60e6                	ld	ra,88(sp)
 274:	6446                	ld	s0,80(sp)
 276:	64a6                	ld	s1,72(sp)
 278:	6906                	ld	s2,64(sp)
 27a:	79e2                	ld	s3,56(sp)
 27c:	7a42                	ld	s4,48(sp)
 27e:	7aa2                	ld	s5,40(sp)
 280:	7b02                	ld	s6,32(sp)
 282:	6be2                	ld	s7,24(sp)
 284:	6125                	addi	sp,sp,96
 286:	8082                	ret

0000000000000288 <stat>:

int
stat(const char *n, struct stat *st)
{
 288:	1101                	addi	sp,sp,-32
 28a:	ec06                	sd	ra,24(sp)
 28c:	e822                	sd	s0,16(sp)
 28e:	e426                	sd	s1,8(sp)
 290:	e04a                	sd	s2,0(sp)
 292:	1000                	addi	s0,sp,32
 294:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 296:	4581                	li	a1,0
 298:	00000097          	auipc	ra,0x0
 29c:	172080e7          	jalr	370(ra) # 40a <open>
  if(fd < 0)
 2a0:	02054563          	bltz	a0,2ca <stat+0x42>
 2a4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a6:	85ca                	mv	a1,s2
 2a8:	00000097          	auipc	ra,0x0
 2ac:	17a080e7          	jalr	378(ra) # 422 <fstat>
 2b0:	892a                	mv	s2,a0
  close(fd);
 2b2:	8526                	mv	a0,s1
 2b4:	00000097          	auipc	ra,0x0
 2b8:	13e080e7          	jalr	318(ra) # 3f2 <close>
  return r;
}
 2bc:	854a                	mv	a0,s2
 2be:	60e2                	ld	ra,24(sp)
 2c0:	6442                	ld	s0,16(sp)
 2c2:	64a2                	ld	s1,8(sp)
 2c4:	6902                	ld	s2,0(sp)
 2c6:	6105                	addi	sp,sp,32
 2c8:	8082                	ret
    return -1;
 2ca:	597d                	li	s2,-1
 2cc:	bfc5                	j	2bc <stat+0x34>

00000000000002ce <atoi>:

int
atoi(const char *s)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2d4:	00054603          	lbu	a2,0(a0)
 2d8:	fd06079b          	addiw	a5,a2,-48
 2dc:	0ff7f793          	andi	a5,a5,255
 2e0:	4725                	li	a4,9
 2e2:	02f76963          	bltu	a4,a5,314 <atoi+0x46>
 2e6:	86aa                	mv	a3,a0
  n = 0;
 2e8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2ea:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2ec:	0685                	addi	a3,a3,1
 2ee:	0025179b          	slliw	a5,a0,0x2
 2f2:	9fa9                	addw	a5,a5,a0
 2f4:	0017979b          	slliw	a5,a5,0x1
 2f8:	9fb1                	addw	a5,a5,a2
 2fa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2fe:	0006c603          	lbu	a2,0(a3)
 302:	fd06071b          	addiw	a4,a2,-48
 306:	0ff77713          	andi	a4,a4,255
 30a:	fee5f1e3          	bgeu	a1,a4,2ec <atoi+0x1e>
  return n;
}
 30e:	6422                	ld	s0,8(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret
  n = 0;
 314:	4501                	li	a0,0
 316:	bfe5                	j	30e <atoi+0x40>

0000000000000318 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 318:	1141                	addi	sp,sp,-16
 31a:	e422                	sd	s0,8(sp)
 31c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 31e:	02b57463          	bgeu	a0,a1,346 <memmove+0x2e>
    while(n-- > 0)
 322:	00c05f63          	blez	a2,340 <memmove+0x28>
 326:	1602                	slli	a2,a2,0x20
 328:	9201                	srli	a2,a2,0x20
 32a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 32e:	872a                	mv	a4,a0
      *dst++ = *src++;
 330:	0585                	addi	a1,a1,1
 332:	0705                	addi	a4,a4,1
 334:	fff5c683          	lbu	a3,-1(a1)
 338:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33c:	fee79ae3          	bne	a5,a4,330 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
    dst += n;
 346:	00c50733          	add	a4,a0,a2
    src += n;
 34a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34c:	fec05ae3          	blez	a2,340 <memmove+0x28>
 350:	fff6079b          	addiw	a5,a2,-1
 354:	1782                	slli	a5,a5,0x20
 356:	9381                	srli	a5,a5,0x20
 358:	fff7c793          	not	a5,a5
 35c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35e:	15fd                	addi	a1,a1,-1
 360:	177d                	addi	a4,a4,-1
 362:	0005c683          	lbu	a3,0(a1)
 366:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 36a:	fee79ae3          	bne	a5,a4,35e <memmove+0x46>
 36e:	bfc9                	j	340 <memmove+0x28>

0000000000000370 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 370:	1141                	addi	sp,sp,-16
 372:	e422                	sd	s0,8(sp)
 374:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 376:	ca05                	beqz	a2,3a6 <memcmp+0x36>
 378:	fff6069b          	addiw	a3,a2,-1
 37c:	1682                	slli	a3,a3,0x20
 37e:	9281                	srli	a3,a3,0x20
 380:	0685                	addi	a3,a3,1
 382:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 384:	00054783          	lbu	a5,0(a0)
 388:	0005c703          	lbu	a4,0(a1)
 38c:	00e79863          	bne	a5,a4,39c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 390:	0505                	addi	a0,a0,1
    p2++;
 392:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 394:	fed518e3          	bne	a0,a3,384 <memcmp+0x14>
  }
  return 0;
 398:	4501                	li	a0,0
 39a:	a019                	j	3a0 <memcmp+0x30>
      return *p1 - *p2;
 39c:	40e7853b          	subw	a0,a5,a4
}
 3a0:	6422                	ld	s0,8(sp)
 3a2:	0141                	addi	sp,sp,16
 3a4:	8082                	ret
  return 0;
 3a6:	4501                	li	a0,0
 3a8:	bfe5                	j	3a0 <memcmp+0x30>

00000000000003aa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3aa:	1141                	addi	sp,sp,-16
 3ac:	e406                	sd	ra,8(sp)
 3ae:	e022                	sd	s0,0(sp)
 3b0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b2:	00000097          	auipc	ra,0x0
 3b6:	f66080e7          	jalr	-154(ra) # 318 <memmove>
}
 3ba:	60a2                	ld	ra,8(sp)
 3bc:	6402                	ld	s0,0(sp)
 3be:	0141                	addi	sp,sp,16
 3c0:	8082                	ret

00000000000003c2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c2:	4885                	li	a7,1
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ca:	4889                	li	a7,2
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d2:	488d                	li	a7,3
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3da:	4891                	li	a7,4
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <read>:
.global read
read:
 li a7, SYS_read
 3e2:	4895                	li	a7,5
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <write>:
.global write
write:
 li a7, SYS_write
 3ea:	48c1                	li	a7,16
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <close>:
.global close
close:
 li a7, SYS_close
 3f2:	48d5                	li	a7,21
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <kill>:
.global kill
kill:
 li a7, SYS_kill
 3fa:	4899                	li	a7,6
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <exec>:
.global exec
exec:
 li a7, SYS_exec
 402:	489d                	li	a7,7
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <open>:
.global open
open:
 li a7, SYS_open
 40a:	48bd                	li	a7,15
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 412:	48c5                	li	a7,17
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 41a:	48c9                	li	a7,18
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 422:	48a1                	li	a7,8
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <link>:
.global link
link:
 li a7, SYS_link
 42a:	48cd                	li	a7,19
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 432:	48d1                	li	a7,20
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 43a:	48a5                	li	a7,9
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <dup>:
.global dup
dup:
 li a7, SYS_dup
 442:	48a9                	li	a7,10
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 44a:	48ad                	li	a7,11
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 452:	48b1                	li	a7,12
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 45a:	48b5                	li	a7,13
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 462:	48b9                	li	a7,14
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 46a:	48d9                	li	a7,22
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <getSysCount>:
.global getSysCount
getSysCount:
 li a7, SYS_getSysCount
 472:	48dd                	li	a7,23
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 47a:	48e1                	li	a7,24
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 482:	48e5                	li	a7,25
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 48a:	48e9                	li	a7,26
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 492:	1101                	addi	sp,sp,-32
 494:	ec06                	sd	ra,24(sp)
 496:	e822                	sd	s0,16(sp)
 498:	1000                	addi	s0,sp,32
 49a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 49e:	4605                	li	a2,1
 4a0:	fef40593          	addi	a1,s0,-17
 4a4:	00000097          	auipc	ra,0x0
 4a8:	f46080e7          	jalr	-186(ra) # 3ea <write>
}
 4ac:	60e2                	ld	ra,24(sp)
 4ae:	6442                	ld	s0,16(sp)
 4b0:	6105                	addi	sp,sp,32
 4b2:	8082                	ret

00000000000004b4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b4:	7139                	addi	sp,sp,-64
 4b6:	fc06                	sd	ra,56(sp)
 4b8:	f822                	sd	s0,48(sp)
 4ba:	f426                	sd	s1,40(sp)
 4bc:	f04a                	sd	s2,32(sp)
 4be:	ec4e                	sd	s3,24(sp)
 4c0:	0080                	addi	s0,sp,64
 4c2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c4:	c299                	beqz	a3,4ca <printint+0x16>
 4c6:	0805c863          	bltz	a1,556 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ca:	2581                	sext.w	a1,a1
  neg = 0;
 4cc:	4881                	li	a7,0
 4ce:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d4:	2601                	sext.w	a2,a2
 4d6:	00000517          	auipc	a0,0x0
 4da:	67a50513          	addi	a0,a0,1658 # b50 <digits>
 4de:	883a                	mv	a6,a4
 4e0:	2705                	addiw	a4,a4,1
 4e2:	02c5f7bb          	remuw	a5,a1,a2
 4e6:	1782                	slli	a5,a5,0x20
 4e8:	9381                	srli	a5,a5,0x20
 4ea:	97aa                	add	a5,a5,a0
 4ec:	0007c783          	lbu	a5,0(a5)
 4f0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f4:	0005879b          	sext.w	a5,a1
 4f8:	02c5d5bb          	divuw	a1,a1,a2
 4fc:	0685                	addi	a3,a3,1
 4fe:	fec7f0e3          	bgeu	a5,a2,4de <printint+0x2a>
  if(neg)
 502:	00088b63          	beqz	a7,518 <printint+0x64>
    buf[i++] = '-';
 506:	fd040793          	addi	a5,s0,-48
 50a:	973e                	add	a4,a4,a5
 50c:	02d00793          	li	a5,45
 510:	fef70823          	sb	a5,-16(a4)
 514:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 518:	02e05863          	blez	a4,548 <printint+0x94>
 51c:	fc040793          	addi	a5,s0,-64
 520:	00e78933          	add	s2,a5,a4
 524:	fff78993          	addi	s3,a5,-1
 528:	99ba                	add	s3,s3,a4
 52a:	377d                	addiw	a4,a4,-1
 52c:	1702                	slli	a4,a4,0x20
 52e:	9301                	srli	a4,a4,0x20
 530:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 534:	fff94583          	lbu	a1,-1(s2)
 538:	8526                	mv	a0,s1
 53a:	00000097          	auipc	ra,0x0
 53e:	f58080e7          	jalr	-168(ra) # 492 <putc>
  while(--i >= 0)
 542:	197d                	addi	s2,s2,-1
 544:	ff3918e3          	bne	s2,s3,534 <printint+0x80>
}
 548:	70e2                	ld	ra,56(sp)
 54a:	7442                	ld	s0,48(sp)
 54c:	74a2                	ld	s1,40(sp)
 54e:	7902                	ld	s2,32(sp)
 550:	69e2                	ld	s3,24(sp)
 552:	6121                	addi	sp,sp,64
 554:	8082                	ret
    x = -xx;
 556:	40b005bb          	negw	a1,a1
    neg = 1;
 55a:	4885                	li	a7,1
    x = -xx;
 55c:	bf8d                	j	4ce <printint+0x1a>

000000000000055e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 55e:	7119                	addi	sp,sp,-128
 560:	fc86                	sd	ra,120(sp)
 562:	f8a2                	sd	s0,112(sp)
 564:	f4a6                	sd	s1,104(sp)
 566:	f0ca                	sd	s2,96(sp)
 568:	ecce                	sd	s3,88(sp)
 56a:	e8d2                	sd	s4,80(sp)
 56c:	e4d6                	sd	s5,72(sp)
 56e:	e0da                	sd	s6,64(sp)
 570:	fc5e                	sd	s7,56(sp)
 572:	f862                	sd	s8,48(sp)
 574:	f466                	sd	s9,40(sp)
 576:	f06a                	sd	s10,32(sp)
 578:	ec6e                	sd	s11,24(sp)
 57a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 57c:	0005c903          	lbu	s2,0(a1)
 580:	18090f63          	beqz	s2,71e <vprintf+0x1c0>
 584:	8aaa                	mv	s5,a0
 586:	8b32                	mv	s6,a2
 588:	00158493          	addi	s1,a1,1
  state = 0;
 58c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 58e:	02500a13          	li	s4,37
      if(c == 'd'){
 592:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 596:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 59a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 59e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a2:	00000b97          	auipc	s7,0x0
 5a6:	5aeb8b93          	addi	s7,s7,1454 # b50 <digits>
 5aa:	a839                	j	5c8 <vprintf+0x6a>
        putc(fd, c);
 5ac:	85ca                	mv	a1,s2
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	ee2080e7          	jalr	-286(ra) # 492 <putc>
 5b8:	a019                	j	5be <vprintf+0x60>
    } else if(state == '%'){
 5ba:	01498f63          	beq	s3,s4,5d8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5be:	0485                	addi	s1,s1,1
 5c0:	fff4c903          	lbu	s2,-1(s1)
 5c4:	14090d63          	beqz	s2,71e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5c8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5cc:	fe0997e3          	bnez	s3,5ba <vprintf+0x5c>
      if(c == '%'){
 5d0:	fd479ee3          	bne	a5,s4,5ac <vprintf+0x4e>
        state = '%';
 5d4:	89be                	mv	s3,a5
 5d6:	b7e5                	j	5be <vprintf+0x60>
      if(c == 'd'){
 5d8:	05878063          	beq	a5,s8,618 <vprintf+0xba>
      } else if(c == 'l') {
 5dc:	05978c63          	beq	a5,s9,634 <vprintf+0xd6>
      } else if(c == 'x') {
 5e0:	07a78863          	beq	a5,s10,650 <vprintf+0xf2>
      } else if(c == 'p') {
 5e4:	09b78463          	beq	a5,s11,66c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5e8:	07300713          	li	a4,115
 5ec:	0ce78663          	beq	a5,a4,6b8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5f0:	06300713          	li	a4,99
 5f4:	0ee78e63          	beq	a5,a4,6f0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5f8:	11478863          	beq	a5,s4,708 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5fc:	85d2                	mv	a1,s4
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	e92080e7          	jalr	-366(ra) # 492 <putc>
        putc(fd, c);
 608:	85ca                	mv	a1,s2
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e86080e7          	jalr	-378(ra) # 492 <putc>
      }
      state = 0;
 614:	4981                	li	s3,0
 616:	b765                	j	5be <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 618:	008b0913          	addi	s2,s6,8
 61c:	4685                	li	a3,1
 61e:	4629                	li	a2,10
 620:	000b2583          	lw	a1,0(s6)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	e8e080e7          	jalr	-370(ra) # 4b4 <printint>
 62e:	8b4a                	mv	s6,s2
      state = 0;
 630:	4981                	li	s3,0
 632:	b771                	j	5be <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 634:	008b0913          	addi	s2,s6,8
 638:	4681                	li	a3,0
 63a:	4629                	li	a2,10
 63c:	000b2583          	lw	a1,0(s6)
 640:	8556                	mv	a0,s5
 642:	00000097          	auipc	ra,0x0
 646:	e72080e7          	jalr	-398(ra) # 4b4 <printint>
 64a:	8b4a                	mv	s6,s2
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bf85                	j	5be <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 650:	008b0913          	addi	s2,s6,8
 654:	4681                	li	a3,0
 656:	4641                	li	a2,16
 658:	000b2583          	lw	a1,0(s6)
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	e56080e7          	jalr	-426(ra) # 4b4 <printint>
 666:	8b4a                	mv	s6,s2
      state = 0;
 668:	4981                	li	s3,0
 66a:	bf91                	j	5be <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 66c:	008b0793          	addi	a5,s6,8
 670:	f8f43423          	sd	a5,-120(s0)
 674:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 678:	03000593          	li	a1,48
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	e14080e7          	jalr	-492(ra) # 492 <putc>
  putc(fd, 'x');
 686:	85ea                	mv	a1,s10
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	e08080e7          	jalr	-504(ra) # 492 <putc>
 692:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 694:	03c9d793          	srli	a5,s3,0x3c
 698:	97de                	add	a5,a5,s7
 69a:	0007c583          	lbu	a1,0(a5)
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	df2080e7          	jalr	-526(ra) # 492 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a8:	0992                	slli	s3,s3,0x4
 6aa:	397d                	addiw	s2,s2,-1
 6ac:	fe0914e3          	bnez	s2,694 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6b0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	b721                	j	5be <vprintf+0x60>
        s = va_arg(ap, char*);
 6b8:	008b0993          	addi	s3,s6,8
 6bc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6c0:	02090163          	beqz	s2,6e2 <vprintf+0x184>
        while(*s != 0){
 6c4:	00094583          	lbu	a1,0(s2)
 6c8:	c9a1                	beqz	a1,718 <vprintf+0x1ba>
          putc(fd, *s);
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	dc6080e7          	jalr	-570(ra) # 492 <putc>
          s++;
 6d4:	0905                	addi	s2,s2,1
        while(*s != 0){
 6d6:	00094583          	lbu	a1,0(s2)
 6da:	f9e5                	bnez	a1,6ca <vprintf+0x16c>
        s = va_arg(ap, char*);
 6dc:	8b4e                	mv	s6,s3
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	bdf9                	j	5be <vprintf+0x60>
          s = "(null)";
 6e2:	00000917          	auipc	s2,0x0
 6e6:	46690913          	addi	s2,s2,1126 # b48 <syscall_names+0xd0>
        while(*s != 0){
 6ea:	02800593          	li	a1,40
 6ee:	bff1                	j	6ca <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6f0:	008b0913          	addi	s2,s6,8
 6f4:	000b4583          	lbu	a1,0(s6)
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	d98080e7          	jalr	-616(ra) # 492 <putc>
 702:	8b4a                	mv	s6,s2
      state = 0;
 704:	4981                	li	s3,0
 706:	bd65                	j	5be <vprintf+0x60>
        putc(fd, c);
 708:	85d2                	mv	a1,s4
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	d86080e7          	jalr	-634(ra) # 492 <putc>
      state = 0;
 714:	4981                	li	s3,0
 716:	b565                	j	5be <vprintf+0x60>
        s = va_arg(ap, char*);
 718:	8b4e                	mv	s6,s3
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b54d                	j	5be <vprintf+0x60>
    }
  }
}
 71e:	70e6                	ld	ra,120(sp)
 720:	7446                	ld	s0,112(sp)
 722:	74a6                	ld	s1,104(sp)
 724:	7906                	ld	s2,96(sp)
 726:	69e6                	ld	s3,88(sp)
 728:	6a46                	ld	s4,80(sp)
 72a:	6aa6                	ld	s5,72(sp)
 72c:	6b06                	ld	s6,64(sp)
 72e:	7be2                	ld	s7,56(sp)
 730:	7c42                	ld	s8,48(sp)
 732:	7ca2                	ld	s9,40(sp)
 734:	7d02                	ld	s10,32(sp)
 736:	6de2                	ld	s11,24(sp)
 738:	6109                	addi	sp,sp,128
 73a:	8082                	ret

000000000000073c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 73c:	715d                	addi	sp,sp,-80
 73e:	ec06                	sd	ra,24(sp)
 740:	e822                	sd	s0,16(sp)
 742:	1000                	addi	s0,sp,32
 744:	e010                	sd	a2,0(s0)
 746:	e414                	sd	a3,8(s0)
 748:	e818                	sd	a4,16(s0)
 74a:	ec1c                	sd	a5,24(s0)
 74c:	03043023          	sd	a6,32(s0)
 750:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 754:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 758:	8622                	mv	a2,s0
 75a:	00000097          	auipc	ra,0x0
 75e:	e04080e7          	jalr	-508(ra) # 55e <vprintf>
}
 762:	60e2                	ld	ra,24(sp)
 764:	6442                	ld	s0,16(sp)
 766:	6161                	addi	sp,sp,80
 768:	8082                	ret

000000000000076a <printf>:

void
printf(const char *fmt, ...)
{
 76a:	711d                	addi	sp,sp,-96
 76c:	ec06                	sd	ra,24(sp)
 76e:	e822                	sd	s0,16(sp)
 770:	1000                	addi	s0,sp,32
 772:	e40c                	sd	a1,8(s0)
 774:	e810                	sd	a2,16(s0)
 776:	ec14                	sd	a3,24(s0)
 778:	f018                	sd	a4,32(s0)
 77a:	f41c                	sd	a5,40(s0)
 77c:	03043823          	sd	a6,48(s0)
 780:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 784:	00840613          	addi	a2,s0,8
 788:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78c:	85aa                	mv	a1,a0
 78e:	4505                	li	a0,1
 790:	00000097          	auipc	ra,0x0
 794:	dce080e7          	jalr	-562(ra) # 55e <vprintf>
}
 798:	60e2                	ld	ra,24(sp)
 79a:	6442                	ld	s0,16(sp)
 79c:	6125                	addi	sp,sp,96
 79e:	8082                	ret

00000000000007a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a0:	1141                	addi	sp,sp,-16
 7a2:	e422                	sd	s0,8(sp)
 7a4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7aa:	00001797          	auipc	a5,0x1
 7ae:	85e7b783          	ld	a5,-1954(a5) # 1008 <freep>
 7b2:	a805                	j	7e2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b4:	4618                	lw	a4,8(a2)
 7b6:	9db9                	addw	a1,a1,a4
 7b8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7bc:	6398                	ld	a4,0(a5)
 7be:	6318                	ld	a4,0(a4)
 7c0:	fee53823          	sd	a4,-16(a0)
 7c4:	a091                	j	808 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c6:	ff852703          	lw	a4,-8(a0)
 7ca:	9e39                	addw	a2,a2,a4
 7cc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7ce:	ff053703          	ld	a4,-16(a0)
 7d2:	e398                	sd	a4,0(a5)
 7d4:	a099                	j	81a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d6:	6398                	ld	a4,0(a5)
 7d8:	00e7e463          	bltu	a5,a4,7e0 <free+0x40>
 7dc:	00e6ea63          	bltu	a3,a4,7f0 <free+0x50>
{
 7e0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e2:	fed7fae3          	bgeu	a5,a3,7d6 <free+0x36>
 7e6:	6398                	ld	a4,0(a5)
 7e8:	00e6e463          	bltu	a3,a4,7f0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ec:	fee7eae3          	bltu	a5,a4,7e0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7f0:	ff852583          	lw	a1,-8(a0)
 7f4:	6390                	ld	a2,0(a5)
 7f6:	02059713          	slli	a4,a1,0x20
 7fa:	9301                	srli	a4,a4,0x20
 7fc:	0712                	slli	a4,a4,0x4
 7fe:	9736                	add	a4,a4,a3
 800:	fae60ae3          	beq	a2,a4,7b4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 804:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 808:	4790                	lw	a2,8(a5)
 80a:	02061713          	slli	a4,a2,0x20
 80e:	9301                	srli	a4,a4,0x20
 810:	0712                	slli	a4,a4,0x4
 812:	973e                	add	a4,a4,a5
 814:	fae689e3          	beq	a3,a4,7c6 <free+0x26>
  } else
    p->s.ptr = bp;
 818:	e394                	sd	a3,0(a5)
  freep = p;
 81a:	00000717          	auipc	a4,0x0
 81e:	7ef73723          	sd	a5,2030(a4) # 1008 <freep>
}
 822:	6422                	ld	s0,8(sp)
 824:	0141                	addi	sp,sp,16
 826:	8082                	ret

0000000000000828 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 828:	7139                	addi	sp,sp,-64
 82a:	fc06                	sd	ra,56(sp)
 82c:	f822                	sd	s0,48(sp)
 82e:	f426                	sd	s1,40(sp)
 830:	f04a                	sd	s2,32(sp)
 832:	ec4e                	sd	s3,24(sp)
 834:	e852                	sd	s4,16(sp)
 836:	e456                	sd	s5,8(sp)
 838:	e05a                	sd	s6,0(sp)
 83a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 83c:	02051493          	slli	s1,a0,0x20
 840:	9081                	srli	s1,s1,0x20
 842:	04bd                	addi	s1,s1,15
 844:	8091                	srli	s1,s1,0x4
 846:	0014899b          	addiw	s3,s1,1
 84a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 84c:	00000517          	auipc	a0,0x0
 850:	7bc53503          	ld	a0,1980(a0) # 1008 <freep>
 854:	c515                	beqz	a0,880 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 856:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 858:	4798                	lw	a4,8(a5)
 85a:	02977f63          	bgeu	a4,s1,898 <malloc+0x70>
 85e:	8a4e                	mv	s4,s3
 860:	0009871b          	sext.w	a4,s3
 864:	6685                	lui	a3,0x1
 866:	00d77363          	bgeu	a4,a3,86c <malloc+0x44>
 86a:	6a05                	lui	s4,0x1
 86c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 870:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 874:	00000917          	auipc	s2,0x0
 878:	79490913          	addi	s2,s2,1940 # 1008 <freep>
  if(p == (char*)-1)
 87c:	5afd                	li	s5,-1
 87e:	a88d                	j	8f0 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 880:	00000797          	auipc	a5,0x0
 884:	79078793          	addi	a5,a5,1936 # 1010 <base>
 888:	00000717          	auipc	a4,0x0
 88c:	78f73023          	sd	a5,1920(a4) # 1008 <freep>
 890:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 892:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 896:	b7e1                	j	85e <malloc+0x36>
      if(p->s.size == nunits)
 898:	02e48b63          	beq	s1,a4,8ce <malloc+0xa6>
        p->s.size -= nunits;
 89c:	4137073b          	subw	a4,a4,s3
 8a0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a2:	1702                	slli	a4,a4,0x20
 8a4:	9301                	srli	a4,a4,0x20
 8a6:	0712                	slli	a4,a4,0x4
 8a8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8aa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ae:	00000717          	auipc	a4,0x0
 8b2:	74a73d23          	sd	a0,1882(a4) # 1008 <freep>
      return (void*)(p + 1);
 8b6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8ba:	70e2                	ld	ra,56(sp)
 8bc:	7442                	ld	s0,48(sp)
 8be:	74a2                	ld	s1,40(sp)
 8c0:	7902                	ld	s2,32(sp)
 8c2:	69e2                	ld	s3,24(sp)
 8c4:	6a42                	ld	s4,16(sp)
 8c6:	6aa2                	ld	s5,8(sp)
 8c8:	6b02                	ld	s6,0(sp)
 8ca:	6121                	addi	sp,sp,64
 8cc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8ce:	6398                	ld	a4,0(a5)
 8d0:	e118                	sd	a4,0(a0)
 8d2:	bff1                	j	8ae <malloc+0x86>
  hp->s.size = nu;
 8d4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8d8:	0541                	addi	a0,a0,16
 8da:	00000097          	auipc	ra,0x0
 8de:	ec6080e7          	jalr	-314(ra) # 7a0 <free>
  return freep;
 8e2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e6:	d971                	beqz	a0,8ba <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ea:	4798                	lw	a4,8(a5)
 8ec:	fa9776e3          	bgeu	a4,s1,898 <malloc+0x70>
    if(p == freep)
 8f0:	00093703          	ld	a4,0(s2)
 8f4:	853e                	mv	a0,a5
 8f6:	fef719e3          	bne	a4,a5,8e8 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8fa:	8552                	mv	a0,s4
 8fc:	00000097          	auipc	ra,0x0
 900:	b56080e7          	jalr	-1194(ra) # 452 <sbrk>
  if(p == (char*)-1)
 904:	fd5518e3          	bne	a0,s5,8d4 <malloc+0xac>
        return 0;
 908:	4501                	li	a0,0
 90a:	bf45                	j	8ba <malloc+0x92>
