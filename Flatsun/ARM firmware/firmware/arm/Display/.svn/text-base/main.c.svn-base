#include "stm32f10x.h"
#include "Packet.h"
#include <string.h>
#include "font.h"

#define SPI_MASTER                   SPI1
#define SPI_MASTER_CLK               RCC_APB2Periph_SPI1
#define SPI_MASTER_GPIO              GPIOA
#define SPI_MASTER_GPIO_CLK          RCC_APB2Periph_GPIOA  
#define SPI_MASTER_PIN_SCK           GPIO_Pin_5
#define SPI_MASTER_PIN_MOSI          GPIO_Pin_7

#define  GPIOx                    GPIOD
#define  RCC_APB2Periph_GPIOx     RCC_APB2Periph_GPIOD
#define  GPIO_RTSPin              GPIO_Pin_4
#define  GPIO_CTSPin              GPIO_Pin_3
#define  GPIO_TxPin               GPIO_Pin_5
#define  GPIO_RxPin               GPIO_Pin_6

#define RS485_PORT                  GPIOB
#define RS485_USART                 USART1
#define RS485_USART_GPIO            GPIOA
            
#define RS485_USART_CLK             RCC_APB2Periph_USART1
#define RS485_USART_GPIO_CLK        RCC_APB2Periph_GPIOA
#define RS485_USART_TxPin           GPIO_Pin_9
#define RS485_USART_RxPin           GPIO_Pin_10

#define Rx_DMA_Channel              DMA1_Channel5
#define Rx_DMA_FLAG                 DMA1_FLAG_TC5

// #define CLOCK_CYCLES                1024
// #define CLOCK_CYCLES                2048
#define CLOCK_CYCLES                4096    // Default value

#define USE_WATCHDOG    0

void RCC_Configuration(void);
void NVIC_Configuration(void);
void DEMUX_Line(unsigned char line);
void LEDXLat(char state);
void AddressSelector_Init(void);
void RS485_Init();
void LED_Toggle(int led);

#define BufferSize       24
unsigned char SPI_MASTER_Buffer_Tx[BufferSize];
            
unsigned char LEDS[PIXEL_COUNT];
DisplayPacket   CommPacket;
int             CommPacket_Available = 0;
static volatile char BLANK_Set = 0;
static volatile int line = 0;
volatile unsigned int Address = 0;



void AddressSelector_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStructure;

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_6 | GPIO_Pin_7 | GPIO_Pin_8 | GPIO_Pin_9;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_IPU;
    GPIO_Init(GPIOB, &GPIO_InitStructure);
}

unsigned char AddressSelector_Data()
{
    unsigned int word;
    
    AddressSelector_Init();
    word = GPIOB->IDR;
    
    return (word >>  6) & 0xf;
}


void DMA1_Channel5_IRQHandler(void)
{
    DMA_ClearITPendingBit(DMA1_IT_GL5);
    USART_DMACmd(RS485_USART, USART_DMAReq_Rx, DISABLE);
    DMA_Cmd(Rx_DMA_Channel, DISABLE);
    // LED_Toggle(2);
    CommPacket_Available = 1;
}


void USART1_IRQHandler(void)
{
    unsigned short data;

    data = RS485_USART->DR;

    if ((data & 0x100) == 0x100) {
        if (CommPacket_Available == 0) {
            Rx_DMA_Channel->CNDTR = sizeof(DisplayPacket);
            RS485_USART->CR3 |= USART_DMAReq_Rx;
            Rx_DMA_Channel->CCR |= 1;
        }
        // LED_Toggle(1);
    }
}


void TIM3_IRQHandler(void)
{
    if (TIM_GetITStatus(TIM3, TIM_IT_CC1) != RESET) {
      TIM_ClearITPendingBit(TIM3, TIM_IT_CC1);
      GPIO_WriteBit(GPIOA, GPIO_Pin_6, Bit_SET);


      line = (line + 1) % 16;
      LEDXLat(TRUE);
      DEMUX_Line(line);
      LEDXLat(FALSE);

      GPIO_WriteBit(GPIOA, GPIO_Pin_6, Bit_SET);
      GPIO_WriteBit(GPIOA, GPIO_Pin_6, Bit_RESET);
      BLANK_Set = 1;
    }
}



