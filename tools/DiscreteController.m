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

        function stepResponse(W_z, Ts, Settle_Threshold)
            z_tf = Domain.sym2tf(W_z, Ts);

            [y, t] = step(z_tf);

            if(nargin >= 3)
                d = stepinfo(z_tf, 'SettlingTimeThreshold', Settle_Threshold);
            else    % default threshold = 2%;
                d = stepinfo(z_tf);
            end

            f = Figure();
            f.scale(1.5);
            f.XLabel = "Time (seconds)";
            f.YLabel = "Amplitude";
            f.stem(t, y, 'b');
            f.plot(t, y, '-r');

            % Metadata
            yline(f.Axes(1), 1, '--k');
            xline(f.Axes(1), d.SettlingTime, '--g', 'LineWidth', 2);

            f.Title = sprintf("Unit Step Response for $$W(z) = %s$$\n\n $$T_{sample} = %.3f$$, Percentage Overshoot $$= %.3f$$, Settling Time $$= %.3f$$ s\n", LaTex.eq(W_z), Ts, d.Overshoot, d.SettlingTime);
        end

        function rootLocus(G_z, Ts)
            f = Figure();
            f.scale(1.5);
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

        function target = targetPoleLocation(Ts, varargin)
            W_s = (2*pi)/Ts;

            % All possible symbolic variables
            SettlingTime = sym('SettlingTime');
            SamplesPerCycle = sym('SamplesPerCycle');
            Overshoot = sym('Overshoot');
            DampingRatio = sym('DampingRatio');

            % Parse inputs
            p = inputParser;
            addOptional(p,'SettlingTime', SettlingTime, @isnumeric);
            addOptional(p,'SettleThreshold', 0.02, @isnumeric);
            addOptional(p,'SamplesPerCycle', SamplesPerCycle, @isnumeric);
            addOptional(p,'Overshoot', Overshoot, @isnumeric);
            addOptional(p,'DampingRatio', DampingRatio, @isnumeric);
            parse(p, varargin{:});
            e = p.Results;

            % Find Delta
            delta_sym = {
                vpa(subs(e.DampingRatio), 4);
                vpa((abs(log(e.Overshoot))/sqrt(pi^2 + log(e.Overshoot)^2)), 4);
            };

            delta = cellfun(@Maths.isSolved, delta_sym);
            delta = rmmissing(delta);
            if isempty(delta)
                error("System not fully defined!");
            end

            % Find Damped Natural Frequency
            W_d_sym = {
                subs(W_s/e.SamplesPerCycle);
                subs((abs(log(e.SettleThreshold))/(delta*e.SettlingTime))*sqrt(1 - delta.^2));
            };

            W_d = cellfun(@Maths.isSolved, W_d_sym);
            W_d = rmmissing(W_d);
            if isempty(W_d)
                error("System not fully defined!");
            end

            fprintf("Target Specifications: delta = %.3f, W_d = %.3f\n", delta, W_d);

            % Convert to pole specifications
            z_mod = exp(-Ts*(delta*W_d)/sqrt(1 - delta^2));
            z_arg = Ts*W_d;
            [x_z,y_z] = pol2cart(z_arg, z_mod);
            target = x_z + 1i*y_z;

            fprintf("Dominant Pole Target: |z| = %.3f, <z = %.3f rad\n\n", z_mod, z_arg);

            % Plot target position in the frequency domain
            f = Figure();
            f.scale(1.5);
            zgrid;
            xlim([-1.2, 1.2]);
            ylim([-1.2, 1.2]);
            axis equal;
            f.XLabel = "Real Axis";
            f.YLabel = "Imaginary Axis";
            f.Title = sprintf("Target Pole Location for $$\\delta = %.3f$$, $$W_d = %.3f$$", delta, W_d);
            f.plot(target, '*', 'Color', 'r'); % Desired pole
            legend({'Unit Circle', 'Constant Damping', 'Constant Frequency', 'Target Pole'}, 'location', 'eastoutside');
        end

        function [phase_gap, real_loc, target_gain] = evaluateCompensator(CG_z, Ts, target)
            % Plot poles, zeros and targets
            f = Figure();
            f.scale(1.5);

            z_tf = Domain.sym2tf(CG_z, Ts);
            pzmap(f.Axes(1), z_tf);

            zgrid;
            xlim([-1.2, 1.2]);
            ylim([-1.2, 1.2]);
            axis equal;
            f.XLabel = "Real Axis";
            f.YLabel = "Imaginary Axis";
            f.Title = "Pole-Zero Map for $$C(z)*G(z)$$ with respect to target pole";
            f.plot(target, '*', 'Color', 'r'); % Desired pole

            % Plot zoining lines and find total gamma offset
            z_p = pole(z_tf);
            z_z = zero(z_tf);
            gamma_p = zeros(1, length(z_p));
            gamma_z = zeros(1, length(z_z));

            for n =1:length(z_p)
                f.plot([real(z_p(n)), real(target)], [imag(z_p(n)), imag(target)], '-b');
                gamma_p(n) = rad2deg(atan2((imag(target) - imag(z_p(n))), (real(target) - real(z_p(n)))));
            end

            for n =1:length(z_z)
                f.plot([real(z_z(n)), real(target)], [imag(z_z(n)), imag(target)], '-m');
                gamma_z(n) = rad2deg(atan2((imag(target) - imag(z_z(n))), (real(target) - real(z_z(n)))));
            end

            fprintf("C(z)*G(z) Pole Phase Lags: "); disp(gamma_p);
            fprintf("C(z)*G(z) Zero Phase Leads: "); disp(gamma_z);
            fprintf("\n");

            mult = -1; % HACK: ignore for now
            gamma = sum(gamma_z) - sum(gamma_p);
            phase_gap_degrees = mult*180 - gamma;    % Nearest 180 degrees gap
            phase_gap = deg2rad(phase_gap_degrees);
            fprintf("C(z)*G(z) Total Gamma: %.3f degrees\n", gamma);
            fprintf("C(z)*G(z) Required Compensator: %.3f degrees = %.3f rad\n", phase_gap_degrees, phase_gap);

            % Work out where the required singularity needs to be
            real_loc = real(target) - imag(target)/tan(phase_gap);

            % Calculate gain of C(z)*G(z)
            target_gain = abs(evalfr(z_tf, target));
            fprintf("C(z)*G(z) Gain at target: %.3f\n", target_gain);
        end

        function deadbeatController(G_z, Ts)

        end

    end

end
