% FILE:         DiscreteController.m
% DESCRIPTION:  Discrete Controller Utils
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 30/06/2022

%------------------------------------------------------------------------------%

classdef DiscreteController < handle

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = DiscreteController()

        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods (Static)
        function j = juryCriterion(P_z)
            % P_z is the characteristic polynomial - d_p are the coefficients
            d_p = sym2poly(vpa(P_z, 4));

            % Condition 1
            if abs(d_p(end)) < d_p(1)
                fprintf("Condition 1 Satisfied: %.3f < %.3f\n\n", d_p(end), d_p(1));
            else
                j = 0;
                warning("Condition 1 Not Satisfied: %.3f >= %.3f\n\n", d_p(end), d_p(1));
                return;
            end

            % Condition 2
            Pplus1 = vpa(subs(P_z, 'z', 1), 3);
            if Pplus1 > 0
                fprintf("Condition 2 Satisfied: %.3f > 0\n\n", Pplus1);
            else
                j = 0;
                warning("Condition 2 Not Satisfied: %.3f <= 0\n\n", Pplus1);
                return;
            end

            % Condition 3
            Pminus1 = vpa(subs(P_z, 'z', -1), 3);
            if mod(length(d_p), 2) == 0 % Odd
                if Pminus1 < 0
                    fprintf("Condition 3 Satisfied: %.3f < 0\n\n", Pminus1);
                else
                    j = 0;
                    warning("Condition 3 Not Satisfied: %.3f >= 0\n\n", Pminus1);
                    return;
                end
            else
                if Pminus1 > 0
                    fprintf("Condition 3 Satisfied: %.3f > 0\n\n", Pminus1);
                else
                    j = 0;
                    warning("Condition 3 Not Satisfied: %.3f <= 0\n\n", Pminus1);
                    return;
                end
            end

            % Condition 4: Generate Jury Table
            n = length(d_p) - 1;
            s = 0;  % Stop value increment

            j = zeros(2*n - 3, n + 1);
            j(1, :) = flip(d_p(:));

            for row = 2:size(j, 1)
                if (mod(row, 2) == 1)
                    s = s + 1;
                    for k = 0:(n - s)
                        j(row, n - s - k + 1) = det([j(row - 1, n - s + 2), j(row - 1, n - s - k + 1);
                                                     j(row - 1, 1), j(row - 1, k + 2)]);
                    end
                else
                    j(row, 1:n - s + 1) = flip(j(row - 1, 1:n - s + 1));
                end
            end

            jury_table = LaTex.matrix(j);
            fprintf("Condition 4: Check Table \n\n");
            disp(j);
            LaTex.copy(jury_table);
        end

        function C_z = compensator()
            syms K a b z;
            C_z = K*(z - a)/(z - b);
        end

        function [O_l, C_l] = controller(C_z, G_z)
            O_l = vpa(C_z*G_z, 4);
            C_l = vpa(O_l/(1 + O_l), 4);
        end

        function stepResponse(z, Ts)
            z_tf = Domain.sym2tf(z, Ts);

            [y, t] = step(z_tf);
            d = stepinfo(z_tf);

            f = Figure();
            f.Title = sprintf("Unit Step Response for $$%s$$, $$T_s = %.3f$$\n", LaTex.eq(z), Ts);
            f.XLabel = "Time (seconds)";
            f.YLabel = "Amplitude";
            f.stem(t, y, 'b');
            f.plot(t, y, '-r');

            % TODO overlay target line, settling specs, percentage overshoot, etc...
        end

        function plotTargetPoleLocation()

        end

    end

end