void SetDotValue(unsigned char val)
{
    int i, byte_off, bit_off;
    unsigned char high_byte, low_byte;
    
    unsigned short offset = 0;
    
    for (i=0; i<BufferSize; i++) {
        SPI_MASTER_Buffer_Tx[i] = 0;
    }

    for (i=0 ; i<16; i++) {
        byte_off = offset / 8;
        bit_off = offset % 8;

        if (bit_off <= 2) {
            high_byte = val << (2 - bit_off);
            low_byte = 0;
        } else {
            high_byte = val >> (bit_off - 2);
            low_byte = val << (10 - bit_off);
        }
        SPI_MASTER_Buffer_Tx[byte_off] |= high_byte;
        SPI_MASTER_Buffer_Tx[byte_off + 1] |= low_byte;
        
        offset += 6;
    }
}

void FillBuffer(unsigned char block, unsigned char ln)
{
    int  offset, i, j;
    
    offset = 256 * block;
    offset += 16 * ln;
    
    j = 0;
    for (i=0; i<BufferSize; i++) SPI_MASTER_Buffer_Tx[i] = 0;

    for (i=0; i<BufferSize;) {
        unsigned short pixel1 = LEDS[offset + j] * 16;
        unsigned short pixel2 = LEDS[offset + j + 1] * 16;
        j += 2;
        SPI_MASTER_Buffer_Tx[i++] =     pixel1 >> 4;
        SPI_MASTER_Buffer_Tx[i++] =     (pixel1 & 0x0F) << 4 | pixel2 >> 8;
        SPI_MASTER_Buffer_Tx[i++] =     pixel2;
    }
}

void LED_Init()
{
    GPIO_InitTypeDef GPIO_InitStructure;
    
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_Out_PP;
    GPIO_Init(GPIOB, &GPIO_InitStructure);
}

void LED_On(int led)
{
    GPIOB->ODR &= ~(1 << (led+12));
}

void LED_Off(int led)
{
    GPIOB->ODR  |= (1 << (led+12));
}


void LED_Toggle(int led)
{
    GPIOB->ODR ^= (1 << (led+12));
}
void DEMUX_Init()
{
    GPIO_InitTypeDef GPIO_InitStructure;

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);
    
    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3 | GPIO_Pin_4;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_Out_PP;
    GPIO_Init(GPIOC, &GPIO_InitStructure);
}

void DEMUX_Enable(char state)
{
    if (state) {
        GPIOC->ODR &= ~(1 << 4);
    } else {
        GPIOC->ODR |= (1 << 4);
    }    
}

void DEMUX_Line(unsigned char ln)
{
    GPIOC->ODR = (GPIOC->ODR & 0xF0) | (ln & 0x0F);
}

void Driver_Init()
{
    GPIO_InitTypeDef GPIO_InitStructure;
    
    GPIO_InitStructure.GPIO_Pin   = SPI_MASTER_PIN_SCK | SPI_MASTER_PIN_MOSI;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_AF_PP;
    GPIO_Init(SPI_MASTER_GPIO, &GPIO_InitStructure);
}

