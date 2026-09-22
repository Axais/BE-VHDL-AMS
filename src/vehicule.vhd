library ieee;
use ieee.mechanical_systems.all;

use work.MES_CONSTANTES.all;

entity vehicule is
  generic(
    m : MASS; 			-- Masse vehicule
    Cx : real;			-- Coef aerodynamique
    S : real;			-- Surface frontale
    v_init : VELOCITY);		-- Vitesse initiale du vehicule
  port(terminal  Troue : translational_velocity);
end vehicule;

architecture one of vehicule is
  quantity vitesse across force through Troue;
  quantity pos :DISPLACEMENT :=0.0;
 
begin
if domain = quiescent_domain use
  pos==0.0;
  vitesse==v_init;
else
  vitesse'integ == pos;
  if vitesse'above(0.0) use m/4.0*vitesse'dot == force - 0.5*Rho*S*Cx*vitesse**2;
  else vitesse==-zero;
  end use; 
end use;	

break on vitesse'above(0.0);
end one;
