% FILE:         DSP.m
% DESCRIPTION:  Digital Signal Toolbox Processing for MATLAB
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 07/04/2022

%------------------------------------------------------------------------------%

classdef DSP < handle

    %---------------------------- Public Properties ---------------------------%
    properties
        SampleRate,     % Signal sample rate in Hz
        Signal,
        Window,
    end

    %---------------------------- Private Properties --------------------------%
    properties (Access = private)

    end

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = DSP(samplerate)
            if(nargin > 0)
                obj.SampleRate = samplerate;
            end
        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods
        % Create timeseries data based on global sample rate
        function ts = signal(obj, data, offset)
            if(nargin < 3)
                offset = 0;
            end

            times = (0 + offset):(1/obj.SampleRate):((length(data) - 1)*(1/obj.SampleRate) + offset);
            ts = struct;
            ts.Time = times;
            ts.Data = data;
        end

        % Create a convolution stem plot of a signal and a window
        function convolutionPlot(obj, signal, window)
            c = Figure([2, 1]);

            c.SuperTitle = "Convolution of $X(n)$ with respect to window $H(n)$";
            c.XLabels = "sample number (n)";

            c.ActiveAxes = 1;
            c.stem(signal.Time, signal.Data, 'b', 'fill');


        end
    end
        
    %------------------------------ Private Methods ---------------------------%
    methods
        
    end

    %------------------------------ Get/Set Methods ---------------------------%
    methods
        
    end

end
