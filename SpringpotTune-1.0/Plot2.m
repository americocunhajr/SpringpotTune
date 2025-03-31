% -----------------------------------------------------------------
%  Plot2.m
% -----------------------------------------------------------------
%  Programmer: Americo Cunha Jr
%
%  Originally programmed in: Aug 30, 2024
%           Last updated in: Mar 31, 2025
% -----------------------------------------------------------------
% This function plots two temporal curves from given datasets
% in linear scale.
% 
% Input:
% time1    - temporal vector 1
% data1    - dependent variable 1
% time2    - temporal vector 2
% data2    - dependent variable 2
% graphobj - struct containing graph configuration parameters
%
% Output:
% fig       - the handle to the created figure
% ----------------------------------------------------------------- 
function fig = Plot2(time1,data1,time2,data2,graphobj)
    
    % Check number of arguments
    if nargin < 5
        error('Too few inputs.');
    elseif nargin > 5
        error('Too many inputs.');
    end

    % Check arguments for length compatibility
    if length(time1) ~= length(data1)
        error('time1 and data1 vectors must be the same length');
    end
    if length(time2) ~= length(data2)
        error('time2 and data2 vectors must be the same length');
    end

    % Ensure time and data are row vectors
    if iscolumn(time1)
        time1 = time1';
    end
    if iscolumn(data1)
        data1 = data1';
    end
    if iscolumn(time2)
        time2 = time2';
    end
    if iscolumn(data2)
        data2 = data2';
    end
    
    % Create the figure
    fig = figure('Name', graphobj.gname, 'NumberTitle', 'off');
    
    % Plot the first time series
    plot(time1, data1, 'LineWidth'  , 2, ...
                       'Color'      , graphobj.linecolor1, ...
                       'LineStyle'  , graphobj.linestyle1, ...
                       'Marker'     , graphobj.Marker1, ...
                       'DisplayName', graphobj.legend1);
    hold on;
    
    % Plot the second time series
    plot(time2, data2, 'LineWidth'  , 2, ...
                       'Color'      , graphobj.linecolor2, ...
                       'LineStyle'  , graphobj.linestyle2, ...
                       'Marker'     , graphobj.Marker2, ...
                       'DisplayName', graphobj.legend2);
    hold off;

    % Set figure and axis properties
    set(gcf, 'Color', 'white');
    set(gca, 'Position', [0.15 0.15 0.75 0.75]);
    set(gca, 'Box', 'on');
    set(gca, 'TickDir', 'out', 'TickLength', [0.02 0.02]);
    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on');
    set(gca, 'FontName', 'Helvetica', 'FontSize', 16);
    grid on;

    % Set axis limits
    xlim([min([min(time1), min(time2)]), max([max(time1), max(time2)])]);
    if ~strcmp(graphobj.ymin, 'auto') && ~strcmp(graphobj.ymax, 'auto')
        ylim([graphobj.ymin graphobj.ymax]);
    else
        ylim('auto');
    end

    % Labels and title
    xlabel(graphobj.xlab,  'FontSize', 18);
    ylabel(graphobj.ylab,  'FontSize', 18);
    title(graphobj.gtitle, 'FontSize', 20, 'FontWeight', 'bold');

    % Legend
    legend('show', 'Location', 'best', 'FontSize', 14);
    %legend('boxoff'); % Optional: turn off legend box

    % Add logo image to the southwest part of the plot
    axes('Position', [0.7 0.15 0.15 0.15]);
    imshow('SpringpotTune.png');
    axis off;

    % Annotation
    if isfield(graphobj, 'signature') && ~isempty(graphobj.signature)
        annotation('textbox', [0.95, 0.2, 0.5, 0.5], 'String', ...
            graphobj.signature, 'FontSize', 12, 'Color', [0.5 0.5 0.5], ...
            'Rotation', 90, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', 'EdgeColor', 'none');
    end

    % Export plot if required
    if strcmp(graphobj.print, 'yes')
        print('-depsc2', [graphobj.gname,'.eps']);
        print('-dpng'  , [graphobj.gname,'.png']);
    end

    % Close figure if requested
    if strcmp(graphobj.close, 'yes')
        close(fig);
    end
end
% -----------------------------------------------------------------