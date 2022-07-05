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

        function [f, s, theta] = normFFT(t, x)
            %NORM_FFT Simple fft abstraction that returns normalised
            %frequency-amplitude data.

            % Get data length and step size.
            % t is assumed to be in seconds
            % and have a constant sampling rate.
            samples = length(t);
            Fs = samples/(t(end) - t(1));   % sampling frequency
            df = Fs/samples;    % width of a frequency 'bin'

            transform = fftshift(fft(x))/samples;

            % Generate frequency from 'bin' width.
            % This works with both odd and even numbers of samples.
            f = fftshift(0:df:df*(samples - 1));
            f(1:floor(samples/2)) = f(1:floor(samples/2)) - Fs;

            % Give complex fourier series in polar form.
            % This makes it easy to plot, but can also be reconstructed.
            s = abs(transform);
            theta = angle(transform);
        end

        function result = ifft(data, method)
            twiddle_factor = 1/exp(-2i*pi/length(data));

            fprintf('Using a twiddle factor = '); disp(twiddle_factor);

            result = FFT.butterfly(data, method, twiddle_factor)./length(data);
        end

        function [x, t] = normIFFT(f, s, theta)
            %NORM_IFFT Simple ifft abstraction that constructs a signal
            % in the time domain based on the freqency components.

            % Get data length and step size.
            % f is assumed to be in Hertz
            % and have a constant 'bin' width.
            samples = length(f);
            t_max = (samples - 1)/(f(end) - f(1));   % sampling frequency

            % Convert polar co-ordinates back into complex form:
            transform = s.*exp(theta*1i);

            % Undo the Fourier transform, ignore imaginary component:
            % [imaginary component is only a product of floating-point
            % rounding error if original data is real].
            x = real(ifft(ifftshift(transform))*samples);

            % IFFT has to assume that time starts from zero.
            t = linspace(0, t_max, samples);
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

        function saneFFT(data, Ts)
            t = 0:Ts:(Ts*(length(data) - 1));

            [f_freq, f_magnitude, ~] = FFT.normFFT(t, data);

            f = Figure();
            f.Title = "FFT Plot with Frequency Bins Labelled";
            f.XLabel = "Frequency / Hz";
            f.YLabel = "Amplitude";
            f.stem(f_freq, f_magnitude);

            f.Axes(1).YAxisLocation = 'origin';
        end

        function plotTwoSided(data)
            data = abs(data); % Ignore phase

            f = Figure();
            f.Title = "Two-Sided FFT Plot";
            f.XLabel = "Bin (DC component centred to 0)";
            f.YLabel = "Amplitude";

            bins = -length(data)/2:(length(data)/2 - 1);
            freq = fftshift(data)/length(data);
            f.stem(bins, freq);

            f.Axes(1).YAxisLocation = 'origin';
        end

        function plotOneSided(data)
            data = abs(data); % Ignore phase

            f = Figure();
            f.Title = "One-Sided FFT Plot";
            f.XLabel = "Bin";
            f.YLabel = "Amplitude";

            bins = 0:length(data) - 1;
            freq = data/length(data);
            freq(2:end) = 2*freq(2:end);    % Double all components except DC

            f.stem(bins, freq);

            f.Axes(1).YAxisLocation = 'origin';
        end

        function plotOneSidedPower(data)
            data = abs(data); % Ignore phase

            f = Figure();
            f.Title = "One-Sided FFT Power Plot";
            f.XLabel = "Bin";
            f.YLabel = "Amplitude";

            bins = 0:length(data) - 1;

            freq = data.^2/(length(data).^2);
            freq(2:end) = 2*freq(2:end);    % Double all components except DC

            f.stem(bins, freq);

            f.Axes(1).YAxisLocation = 'origin';
        end
    end

end
