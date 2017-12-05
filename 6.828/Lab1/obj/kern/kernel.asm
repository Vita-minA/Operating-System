
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 00 19 10 f0       	push   $0xf0101900
f0100050:	e8 2b 09 00 00       	call   f0100980 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 f3 06 00 00       	call   f010076e <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 1c 19 10 f0       	push   $0xf010191c
f0100087:	e8 f4 08 00 00       	call   f0100980 <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 aa 13 00 00       	call   f010145b <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 9d 04 00 00       	call   f0100553 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 37 19 10 f0       	push   $0xf0101937
f01000c3:	e8 b8 08 00 00       	call   f0100980 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 1f 07 00 00       	call   f0100800 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 52 19 10 f0       	push   $0xf0101952
f0100110:	e8 6b 08 00 00       	call   f0100980 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 3b 08 00 00       	call   f010095a <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 8e 19 10 f0 	movl   $0xf010198e,(%esp)
f0100126:	e8 55 08 00 00       	call   f0100980 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 c8 06 00 00       	call   f0100800 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 6a 19 10 f0       	push   $0xf010196a
f0100152:	e8 29 08 00 00       	call   f0100980 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 f7 07 00 00       	call   f010095a <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 8e 19 10 f0 	movl   $0xf010198e,(%esp)
f010016a:	e8 11 08 00 00       	call   f0100980 <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f8 00 00 00    	je     f01002df <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001e7:	a8 20                	test   $0x20,%al
f01001e9:	0f 85 f6 00 00 00    	jne    f01002e5 <kbd_proc_data+0x10c>
f01001ef:	ba 60 00 00 00       	mov    $0x60,%edx
f01001f4:	ec                   	in     (%dx),%al
f01001f5:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f7:	3c e0                	cmp    $0xe0,%al
f01001f9:	75 0d                	jne    f0100208 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001fb:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f0100202:	b8 00 00 00 00       	mov    $0x0,%eax
f0100207:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100208:	55                   	push   %ebp
f0100209:	89 e5                	mov    %esp,%ebp
f010020b:	53                   	push   %ebx
f010020c:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010020f:	84 c0                	test   %al,%al
f0100211:	79 36                	jns    f0100249 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100213:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100219:	89 cb                	mov    %ecx,%ebx
f010021b:	83 e3 40             	and    $0x40,%ebx
f010021e:	83 e0 7f             	and    $0x7f,%eax
f0100221:	85 db                	test   %ebx,%ebx
f0100223:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100226:	0f b6 d2             	movzbl %dl,%edx
f0100229:	0f b6 82 e0 1a 10 f0 	movzbl -0xfefe520(%edx),%eax
f0100230:	83 c8 40             	or     $0x40,%eax
f0100233:	0f b6 c0             	movzbl %al,%eax
f0100236:	f7 d0                	not    %eax
f0100238:	21 c8                	and    %ecx,%eax
f010023a:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010023f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100244:	e9 a4 00 00 00       	jmp    f01002ed <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100249:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010024f:	f6 c1 40             	test   $0x40,%cl
f0100252:	74 0e                	je     f0100262 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100254:	83 c8 80             	or     $0xffffff80,%eax
f0100257:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100259:	83 e1 bf             	and    $0xffffffbf,%ecx
f010025c:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f0100262:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100265:	0f b6 82 e0 1a 10 f0 	movzbl -0xfefe520(%edx),%eax
f010026c:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f0100272:	0f b6 8a e0 19 10 f0 	movzbl -0xfefe620(%edx),%ecx
f0100279:	31 c8                	xor    %ecx,%eax
f010027b:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100280:	89 c1                	mov    %eax,%ecx
f0100282:	83 e1 03             	and    $0x3,%ecx
f0100285:	8b 0c 8d c0 19 10 f0 	mov    -0xfefe640(,%ecx,4),%ecx
f010028c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100290:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100293:	a8 08                	test   $0x8,%al
f0100295:	74 1b                	je     f01002b2 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100297:	89 da                	mov    %ebx,%edx
f0100299:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010029c:	83 f9 19             	cmp    $0x19,%ecx
f010029f:	77 05                	ja     f01002a6 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002a1:	83 eb 20             	sub    $0x20,%ebx
f01002a4:	eb 0c                	jmp    f01002b2 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002a6:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a9:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002ac:	83 fa 19             	cmp    $0x19,%edx
f01002af:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002b2:	f7 d0                	not    %eax
f01002b4:	a8 06                	test   $0x6,%al
f01002b6:	75 33                	jne    f01002eb <kbd_proc_data+0x112>
f01002b8:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002be:	75 2b                	jne    f01002eb <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002c0:	83 ec 0c             	sub    $0xc,%esp
f01002c3:	68 84 19 10 f0       	push   $0xf0101984
f01002c8:	e8 b3 06 00 00       	call   f0100980 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002cd:	ba 92 00 00 00       	mov    $0x92,%edx
f01002d2:	b8 03 00 00 00       	mov    $0x3,%eax
f01002d7:	ee                   	out    %al,(%dx)
f01002d8:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002db:	89 d8                	mov    %ebx,%eax
f01002dd:	eb 0e                	jmp    f01002ed <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002e4:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01002e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ea:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002eb:	89 d8                	mov    %ebx,%eax
}
f01002ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f0:	c9                   	leave  
f01002f1:	c3                   	ret    

f01002f2 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f2:	55                   	push   %ebp
f01002f3:	89 e5                	mov    %esp,%ebp
f01002f5:	57                   	push   %edi
f01002f6:	56                   	push   %esi
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 1c             	sub    $0x1c,%esp
f01002fb:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002fd:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100302:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100307:	b9 84 00 00 00       	mov    $0x84,%ecx
f010030c:	eb 09                	jmp    f0100317 <cons_putc+0x25>
f010030e:	89 ca                	mov    %ecx,%edx
f0100310:	ec                   	in     (%dx),%al
f0100311:	ec                   	in     (%dx),%al
f0100312:	ec                   	in     (%dx),%al
f0100313:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100314:	83 c3 01             	add    $0x1,%ebx
f0100317:	89 f2                	mov    %esi,%edx
f0100319:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031a:	a8 20                	test   $0x20,%al
f010031c:	75 08                	jne    f0100326 <cons_putc+0x34>
f010031e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100324:	7e e8                	jle    f010030e <cons_putc+0x1c>
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100330:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100331:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100336:	be 79 03 00 00       	mov    $0x379,%esi
f010033b:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100340:	eb 09                	jmp    f010034b <cons_putc+0x59>
f0100342:	89 ca                	mov    %ecx,%edx
f0100344:	ec                   	in     (%dx),%al
f0100345:	ec                   	in     (%dx),%al
f0100346:	ec                   	in     (%dx),%al
f0100347:	ec                   	in     (%dx),%al
f0100348:	83 c3 01             	add    $0x1,%ebx
f010034b:	89 f2                	mov    %esi,%edx
f010034d:	ec                   	in     (%dx),%al
f010034e:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100354:	7f 04                	jg     f010035a <cons_putc+0x68>
f0100356:	84 c0                	test   %al,%al
f0100358:	79 e8                	jns    f0100342 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035a:	ba 78 03 00 00       	mov    $0x378,%edx
f010035f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100363:	ee                   	out    %al,(%dx)
f0100364:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100369:	b8 0d 00 00 00       	mov    $0xd,%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b8 08 00 00 00       	mov    $0x8,%eax
f0100374:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100375:	89 fa                	mov    %edi,%edx
f0100377:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 07             	or     $0x7,%ah
f0100382:	85 d2                	test   %edx,%edx
f0100384:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100387:	89 f8                	mov    %edi,%eax
f0100389:	0f b6 c0             	movzbl %al,%eax
f010038c:	83 f8 09             	cmp    $0x9,%eax
f010038f:	74 74                	je     f0100405 <cons_putc+0x113>
f0100391:	83 f8 09             	cmp    $0x9,%eax
f0100394:	7f 0a                	jg     f01003a0 <cons_putc+0xae>
f0100396:	83 f8 08             	cmp    $0x8,%eax
f0100399:	74 14                	je     f01003af <cons_putc+0xbd>
f010039b:	e9 99 00 00 00       	jmp    f0100439 <cons_putc+0x147>
f01003a0:	83 f8 0a             	cmp    $0xa,%eax
f01003a3:	74 3a                	je     f01003df <cons_putc+0xed>
f01003a5:	83 f8 0d             	cmp    $0xd,%eax
f01003a8:	74 3d                	je     f01003e7 <cons_putc+0xf5>
f01003aa:	e9 8a 00 00 00       	jmp    f0100439 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003af:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003b6:	66 85 c0             	test   %ax,%ax
f01003b9:	0f 84 e6 00 00 00    	je     f01004a5 <cons_putc+0x1b3>
			crt_pos--;
f01003bf:	83 e8 01             	sub    $0x1,%eax
f01003c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003c8:	0f b7 c0             	movzwl %ax,%eax
f01003cb:	66 81 e7 00 ff       	and    $0xff00,%di
f01003d0:	83 cf 20             	or     $0x20,%edi
f01003d3:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003d9:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003dd:	eb 78                	jmp    f0100457 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003df:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003e6:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003e7:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003ee:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003f4:	c1 e8 16             	shr    $0x16,%eax
f01003f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003fa:	c1 e0 04             	shl    $0x4,%eax
f01003fd:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f0100403:	eb 52                	jmp    f0100457 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100405:	b8 20 00 00 00       	mov    $0x20,%eax
f010040a:	e8 e3 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 d9 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 cf fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 c5 fe ff ff       	call   f01002f2 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 bb fe ff ff       	call   f01002f2 <cons_putc>
f0100437:	eb 1e                	jmp    f0100457 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100439:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100440:	8d 50 01             	lea    0x1(%eax),%edx
f0100443:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010044a:	0f b7 c0             	movzwl %ax,%eax
f010044d:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100453:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100457:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010045e:	cf 07 
f0100460:	76 43                	jbe    f01004a5 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100462:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100467:	83 ec 04             	sub    $0x4,%esp
f010046a:	68 00 0f 00 00       	push   $0xf00
f010046f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100475:	52                   	push   %edx
f0100476:	50                   	push   %eax
f0100477:	e8 2c 10 00 00       	call   f01014a8 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010047c:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100482:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100488:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010048e:	83 c4 10             	add    $0x10,%esp
f0100491:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100496:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100499:	39 d0                	cmp    %edx,%eax
f010049b:	75 f4                	jne    f0100491 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010049d:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004a4:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004a5:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004ab:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004b0:	89 ca                	mov    %ecx,%edx
f01004b2:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004b3:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ba:	8d 71 01             	lea    0x1(%ecx),%esi
f01004bd:	89 d8                	mov    %ebx,%eax
f01004bf:	66 c1 e8 08          	shr    $0x8,%ax
f01004c3:	89 f2                	mov    %esi,%edx
f01004c5:	ee                   	out    %al,(%dx)
f01004c6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004cb:	89 ca                	mov    %ecx,%edx
f01004cd:	ee                   	out    %al,(%dx)
f01004ce:	89 d8                	mov    %ebx,%eax
f01004d0:	89 f2                	mov    %esi,%edx
f01004d2:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004d6:	5b                   	pop    %ebx
f01004d7:	5e                   	pop    %esi
f01004d8:	5f                   	pop    %edi
f01004d9:	5d                   	pop    %ebp
f01004da:	c3                   	ret    

f01004db <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004db:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004e2:	74 11                	je     f01004f5 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004e4:	55                   	push   %ebp
f01004e5:	89 e5                	mov    %esp,%ebp
f01004e7:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004ea:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004ef:	e8 a2 fc ff ff       	call   f0100196 <cons_intr>
}
f01004f4:	c9                   	leave  
f01004f5:	f3 c3                	repz ret 

f01004f7 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004f7:	55                   	push   %ebp
f01004f8:	89 e5                	mov    %esp,%ebp
f01004fa:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004fd:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f0100502:	e8 8f fc ff ff       	call   f0100196 <cons_intr>
}
f0100507:	c9                   	leave  
f0100508:	c3                   	ret    

f0100509 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100509:	55                   	push   %ebp
f010050a:	89 e5                	mov    %esp,%ebp
f010050c:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010050f:	e8 c7 ff ff ff       	call   f01004db <serial_intr>
	kbd_intr();
f0100514:	e8 de ff ff ff       	call   f01004f7 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100519:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010051e:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100524:	74 26                	je     f010054c <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100526:	8d 50 01             	lea    0x1(%eax),%edx
f0100529:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010052f:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100536:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100538:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010053e:	75 11                	jne    f0100551 <cons_getc+0x48>
			cons.rpos = 0;
f0100540:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100547:	00 00 00 
f010054a:	eb 05                	jmp    f0100551 <cons_getc+0x48>
		return c;
	}
	return 0;
f010054c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100551:	c9                   	leave  
f0100552:	c3                   	ret    

