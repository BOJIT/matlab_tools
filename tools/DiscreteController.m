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

        function [CG_z, W_z] = controller(C_z, G_z)
            CG_z = vpa(C_z*G_z, 4);
            W_z = vpa(CG_z/(1 + CG_z), 4);
        end

        function stepResponse(W_z, Ts, Tsettle)
            z_tf = Domain.sym2tf(W_z, Ts);

            [y, t] = step(z_tf);

            if(nargin >= 3)
                d = stepinfo(z_tf, 'SettlingTimeThreshold', Tsettle);
            else    % default threshold = 2%;
                d = stepinfo(z_tf);
            end

            f = Figure();
            f.XLabel = "Time (seconds)";
            f.YLabel = "Amplitude";
            f.stem(t, y, 'b');
            f.plot(t, y, '-r');

            % Metadata
            yline(f.Axes(1), 1, '--k');
            xline(f.Axes(1), d.SettlingTime, '--g', 'LineWidth', 2);

            f.Title = sprintf("Unit Step Response for $$W_z = %s$$\n\n $$T_{sample} = %.3f$$, Percentage Overshoot $$= %.3f$$, Settling Time $$= %.3f$$ s\n", LaTex.eq(W_z), Ts, d.Overshoot, d.SettlingTime);
        end

        function rootLocus(G_z, Ts)
            f = Figure();
            z_tf = Domain.sym2tf(G_z, Ts);
            rlocus(f.Axes(1), z_tf);
            zgrid;
            xlim([-1.2, 1.2]);
            ylim([-1.2, 1.2]);
            axis equal;
            f.XLabel = "Real Axis";
            f.YLabel = "Imaginary Axis";
            f.Title = "Root Locus for $$G_z$$";
        end

        function targetPoleLocation()
            %
        end

    end

end
