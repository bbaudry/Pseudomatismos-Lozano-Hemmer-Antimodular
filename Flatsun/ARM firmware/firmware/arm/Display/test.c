#include "stm32f10x.h"
#define SPI2_PORT                   GPIOB
#define SPI2_CLOCK_DIR               GPIO_Pin_11     /* Clock Direction */
#define SPI2_SCK                    GPIO_Pin_13
#define SPI2_MOSI                   GPIO_Pin_15
#define SPI2_NRE                    GPIO_Pin_0      /* ! Receiver Enable */
#define SPI2_TE                     GPIO_Pin_1      /* Termination Enable */
#define SPI2_DE                     GPIO_Pin_5      /* Driver Enable */


#define USE_STM3210E_EVAL


#define USARTy                   USART1
#define USARTy_GPIO              GPIOA
#define USARTy_CLK               RCC_APB2Periph_USART1
#define USARTy_GPIO_CLK          RCC_APB2Periph_GPIOA
#define USARTy_TxPin             GPIO_Pin_9

#define USARTz                   USART2
#define USARTz_GPIO              GPIOA
#define USARTz_CLK               RCC_APB1Periph_USART2
#define USARTz_GPIO_CLK          RCC_APB2Periph_GPIOA
#define USARTz_TxPin             GPIO_Pin_2
  
  
/* Private typedef -----------------------------------------------------------*/
typedef enum {FAILED = 0, PASSED = !FAILED} TestStatus;

/* Private define ------------------------------------------------------------*/
#define BufferSize  32

/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
uint16_t SPI1_Buffer_Tx[BufferSize] = {0x0102, 0x0304, 0x0506, 0x0708, 0x090A, 0x0B0C,
    0x0D0E, 0x0F10, 0x1112, 0x1314, 0x1516, 0x1718,
    0x191A, 0x1B1C, 0x1D1E, 0x1F20, 0x2122, 0x2324,
    0x2526, 0x2728, 0x292A, 0x2B2C, 0x2D2E, 0x2F30,
    0x3132, 0x3334, 0x3536, 0x3738, 0x393A, 0x3B3C,
    0x3D3E, 0x3F40};
uint16_t SPI2_Buffer_Tx[BufferSize] = {0x5152, 0x5354, 0x5556, 0x5758, 0x595A, 0x5B5C,
    0x5D5E, 0x5F60, 0x6162, 0x6364, 0x6566, 0x6768,
    0x696A, 0x6B6C, 0x6D6E, 0x6F70, 0x7172, 0x7374,
    0x7576, 0x7778, 0x797A, 0x7B7C, 0x7D7E, 0x7F80,
    0x8182, 0x8384, 0x8586, 0x8788, 0x898A, 0x8B8C,
    0x8D8E, 0x8F90};
uint16_t SPI1_Buffer_Rx[BufferSize], SPI2_Buffer_Rx[BufferSize];
uint32_t TxIdx = 0, RxIdx = 0;
__IO uint16_t CRC1Value = 0, CRC2Value = 0;
volatile TestStatus TransferStatus1 = FAILED, TransferStatus2 = FAILED;
TestStatus Buffercmp(uint16_t* pBuffer1, uint16_t* pBuffer2, uint16_t BufferLength)
{
    while (BufferLength--)
    {
        if (*pBuffer1 != *pBuffer2)
        {
            return FAILED;
        }

        pBuffer1++;
        pBuffer2++;
    }

    return PASSED;
}

void Test_SPI2()
{
    SPI_InitTypeDef  SPI_InitStructure;
    USART_InitTypeDef USART_InitStructure;
    USART_ClockInitTypeDef USART_ClockInitStructure;
    volatile    int k;
    
    SystemInit();
    
    /* PCLK2 = HCLK/1 */
    RCC_PCLK2Config(RCC_HCLK_Div1);

    /* Enable peripheral clocks --------------------------------------------------*/
    /* GPIOA, GPIOB and SPI1 clock enable */
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_GPIOB | RCC_APB2Periph_GPIOC, ENABLE);

    /* Enable GPIO clock */
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);

    /* Enable USARTy Clock */
    RCC_APB2PeriphClockCmd(USARTy_CLK, ENABLE); 
    
    /* Enable USARTz Clock */
    RCC_APB1PeriphClockCmd(USARTz_CLK, ENABLE);
        
#if 0    
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_SPI1, ENABLE);
    /* SPI2 Periph clock enable */
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_SPI2, ENABLE);
#endif

    GPIO_InitTypeDef GPIO_InitStructure;

    // GPIO_InitStructure.GPIO_Pin = GPIO_Pin_All;
    // GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
    // GPIO_Init(GPIOB, &GPIO_InitStructure);

    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_10 | GPIO_Pin_11 | GPIO_Pin_12;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_Out_PP;
    GPIO_Init(GPIOC, &GPIO_InitStructure);
    
