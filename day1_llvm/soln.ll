#define PTR(len, const) i8* getelementptr inbounds ([len x i8], [len x i8]* const, i32 0, i32 0)
#define STDOUT i64 1
#define SYSCALL_READ i64 0
#define SYSCALL_WRITE i64 1
#define SYSCALL_OPEN i64 2
#define SYSCALL_SEEK i64 8
#define SYSCALL_EXIT i64 60

#define HELLO_LEN 15
@.hello = constant [HELLO_LEN x i8] c"Hello, World!\0A\00"
;;@.input_filename = constant [6 x i8] c"input\00"
@.input_filename = constant [6 x i8] c"sampl\00"

define i32 @main() {
  #define PLUS 43
  entry:
    %fd = call i64 @open(PTR(6, @.input_filename))
    br label %loop
  loop:
    %sum = phi i64 [0, %entry], [%nextsum, %isnotend]
    %plusorminus = call i8 @getc(i64 %fd)
    %endcond = icmp eq i8 %plusorminus, -1
    br i1 %endcond, label %end, label %isnotend
  isnotend:
    %n = call i64 @getnum(i64 %fd)
    call i8 @getc(i64 %fd) ; this is the newline
    %nextsum = add i64 %sum, %n
    br label %loop
  end:
    ;; @putnum %sum
    call i64 @exit(i64 %sum)
    ret i32 0
}

; assumes that %fd is pointing to a number, this will return 0
; and seek backwards, really undefined behavior otherwise
define i64 @getnum(i64 %fd) {
  #define ZERO 48
  #define NINE 57
  entry:
    br label %loop
  loop:
    %acc = phi i64 [0, %entry], [%nextacc, %isnum]

    %n = call i8 @getc(i64 %fd)
    %cond1 = icmp sge i8 %n, ZERO
    %cond2 = icmp sle i8 %n, NINE
    %cond = and i1 %cond1, %cond2
    br i1 %cond, label %isnum, label %isnotnum
  isnum:
    %n1 = sub i8 %n, ZERO
    %n2 = sext i8 %n1 to i64
    %acc2 = mul i64 %acc, 10
    %nextacc = add i64 %acc2, %n2
    br label %loop
  isnotnum:
    call void @seek_rel(i64 %fd, i64 -1)
    ret i64 %acc
}

define void @seek_rel(i64 %fd, i64 %offset) {
  #define SEEK_CUR 1
  call i64 @syscall(
    SYSCALL_SEEK,
    i64 %fd,
    i64 %offset,
    i64 SEEK_CUR
  )
  ret void
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
  %num_read = call i64 @syscall(
    SYSCALL_READ,
    i64 %fd,
    i64 %bufptr,
    i64 LEN
  )
  %cmp = icmp ne i64 %num_read, 0
  br i1 %cmp, label %read, label %eof
  read:
    %value = load i8, i8* %buf
    ret i8 %value
  eof:
    ret i8 -1
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