f0100553 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100553:	55                   	push   %ebp
f0100554:	89 e5                	mov    %esp,%ebp
f0100556:	57                   	push   %edi
f0100557:	56                   	push   %esi
f0100558:	53                   	push   %ebx
f0100559:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010055c:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100563:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010056a:	5a a5 
	if (*cp != 0xA55A) {
f010056c:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100573:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100577:	74 11                	je     f010058a <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100579:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100580:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100583:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100588:	eb 16                	jmp    f01005a0 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010058a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100591:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f0100598:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010059b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005a0:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005a6:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ab:	89 fa                	mov    %edi,%edx
f01005ad:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ae:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	89 da                	mov    %ebx,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	0f b6 c8             	movzbl %al,%ecx
f01005b7:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ba:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005bf:	89 fa                	mov    %edi,%edx
f01005c1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005c5:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005cb:	0f b6 c0             	movzbl %al,%eax
f01005ce:	09 c8                	or     %ecx,%eax
f01005d0:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d6:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005db:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e0:	89 f2                	mov    %esi,%edx
f01005e2:	ee                   	out    %al,(%dx)
f01005e3:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005f3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005f8:	89 da                	mov    %ebx,%edx
f01005fa:	ee                   	out    %al,(%dx)
f01005fb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100600:	b8 00 00 00 00       	mov    $0x0,%eax
f0100605:	ee                   	out    %al,(%dx)
f0100606:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010060b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100610:	ee                   	out    %al,(%dx)
f0100611:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100616:	b8 00 00 00 00       	mov    $0x0,%eax
f010061b:	ee                   	out    %al,(%dx)
f010061c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100621:	b8 01 00 00 00       	mov    $0x1,%eax
f0100626:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100627:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010062f:	3c ff                	cmp    $0xff,%al
f0100631:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100638:	89 f2                	mov    %esi,%edx
f010063a:	ec                   	in     (%dx),%al
f010063b:	89 da                	mov    %ebx,%edx
f010063d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010063e:	80 f9 ff             	cmp    $0xff,%cl
f0100641:	75 10                	jne    f0100653 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100643:	83 ec 0c             	sub    $0xc,%esp
f0100646:	68 90 19 10 f0       	push   $0xf0101990
f010064b:	e8 30 03 00 00       	call   f0100980 <cprintf>
f0100650:	83 c4 10             	add    $0x10,%esp
}
f0100653:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100656:	5b                   	pop    %ebx
f0100657:	5e                   	pop    %esi
f0100658:	5f                   	pop    %edi
f0100659:	5d                   	pop    %ebp
f010065a:	c3                   	ret    

f010065b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065b:	55                   	push   %ebp
f010065c:	89 e5                	mov    %esp,%ebp
f010065e:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100661:	8b 45 08             	mov    0x8(%ebp),%eax
f0100664:	e8 89 fc ff ff       	call   f01002f2 <cons_putc>
}
f0100669:	c9                   	leave  
f010066a:	c3                   	ret    

f010066b <getchar>:

int
getchar(void)
{
f010066b:	55                   	push   %ebp
f010066c:	89 e5                	mov    %esp,%ebp
f010066e:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100671:	e8 93 fe ff ff       	call   f0100509 <cons_getc>
f0100676:	85 c0                	test   %eax,%eax
f0100678:	74 f7                	je     f0100671 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010067a:	c9                   	leave  
f010067b:	c3                   	ret    

f010067c <iscons>:

int
iscons(int fdnum)
{
f010067c:	55                   	push   %ebp
f010067d:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010067f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100684:	5d                   	pop    %ebp
f0100685:	c3                   	ret    

f0100686 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
f0100689:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010068c:	68 e0 1b 10 f0       	push   $0xf0101be0
f0100691:	68 fe 1b 10 f0       	push   $0xf0101bfe
f0100696:	68 03 1c 10 f0       	push   $0xf0101c03
f010069b:	e8 e0 02 00 00       	call   f0100980 <cprintf>
f01006a0:	83 c4 0c             	add    $0xc,%esp
f01006a3:	68 b0 1c 10 f0       	push   $0xf0101cb0
f01006a8:	68 0c 1c 10 f0       	push   $0xf0101c0c
f01006ad:	68 03 1c 10 f0       	push   $0xf0101c03
f01006b2:	e8 c9 02 00 00       	call   f0100980 <cprintf>
	return 0;
}
f01006b7:	b8 00 00 00 00       	mov    $0x0,%eax
f01006bc:	c9                   	leave  
f01006bd:	c3                   	ret    

f01006be <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006be:	55                   	push   %ebp
f01006bf:	89 e5                	mov    %esp,%ebp
f01006c1:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006c4:	68 15 1c 10 f0       	push   $0xf0101c15
f01006c9:	e8 b2 02 00 00       	call   f0100980 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ce:	83 c4 08             	add    $0x8,%esp
f01006d1:	68 0c 00 10 00       	push   $0x10000c
f01006d6:	68 d8 1c 10 f0       	push   $0xf0101cd8
f01006db:	e8 a0 02 00 00       	call   f0100980 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006e0:	83 c4 0c             	add    $0xc,%esp
f01006e3:	68 0c 00 10 00       	push   $0x10000c
f01006e8:	68 0c 00 10 f0       	push   $0xf010000c
f01006ed:	68 00 1d 10 f0       	push   $0xf0101d00
f01006f2:	e8 89 02 00 00       	call   f0100980 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006f7:	83 c4 0c             	add    $0xc,%esp
f01006fa:	68 e1 18 10 00       	push   $0x1018e1
f01006ff:	68 e1 18 10 f0       	push   $0xf01018e1
f0100704:	68 24 1d 10 f0       	push   $0xf0101d24
f0100709:	e8 72 02 00 00       	call   f0100980 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010070e:	83 c4 0c             	add    $0xc,%esp
f0100711:	68 00 23 11 00       	push   $0x112300
f0100716:	68 00 23 11 f0       	push   $0xf0112300
f010071b:	68 48 1d 10 f0       	push   $0xf0101d48
f0100720:	e8 5b 02 00 00       	call   f0100980 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100725:	83 c4 0c             	add    $0xc,%esp
f0100728:	68 44 29 11 00       	push   $0x112944
f010072d:	68 44 29 11 f0       	push   $0xf0112944
f0100732:	68 6c 1d 10 f0       	push   $0xf0101d6c
f0100737:	e8 44 02 00 00       	call   f0100980 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010073c:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100741:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100746:	83 c4 08             	add    $0x8,%esp
f0100749:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010074e:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100754:	85 c0                	test   %eax,%eax
f0100756:	0f 48 c2             	cmovs  %edx,%eax
f0100759:	c1 f8 0a             	sar    $0xa,%eax
f010075c:	50                   	push   %eax
f010075d:	68 90 1d 10 f0       	push   $0xf0101d90
f0100762:	e8 19 02 00 00       	call   f0100980 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100767:	b8 00 00 00 00       	mov    $0x0,%eax
f010076c:	c9                   	leave  
f010076d:	c3                   	ret    

f010076e <mon_backtrace>:
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010076e:	55                   	push   %ebp
f010076f:	89 e5                	mov    %esp,%ebp
f0100771:	57                   	push   %edi
f0100772:	56                   	push   %esi
f0100773:	53                   	push   %ebx
f0100774:	83 ec 38             	sub    $0x38,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100777:	89 ee                	mov    %ebp,%esi
	// Your code here.
struct Eipdebuginfo info;
uint32_t *ebp = (uint32_t *) read_ebp();
cprintf("Stack backtrace:\n");
f0100779:	68 2e 1c 10 f0       	push   $0xf0101c2e
f010077e:	e8 fd 01 00 00       	call   f0100980 <cprintf>
while (ebp) {
f0100783:	83 c4 10             	add    $0x10,%esp
f0100786:	eb 67                	jmp    f01007ef <mon_backtrace+0x81>
    cprintf(" ebp %08x eip %08x args", ebp, ebp[1]);
f0100788:	83 ec 04             	sub    $0x4,%esp
f010078b:	ff 76 04             	pushl  0x4(%esi)
f010078e:	56                   	push   %esi
f010078f:	68 40 1c 10 f0       	push   $0xf0101c40
f0100794:	e8 e7 01 00 00       	call   f0100980 <cprintf>
f0100799:	8d 5e 08             	lea    0x8(%esi),%ebx
f010079c:	8d 7e 1c             	lea    0x1c(%esi),%edi
f010079f:	83 c4 10             	add    $0x10,%esp
    for (int j = 2; j != 7; ++j) {
        cprintf(" %08x", ebp[j]);   
f01007a2:	83 ec 08             	sub    $0x8,%esp
f01007a5:	ff 33                	pushl  (%ebx)
f01007a7:	68 58 1c 10 f0       	push   $0xf0101c58
f01007ac:	e8 cf 01 00 00       	call   f0100980 <cprintf>
f01007b1:	83 c3 04             	add    $0x4,%ebx
struct Eipdebuginfo info;
uint32_t *ebp = (uint32_t *) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp) {
    cprintf(" ebp %08x eip %08x args", ebp, ebp[1]);
    for (int j = 2; j != 7; ++j) {
f01007b4:	83 c4 10             	add    $0x10,%esp
f01007b7:	39 fb                	cmp    %edi,%ebx
f01007b9:	75 e7                	jne    f01007a2 <mon_backtrace+0x34>
        cprintf(" %08x", ebp[j]);   
    }
    debuginfo_eip(ebp[1], &info);
f01007bb:	83 ec 08             	sub    $0x8,%esp
f01007be:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01007c1:	50                   	push   %eax
f01007c2:	ff 76 04             	pushl  0x4(%esi)
f01007c5:	e8 c0 02 00 00       	call   f0100a8a <debuginfo_eip>
    cprintf("\n     %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ebp[1] - info.eip_fn_addr);
f01007ca:	83 c4 08             	add    $0x8,%esp
f01007cd:	8b 46 04             	mov    0x4(%esi),%eax
f01007d0:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01007d3:	50                   	push   %eax
f01007d4:	ff 75 d8             	pushl  -0x28(%ebp)
f01007d7:	ff 75 dc             	pushl  -0x24(%ebp)
f01007da:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007dd:	ff 75 d0             	pushl  -0x30(%ebp)
f01007e0:	68 5e 1c 10 f0       	push   $0xf0101c5e
f01007e5:	e8 96 01 00 00       	call   f0100980 <cprintf>
    ebp = (uint32_t *) (*ebp);
f01007ea:	8b 36                	mov    (%esi),%esi
f01007ec:	83 c4 20             	add    $0x20,%esp
{
	// Your code here.
struct Eipdebuginfo info;
uint32_t *ebp = (uint32_t *) read_ebp();
cprintf("Stack backtrace:\n");
while (ebp) {
f01007ef:	85 f6                	test   %esi,%esi
f01007f1:	75 95                	jne    f0100788 <mon_backtrace+0x1a>
    debuginfo_eip(ebp[1], &info);
    cprintf("\n     %s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, ebp[1] - info.eip_fn_addr);
    ebp = (uint32_t *) (*ebp);
}
	return 0;
}
f01007f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007fb:	5b                   	pop    %ebx
f01007fc:	5e                   	pop    %esi
f01007fd:	5f                   	pop    %edi
f01007fe:	5d                   	pop    %ebp
f01007ff:	c3                   	ret    

f0100800 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100800:	55                   	push   %ebp
f0100801:	89 e5                	mov    %esp,%ebp
f0100803:	57                   	push   %edi
f0100804:	56                   	push   %esi
f0100805:	53                   	push   %ebx
f0100806:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100809:	68 bc 1d 10 f0       	push   $0xf0101dbc
f010080e:	e8 6d 01 00 00       	call   f0100980 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100813:	c7 04 24 e0 1d 10 f0 	movl   $0xf0101de0,(%esp)
f010081a:	e8 61 01 00 00       	call   f0100980 <cprintf>
f010081f:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100822:	83 ec 0c             	sub    $0xc,%esp
f0100825:	68 74 1c 10 f0       	push   $0xf0101c74
f010082a:	e8 d5 09 00 00       	call   f0101204 <readline>
f010082f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100831:	83 c4 10             	add    $0x10,%esp
f0100834:	85 c0                	test   %eax,%eax
f0100836:	74 ea                	je     f0100822 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100838:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010083f:	be 00 00 00 00       	mov    $0x0,%esi
f0100844:	eb 0a                	jmp    f0100850 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100846:	c6 03 00             	movb   $0x0,(%ebx)
f0100849:	89 f7                	mov    %esi,%edi
f010084b:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010084e:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100850:	0f b6 03             	movzbl (%ebx),%eax
f0100853:	84 c0                	test   %al,%al
f0100855:	74 63                	je     f01008ba <monitor+0xba>
f0100857:	83 ec 08             	sub    $0x8,%esp
f010085a:	0f be c0             	movsbl %al,%eax
f010085d:	50                   	push   %eax
f010085e:	68 78 1c 10 f0       	push   $0xf0101c78
f0100863:	e8 b6 0b 00 00       	call   f010141e <strchr>
f0100868:	83 c4 10             	add    $0x10,%esp
f010086b:	85 c0                	test   %eax,%eax
f010086d:	75 d7                	jne    f0100846 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010086f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100872:	74 46                	je     f01008ba <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100874:	83 fe 0f             	cmp    $0xf,%esi
f0100877:	75 14                	jne    f010088d <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100879:	83 ec 08             	sub    $0x8,%esp
f010087c:	6a 10                	push   $0x10
f010087e:	68 7d 1c 10 f0       	push   $0xf0101c7d
f0100883:	e8 f8 00 00 00       	call   f0100980 <cprintf>
f0100888:	83 c4 10             	add    $0x10,%esp
f010088b:	eb 95                	jmp    f0100822 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f010088d:	8d 7e 01             	lea    0x1(%esi),%edi
f0100890:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100894:	eb 03                	jmp    f0100899 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100896:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100899:	0f b6 03             	movzbl (%ebx),%eax
f010089c:	84 c0                	test   %al,%al
f010089e:	74 ae                	je     f010084e <monitor+0x4e>
f01008a0:	83 ec 08             	sub    $0x8,%esp
f01008a3:	0f be c0             	movsbl %al,%eax
f01008a6:	50                   	push   %eax
f01008a7:	68 78 1c 10 f0       	push   $0xf0101c78
f01008ac:	e8 6d 0b 00 00       	call   f010141e <strchr>
f01008b1:	83 c4 10             	add    $0x10,%esp
f01008b4:	85 c0                	test   %eax,%eax
f01008b6:	74 de                	je     f0100896 <monitor+0x96>
f01008b8:	eb 94                	jmp    f010084e <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01008ba:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008c1:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008c2:	85 f6                	test   %esi,%esi
f01008c4:	0f 84 58 ff ff ff    	je     f0100822 <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ca:	83 ec 08             	sub    $0x8,%esp
f01008cd:	68 fe 1b 10 f0       	push   $0xf0101bfe
f01008d2:	ff 75 a8             	pushl  -0x58(%ebp)
f01008d5:	e8 e6 0a 00 00       	call   f01013c0 <strcmp>
f01008da:	83 c4 10             	add    $0x10,%esp
f01008dd:	85 c0                	test   %eax,%eax
f01008df:	74 1e                	je     f01008ff <monitor+0xff>
f01008e1:	83 ec 08             	sub    $0x8,%esp
f01008e4:	68 0c 1c 10 f0       	push   $0xf0101c0c
f01008e9:	ff 75 a8             	pushl  -0x58(%ebp)
f01008ec:	e8 cf 0a 00 00       	call   f01013c0 <strcmp>
f01008f1:	83 c4 10             	add    $0x10,%esp
f01008f4:	85 c0                	test   %eax,%eax
f01008f6:	75 2f                	jne    f0100927 <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008f8:	b8 01 00 00 00       	mov    $0x1,%eax
f01008fd:	eb 05                	jmp    f0100904 <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f01008ff:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100904:	83 ec 04             	sub    $0x4,%esp
f0100907:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010090a:	01 d0                	add    %edx,%eax
f010090c:	ff 75 08             	pushl  0x8(%ebp)
f010090f:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100912:	51                   	push   %ecx
f0100913:	56                   	push   %esi
f0100914:	ff 14 85 10 1e 10 f0 	call   *-0xfefe1f0(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010091b:	83 c4 10             	add    $0x10,%esp
f010091e:	85 c0                	test   %eax,%eax
f0100920:	78 1d                	js     f010093f <monitor+0x13f>
f0100922:	e9 fb fe ff ff       	jmp    f0100822 <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100927:	83 ec 08             	sub    $0x8,%esp
f010092a:	ff 75 a8             	pushl  -0x58(%ebp)
f010092d:	68 9a 1c 10 f0       	push   $0xf0101c9a
f0100932:	e8 49 00 00 00       	call   f0100980 <cprintf>
f0100937:	83 c4 10             	add    $0x10,%esp
f010093a:	e9 e3 fe ff ff       	jmp    f0100822 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010093f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100942:	5b                   	pop    %ebx
f0100943:	5e                   	pop    %esi
f0100944:	5f                   	pop    %edi
f0100945:	5d                   	pop    %ebp
f0100946:	c3                   	ret    

f0100947 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100947:	55                   	push   %ebp
f0100948:	89 e5                	mov    %esp,%ebp
f010094a:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010094d:	ff 75 08             	pushl  0x8(%ebp)
f0100950:	e8 06 fd ff ff       	call   f010065b <cputchar>
	*cnt++;
}
f0100955:	83 c4 10             	add    $0x10,%esp
f0100958:	c9                   	leave  
f0100959:	c3                   	ret    

f010095a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010095a:	55                   	push   %ebp
f010095b:	89 e5                	mov    %esp,%ebp
f010095d:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0100960:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100967:	ff 75 0c             	pushl  0xc(%ebp)
f010096a:	ff 75 08             	pushl  0x8(%ebp)
f010096d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100970:	50                   	push   %eax
f0100971:	68 47 09 10 f0       	push   $0xf0100947
f0100976:	e8 74 04 00 00       	call   f0100def <vprintfmt>
	return cnt;
}
f010097b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010097e:	c9                   	leave  
f010097f:	c3                   	ret    

f0100980 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100980:	55                   	push   %ebp
f0100981:	89 e5                	mov    %esp,%ebp
f0100983:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100986:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100989:	50                   	push   %eax
f010098a:	ff 75 08             	pushl  0x8(%ebp)
f010098d:	e8 c8 ff ff ff       	call   f010095a <vcprintf>
	va_end(ap);

	return cnt;
}
f0100992:	c9                   	leave  
f0100993:	c3                   	ret    

f0100994 <stab_binsearch>:
											//	will exit setting left = 118, right = 554.
											//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	int type, uintptr_t addr)
{
f0100994:	55                   	push   %ebp
f0100995:	89 e5                	mov    %esp,%ebp
f0100997:	57                   	push   %edi
f0100998:	56                   	push   %esi
f0100999:	53                   	push   %ebx
f010099a:	83 ec 14             	sub    $0x14,%esp
f010099d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009a3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009a6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009a9:	8b 1a                	mov    (%edx),%ebx
f01009ab:	8b 01                	mov    (%ecx),%eax
f01009ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009b0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009b7:	eb 7f                	jmp    f0100a38 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009bc:	01 d8                	add    %ebx,%eax
f01009be:	89 c6                	mov    %eax,%esi
f01009c0:	c1 ee 1f             	shr    $0x1f,%esi
f01009c3:	01 c6                	add    %eax,%esi
f01009c5:	d1 fe                	sar    %esi
f01009c7:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009ca:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009cd:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009d0:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009d2:	eb 03                	jmp    f01009d7 <stab_binsearch+0x43>
			m--;
f01009d4:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009d7:	39 c3                	cmp    %eax,%ebx
f01009d9:	7f 0d                	jg     f01009e8 <stab_binsearch+0x54>
f01009db:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009df:	83 ea 0c             	sub    $0xc,%edx
f01009e2:	39 f9                	cmp    %edi,%ecx
f01009e4:	75 ee                	jne    f01009d4 <stab_binsearch+0x40>
f01009e6:	eb 05                	jmp    f01009ed <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009e8:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01009eb:	eb 4b                	jmp    f0100a38 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009ed:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01009f0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009f3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01009f7:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01009fa:	76 11                	jbe    f0100a0d <stab_binsearch+0x79>
			*region_left = m;
f01009fc:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01009ff:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a01:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a04:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a0b:	eb 2b                	jmp    f0100a38 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		}
		else if (stabs[m].n_value > addr) {
f0100a0d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a10:	73 14                	jae    f0100a26 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a12:	83 e8 01             	sub    $0x1,%eax
f0100a15:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a18:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a1b:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a1d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a24:	eb 12                	jmp    f0100a38 <stab_binsearch+0xa4>
			r = m - 1;
		}
		else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a26:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a29:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a2b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a2f:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a31:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a38:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a3b:	0f 8e 78 ff ff ff    	jle    f01009b9 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a41:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a45:	75 0f                	jne    f0100a56 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a4a:	8b 00                	mov    (%eax),%eax
f0100a4c:	83 e8 01             	sub    $0x1,%eax
f0100a4f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a52:	89 06                	mov    %eax,(%esi)
f0100a54:	eb 2c                	jmp    f0100a82 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a56:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a59:	8b 00                	mov    (%eax),%eax
			l > *region_left && stabs[l].n_type != type;
f0100a5b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a5e:	8b 0e                	mov    (%esi),%ecx
f0100a60:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a63:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a66:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a69:	eb 03                	jmp    f0100a6e <stab_binsearch+0xda>
			l > *region_left && stabs[l].n_type != type;
			l--)
f0100a6b:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a6e:	39 c8                	cmp    %ecx,%eax
f0100a70:	7e 0b                	jle    f0100a7d <stab_binsearch+0xe9>
			l > *region_left && stabs[l].n_type != type;
f0100a72:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a76:	83 ea 0c             	sub    $0xc,%edx
f0100a79:	39 df                	cmp    %ebx,%edi
f0100a7b:	75 ee                	jne    f0100a6b <stab_binsearch+0xd7>
			l--)
			/* do nothing */;
		*region_left = l;
f0100a7d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a80:	89 06                	mov    %eax,(%esi)
	}
}
f0100a82:	83 c4 14             	add    $0x14,%esp
f0100a85:	5b                   	pop    %ebx
f0100a86:	5e                   	pop    %esi
f0100a87:	5f                   	pop    %edi
f0100a88:	5d                   	pop    %ebp
f0100a89:	c3                   	ret    

