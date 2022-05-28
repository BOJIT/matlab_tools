% FILE:         MimoControl.m
% DESCRIPTION:  MIMO (WM363 Control Theory) Utils Class
% AUTHOR:       James Bennion-Pedley
% DEPENDENCIES: Symbolic Toolbox, Optimisation Toolbox
% DATE CREATED: 05/05/2022

%------------------------------------------------------------------------------%

classdef MimoControl < handle

    %---------------------------- Public Properties ---------------------------%
    properties
        Constants = struct;
        C;  % Constant symbolic variables

        % Symbolic variable states
        U;  % u
        Q;  % q
        Y;  % y
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
        function obj = MimoControl(dimensions, constants)
            u = sym('u', [1 dimensions(1)]);
            for el = u
                obj.U.(string(el)) = sym(el);
            end

            q = sym('q', [1 dimensions(2)]);
            for el = q
                obj.Q.(string(el)) = sym(el);
            end

            y = sym('y', [1 dimensions(3)]);
            for el = y
                obj.Y.(string(el)) = sym(el);
            end

            obj.Constants = constants;

            fns = fieldnames(obj.Constants)';
            for fn = fns
                obj.C.(fn{:}) = sym(fn{:});
            end
        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods

        function [c, rank] = controllabilityMatrix(obj)
            % TODO
        end

        function e = eigenValues(obj, m)
            % TODO
        end

        function s = stateObserver(obj, c)
            % TODO
        end

        function showWorkings(obj)
            % TODO
        end
    end

    %------------------------------ Private Methods ---------------------------%
    methods

    end

    %------------------------------ Get/Set Methods ---------------------------%
    methods

    end

end