void PixelClock_Init()
{
    GPIO_InitTypeDef            GPIO_InitStructure;
    TIM_TimeBaseInitTypeDef     TIM_TimeBaseStructure;
    TIM_OCInitTypeDef           TIM_OCInitStructure;


    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
    
    // GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_0  | GPIO_Pin_6;
    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_0;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_AF_PP;
    GPIO_Init(GPIOA, &GPIO_InitStructure);

    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_6;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_Out_PP;
    GPIO_Init(GPIOA, &GPIO_InitStructure);
    
    /* TIM2 + TIM3 clock enable */
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3, ENABLE);

    /* GPIOA and GPIOB clock enable */
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);
    
    /*
     *
     */
    
    /* Time base configuration */
    TIM_TimeBaseStructure.TIM_Period = 1;
    TIM_TimeBaseStructure.TIM_Prescaler = 2;
    TIM_TimeBaseStructure.TIM_ClockDivision = TIM_CKD_DIV1;
    TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
    TIM_TimeBaseInit(TIM2, &TIM_TimeBaseStructure);

    /* PWM1 Mode configuration: Channel1 */
    TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_Toggle;
    TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;
    TIM_OCInitStructure.TIM_Pulse = 0;
    TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_High;
    TIM_OC1Init(TIM2, &TIM_OCInitStructure);
    
    TIM_SelectMasterSlaveMode(TIM2, TIM_MasterSlaveMode_Enable);
    TIM_SelectOutputTrigger(TIM2, TIM_TRGOSource_Update);

    /*
     *
     */
    
    /* Time base configuration */
    TIM_TimeBaseStructure.TIM_Period = CLOCK_CYCLES;
    TIM_TimeBaseStructure.TIM_Prescaler = 1;
    TIM_TimeBaseStructure.TIM_ClockDivision = TIM_CKD_DIV1;
    TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
    TIM_TimeBaseInit(TIM3, &TIM_TimeBaseStructure);

    /* PWM1 Mode configuration: Channel1 */
    TIM_OCInitStructure.TIM_OCMode = TIM_OCMode_PWM1;
    // TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Enable;
    TIM_OCInitStructure.TIM_OutputState = TIM_OutputState_Disable;
    TIM_OCInitStructure.TIM_Pulse = 1;
    TIM_OCInitStructure.TIM_OCPolarity = TIM_OCPolarity_High;
    TIM_OC1Init(TIM3, &TIM_OCInitStructure);
    TIM_SelectSlaveMode(TIM3, TIM_SlaveMode_Gated);
    TIM_SelectInputTrigger(TIM3, TIM_TS_ITR1);
    
    TIM_ITConfig(TIM3, TIM_IT_CC1, ENABLE);

    TIM_ARRPreloadConfig(TIM2, ENABLE);
    TIM_Cmd(TIM2, ENABLE);

    TIM_ARRPreloadConfig(TIM3, ENABLE);
    TIM_Cmd(TIM3, ENABLE);
}

void LEDData_Init()
{
    GPIO_InitTypeDef GPIO_InitStructure;
    SPI_InitTypeDef SPI_InitStructure;

    /* Enable SPI_MASTER clock and GPIO clock for SPI_MASTER */
    RCC_APB2PeriphClockCmd(SPI_MASTER_GPIO_CLK | SPI_MASTER_CLK, ENABLE);
  
    /* Configure SPI_MASTER pins: SCK and MOSI */
    GPIO_InitStructure.GPIO_Pin   = SPI_MASTER_PIN_SCK | SPI_MASTER_PIN_MOSI;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_AF_PP;
    GPIO_Init(SPI_MASTER_GPIO, &GPIO_InitStructure);
  
      /* SPI_MASTER configuration ------------------------------------------------*/
    SPI_InitStructure.SPI_Direction = SPI_Direction_1Line_Tx;
    SPI_InitStructure.SPI_Mode = SPI_Mode_Master;
    SPI_InitStructure.SPI_DataSize = SPI_DataSize_8b;
    SPI_InitStructure.SPI_CPOL = SPI_CPOL_High;
    SPI_InitStructure.SPI_CPHA = SPI_CPHA_2Edge;
    SPI_InitStructure.SPI_NSS = SPI_NSS_Soft;
    SPI_InitStructure.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_8;
    SPI_InitStructure.SPI_FirstBit = SPI_FirstBit_MSB;
    SPI_InitStructure.SPI_CRCPolynomial = 7;
    SPI_Init(SPI_MASTER, &SPI_InitStructure);

    SPI_Cmd(SPI_MASTER, ENABLE);
    
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);
    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_5 | GPIO_Pin_6;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_Out_PP;
    GPIO_Init(GPIOC, &GPIO_InitStructure);

}

void Init()
{
    GPIO_InitTypeDef GPIO_InitStructure;
    
    RCC_Configuration();
    
    /* NVIC Configuration */
    NVIC_Configuration();


    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOB |
                           RCC_APB2Periph_GPIOC | RCC_APB2Periph_GPIOD
                           , ENABLE);

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;
    GPIO_Init(GPIOA, &GPIO_InitStructure);
    GPIO_Init(GPIOB, &GPIO_InitStructure);
    GPIO_Init(GPIOC, &GPIO_InitStructure);
    GPIO_Init(GPIOD, &GPIO_InitStructure);

    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOB |
                           RCC_APB2Periph_GPIOC | RCC_APB2Periph_GPIOD 
                           , DISABLE);  

     /* Enable CRC clock */
     RCC_AHBPeriphClockCmd(RCC_AHBPeriph_CRC, ENABLE);

     DEMUX_Init();
     LED_Init();
     LEDData_Init();
     PixelClock_Init();
     AddressSelector_Init();
}



