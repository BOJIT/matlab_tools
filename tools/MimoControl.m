% FILE:         MimoControl.m
% DESCRIPTION:  MIMO (WM363 Control Theory) Utils Class
% AUTHOR:       James Bennion-Pedley
% DEPENDENCIES: Symbolic Toolbox, Optimisation Toolbox
% DATE CREATED: 05/05/2022

% General workflow:
% - Initialise object with correct state space dimensions and constants
% - Set the symbolic ISO form
% - Get symbolic state-space (non-linear)
% - Get all numeric equilibrium points
% - Set chosen equilibrium point
% - get transfer function at this point
% - check controllability state

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
        EquilibriumStateSpace;
        ControllabilityMatrix;
        ObservabilityMatrix;

        % State Space Matrices (for reference purpose only)
        StateA;
        StateB;
        StateC;
        StateD;
    end

    %---------------------------- Private Properties --------------------------%
    properties (Access = private)
        % Actual ISO Form
        p_ISOForm;

        % Numerical Equilibrium Point
        p_Q_Numeric = [];
        p_U_Numeric = [];
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

        function setEquilibriumPoints(obj, q, u)
            obj.p_Q_Numeric = q;
            obj.p_U_Numeric = u;
        end

        function t = transferFcn(~, s)
            % Numerical transfer function to 3.d.p
            [n, d] = ss2tf(s.A, s.B, s.C, s.D);
            syms t_full s;
            t_full = poly2sym(n, s)/poly2sym(d, s);
            t = vpa(t_full, 3);
        end

        function out = sym2tf(~, in)
            [n, d] = numden(in);
            n_coeff = sym2poly(n);
            d_coeff = sym2poly(d);
            out = tf(n_coeff, d_coeff);
        end

        %---------------------------- Controller ------------------------------%

        function t = isControllable(obj)
            r = rank(obj.ControllabilityMatrix);
            s = numel(obj.Q);
            fprintf("Controllability Matrix Rank: %d, State Dimensions: %d\n", r, s);
            t = (r == s);
        end

        function t = isObservable(obj)
            r = rank(obj.ObservabilityMatrix);
            s = numel(obj.Q);
            fprintf("Observability Matrix Rank: %d, State Dimensions: %d\n", r, s);
            t = (r == s);
        end

        function k = stateFeedbackController(obj, e)
            k = place(obj.EquilibriumStateSpace.A, obj.EquilibriumStateSpace.B, e);
        end

        %------------------------------ Plotting ------------------------------%

        function launchDesigner(obj, g)
            t = obj.sym2tf(g);
            controlSystemDesigner(t);
        end

        function plotRootLoci(obj, sys)
            f1 = Figure;
            rlocus(f1.Axes(1), obj.sym2tf(sys));
            f1.Title = "Positive Root Locus";

            f2 = Figure;
            rlocus(f2.Axes(1), -obj.sym2tf(sys));
            f2.Title = "Negative Root Locus";
        end

        function f = plotEigenValues(~, v)
            e = eig(v);

            f = Figure;
            ax = f.Axes(1);
            f.plot(e, "*");
            f.XLabel = "Real Axis";
            f.YLabel = "Imaginary Axis";
            ax.XAxisLocation = 'origin';
            ax.YAxisLocation = 'origin';
        end

        function f = plotStepResponse(obj, K)
            A_CL = obj.EquilibriumStateSpace.A - obj.EquilibriumStateSpace.B*K;
            sys_cl = ss(A_CL, obj.EquilibriumStateSpace.B, ...
                        obj.EquilibriumStateSpace.C, obj.EquilibriumStateSpace.D);

            f = Figure;
            step(f.Axes(1), sys_cl);
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
    methods (Access = private)

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

        function val = get.EquilibriumStateSpace(obj)
            if numel(obj.Q) ~= numel(obj.p_Q_Numeric)
                error("Equilibrium 'q' not set!");
            end

            if numel(obj.U) ~= numel(obj.p_U_Numeric)
                error("Equilibrium 'u' not set!");
            end

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
                s.(fn{:}) = subs(s.(fn{:}), obj.Q, obj.p_Q_Numeric');
                s.(fn{:}) = subs(s.(fn{:}), obj.U, obj.p_U_Numeric');

                s.(fn{:}) = double(round(subs(s.(fn{:})), 4));
            end

            val = s;
        end

        function val = get.ControllabilityMatrix(obj)
            val = ctrb(obj.EquilibriumStateSpace.A, obj.EquilibriumStateSpace.B);
            clipboard('copy', obj.latexMatrix(val));
            disp("Controllability Matrix copied to clipboard");
            disp("-----------------------------------------------------------");
        end

        function val = get.ObservabilityMatrix(obj)
            val = obsv(obj.EquilibriumStateSpace.A, obj.EquilibriumStateSpace.C);
            clipboard('copy', obj.latexMatrix(val));
            disp("Observability Matrix copied to clipboard");
            disp("-----------------------------------------------------------");
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
