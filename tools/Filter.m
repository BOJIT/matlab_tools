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
        FirPrototype = struct( ...
            'lowpass', piecewise(Filter.n == 0, Filter.W_c/pi, sin(Filter.W_c*Filter.n)/(Filter.n*pi)), ...
            'highpass', piecewise(Filter.n == 0, pi - Filter.W_c/pi, -sin(Filter.W_c*Filter.n)/(Filter.n*pi)) ...
        );
    end

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = Filter()

        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods (Static)
        function plotImpulseResponse(in_coeffs, out_coeffs)

        end

        function plotFrequencyResponse(in_coeffs, out_coeffs)

        end

        function [y_vals, y_windowed] = fir(order, F_c, F_s, type, window)
            % Create set of input steps
            n_vals = (1:order) - (order + 1)/2;

            % Calculate normalised angular velocity
            W_c = 2*pi*(F_c/F_s);

            % Evaluate for piecewise 'sinc' function
            syms y(n); y(n) = Filter.FirPrototype.(type);
            y_vals = double(vpa(subs(y(n_vals), Filter.W_c, W_c), 4));

            % Print stats
            fprintf("n steps: "); disp(vpa(n_vals, 2));
            fprintf("coefficients: "); disp(vpa(y_vals, 3));

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

        function bilinearTransform(s)

        end
    end

end
