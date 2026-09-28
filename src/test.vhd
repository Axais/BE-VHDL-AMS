library ieee;
use ieee.std_logic_1164.all;
use ieee.mechanical_systems.all;
use ieee.fluidic_systems.all;
use ieee.electrical_systems.all;

use work.MES_TYPES.all;
use work.MES_CONSTANTES.all;

entity test is
  constant m_veh : MASS := 1500.0;
end test;

--------------------------------------------------------------------------------------------------------------
-- Étape 1 : véhicule seul
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
-- Étape 2 : véhicule + roue
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
-- Étape 3 : véhicule + roue + frein
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
-- Étape 4 : véhicule + roue + frein + maître cylindre
--------------------------------------------------------------------------------------------------------------

architecture F of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;

  quantity f_cmd : real;          
  
begin
  f_cmd == 180.0;
 
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


--------------------------------------------------------------------------------------------------------------
-- Étape 5 : véhicule + roue + frein + maître cylindre + signal COND
--------------------------------------------------------------------------------------------------------------

architecture G of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;

  signal COND : real := 0.0;      
  quantity f_cmd : real;
  
begin
  COND <= 180.0 after 100 ms;
  f_cmd == COND'ramp(0.5, 0.5);
 
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
end G;


--------------------------------------------------------------------------------------------------------------
-- Test régulateur : véhicule + roue + frein + régulateur + MC + signal COND
--------------------------------------------------------------------------------------------------------------

architecture H of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;                     -- maître cylindre -> régulateur
  terminal t4 : fluidic;                     -- régulateur -> étrier
  terminal t5 : electrical;                  -- commande du régulateur

  quantity f_cmd : real;                     
  quantity Vcmd across Icmd through t5;      -- source de commande

begin
  f_cmd == 180.0;
  Vcmd  == 5.0;
 
  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
    
  U_roue: entity roue(A) 
    generic map (route => seche, m => m_veh, rR => 0.275, IR => 0.4, mu0_D => 1.0, As => 0.01, mu0_W => 0.5, Vc => 27.8)
    port map (Tveh => t1, Tfrein => t2);
    
  U_frein: entity frein(one)
    generic map (coef_fric => 0.36, S => 1.0e-3, R => 0.12)
    port map (Troue => t2, TMC => t4);
    
  U_regul: entity regulP(one)
    port map (TMC => t3, Tfrein => t4, Tcmd => t5);
    
  U_MC: entity maitre_cylindre(one)
    generic map (S => 1.0e-4, coef_assistance => 10.0)
    port map (Tfrein => t3, force => f_cmd); 
end H;


--------------------------------------------------------------------------------------------------------------
-- Test régulateur sur route humide : échelon de Vcmd à t = 2 s, de 5 V à 1 V
--------------------------------------------------------------------------------------------------------------

architecture I of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;                     -- maître cylindre -> régulateur
  terminal t4 : fluidic;                     -- régulateur -> étrier
  terminal t5 : electrical;                  -- commande du régulateur

  quantity f_cmd : real;                     
  quantity Vcmd across Icmd through t5;      -- source de commande
  signal CMD : real := 5.0;                  -- consigne du régulateur, en V

begin
  f_cmd == 180.0;
  CMD  <= 1.0 after 2000 ms;                 -- échelon du sujet (regulateur.odp)
  Vcmd == CMD'ramp(0.01);
 
  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
    
  U_roue: entity roue(A) 
    generic map (route => humide, m => m_veh, rR => 0.275, IR => 0.4, mu0_D => 1.0, As => 0.01, mu0_W => 0.5, Vc => 27.8)
    port map (Tveh => t1, Tfrein => t2);
    
  U_frein: entity frein(one)
    generic map (coef_fric => 0.36, S => 1.0e-3, R => 0.12)
    port map (Troue => t2, TMC => t4);
    
  U_regul: entity regulP(one)
    port map (TMC => t3, Tfrein => t4, Tcmd => t5);
    
  U_MC: entity maitre_cylindre(one)
    generic map (S => 1.0e-4, coef_assistance => 10.0)
    port map (Tfrein => t3, force => f_cmd); 
end I;


--------------------------------------------------------------------------------------------------------------
-- ABS, test II-1 : pédale à 180 N à t = 100 ms (établissement 0.5 s) jusqu'à l'arrêt, route humide
--------------------------------------------------------------------------------------------------------------

architecture J of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;                     -- maître cylindre -> régulateur
  terminal t4 : fluidic;                     -- régulateur -> étrier
  terminal t5 : electrical;                  -- commande du régulateur, pilotée par l'ABS

  signal COND : real := 0.0;                 -- effort sur la pédale, en N
  quantity f_cmd : real;

begin
  COND  <= 180.0 after 100 ms;
  f_cmd == COND'ramp(0.5);

  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
    
  U_roue: entity roue(A) 
    generic map (route => humide, m => m_veh, rR => 0.275, IR => 0.4, mu0_D => 1.0, As => 0.01, mu0_W => 0.5, Vc => 27.8)
    port map (Tveh => t1, Tfrein => t2);
    
  U_frein: entity frein(one)
    generic map (coef_fric => 0.36, S => 1.0e-3, R => 0.12)
    port map (Troue => t2, TMC => t4);
    
  U_regul: entity regulP(one)
    port map (TMC => t3, Tfrein => t4, Tcmd => t5);
    
  U_MC: entity maitre_cylindre(one)
    generic map (S => 1.0e-4, coef_assistance => 10.0)
    port map (Tfrein => t3, force => f_cmd); 

  U_ABS: entity Calc_ABS(simple)
    port map (Tveh => t1, Troue => t2, Thydro => t3, Tvcmde => t5);