f0100a8a <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a8a:	55                   	push   %ebp
f0100a8b:	89 e5                	mov    %esp,%ebp
f0100a8d:	57                   	push   %edi
f0100a8e:	56                   	push   %esi
f0100a8f:	53                   	push   %ebx
f0100a90:	83 ec 3c             	sub    $0x3c,%esp
f0100a93:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a99:	c7 03 20 1e 10 f0    	movl   $0xf0101e20,(%ebx)
	info->eip_line = 0;
f0100a9f:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100aa6:	c7 43 08 20 1e 10 f0 	movl   $0xf0101e20,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100aad:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ab4:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ab7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100abe:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ac4:	76 11                	jbe    f0100ad7 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
		panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ac6:	b8 07 73 10 f0       	mov    $0xf0107307,%eax
f0100acb:	3d e9 59 10 f0       	cmp    $0xf01059e9,%eax
f0100ad0:	77 1c                	ja     f0100aee <debuginfo_eip+0x64>
f0100ad2:	e9 cc 01 00 00       	jmp    f0100ca3 <debuginfo_eip+0x219>
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	}
	else {
		// Can't search for user-level addresses yet!
		panic("User address");
f0100ad7:	83 ec 04             	sub    $0x4,%esp
f0100ada:	68 2a 1e 10 f0       	push   $0xf0101e2a
f0100adf:	68 82 00 00 00       	push   $0x82
f0100ae4:	68 37 1e 10 f0       	push   $0xf0101e37
f0100ae9:	e8 f8 f5 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100aee:	80 3d 06 73 10 f0 00 	cmpb   $0x0,0xf0107306
f0100af5:	0f 85 af 01 00 00    	jne    f0100caa <debuginfo_eip+0x220>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100afb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b02:	b8 e8 59 10 f0       	mov    $0xf01059e8,%eax
f0100b07:	2d 58 20 10 f0       	sub    $0xf0102058,%eax
f0100b0c:	c1 f8 02             	sar    $0x2,%eax
f0100b0f:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b15:	83 e8 01             	sub    $0x1,%eax
f0100b18:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b1b:	83 ec 08             	sub    $0x8,%esp
f0100b1e:	56                   	push   %esi
f0100b1f:	6a 64                	push   $0x64
f0100b21:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b24:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b27:	b8 58 20 10 f0       	mov    $0xf0102058,%eax
f0100b2c:	e8 63 fe ff ff       	call   f0100994 <stab_binsearch>
	if (lfile == 0)
f0100b31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b34:	83 c4 10             	add    $0x10,%esp
f0100b37:	85 c0                	test   %eax,%eax
f0100b39:	0f 84 72 01 00 00    	je     f0100cb1 <debuginfo_eip+0x227>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b42:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b45:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b48:	83 ec 08             	sub    $0x8,%esp
f0100b4b:	56                   	push   %esi
f0100b4c:	6a 24                	push   $0x24
f0100b4e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b51:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b54:	b8 58 20 10 f0       	mov    $0xf0102058,%eax
f0100b59:	e8 36 fe ff ff       	call   f0100994 <stab_binsearch>

	if (lfun <= rfun) {
f0100b5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b61:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b64:	83 c4 10             	add    $0x10,%esp
f0100b67:	39 d0                	cmp    %edx,%eax
f0100b69:	7f 40                	jg     f0100bab <debuginfo_eip+0x121>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b6b:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b6e:	c1 e1 02             	shl    $0x2,%ecx
f0100b71:	8d b9 58 20 10 f0    	lea    -0xfefdfa8(%ecx),%edi
f0100b77:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100b7a:	8b b9 58 20 10 f0    	mov    -0xfefdfa8(%ecx),%edi
f0100b80:	b9 07 73 10 f0       	mov    $0xf0107307,%ecx
f0100b85:	81 e9 e9 59 10 f0    	sub    $0xf01059e9,%ecx
f0100b8b:	39 cf                	cmp    %ecx,%edi
f0100b8d:	73 09                	jae    f0100b98 <debuginfo_eip+0x10e>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b8f:	81 c7 e9 59 10 f0    	add    $0xf01059e9,%edi
f0100b95:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b98:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100b9b:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100b9e:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100ba1:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100ba3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100ba6:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100ba9:	eb 0f                	jmp    f0100bba <debuginfo_eip+0x130>
	}
	else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bab:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bb1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bb7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bba:	83 ec 08             	sub    $0x8,%esp
f0100bbd:	6a 3a                	push   $0x3a
f0100bbf:	ff 73 08             	pushl  0x8(%ebx)
f0100bc2:	e8 78 08 00 00       	call   f010143f <strfind>
f0100bc7:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bca:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	info->eip_file = stabstr + stabs[lfile].n_strx;
f0100bcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bd0:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100bd3:	8b 04 85 58 20 10 f0 	mov    -0xfefdfa8(,%eax,4),%eax
f0100bda:	05 e9 59 10 f0       	add    $0xf01059e9,%eax
f0100bdf:	89 03                	mov    %eax,(%ebx)

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100be1:	83 c4 08             	add    $0x8,%esp
f0100be4:	56                   	push   %esi
f0100be5:	6a 44                	push   $0x44
f0100be7:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100bea:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100bed:	b8 58 20 10 f0       	mov    $0xf0102058,%eax
f0100bf2:	e8 9d fd ff ff       	call   f0100994 <stab_binsearch>
	if (lline > rline) {
f0100bf7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100bfa:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100bfd:	83 c4 10             	add    $0x10,%esp
f0100c00:	39 d0                	cmp    %edx,%eax
f0100c02:	0f 8f b0 00 00 00    	jg     f0100cb8 <debuginfo_eip+0x22e>
		return -1;
	}
	else {
		info->eip_line = stabs[rline].n_desc;
f0100c08:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c0b:	0f b7 14 95 5e 20 10 	movzwl -0xfefdfa2(,%edx,4),%edx
f0100c12:	f0 
f0100c13:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c19:	89 c2                	mov    %eax,%edx
f0100c1b:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100c1e:	8d 04 85 58 20 10 f0 	lea    -0xfefdfa8(,%eax,4),%eax
f0100c25:	eb 06                	jmp    f0100c2d <debuginfo_eip+0x1a3>
f0100c27:	83 ea 01             	sub    $0x1,%edx
f0100c2a:	83 e8 0c             	sub    $0xc,%eax
f0100c2d:	39 d7                	cmp    %edx,%edi
f0100c2f:	7f 34                	jg     f0100c65 <debuginfo_eip+0x1db>
		&& stabs[lline].n_type != N_SOL
f0100c31:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c35:	80 f9 84             	cmp    $0x84,%cl
f0100c38:	74 0b                	je     f0100c45 <debuginfo_eip+0x1bb>
		&& (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c3a:	80 f9 64             	cmp    $0x64,%cl
f0100c3d:	75 e8                	jne    f0100c27 <debuginfo_eip+0x19d>
f0100c3f:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c43:	74 e2                	je     f0100c27 <debuginfo_eip+0x19d>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c45:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c48:	8b 14 85 58 20 10 f0 	mov    -0xfefdfa8(,%eax,4),%edx
f0100c4f:	b8 07 73 10 f0       	mov    $0xf0107307,%eax
f0100c54:	2d e9 59 10 f0       	sub    $0xf01059e9,%eax
f0100c59:	39 c2                	cmp    %eax,%edx
f0100c5b:	73 08                	jae    f0100c65 <debuginfo_eip+0x1db>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c5d:	81 c2 e9 59 10 f0    	add    $0xf01059e9,%edx
f0100c63:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c65:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c68:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
			lline < rfun && stabs[lline].n_type == N_PSYM;
			lline++)
			info->eip_fn_narg++;

	return 0;
f0100c6b:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c70:	39 f2                	cmp    %esi,%edx
f0100c72:	7d 50                	jge    f0100cc4 <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
f0100c74:	83 c2 01             	add    $0x1,%edx
f0100c77:	89 d0                	mov    %edx,%eax
f0100c79:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c7c:	8d 14 95 58 20 10 f0 	lea    -0xfefdfa8(,%edx,4),%edx
f0100c83:	eb 04                	jmp    f0100c89 <debuginfo_eip+0x1ff>
			lline < rfun && stabs[lline].n_type == N_PSYM;
			lline++)
			info->eip_fn_narg++;
f0100c85:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c89:	39 c6                	cmp    %eax,%esi
f0100c8b:	7e 32                	jle    f0100cbf <debuginfo_eip+0x235>
			lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c8d:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c91:	83 c0 01             	add    $0x1,%eax
f0100c94:	83 c2 0c             	add    $0xc,%edx
f0100c97:	80 f9 a0             	cmp    $0xa0,%cl
f0100c9a:	74 e9                	je     f0100c85 <debuginfo_eip+0x1fb>
			lline++)
			info->eip_fn_narg++;

	return 0;