#if 0
    GPIO_InitStructure.GPIO_Pin   = SPI2_NRE | SPI2_DE | SPI2_TE | SPI2_CLOCK_DIR;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_Out_PP;
    GPIO_Init(SPI2_PORT, &GPIO_InitStructure);

    SPI2_PORT->ODR &= ~SPI2_NRE;       // RE
    SPI2_PORT->ODR &= ~SPI2_DE;        // DE
    SPI2_PORT->ODR |=  SPI2_TE;        // TE
    SPI2_PORT->ODR &= ~SPI2_CLOCK_DIR;

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_8 ;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
    GPIO_Init(GPIOA, &GPIO_InitStructure);
    
    
  /* Configure SPI1 pins: SCK, MISO and MOSI ---------------------------------*/
  /* Confugure SCK and MOSI pins as Alternate Function Push Pull */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_5 | GPIO_Pin_7;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  /* Confugure MISO pin as Input Floating  */
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
  GPIO_Init(GPIOA, &GPIO_InitStructure);
  
    /* Configure SPI2 pins: SCK, MISO and MOSI ---------------------------------*/
    /* Confugure SCK and MOSI pins as Input Floating */
    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13 | GPIO_Pin_15;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
    GPIO_Init(GPIOB, &GPIO_InitStructure);
    /* Confugure MISO pin as Alternate Function Push Pull */
    //  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_14;
    //  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
    //  GPIO_Init(GPIOB, &GPIO_InitStructure);

    /* SPI1 configuration ------------------------------------------------------*/
    SPI_InitStructure.SPI_Direction = SPI_Direction_2Lines_FullDuplex;
    SPI_InitStructure.SPI_Mode = SPI_Mode_Master;
    SPI_InitStructure.SPI_DataSize = SPI_DataSize_8b;
    SPI_InitStructure.SPI_CPOL = SPI_CPOL_High;
    SPI_InitStructure.SPI_CPHA = SPI_CPHA_2Edge;
    SPI_InitStructure.SPI_NSS = SPI_NSS_Soft;
    SPI_InitStructure.SPI_FirstBit = SPI_FirstBit_MSB;
    SPI_InitStructure.SPI_BaudRatePrescaler = SPI_BaudRatePrescaler_8;
    SPI_Init(SPI1, &SPI_InitStructure);

    /* SPI2 configuration ------------------------------------------------------*/
    SPI_InitStructure.SPI_Direction = SPI_Direction_1Line_Rx;
    SPI_InitStructure.SPI_Mode = SPI_Mode_Slave;
    SPI_Init(SPI2, &SPI_InitStructure);

    SPI_Cmd(SPI1, ENABLE);
    SPI_Cmd(SPI2, ENABLE);
#endif
    
    
  /* Configure USARTy Tx as alternate function open-drain */
  GPIO_InitStructure.GPIO_Pin = USARTy_TxPin;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
  // GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_OD;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
  GPIO_Init(USARTy_GPIO, &GPIO_InitStructure);

  /* Configure USARTz Tx as alternate function open-drain */
  GPIO_InitStructure.GPIO_Pin = USARTz_TxPin;
  GPIO_Init(USARTz_GPIO, &GPIO_InitStructure);

  USART_StructInit(&USART_InitStructure);
  // USART_InitStructure.USART_BaudRate = 9600;
  // USART_InitStructure.USART_BaudRate = 230400;
  // USART_InitStructure.USART_BaudRate = 460800;
  // USART_InitStructure.USART_BaudRate = 500000;
  // USART_InitStructure.USART_BaudRate = 4500000;
  // USART_InitStructure.USART_BaudRate = 921600;
  USART_InitStructure.USART_BaudRate = 2250000;
  USART_InitStructure.USART_WordLength = USART_WordLength_9b;
  USART_InitStructure.USART_StopBits = USART_StopBits_1;
  USART_InitStructure.USART_Parity = USART_Parity_No;
  USART_InitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
  USART_InitStructure.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;

  /* Configure USARTy */
  USART_Init(USARTy, &USART_InitStructure);
  /* Configure USARTz */
  USART_Init(USARTz, &USART_InitStructure);
  
  /*
  USART_ClockStructInit(&USART_ClockInitStructure);
  USART_ClockInit(USARTy, &USART_ClockInitStructure);
  USART_ClockInit(USARTz, &USART_ClockInitStructure);
  */
  
  
  /* Enable the USARTy */
  USART_Cmd(USARTy, ENABLE);
  /* Enable the USARTz */
  USART_Cmd(USARTz, ENABLE);

  /* Enable USARTy Half Duplex Mode*/
  // USART_HalfDuplexCmd(USARTy, ENABLE);
  /* Enable USARTz Half Duplex Mode*/
  // USART_HalfDuplexCmd(USARTz, ENABLE);
  
  while (1) {
      // USART_SendData(USARTy, 0xFF);
      // USART_SendData(USARTy, 0x00);
      // USART_SendData(USARTz, 0x081);
      while(USART_GetFlagStatus(USARTy, USART_FLAG_RXNE) == RESET) {}
      USART_ReceiveData(USARTy);
      GPIOC->ODR ^= GPIO_Pin_10;
  }