void UpdateLEDDot()
{
    int TxIdx = 0;

    while (SPI_I2S_GetFlagStatus(SPI_MASTER, SPI_I2S_FLAG_TXE) == RESET);
    while (TxIdx < 12) {
        SPI_I2S_SendData(SPI_MASTER, SPI_MASTER_Buffer_Tx[TxIdx++]);
        while (SPI_I2S_GetFlagStatus(SPI_MASTER, SPI_I2S_FLAG_TXE) == RESET);
    }
}

void UpdateLED()
{
    int TxIdx = 0;
    
    /* Transfer procedure */
    while (SPI_I2S_GetFlagStatus(SPI_MASTER, SPI_I2S_FLAG_TXE) == RESET);
    while (TxIdx < BufferSize) {
        SPI_I2S_SendData(SPI_MASTER, SPI_MASTER_Buffer_Tx[TxIdx++]);
        while (SPI_I2S_GetFlagStatus(SPI_MASTER, SPI_I2S_FLAG_TXE) == RESET);
    }
}

void LEDMode(char state)
{
    GPIO_WriteBit(GPIOC, GPIO_Pin_6, (state ? Bit_SET : Bit_RESET));
}

void LEDXLat(char state)
{
    GPIO_WriteBit(GPIOC, GPIO_Pin_5, (state ? Bit_SET : Bit_RESET));
}

void LED_Set(unsigned char val)
{
	int i;
    for (i=0; i<PIXEL_COUNT; i++) {
        LEDS[i] = val;
    }
}

#if 0
void UpdateAnim()
{
    static int dir = 1;
    static int delay = 0;
    static int k = 0;
    // static int val = 0;
    int p;

    delay ++;
    if (delay < 100) return;
    delay = 0;
    
    for (p=0; p<PIXEL_COUNT; p++) {
        // LEDS[p] = val;
        #if 1
        if (p == k) {
            LEDS[p] = 255;
        } else {
            LEDS[p] = 0;
        }
        #endif
    }
    #if 0
    val += dir;
    if (val == 256 || val == 0) {
        dir = -dir;
        val += dir;
        val += dir;
    }
    #endif
    
    #if 1
    k += dir;
    if (k == 64 || k == 0) {
        dir = -dir;
        k += dir;
        k += dir;
    }
    #endif
}
#else

void UpdateAnim(int value)
{
    static int val = 0;
    static int dir = 1;
    static int delay = 250;
    static int k = 0;
    
    delay ++;
    if (delay < 250) return;
    delay = 0;
    int i, x, y;
    i = 0;
    
    for (y=0; y<32; y++) {
        // i = 3 - i;
        for (x=0; x<32; x++) {
            char on = TRUE;
                if (y % 2 == 0) {
                    if (x % 2 == 0){}
                        // on = FALSE;
                } else {
                    if (x % 2 == 1) {}
                        // on = FALSE;
                }
                if (on) {
                        LEDS[y * 32 + x] = value;
                } else {
                        LEDS[y * 32 + x] = 0;
                }
            LEDS[y * 32 + x] = 255;
        }
    }
    return;

#if 1   
    
    for (y=0; y<32; y++) {
        i = 3 - i;
        for (x=0; x<32; x++) {
            // LEDS[y * 32 + x] = (x + i) % 2 ? val : 255 - val;
            if (y == k) {
                LEDS[y * 32 + x] =val;
            } else {
                LEDS[y * 32 + x] =0;
            }
        }
    }
            k ++;
            if (k == 32) k = 0;
//    for (i=0; i<PIXEL_COUNT;) {
//        LEDS[i++] = val;
//        LEDS[i++] = 255 - val;
//    }
    val = val + dir;
    if (val == 0 || val == 70) dir = -dir;
#endif
}

#endif