f0100c9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ca1:	eb 21                	jmp    f0100cc4 <debuginfo_eip+0x23a>
		panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100ca3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ca8:	eb 1a                	jmp    f0100cc4 <debuginfo_eip+0x23a>
f0100caa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100caf:	eb 13                	jmp    f0100cc4 <debuginfo_eip+0x23a>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cb1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cb6:	eb 0c                	jmp    f0100cc4 <debuginfo_eip+0x23a>
	// Your code here.
	info->eip_file = stabstr + stabs[lfile].n_strx;

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline) {
		return -1;
f0100cb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cbd:	eb 05                	jmp    f0100cc4 <debuginfo_eip+0x23a>
		for (lline = lfun + 1;
			lline < rfun && stabs[lline].n_type == N_PSYM;
			lline++)
			info->eip_fn_narg++;

	return 0;
f0100cbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cc7:	5b                   	pop    %ebx
f0100cc8:	5e                   	pop    %esi
f0100cc9:	5f                   	pop    %edi
f0100cca:	5d                   	pop    %ebp
f0100ccb:	c3                   	ret    

f0100ccc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ccc:	55                   	push   %ebp
f0100ccd:	89 e5                	mov    %esp,%ebp
f0100ccf:	57                   	push   %edi
f0100cd0:	56                   	push   %esi
f0100cd1:	53                   	push   %ebx
f0100cd2:	83 ec 1c             	sub    $0x1c,%esp
f0100cd5:	89 c7                	mov    %eax,%edi
f0100cd7:	89 d6                	mov    %edx,%esi
f0100cd9:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cdc:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cdf:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ce2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ce5:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ced:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100cf0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100cf3:	39 d3                	cmp    %edx,%ebx
f0100cf5:	72 05                	jb     f0100cfc <printnum+0x30>
f0100cf7:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100cfa:	77 45                	ja     f0100d41 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cfc:	83 ec 0c             	sub    $0xc,%esp
f0100cff:	ff 75 18             	pushl  0x18(%ebp)
f0100d02:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d05:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d08:	53                   	push   %ebx
f0100d09:	ff 75 10             	pushl  0x10(%ebp)
f0100d0c:	83 ec 08             	sub    $0x8,%esp
f0100d0f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d12:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d15:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d18:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d1b:	e8 40 09 00 00       	call   f0101660 <__udivdi3>
f0100d20:	83 c4 18             	add    $0x18,%esp
f0100d23:	52                   	push   %edx
f0100d24:	50                   	push   %eax
f0100d25:	89 f2                	mov    %esi,%edx
f0100d27:	89 f8                	mov    %edi,%eax
f0100d29:	e8 9e ff ff ff       	call   f0100ccc <printnum>
f0100d2e:	83 c4 20             	add    $0x20,%esp
f0100d31:	eb 18                	jmp    f0100d4b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d33:	83 ec 08             	sub    $0x8,%esp
f0100d36:	56                   	push   %esi
f0100d37:	ff 75 18             	pushl  0x18(%ebp)
f0100d3a:	ff d7                	call   *%edi
f0100d3c:	83 c4 10             	add    $0x10,%esp
f0100d3f:	eb 03                	jmp    f0100d44 <printnum+0x78>
f0100d41:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d44:	83 eb 01             	sub    $0x1,%ebx
f0100d47:	85 db                	test   %ebx,%ebx
f0100d49:	7f e8                	jg     f0100d33 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d4b:	83 ec 08             	sub    $0x8,%esp
f0100d4e:	56                   	push   %esi
f0100d4f:	83 ec 04             	sub    $0x4,%esp
f0100d52:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d55:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d58:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d5b:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d5e:	e8 2d 0a 00 00       	call   f0101790 <__umoddi3>
f0100d63:	83 c4 14             	add    $0x14,%esp
f0100d66:	0f be 80 45 1e 10 f0 	movsbl -0xfefe1bb(%eax),%eax
f0100d6d:	50                   	push   %eax
f0100d6e:	ff d7                	call   *%edi
}
f0100d70:	83 c4 10             	add    $0x10,%esp
f0100d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d76:	5b                   	pop    %ebx
f0100d77:	5e                   	pop    %esi
f0100d78:	5f                   	pop    %edi
f0100d79:	5d                   	pop    %ebp
f0100d7a:	c3                   	ret    

f0100d7b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d7b:	55                   	push   %ebp
f0100d7c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d7e:	83 fa 01             	cmp    $0x1,%edx
f0100d81:	7e 0e                	jle    f0100d91 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d83:	8b 10                	mov    (%eax),%edx
f0100d85:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d88:	89 08                	mov    %ecx,(%eax)
f0100d8a:	8b 02                	mov    (%edx),%eax
f0100d8c:	8b 52 04             	mov    0x4(%edx),%edx
f0100d8f:	eb 22                	jmp    f0100db3 <getuint+0x38>
	else if (lflag)
f0100d91:	85 d2                	test   %edx,%edx
f0100d93:	74 10                	je     f0100da5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d95:	8b 10                	mov    (%eax),%edx
f0100d97:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d9a:	89 08                	mov    %ecx,(%eax)
f0100d9c:	8b 02                	mov    (%edx),%eax
f0100d9e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100da3:	eb 0e                	jmp    f0100db3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100da5:	8b 10                	mov    (%eax),%edx
f0100da7:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100daa:	89 08                	mov    %ecx,(%eax)
f0100dac:	8b 02                	mov    (%edx),%eax
f0100dae:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100db3:	5d                   	pop    %ebp
f0100db4:	c3                   	ret    

f0100db5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100db5:	55                   	push   %ebp
f0100db6:	89 e5                	mov    %esp,%ebp
f0100db8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100dbb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100dbf:	8b 10                	mov    (%eax),%edx
f0100dc1:	3b 50 04             	cmp    0x4(%eax),%edx
f0100dc4:	73 0a                	jae    f0100dd0 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100dc6:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100dc9:	89 08                	mov    %ecx,(%eax)
f0100dcb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dce:	88 02                	mov    %al,(%edx)
}
f0100dd0:	5d                   	pop    %ebp
f0100dd1:	c3                   	ret    

f0100dd2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100dd2:	55                   	push   %ebp
f0100dd3:	89 e5                	mov    %esp,%ebp
f0100dd5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100dd8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100ddb:	50                   	push   %eax
f0100ddc:	ff 75 10             	pushl  0x10(%ebp)
f0100ddf:	ff 75 0c             	pushl  0xc(%ebp)
f0100de2:	ff 75 08             	pushl  0x8(%ebp)
f0100de5:	e8 05 00 00 00       	call   f0100def <vprintfmt>
	va_end(ap);
}
f0100dea:	83 c4 10             	add    $0x10,%esp
f0100ded:	c9                   	leave  
f0100dee:	c3                   	ret    

f0100def <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100def:	55                   	push   %ebp
f0100df0:	89 e5                	mov    %esp,%ebp
f0100df2:	57                   	push   %edi
f0100df3:	56                   	push   %esi
f0100df4:	53                   	push   %ebx
f0100df5:	83 ec 2c             	sub    $0x2c,%esp
f0100df8:	8b 75 08             	mov    0x8(%ebp),%esi
f0100dfb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100dfe:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e01:	eb 12                	jmp    f0100e15 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e03:	85 c0                	test   %eax,%eax
f0100e05:	0f 84 89 03 00 00    	je     f0101194 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100e0b:	83 ec 08             	sub    $0x8,%esp
f0100e0e:	53                   	push   %ebx
f0100e0f:	50                   	push   %eax
f0100e10:	ff d6                	call   *%esi
f0100e12:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e15:	83 c7 01             	add    $0x1,%edi
f0100e18:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e1c:	83 f8 25             	cmp    $0x25,%eax
f0100e1f:	75 e2                	jne    f0100e03 <vprintfmt+0x14>
f0100e21:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e25:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e2c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e33:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e3a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e3f:	eb 07                	jmp    f0100e48 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e41:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e44:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e48:	8d 47 01             	lea    0x1(%edi),%eax
f0100e4b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e4e:	0f b6 07             	movzbl (%edi),%eax
f0100e51:	0f b6 c8             	movzbl %al,%ecx
f0100e54:	83 e8 23             	sub    $0x23,%eax
f0100e57:	3c 55                	cmp    $0x55,%al
f0100e59:	0f 87 1a 03 00 00    	ja     f0101179 <vprintfmt+0x38a>
f0100e5f:	0f b6 c0             	movzbl %al,%eax
f0100e62:	ff 24 85 d4 1e 10 f0 	jmp    *-0xfefe12c(,%eax,4)
f0100e69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e6c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e70:	eb d6                	jmp    f0100e48 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e75:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e7a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e7d:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e80:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e84:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100e87:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100e8a:	83 fa 09             	cmp    $0x9,%edx
f0100e8d:	77 39                	ja     f0100ec8 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e8f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e92:	eb e9                	jmp    f0100e7d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e94:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e97:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e9a:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e9d:	8b 00                	mov    (%eax),%eax
f0100e9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ea2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100ea5:	eb 27                	jmp    f0100ece <vprintfmt+0xdf>
f0100ea7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100eaa:	85 c0                	test   %eax,%eax
f0100eac:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100eb1:	0f 49 c8             	cmovns %eax,%ecx
f0100eb4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100eba:	eb 8c                	jmp    f0100e48 <vprintfmt+0x59>
f0100ebc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100ebf:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100ec6:	eb 80                	jmp    f0100e48 <vprintfmt+0x59>
f0100ec8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ecb:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100ece:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ed2:	0f 89 70 ff ff ff    	jns    f0100e48 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100ed8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100edb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ede:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100ee5:	e9 5e ff ff ff       	jmp    f0100e48 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100eea:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100ef0:	e9 53 ff ff ff       	jmp    f0100e48 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ef5:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef8:	8d 50 04             	lea    0x4(%eax),%edx
f0100efb:	89 55 14             	mov    %edx,0x14(%ebp)
f0100efe:	83 ec 08             	sub    $0x8,%esp
f0100f01:	53                   	push   %ebx
f0100f02:	ff 30                	pushl  (%eax)
f0100f04:	ff d6                	call   *%esi
			break;
