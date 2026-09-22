library ieee;
use ieee.fluidic_systems.all;
use ieee.electrical_systems.all;

entity regulP is
  port(terminal TMC : fluidic; terminal Tfrein : fluidic; terminal Tcmd : electrical);
end regulP;

architecture one of regulP is
  quantity Pin across Din through TMC;
  quantity Pout across Dout through Tfrein;
  quantity Vcmd across Icmd through Tcmd;
  
begin
  Pout==Pin*Vcmd/5.0;
end one;
