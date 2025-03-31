% -----------------------------------------------------------------
%  Main_VOSpringpot_Calibration2.m
% -----------------------------------------------------------------
%  programmers: Jose Geraldo Telles Ribeiro
%               Americo Cunha Jr
%
%  Originally programmed in: Mar 21, 2025
%           Last updated in: Mar 29, 2025
% -----------------------------------------------------------------
%  This program solves a calibration inverse problem to better
%  represent load dependence of mechanical properties in a 
%  variable-order springpot model for a given dataset.
% -----------------------------------------------------------------
%  Reference:
%  J. G. Telles Ribeiro and A. Cunha Jr,
%  Advanced creep modeling for polymers: A variable-order 
%  fractional calculus approach, 2025
% -----------------------------------------------------------------

clc; clear; close all;

% random number generator (fix the seed for reproducibility)
%rng_stream = RandStream('mt19937ar','Seed',30081984);
%RandStream.setGlobalStream(rng_stream);

% program header
% -----------------------------------------------------------
disp(' ---------------------------------------------------')
disp(' Main_VOSpringpot_Calibration2.m                    ')
disp(' ---------------------------------------------------')
disp(' Calibration of the load dependent properties of a  ')
disp(' Variable-Order Springpot model                     ')
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

% Model Calibration Setup
% -----------------------------------------------------------------
if strcmp(MyMaterial, 'PP')
    
    sigma0_training = [2.8 4.2 5.6 9.8 11.2 12.6];   % training loads (MPa) from Calibration1
    sigma0_test     = 1.4:0.1:14;                    % load range for plotting
    
    param = input('\n 1-Elastic modulus\n 2-Initial order\n 3-Assymptotic order\n 4-Characteristic time\n Choose the parameter:', 's');
    while ~ismember(param, {'1','2','3','4'})
        disp('Not a valid option, please try again.');
        param = input('\n 1-Elastic modulus\n 2-Initial order\n 3-Assymptotic order\n 4-Characteristic time\n Choose the parameter:', 's');
    end
    switch param
        case '1'
            name1 = 'Elastic modulus (MPa)';
            name2 = 'E';

            % Reference values from Calibration1
            refValues = [1247 1216 1178 1016 957 875]; % reference values from Calibration1
            
            % lower and upper bounds [sigmaR, n, m1, m2, m3, m4]
            lb = [ 5, 1, -80, 1000, -30, 1000];
            ub = [15, 7, -20, 2000, -10, 1500];
        case '2'
            name1 = 'Initial model order';
            name2 = 'Beta_0';

            % Reference values from Calibration1
            refValues = [0.0363 0.0397 0.0475 0.0687 0.0720 0.0866]; % reference values from Calibration1
            
            % lower and upper bounds [sigmaR, n, m1, m2, m3, m4]
            lb = [1.0e10  , 1.0e10  , 0.0    , 0.0    , 0.0 , 0.0];
            ub = [1.0e10+1, 1.0e10+1, 1.0e-10, 1.0e-10, 0.01, 0.05];
        case '3'
            name1 = 'Assymptotic model order';
            name2 = 'Beta_inf';

            % Reference values from Calibration1
            refValues = [0.1015 0.1005 0.1030 0.1147 0.1216 0.1258]; % reference values from Calibration1
            
            % lower and upper bounds [sigmaR, n, m1, m2, m3, m4]
            lb = [ 5,  2, 0.0    , 0.10, 0.0    , 0.09];
            ub = [15, 10, 1.0e-10, 0.15, 1.0e-10, 0.11];
        case '4'
            name1 = 'Characteristic time (s)';
            name2 = 'Gam';

            % Reference values from Calibration1
            refValues = [4.4e3, 3.76e3, 3.11e3, 1.2e3, 1.2e3, 1.2e3]; % reference values from Calibration1

            % lower and upper bounds [sigmaR, n, m1, m2, m3, m4]
            lb = [ 5,  5, 0.0    ,  900, -1000, 4000];
            ub = [15, 20, 1.0e-10, 2000, -100 , 6000];
    end
