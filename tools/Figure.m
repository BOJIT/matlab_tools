% FILE:         Figure.m
% DESCRIPTION:  Class encapsulation for figures with opinionated formatting
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 07/04/2022

%------------------------------------------------------------------------------%

classdef Figure < handle

    %---------------------------- Public Properties ---------------------------%
    properties
        Handle      % Handle for root figure
        Axes        % Handle for root axes within
        ActiveAxes  % Selected target axes
    end

    properties (Dependent)
        Title       % Graph title
        XLabel      % X-Axis label (LaTex)
        YLabel      % Y-Axis label (LaTex)

        SuperTitle  % Set title for top of figure
        XLabels     % Set X-Axis label (LaTex) for all graphs
        YLabels     % Set Y-Axis label (LaTex) for all graphs
    end

    %---------------------------- Private Properties --------------------------%
    properties (Access = private)

    end

    properties (Access = private, Dependent)

    end

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = Figure(dimensions)
            % Create figure framework
            obj.Handle = figure();
            set(obj.Handle, 'color', 'white');

            if(nargin > 0)
                % Create array of pre-formatted axes
                obj.Axes = arrayfun(@obj.createAxes, zeros(dimensions(1)*dimensions(2), 1));

                for i = 1:size(obj.Axes, 1)
                    subplot(dimensions(1), dimensions(2), i, obj.Axes(i));
                end
            else
                obj.Axes = [obj.createAxes()];
            end

            obj.ActiveAxes = 1;
        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods
        function handle = plot(obj, varargin)
            handle = plot(obj.Axes(obj.ActiveAxes), varargin{:});
        end

        function handle = stem(obj, varargin)
            handle = stem(obj.Axes(obj.ActiveAxes), varargin{:});
        end

        function handle = arrow(obj, x, y, color)
            handle = annotation('arrow');
            handle.Parent = obj.Axes(obj.ActiveAxes);
            handle.X = x;
            handle.Y = y;
            handle.LineWidth = 1;
            if(nargin >= 4)
                handle.Color = color;
            else
                handle.Color = 'black';
            end
        end

        function scale(obj, sf)
            pos = get(obj.Handle, 'Position');
            width = pos(3); height = pos(4);
            new_pos = pos;
            new_pos(3) = round(width * sf); new_pos(4) = round(height * sf);
            set(obj.Handle, 'Position', new_pos);
        end
    end

    %------------------------------ Private Methods ---------------------------%
    methods
        function handle = createAxes(obj, varargin)
            handle = axes(obj.Handle);
            handle.NextPlot = 'add';
            set(handle, 'TickLabelInterpreter', 'latex');
            grid(handle, 'on');
        end
    end

    %------------------------------ Get/Set Methods ---------------------------%
    methods
        function set.Title(obj, val)
            title(obj.Axes(obj.ActiveAxes), val, 'interpreter', 'latex');
        end

        function set.XLabel(obj, val)
            xlabel(obj.Axes(obj.ActiveAxes), val, 'interpreter', 'latex');
        end

        function set.YLabel(obj, val)
            ylabel(obj.Axes(obj.ActiveAxes), val, 'interpreter', 'latex');
        end

        function set.SuperTitle(obj, val)
            if(length(obj.Axes) > 1)
                sgtitle(obj.Handle, val, 'interpreter', 'latex');
            end
        end

        function set.XLabels(obj, val)
            xlabel(obj.Axes, val, 'interpreter', 'latex');
        end

        function set.YLabels(obj, val)
            ylabel(obj.Axes, val, 'interpreter', 'latex');
        end
    end

end
