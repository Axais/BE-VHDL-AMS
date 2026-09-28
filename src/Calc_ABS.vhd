library ieee;
use ieee.mechanical_systems.all;
use ieee.fluidic_systems.all;
use ieee.electrical_systems.all;

entity Calc_ABS is
  generic (
    rR    : real := 0.275;          -- rayon de la roue (m)
    V_min : real := 30.0/3.6;       -- ABS actif au-dessus de 30 km/h (m/s)
    P_min : real := 1.0e4;          -- en dessous (0,1 bar), la pedale est consideree relachee (Pa)
    S_max : real := 0.5             -- seuil de glissement
  );
  port (
    terminal Tveh   : translational_velocity;
    terminal Troue  : rotational_velocity;
    terminal Thydro : fluidic;
    terminal Tvcmde : electrical
  );
end Calc_ABS;

architecture simple of Calc_ABS is
  quantity vv    across ii    through Tvcmde;
  quantity pin   across din   through Thydro;
  quantity vit   across force through Tveh;
  quantity omega across tq    through Troue;

  signal clock : bit  := '0';
  signal cmd   : real := 5.0;       -- tension de commande calculee (V)

begin
  -- Une equation par paire de ports : trois capteurs et une sortie
  force == 0.0;                     -- mesure de la vitesse vehicule, sans effort
  tq    == 0.0;                     -- mesure de la vitesse roue, sans couple
  din   == 0.0;                     -- mesure de la pression MC, sans debit
  vv    == cmd'slew(1000.0);        -- sortie : dynamique limitee a 1 V/ms

  clock <= not clock after 1 ms;    -- horloge de periode 2 ms

  process (clock)
    variable v_cmd : real := 5.0;
    variable S     : real;
  begin
    if clock = '1' then             -- front montant
      if vit > V_min and pin > P_min then
        S := 1.0 - omega*rR/vit;
        if S > S_max then
          v_cmd := v_cmd - 0.5;     -- glissement > 50 % : on relache la pression
        else
          v_cmd := v_cmd + 0.1;     -- glissement < 50 % : on retablit la pression
        end if;
        if v_cmd < 0.0 then
          v_cmd := 0.0;
        elsif v_cmd > 5.0 then
          v_cmd := 5.0;
        end if;
      else
        v_cmd := 5.0;               -- vitesse < 30 km/h ou pedale relachee
      end if;
      cmd <= v_cmd;
    end if;
  end process;
end simple;
