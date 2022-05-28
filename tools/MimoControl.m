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

    % These properties are used for LaTex wrapping
    properties (Dependent)
        ISOForm;
        StateSpace;

        % State Space Matrices (for reference purpose only)
        StateA;
        StateB;
        StateC;
        StateD;
    end

    %---------------------------- Private Properties --------------------------%
    properties (Access = private)
        p_ISOForm;
        p_C;            % Backup of constant symbolic variables
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
        function numericConstants(obj, t)
            if t
                obj.p_C = obj.C;
                obj.C = obj.Constants;
            else
                obj.C = obj.p_C;
            end
        end

        function e = findEquilibriumPoints(obj, constraints)
            const_state = sym(zeros(numel(obj.Q), 1));
            for i = 1:numel(obj.Q)
                const_state(i) = (0 == obj.p_ISOForm(i));
            end

            % Set temporary constraints
            for cs = constraints
                assume(cs);
            end

            fprintf("Finding Equilibrium Points...");
            e = solve(const_state, obj.Q, 'ReturnConditions',true);
            fprintf("Complete!\n");

            % Clear temporary constraints
            for cs = constraints
                assume(cs, 'clear');
            end
        end

        function s = StateSpaceModel(obj, q, u)
            s = obj.StateSpace;
        end


        % Controller-related methods
        function [c, rank] = controllabilityMatrix(obj)
            % TODO
        end

        function e = eigenValues(obj, m)
            % TODO
        end

        function s = stateObserver(obj, c)
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

        function val = get.StateSpace(obj)
            % Calculate state space matrices whenever required
            q_iso = obj.p_ISOForm(1:length(obj.Q));
            y_iso = obj.p_ISOForm(length(obj.Q) + 1:end);
            val.A = jacobian(q_iso, obj.Q);
            val.B = jacobian(q_iso, obj.U);
            val.C = jacobian(y_iso, obj.Q);
            val.D = 0;      % Feed-forward networks not implemented
        end

        %------------------------- LaTex Copy Functions -----------------------%

        function val = get.ISOForm(obj)
            val = obj.p_ISOForm;
            clipboard('copy', obj.latexBrace(val));
            disp("ISO Form copied to clipboard");
            disp("-----------------------------------------------------------");
        end

        function val = get.StateA(obj)
            val = obj.StateSpace.A;
            clipboard('copy', obj.latexMatrix(val));
            disp("State Space 'A' matrix copied to clipboard");
            disp("-----------------------------------------------------------");
        end

        function val = get.StateB(obj)
            val = obj.StateSpace.B;
            clipboard('copy', obj.latexMatrix(val));
            disp("State Space 'B' matrix copied to clipboard");
            disp("-----------------------------------------------------------");
        end

        function val = get.StateC(obj)
            val = obj.StateSpace.C;
            clipboard('copy', obj.latexMatrix(val));
            disp("State Space 'C' matrix copied to clipboard");
            disp("-----------------------------------------------------------");
        end
    end

end
