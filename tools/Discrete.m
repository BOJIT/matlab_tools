% FILE:         Discrete.m
% DESCRIPTION:  Discrete Time Helper Utilities
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 30/06/2022

%------------------------------------------------------------------------------%

classdef Discrete < handle

    %---------------------------- Public Properties ---------------------------%
    properties

    end

    properties (Dependent)

    end

    %---------------------------- Private Properties --------------------------%
    properties (Access = private)

    end

    properties (Access = private, Dependent)

    end

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = Discrete()

        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods (Static)
        function z = s2z(s)

        end

        function s = z2s(z)

        end

        function z_n = zDelayForm(z)

        end

        function z_n = zEvansForm(z)

        end

        function pzPlotS(s)

        end

        function pzPlotZ(z)

        end
    end

    %------------------------------ Private Methods ---------------------------%
    methods

    end

    %------------------------------ Get/Set Methods ---------------------------%
    methods

    end

end