f0100f06:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100f0c:	e9 04 ff ff ff       	jmp    f0100e15 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f11:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f14:	8d 50 04             	lea    0x4(%eax),%edx
f0100f17:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f1a:	8b 00                	mov    (%eax),%eax
f0100f1c:	99                   	cltd   
f0100f1d:	31 d0                	xor    %edx,%eax
f0100f1f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f21:	83 f8 06             	cmp    $0x6,%eax
f0100f24:	7f 0b                	jg     f0100f31 <vprintfmt+0x142>
f0100f26:	8b 14 85 2c 20 10 f0 	mov    -0xfefdfd4(,%eax,4),%edx
f0100f2d:	85 d2                	test   %edx,%edx
f0100f2f:	75 18                	jne    f0100f49 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f31:	50                   	push   %eax
f0100f32:	68 5d 1e 10 f0       	push   $0xf0101e5d
f0100f37:	53                   	push   %ebx
f0100f38:	56                   	push   %esi
f0100f39:	e8 94 fe ff ff       	call   f0100dd2 <printfmt>
f0100f3e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f44:	e9 cc fe ff ff       	jmp    f0100e15 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f49:	52                   	push   %edx
f0100f4a:	68 66 1e 10 f0       	push   $0xf0101e66
f0100f4f:	53                   	push   %ebx
f0100f50:	56                   	push   %esi
f0100f51:	e8 7c fe ff ff       	call   f0100dd2 <printfmt>
f0100f56:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f5c:	e9 b4 fe ff ff       	jmp    f0100e15 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f61:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f64:	8d 50 04             	lea    0x4(%eax),%edx
f0100f67:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f6a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f6c:	85 ff                	test   %edi,%edi
f0100f6e:	b8 56 1e 10 f0       	mov    $0xf0101e56,%eax
f0100f73:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f76:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f7a:	0f 8e 94 00 00 00    	jle    f0101014 <vprintfmt+0x225>
f0100f80:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f84:	0f 84 98 00 00 00    	je     f0101022 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f8a:	83 ec 08             	sub    $0x8,%esp
f0100f8d:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f90:	57                   	push   %edi
f0100f91:	e8 5f 03 00 00       	call   f01012f5 <strnlen>
f0100f96:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f99:	29 c1                	sub    %eax,%ecx
f0100f9b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100f9e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100fa1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100fa5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fa8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100fab:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fad:	eb 0f                	jmp    f0100fbe <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100faf:	83 ec 08             	sub    $0x8,%esp
f0100fb2:	53                   	push   %ebx
f0100fb3:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fb6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fb8:	83 ef 01             	sub    $0x1,%edi
f0100fbb:	83 c4 10             	add    $0x10,%esp
f0100fbe:	85 ff                	test   %edi,%edi
f0100fc0:	7f ed                	jg     f0100faf <vprintfmt+0x1c0>
f0100fc2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fc5:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100fc8:	85 c9                	test   %ecx,%ecx
f0100fca:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fcf:	0f 49 c1             	cmovns %ecx,%eax
f0100fd2:	29 c1                	sub    %eax,%ecx
f0100fd4:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fd7:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fda:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fdd:	89 cb                	mov    %ecx,%ebx
f0100fdf:	eb 4d                	jmp    f010102e <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100fe1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fe5:	74 1b                	je     f0101002 <vprintfmt+0x213>
f0100fe7:	0f be c0             	movsbl %al,%eax
f0100fea:	83 e8 20             	sub    $0x20,%eax
f0100fed:	83 f8 5e             	cmp    $0x5e,%eax
f0100ff0:	76 10                	jbe    f0101002 <vprintfmt+0x213>
					putch('?', putdat);
f0100ff2:	83 ec 08             	sub    $0x8,%esp
f0100ff5:	ff 75 0c             	pushl  0xc(%ebp)
f0100ff8:	6a 3f                	push   $0x3f
f0100ffa:	ff 55 08             	call   *0x8(%ebp)
f0100ffd:	83 c4 10             	add    $0x10,%esp
f0101000:	eb 0d                	jmp    f010100f <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101002:	83 ec 08             	sub    $0x8,%esp
f0101005:	ff 75 0c             	pushl  0xc(%ebp)
f0101008:	52                   	push   %edx
f0101009:	ff 55 08             	call   *0x8(%ebp)
f010100c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010100f:	83 eb 01             	sub    $0x1,%ebx
f0101012:	eb 1a                	jmp    f010102e <vprintfmt+0x23f>
f0101014:	89 75 08             	mov    %esi,0x8(%ebp)
f0101017:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010101a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010101d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101020:	eb 0c                	jmp    f010102e <vprintfmt+0x23f>
f0101022:	89 75 08             	mov    %esi,0x8(%ebp)
f0101025:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101028:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010102b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010102e:	83 c7 01             	add    $0x1,%edi
f0101031:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101035:	0f be d0             	movsbl %al,%edx
f0101038:	85 d2                	test   %edx,%edx
f010103a:	74 23                	je     f010105f <vprintfmt+0x270>
f010103c:	85 f6                	test   %esi,%esi
f010103e:	78 a1                	js     f0100fe1 <vprintfmt+0x1f2>
f0101040:	83 ee 01             	sub    $0x1,%esi
f0101043:	79 9c                	jns    f0100fe1 <vprintfmt+0x1f2>
f0101045:	89 df                	mov    %ebx,%edi
f0101047:	8b 75 08             	mov    0x8(%ebp),%esi
f010104a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010104d:	eb 18                	jmp    f0101067 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010104f:	83 ec 08             	sub    $0x8,%esp
f0101052:	53                   	push   %ebx
f0101053:	6a 20                	push   $0x20
f0101055:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101057:	83 ef 01             	sub    $0x1,%edi
f010105a:	83 c4 10             	add    $0x10,%esp
f010105d:	eb 08                	jmp    f0101067 <vprintfmt+0x278>
f010105f:	89 df                	mov    %ebx,%edi
f0101061:	8b 75 08             	mov    0x8(%ebp),%esi
f0101064:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101067:	85 ff                	test   %edi,%edi
f0101069:	7f e4                	jg     f010104f <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010106b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010106e:	e9 a2 fd ff ff       	jmp    f0100e15 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101073:	83 fa 01             	cmp    $0x1,%edx
f0101076:	7e 16                	jle    f010108e <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101078:	8b 45 14             	mov    0x14(%ebp),%eax
f010107b:	8d 50 08             	lea    0x8(%eax),%edx
f010107e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101081:	8b 50 04             	mov    0x4(%eax),%edx
f0101084:	8b 00                	mov    (%eax),%eax
f0101086:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101089:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010108c:	eb 32                	jmp    f01010c0 <vprintfmt+0x2d1>
	else if (lflag)
f010108e:	85 d2                	test   %edx,%edx
f0101090:	74 18                	je     f01010aa <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101092:	8b 45 14             	mov    0x14(%ebp),%eax
f0101095:	8d 50 04             	lea    0x4(%eax),%edx
f0101098:	89 55 14             	mov    %edx,0x14(%ebp)
f010109b:	8b 00                	mov    (%eax),%eax
f010109d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a0:	89 c1                	mov    %eax,%ecx
f01010a2:	c1 f9 1f             	sar    $0x1f,%ecx
f01010a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010a8:	eb 16                	jmp    f01010c0 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01010aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ad:	8d 50 04             	lea    0x4(%eax),%edx
f01010b0:	89 55 14             	mov    %edx,0x14(%ebp)
f01010b3:	8b 00                	mov    (%eax),%eax
f01010b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010b8:	89 c1                	mov    %eax,%ecx
f01010ba:	c1 f9 1f             	sar    $0x1f,%ecx
f01010bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01010c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010c6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010cf:	79 74                	jns    f0101145 <vprintfmt+0x356>
				putch('-', putdat);
f01010d1:	83 ec 08             	sub    $0x8,%esp
f01010d4:	53                   	push   %ebx
f01010d5:	6a 2d                	push   $0x2d
f01010d7:	ff d6                	call   *%esi
				num = -(long long) num;
f01010d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010df:	f7 d8                	neg    %eax
f01010e1:	83 d2 00             	adc    $0x0,%edx
f01010e4:	f7 da                	neg    %edx
f01010e6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01010e9:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01010ee:	eb 55                	jmp    f0101145 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01010f0:	8d 45 14             	lea    0x14(%ebp),%eax
f01010f3:	e8 83 fc ff ff       	call   f0100d7b <getuint>
			base = 10;
f01010f8:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01010fd:	eb 46                	jmp    f0101145 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01010ff:	8d 45 14             	lea    0x14(%ebp),%eax
f0101102:	e8 74 fc ff ff       	call   f0100d7b <getuint>
			base = 8;
f0101107:	b9 08 00 00 00       	mov    $0x8,%ecx
                        goto number;
f010110c:	eb 37                	jmp    f0101145 <vprintfmt+0x356>
                        break;
		// pointer
		case 'p':
			putch('0', putdat);
f010110e:	83 ec 08             	sub    $0x8,%esp
f0101111:	53                   	push   %ebx
f0101112:	6a 30                	push   $0x30
f0101114:	ff d6                	call   *%esi
			putch('x', putdat);
f0101116:	83 c4 08             	add    $0x8,%esp
f0101119:	53                   	push   %ebx
f010111a:	6a 78                	push   $0x78
f010111c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010111e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101121:	8d 50 04             	lea    0x4(%eax),%edx
f0101124:	89 55 14             	mov    %edx,0x14(%ebp)
                        break;
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101127:	8b 00                	mov    (%eax),%eax
f0101129:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010112e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101131:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101136:	eb 0d                	jmp    f0101145 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101138:	8d 45 14             	lea    0x14(%ebp),%eax
f010113b:	e8 3b fc ff ff       	call   f0100d7b <getuint>
			base = 16;
f0101140:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101145:	83 ec 0c             	sub    $0xc,%esp
f0101148:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f010114c:	57                   	push   %edi
f010114d:	ff 75 e0             	pushl  -0x20(%ebp)
f0101150:	51                   	push   %ecx
f0101151:	52                   	push   %edx
f0101152:	50                   	push   %eax
f0101153:	89 da                	mov    %ebx,%edx
f0101155:	89 f0                	mov    %esi,%eax
f0101157:	e8 70 fb ff ff       	call   f0100ccc <printnum>
			break;
f010115c:	83 c4 20             	add    $0x20,%esp
f010115f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101162:	e9 ae fc ff ff       	jmp    f0100e15 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101167:	83 ec 08             	sub    $0x8,%esp
f010116a:	53                   	push   %ebx
f010116b:	51                   	push   %ecx
f010116c:	ff d6                	call   *%esi
			break;
f010116e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101171:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101174:	e9 9c fc ff ff       	jmp    f0100e15 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101179:	83 ec 08             	sub    $0x8,%esp
f010117c:	53                   	push   %ebx
f010117d:	6a 25                	push   $0x25
f010117f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101181:	83 c4 10             	add    $0x10,%esp
f0101184:	eb 03                	jmp    f0101189 <vprintfmt+0x39a>
f0101186:	83 ef 01             	sub    $0x1,%edi
f0101189:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010118d:	75 f7                	jne    f0101186 <vprintfmt+0x397>
f010118f:	e9 81 fc ff ff       	jmp    f0100e15 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101194:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101197:	5b                   	pop    %ebx
f0101198:	5e                   	pop    %esi
f0101199:	5f                   	pop    %edi
f010119a:	5d                   	pop    %ebp
f010119b:	c3                   	ret    

