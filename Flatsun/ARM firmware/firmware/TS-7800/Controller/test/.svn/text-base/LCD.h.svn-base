
#define ENABLE_MASK   0x00100000
#define BASELINE_MASK 0x00080000
#define RS_MASK       0x00040000
#define BUSY_MASK     0x20000000


#define MIRROR_PINS

volatile unsigned int *lcd;

inline int getLCDbit(int n) {
#ifdef MIRROR_PINS
  switch (n) {
  case 3: n =4 ; break;
  case 4:  n =3 ; break;
  case 5: n =6 ; break;
  case 6: n =5 ; break;
  case 7: n =8 ; break;
  case 8: n =7 ; break;
  case 9: n =10 ; break;
  case 10: n =9 ; break;
  case 11: n =12 ; break;
  case 12: n =11 ; break;
  case 13: n =14 ; break;
  case 14: n =13 ; break;
 }
#endif
  return (*lcd >> (16+n-1)) & 1;
}

//inline
void putLCDbit(int n,int val) {
   volatile int i;
   unsigned int tmp;

#ifdef MIRROR_PINS
  switch (n) {
  case 3: n =4 ; break;
  case 4:  n =3 ; break;
  case 5: n =6 ; break;
  case 6: n =5 ; break;
  case 7: n =8 ; break;
  case 8: n =7 ; break;
  case 9: n =10 ; break;
  case 10: n =9 ; break;
  case 11: n =12 ; break;
  case 12: n =11 ; break;
  case 13: n =14 ; break;
  case 14: n =13 ; break;
 }
#endif
  if (val) {
    tmp = *(lcd+1);
    tmp |= (1 << (16+n-1));
    *(lcd+1) = tmp;
  } else {
    tmp = *(lcd+1);
    tmp &= ~(1 << (16+n-1));
    *(lcd+1) = tmp;
  }
  i = *(lcd+1); // force bus cycle to flush write now
  if (i != tmp) printf("put %X, got %X\n",tmp,i); // don't really need this
}

inline void lcd_instr(int i) {
  putLCDbit(4,!i);
}

inline void lcd_data_out(int data) {
  int i;
  for (i=0;i<8;i++) {
    putLCDbit(i+7,data & 1);
    data >>= 1;
  }
}

inline void lcd_write(int w) {
  if (!w) {
    lcd_data_out(0xFF);
  }
  putLCDbit(5,!w);
}

inline void lcd_enable(int e) {
  putLCDbit(6,e);
}

inline void lcd_wait_not_busy() {
  int i = 1000,val;
  volatile int ii;

  do {
    lcd_instr(1);
    lcd_write(0);
    for (ii=0;ii<10000;ii++); // wait 800nS minimum
    lcd_enable(1);
    for (ii=0;ii<10000;ii++); // wait 800nS minimum
    //usleep(10000);
    val = getLCDbit(14);
    lcd_enable(0);
    for (ii=0;ii<10000;ii++); // wait 800nS minimum
  } while (--i && val);
  if (i == 0) {
    printf("LCD timeout %X\n",val);
  }
}

inline void lcd_cmd(int cmd) {
  volatile int i;

  lcd_write(1);
  lcd_data_out(cmd);
  lcd_instr(1);
  for (i=0;i<1000;i++);
  lcd_enable(1);
  //usleep(10000);
  for (i=0;i<10000;i++);
  lcd_enable(0);
  lcd_wait_not_busy();
}

inline void lcd_data(int data) {
  volatile int i;

  lcd_data_out(data);
  lcd_instr(0);
  lcd_write(1);
  for (i=0;i<1000;i++);
  lcd_enable(1);
  for (i=0;i<10000;i++); // wait 800nS minimum
  //usleep(10000);
  lcd_enable(0);
  lcd_wait_not_busy();
}

inline void lcd_cmd_cls() {
  lcd_cmd(0x01);
}

#ifndef RW_REG
#define RW_REG(ptr) *(ptr + 0x08/sizeof(unsigned int))
#endif

lcd_init(volatile unsigned int *baseptr)
{
    RW_REG(baseptr) &= ~BASELINE_MASK; /* baseline should always be zero */

    lcd = baseptr + 1;

    lcd_cmd(0x38);
    lcd_cmd(0x38);
    lcd_cmd(0x38);
    lcd_cmd(0x6);
    lcd_cmd_cls();
    lcd_cmd(0xC);
    lcd_cmd(0x2);

    
}

#undef RW_REG

