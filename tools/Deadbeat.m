% FILE:         Deadbeat.m
% DESCRIPTION:  Deadbeat Controller Design Utilities
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 07/07/2022

%------------------------------------------------------------------------------%

classdef Deadbeat < handle

    properties (Constant)
        z = sym('z');
        T = sym('T');
        UnitStep = 1/(1 - Deadbeat.z^-1);
        UnitRamp = (Deadbeat.T*Deadbeat.z^-1)/((1 - Deadbeat.z^-1)^2);
        UnitParabola = (Deadbeat.T^2*Deadbeat.z^-1)*(1 + Deadbeat.z^-1)/(2*(1 - Deadbeat.z^-1)^3);
    end

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = Deadbeat()

        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods (Static)
        function checkPossible(C_z, G_z)

        end

        function checkStability(C_z, G_z)

        end

        function design(C_z, G_z)

        end
    end
end
