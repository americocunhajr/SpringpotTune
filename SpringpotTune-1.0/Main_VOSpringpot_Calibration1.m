% -----------------------------------------------------------------
%  Main_VOSpringpot_Calibration1.m
% -----------------------------------------------------------------
%  programmers: Jose Geraldo Telles Ribeiro
%               Americo Cunha Jr
%
%  Originally programmed in: Mar 21, 2025
%           Last updated in: Mar 29, 2025
% -----------------------------------------------------------------
%  This program solves a calibration inverse problem to fit
%  a variable-order springpot model to given dataset.
% -----------------------------------------------------------------
%  Reference:
%  J. G. Telles Ribeiro and A. Cunha Jr,
%  Advanced creep modeling for polymers: A variable-order 
%  fractional calculus approach, 2025
% -----------------------------------------------------------------

clc; clear; close all;

% random number generator (fix the seed for reproducibility)
rng_stream = RandStream('mt19937ar','Seed',30081984);
RandStream.setGlobalStream(rng_stream);

% program header
% -----------------------------------------------------------
disp(' ---------------------------------------------------')
disp(' Main_VOSpringpot_Calibration1.m                    ')
disp(' ---------------------------------------------------')
disp(' Calibration of a Variable-Order Springpot model    ')
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
idx         = loads_history == sigma0;
time        = times_history(idx)*24*3600;       % in seconds
Epsilon_exp = strains_history(idx);             % in percentage
% -----------------------------------------------------------------

% Ensure data is sorted by time (if needed)
% -----------------------------------------------------------------
[time, sortIdx] = sort(time);
Epsilon_exp     = Epsilon_exp(sortIdx);
% -----------------------------------------------------------------

% Model Calibration Setup
%   E       : Elastic modulus [Pa]
%   Eta     : Viscosity [Pa*s]
%   Beta_0  : Initial    fractional order (dimensionless)
%   Beta_inf: Asymptotic fractional order (dimensionless)
%   Gamma   : Characteristic time [s]
%   Delta   : Dispersion parameter [-]
% -----------------------------------------------------------------
if strcmp(MyMaterial, 'PP')
   
    % lower and upper bounds
    lb = [ 650.0; 2.0e5; 0.0; 0.09; 7.0e2; 0.70000000];
    ub = [1500.0; 4.0e5; 0.1; 0.10; 6.0e3; 0.70000001];
    
elseif strcmp(MyMaterial, 'PVC')
    
    % lower and upper bounds
    lb = [ 650.0; 2.0e8; 0.0; 0.06; 2.0e3; 0.15];
    ub = [3000.0; 4.0e8; 0.1; 0.20; 6.0e4; 0.95];
end

% Cross-entropy (CE) method parameters (modify as needed)
CEstr.EliteFactor = 0.05;
CEstr.Nsamp       = 500;
CEstr.MaxIter     = 150;
% -----------------------------------------------------------------

% Misfit function between experimental data and model prediction
% -----------------------------------------------------------------
F = @(x) MisfitFunc(x,time,Epsilon_exp/sigma0/100);
% -----------------------------------------------------------------

% Run the calibration using the CE method
% "Since CE is a stochastic algorithm, so different results 
% will be obatined each execution of the solver"
% -----------------------------------------------------------------
disp('Running calibration using cross-entropy method...');
tic
[Xopt,Fopt,ExitFlag,CEstr] = CEopt(F,[],[],lb, ub,[],CEstr);
toc
% -----------------------------------------------------------------

% Display optimal parameters and misfit value
% -----------------------------------------------------------------
disp('Optimal Parameters:');
disp(Xopt);
disp('Optimal Misfit (%):');
disp(Fopt);
% -----------------------------------------------------------------

% Deformation curve
% -----------------------------------------------------------------
Epsilon = sigma0*DeformationEq(Xopt,time);
% -----------------------------------------------------------------

% Custom colors
% -----------------------------------------------------------------
MyBlue   = [0      0.4470 0.7410];
MyOrange = [0.8500 0.3250 0.0980];
% -----------------------------------------------------------------

% Define graph properties structure for the plot
% -----------------------------------------------------------------
graphobj.gname      = sprintf('VOSpringpotCalibration_%s_sigma0_%gMPa',MyMaterial,sigma0);
graphobj.linecolor1 = MyOrange; 
graphobj.linecolor2 = MyBlue;
graphobj.Marker1    = 'square';
graphobj.Marker2    = 'none';
graphobj.linestyle1 = ':';
graphobj.linestyle2 = '-';
graphobj.xlab       = 'Time (s)';
graphobj.ylab       = 'Deformation (%)';
graphobj.xmin       = 1e0;
graphobj.xmax       = 1e10;
graphobj.ymin       = 1e-1;
graphobj.ymax       = 1e1;
graphobj.gtitle     = sprintf('Creep Response for %s at %g MPa',MyMaterial,sigma0);
graphobj.legend1    = 'Experimental Data';
graphobj.legend2    = 'Variable-Order Springpot Model';
graphobj.signature  = 'Telles Ribeiro and Cunha Jr (2025)';
graphobj.print      = 'yes';
graphobj.close      = 'no';
% -----------------------------------------------------------------

% Plotting the Data
% -----------------------------------------------------------------
PlotLoglog2(time,Epsilon_exp,time,Epsilon*100,graphobj);
% -----------------------------------------------------------------

% Save deformation curves into a file
% -----------------------------------------------------------------
OutputTable1 = table(time,Epsilon_exp,Epsilon*100,...
                     'VariableNames', {'Time_sec',...
                                       'StrainExp_percentage',...
                                       'StrainModel_percentage'});
OutputName1 = [sprintf('VOSpringpotCalibration_%s_sigma0_%gMPa',MyMaterial,sigma0) '.csv'];
writetable(OutputTable1,OutputName1);
% -----------------------------------------------------------------

% Save calibration parameters into a file
% -----------------------------------------------------------------
OutputTable2 = table(Xopt(1),Xopt(2),Xopt(3),Xopt(4),Xopt(5),Xopt(6),...
                     'VariableNames', {'E_MPa','eta_MPa_sec',...
                                       'beta_0_dimless','beta_inf_dimless',...
                                       'gamma_sec','delta_dimless'});
OutputName2 = [sprintf('VOSpringpotParameters_%s_sigma0_%gMPa',MyMaterial,sigma0) '.csv'];
writetable(OutputTable2,OutputName2);
% -----------------------------------------------------------------



% --- Auxiliary Functions --- %

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
    
    % Compute the deformation using the springpot constitutive equation.
    % Epsilon = (1 / (gamma(Beta(t)+1)*E)) * (t/T)^Beta(t)
    Epsilon = (1./(gamma(Beta_t+1)*E)).*((t/T).^Beta_t);
end
% -----------------------------------------------------------------

% -----------------------------------------------------------------
% Function to compute the misfit between experimental and model data (in %)
% -----------------------------------------------------------------
function J = MisfitFunc(x,t,EpsExp)
    
    % Model prediction
    logEps = log(DeformationEq(x,t));

    % Compute logarithmic error
    J = sqrt(sum((log(EpsExp)-logEps).^2)/sum(log(EpsExp).^2))*100;
end
% -----------------------------------------------------------------