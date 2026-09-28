# BE VHDL-AMS — Système de freinage ABS

Modélisation multi-physique d'un quart de véhicule en phase de freinage, puis de
sa régulation ABS.

Outils : Questa ADMS 2023.2 (noyau analogique ELDO, visualisation EZwave),
simulation transitoire `.tran`, horizon adapté à chaque test.

Chaîne modélisée : `Conducteur → maître-cylindre → régulateur → frein → roue → véhicule`,
le calculateur ABS mesurant la vitesse véhicule et la vitesse roue pour piloter
le régulateur par une tension 0–5 V.

## `src/`

| Fichier | Ce que fait le composant |
|---|---|
| `mes_types.vhd` | Package : type `etat_route` (`seche`, `humide`). |
| `mes_constantes.vhd` | Package : seuil numérique `zero` et masse volumique de l'air `Rho`. |
| `vehicule.vhd` | Quart de véhicule avec traînée aérodynamique : `m/4·dv/dt = F − ½·ρ·S·Cx·v²`. Arrêt propre par `break on vitesse'above(0.0)`. |
| `roue.vhd` | Roue et contact pneu/sol : taux de glissement `S = 1 − ω·rR/v`, adhérence `mu` selon l'état de la route, force de friction en quatre régimes. Équation mécanique `IR·dω/dt = Croue`. |
| `frein.vhd` | Étrier : `tq = coef_fric · press · S · R`, débit nul. |
| `maitre_cylindre.vhd` | Maître-cylindre assisté : `press = force · coef_assistance / S`. |
| `regulP.vhd` | Limiteur de pression commandé en 0–5 V, modèle statique `Pout = Pin · Vcmd/5.0`. Quadripôle : l'entrée hydraulique et la commande ne prélèvent rien (`Din = 0`, `Icmd = 0`). |
| `Calc_ABS.vhd` | Calculateur ABS cadencé à 2 ms : −0,5 V si le glissement dépasse 50 %, +0,1 V sinon, commande bornée à 0–5 V, remise à 5 V sous 30 km/h ou pédale relâchée, dynamique limitée à 1 V/ms. |
| `test.vhd` | Banc d'essai, une architecture par étape d'assemblage. |
| `param.txt` | Jeux de `generic map` de référence pour chaque composant. |

## Architectures de `test.vhd`

Le banc a été enrichi séance après séance : chaque architecture ajoute un
composant, les terminaux pas encore connectés étant alimentés par des sources
idéales.

| Arch. | Assemblage | Stimulus | Ce qu'on vérifie |
|---|---|---|---|
| `A` | Véhicule seul | `force = +2800 N` | Vitesse limite quand la traînée équilibre l'effort moteur. |
| `B` | Véhicule seul | `force = −2800 N` | Décélération jusqu'à l'arrêt, pas de vitesse négative. |
| `C` | Véhicule + roue | `Croue = 800 N·m`, route sèche | Couplage `v` ↔ `ω` par la force de friction. |
| `D` | Véhicule + roue | `Croue = 800 N·m`, route humide | Adhérence dégradée : blocage plus précoce. |
| `E` | + frein | `press = 18 MPa` | Le couple de freinage vient de l'étrier, plus d'une source. |
| `F` | + maître-cylindre | `f_cmd = 180 N` | Chaîne complète depuis l'effort pédale. |
| `G` | + commande pédale | `COND` : 0 → 180 N à 100 ms, établissement 0,5 s | Appui réaliste, `'ramp` pour passer du signal à la quantité. |
| `H` | + régulateur | `Vcmd = 5 V`, route sèche | Régulateur transparent : on retrouve `F`. |
| `I` | + régulateur | `Vcmd` : 5 V → 1 V à 2 s, route humide | Roue bloquée, puis relancée quand la pression baisse. |
| `J` | + calculateur ABS | appui de `G`, route humide | Freinage avec antiblocage (test II-1 du sujet). |
| `K` | + calculateur ABS | appui puis relâchement à 5 s | Arrêt de l'antiblocage au relâchement (test II-2). |
| `L` | sans ABS | appui de `G`, route humide | Référence pour comparer la distance d'arrêt avec `J`. |
| `M` | calculateur ABS seul | vitesses et pression imposées | Test unitaire : chaque règle de l'algorithme sur `vv`. |

Captures correspondantes dans `resultats/`, schémas d'assemblage dans `doc/`.

## Compilation

```sh
valib Travail
vacom src/mes_types.vhd src/mes_constantes.vhd
vacom src/vehicule.vhd src/roue.vhd src/frein.vhd src/maitre_cylindre.vhd src/regulP.vhd src/Calc_ABS.vhd
vacom src/test.vhd
vasim -cmd testo.cmd test f -lib Travail
```

