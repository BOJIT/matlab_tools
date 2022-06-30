% FILE:         Domain.m
% DESCRIPTION:  S and Z domain helpers
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 30/06/2022

%------------------------------------------------------------------------------%


%------------------------------------------------------------------------------%

classdef Domain < handle

    %---------------------------- Public Properties ---------------------------%
    properties

    end

    properties (Dependent)

    end

    %---------------------------- Private Properties --------------------------%
    properties (Access = private)

    end

    properties (Access = private, Dependent)

    end

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = Domain()

        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods (Static)
        function [out, v] = sym2tf(in)
            % Set the variable that is used in the TF
            v_all = symvar(in);
            v = char(v_all(1)); % Primary symvar assumed to be target

            % Convert exponent terms to time delays if they are present
            delay_term = 0;

            ch = children(in);
            for c = ch
                if has(c{:}, 'exp')
                    d = -double(subs(log(c{:}), v, 1));
                    warning("Delay Term Present %.3f", d);
                    delay_term = delay_term + d;
                    in = in/c{:};   % Remove exponent terms if present
                end
            end

            % Extract Polynomials
            [n, d] = numden(in);
            n_coeff = sym2poly(n);
            d_coeff = sym2poly(d);
            out = tf(n_coeff, d_coeff, 'InputDelay', delay_term);
        end

        function out = tf2sym(in, v)
            [n, d] = tfdata(in);

            sym_var = sym(v);
            out = poly2sym(cell2mat(n), sym_var)/poly2sym(cell2mat(d), sym_var);

            if in.InputDelay ~= 0
                warning("Re-adding Delay Term: %.3f", in.InputDelay);
                if v == 's'
                    disp("ADD S");
                    out = out * exp(-in.InputDelay*sym_var);
                elseif v == 'z'
                    disp("ADD Z");

                end
            end
        end

        function z = s2z(s)
            [s_tf, v] = Domain.sym2tf(s);
            z = Domain.tf2sym(s_tf, v);
            disp(s_tf);
        end

        function s = z2s(z)
            s = iztrans(z, 'z');
        end

        function z_n = zDelayForm(z)

        end

        function z_n = evansForm(z)
            [z_tf, v] = Domain.sym2tf(z);
            z_e = zpk(z_tf, v);
            z_n = Domain.tf2sym(z_e, v);
        end

        function pzPlotS(s)

        end

        function pzPlotZ(z)

        end
    end

    %------------------------------ Private Methods ---------------------------%
    methods

    end

    %------------------------------ Get/Set Methods ---------------------------%
    methods

    end

end
