% -----------------------------------------------------------------
%  Main_VOSpringpot_StrainCurves.m
% -----------------------------------------------------------------
%  programmers: Jose Geraldo Telles Ribeiro
%               Americo Cunha Jr
%
%  Originally programmed in: Mar 21, 2025
%           Last updated in: Mar 29, 2025
% -----------------------------------------------------------------
%  This program computes the strain curve evolution for a chosen
%  material and load using a variable-order springpot model.
% -----------------------------------------------------------------
%  Reference:
%  J. G. Telles Ribeiro and A. Cunha Jr,
%  Advanced creep modeling for polymers: A variable-order 
%  fractional calculus approach, 2025
% -----------------------------------------------------------------

clc; clear; close all;

% program header
% -----------------------------------------------------------
disp(' ---------------------------------------------------')
disp(' Main_VOSpringpot_StrainCurves.m                    ')
disp(' ---------------------------------------------------')
disp(' Strain curves via a Variable-Order Springpot model ')
disp('                                                    ')
disp(' by                                                 ')
disp(' José Geraldo Telles Ribeiro                        ')
disp(' Americo Cunha Jr                                   ')
disp(' ---------------------------------------------------')
disp('                                                    ')
% -----------------------------------------------------------

% User Input: Choose Material
% -----------------------------------------------------------------
MyMaterial = input('Choose the material (PP or PVC): ', 's');
while ~ismember(MyMaterial, {'PP','PVC'})
    disp('Not a valid option, please try again.');
    MyMaterial = input('Choose the material (PP or PVC): ', 's');
end
% -----------------------------------------------------------------

% Determine CSV File
% -----------------------------------------------------------------
if strcmp(MyMaterial, 'PP')
    csvFile = 'CreepDataPP.csv';
elseif strcmp(MyMaterial, 'PVC')
    csvFile = 'CreepDataPVC.csv';
end
% -----------------------------------------------------------------

% Read CSV File
% The CSV file is assumed to have a header row and three columns:
%   Column 1: Load (MPa)
%   Column 2: Time (days)
%   Column 3: Strain (dimensionless)
% -----------------------------------------------------------------
dataTable = readtable(csvFile);
% -----------------------------------------------------------------

% Extract data from each column
% (Assuming the columns are in order; you may also use the header names)
% -----------------------------------------------------------------
  loads_history = dataTable{:,1};  % Load values
  times_history = dataTable{:,2};  % Time values
strains_history = dataTable{:,3};  % Strain values
% -----------------------------------------------------------------