elseif strcmp(MyMaterial, 'PVC')

    sigma0_training = [10 20 25 35];   % training loads (MPa) from Calibration1
    sigma0_test     = 10:0.1:40;       % load range for plotting
    
    param = input('\n 1-Elastic modulus\n 2-Initial order\n 3-Assymptotic order\n 4-Characteristic time\n 5-Shaping exponent\n Choose the parameter:', 's');
    while ~ismember(param, {'1','2','3','4','5'})
        disp('Not a valid option, please try again.');
        param = input('\n 1-Elastic modulus\n 2-Initial order\n 3-Assymptotic order\n 4-Characteristic time\n 5-Shaping exponent\n Choose the parameter:', 's');
    end
    switch param
        case '1'
            name1 = 'Elastic modulus (GPa)';
            name2 = 'E';

            % Reference values from Calibration1
            refValues = [2623.70 2207.08 1876.81 1082.01]; % reference values from Calibration1

            % lower and upper bounds [sigmaR, n, m1, m2, m3, m4]
            lb = [10, 1, -100, 2000, -50, 2000];
            ub = [25, 7, - 50, 4000, -10, 5000];
        case '2'
            name1 = 'Initial model order';
            name2 = 'Beta_0';
            
            % Reference values from Calibration1
            refValues = [0.0148, 0.0260, 0.0291, 0.0611]; % reference values from Calibration1

            % lower and upper bounds [sigmaR, n, m1, m2, m3, m4]
            lb = [20,  5, 0.0 , -0.1, 0.0 , -0.01];
            ub = [24, 10, 0.01,  0.0, 0.01,  0.0 ];
        case '3'
            name1 = 'Final model order';
            name2 = 'Beta_inf';
            
            % Reference values from Calibration1
            refValues = [0.0689, 0.0750, 0.1091, 0.1774]; % reference values from Calibration1

            % lower and upper bounds [sigmaR, n, m1, m2, m3, m4]
            lb = [20,  8, 0.0    , 0.10, 0.0    , 0.04];
            ub = [30, 15, 1.0e-10, 0.20, 1.0e-10, 0.08];
        case '4'
            name1 = 'Characteristic time (s)';
            name2 = 'Gam';
            
            % Reference values from Calibration1
            refValues = [3.66e4, 9.43e3, 6e3, 2.4e3]; % reference values from Calibration1

            % lower and upper bounds [sigmaR, n, m1, m2, m3, m4]
            lb = [10, 2, 0.0    , 2000, -2000, 40000];
            ub = [20, 5, 1.0e-10, 3000, -1000, 60000];
        case '5'
            name1 = 'Shaping exponent';
            name2 = 'Delta';
            
            % Reference values from Calibration1
            refValues = [0.578, 0.4174, 0.265, 0.22]; % reference values from Calibration1

            % lower and upper bounds [sigmaR, n, m1, m2, m3, m4]
            lb = [20, 10, 0.0    , 0.0, -0.02, 0.0];
            ub = [30, 20, 1.0e-10, 0.3,  0.0 , 1.0];
    end
end

% Cross-entropy (CE) method parameters (modify as needed)
CEstr.EliteFactor = 0.05;
CEstr.Nsamp       = 500;
CEstr.MaxIter     = 150;
% -----------------------------------------------------------------

% Misfit function
% -----------------------------------------------------------------
F = @(x) MisfitFunc(x,sigma0_training,refValues);
% -----------------------------------------------------------------

% Run the calibration using the CE method
% "Since CE is a stochastic algorithm, so different results 
% will be obatined each execution of the solver"
% -----------------------------------------------------------------
disp('Running calibration using cross-entropy method...');
tic
[Xopt,Fopt,ExitFlag,CEstr] = CEopt(F,[],[],lb,ub,[],CEstr);
toc
% -----------------------------------------------------------------

% Display optimal parameters and misfit value
% -----------------------------------------------------------------
disp('Optimal Parameters:');
disp(Xopt);
disp('Optimal Misfit (%):');
disp(Fopt);
% -----------------------------------------------------------------

% Material parameter curve
% -----------------------------------------------------------------
M = PhenomEq(sigma0_test,Xopt);
% -----------------------------------------------------------------

% Custom colors
% -----------------------------------------------------------------
MyBlue   = [0      0.4470 0.7410];
MyOrange = [0.8500 0.3250 0.0980];
% -----------------------------------------------------------------

% Define graph properties structure for the plot
% -----------------------------------------------------------------
graphobj.gname      = sprintf('VOSpringpot_%s_%s',MyMaterial,name2);
graphobj.linecolor1 = MyBlue; 
graphobj.linecolor2 = MyOrange;
graphobj.Marker1    = 'square';
graphobj.Marker2    = 'none';
graphobj.linestyle1 = 'none';
graphobj.linestyle2 = '-';
graphobj.xlab       = 'Applied load (MPa)';
graphobj.ylab       = name1;
graphobj.xmin       = round(min(sigma0_training));
graphobj.xmax       = round(max(sigma0_training));
graphobj.ymin       = 'auto';
graphobj.ymax       = 'auto';
graphobj.gtitle     = ' ';
graphobj.legend1    = 'Fitted values';
graphobj.legend2    = 'Phenomenological model';
graphobj.signature  = 'Telles Ribeiro and Cunha Jr (2025)';
graphobj.print      = 'yes';
graphobj.close      = 'no';
% -----------------------------------------------------------------

% Plot the data using the auxiliary plotting function (PlotSemilogx2.m)
%fig = PlotSemilogx2(time_sec, epsilon_exp, time_sec, epsilon_model, graphobj);

% Plotting the Data
% -----------------------------------------------------------------
Plot2(sigma0_training,refValues,sigma0_test,M,graphobj);
% -----------------------------------------------------------------


% --- Auxiliary Functions --- %

% -----------------------------------------------------------------
% PhenomEq: Phenomenological equation for material parameters.
% -----------------------------------------------------------------
function M = PhenomEq(sigma0,x)

    % x = [sigmaR,n,m1,m2,m3,m4] 
    % x is a vector of model parameters
    sigmaR = x(1);
    n      = x(2);
    m1     = x(3);
    m2     = x(4);
    m3     = x(5);
    m4     = x(6);
    
    % Compute the parameter M based on the phenomenological model
    num = (m1*sigma0 + m2).*(sigma0./sigmaR).^n + m3*sigma0 + m4;
    den = (sigma0./sigmaR).^n + 1;
    M   = num./den;
end
% -----------------------------------------------------------------

% -----------------------------------------------------------------
% Function to compute the misfit between experimental and model data (in %)
% -----------------------------------------------------------------
function J = MisfitFunc(x,sigma0,M_exp)
    
    % Compute the phenomenological parameter for each load value
    M_model = PhenomEq(sigma0,x);
    
    % Compute misfit function
    J = 100*sqrt(sum((M_exp - M_model).^2)/sum(M_exp.^2));
end
% -----------------------------------------------------------------