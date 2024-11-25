--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  GPIO E

--  pragma Restrictions (No_Elaboration_Code);

package A0B.STM32F407.GPIO.PIOE
  with Preelaborate
is

   GPIOE : aliased GPIO_Controller
     (Peripheral => A0B.STM32F407.SVD.GPIO.GPIOE_Periph'Access,
      Identifier => E);

   PE0  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 0);
   PE1  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 1);
   PE2  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 2);
   PE3  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 3);
   PE4  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 4);
   PE5  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 5);
   PE6  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 6);
   PE7  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 7);
   PE8  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 8);
   PE9  : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 9);
   PE10 : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 10);
   PE11 : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 11);
   PE12 : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 12);
   PE13 : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 13);
   PE14 : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 14);
   PE15 : aliased GPIO_Line (Controller => GPIOE'Access, Identifier => 15);

end A0B.STM32F407.GPIO.PIOE;
