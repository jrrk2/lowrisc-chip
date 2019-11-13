#include <stdio.h>
#include "ariane.h"
#include "uart.h"

static uint64_t old_status1, old_status3;

void bt_main(int sw)
{
  int i, j;
  init_uart(1, 326); /* 9600 baud, 0.2% error */
  old_status1 = -1;
  
  for (i = 0; i < 3; i++)
    {
      for (j = 1000000; j--; )
        old_status3 += j;
      write_serial(1, '$');
    }
  while (1)
    {
      uint64_t status1 = read_line_status(1);
      if (status1 != old_status1)
        {
          printf("Status1 = %lX\n", status1);
          old_status1 = status1;
        }
    }
}
