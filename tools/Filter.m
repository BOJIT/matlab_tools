% FILE:         Filter.m
% DESCRIPTION:  Filter Utilities
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 30/06/2022

%------------------------------------------------------------------------------%

classdef Filter < handle

    %---------------------------- Public Properties ---------------------------%
    properties (Constant)
        n = sym('n');
        W_c = sym('W_c');
        W_l = sym('W_l');
        W_h = sym('W_h');
        FirPrototype = struct( ...
            'lowpass', piecewise(Filter.n == 0, Filter.W_c/pi, sin(Filter.W_c*Filter.n)/(Filter.n*pi)), ...
            'highpass', piecewise(Filter.n == 0, (pi - Filter.W_c)/pi, -sin(Filter.W_c*Filter.n)/(Filter.n*pi)), ...
            'bandpass', piecewise(Filter.n == 0, (Filter.W_h - Filter.W_l)/pi, (sin(Filter.W_h*Filter.n) - sin(Filter.W_l*Filter.n))/(Filter.n*pi)), ...
            'bandstop', piecewise(Filter.n == 0, (pi - Filter.W_h + Filter.W_l)/pi, (sin(Filter.W_l*Filter.n) - sin(Filter.W_h*Filter.n))/(Filter.n*pi)) ...
        );
    end

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = Filter()

        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods (Static)
        function impulseResponse(in_coeffs, out_coeffs)
            % f = Figure();
            % f.Title = sprintf("FIR Coefficients for order %u filter", order);
            % f.XLabel = "Coefficient (non-causal)";
            % f.YLabel = "Magnitude";
            % f.stem(n_vals, y_vals, 'b');
        end

        function freqResponse(F_s, n_coeffs, d_coeffs)
            % Allow operation for both FIR and IIR
            if nargin < 3
                d_coeffs = 1;
            end

            % Compute details
            h = freqz(n_coeffs, d_coeffs);
            h_mag = mag2db(abs(h));
            h_phase = rad2deg(angle(h));

            h_freq = linspace(0, F_s/2, length(h_mag));

            f = Figure([2, 1]);
            f.SuperTitle = "Frequency Response of Digital Filter";

            f.ActiveAxes = 1;
            f.plot(h_freq, h_mag);
            f.XLabel = "Frequency / Hz";
            f.YLabel = "Magnitude / dB";

            xlim(f.Axes(f.ActiveAxes), [0, F_s/2]);

            f.ActiveAxes = 2;
            f.plot(h_freq, h_phase);
            f.XLabel = "Frequency / Hz";
            f.YLabel = "Phase / degrees";

            xlim(f.Axes(f.ActiveAxes), [0, F_s/2]);
        end

        function [y_vals, y_windowed] = fir(order, F_c, F_s, type, window)
            % Create set of input steps
            n_vals = (1:order) - (order + 1)/2;

            % Calculate normalised angular velocity
            W_c = 2*pi*(F_c/F_s);

            % Evaluate for piecewise 'sinc' function
            syms y(n); y(n) = Filter.FirPrototype.(type);

            if length(F_c) == 1
                y_vals = double(vpa(subs(y(n_vals), Filter.W_c, W_c), 4));
            else
                y_vals = double(vpa(subs(y(n_vals), [Filter.W_l, Filter.W_h], [W_c(1), W_c(2)]), 4));
            end

            % Print stats
            fprintf("n steps: "); disp(vpa(n_vals, 2));
            fprintf("coefficients: "); disp(vpa(y_vals, 4));

            % Create graph with/without windowing function
            f = Figure();
            f.Title = sprintf("FIR Coefficients for order %u filter", order);
            f.XLabel = "Coefficient (non-causal)";
            f.YLabel = "Magnitude";
            f.stem(n_vals, y_vals, 'b');

            % Add window if applicable
            y_windowed = ones(1, length(n_vals));
            if nargin >= 5
                y_windowed = window(length(n_vals))'.*y_vals;
                f.stem(n_vals, y_windowed, 'r');

                legend({'No window (boxcar)', 'windowed'})
            end
        end

        function iir()

        end

        function bilinearTransform(s)

        end
    end

end
