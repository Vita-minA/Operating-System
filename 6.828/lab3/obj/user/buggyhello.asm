
obj/user/buggyhello：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 60 00 00 00       	call   8000a2 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t i = sys_getenvid();
  800052:	e8 c9 00 00 00       	call   800120 <sys_getenvid>
    thisenv = &envs[ENVX(i)];
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005f:	c1 e0 05             	shl    $0x5,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x30>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 6a 0e 80 00       	push   $0x800e6a
  80010c:	6a 23                	push   $0x23
  80010e:	68 87 0e 80 00       	push   $0x800e87
  800113:	e8 27 00 00 00       	call   80013f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	56                   	push   %esi
  800143:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800144:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800147:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014d:	e8 ce ff ff ff       	call   800120 <sys_getenvid>
  800152:	83 ec 0c             	sub    $0xc,%esp
  800155:	ff 75 0c             	pushl  0xc(%ebp)
  800158:	ff 75 08             	pushl  0x8(%ebp)
  80015b:	56                   	push   %esi
  80015c:	50                   	push   %eax
  80015d:	68 98 0e 80 00       	push   $0x800e98
  800162:	e8 b1 00 00 00       	call   800218 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800167:	83 c4 18             	add    $0x18,%esp
  80016a:	53                   	push   %ebx
  80016b:	ff 75 10             	pushl  0x10(%ebp)
  80016e:	e8 54 00 00 00       	call   8001c7 <vcprintf>
	cprintf("\n");
  800173:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  80017a:	e8 99 00 00 00       	call   800218 <cprintf>
  80017f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800182:	cc                   	int3   
  800183:	eb fd                	jmp    800182 <_panic+0x43>

00800185 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	53                   	push   %ebx
  800189:	83 ec 04             	sub    $0x4,%esp
  80018c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018f:	8b 13                	mov    (%ebx),%edx
  800191:	8d 42 01             	lea    0x1(%edx),%eax
  800194:	89 03                	mov    %eax,(%ebx)
  800196:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800199:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019d:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a2:	75 1a                	jne    8001be <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001a4:	83 ec 08             	sub    $0x8,%esp
  8001a7:	68 ff 00 00 00       	push   $0xff
  8001ac:	8d 43 08             	lea    0x8(%ebx),%eax
  8001af:	50                   	push   %eax
  8001b0:	e8 ed fe ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8001b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001bb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d7:	00 00 00 
	b.cnt = 0;
  8001da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e4:	ff 75 0c             	pushl  0xc(%ebp)
  8001e7:	ff 75 08             	pushl  0x8(%ebp)
  8001ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f0:	50                   	push   %eax
  8001f1:	68 85 01 80 00       	push   $0x800185
  8001f6:	e8 1a 01 00 00       	call   800315 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fb:	83 c4 08             	add    $0x8,%esp
  8001fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800204:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	e8 92 fe ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  800210:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800221:	50                   	push   %eax
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	e8 9d ff ff ff       	call   8001c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 1c             	sub    $0x1c,%esp
  800235:	89 c7                	mov    %eax,%edi
  800237:	89 d6                	mov    %edx,%esi
  800239:	8b 45 08             	mov    0x8(%ebp),%eax
  80023c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800242:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800245:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800248:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800250:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800253:	39 d3                	cmp    %edx,%ebx
  800255:	72 05                	jb     80025c <printnum+0x30>
  800257:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025a:	77 45                	ja     8002a1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	ff 75 18             	pushl  0x18(%ebp)
  800262:	8b 45 14             	mov    0x14(%ebp),%eax
  800265:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800268:	53                   	push   %ebx
  800269:	ff 75 10             	pushl  0x10(%ebp)
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800272:	ff 75 e0             	pushl  -0x20(%ebp)
  800275:	ff 75 dc             	pushl  -0x24(%ebp)
  800278:	ff 75 d8             	pushl  -0x28(%ebp)
  80027b:	e8 50 09 00 00       	call   800bd0 <__udivdi3>
  800280:	83 c4 18             	add    $0x18,%esp
  800283:	52                   	push   %edx
  800284:	50                   	push   %eax
  800285:	89 f2                	mov    %esi,%edx
  800287:	89 f8                	mov    %edi,%eax
  800289:	e8 9e ff ff ff       	call   80022c <printnum>
  80028e:	83 c4 20             	add    $0x20,%esp
  800291:	eb 18                	jmp    8002ab <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	ff 75 18             	pushl  0x18(%ebp)
  80029a:	ff d7                	call   *%edi
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	eb 03                	jmp    8002a4 <printnum+0x78>
  8002a1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a4:	83 eb 01             	sub    $0x1,%ebx
  8002a7:	85 db                	test   %ebx,%ebx
  8002a9:	7f e8                	jg     800293 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	56                   	push   %esi
  8002af:	83 ec 04             	sub    $0x4,%esp
  8002b2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002be:	e8 3d 0a 00 00       	call   800d00 <__umoddi3>
  8002c3:	83 c4 14             	add    $0x14,%esp
  8002c6:	0f be 80 be 0e 80 00 	movsbl 0x800ebe(%eax),%eax
  8002cd:	50                   	push   %eax
  8002ce:	ff d7                	call   *%edi
}
  8002d0:	83 c4 10             	add    $0x10,%esp
  8002d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d6:	5b                   	pop    %ebx
  8002d7:	5e                   	pop    %esi
  8002d8:	5f                   	pop    %edi
  8002d9:	5d                   	pop    %ebp
  8002da:	c3                   	ret    

008002db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e5:	8b 10                	mov    (%eax),%edx
  8002e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ea:	73 0a                	jae    8002f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f4:	88 02                	mov    %al,(%edx)
}
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800301:	50                   	push   %eax
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	ff 75 0c             	pushl  0xc(%ebp)
  800308:	ff 75 08             	pushl  0x8(%ebp)
  80030b:	e8 05 00 00 00       	call   800315 <vprintfmt>
	va_end(ap);
}
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	c9                   	leave  
  800314:	c3                   	ret    

