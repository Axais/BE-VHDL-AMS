library ieee;
use ieee.std_logic_1164.all;
use ieee.mechanical_systems.all;
use ieee.fluidic_systems.all;

use work.MES_TYPES.all;
use work.MES_CONSTANTES.all;

entity test is
  constant m_veh : MASS := 1500.0;
end test;

--------------------------------------------------------------------------------------------------------------
-- Test véhicule seul
--------------------------------------------------------------------------------------------------------------
architecture A of test is
  terminal t1 : translational_velocity;
  quantity force through t1;
begin
  force == 2800.0;
  
  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
end A;


architecture B of test is
  terminal t1 : translational_velocity;
  quantity force through t1; 
begin
  force == -2800.0;
  
  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
end B;


--------------------------------------------------------------------------------------------------------------
-- Test véhicule + roue
--------------------------------------------------------------------------------------------------------------
architecture C of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  
  quantity force through t1; 
  quantity w across Croue through t2; 
begin
  Croue == 800.0;
  force == 0.0;

  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
    
  U_roue: entity roue(A) 
    generic map (route => seche, m => m_veh, rR => 0.275, IR => 0.4, mu0_D => 1.0, As => 0.01, mu0_W => 0.5, Vc => 27.8)
    port map (Tveh => t1, Tfrein => t2);
end C;


architecture D of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  quantity force through t1; 
  quantity w across Croue through t2; 
begin
  Croue == 800.0;
  force == 0.0;

  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
    
  U_roue: entity roue(A) 
    generic map (route => humide, m => m_veh, rR => 0.275, IR => 0.4, mu0_D => 1.0, As => 0.01, mu0_W => 0.5, Vc => 27.8)
    port map (Tveh => t1, Tfrein => t2);
end D;


--------------------------------------------------------------------------------------------------------------
-- Test véhicule + roue + frein
--------------------------------------------------------------------------------------------------------------
architecture E of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;

  quantity force through t1; 
  quantity Croue through t2;
  quantity press across debit through t3;
begin
  press == 18.0e6;
  force == 0.0;
  Croue == 0.0;
  
  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
    
  U_roue: entity roue(A) 
    generic map (route => seche, m => m_veh, rR => 0.275, IR => 0.4, mu0_D => 1.0, As => 0.01, mu0_W => 0.5, Vc => 27.8)
    port map (Tveh => t1, Tfrein => t2);
    
  U_frein: entity frein(one)
    generic map (coef_fric => 0.36, S => 1.0e-3, R => 0.12)
    port map (Troue => t2, TMC => t3);
end E;

--------------------------------------------------------------------------------------------------------------
-- Test véhicule + roue + frein + maître cylindre
--------------------------------------------------------------------------------------------------------------

architecture F of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;


  quantity press across debit through t3;
  
  quantity f_cmd : real;
  
begin
  f_cmd == 180.0;
  press == 18.0e6;
 
  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
    
  U_roue: entity roue(A) 
    generic map (route => seche, m => m_veh, rR => 0.275, IR => 0.4, mu0_D => 1.0, As => 0.01, mu0_W => 0.5, Vc => 27.8)
    port map (Tveh => t1, Tfrein => t2);
    
  U_frein: entity frein(one)
    generic map (coef_fric => 0.36, S => 1.0e-3, R => 0.12)
    port map (Troue => t2, TMC => t3);
    
  U_MC: entity maitre_cylindre(one)
    generic map (S => 1.0e-4, coef_assistance => 10.0)
    port map (Tfrein => t3, force => f_cmd); 
end F;
