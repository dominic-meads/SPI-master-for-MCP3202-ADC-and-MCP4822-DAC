#include <stdio.h>
#include "platform.h"
#include "xgpio.h"
#include "xparameters.h"
#include "sleep.h"
#include "xil_printf.h"

int main()
{
  init_platform();

  XGpio data, dv;

  int rx_data;
  int dv_state = 0;
  int last_dv_state = 0;

  XGpio_Initialize(&data,XPAR_AXI_GPIO_0_DEVICE_ID);
  XGpio_Initialize(&dv,XPAR_AXI_GPIO_1_DEVICE_ID);

  // both inputs
  XGpio_SetDataDirection(&data,1,1);
  XGpio_SetDataDirection(&dv,1,1);

  // do 500 samples (1 second)
  for(int i = 0; i < 499; i++){
    dv_state = XGpio_DiscreteRead(&dv,1);

    if (dv_state != last_dv_state){
      if (dv_state == 1){
        rx_data = XGpio_DiscreteRead(&data,1);
        printf("%d\n",rx_data);
      }
      /* else {
        print("new sample conversion taking place\n\r");
      } */
      usleep(2);
    }
    last_dv_state = dv_state;
  }
  
  
  cleanup_platform();
  return(0);
}