00800315 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	83 ec 2c             	sub    $0x2c,%esp
  80031e:	8b 75 08             	mov    0x8(%ebp),%esi
  800321:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800324:	8b 7d 10             	mov    0x10(%ebp),%edi
  800327:	eb 12                	jmp    80033b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800329:	85 c0                	test   %eax,%eax
  80032b:	0f 84 a9 04 00 00    	je     8007da <vprintfmt+0x4c5>
				return;
			putch(ch, putdat);
  800331:	83 ec 08             	sub    $0x8,%esp
  800334:	53                   	push   %ebx
  800335:	50                   	push   %eax
  800336:	ff d6                	call   *%esi
  800338:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80033b:	83 c7 01             	add    $0x1,%edi
  80033e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800342:	83 f8 25             	cmp    $0x25,%eax
  800345:	75 e2                	jne    800329 <vprintfmt+0x14>
  800347:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80034b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800352:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800359:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800360:	b9 00 00 00 00       	mov    $0x0,%ecx
  800365:	eb 07                	jmp    80036e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80036a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8d 47 01             	lea    0x1(%edi),%eax
  800371:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800374:	0f b6 07             	movzbl (%edi),%eax
  800377:	0f b6 d0             	movzbl %al,%edx
  80037a:	83 e8 23             	sub    $0x23,%eax
  80037d:	3c 55                	cmp    $0x55,%al
  80037f:	0f 87 3a 04 00 00    	ja     8007bf <vprintfmt+0x4aa>
  800385:	0f b6 c0             	movzbl %al,%eax
  800388:	ff 24 85 60 0f 80 00 	jmp    *0x800f60(,%eax,4)
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800392:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800396:	eb d6                	jmp    80036e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039b:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003aa:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ad:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b0:	83 f9 09             	cmp    $0x9,%ecx
  8003b3:	77 3f                	ja     8003f4 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003b5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003b8:	eb e9                	jmp    8003a3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8b 00                	mov    (%eax),%eax
  8003bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8d 40 04             	lea    0x4(%eax),%eax
  8003c8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ce:	eb 2a                	jmp    8003fa <vprintfmt+0xe5>
  8003d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003d3:	85 c0                	test   %eax,%eax
  8003d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003da:	0f 49 d0             	cmovns %eax,%edx
  8003dd:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e3:	eb 89                	jmp    80036e <vprintfmt+0x59>
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003e8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ef:	e9 7a ff ff ff       	jmp    80036e <vprintfmt+0x59>
  8003f4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003fa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003fe:	0f 89 6a ff ff ff    	jns    80036e <vprintfmt+0x59>
				width = precision, precision = -1;
  800404:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800407:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800411:	e9 58 ff ff ff       	jmp    80036e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800416:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80041c:	e9 4d ff ff ff       	jmp    80036e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 78 04             	lea    0x4(%eax),%edi
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	53                   	push   %ebx
  80042b:	ff 30                	pushl  (%eax)
  80042d:	ff d6                	call   *%esi
			break;
  80042f:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800432:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800435:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800438:	e9 fe fe ff ff       	jmp    80033b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8d 78 04             	lea    0x4(%eax),%edi
  800443:	8b 00                	mov    (%eax),%eax
  800445:	99                   	cltd   
  800446:	31 d0                	xor    %edx,%eax
  800448:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044a:	83 f8 07             	cmp    $0x7,%eax
  80044d:	7f 0b                	jg     80045a <vprintfmt+0x145>
  80044f:	8b 14 85 c0 10 80 00 	mov    0x8010c0(,%eax,4),%edx
  800456:	85 d2                	test   %edx,%edx
  800458:	75 1b                	jne    800475 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80045a:	50                   	push   %eax
  80045b:	68 d6 0e 80 00       	push   $0x800ed6
  800460:	53                   	push   %ebx
  800461:	56                   	push   %esi
  800462:	e8 91 fe ff ff       	call   8002f8 <printfmt>
  800467:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800470:	e9 c6 fe ff ff       	jmp    80033b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800475:	52                   	push   %edx
  800476:	68 df 0e 80 00       	push   $0x800edf
  80047b:	53                   	push   %ebx
  80047c:	56                   	push   %esi
  80047d:	e8 76 fe ff ff       	call   8002f8 <printfmt>
  800482:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800485:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80048b:	e9 ab fe ff ff       	jmp    80033b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	83 c0 04             	add    $0x4,%eax
  800496:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800499:	8b 45 14             	mov    0x14(%ebp),%eax
  80049c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80049e:	85 ff                	test   %edi,%edi
  8004a0:	b8 cf 0e 80 00       	mov    $0x800ecf,%eax
  8004a5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ac:	0f 8e 94 00 00 00    	jle    800546 <vprintfmt+0x231>
  8004b2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004b6:	0f 84 98 00 00 00    	je     800554 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	ff 75 d0             	pushl  -0x30(%ebp)
  8004c2:	57                   	push   %edi
  8004c3:	e8 9a 03 00 00       	call   800862 <strnlen>
  8004c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cb:	29 c1                	sub    %eax,%ecx
  8004cd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004d0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004d3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004da:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004dd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	eb 0f                	jmp    8004f0 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	53                   	push   %ebx
  8004e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ea:	83 ef 01             	sub    $0x1,%edi
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 ff                	test   %edi,%edi
  8004f2:	7f ed                	jg     8004e1 <vprintfmt+0x1cc>
  8004f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004f7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004fa:	85 c9                	test   %ecx,%ecx
  8004fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800501:	0f 49 c1             	cmovns %ecx,%eax
  800504:	29 c1                	sub    %eax,%ecx
  800506:	89 75 08             	mov    %esi,0x8(%ebp)
  800509:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80050c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050f:	89 cb                	mov    %ecx,%ebx
  800511:	eb 4d                	jmp    800560 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800513:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800517:	74 1b                	je     800534 <vprintfmt+0x21f>
  800519:	0f be c0             	movsbl %al,%eax
  80051c:	83 e8 20             	sub    $0x20,%eax
  80051f:	83 f8 5e             	cmp    $0x5e,%eax
  800522:	76 10                	jbe    800534 <vprintfmt+0x21f>
					putch('?', putdat);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	ff 75 0c             	pushl  0xc(%ebp)
  80052a:	6a 3f                	push   $0x3f
  80052c:	ff 55 08             	call   *0x8(%ebp)
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	eb 0d                	jmp    800541 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	ff 75 0c             	pushl  0xc(%ebp)
  80053a:	52                   	push   %edx
  80053b:	ff 55 08             	call   *0x8(%ebp)
  80053e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800541:	83 eb 01             	sub    $0x1,%ebx
  800544:	eb 1a                	jmp    800560 <vprintfmt+0x24b>
  800546:	89 75 08             	mov    %esi,0x8(%ebp)
  800549:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800552:	eb 0c                	jmp    800560 <vprintfmt+0x24b>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	83 c7 01             	add    $0x1,%edi
  800563:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800567:	0f be d0             	movsbl %al,%edx
  80056a:	85 d2                	test   %edx,%edx
  80056c:	74 23                	je     800591 <vprintfmt+0x27c>
  80056e:	85 f6                	test   %esi,%esi
  800570:	78 a1                	js     800513 <vprintfmt+0x1fe>
  800572:	83 ee 01             	sub    $0x1,%esi
  800575:	79 9c                	jns    800513 <vprintfmt+0x1fe>
  800577:	89 df                	mov    %ebx,%edi
  800579:	8b 75 08             	mov    0x8(%ebp),%esi
  80057c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057f:	eb 18                	jmp    800599 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	53                   	push   %ebx
  800585:	6a 20                	push   $0x20
  800587:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800589:	83 ef 01             	sub    $0x1,%edi
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	eb 08                	jmp    800599 <vprintfmt+0x284>
  800591:	89 df                	mov    %ebx,%edi
  800593:	8b 75 08             	mov    0x8(%ebp),%esi
  800596:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800599:	85 ff                	test   %edi,%edi
  80059b:	7f e4                	jg     800581 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80059d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a0:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a6:	e9 90 fd ff ff       	jmp    80033b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ab:	83 f9 01             	cmp    $0x1,%ecx
  8005ae:	7e 19                	jle    8005c9 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8b 50 04             	mov    0x4(%eax),%edx
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8d 40 08             	lea    0x8(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c7:	eb 38                	jmp    800601 <vprintfmt+0x2ec>
	else if (lflag)
  8005c9:	85 c9                	test   %ecx,%ecx
  8005cb:	74 1b                	je     8005e8 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d5:	89 c1                	mov    %eax,%ecx
  8005d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8005da:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 40 04             	lea    0x4(%eax),%eax
  8005e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e6:	eb 19                	jmp    800601 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 00                	mov    (%eax),%eax
  8005ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f0:	89 c1                	mov    %eax,%ecx
  8005f2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 40 04             	lea    0x4(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800601:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800604:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80060c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800610:	0f 89 75 01 00 00    	jns    80078b <vprintfmt+0x476>
				putch('-', putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 2d                	push   $0x2d
  80061c:	ff d6                	call   *%esi
				num = -(long long) num;
  80061e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800621:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800624:	f7 da                	neg    %edx
  800626:	83 d1 00             	adc    $0x0,%ecx
  800629:	f7 d9                	neg    %ecx
  80062b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800633:	e9 53 01 00 00       	jmp    80078b <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800638:	83 f9 01             	cmp    $0x1,%ecx
  80063b:	7e 18                	jle    800655 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 10                	mov    (%eax),%edx
  800642:	8b 48 04             	mov    0x4(%eax),%ecx
  800645:	8d 40 08             	lea    0x8(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80064b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800650:	e9 36 01 00 00       	jmp    80078b <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800655:	85 c9                	test   %ecx,%ecx
  800657:	74 1a                	je     800673 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800663:	8d 40 04             	lea    0x4(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800669:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066e:	e9 18 01 00 00       	jmp    80078b <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800683:	b8 0a 00 00 00       	mov    $0xa,%eax
  800688:	e9 fe 00 00 00       	jmp    80078b <vprintfmt+0x476>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068d:	83 f9 01             	cmp    $0x1,%ecx
  800690:	7e 19                	jle    8006ab <vprintfmt+0x396>
		return va_arg(*ap, long long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 50 04             	mov    0x4(%eax),%edx
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 40 08             	lea    0x8(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a9:	eb 38                	jmp    8006e3 <vprintfmt+0x3ce>
	else if (lflag)
  8006ab:	85 c9                	test   %ecx,%ecx
  8006ad:	74 1b                	je     8006ca <vprintfmt+0x3b5>
		return va_arg(*ap, long);
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b7:	89 c1                	mov    %eax,%ecx
  8006b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c2:	8d 40 04             	lea    0x4(%eax),%eax
  8006c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c8:	eb 19                	jmp    8006e3 <vprintfmt+0x3ce>
	else
		return va_arg(*ap, int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d2:	89 c1                	mov    %eax,%ecx
  8006d4:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
  8006e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006e6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 8;
  8006e9:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;

		// (unsigned) octal
		case 'o':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006ee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f2:	0f 89 93 00 00 00    	jns    80078b <vprintfmt+0x476>
				putch('-', putdat);
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	6a 2d                	push   $0x2d
  8006fe:	ff d6                	call   *%esi
				num = -(long long) num;
  800700:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800703:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800706:	f7 da                	neg    %edx
  800708:	83 d1 00             	adc    $0x0,%ecx
  80070b:	f7 d9                	neg    %ecx
  80070d:	83 c4 10             	add    $0x10,%esp
			}
			base = 8;
  800710:	b8 08 00 00 00       	mov    $0x8,%eax
  800715:	eb 74                	jmp    80078b <vprintfmt+0x476>
			goto number;

		// pointer
		case 'p':
			putch('0', putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	53                   	push   %ebx
  80071b:	6a 30                	push   $0x30
  80071d:	ff d6                	call   *%esi
			putch('x', putdat);
  80071f:	83 c4 08             	add    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	6a 78                	push   $0x78
  800725:	ff d6                	call   *%esi
			num = (unsigned long long)
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8b 10                	mov    (%eax),%edx
  80072c:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800731:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800734:	8d 40 04             	lea    0x4(%eax),%eax
  800737:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80073f:	eb 4a                	jmp    80078b <vprintfmt+0x476>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800741:	83 f9 01             	cmp    $0x1,%ecx
  800744:	7e 15                	jle    80075b <vprintfmt+0x446>
		return va_arg(*ap, unsigned long long);
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8b 10                	mov    (%eax),%edx
  80074b:	8b 48 04             	mov    0x4(%eax),%ecx
  80074e:	8d 40 08             	lea    0x8(%eax),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800754:	b8 10 00 00 00       	mov    $0x10,%eax
  800759:	eb 30                	jmp    80078b <vprintfmt+0x476>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80075b:	85 c9                	test   %ecx,%ecx
  80075d:	74 17                	je     800776 <vprintfmt+0x461>
		return va_arg(*ap, unsigned long);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8b 10                	mov    (%eax),%edx
  800764:	b9 00 00 00 00       	mov    $0x0,%ecx
  800769:	8d 40 04             	lea    0x4(%eax),%eax
  80076c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80076f:	b8 10 00 00 00       	mov    $0x10,%eax
  800774:	eb 15                	jmp    80078b <vprintfmt+0x476>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800776:	8b 45 14             	mov    0x14(%ebp),%eax
  800779:	8b 10                	mov    (%eax),%edx
  80077b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800780:	8d 40 04             	lea    0x4(%eax),%eax
  800783:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800786:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80078b:	83 ec 0c             	sub    $0xc,%esp
  80078e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800792:	57                   	push   %edi
  800793:	ff 75 e0             	pushl  -0x20(%ebp)
  800796:	50                   	push   %eax
  800797:	51                   	push   %ecx
  800798:	52                   	push   %edx
  800799:	89 da                	mov    %ebx,%edx
  80079b:	89 f0                	mov    %esi,%eax
  80079d:	e8 8a fa ff ff       	call   80022c <printnum>
			break;
  8007a2:	83 c4 20             	add    $0x20,%esp
  8007a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a8:	e9 8e fb ff ff       	jmp    80033b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	52                   	push   %edx
  8007b2:	ff d6                	call   *%esi
			break;
  8007b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ba:	e9 7c fb ff ff       	jmp    80033b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	6a 25                	push   $0x25
  8007c5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	eb 03                	jmp    8007cf <vprintfmt+0x4ba>
  8007cc:	83 ef 01             	sub    $0x1,%edi
  8007cf:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007d3:	75 f7                	jne    8007cc <vprintfmt+0x4b7>
  8007d5:	e9 61 fb ff ff       	jmp    80033b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007dd:	5b                   	pop    %ebx
  8007de:	5e                   	pop    %esi
  8007df:	5f                   	pop    %edi
  8007e0:	5d                   	pop    %ebp
  8007e1:	c3                   	ret    

008007e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 18             	sub    $0x18,%esp
  8007e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ff:	85 c0                	test   %eax,%eax
  800801:	74 26                	je     800829 <vsnprintf+0x47>
  800803:	85 d2                	test   %edx,%edx
  800805:	7e 22                	jle    800829 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800807:	ff 75 14             	pushl  0x14(%ebp)
  80080a:	ff 75 10             	pushl  0x10(%ebp)
  80080d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800810:	50                   	push   %eax
  800811:	68 db 02 80 00       	push   $0x8002db
  800816:	e8 fa fa ff ff       	call   800315 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800821:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800824:	83 c4 10             	add    $0x10,%esp
  800827:	eb 05                	jmp    80082e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800829:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800836:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800839:	50                   	push   %eax
  80083a:	ff 75 10             	pushl  0x10(%ebp)
  80083d:	ff 75 0c             	pushl  0xc(%ebp)
  800840:	ff 75 08             	pushl  0x8(%ebp)
  800843:	e8 9a ff ff ff       	call   8007e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800848:	c9                   	leave  
  800849:	c3                   	ret    

0080084a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
  800855:	eb 03                	jmp    80085a <strlen+0x10>
		n++;
  800857:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80085a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80085e:	75 f7                	jne    800857 <strlen+0xd>
		n++;
	return n;
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800868:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80086b:	ba 00 00 00 00       	mov    $0x0,%edx
  800870:	eb 03                	jmp    800875 <strnlen+0x13>
		n++;
  800872:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800875:	39 c2                	cmp    %eax,%edx
  800877:	74 08                	je     800881 <strnlen+0x1f>
  800879:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80087d:	75 f3                	jne    800872 <strnlen+0x10>
  80087f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	8b 45 08             	mov    0x8(%ebp),%eax
  80088a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80088d:	89 c2                	mov    %eax,%edx
  80088f:	83 c2 01             	add    $0x1,%edx
  800892:	83 c1 01             	add    $0x1,%ecx
  800895:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800899:	88 5a ff             	mov    %bl,-0x1(%edx)
  80089c:	84 db                	test   %bl,%bl
  80089e:	75 ef                	jne    80088f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
  8008a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008aa:	53                   	push   %ebx
  8008ab:	e8 9a ff ff ff       	call   80084a <strlen>
  8008b0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008b3:	ff 75 0c             	pushl  0xc(%ebp)
  8008b6:	01 d8                	add    %ebx,%eax
  8008b8:	50                   	push   %eax
  8008b9:	e8 c5 ff ff ff       	call   800883 <strcpy>
	return dst;
}
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    

008008c5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	56                   	push   %esi
  8008c9:	53                   	push   %ebx
  8008ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d0:	89 f3                	mov    %esi,%ebx
  8008d2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d5:	89 f2                	mov    %esi,%edx
  8008d7:	eb 0f                	jmp    8008e8 <strncpy+0x23>
		*dst++ = *src;
  8008d9:	83 c2 01             	add    $0x1,%edx
  8008dc:	0f b6 01             	movzbl (%ecx),%eax
  8008df:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e2:	80 39 01             	cmpb   $0x1,(%ecx)
  8008e5:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e8:	39 da                	cmp    %ebx,%edx
  8008ea:	75 ed                	jne    8008d9 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008ec:	89 f0                	mov    %esi,%eax
  8008ee:	5b                   	pop    %ebx
  8008ef:	5e                   	pop    %esi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fd:	8b 55 10             	mov    0x10(%ebp),%edx
  800900:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800902:	85 d2                	test   %edx,%edx
  800904:	74 21                	je     800927 <strlcpy+0x35>
  800906:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80090a:	89 f2                	mov    %esi,%edx
  80090c:	eb 09                	jmp    800917 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80090e:	83 c2 01             	add    $0x1,%edx
  800911:	83 c1 01             	add    $0x1,%ecx
  800914:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800917:	39 c2                	cmp    %eax,%edx
  800919:	74 09                	je     800924 <strlcpy+0x32>
  80091b:	0f b6 19             	movzbl (%ecx),%ebx
  80091e:	84 db                	test   %bl,%bl
  800920:	75 ec                	jne    80090e <strlcpy+0x1c>
  800922:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800924:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800927:	29 f0                	sub    %esi,%eax
}
  800929:	5b                   	pop    %ebx
  80092a:	5e                   	pop    %esi
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800933:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800936:	eb 06                	jmp    80093e <strcmp+0x11>
		p++, q++;
  800938:	83 c1 01             	add    $0x1,%ecx
  80093b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093e:	0f b6 01             	movzbl (%ecx),%eax
  800941:	84 c0                	test   %al,%al
  800943:	74 04                	je     800949 <strcmp+0x1c>
  800945:	3a 02                	cmp    (%edx),%al
  800947:	74 ef                	je     800938 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800949:	0f b6 c0             	movzbl %al,%eax
  80094c:	0f b6 12             	movzbl (%edx),%edx
  80094f:	29 d0                	sub    %edx,%eax
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	89 c3                	mov    %eax,%ebx
  80095f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800962:	eb 06                	jmp    80096a <strncmp+0x17>
		n--, p++, q++;
  800964:	83 c0 01             	add    $0x1,%eax
  800967:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80096a:	39 d8                	cmp    %ebx,%eax
  80096c:	74 15                	je     800983 <strncmp+0x30>
  80096e:	0f b6 08             	movzbl (%eax),%ecx
  800971:	84 c9                	test   %cl,%cl
  800973:	74 04                	je     800979 <strncmp+0x26>
  800975:	3a 0a                	cmp    (%edx),%cl
  800977:	74 eb                	je     800964 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800979:	0f b6 00             	movzbl (%eax),%eax
  80097c:	0f b6 12             	movzbl (%edx),%edx
  80097f:	29 d0                	sub    %edx,%eax
  800981:	eb 05                	jmp    800988 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800983:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800995:	eb 07                	jmp    80099e <strchr+0x13>
		if (*s == c)
  800997:	38 ca                	cmp    %cl,%dl
  800999:	74 0f                	je     8009aa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099b:	83 c0 01             	add    $0x1,%eax
  80099e:	0f b6 10             	movzbl (%eax),%edx
  8009a1:	84 d2                	test   %dl,%dl
  8009a3:	75 f2                	jne    800997 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b6:	eb 03                	jmp    8009bb <strfind+0xf>
  8009b8:	83 c0 01             	add    $0x1,%eax
  8009bb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009be:	38 ca                	cmp    %cl,%dl
  8009c0:	74 04                	je     8009c6 <strfind+0x1a>
  8009c2:	84 d2                	test   %dl,%dl
  8009c4:	75 f2                	jne    8009b8 <strfind+0xc>
			break;
	return (char *) s;
}
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	53                   	push   %ebx
  8009ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009d4:	85 c9                	test   %ecx,%ecx
  8009d6:	74 36                	je     800a0e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009d8:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009de:	75 28                	jne    800a08 <memset+0x40>
  8009e0:	f6 c1 03             	test   $0x3,%cl
  8009e3:	75 23                	jne    800a08 <memset+0x40>
		c &= 0xFF;
  8009e5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009e9:	89 d3                	mov    %edx,%ebx
  8009eb:	c1 e3 08             	shl    $0x8,%ebx
  8009ee:	89 d6                	mov    %edx,%esi
  8009f0:	c1 e6 18             	shl    $0x18,%esi
  8009f3:	89 d0                	mov    %edx,%eax
  8009f5:	c1 e0 10             	shl    $0x10,%eax
  8009f8:	09 f0                	or     %esi,%eax
  8009fa:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009fc:	89 d8                	mov    %ebx,%eax
  8009fe:	09 d0                	or     %edx,%eax
  800a00:	c1 e9 02             	shr    $0x2,%ecx
  800a03:	fc                   	cld    
  800a04:	f3 ab                	rep stos %eax,%es:(%edi)
  800a06:	eb 06                	jmp    800a0e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0b:	fc                   	cld    
  800a0c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a0e:	89 f8                	mov    %edi,%eax
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5f                   	pop    %edi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	57                   	push   %edi
  800a19:	56                   	push   %esi
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a23:	39 c6                	cmp    %eax,%esi
  800a25:	73 35                	jae    800a5c <memmove+0x47>
  800a27:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a2a:	39 d0                	cmp    %edx,%eax
  800a2c:	73 2e                	jae    800a5c <memmove+0x47>
		s += n;
		d += n;
  800a2e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a31:	89 d6                	mov    %edx,%esi
  800a33:	09 fe                	or     %edi,%esi
  800a35:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a3b:	75 13                	jne    800a50 <memmove+0x3b>
  800a3d:	f6 c1 03             	test   $0x3,%cl
  800a40:	75 0e                	jne    800a50 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a42:	83 ef 04             	sub    $0x4,%edi
  800a45:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a48:	c1 e9 02             	shr    $0x2,%ecx
  800a4b:	fd                   	std    
  800a4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4e:	eb 09                	jmp    800a59 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a50:	83 ef 01             	sub    $0x1,%edi
  800a53:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a56:	fd                   	std    
  800a57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a59:	fc                   	cld    
  800a5a:	eb 1d                	jmp    800a79 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5c:	89 f2                	mov    %esi,%edx
  800a5e:	09 c2                	or     %eax,%edx
  800a60:	f6 c2 03             	test   $0x3,%dl
  800a63:	75 0f                	jne    800a74 <memmove+0x5f>
  800a65:	f6 c1 03             	test   $0x3,%cl
  800a68:	75 0a                	jne    800a74 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a6a:	c1 e9 02             	shr    $0x2,%ecx
  800a6d:	89 c7                	mov    %eax,%edi
  800a6f:	fc                   	cld    
  800a70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a72:	eb 05                	jmp    800a79 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a74:	89 c7                	mov    %eax,%edi
  800a76:	fc                   	cld    
  800a77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a79:	5e                   	pop    %esi
  800a7a:	5f                   	pop    %edi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a80:	ff 75 10             	pushl  0x10(%ebp)
  800a83:	ff 75 0c             	pushl  0xc(%ebp)
  800a86:	ff 75 08             	pushl  0x8(%ebp)
  800a89:	e8 87 ff ff ff       	call   800a15 <memmove>
}
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9b:	89 c6                	mov    %eax,%esi
  800a9d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa0:	eb 1a                	jmp    800abc <memcmp+0x2c>
		if (*s1 != *s2)
  800aa2:	0f b6 08             	movzbl (%eax),%ecx
  800aa5:	0f b6 1a             	movzbl (%edx),%ebx
  800aa8:	38 d9                	cmp    %bl,%cl
  800aaa:	74 0a                	je     800ab6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800aac:	0f b6 c1             	movzbl %cl,%eax
  800aaf:	0f b6 db             	movzbl %bl,%ebx
  800ab2:	29 d8                	sub    %ebx,%eax
  800ab4:	eb 0f                	jmp    800ac5 <memcmp+0x35>
		s1++, s2++;
  800ab6:	83 c0 01             	add    $0x1,%eax
  800ab9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abc:	39 f0                	cmp    %esi,%eax
  800abe:	75 e2                	jne    800aa2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ac5:	5b                   	pop    %ebx
  800ac6:	5e                   	pop    %esi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	53                   	push   %ebx
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ad0:	89 c1                	mov    %eax,%ecx
  800ad2:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ad5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ad9:	eb 0a                	jmp    800ae5 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800adb:	0f b6 10             	movzbl (%eax),%edx
  800ade:	39 da                	cmp    %ebx,%edx
  800ae0:	74 07                	je     800ae9 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae2:	83 c0 01             	add    $0x1,%eax
  800ae5:	39 c8                	cmp    %ecx,%eax
  800ae7:	72 f2                	jb     800adb <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	57                   	push   %edi
  800af0:	56                   	push   %esi
  800af1:	53                   	push   %ebx
  800af2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800af8:	eb 03                	jmp    800afd <strtol+0x11>
		s++;
  800afa:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800afd:	0f b6 01             	movzbl (%ecx),%eax
  800b00:	3c 20                	cmp    $0x20,%al
  800b02:	74 f6                	je     800afa <strtol+0xe>
  800b04:	3c 09                	cmp    $0x9,%al
  800b06:	74 f2                	je     800afa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b08:	3c 2b                	cmp    $0x2b,%al
  800b0a:	75 0a                	jne    800b16 <strtol+0x2a>
		s++;
  800b0c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800b14:	eb 11                	jmp    800b27 <strtol+0x3b>
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b1b:	3c 2d                	cmp    $0x2d,%al
  800b1d:	75 08                	jne    800b27 <strtol+0x3b>
		s++, neg = 1;
  800b1f:	83 c1 01             	add    $0x1,%ecx
  800b22:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b27:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b2d:	75 15                	jne    800b44 <strtol+0x58>
  800b2f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b32:	75 10                	jne    800b44 <strtol+0x58>
  800b34:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b38:	75 7c                	jne    800bb6 <strtol+0xca>
		s += 2, base = 16;
  800b3a:	83 c1 02             	add    $0x2,%ecx
  800b3d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b42:	eb 16                	jmp    800b5a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b44:	85 db                	test   %ebx,%ebx
  800b46:	75 12                	jne    800b5a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b48:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b4d:	80 39 30             	cmpb   $0x30,(%ecx)
  800b50:	75 08                	jne    800b5a <strtol+0x6e>
		s++, base = 8;
  800b52:	83 c1 01             	add    $0x1,%ecx
  800b55:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b62:	0f b6 11             	movzbl (%ecx),%edx
  800b65:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b68:	89 f3                	mov    %esi,%ebx
  800b6a:	80 fb 09             	cmp    $0x9,%bl
  800b6d:	77 08                	ja     800b77 <strtol+0x8b>
			dig = *s - '0';
  800b6f:	0f be d2             	movsbl %dl,%edx
  800b72:	83 ea 30             	sub    $0x30,%edx
  800b75:	eb 22                	jmp    800b99 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b77:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b7a:	89 f3                	mov    %esi,%ebx
  800b7c:	80 fb 19             	cmp    $0x19,%bl
  800b7f:	77 08                	ja     800b89 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b81:	0f be d2             	movsbl %dl,%edx
  800b84:	83 ea 57             	sub    $0x57,%edx
  800b87:	eb 10                	jmp    800b99 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b89:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b8c:	89 f3                	mov    %esi,%ebx
  800b8e:	80 fb 19             	cmp    $0x19,%bl
  800b91:	77 16                	ja     800ba9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b93:	0f be d2             	movsbl %dl,%edx
  800b96:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b99:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b9c:	7d 0b                	jge    800ba9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b9e:	83 c1 01             	add    $0x1,%ecx
  800ba1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ba5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ba7:	eb b9                	jmp    800b62 <strtol+0x76>

	if (endptr)
  800ba9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bad:	74 0d                	je     800bbc <strtol+0xd0>
		*endptr = (char *) s;
  800baf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bb2:	89 0e                	mov    %ecx,(%esi)
  800bb4:	eb 06                	jmp    800bbc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bb6:	85 db                	test   %ebx,%ebx
  800bb8:	74 98                	je     800b52 <strtol+0x66>
  800bba:	eb 9e                	jmp    800b5a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bbc:	89 c2                	mov    %eax,%edx
  800bbe:	f7 da                	neg    %edx
  800bc0:	85 ff                	test   %edi,%edi
  800bc2:	0f 45 c2             	cmovne %edx,%eax
}
  800bc5:	5b                   	pop    %ebx
  800bc6:	5e                   	pop    %esi
  800bc7:	5f                   	pop    %edi
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    
  800bca:	66 90                	xchg   %ax,%ax
  800bcc:	66 90                	xchg   %ax,%ax
  800bce:	66 90                	xchg   %ax,%ax

00800bd0 <__udivdi3>:
  800bd0:	55                   	push   %ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 1c             	sub    $0x1c,%esp
  800bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800be7:	85 f6                	test   %esi,%esi
  800be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bed:	89 ca                	mov    %ecx,%edx
  800bef:	89 f8                	mov    %edi,%eax
  800bf1:	75 3d                	jne    800c30 <__udivdi3+0x60>
  800bf3:	39 cf                	cmp    %ecx,%edi
  800bf5:	0f 87 c5 00 00 00    	ja     800cc0 <__udivdi3+0xf0>
  800bfb:	85 ff                	test   %edi,%edi
  800bfd:	89 fd                	mov    %edi,%ebp
  800bff:	75 0b                	jne    800c0c <__udivdi3+0x3c>
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	31 d2                	xor    %edx,%edx
  800c08:	f7 f7                	div    %edi
  800c0a:	89 c5                	mov    %eax,%ebp
  800c0c:	89 c8                	mov    %ecx,%eax
  800c0e:	31 d2                	xor    %edx,%edx
  800c10:	f7 f5                	div    %ebp
  800c12:	89 c1                	mov    %eax,%ecx
  800c14:	89 d8                	mov    %ebx,%eax
  800c16:	89 cf                	mov    %ecx,%edi
  800c18:	f7 f5                	div    %ebp
  800c1a:	89 c3                	mov    %eax,%ebx
  800c1c:	89 d8                	mov    %ebx,%eax
  800c1e:	89 fa                	mov    %edi,%edx
  800c20:	83 c4 1c             	add    $0x1c,%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
  800c28:	90                   	nop
  800c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c30:	39 ce                	cmp    %ecx,%esi
  800c32:	77 74                	ja     800ca8 <__udivdi3+0xd8>
  800c34:	0f bd fe             	bsr    %esi,%edi
  800c37:	83 f7 1f             	xor    $0x1f,%edi
  800c3a:	0f 84 98 00 00 00    	je     800cd8 <__udivdi3+0x108>
  800c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  800c45:	89 f9                	mov    %edi,%ecx
  800c47:	89 c5                	mov    %eax,%ebp
  800c49:	29 fb                	sub    %edi,%ebx
  800c4b:	d3 e6                	shl    %cl,%esi
  800c4d:	89 d9                	mov    %ebx,%ecx
  800c4f:	d3 ed                	shr    %cl,%ebp
  800c51:	89 f9                	mov    %edi,%ecx
  800c53:	d3 e0                	shl    %cl,%eax
  800c55:	09 ee                	or     %ebp,%esi
  800c57:	89 d9                	mov    %ebx,%ecx
  800c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c5d:	89 d5                	mov    %edx,%ebp
  800c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c63:	d3 ed                	shr    %cl,%ebp
  800c65:	89 f9                	mov    %edi,%ecx
  800c67:	d3 e2                	shl    %cl,%edx
  800c69:	89 d9                	mov    %ebx,%ecx
  800c6b:	d3 e8                	shr    %cl,%eax
  800c6d:	09 c2                	or     %eax,%edx
  800c6f:	89 d0                	mov    %edx,%eax
  800c71:	89 ea                	mov    %ebp,%edx
  800c73:	f7 f6                	div    %esi
  800c75:	89 d5                	mov    %edx,%ebp
  800c77:	89 c3                	mov    %eax,%ebx
  800c79:	f7 64 24 0c          	mull   0xc(%esp)
  800c7d:	39 d5                	cmp    %edx,%ebp
  800c7f:	72 10                	jb     800c91 <__udivdi3+0xc1>
  800c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c85:	89 f9                	mov    %edi,%ecx
  800c87:	d3 e6                	shl    %cl,%esi
  800c89:	39 c6                	cmp    %eax,%esi
  800c8b:	73 07                	jae    800c94 <__udivdi3+0xc4>
  800c8d:	39 d5                	cmp    %edx,%ebp
  800c8f:	75 03                	jne    800c94 <__udivdi3+0xc4>
  800c91:	83 eb 01             	sub    $0x1,%ebx
  800c94:	31 ff                	xor    %edi,%edi
  800c96:	89 d8                	mov    %ebx,%eax
  800c98:	89 fa                	mov    %edi,%edx
  800c9a:	83 c4 1c             	add    $0x1c,%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    
  800ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ca8:	31 ff                	xor    %edi,%edi
  800caa:	31 db                	xor    %ebx,%ebx
  800cac:	89 d8                	mov    %ebx,%eax
  800cae:	89 fa                	mov    %edi,%edx
  800cb0:	83 c4 1c             	add    $0x1c,%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    
  800cb8:	90                   	nop
  800cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	89 d8                	mov    %ebx,%eax
  800cc2:	f7 f7                	div    %edi
  800cc4:	31 ff                	xor    %edi,%edi
  800cc6:	89 c3                	mov    %eax,%ebx
  800cc8:	89 d8                	mov    %ebx,%eax
  800cca:	89 fa                	mov    %edi,%edx
  800ccc:	83 c4 1c             	add    $0x1c,%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    
  800cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800cd8:	39 ce                	cmp    %ecx,%esi
  800cda:	72 0c                	jb     800ce8 <__udivdi3+0x118>
  800cdc:	31 db                	xor    %ebx,%ebx
  800cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ce2:	0f 87 34 ff ff ff    	ja     800c1c <__udivdi3+0x4c>
  800ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ced:	e9 2a ff ff ff       	jmp    800c1c <__udivdi3+0x4c>
  800cf2:	66 90                	xchg   %ax,%ax
  800cf4:	66 90                	xchg   %ax,%ax
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

00800d00 <__umoddi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d17:	85 d2                	test   %edx,%edx
  800d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d21:	89 f3                	mov    %esi,%ebx
  800d23:	89 3c 24             	mov    %edi,(%esp)
  800d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d2a:	75 1c                	jne    800d48 <__umoddi3+0x48>
  800d2c:	39 f7                	cmp    %esi,%edi
  800d2e:	76 50                	jbe    800d80 <__umoddi3+0x80>
  800d30:	89 c8                	mov    %ecx,%eax
  800d32:	89 f2                	mov    %esi,%edx
  800d34:	f7 f7                	div    %edi
  800d36:	89 d0                	mov    %edx,%eax
  800d38:	31 d2                	xor    %edx,%edx
  800d3a:	83 c4 1c             	add    $0x1c,%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
  800d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d48:	39 f2                	cmp    %esi,%edx
  800d4a:	89 d0                	mov    %edx,%eax
  800d4c:	77 52                	ja     800da0 <__umoddi3+0xa0>
  800d4e:	0f bd ea             	bsr    %edx,%ebp
  800d51:	83 f5 1f             	xor    $0x1f,%ebp
  800d54:	75 5a                	jne    800db0 <__umoddi3+0xb0>
  800d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800d5a:	0f 82 e0 00 00 00    	jb     800e40 <__umoddi3+0x140>
  800d60:	39 0c 24             	cmp    %ecx,(%esp)
  800d63:	0f 86 d7 00 00 00    	jbe    800e40 <__umoddi3+0x140>
  800d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d71:	83 c4 1c             	add    $0x1c,%esp
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	85 ff                	test   %edi,%edi
  800d82:	89 fd                	mov    %edi,%ebp
  800d84:	75 0b                	jne    800d91 <__umoddi3+0x91>
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	f7 f7                	div    %edi
  800d8f:	89 c5                	mov    %eax,%ebp
  800d91:	89 f0                	mov    %esi,%eax
  800d93:	31 d2                	xor    %edx,%edx
  800d95:	f7 f5                	div    %ebp
  800d97:	89 c8                	mov    %ecx,%eax
  800d99:	f7 f5                	div    %ebp
  800d9b:	89 d0                	mov    %edx,%eax
  800d9d:	eb 99                	jmp    800d38 <__umoddi3+0x38>
  800d9f:	90                   	nop
  800da0:	89 c8                	mov    %ecx,%eax
  800da2:	89 f2                	mov    %esi,%edx
  800da4:	83 c4 1c             	add    $0x1c,%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
  800dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800db0:	8b 34 24             	mov    (%esp),%esi
  800db3:	bf 20 00 00 00       	mov    $0x20,%edi
  800db8:	89 e9                	mov    %ebp,%ecx
  800dba:	29 ef                	sub    %ebp,%edi
  800dbc:	d3 e0                	shl    %cl,%eax
  800dbe:	89 f9                	mov    %edi,%ecx
  800dc0:	89 f2                	mov    %esi,%edx
  800dc2:	d3 ea                	shr    %cl,%edx
  800dc4:	89 e9                	mov    %ebp,%ecx
  800dc6:	09 c2                	or     %eax,%edx
  800dc8:	89 d8                	mov    %ebx,%eax
  800dca:	89 14 24             	mov    %edx,(%esp)
  800dcd:	89 f2                	mov    %esi,%edx
  800dcf:	d3 e2                	shl    %cl,%edx
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800ddb:	d3 e8                	shr    %cl,%eax
  800ddd:	89 e9                	mov    %ebp,%ecx
  800ddf:	89 c6                	mov    %eax,%esi
  800de1:	d3 e3                	shl    %cl,%ebx
  800de3:	89 f9                	mov    %edi,%ecx
  800de5:	89 d0                	mov    %edx,%eax
  800de7:	d3 e8                	shr    %cl,%eax
  800de9:	89 e9                	mov    %ebp,%ecx
  800deb:	09 d8                	or     %ebx,%eax
  800ded:	89 d3                	mov    %edx,%ebx
  800def:	89 f2                	mov    %esi,%edx
  800df1:	f7 34 24             	divl   (%esp)
  800df4:	89 d6                	mov    %edx,%esi
  800df6:	d3 e3                	shl    %cl,%ebx
  800df8:	f7 64 24 04          	mull   0x4(%esp)
  800dfc:	39 d6                	cmp    %edx,%esi
  800dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e02:	89 d1                	mov    %edx,%ecx
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	72 08                	jb     800e10 <__umoddi3+0x110>
  800e08:	75 11                	jne    800e1b <__umoddi3+0x11b>
  800e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e0e:	73 0b                	jae    800e1b <__umoddi3+0x11b>
  800e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e14:	1b 14 24             	sbb    (%esp),%edx
  800e17:	89 d1                	mov    %edx,%ecx
  800e19:	89 c3                	mov    %eax,%ebx
  800e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800e1f:	29 da                	sub    %ebx,%edx
  800e21:	19 ce                	sbb    %ecx,%esi
  800e23:	89 f9                	mov    %edi,%ecx
  800e25:	89 f0                	mov    %esi,%eax
  800e27:	d3 e0                	shl    %cl,%eax
  800e29:	89 e9                	mov    %ebp,%ecx
  800e2b:	d3 ea                	shr    %cl,%edx
  800e2d:	89 e9                	mov    %ebp,%ecx
  800e2f:	d3 ee                	shr    %cl,%esi
  800e31:	09 d0                	or     %edx,%eax
  800e33:	89 f2                	mov    %esi,%edx
  800e35:	83 c4 1c             	add    $0x1c,%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5f                   	pop    %edi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    
  800e3d:	8d 76 00             	lea    0x0(%esi),%esi
  800e40:	29 f9                	sub    %edi,%ecx
  800e42:	19 d6                	sbb    %edx,%esi
  800e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e4c:	e9 18 ff ff ff       	jmp    800d69 <__umoddi3+0x69>
