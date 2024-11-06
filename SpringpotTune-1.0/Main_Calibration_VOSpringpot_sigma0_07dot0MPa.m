% -----------------------------------------------------------------
%  Main_Calibration_VOSpringpot_sigma0_07dot0MPa.m
% -----------------------------------------------------------------
%  programmers: Jose Geraldo Telles Ribeiro
%               Americo Cunha Jr
%
%  Originally programmed in: Sep 11, 2024
%           Last updated in: Nov 06, 2024
% -----------------------------------------------------------------
% ﻿ Model calibration for a variable-order springpot model
%  (fractional rheological model) using the cross-entropy method.
% -----------------------------------------------------------------

clc; clear; close all;

disp(' ----------------------------------------------- ')
disp(' Main_Calibration_VOSpringpot_sigma0_07dot0MPa.m ')
disp(' ----------------------------------------------- ')

% random number generator (fix the seed for reproducibility)
%rng_stream = RandStream('mt19937ar','Seed',30081984);
%RandStream.setGlobalStream(rng_stream);

% Load experimental data for polypropilene
% time (days) and deformation (%)
load PP5.mat;

% Define time (s) and deformation (mu-strain)/sigma0 data series
time   = time*60*60*24;
EpsExp = 0.01*deformation/sigma0;

% Objective function (minimize the discrepancy)
F = @(x) MisfitFunc(x,time,EpsExp);

% Define bounds for model parameters
% (E,eta,beta0,beta_inf,Gama)
lb = [0.7e3; 100.0e3; 0.001; 0.05; 0.5e3];
ub = [1.5e3; 800.0e3; 0.460; 0.14; 7.0e3];

% Initial mean and standard deviation vectors
x0      = [1.2e3; 572.0e3; 0.02; 0.09; 5.0e3];
StdDev0 = 0.01*ones(5,1);

% Define control parameters for CEopt
CEstr.EliteFactor  = 0.05;    % Elite samples percentage
CEstr.Nsamp        = 500;     % Number of samples
CEstr.MaxIter      = 150;     % Maximum number of iterations
CEstr.TolAbs       = 1.0e-5;  % Absolute tolerance
CEstr.TolRel       = 1.0e-5;  % Relative tolerance
CEstr.alpha        = 0.9;     % Smoothing parameter


% Run CEopt with MisfitFunc as the function handle
tic
[Xopt, Fopt, ExitFlag, CEstr] = CEopt(F,x0,[],lb,ub,[],CEstr);
toc

% Display results
disp('Optimal Parameters:');
disp(Xopt);
disp('Optimal Misfit:');
disp(Fopt);

% Custom colors
MyBlue   = [0 0.4470 0.7410];
MyOrange = [0.8500 0.3250 0.0980];

% Define graph properties structure for the plot
graphobj.gname      = 'VO-Springpot_sigma0_07dot0MPa';
graphobj.linecolor1 = MyOrange; 
graphobj.linecolor2 = MyBlue;
graphobj.Marker1    = 'square';
graphobj.Marker2    = '<';
graphobj.linestyle1 = ':';
graphobj.linestyle2 = '-';
graphobj.xlab       = 'Time t (s)';
graphobj.ylab       = 'Deformation \epsilon (%)';
graphobj.xmin       = 'auto';
graphobj.xmax       = 'auto';
graphobj.ymin       = 'auto';
graphobj.ymax       = 'auto';
graphobj.gtitle     = 'Variable-Order Springpot';
graphobj.legend1    = 'Experimental Data';
graphobj.legend2    = 'Variable-Order Springpot';
graphobj.signature  = 'Telles Ribeiro and Cunha Jr (2024)';
graphobj.print      = 'yes';
graphobj.close      = 'no';

% Plot the two time series
PlotSemilogx2(time,EpsExp*sigma0/0.01,...
              time,DeformationFunc(Xopt,time)*sigma0/0.01,graphobj);


% Deformation function
% -----------------------------------------------------------------
function Eps = DeformationFunc(x,t)
    % model parameters
    E        = x(1);
    eta      = x(2);
    beta0    = x(3);
    beta_inf = x(4);
    Gam      = x(5);
    % material time scale
    T = eta/E;
    % time-dependent order
    beta_t = (beta_inf*(t/Gam)+beta0)./((t/Gam)+1);
    % deformation
    Eps = (1./(gamma(beta_t+1)*E)).*((t/T).^beta_t);
end
% -----------------------------------------------------------------

% Misfit function
% -----------------------------------------------------------------
function J = MisfitFunc(x,t,EpsExp)
    logEps = log(DeformationFunc(x,t));
    J      = sqrt(sum((log(EpsExp)-logEps).^2)/sum(log(EpsExp).^2))*100;
end
% -----------------------------------------------------------------