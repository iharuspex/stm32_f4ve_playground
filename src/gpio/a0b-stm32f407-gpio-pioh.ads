--
--  Copyright (C) 2024, Vadim Godunko <vgodunko@gmail.com>
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  GPIO H

--  pragma Restrictions (No_Elaboration_Code);

package A0B.STM32F407.GPIO.PIOH
  with Preelaborate
is

   GPIOH : aliased GPIO_Controller
     (Peripheral => A0B.STM32F407.SVD.GPIO.GPIOH_Periph'Access,
      Identifier => H);

   PH0  : aliased GPIO_Line (Controller => GPIOH'Access, Identifier => 0);
   PH1  : aliased GPIO_Line (Controller => GPIOH'Access, Identifier => 1);

end A0B.STM32F407.GPIO.PIOH;
