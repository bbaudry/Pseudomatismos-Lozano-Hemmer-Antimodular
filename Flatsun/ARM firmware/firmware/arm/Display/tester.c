#include "stm32f10x.h"
#include "Packet.h"
#include <string.h>
// #include <stm32f10x_lib.h>                        // STM32F10x Library Definitions
// #include "STM32_Init.h"                           // STM32 Initialization

#define USE_WATCHDOG                0

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
#define SPI_CLOCK_DIR_PIN           GPIO_Pin_11

#define Rx_DMA_Channel              DMA1_Channel5
#define Rx_DMA_FLAG                 DMA1_FLAG_TC5

unsigned char LEDS[1024];

void RCC_Configuration(void);
void NVIC_Configuration(void);

void LED_Init()
{
    GPIO_InitTypeDef GPIO_InitStructure;
    
    // RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

    // GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14;
    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_12 | GPIO_Pin_14;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_Out_PP;
    GPIO_Init(GPIOB, &GPIO_InitStructure);
}

void LED_On(int led)
{
    if (led != 1) GPIOB->ODR &= ~(1 << (led+12));
}

void LED_Off(int led)
{
    if (led != 1) GPIOB->ODR  |= (1 << (led+12));
}


void LED_Toggle(int led)
{
    if (led != 1) GPIOB->ODR ^= (1 << (led+12));
}

void Comm_Init()
{
    GPIO_InitTypeDef GPIO_InitStructure;
    SPI_InitTypeDef SPI_InitStructure;

   
    

  /* Configure SPI2 pins: SCK and MOSI ---------------------------------*/
  /* Confugure SCK and MOSI pins as Input Floating */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13 | GPIO_Pin_15;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_Init(GPIOB, &GPIO_InitStructure);

  /* SPI2 configuration ------------------------------------------------------*/
  SPI_StructInit(&SPI_InitStructure);
  SPI_InitStructure.SPI_Direction = SPI_Direction_1Line_Rx;
  SPI_InitStructure.SPI_Mode      = SPI_Mode_Slave;
  SPI_InitStructure.SPI_DataSize  = SPI_DataSize_8b;
  SPI_InitStructure.SPI_CPOL      = SPI_CPOL_High;
  SPI_InitStructure.SPI_CPHA      = SPI_CPHA_2Edge;
  SPI_InitStructure.SPI_NSS       = SPI_NSS_Soft;
  SPI_InitStructure.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_8;
  SPI_InitStructure.SPI_FirstBit = SPI_FirstBit_LSB;
  SPI_InitStructure.SPI_CRCPolynomial = 7;
  SPI_Init(SPI2, &SPI_InitStructure);
  
  // SPI_NSSInternalSoftwareConfig(SPI2, SPI_NSSInternalSoft_Set);
  
  /* Enable SPI_SLAVE RXNE interrupt */
  // SPI_I2S_ITConfig(SPI2, SPI_I2S_IT_RXNE, ENABLE);
  
  /* Enable SPI2 */
  SPI_Cmd(SPI2, ENABLE);

  GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_5 | SPI_CLOCK_DIR_PIN;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_Out_PP;
  GPIO_Init(RS485_PORT, &GPIO_InitStructure);
  
  GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_8 | GPIO_Pin_9 | GPIO_Pin_10;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_IN_FLOATING;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  
    RS485_PORT->ODR &= ~GPIO_Pin_0;       // RE
    RS485_PORT->ODR |=  GPIO_Pin_1;        // TE
    RS485_PORT->ODR &= ~GPIO_Pin_5;        // DE
    RS485_PORT->ODR &= ~SPI_CLOCK_DIR_PIN;

}

void Init()
{
    GPIO_InitTypeDef GPIO_InitStructure;
    
    RCC_Configuration();
    
    NVIC_Configuration();

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;
    GPIO_Init(GPIOA, &GPIO_InitStructure);
    GPIO_Init(GPIOB, &GPIO_InitStructure);
    GPIO_Init(GPIOC, &GPIO_InitStructure);
    GPIO_Init(GPIOD, &GPIO_InitStructure);                           

    LED_Init();
    Comm_Init();
}



                                                            
/*----------------------------------------------------------------------------
  MAIN function
 *----------------------------------------------------------------------------*/
int main (void) {
    unsigned int word;
    Init();

    LED_On(0);
    LED_Off(1);
    LED_On(2);

    while (1) {
        word = GPIOB->IDR;
        
        #if 0
        if (word & GPIO_Pin_13) {
            LED_On(0);
        } else {
            LED_Off(0);
        }
        #else
        if (SPI_I2S_GetFlagStatus(SPI2, SPI_I2S_FLAG_RXNE) != RESET) {
            SPI_I2S_ReceiveData(SPI2);
            LED_Toggle(0);
        }
        #endif
        
        LED_Toggle(2);
    }
} // end main

void RCC_Configuration(void)
{
    SystemInit();
    
    /* PCLK1 = HCLK */
    RCC_PCLK1Config(RCC_HCLK_Div1);
    
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOB |
                           RCC_APB2Periph_GPIOC | RCC_APB2Periph_GPIOD, ENABLE);

    RCC_APB1PeriphClockCmd(RCC_APB1Periph_SPI2, ENABLE);
}

void NVIC_Configuration(void)
{
  NVIC_InitTypeDef NVIC_InitStructure;
  
  /* Configure the NVIC Preemption Priority Bits */  
  // NVIC_PriorityGroupConfig(NVIC_PriorityGroup_0);
  
}
