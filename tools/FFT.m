% FILE:         FFT.m
% DESCRIPTION:  FFT Utilities
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 30/06/2022

%------------------------------------------------------------------------------%

classdef FFT < handle

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = FFT()
            % NOTE this utility class assumes 2^n padded data
        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods (Static)
        function result = fft(data, method)
            twiddle_factor = exp(-2i*pi/length(data));

            fprintf('Using a twiddle factor = '); disp(twiddle_factor);

            result = FFT.butterfly(data, method, twiddle_factor);
        end

        function result = ifft(data, method)
            twiddle_factor = 1/exp(-2i*pi/length(data));

            fprintf('Using a twiddle factor = '); disp(twiddle_factor);

            result = FFT.butterfly(data, method, twiddle_factor)./length(data);
        end

        function result = butterfly(data, method, twiddle_factor)
            if (method ~= "dif") && (method ~= "dit")
                error("No valid method provided!");
            end

            n = length(data);
            steps = log2(n);
            pad = 0.12;

            f = Figure();
            if (method == "dif")
                f.Title = sprintf("%u-Point FFT by Decimation in Frequency\n", n);
            else %(method == "dit")
                f.Title = sprintf("%u-Point FFT by Decimation in Time\n", n);
            end
            grid(f.Axes(1), 'off');
            set(f.Axes(1),'XTickLabel',[]);
            set(f.Axes(1),'YTickLabel',[]);

            xlim([0 - pad, steps + pad]);
            ylim([-1, n])

            % Allocate array for step indices
            t = zeros(n, steps + 1);

            if (method == "dif")
                t(:, 1) = data;
                b_label = 0:(n - 1);
            else %(method == "dit")
                % Update first row to use bit-reversals
                t(:, 1) = bitrevorder(data);
                b_label = bitrevorder(0:(n - 1));
            end

            % Add first row labels
            for b = 0:(n - 1)
                txtkey = texlabel(sprintf('X(%u)', b_label(b + 1)));
                txtval = texlabel(sprintf('= %.2f + %.2fi', real(t((b + 1), 1)), imag(t((b + 1), 1))));
                text(f.Axes(1), (0 - pad/2), (n - b - 1), {txtkey, txtval});
            end

            for s = 0:steps - 1

                if (method == "dif")
                    b_type = 2^(steps - s - 1);
                else %(method == "dit")
                    b_type = 2^s;
                end

                for b = 0:(n - 1)
                    if (method == "dif")
                        twd_power = bitshift(mod(b, b_type), s);
                    else %(method == "dit")
                        twd_power = bitshift(mod(b, b_type), steps - s - 1);
                    end
                    twd_mult = twiddle_factor^twd_power;

                    if bitand(b, b_type)
                        % Compute next term
                        txttwd = texlabel(sprintf('W_n^%u = %.1f + %.1fi', twd_power, real(twd_mult), imag(twd_mult)));
                        if (method == "dif")
                            t((b + 1), (s + 2)) = (t((b + 1 - b_type), (s + 1)) - t((b + 1), (s + 1)))*twd_mult;
                            text(f.Axes(1), (s + 0.6 + pad), (n - b - 1.25), txttwd, 'Color', 'red');
                        else %(method == "dit")
                            t((b + 1), (s + 2)) = t((b + 1 - b_type), (s + 1)) - (t((b + 1), (s + 1))*twd_mult);
                            text(f.Axes(1), (s + pad), (n - b - 1.25), txttwd, 'Color', 'red');
                        end

                        % Draw butterfly arrows
                        f.arrow([s + pad, s + 1 - pad], [n - b - 1, n - b - 1], 'green');
                        f.arrow([s + pad, s + 1 - pad], [n - b - 1 + b_type, n - b - 1], 'black');
                    else
                        % Compute next term
                        if (method == "dif")
                            t((b + 1), (s + 2)) = t((b + 1), (s + 1)) + t((b + 1 + b_type), (s + 1));
                        else %(method == "dit")
                            t((b + 1), (s + 2)) = t((b + 1), (s + 1)) + (t((b + 1 + b_type), (s + 1))*twd_mult);
                        end

                        % Draw butterfly arrows
                        f.arrow([s + pad, s + 1 - pad], [n - b - 1, n - b - 1], 'blue');
                        f.arrow([s + pad, s + 1 - pad], [n - b - 1 - b_type, n - b - 1], 'red');
                    end

                    % Add label
                    if s ~= (steps - 1)
                        txtkey = texlabel(sprintf('%.2f', real(t((b + 1), (s + 2)))));
                        txtval = texlabel(sprintf('+ %.2fi', imag(t((b + 1), (s + 2)))));
                        text(f.Axes(1), (s + 1 - pad/2), (n - b - 1), {txtkey, txtval});
                    end
                end
            end

            if (method == "dif")
                % Update last row to use bit-reversals
                b_label = bitrevorder(0:(n - 1));
                result = bitrevorder(t(:, end)).';
            else %(method == "dit")
                b_label = 0:(n - 1);
                result = t(:, end).';
            end

            % Add final row labels
            for b = 0:(n - 1)
                txtkey = texlabel(sprintf('X(%u)', b_label(b + 1)));
                txtval = texlabel(sprintf('= %.2f + %.2fi', real(t((b + 1), end)), imag(t((b + 1), end))));
                text(f.Axes(1), (steps - pad/2), (n - b - 1), {txtkey, txtval});
            end

        end

        function fftProperties(data)

        end

        function plotTwoSided(data)

        end

        function plotOneSided(data)

        end

        function plotOneSidedPower(data)

        end
    end

end
