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

        function ts = impulse(obj, length)
            pad = zeros(1, length - 1);
            ts = obj.signal([1, pad]);
        end

        function ts = step(obj, length, offset)
            if(nargin > 2)
                % ts = obj.signal(ones(1, length), offset);
                padl = zeros(1, offset);
                padr = ones(1, length - offset);
                ts = obj.signal([padl, padr]);
            else
                ts = obj.signal(ones(1, length));
            end
        end

        % Create a convolution stem plot of a signal and a window
        function convolutionPlot(obj, signal, filter)
            c = Figure([2, 1]);

            c.SuperTitle = "Convolution of $X(n)$ with respect to filter $H(n)$";
            c.XLabel = "Coefficient (n)";
            % c.XLabels = "sample number (n)";

            % Plot figure as time-series data
            c.ActiveAxes = 1;
            c.stem(filter, 'b', 'fill');

            % Get filter response by convolution
            response = conv(signal.Data, filter);
            rdata = obj.signal(response);

            % Plot impulse response
            c.ActiveAxes = 2;
            c.XLabel = "sample time (s)";

            c.stem(signal.Time, signal.Data, 'b', 'fill');
            c.stem(rdata.Time, rdata.Data, 'r', 'fill');

        end
    end

    %------------------------------ Private Methods ---------------------------%
    methods

    end

    %------------------------------ Get/Set Methods ---------------------------%
    methods

    end

end
