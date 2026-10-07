%% =====================================================================
%  Parameters of the model Model_pf_regulacije
%% --- general ---------------------------------------------------------
Fn    = 50;            % Hz, nominal system frequency
Vrms  = 230e3;         % V, nominal (line-to-line, RMS) voltage of the transmission network
Vg    = 13.8e3;        % V, nominal voltage of the generator busbars
Sbase = 100e6;         % VA, base power for powergui / load flow

%% --- 230 kV line, data per single circuit ----------------------------
%  Source: Kundur, "Power System Stability and Control", table 6.1,
%  typical 230 kV overhead line (data given for 60 Hz):
%      R = 0.050 ohm/km,  xL = 0.488 ohm/km,  bC = 3.371 uS/km
%  From these, the frequency-independent data are obtained:
r1 = 0.050;                    % ohm/km   (positive sequence)
l1 = 0.488/(2*pi*60);          % H/km     = 1.2945e-3
c1 = 3.371e-6/(2*pi*60);       % F/km     = 8.9419e-9

%  Zero sequence: typical ratios (r0 = 5*r1, l0 = 3*l1, c0 = 0.6*c1).
%  All disturbances are symmetrical, so the zero sequence does not affect the results.
r0 = 0.25;                     % ohm/km
l0 = 3*l1;                     % H/km
c0 = 0.6*c1;                   % F/km

Rv = [r1 r0];                  % vectors required by the Distributed Parameters Line block
Lv = [l1 l0];
Cv = [c1 c0];

%  Derived quantities at 50 Hz (for manual checking in the thesis):
x1_km = 2*pi*Fn*l1;            % = 0.4067 ohm/km
b1_km = 2*pi*Fn*c1;            % = 2.809e-6 S/km
Zc    = sqrt(l1/c1);           % = 380.5 ohm
Pnat  = Vrms^2/Zc;             % = 139.0 MW per circuit

%% --- line lengths and number of parallel circuits --------------------
%  The number of circuits is set by a thermal criterion: the load per
%  circuit stays below 320 MVA (80 % of 400 MVA per circuit).
d_LG2_CHM = 80;   n_LG2_CHM = 13;
d_LG3_CHM = 60;   n_LG3_CHM = 6;
d_LG4_CHM = 50;   n_LG4_CHM = 8;
d_LG2_LG3 = 40;   n_LG2_LG3 = 2;
d_LG3_LG4 = 40;   n_LG3_LG4 = 2;

%% --- compensation ----------------------------------------------------
%  Shunt reactors and series capacitors are not modeled.
Qc_CHM = 2200e6;               % var, capacitor bank at the CHM busbar

%% --- loads -----------------------------------------------------------
P_CHM1 = 8000e6;   Q_CHM1 = 1000e6;   % CHM1, constant impedance
P_LG2loc = 275e6;                      % 13.8 kV, local load at LG2
P_LG3loc = 110e6;                      % at generator LG3
P_LG31loc = 5e6;                       % behind the breaker, stays in the system
P_LG31loc2 = 5e6;                      % at generator LG31 (islanded part)
P_LG4loc = 135e6;                      % at LG4

%% --- scenario --------------------------------------------------------
%  The scenario is selected by setting the switching time of the
%  corresponding breaker; breakers set to 1e6 s do not operate
%  during the simulation.
%    Scenario 1: t_povecanje_potrosnje = 100  (connect load CHM2)
%    Scenario 2: t_ispad_LG31 = 100           (outage of generator LG31)
%    Scenario 3: t_ispad_voda_LG2_LG3 = 100   (disconnect line LG2-LG3)
t_ispad_LG31 = 100;            % s, breaker at LG31
t_povecanje_potrosnje = 1e6;   % s, breaker at CHM2
t_ispad_voda_LG2_LG3 = 1e6;    % s, breaker on line LG2_LG3

%% --- simulation ------------------------------------------------------
Ts       = 50e-6;              % s, sampling step (powergui)
Tsim     = 300;                % s, simulation duration
PSStype  = 1;                  % 1 = no PSS, 2 = Generic PSS, 3 = Multi-Band PSS