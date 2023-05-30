#define PTR(len, const) i8* getelementptr inbounds ([len x i8], [len x i8]* const, i32 0, i32 0)
#define STDOUT i64 1
#define SYSCALL_READ i64 0
#define SYSCALL_WRITE i64 1
#define SYSCALL_OPEN i64 2
#define SYSCALL_EXIT i64 60

#define HELLO_LEN 15
@.hello = constant [HELLO_LEN x i8] c"Hello, World!\0A\00"
@.input_filename = constant [6 x i8] c"input\00"

define i32 @main() {
entry:
  %fd = call i64 @open(PTR(6, @.input_filename))

  %c = call i8 @getc(i64 %fd)
  call void @putc(i8 %c)
  %d = call i8 @getc(i64 %fd)
  call void @putc(i8 %d)

  call i64 @syscall(
    SYSCALL_WRITE,
    STDOUT,
    i64 ptrtoint (PTR(HELLO_LEN, @.hello) to i64),
    i64 HELLO_LEN
  )
  call i64 @exit(i64 0)
  ret i32 0
}

define void @putc(i8 %c) {
  %buf = alloca i8
  store i8 %c, i8* %buf
  %bufptr = ptrtoint i8* %buf to i64
  #define LEN 1
  call i64 @syscall(
    SYSCALL_WRITE,
    STDOUT,
    i64 %bufptr,
    i64 LEN
  )
  ret void
}

define i8 @getc(i64 %fd) {
  %buf = alloca i8
  %bufptr = ptrtoint i8* %buf to i64
  #define LEN 1
  %ret = call i64 @syscall(
    SYSCALL_READ,
    i64 %fd,
    i64 %bufptr,
    i64 LEN
  )
  %value = load i8, i8* %buf
  ret i8 %value
}

define i64 @open(i8* %path) {
  %pathi64 = ptrtoint i8* %path to i64
  #define O_RDONLY 0
  %fd = call i64 @syscall(
    SYSCALL_OPEN,
    i64 %pathi64,
    i64 O_RDONLY,
    i64 0
  )
  ret i64 %fd
}

define i64 @exit(i64 %status) {
  call i64 @syscall(SYSCALL_EXIT, i64 %status, i64 0, i64 0)
  ret i64 0
}

declare i64 @syscall(i64, i64, i64, i64) 