#if 0
    while (1) {

        while (1) {
            /* Wait for SPI1 Tx buffer empty */
            while (SPI_I2S_GetFlagStatus(SPI1, SPI_I2S_FLAG_TXE) == RESET);
            /* Send SPI2 data */
            SPI_I2S_SendData(SPI1, 0x55);

            /* Wait for SPI2 data reception */
            // while (SPI_I2S_GetFlagStatus(SPI2, SPI_I2S_FLAG_RXNE) == RESET);
            /* Read SPI2 received data */
            SPI2_Buffer_Rx[0] = SPI_I2S_ReceiveData(SPI2);
            for (k=0; k<10; k++) ;
            GPIOC->ODR ^= GPIO_Pin_10;
            // GPIOB->ODR ^= GPIO_Pin_8;
        }

        /* Transfer procedure */
        while (TxIdx < BufferSize - 1)
        {
            /* Wait for SPI1 Tx buffer empty */
            while (SPI_I2S_GetFlagStatus(SPI1, SPI_I2S_FLAG_TXE) == RESET);
            /* Send SPI2 data */
            SPI_I2S_SendData(SPI2, SPI2_Buffer_Tx[TxIdx]);
            /* Send SPI1 data */
            SPI_I2S_SendData(SPI1, SPI1_Buffer_Tx[TxIdx++]);
            /* Wait for SPI2 data reception */
            while (SPI_I2S_GetFlagStatus(SPI2, SPI_I2S_FLAG_RXNE) == RESET);
            /* Read SPI2 received data */
            SPI2_Buffer_Rx[RxIdx] = SPI_I2S_ReceiveData(SPI2);
            /* Wait for SPI1 data reception */
            while (SPI_I2S_GetFlagStatus(SPI1, SPI_I2S_FLAG_RXNE) == RESET);
            /* Read SPI1 received data */
            SPI1_Buffer_Rx[RxIdx++] = SPI_I2S_ReceiveData(SPI1);
        }

        /* Wait for SPI1 Tx buffer empty */
        while (SPI_I2S_GetFlagStatus(SPI1, SPI_I2S_FLAG_TXE) == RESET);
        /* Wait for SPI2 Tx buffer empty */
        while (SPI_I2S_GetFlagStatus(SPI2, SPI_I2S_FLAG_TXE) == RESET);

        /* Send last SPI2_Buffer_Tx data */
        SPI_I2S_SendData(SPI2, SPI2_Buffer_Tx[TxIdx]);
        /* Enable SPI2 CRC transmission */
        SPI_TransmitCRC(SPI2);
        /* Send last SPI1_Buffer_Tx data */
        SPI_I2S_SendData(SPI1, SPI1_Buffer_Tx[TxIdx]);
        /* Enable SPI1 CRC transmission */
        SPI_TransmitCRC(SPI1);

        /* Wait for SPI1 last data reception */
        while (SPI_I2S_GetFlagStatus(SPI1, SPI_I2S_FLAG_RXNE) == RESET);
        /* Read SPI1 last received data */
        SPI1_Buffer_Rx[RxIdx] = SPI_I2S_ReceiveData(SPI1);

        /* Wait for SPI2 last data reception */
        while (SPI_I2S_GetFlagStatus(SPI2, SPI_I2S_FLAG_RXNE) == RESET);
        /* Read SPI2 last received data */
        SPI2_Buffer_Rx[RxIdx] = SPI_I2S_ReceiveData(SPI2);

        /* Wait for SPI1 data reception: CRC transmitted by SPI2 */
        while (SPI_I2S_GetFlagStatus(SPI1, SPI_I2S_FLAG_RXNE) == RESET);
        /* Wait for SPI2 data reception: CRC transmitted by SPI1 */
        while (SPI_I2S_GetFlagStatus(SPI2, SPI_I2S_FLAG_RXNE) == RESET);

        /* Check the received data with the send ones */
        TransferStatus1 = Buffercmp(SPI2_Buffer_Rx, SPI1_Buffer_Tx, BufferSize);
        TransferStatus2 = Buffercmp(SPI1_Buffer_Rx, SPI2_Buffer_Tx, BufferSize);
        /* TransferStatus1, TransferStatus2 = PASSED, if the data transmitted and received
           are correct */
        /* TransferStatus1, TransferStatus2 = FAILED, if the data transmitted and received
           are different */

        /* Test on the SPI1 CRC Error flag */
        if ((SPI_I2S_GetFlagStatus(SPI1, SPI_FLAG_CRCERR)) == SET)
        {
            TransferStatus2 = FAILED;
        }

        /* Test on the SPI2 CRC Error flag */
        if ((SPI_I2S_GetFlagStatus(SPI2, SPI_FLAG_CRCERR)) == SET)
        {
            TransferStatus1 = FAILED;
        }

        /* Read SPI1 received CRC value */
        CRC1Value = SPI_I2S_ReceiveData(SPI1);
        /* Read SPI2 received CRC value */
        CRC2Value = SPI_I2S_ReceiveData(SPI2);

        GPIOB->ODR ^= GPIO_Pin_8;
    }
#endif
}
