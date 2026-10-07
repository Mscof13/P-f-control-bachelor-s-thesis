# P-f (Frequency) Control in Power Systems: MATLAB/Simulink Simulation

Simulation of primary and secondary P-f (active power–frequency) control in a power system with four hydro generating units and a 230 kV network. This is the practical part of my bachelor's thesis at the Faculty of Technical Sciences, University of Novi Sad (2026).

- **Thesis title:** Analysis of primary and secondary P-f control in power systems
- **Mentor:** Prof. Dr Goran Švenda
- **Tools:** MATLAB R2024a, Simulink, Simscape Electrical (Specialized Power Systems)

> The full thesis is written in Serbian (`docs/thesis_sr.pdf`). This README summarizes it in English.

## Abstract

A load increase, a generator outage, and a line outage were simulated on a MATLAB/Simulink model with four hydro units and a 230 kV network. The results show that primary control halts the frequency drop but leaves a steady-state error, which secondary control eliminates.

## The model

| Unit | Rated power | Inertia constant H |
|---|---|---|
| LG2 (reference/swing unit) | 5500 MVA | 4.1 s |
| LG3 | 2200 MVA | 3.2 s |
| LG31 | 200 MVA | 3.2 s |
| LG4 | 2700 MVA | 3.7 s |

- **Generators:** salient-pole hydro units, 13.8 kV, each connected through its own 13.8/230 kV block transformer.
- **Network:** 230 kV, four nodes (LG2, LG3, LG4 and the load node CHM) forming two loops. Lines use distributed parameters, and the number of parallel circuits keeps the load below 80 % of the thermal limit.
- **Load:** 8000 MW main load at CHM, a switchable extra 1500 MW, a 2200 Mvar capacitor bank, and small local loads at the generator busbars.
- **Primary control:** Hydraulic Turbine and Governor block (PID controller, permanent droop 0.05).
- **Excitation:** IEEE Type 1 voltage regulator. An optional power system stabilizer is switched off by default.
- **Secondary control:** the integral of the rotor speed deviation is added to the turbine power reference on units LG2 and LG4. A relay enables it after a 65 s delay, once the speed deviation reaches 0.005 p.u. (0.25 Hz).
- **Simulation:** starts from a Load Flow steady state (100 MVA base), discrete solver, step 50 µs, duration 300 s. Disturbances are applied at t = 100 s.

## Scenarios and results

| Scenario | Disturbance | Primary control only | With secondary control |
|---|---|---|---|
| 1. Load increase | +1500 MW at node CHM | Frequency falls to about 44.2 Hz, then settles at about 49.7 Hz (steady-state error of about 0.3 Hz) | Returns to 50 Hz, with deviation under 0.1 Hz by the end of the run |
| 2. Generator outage | LG31 trips (200 MVA, 180 MW) | Minimum about 49.27 Hz, settles at about 49.95 Hz | Frequency returns toward 50 Hz after secondary control activates (about t = 167 s) |
| 3. Line outage | Line LG2–LG3 disconnected | Very small deviation (peak about 50.018 Hz), back to nominal within about 25 s | With the relay threshold lowered to 0.0003, frequency returns to 50 Hz by about t = 250 s |

## Effect of system inertia

For an equivalent single machine, the initial rate of frequency change is df/dt = −fn·ΔP / (2·Ek), where Ek is the sum of H·Sn over all units. For this system Ek = 40.22 GWs. The table shows what happens if part of the synchronous generation is replaced by inverter-connected sources that add no inertia.

| Renewable share | Ek (GWs) | 1500 MW load increase (Hz/s) | LG31 outage (Hz/s) |
|---|---|---|---|
| 0 % | 40.22 | 0.93 | 0.11 |
| 25 % | 30.17 | 1.24 | 0.15 |
| 50 % | 20.11 | 1.86 | 0.22 |
| 75 % | 10.06 | 3.73 | 0.44 |

## How to reproduce

1. Install MATLAB R2024a with Simulink, Simscape, Simscape Electrical and DSP System Toolbox (needed for the Moving RMS block).
2. Put the model `Model_pf_regulacije_C.slx` and the script `Model_pf_regulacijemat.m` in the same folder.
3. In the script, choose the scenario by setting the switching time of one breaker to 100 and leaving the other two at 1e6.
4. Run the script. It loads all parameters into the workspace.
5. Open and run the model. Initial conditions are already stored in it. If you change any value from the parameter tables, first re-run Load Flow (powergui → Load Flow) and apply the results.
6. Read the frequency from the scope `Scope4` inside the relevant `Merenja` subsystem.

To run without secondary control, set the Relay block's "Switch on point" in the subsystems `Regulators1` and `Regulators4` to a value the speed deviation cannot reach (for example 1).

| Scenario | Script variable | Breaker in the model |
|---|---|---|
| Load increase | `t_povecanje_potrosnje = 100` | `Prekidac CHM2` |
| Generator outage | `t_ispad_LG31 = 100` | `Prekidac LG31` |
| Line outage | `t_ispad_voda_LG2_LG3 = 100` | `Prekidac CHM1` |

Names inside the model are Serbian: *prekidac* = breaker, *merenja* = measurements, *potrosnja* = load, *ispad* = outage, *vod* = line.

## Repository contents

- `Model_pf_regulacijemat.m`: model parameters and scenario selection (comments in English, variable names kept because the model refers to them)
- `Model_pf_regulacije_C.slx`: Simulink model
- `docs/thesis_sr.pdf`: full thesis (in Serbian)

## Credits and references

- The Simulink model started from the MathWorks example "MMC-STATCOM Connected to a 735-kV Transmission System" (Simscape Electrical – Specialized Power Systems, R2024a). I reworked and adapted it to a 230 kV, 50 Hz network.
- Line parameters: P. Kundur, *Power System Stability and Control*, McGraw-Hill, 1994 (Table 6.1).