f010119c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010119c:	55                   	push   %ebp
f010119d:	89 e5                	mov    %esp,%ebp
f010119f:	83 ec 18             	sub    $0x18,%esp
f01011a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01011a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011a8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011ab:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01011af:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01011b2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011b9:	85 c0                	test   %eax,%eax
f01011bb:	74 26                	je     f01011e3 <vsnprintf+0x47>
f01011bd:	85 d2                	test   %edx,%edx
f01011bf:	7e 22                	jle    f01011e3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011c1:	ff 75 14             	pushl  0x14(%ebp)
f01011c4:	ff 75 10             	pushl  0x10(%ebp)
f01011c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011ca:	50                   	push   %eax
f01011cb:	68 b5 0d 10 f0       	push   $0xf0100db5
f01011d0:	e8 1a fc ff ff       	call   f0100def <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011d5:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011d8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011db:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011de:	83 c4 10             	add    $0x10,%esp
f01011e1:	eb 05                	jmp    f01011e8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011e8:	c9                   	leave  
f01011e9:	c3                   	ret    

f01011ea <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011ea:	55                   	push   %ebp
f01011eb:	89 e5                	mov    %esp,%ebp
f01011ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011f0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011f3:	50                   	push   %eax
f01011f4:	ff 75 10             	pushl  0x10(%ebp)
f01011f7:	ff 75 0c             	pushl  0xc(%ebp)
f01011fa:	ff 75 08             	pushl  0x8(%ebp)
f01011fd:	e8 9a ff ff ff       	call   f010119c <vsnprintf>
	va_end(ap);

	return rc;
}
f0101202:	c9                   	leave  
f0101203:	c3                   	ret    

f0101204 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101204:	55                   	push   %ebp
f0101205:	89 e5                	mov    %esp,%ebp
f0101207:	57                   	push   %edi
f0101208:	56                   	push   %esi
f0101209:	53                   	push   %ebx
f010120a:	83 ec 0c             	sub    $0xc,%esp
f010120d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101210:	85 c0                	test   %eax,%eax
f0101212:	74 11                	je     f0101225 <readline+0x21>
		cprintf("%s", prompt);
f0101214:	83 ec 08             	sub    $0x8,%esp
f0101217:	50                   	push   %eax
f0101218:	68 66 1e 10 f0       	push   $0xf0101e66
f010121d:	e8 5e f7 ff ff       	call   f0100980 <cprintf>
f0101222:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101225:	83 ec 0c             	sub    $0xc,%esp
f0101228:	6a 00                	push   $0x0
f010122a:	e8 4d f4 ff ff       	call   f010067c <iscons>
f010122f:	89 c7                	mov    %eax,%edi
f0101231:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101234:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101239:	e8 2d f4 ff ff       	call   f010066b <getchar>
f010123e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101240:	85 c0                	test   %eax,%eax
f0101242:	79 18                	jns    f010125c <readline+0x58>
			cprintf("read error: %e\n", c);
f0101244:	83 ec 08             	sub    $0x8,%esp
f0101247:	50                   	push   %eax
f0101248:	68 48 20 10 f0       	push   $0xf0102048
f010124d:	e8 2e f7 ff ff       	call   f0100980 <cprintf>
			return NULL;
f0101252:	83 c4 10             	add    $0x10,%esp
f0101255:	b8 00 00 00 00       	mov    $0x0,%eax
f010125a:	eb 79                	jmp    f01012d5 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010125c:	83 f8 08             	cmp    $0x8,%eax
f010125f:	0f 94 c2             	sete   %dl
f0101262:	83 f8 7f             	cmp    $0x7f,%eax
f0101265:	0f 94 c0             	sete   %al
f0101268:	08 c2                	or     %al,%dl
f010126a:	74 1a                	je     f0101286 <readline+0x82>
f010126c:	85 f6                	test   %esi,%esi
f010126e:	7e 16                	jle    f0101286 <readline+0x82>
			if (echoing)
f0101270:	85 ff                	test   %edi,%edi
f0101272:	74 0d                	je     f0101281 <readline+0x7d>
				cputchar('\b');
f0101274:	83 ec 0c             	sub    $0xc,%esp
f0101277:	6a 08                	push   $0x8
f0101279:	e8 dd f3 ff ff       	call   f010065b <cputchar>
f010127e:	83 c4 10             	add    $0x10,%esp
			i--;
f0101281:	83 ee 01             	sub    $0x1,%esi
f0101284:	eb b3                	jmp    f0101239 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101286:	83 fb 1f             	cmp    $0x1f,%ebx
f0101289:	7e 23                	jle    f01012ae <readline+0xaa>
f010128b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101291:	7f 1b                	jg     f01012ae <readline+0xaa>
			if (echoing)
f0101293:	85 ff                	test   %edi,%edi
f0101295:	74 0c                	je     f01012a3 <readline+0x9f>
				cputchar(c);
f0101297:	83 ec 0c             	sub    $0xc,%esp
f010129a:	53                   	push   %ebx
f010129b:	e8 bb f3 ff ff       	call   f010065b <cputchar>
f01012a0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01012a3:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012a9:	8d 76 01             	lea    0x1(%esi),%esi
f01012ac:	eb 8b                	jmp    f0101239 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01012ae:	83 fb 0a             	cmp    $0xa,%ebx
f01012b1:	74 05                	je     f01012b8 <readline+0xb4>
f01012b3:	83 fb 0d             	cmp    $0xd,%ebx
f01012b6:	75 81                	jne    f0101239 <readline+0x35>
			if (echoing)
f01012b8:	85 ff                	test   %edi,%edi
f01012ba:	74 0d                	je     f01012c9 <readline+0xc5>
				cputchar('\n');
f01012bc:	83 ec 0c             	sub    $0xc,%esp
f01012bf:	6a 0a                	push   $0xa
f01012c1:	e8 95 f3 ff ff       	call   f010065b <cputchar>
f01012c6:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012c9:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012d0:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012d8:	5b                   	pop    %ebx
f01012d9:	5e                   	pop    %esi
f01012da:	5f                   	pop    %edi
f01012db:	5d                   	pop    %ebp
f01012dc:	c3                   	ret    

f01012dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012dd:	55                   	push   %ebp
f01012de:	89 e5                	mov    %esp,%ebp
f01012e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e8:	eb 03                	jmp    f01012ed <strlen+0x10>
		n++;
f01012ea:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012f1:	75 f7                	jne    f01012ea <strlen+0xd>
		n++;
	return n;
}
f01012f3:	5d                   	pop    %ebp
f01012f4:	c3                   	ret    

f01012f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012f5:	55                   	push   %ebp
f01012f6:	89 e5                	mov    %esp,%ebp
f01012f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0101303:	eb 03                	jmp    f0101308 <strnlen+0x13>
		n++;
f0101305:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101308:	39 c2                	cmp    %eax,%edx
f010130a:	74 08                	je     f0101314 <strnlen+0x1f>
f010130c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101310:	75 f3                	jne    f0101305 <strnlen+0x10>
f0101312:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101314:	5d                   	pop    %ebp
f0101315:	c3                   	ret    

f0101316 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101316:	55                   	push   %ebp
f0101317:	89 e5                	mov    %esp,%ebp
f0101319:	53                   	push   %ebx
f010131a:	8b 45 08             	mov    0x8(%ebp),%eax
f010131d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101320:	89 c2                	mov    %eax,%edx
f0101322:	83 c2 01             	add    $0x1,%edx
f0101325:	83 c1 01             	add    $0x1,%ecx
f0101328:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010132c:	88 5a ff             	mov    %bl,-0x1(%edx)
f010132f:	84 db                	test   %bl,%bl
f0101331:	75 ef                	jne    f0101322 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101333:	5b                   	pop    %ebx
f0101334:	5d                   	pop    %ebp
f0101335:	c3                   	ret    

f0101336 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101336:	55                   	push   %ebp
f0101337:	89 e5                	mov    %esp,%ebp
f0101339:	53                   	push   %ebx
f010133a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010133d:	53                   	push   %ebx
f010133e:	e8 9a ff ff ff       	call   f01012dd <strlen>
f0101343:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101346:	ff 75 0c             	pushl  0xc(%ebp)
f0101349:	01 d8                	add    %ebx,%eax
f010134b:	50                   	push   %eax
f010134c:	e8 c5 ff ff ff       	call   f0101316 <strcpy>
	return dst;
}
f0101351:	89 d8                	mov    %ebx,%eax
f0101353:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101356:	c9                   	leave  
f0101357:	c3                   	ret    

f0101358 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101358:	55                   	push   %ebp
f0101359:	89 e5                	mov    %esp,%ebp
f010135b:	56                   	push   %esi
f010135c:	53                   	push   %ebx
f010135d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101360:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101363:	89 f3                	mov    %esi,%ebx
f0101365:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101368:	89 f2                	mov    %esi,%edx
f010136a:	eb 0f                	jmp    f010137b <strncpy+0x23>
		*dst++ = *src;
f010136c:	83 c2 01             	add    $0x1,%edx
f010136f:	0f b6 01             	movzbl (%ecx),%eax
f0101372:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101375:	80 39 01             	cmpb   $0x1,(%ecx)
f0101378:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010137b:	39 da                	cmp    %ebx,%edx
f010137d:	75 ed                	jne    f010136c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010137f:	89 f0                	mov    %esi,%eax
f0101381:	5b                   	pop    %ebx
f0101382:	5e                   	pop    %esi
f0101383:	5d                   	pop    %ebp
f0101384:	c3                   	ret    

f0101385 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101385:	55                   	push   %ebp
f0101386:	89 e5                	mov    %esp,%ebp
f0101388:	56                   	push   %esi
f0101389:	53                   	push   %ebx
f010138a:	8b 75 08             	mov    0x8(%ebp),%esi
f010138d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101390:	8b 55 10             	mov    0x10(%ebp),%edx
f0101393:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101395:	85 d2                	test   %edx,%edx
f0101397:	74 21                	je     f01013ba <strlcpy+0x35>
f0101399:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010139d:	89 f2                	mov    %esi,%edx
f010139f:	eb 09                	jmp    f01013aa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013a1:	83 c2 01             	add    $0x1,%edx
f01013a4:	83 c1 01             	add    $0x1,%ecx
f01013a7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01013aa:	39 c2                	cmp    %eax,%edx
f01013ac:	74 09                	je     f01013b7 <strlcpy+0x32>
f01013ae:	0f b6 19             	movzbl (%ecx),%ebx
f01013b1:	84 db                	test   %bl,%bl
f01013b3:	75 ec                	jne    f01013a1 <strlcpy+0x1c>
f01013b5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01013b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013ba:	29 f0                	sub    %esi,%eax
}
f01013bc:	5b                   	pop    %ebx
f01013bd:	5e                   	pop    %esi
f01013be:	5d                   	pop    %ebp
f01013bf:	c3                   	ret    

f01013c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013c0:	55                   	push   %ebp
f01013c1:	89 e5                	mov    %esp,%ebp
f01013c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013c9:	eb 06                	jmp    f01013d1 <strcmp+0x11>
		p++, q++;
f01013cb:	83 c1 01             	add    $0x1,%ecx
f01013ce:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013d1:	0f b6 01             	movzbl (%ecx),%eax
f01013d4:	84 c0                	test   %al,%al
f01013d6:	74 04                	je     f01013dc <strcmp+0x1c>
f01013d8:	3a 02                	cmp    (%edx),%al
f01013da:	74 ef                	je     f01013cb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013dc:	0f b6 c0             	movzbl %al,%eax
f01013df:	0f b6 12             	movzbl (%edx),%edx
f01013e2:	29 d0                	sub    %edx,%eax
}
f01013e4:	5d                   	pop    %ebp
f01013e5:	c3                   	ret    

f01013e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013e6:	55                   	push   %ebp
f01013e7:	89 e5                	mov    %esp,%ebp
f01013e9:	53                   	push   %ebx
f01013ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ed:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013f0:	89 c3                	mov    %eax,%ebx
f01013f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01013f5:	eb 06                	jmp    f01013fd <strncmp+0x17>
		n--, p++, q++;
f01013f7:	83 c0 01             	add    $0x1,%eax
f01013fa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013fd:	39 d8                	cmp    %ebx,%eax
f01013ff:	74 15                	je     f0101416 <strncmp+0x30>
f0101401:	0f b6 08             	movzbl (%eax),%ecx
f0101404:	84 c9                	test   %cl,%cl
f0101406:	74 04                	je     f010140c <strncmp+0x26>
f0101408:	3a 0a                	cmp    (%edx),%cl
f010140a:	74 eb                	je     f01013f7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010140c:	0f b6 00             	movzbl (%eax),%eax
f010140f:	0f b6 12             	movzbl (%edx),%edx
f0101412:	29 d0                	sub    %edx,%eax
f0101414:	eb 05                	jmp    f010141b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101416:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010141b:	5b                   	pop    %ebx
f010141c:	5d                   	pop    %ebp
f010141d:	c3                   	ret    

f010141e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010141e:	55                   	push   %ebp
f010141f:	89 e5                	mov    %esp,%ebp
f0101421:	8b 45 08             	mov    0x8(%ebp),%eax
f0101424:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101428:	eb 07                	jmp    f0101431 <strchr+0x13>
		if (*s == c)
f010142a:	38 ca                	cmp    %cl,%dl
f010142c:	74 0f                	je     f010143d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010142e:	83 c0 01             	add    $0x1,%eax
f0101431:	0f b6 10             	movzbl (%eax),%edx
f0101434:	84 d2                	test   %dl,%dl
f0101436:	75 f2                	jne    f010142a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101438:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010143d:	5d                   	pop    %ebp
f010143e:	c3                   	ret    