extern const struct bitmap_font font;
void DrawChar(char c)
{
    int i, x, y;
    for (i=0; i<font.Chars; i++) {
        if (c == font.Index[i]) break;
    }
    if (i == font.Chars) return;
    unsigned char * bitmap = (unsigned char *) font.Bitmap;
    
    int boff = i * 32;  /* 16 words per glyph */
    for (y=0; y<16; y++) {
        for (x=0; x<16; x++) {
            unsigned char value = 0x02;
            if (x < 8) {
                if (bitmap[boff + (15 - y) * 2 + 1] & (1 << x))  value = 0x60;
            }  else {
                if (bitmap[boff + (15 - y) * 2 ] & (1 << (x - 8)))  value = 0x60;
            }
            LEDS[y * 16 + x] = value; 
            LEDS[256 + y * 16 + x] = value;
            LEDS[512 + y * 16 + x] = value;
            LEDS[768 + y * 16 + x] = value;
        }   
    }
    LEDS[255 - 15] = 0xFF;  /* Upper Right dot */
    LEDS[511] = 0xFF;       /* Upper Left  dot */
    LEDS[512] = 0xFF;       /* Lower Right dot */
    LEDS[768+15] = 0xFF;    /* Lower Left  dot */
}

                                                            
/*----------------------------------------------------------------------------
  MAIN function
 *----------------------------------------------------------------------------*/
int main (void) {
    int i, j, k;

    unsigned int dot_value = 30;
    char data_active = FALSE;

    Init();
    j = k = 0;

    GPIOB->ODR = 0;

    LED_On(0);
    LED_Off(1);
    LED_On(2);

    LEDMode(FALSE);

    for (i=0; i<24; i++) {
        SPI_MASTER_Buffer_Tx[i] = 0x00;
    }

    DEMUX_Enable(TRUE);
    LEDMode(TRUE);
    SetDotValue(dot_value);
    for (i=0; i<4; i++) {
        UpdateLEDDot();
    }
    BLANK_Set = 0;
    while (BLANK_Set == 0);
    LEDMode(FALSE);

    for (i=0; i<PIXEL_COUNT; i++) LEDS[i] = 00;

    RS485_Init();
    /* Select the RS485_USART WakeUp Method */
    Address = AddressSelector_Data();
    USART_SetAddress(RS485_USART, Address);
    USART_WakeUpConfig(RS485_USART, USART_WakeUp_AddressMark);
    USART_ReceiverWakeUpCmd(RS485_USART, ENABLE);
    USART_ITConfig(RS485_USART, USART_IT_RXNE, ENABLE);
    
    if (USE_WATCHDOG) {
          IWDG_WriteAccessCmd(IWDG_WriteAccess_Enable);
          IWDG_SetPrescaler(IWDG_Prescaler_128);    /* 3.2 ms per tick */
          IWDG_SetReload(500);                      /* 1.5 seconds timeout */
          IWDG_ReloadCounter();
          /* Enable IWDG (the LSI oscillator will be enabled by hardware) */
          IWDG_Enable();    
    }

    j = 0;
    
    // UpdateAnim(0x10);
    
    DrawChar(' ');
    // Loop forever
    while (1) { 
        if (USE_WATCHDOG) {
            IWDG_ReloadCounter();                       // Reset the watchdog timer
        }
        Address = AddressSelector_Data();

        // Terminate the RS485 line on panel #0
        if (Address == 0) {
            RS485_PORT->ODR |= ( 1 << 1);           // TE
        } else {
            RS485_PORT->ODR &= ~( 1 << 1);          // ! TE
        }

        USART_SetAddress(RS485_USART, Address);

        BLANK_Set = 0;
        while (BLANK_Set == 0);

        if (CommPacket_Available) {
            if (Packet_CheckCRC(&CommPacket) == TRUE) {
                if (CommPacket.id != Address) {
                    LED_Toggle(0);
                } else {
                    data_active = TRUE;
                    memcpy(LEDS, CommPacket.pixels, PIXEL_COUNT);
                    if (dot_value != CommPacket.dot_cor) {
                        dot_value = CommPacket.dot_cor;
                        LEDMode(TRUE);
                        SetDotValue(dot_value);
                        for (i=0; i<4; i++) {
                            UpdateLEDDot();
                        }
                        BLANK_Set = 0;
                        while (BLANK_Set == 0);
                        LEDMode(FALSE);
                    }
                }
            } else {
                LED_Toggle(0);
            }
            CommPacket_Available = 0;
        }

        if (data_active == FALSE) {
            DrawChar(Address < 10 ? '0' + Address : 'A' + Address - 10);
            LED_Toggle(0);
        }

        for (i=0; i<4 ; i++ ) {
            FillBuffer(i, (line + 1 + 16) % 16);
            UpdateLED();
        }
        LED_Toggle(2);
    }
} // end main