end J;


--------------------------------------------------------------------------------------------------------------
-- ABS, test II-2 : même appui, puis pédale relâchée à t = 5 s (annulation en 100 ms), route humide
--------------------------------------------------------------------------------------------------------------

architecture K of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;                     -- maître cylindre -> régulateur
  terminal t4 : fluidic;                     -- régulateur -> étrier
  terminal t5 : electrical;                  -- commande du régulateur, pilotée par l'ABS

  signal COND : real := 0.0;                 -- effort sur la pédale, en N
  quantity f_cmd : real;

begin
  COND  <= 180.0 after 100 ms, 0.0 after 5000 ms;
  f_cmd == COND'ramp(0.5, 0.1);

  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
    
  U_roue: entity roue(A) 
    generic map (route => humide, m => m_veh, rR => 0.275, IR => 0.4, mu0_D => 1.0, As => 0.01, mu0_W => 0.5, Vc => 27.8)
    port map (Tveh => t1, Tfrein => t2);
    
  U_frein: entity frein(one)
    generic map (coef_fric => 0.36, S => 1.0e-3, R => 0.12)
    port map (Troue => t2, TMC => t4);
    
  U_regul: entity regulP(one)
    port map (TMC => t3, Tfrein => t4, Tcmd => t5);
    
  U_MC: entity maitre_cylindre(one)
    generic map (S => 1.0e-4, coef_assistance => 10.0)
    port map (Tfrein => t3, force => f_cmd); 

  U_ABS: entity Calc_ABS(simple)
    port map (Tveh => t1, Troue => t2, Thydro => t3, Tvcmde => t5);
end K;


--------------------------------------------------------------------------------------------------------------
-- Référence sans ABS pour J : étape 5 (architecture G) sur route humide, même appui pédale
--------------------------------------------------------------------------------------------------------------

architecture L of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;

  signal COND : real := 0.0;      
  quantity f_cmd : real;
  
begin
  COND <= 180.0 after 100 ms;
  f_cmd == COND'ramp(0.5, 0.5);
 
  U_veh: entity vehicule(one) 
    generic map (m => m_veh, cx => 0.3, S => 1.8, v_init => 28.0) 
    port map (Troue => t1);
    
  U_roue: entity roue(A) 
    generic map (route => humide, m => m_veh, rR => 0.275, IR => 0.4, mu0_D => 1.0, As => 0.01, mu0_W => 0.5, Vc => 27.8)
    port map (Tveh => t1, Tfrein => t2);
    
  U_frein: entity frein(one)
    generic map (coef_fric => 0.36, S => 1.0e-3, R => 0.12)
    port map (Troue => t2, TMC => t3);
    
  U_MC: entity maitre_cylindre(one)
    generic map (S => 1.0e-4, coef_assistance => 10.0)
    port map (Tfrein => t3, force => f_cmd); 
end L;


--------------------------------------------------------------------------------------------------------------
-- Test unitaire du calculateur ABS seul : vitesses et pression imposées par des sources idéales.
-- Chaque phase vérifie une règle du sujet, vv doit suivre ce chronogramme :
--   0 - 100 ms : pédale relâchée (pin = 0)            -> vv reste à 5 V
--   100 ms     : pédale enfoncée, roue bloquée (S = 1) -> vv descend de 0.5 V / 2 ms, 0 V vers 120 ms
--   200 ms     : roue qui roule (S = 0)                -> vv remonte de 0.1 V / 2 ms, 5 V vers 300 ms
--   400 ms     : roue de nouveau bloquée               -> vv retombe à 0 V vers 420 ms
--   500 ms     : véhicule sous 30 km/h                 -> vv revient à 5 V en 5 ms (pente 1 V/ms)
--   600 ms     : véhicule au-dessus de 30 km/h         -> vv retombe à 0 V vers 620 ms
--   700 ms     : pédale relâchée                       -> vv revient à 5 V en 5 ms
--------------------------------------------------------------------------------------------------------------

architecture M of test is
  terminal t1 : translational_velocity;
  terminal t2 : rotational_velocity;
  terminal t3 : fluidic;
  terminal t5 : electrical;

  signal S_v : real := 20.0;                 -- vitesse véhicule imposée, en m/s
  signal S_w : real := 0.0;                  -- vitesse roue imposée, en rad/s
  signal S_p : real := 0.0;                  -- pression maître cylindre imposée, en Pa

  quantity v across fv through t1;
  quantity w across cw through t2;
  quantity p across dp through t3;

begin
  S_p <= 18.0e6 after 100 ms, 0.0 after 700 ms;
  S_w <= 20.0/0.275 after 200 ms, 0.0 after 400 ms;   -- 20/rR : roue qui roule sans glisser
  S_v <= 5.0 after 500 ms, 20.0 after 600 ms;

  v == S_v'ramp(1.0e-3);
  w == S_w'ramp(1.0e-3);
  p == S_p'ramp(1.0e-3);

  U_ABS: entity Calc_ABS(simple)
    port map (Tveh => t1, Troue => t2, Thydro => t3, Tvcmde => t5);
end M;