f010143f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010143f:	55                   	push   %ebp
f0101440:	89 e5                	mov    %esp,%ebp
f0101442:	8b 45 08             	mov    0x8(%ebp),%eax
f0101445:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101449:	eb 03                	jmp    f010144e <strfind+0xf>
f010144b:	83 c0 01             	add    $0x1,%eax
f010144e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101451:	38 ca                	cmp    %cl,%dl
f0101453:	74 04                	je     f0101459 <strfind+0x1a>
f0101455:	84 d2                	test   %dl,%dl
f0101457:	75 f2                	jne    f010144b <strfind+0xc>
			break;
	return (char *) s;
}
f0101459:	5d                   	pop    %ebp
f010145a:	c3                   	ret    

f010145b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010145b:	55                   	push   %ebp
f010145c:	89 e5                	mov    %esp,%ebp
f010145e:	57                   	push   %edi
f010145f:	56                   	push   %esi
f0101460:	53                   	push   %ebx
f0101461:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101464:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101467:	85 c9                	test   %ecx,%ecx
f0101469:	74 36                	je     f01014a1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010146b:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101471:	75 28                	jne    f010149b <memset+0x40>
f0101473:	f6 c1 03             	test   $0x3,%cl
f0101476:	75 23                	jne    f010149b <memset+0x40>
		c &= 0xFF;
f0101478:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010147c:	89 d3                	mov    %edx,%ebx
f010147e:	c1 e3 08             	shl    $0x8,%ebx
f0101481:	89 d6                	mov    %edx,%esi
f0101483:	c1 e6 18             	shl    $0x18,%esi
f0101486:	89 d0                	mov    %edx,%eax
f0101488:	c1 e0 10             	shl    $0x10,%eax
f010148b:	09 f0                	or     %esi,%eax
f010148d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010148f:	89 d8                	mov    %ebx,%eax
f0101491:	09 d0                	or     %edx,%eax
f0101493:	c1 e9 02             	shr    $0x2,%ecx
f0101496:	fc                   	cld    
f0101497:	f3 ab                	rep stos %eax,%es:(%edi)
f0101499:	eb 06                	jmp    f01014a1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010149b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010149e:	fc                   	cld    
f010149f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014a1:	89 f8                	mov    %edi,%eax
f01014a3:	5b                   	pop    %ebx
f01014a4:	5e                   	pop    %esi
f01014a5:	5f                   	pop    %edi
f01014a6:	5d                   	pop    %ebp
f01014a7:	c3                   	ret    

f01014a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014a8:	55                   	push   %ebp
f01014a9:	89 e5                	mov    %esp,%ebp
f01014ab:	57                   	push   %edi
f01014ac:	56                   	push   %esi
f01014ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01014b0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014b6:	39 c6                	cmp    %eax,%esi
f01014b8:	73 35                	jae    f01014ef <memmove+0x47>
f01014ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014bd:	39 d0                	cmp    %edx,%eax
f01014bf:	73 2e                	jae    f01014ef <memmove+0x47>
		s += n;
		d += n;
f01014c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014c4:	89 d6                	mov    %edx,%esi
f01014c6:	09 fe                	or     %edi,%esi
f01014c8:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014ce:	75 13                	jne    f01014e3 <memmove+0x3b>
f01014d0:	f6 c1 03             	test   $0x3,%cl
f01014d3:	75 0e                	jne    f01014e3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014d5:	83 ef 04             	sub    $0x4,%edi
f01014d8:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014db:	c1 e9 02             	shr    $0x2,%ecx
f01014de:	fd                   	std    
f01014df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014e1:	eb 09                	jmp    f01014ec <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014e3:	83 ef 01             	sub    $0x1,%edi
f01014e6:	8d 72 ff             	lea    -0x1(%edx),%esi
f01014e9:	fd                   	std    
f01014ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014ec:	fc                   	cld    
f01014ed:	eb 1d                	jmp    f010150c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014ef:	89 f2                	mov    %esi,%edx
f01014f1:	09 c2                	or     %eax,%edx
f01014f3:	f6 c2 03             	test   $0x3,%dl
f01014f6:	75 0f                	jne    f0101507 <memmove+0x5f>
f01014f8:	f6 c1 03             	test   $0x3,%cl
f01014fb:	75 0a                	jne    f0101507 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01014fd:	c1 e9 02             	shr    $0x2,%ecx
f0101500:	89 c7                	mov    %eax,%edi
f0101502:	fc                   	cld    
f0101503:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101505:	eb 05                	jmp    f010150c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101507:	89 c7                	mov    %eax,%edi
f0101509:	fc                   	cld    
f010150a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010150c:	5e                   	pop    %esi
f010150d:	5f                   	pop    %edi
f010150e:	5d                   	pop    %ebp
f010150f:	c3                   	ret    

f0101510 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101510:	55                   	push   %ebp
f0101511:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101513:	ff 75 10             	pushl  0x10(%ebp)
f0101516:	ff 75 0c             	pushl  0xc(%ebp)
f0101519:	ff 75 08             	pushl  0x8(%ebp)
f010151c:	e8 87 ff ff ff       	call   f01014a8 <memmove>
}
f0101521:	c9                   	leave  
f0101522:	c3                   	ret    

f0101523 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101523:	55                   	push   %ebp
f0101524:	89 e5                	mov    %esp,%ebp
f0101526:	56                   	push   %esi
f0101527:	53                   	push   %ebx
f0101528:	8b 45 08             	mov    0x8(%ebp),%eax
f010152b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010152e:	89 c6                	mov    %eax,%esi
f0101530:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101533:	eb 1a                	jmp    f010154f <memcmp+0x2c>
		if (*s1 != *s2)
f0101535:	0f b6 08             	movzbl (%eax),%ecx
f0101538:	0f b6 1a             	movzbl (%edx),%ebx
f010153b:	38 d9                	cmp    %bl,%cl
f010153d:	74 0a                	je     f0101549 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010153f:	0f b6 c1             	movzbl %cl,%eax
f0101542:	0f b6 db             	movzbl %bl,%ebx
f0101545:	29 d8                	sub    %ebx,%eax
f0101547:	eb 0f                	jmp    f0101558 <memcmp+0x35>
		s1++, s2++;
f0101549:	83 c0 01             	add    $0x1,%eax
f010154c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010154f:	39 f0                	cmp    %esi,%eax
f0101551:	75 e2                	jne    f0101535 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101553:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101558:	5b                   	pop    %ebx
f0101559:	5e                   	pop    %esi
f010155a:	5d                   	pop    %ebp
f010155b:	c3                   	ret    

f010155c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010155c:	55                   	push   %ebp
f010155d:	89 e5                	mov    %esp,%ebp
f010155f:	53                   	push   %ebx
f0101560:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0101563:	89 c1                	mov    %eax,%ecx
f0101565:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101568:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010156c:	eb 0a                	jmp    f0101578 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010156e:	0f b6 10             	movzbl (%eax),%edx
f0101571:	39 da                	cmp    %ebx,%edx
f0101573:	74 07                	je     f010157c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101575:	83 c0 01             	add    $0x1,%eax
f0101578:	39 c8                	cmp    %ecx,%eax
f010157a:	72 f2                	jb     f010156e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010157c:	5b                   	pop    %ebx
f010157d:	5d                   	pop    %ebp
f010157e:	c3                   	ret    

f010157f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010157f:	55                   	push   %ebp
f0101580:	89 e5                	mov    %esp,%ebp
f0101582:	57                   	push   %edi
f0101583:	56                   	push   %esi
f0101584:	53                   	push   %ebx
f0101585:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101588:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010158b:	eb 03                	jmp    f0101590 <strtol+0x11>
		s++;
f010158d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101590:	0f b6 01             	movzbl (%ecx),%eax
f0101593:	3c 20                	cmp    $0x20,%al
f0101595:	74 f6                	je     f010158d <strtol+0xe>
f0101597:	3c 09                	cmp    $0x9,%al
f0101599:	74 f2                	je     f010158d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010159b:	3c 2b                	cmp    $0x2b,%al
f010159d:	75 0a                	jne    f01015a9 <strtol+0x2a>
		s++;
f010159f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01015a2:	bf 00 00 00 00       	mov    $0x0,%edi
f01015a7:	eb 11                	jmp    f01015ba <strtol+0x3b>
f01015a9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01015ae:	3c 2d                	cmp    $0x2d,%al
f01015b0:	75 08                	jne    f01015ba <strtol+0x3b>
		s++, neg = 1;
f01015b2:	83 c1 01             	add    $0x1,%ecx
f01015b5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015ba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01015c0:	75 15                	jne    f01015d7 <strtol+0x58>
f01015c2:	80 39 30             	cmpb   $0x30,(%ecx)
f01015c5:	75 10                	jne    f01015d7 <strtol+0x58>
f01015c7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015cb:	75 7c                	jne    f0101649 <strtol+0xca>
		s += 2, base = 16;
f01015cd:	83 c1 02             	add    $0x2,%ecx
f01015d0:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015d5:	eb 16                	jmp    f01015ed <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01015d7:	85 db                	test   %ebx,%ebx
f01015d9:	75 12                	jne    f01015ed <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015db:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015e0:	80 39 30             	cmpb   $0x30,(%ecx)
f01015e3:	75 08                	jne    f01015ed <strtol+0x6e>
		s++, base = 8;
f01015e5:	83 c1 01             	add    $0x1,%ecx
f01015e8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01015ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01015f2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015f5:	0f b6 11             	movzbl (%ecx),%edx
f01015f8:	8d 72 d0             	lea    -0x30(%edx),%esi
f01015fb:	89 f3                	mov    %esi,%ebx
f01015fd:	80 fb 09             	cmp    $0x9,%bl
f0101600:	77 08                	ja     f010160a <strtol+0x8b>
			dig = *s - '0';
f0101602:	0f be d2             	movsbl %dl,%edx
f0101605:	83 ea 30             	sub    $0x30,%edx
f0101608:	eb 22                	jmp    f010162c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010160a:	8d 72 9f             	lea    -0x61(%edx),%esi
f010160d:	89 f3                	mov    %esi,%ebx
f010160f:	80 fb 19             	cmp    $0x19,%bl
f0101612:	77 08                	ja     f010161c <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101614:	0f be d2             	movsbl %dl,%edx
f0101617:	83 ea 57             	sub    $0x57,%edx
f010161a:	eb 10                	jmp    f010162c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010161c:	8d 72 bf             	lea    -0x41(%edx),%esi
f010161f:	89 f3                	mov    %esi,%ebx
f0101621:	80 fb 19             	cmp    $0x19,%bl
f0101624:	77 16                	ja     f010163c <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101626:	0f be d2             	movsbl %dl,%edx
f0101629:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010162c:	3b 55 10             	cmp    0x10(%ebp),%edx
f010162f:	7d 0b                	jge    f010163c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101631:	83 c1 01             	add    $0x1,%ecx
f0101634:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101638:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010163a:	eb b9                	jmp    f01015f5 <strtol+0x76>

	if (endptr)
f010163c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101640:	74 0d                	je     f010164f <strtol+0xd0>
		*endptr = (char *) s;
f0101642:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101645:	89 0e                	mov    %ecx,(%esi)
f0101647:	eb 06                	jmp    f010164f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101649:	85 db                	test   %ebx,%ebx
f010164b:	74 98                	je     f01015e5 <strtol+0x66>
f010164d:	eb 9e                	jmp    f01015ed <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010164f:	89 c2                	mov    %eax,%edx
f0101651:	f7 da                	neg    %edx
f0101653:	85 ff                	test   %edi,%edi
f0101655:	0f 45 c2             	cmovne %edx,%eax
}
f0101658:	5b                   	pop    %ebx
f0101659:	5e                   	pop    %esi
f010165a:	5f                   	pop    %edi
f010165b:	5d                   	pop    %ebp
f010165c:	c3                   	ret    
f010165d:	66 90                	xchg   %ax,%ax
f010165f:	90                   	nop