void RCC_Configuration(void)
{
    SystemInit();
    
    /* PCLK1 = HCLK */
    RCC_PCLK1Config(RCC_HCLK_Div1);
}

void NVIC_Configuration(void)
{
  NVIC_InitTypeDef NVIC_InitStructure;
  
  /* Configure the NVIC Preemption Priority Bits */  
  NVIC_PriorityGroupConfig(NVIC_PriorityGroup_0);

  /* Enable the TIM2 gloabal Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = TIM3_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
  
  /* Enable the RS485_USART Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = USART1_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);

  /* Enable the DMA Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = DMA1_Channel5_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
}



void RS485_Init()
{
    int i;
    GPIO_InitTypeDef GPIO_InitStructure;
    USART_InitTypeDef USART_InitStructure;
    USART_ClockInitTypeDef USART_ClockInitStructure;
    DMA_InitTypeDef DMA_InitStructure;
    
    
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
    RCC_APB2PeriphClockCmd(RS485_USART_GPIO_CLK| RCC_APB2Periph_AFIO, ENABLE);
    RCC_APB2PeriphClockCmd(RS485_USART_CLK, ENABLE);
    
    /* DMA clock enable */
    RCC_AHBPeriphClockCmd(RCC_AHBPeriph_DMA1, ENABLE);
    

    /* Configure  Tx as alternate function open-drain */
    GPIO_InitStructure.GPIO_Pin = RS485_USART_TxPin;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
    GPIO_Init(RS485_USART_GPIO, &GPIO_InitStructure);
    
    /* Configure  Tx as alternate function open-drain */
    GPIO_InitStructure.GPIO_Pin = RS485_USART_RxPin;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
    GPIO_Init(RS485_USART_GPIO, &GPIO_InitStructure);

    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_5;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_Out_PP;
    GPIO_Init(RS485_PORT, &GPIO_InitStructure);

    RS485_PORT->ODR |= (1 << 0);        // !RE
    
    /* Configure RS485_USART */
    USART_StructInit(&USART_InitStructure);
    // USART_InitStructure.USART_BaudRate = 4500000;
    // USART_InitStructure.USART_BaudRate = 45;
    USART_InitStructure.USART_BaudRate = 2250000;
    // USART_InitStructure.USART_BaudRate = 1125000;
    // USART_InitStructure.USART_BaudRate = 2000000;
    // USART_InitStructure.USART_BaudRate = 230400;
    USART_InitStructure.USART_WordLength = USART_WordLength_9b;
    USART_InitStructure.USART_StopBits = USART_StopBits_1;
    USART_InitStructure.USART_Parity = USART_Parity_No;
    USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
    USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
    USART_Init(RS485_USART, &USART_InitStructure);  
  
    USART_ClockStructInit(&USART_ClockInitStructure);
    USART_ClockInit(RS485_USART, &USART_ClockInitStructure);
    
    /* Rx DMA1 Channel (triggered by Rx event) Config */
    DMA_DeInit(Rx_DMA_Channel);  
    DMA_InitStructure.DMA_PeripheralBaseAddr = 0x40013804;
    DMA_InitStructure.DMA_MemoryBaseAddr = (uint32_t) &CommPacket;
    DMA_InitStructure.DMA_BufferSize = sizeof(CommPacket);
    DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralSRC;
    DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
    DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
    DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Byte;
    DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_Byte;
    DMA_InitStructure.DMA_Mode = DMA_Mode_Normal;
    DMA_InitStructure.DMA_Priority = DMA_Priority_VeryHigh;
    DMA_InitStructure.DMA_M2M = DMA_M2M_Disable;
    DMA_Init(Rx_DMA_Channel, &DMA_InitStructure);
    
    DMA_ITConfig(Rx_DMA_Channel, DMA_IT_TC, ENABLE);
    DMA_ITConfig(Rx_DMA_Channel, DMA_IT_TE, ENABLE);
    

    /* Enable the RS485_USART */
    USART_Cmd(RS485_USART, ENABLE);
    
    for (i=0; i<100000; i++);
    
    RS485_PORT->ODR &= ~(1 << 0);        // RE
    RS485_PORT->ODR |= ( 1 << 1);        // TE
    RS485_PORT->ODR &= ~(1 << 5);        // DE
}
