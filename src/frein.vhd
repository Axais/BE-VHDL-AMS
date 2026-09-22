library ieee;
use ieee.fluidic_systems.all;
use ieee.mechanical_systems.all;

entity frein is
  generic (
    coef_fric : real;  	-- Coefficient de friction des plaquettes
    S : real;  			-- Surface piston = 10 cm2
    R : real 			-- Rayon moyen du disque
    );
  port(terminal Troue : rotational_velocity; terminal TMC : fluidic);
end frein;

architecture one of frein is
  quantity omega across tq through TRoue;
  quantity press across debit through TMC;
  
begin
  debit==0.0;
  tq==coef_fric*press*S*R;
end one;
