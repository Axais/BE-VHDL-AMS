library ieee;
use ieee.mechanical_systems.all;
use ieee.fluidic_systems.all;
use ieee.electrical_systems.all;

entity Calc_ABS is
port(
terminal Tveh : translational_velocity;
terminal Troue : rotational_velocity;
terminal Thydro : fluidic;
terminal Tvcmde : electrical;
);
end Calc_ABS;

architecture simple of Calc_ABS is
  quantity vv across ii through Tvcmde;
  quantity pin across din through Thydro;
  quantity vit across force through Tveh;
  quantity omega across tq through Troue;

begin
vv==..
pin==..
...

  process
   
 


  end process;


end simple;
