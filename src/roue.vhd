library ieee;
use ieee.mechanical_systems.all;
use ieee.math_real.all;
       
use work.MES_TYPES.all;
use work.MES_CONSTANTES.all;

entity roue is
  generic (route : etat_route;
  		   m : MASS ;				-- Masse vehicule
  		   rR : real;				-- Rayon roue
  		   IR : MOMENT_INERTIA;		-- Inertie de la roue
  		   mu0_D : real;			-- Coef adherence sans glissement sur sol sec
  		   As : real;				-- Facteur de decroissance de l'adherence
  		   mu0_W : real;			-- Coef adherence sans glissement sur sol mouille
  		   Vc : real				-- Caracteristique de la surface
  		   );
  port (terminal Tveh : translational_velocity; terminal Tfrein : rotational_velocity);
end roue;

architecture A of roue is

constant Nf : FORCE := 9.81*m/4.0; -- Force verticale appliquee a la roue
constant Cs : FORCE :=10.0*Nf;

function friction (w, v, Cr : real) return real_vector is

variable S, mu, Fric : real;
variable res : real_vector(1 to 2) := (0.0,0.0);
variable texte : string(1 to 6):="xxxxxx";
         
begin
    if v>zero then S := 1.0-(w*rR/v);
    	elsif (w>0.0 and Cr>0.0) then S:=-1.0;
    	else S := 0.0;
    	end if;
   
    if (route = seche) then mu:=mu0_D*(1.0-As*v*S);
        else mu:=mu0_W*exp(-v*S/Vc);
    	end if;
    
    if s=0.0 then Fric:=0.0; texte:="S=0   ";
    	elsif S>=1.0 then Fric := Nf*mu;texte:="S>=1  ";
    	elsif S<=-1.0 then Fric := -Nf*mu;texte:="S<=-1 ";
      	elsif (mu*Nf*(1.0-S)<(2.0*S*Cs)) then Fric:=Nf*mu*(1.0-(mu*(1.0-S)*Nf/(4.0*Cs*S)));texte:="part_1";
        else Fric:=Cs*S/(1.0-S);texte:="part_2";
    	end if;
   --assert false report texte severity note;
   res(1) := S;
   res(2) := Fric;
   return res;
end;

quantity v across Ffric through Tveh;      -- Ffric = force de friction (adherence)
quantity w across Croue through Tfrein;
quantity Cfric through rotational_velocity_ref to Tfrein;
quantity glissement : real;

begin

if domain = quiescent_domain use
    Ffric==0.0;
    Cfric==0.0;
    glissement==0.0;
    w==v/rR;
    else
    (glissement,Ffric)==friction(w,v,Croue);	
    Cfric == Ffric*rR;
    if (w'above(0.0) or Croue'above(0.0)) use IR*w'dot == Croue;
    	else w == -zero;
		end use;   
end use;

break on w'above(zero);
break on v'above(zero);
break on w'above(0.0);
break on Croue'above(0.0);

end A;
