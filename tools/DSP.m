% FILE:         DSP.m
% DESCRIPTION:  Digital Signal Toolbox Processing for MATLAB
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 07/04/2022

%------------------------------------------------------------------------------%

classdef DSP < handle

    %---------------------------- Public Properties ---------------------------%
    properties
        Signal,
        Window,
    end

    %---------------------------- Private Properties --------------------------%
    properties (Access = private)

    end

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = DSP()

        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods
        function convolutionPlot(obj, signal, window)
            c = Figure([2, 1]);

            c.SuperTitle = "Convolution of $X(n)$ with respect to window $H(n)$";
            c.XLabels = "sample number (n)";

            c.ActiveAxes = 1;
            c.stem(signal, 'b', 'fill');


        end
    end
        
    %------------------------------ Private Methods ---------------------------%
    methods
        
    end

    %------------------------------ Get/Set Methods ---------------------------%
    methods
        
    end

end