% Discover Unique Load Values
% -----------------------------------------------------------------
uniqueLoads = unique(loads_history);
fprintf('Available load values in %s (MPa):\n %s\n', csvFile, num2str(uniqueLoads'));
% -----------------------------------------------------------------

% Prompt User to Select a Load Value
% -----------------------------------------------------------------
sigma0 = input('Select a load value (MPa): ');
while ~ismember(sigma0, uniqueLoads)
    disp('Invalid load value. Please choose one from the list:');
    fprintf('%s\n', num2str(uniqueLoads'));
    sigma0 = input('Select a load value (MPa): ');
end
% -----------------------------------------------------------------

% Filter Data for the Selected Load
% Select rows where the load equals the selected value
% -----------------------------------------------------------------
idx    = loads_history == sigma0;
time   = times_history(idx)*24*3600;       % in seconds
strain = strains_history(idx);             % in % (percentage)
% -----------------------------------------------------------------

% Ensure data is sorted by time (if needed)
% -----------------------------------------------------------------
[time, sortIdx] = sort(time);
strain          = strain(sortIdx);
% -----------------------------------------------------------------

% Define material parameters via phenomenological equation
% (parameters values obtained from Main_VOSpringpot_Calibration2.m)
% -----------------------------------------------------------------
if strcmp(MyMaterial, 'PP')
    
    % Elastic modulus (E, in MPa)
    sigmaR = 11.72; n = 2.63; m1 = -53.20; m2 = 1415.24; m3 = -21.28; m4 = 1306.29;
    E = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Viscosity (Eta)
    sigmaR = 1.0; n = 0.0; m1 = 0.0; m2 = 0.0; m3 = 0.0; m4 = 3.0e5;
    Eta = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Initial fractional order (Beta_0)
    sigmaR = Inf; n = Inf; m1 = 0.0; m2 = 0.0; m3 = 0.005; m4 = 0.0203;
    Beta_0 = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Asymptotic fractional order (Beta_inf)
    sigmaR = 10.43; n = 5.49; m1 = 0.0; m2 = 0.1347; m3 = 0.0; m4 = 0.1012;
    Beta_inf = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Characteristic time (Gam)
    sigmaR = 7.6; n = 15.56; m1 = 0.0; m2 = 1200.54; m3 = -454.03; m4 = 5669.17;
    Gam = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Shaping exponent (Delta)
    sigmaR = 1.0; n = 0.0; m1 = 0.0; m2 = 0.0; m3 = 0.0; m4 = 0.7;
    Delta = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
elseif strcmp(MyMaterial, 'PVC')
    
    % Elastic modulus (E, in MPa)
    sigmaR = 21.24; n = 3.27; m1 = -76.20; m2 = 3587.29; m3 = -27.38; m4 = 2879.71;
    E = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Viscosity (Eta)
    sigmaR = 1.0; n = 0.0; m1 = 0.0; m2 = 0.0; m3 = 0.0; m4 = 3.0e8;
    Eta = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Initial fractional order (Beta_0)
    sigmaR = 21.81; n = 9.33; m1 = 0.0036; m2 = -0.0659; m3 = 0.0020; m4 = -0.005;
    Beta_0 = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Asymptotic fractional order (Beta_inf)
    sigmaR = 25.64; n = 10.34; m1 = 0.0; m2 = 0.1835; m3 = 0.0; m4 = 0.0690;
    Beta_inf = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Characteristic time (Gam)
    sigmaR = 14.94; n = 3.70; m1 = 0.0; m2 = 2319.31; m3 = -1260.46; m4 = 56959.33;
    Gam = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
    
    % Shaping exponent (Delta)
    sigmaR = 23.16; n = 12.62; m1 = 0.0; m2 = 0.22; m3 = -0.0130; m4 = 0.708;
    Delta = PhenomEq(sigma0, sigmaR, n, m1, m2, m3, m4);
end
% -----------------------------------------------------------------

% Deformation curve
% -----------------------------------------------------------------
x       = [E Eta Beta_0 Beta_inf Gam Delta];
Epsilon = sigma0*DeformationEq(x,time);
% -----------------------------------------------------------------

% Custom colors
% -----------------------------------------------------------------
MyBlue   = [0      0.4470 0.7410];
MyOrange = [0.8500 0.3250 0.0980];
% -----------------------------------------------------------------

% Define graph properties structure for the plot
% -----------------------------------------------------------------
graphobj.gname      = sprintf('VOSpringpotStrainCurve_%s_sigma0_%gMPa',MyMaterial,sigma0);
graphobj.linecolor1 = MyOrange; 
graphobj.linecolor2 = MyBlue;
graphobj.Marker1    = 'square';
graphobj.Marker2    = '<';
graphobj.linestyle1 = ':';
graphobj.linestyle2 = '-';
graphobj.xlab       = 'Time (s)';
graphobj.ylab       = 'Strain (%)';
graphobj.xmin       = 1e0;
graphobj.xmax       = 1e9;
graphobj.ymin       = 1e-1;
graphobj.ymax       = 1e1;
graphobj.gtitle     = sprintf('Creep Response for %s at %g MPa',MyMaterial,sigma0);
graphobj.legend1    = 'Experimental Data';
graphobj.legend2    = 'Variable-Order Springpot';
graphobj.signature  = 'Telles Ribeiro and Cunha Jr (2025)';
graphobj.print      = 'yes';
graphobj.close      = 'no';
% -----------------------------------------------------------------

% Plotting the Data
% -----------------------------------------------------------------
PlotLoglog2(time,strain,time,Epsilon*100,graphobj);
% -----------------------------------------------------------------

% End of Script
% -----------------------------------------------------------------
disp('Creep curve shown on screen.');
% -----------------------------------------------------------------



% --- Auxiliary Functions --- %

% -----------------------------------------------------------------
% PhenomEq: Phenomenological equation for material parameters.
% -----------------------------------------------------------------
function M = PhenomEq(sigma0,sigmaR,n,m1,m2,m3,m4)
    
    % Compute the parameter M based on the phenomenological model
    num = (m1*sigma0 + m2).*(sigma0./sigmaR).^n + m3*sigma0 + m4;
    den = (sigma0./sigmaR).^n + 1;
    M   = num./den;
end
% -----------------------------------------------------------------

% -----------------------------------------------------------------
% DeformationEq: Computes strain evolution using the variable-order
% springpot fractional model.
% -----------------------------------------------------------------
function Epsilon = DeformationEq(x,t)
    
    % x = [E, Eta, Beta_0, Beta_inf, Gam, Delta] 
    % x is a vector of model parameters
    E        = x(1);
    Eta      = x(2);
    Beta_0   = x(3);
    Beta_inf = x(4);
    Gam      = x(5);
    Delta    = x(6);

    % Compute the material time scale
    T = Eta/E;
    
    % Compute the time-dependent fractional order:
    % Beta(t) = (Beta_inf * (t/Gam)^Delta + Beta_0) / ((t/Gam)^Delta + 1)
    Beta_t = (Beta_inf*(t/Gam).^Delta + Beta_0)./((t/Gam).^Delta + 1);
    
    % Compute the deformation using the springpot constitutive equation
    % Epsilon = (1 / (gamma(Beta(t)+1)*E)) * (t/T)^Beta(t)
    Epsilon = (1./(gamma(Beta_t+1)*E)).*((t/T).^Beta_t);
end
% -----------------------------------------------------------------