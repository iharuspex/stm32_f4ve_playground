--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  GPIO B

--  pragma Restrictions (No_Elaboration_Code);

package A0B.STM32F407.GPIO.PIOB
  with Preelaborate
is

   GPIOB : aliased GPIO_Controller
     (Peripheral => A0B.STM32F407.SVD.GPIO.GPIOB_Periph'Access,
      Identifier => B);

   PB0  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 0);
   PB1  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 1);
   PB2  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 2);
   PB3  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 3);
   PB4  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 4);
   PB5  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 5);
   PB6  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 6);
   PB7  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 7);
   PB8  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 8);
   PB9  : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 9);
   PB10 : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 10);
   PB11 : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 11);
   PB12 : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 12);
   PB13 : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 13);
   PB14 : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 14);
   PB15 : aliased GPIO_Line (Controller => GPIOB'Access, Identifier => 15);

end A0B.STM32F407.GPIO.PIOB;
