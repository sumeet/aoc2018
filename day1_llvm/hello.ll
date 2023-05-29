#define PTR(len, const) i8* getelementptr inbounds ([len x i8], [len x i8]* const, i32 0, i32 0)
#define STDOUT i64 1
#define SYSCALL_WRITE i64 1
#define SYSCALL_EXIT i64 60

@.str = constant [15 x i8] c"Hello, World!\0A\00"

define i32 @main() {
entry:
  ; Write syscall
  %0 = call i64 @syscall(
      SYSCALL_WRITE,
      STDOUT,
      PTR(15, @.str),
      i64 15)
  call i64 @exit(i64 0)
  ret i32 0
}

define i64 @exit(i64 %status) {
  call i64 @syscall(SYSCALL_EXIT, i64 %status, i8* null, i64 0)
  ret i64 0
}

declare i64 @syscall(i64, i64, i8*, i64) 

