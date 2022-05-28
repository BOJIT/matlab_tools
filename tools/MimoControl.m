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
        ISOForm;
    end

    %---------------------------- Private Properties --------------------------%
    properties (Access = private)
        p_ISOForm;
    end

    properties (Access = private, Dependent)

    end

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = MimoControl(dimensions, constants)
            obj.U = sym('u', [1 dimensions(1)]);

            obj.Q = sym('q', [1 dimensions(2)]);

            obj.Y = sym('y', [1 dimensions(3)]);

            obj.Constants = constants;

            fns = fieldnames(obj.Constants)';
            for fn = fns
                obj.C.(fn{:}) = sym(fn{:});
            end

            sympref('MatrixWithSquareBrackets',true);
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
        function s = latexMatrix(~, M)
            s = "\left[\begin{matrix}";
            for r = 1:size(M, 1)
                for c = 1:size(M, 2)
                    s = strcat(s, latex(M(r, c)));
                    if(c~= size(M, 2))
                        s = strcat(s, "&");
                    end
                end
                s = strcat(s, "\\");
            end
            s = strcat(s, "\end{matrix}\right]");
        end

        function s = latexBrace(~, M)
            s = "\left\{\begin{matrix}";
            for r = 1:size(M, 1)
                for c = 1:size(M, 2)
                    s = strcat(s, latex(M(r, c)));
                    if(c~= size(M, 2))
                        s = strcat(s, "&");
                    end
                end
                s = strcat(s, "\\");
            end
            s = strcat(s, "\end{matrix}\right.");
        end
    end

    %------------------------------ Get/Set Methods ---------------------------%
    methods
        function set.ISOForm(obj, val)
            terms = numel(obj.Q) + numel(obj.Y);
            if terms ~= length(val)
                error("Invalid ISO Form! Expecting %d Equations.", terms);
            end

            obj.p_ISOForm = val;
        end

        function val = get.ISOForm(obj)
            val = obj.p_ISOForm;
            clipboard('copy', obj.latexBrace(val));
            disp("ISO Form copied to clipboard");
            disp("-----------------------------------------------------------");
        end
    end

end