f0101660 <__udivdi3>:
f0101660:	55                   	push   %ebp
f0101661:	57                   	push   %edi
f0101662:	56                   	push   %esi
f0101663:	53                   	push   %ebx
f0101664:	83 ec 1c             	sub    $0x1c,%esp
f0101667:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010166b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010166f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101673:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101677:	85 f6                	test   %esi,%esi
f0101679:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010167d:	89 ca                	mov    %ecx,%edx
f010167f:	89 f8                	mov    %edi,%eax
f0101681:	75 3d                	jne    f01016c0 <__udivdi3+0x60>
f0101683:	39 cf                	cmp    %ecx,%edi
f0101685:	0f 87 c5 00 00 00    	ja     f0101750 <__udivdi3+0xf0>
f010168b:	85 ff                	test   %edi,%edi
f010168d:	89 fd                	mov    %edi,%ebp
f010168f:	75 0b                	jne    f010169c <__udivdi3+0x3c>
f0101691:	b8 01 00 00 00       	mov    $0x1,%eax
f0101696:	31 d2                	xor    %edx,%edx
f0101698:	f7 f7                	div    %edi
f010169a:	89 c5                	mov    %eax,%ebp
f010169c:	89 c8                	mov    %ecx,%eax
f010169e:	31 d2                	xor    %edx,%edx
f01016a0:	f7 f5                	div    %ebp
f01016a2:	89 c1                	mov    %eax,%ecx
f01016a4:	89 d8                	mov    %ebx,%eax
f01016a6:	89 cf                	mov    %ecx,%edi
f01016a8:	f7 f5                	div    %ebp
f01016aa:	89 c3                	mov    %eax,%ebx
f01016ac:	89 d8                	mov    %ebx,%eax
f01016ae:	89 fa                	mov    %edi,%edx
f01016b0:	83 c4 1c             	add    $0x1c,%esp
f01016b3:	5b                   	pop    %ebx
f01016b4:	5e                   	pop    %esi
f01016b5:	5f                   	pop    %edi
f01016b6:	5d                   	pop    %ebp
f01016b7:	c3                   	ret    
f01016b8:	90                   	nop
f01016b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016c0:	39 ce                	cmp    %ecx,%esi
f01016c2:	77 74                	ja     f0101738 <__udivdi3+0xd8>
f01016c4:	0f bd fe             	bsr    %esi,%edi
f01016c7:	83 f7 1f             	xor    $0x1f,%edi
f01016ca:	0f 84 98 00 00 00    	je     f0101768 <__udivdi3+0x108>
f01016d0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01016d5:	89 f9                	mov    %edi,%ecx
f01016d7:	89 c5                	mov    %eax,%ebp
f01016d9:	29 fb                	sub    %edi,%ebx
f01016db:	d3 e6                	shl    %cl,%esi
f01016dd:	89 d9                	mov    %ebx,%ecx
f01016df:	d3 ed                	shr    %cl,%ebp
f01016e1:	89 f9                	mov    %edi,%ecx
f01016e3:	d3 e0                	shl    %cl,%eax
f01016e5:	09 ee                	or     %ebp,%esi
f01016e7:	89 d9                	mov    %ebx,%ecx
f01016e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016ed:	89 d5                	mov    %edx,%ebp
f01016ef:	8b 44 24 08          	mov    0x8(%esp),%eax
f01016f3:	d3 ed                	shr    %cl,%ebp
f01016f5:	89 f9                	mov    %edi,%ecx
f01016f7:	d3 e2                	shl    %cl,%edx
f01016f9:	89 d9                	mov    %ebx,%ecx
f01016fb:	d3 e8                	shr    %cl,%eax
f01016fd:	09 c2                	or     %eax,%edx
f01016ff:	89 d0                	mov    %edx,%eax
f0101701:	89 ea                	mov    %ebp,%edx
f0101703:	f7 f6                	div    %esi
f0101705:	89 d5                	mov    %edx,%ebp
f0101707:	89 c3                	mov    %eax,%ebx
f0101709:	f7 64 24 0c          	mull   0xc(%esp)
f010170d:	39 d5                	cmp    %edx,%ebp
f010170f:	72 10                	jb     f0101721 <__udivdi3+0xc1>
f0101711:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101715:	89 f9                	mov    %edi,%ecx
f0101717:	d3 e6                	shl    %cl,%esi
f0101719:	39 c6                	cmp    %eax,%esi
f010171b:	73 07                	jae    f0101724 <__udivdi3+0xc4>
f010171d:	39 d5                	cmp    %edx,%ebp
f010171f:	75 03                	jne    f0101724 <__udivdi3+0xc4>
f0101721:	83 eb 01             	sub    $0x1,%ebx
f0101724:	31 ff                	xor    %edi,%edi
f0101726:	89 d8                	mov    %ebx,%eax
f0101728:	89 fa                	mov    %edi,%edx
f010172a:	83 c4 1c             	add    $0x1c,%esp
f010172d:	5b                   	pop    %ebx
f010172e:	5e                   	pop    %esi
f010172f:	5f                   	pop    %edi
f0101730:	5d                   	pop    %ebp
f0101731:	c3                   	ret    
f0101732:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101738:	31 ff                	xor    %edi,%edi
f010173a:	31 db                	xor    %ebx,%ebx
f010173c:	89 d8                	mov    %ebx,%eax
f010173e:	89 fa                	mov    %edi,%edx
f0101740:	83 c4 1c             	add    $0x1c,%esp
f0101743:	5b                   	pop    %ebx
f0101744:	5e                   	pop    %esi
f0101745:	5f                   	pop    %edi
f0101746:	5d                   	pop    %ebp
f0101747:	c3                   	ret    
f0101748:	90                   	nop
f0101749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101750:	89 d8                	mov    %ebx,%eax
f0101752:	f7 f7                	div    %edi
f0101754:	31 ff                	xor    %edi,%edi
f0101756:	89 c3                	mov    %eax,%ebx
f0101758:	89 d8                	mov    %ebx,%eax
f010175a:	89 fa                	mov    %edi,%edx
f010175c:	83 c4 1c             	add    $0x1c,%esp
f010175f:	5b                   	pop    %ebx
f0101760:	5e                   	pop    %esi
f0101761:	5f                   	pop    %edi
f0101762:	5d                   	pop    %ebp
f0101763:	c3                   	ret    
f0101764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101768:	39 ce                	cmp    %ecx,%esi
f010176a:	72 0c                	jb     f0101778 <__udivdi3+0x118>
f010176c:	31 db                	xor    %ebx,%ebx
f010176e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101772:	0f 87 34 ff ff ff    	ja     f01016ac <__udivdi3+0x4c>
f0101778:	bb 01 00 00 00       	mov    $0x1,%ebx
f010177d:	e9 2a ff ff ff       	jmp    f01016ac <__udivdi3+0x4c>
f0101782:	66 90                	xchg   %ax,%ax
f0101784:	66 90                	xchg   %ax,%ax
f0101786:	66 90                	xchg   %ax,%ax
f0101788:	66 90                	xchg   %ax,%ax
f010178a:	66 90                	xchg   %ax,%ax
f010178c:	66 90                	xchg   %ax,%ax
f010178e:	66 90                	xchg   %ax,%ax

f0101790 <__umoddi3>:
f0101790:	55                   	push   %ebp
f0101791:	57                   	push   %edi
f0101792:	56                   	push   %esi
f0101793:	53                   	push   %ebx
f0101794:	83 ec 1c             	sub    $0x1c,%esp
f0101797:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010179b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010179f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017a7:	85 d2                	test   %edx,%edx
f01017a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01017ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017b1:	89 f3                	mov    %esi,%ebx
f01017b3:	89 3c 24             	mov    %edi,(%esp)
f01017b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017ba:	75 1c                	jne    f01017d8 <__umoddi3+0x48>
f01017bc:	39 f7                	cmp    %esi,%edi
f01017be:	76 50                	jbe    f0101810 <__umoddi3+0x80>
f01017c0:	89 c8                	mov    %ecx,%eax
f01017c2:	89 f2                	mov    %esi,%edx
f01017c4:	f7 f7                	div    %edi
f01017c6:	89 d0                	mov    %edx,%eax
f01017c8:	31 d2                	xor    %edx,%edx
f01017ca:	83 c4 1c             	add    $0x1c,%esp
f01017cd:	5b                   	pop    %ebx
f01017ce:	5e                   	pop    %esi
f01017cf:	5f                   	pop    %edi
f01017d0:	5d                   	pop    %ebp
f01017d1:	c3                   	ret    
f01017d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017d8:	39 f2                	cmp    %esi,%edx
f01017da:	89 d0                	mov    %edx,%eax
f01017dc:	77 52                	ja     f0101830 <__umoddi3+0xa0>
f01017de:	0f bd ea             	bsr    %edx,%ebp
f01017e1:	83 f5 1f             	xor    $0x1f,%ebp
f01017e4:	75 5a                	jne    f0101840 <__umoddi3+0xb0>
f01017e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01017ea:	0f 82 e0 00 00 00    	jb     f01018d0 <__umoddi3+0x140>
f01017f0:	39 0c 24             	cmp    %ecx,(%esp)
f01017f3:	0f 86 d7 00 00 00    	jbe    f01018d0 <__umoddi3+0x140>
f01017f9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01017fd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101801:	83 c4 1c             	add    $0x1c,%esp
f0101804:	5b                   	pop    %ebx
f0101805:	5e                   	pop    %esi
f0101806:	5f                   	pop    %edi
f0101807:	5d                   	pop    %ebp
f0101808:	c3                   	ret    
f0101809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101810:	85 ff                	test   %edi,%edi
f0101812:	89 fd                	mov    %edi,%ebp
f0101814:	75 0b                	jne    f0101821 <__umoddi3+0x91>
f0101816:	b8 01 00 00 00       	mov    $0x1,%eax
f010181b:	31 d2                	xor    %edx,%edx
f010181d:	f7 f7                	div    %edi
f010181f:	89 c5                	mov    %eax,%ebp
f0101821:	89 f0                	mov    %esi,%eax
f0101823:	31 d2                	xor    %edx,%edx
f0101825:	f7 f5                	div    %ebp
f0101827:	89 c8                	mov    %ecx,%eax
f0101829:	f7 f5                	div    %ebp
f010182b:	89 d0                	mov    %edx,%eax
f010182d:	eb 99                	jmp    f01017c8 <__umoddi3+0x38>
f010182f:	90                   	nop
f0101830:	89 c8                	mov    %ecx,%eax
f0101832:	89 f2                	mov    %esi,%edx
f0101834:	83 c4 1c             	add    $0x1c,%esp
f0101837:	5b                   	pop    %ebx
f0101838:	5e                   	pop    %esi
f0101839:	5f                   	pop    %edi
f010183a:	5d                   	pop    %ebp
f010183b:	c3                   	ret    
f010183c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101840:	8b 34 24             	mov    (%esp),%esi
f0101843:	bf 20 00 00 00       	mov    $0x20,%edi
f0101848:	89 e9                	mov    %ebp,%ecx
f010184a:	29 ef                	sub    %ebp,%edi
f010184c:	d3 e0                	shl    %cl,%eax
f010184e:	89 f9                	mov    %edi,%ecx
f0101850:	89 f2                	mov    %esi,%edx
f0101852:	d3 ea                	shr    %cl,%edx
f0101854:	89 e9                	mov    %ebp,%ecx
f0101856:	09 c2                	or     %eax,%edx
f0101858:	89 d8                	mov    %ebx,%eax
f010185a:	89 14 24             	mov    %edx,(%esp)
f010185d:	89 f2                	mov    %esi,%edx
f010185f:	d3 e2                	shl    %cl,%edx
f0101861:	89 f9                	mov    %edi,%ecx
f0101863:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101867:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010186b:	d3 e8                	shr    %cl,%eax
f010186d:	89 e9                	mov    %ebp,%ecx
f010186f:	89 c6                	mov    %eax,%esi
f0101871:	d3 e3                	shl    %cl,%ebx
f0101873:	89 f9                	mov    %edi,%ecx
f0101875:	89 d0                	mov    %edx,%eax
f0101877:	d3 e8                	shr    %cl,%eax
f0101879:	89 e9                	mov    %ebp,%ecx
f010187b:	09 d8                	or     %ebx,%eax
f010187d:	89 d3                	mov    %edx,%ebx
f010187f:	89 f2                	mov    %esi,%edx
f0101881:	f7 34 24             	divl   (%esp)
f0101884:	89 d6                	mov    %edx,%esi
f0101886:	d3 e3                	shl    %cl,%ebx
f0101888:	f7 64 24 04          	mull   0x4(%esp)
f010188c:	39 d6                	cmp    %edx,%esi
f010188e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101892:	89 d1                	mov    %edx,%ecx
f0101894:	89 c3                	mov    %eax,%ebx
f0101896:	72 08                	jb     f01018a0 <__umoddi3+0x110>
f0101898:	75 11                	jne    f01018ab <__umoddi3+0x11b>
f010189a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010189e:	73 0b                	jae    f01018ab <__umoddi3+0x11b>
f01018a0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01018a4:	1b 14 24             	sbb    (%esp),%edx
f01018a7:	89 d1                	mov    %edx,%ecx
f01018a9:	89 c3                	mov    %eax,%ebx
f01018ab:	8b 54 24 08          	mov    0x8(%esp),%edx
f01018af:	29 da                	sub    %ebx,%edx
f01018b1:	19 ce                	sbb    %ecx,%esi
f01018b3:	89 f9                	mov    %edi,%ecx
f01018b5:	89 f0                	mov    %esi,%eax
f01018b7:	d3 e0                	shl    %cl,%eax
f01018b9:	89 e9                	mov    %ebp,%ecx
f01018bb:	d3 ea                	shr    %cl,%edx
f01018bd:	89 e9                	mov    %ebp,%ecx
f01018bf:	d3 ee                	shr    %cl,%esi
f01018c1:	09 d0                	or     %edx,%eax
f01018c3:	89 f2                	mov    %esi,%edx
f01018c5:	83 c4 1c             	add    $0x1c,%esp
f01018c8:	5b                   	pop    %ebx
f01018c9:	5e                   	pop    %esi
f01018ca:	5f                   	pop    %edi
f01018cb:	5d                   	pop    %ebp
f01018cc:	c3                   	ret    
f01018cd:	8d 76 00             	lea    0x0(%esi),%esi
f01018d0:	29 f9                	sub    %edi,%ecx
f01018d2:	19 d6                	sbb    %edx,%esi
f01018d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018dc:	e9 18 ff ff ff       	jmp    f01017f9 <__umoddi3+0x69>
