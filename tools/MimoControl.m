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

        % Symbolic variable states
        C;
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

        % Backup State
        p_C;
        p_U;
        p_Q;
        p_Y;
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

        %------------------------------ Model ---------------------------------%

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

        function s = stateSpaceModel(obj, q_numeric, u_numeric)
            s = obj.StateSpace;

            for fn = fieldnames(s)'
                c_fns = fieldnames(obj.Constants)';
                c_syms = sym(zeros(numel(c_fns), 1));
                c_vals = zeros(numel(c_fns), 1);
                for i = 1:numel(c_fns)
                    c_syms(i) = obj.C.(c_fns{i});
                    c_vals(i) = obj.Constants.(c_fns{i});
                end

                s.(fn{:}) = subs(s.(fn{:}), c_syms, c_vals);
                s.(fn{:}) = subs(s.(fn{:}), obj.Q, q_numeric');
                s.(fn{:}) = subs(s.(fn{:}), obj.U, u_numeric');

                s.(fn{:}) = double(round(subs(s.(fn{:})), 4));
            end
        end

        function t = transferFcn(~, s)
            % Numerical transfer function to 3.d.p
            [n, d] = ss2tf(s.A, s.B, s.C, s.D);
            syms t_full;
            t_full = poly2sym(n)/poly2sym(d);
            t = vpa(t_full, 3);
        end

        %---------------------------- Controller ------------------------------%

        function [c, rank] = controllabilityMatrix(obj)
            % TODO
        end

        function e = eigenValues(obj, m)
            % TODO
        end

        function s = stateObserver(obj, c)
            % TODO
        end

        %----------------------------- Formatting -----------------------------%

        function s = latexMatrix(~, M)
            s = "\left[\begin{matrix}";
            for r = 1:size(M, 1)
                for c = 1:size(M, 2)
                    if isa(M(r, c), 'sym')
                        s = strcat(s, latex(M(r, c)));
                    else
                        s = strcat(s, string(M(r, c)));
                    end
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
                    if isa(M(r, c), 'sym')
                        s = strcat(s, latex(M(r, c)));
                    else
                        s = strcat(s, string(M(r, c)));
                    end
                    if(c~= size(M, 2))
                        s = strcat(s, "&");
                    end
                end
                s = strcat(s, "\\");
            end
            s = strcat(s, "\end{matrix}\right.");
        end
    end

    %------------------------------ Private Methods ---------------------------%
    methods
        function backupSymbols(obj)
            obj.p_C = obj.C;
            obj.p_U = obj.U;
            obj.p_Q = obj.Q;
            obj.p_Y = obj.Y;
        end

        function restoreSymbols(obj)
            obj.C = obj.p_C;
            obj.U = obj.p_U;
            obj.Q = obj.p_Q;
            obj.Y = obj.p_Y;
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
