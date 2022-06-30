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
        function [out, v] = sym2tf(in, Ts)
            % Set the variable that is used in the TF.
            v_all = symvar(in);
            v = char(v_all(1)); % Primary symvar assumed to be target

            delay_term = 0;     % Convert exponent terms to time delays if they are present

            ch = children(in);
            for c = ch
                % Delay Term
                if has(c{:}, 'exp')
                    d = -double(subs(log(c{:}), v, 1));
                    warning("Delay Term Present %.3f", d);
                    delay_term = delay_term + d;
                    in = vpa(in/c{:}, 4);   % Remove exponent terms if present
                end
            end

            % Extract Polynomials
            [n, d] = numden(in);
            n_coeff = sym2poly(vpa(n, 4));
            d_coeff = sym2poly(vpa(d, 4));
            if(nargin >= 2)
                out = tf(n_coeff, d_coeff, Ts, 'InputDelay', delay_term);
            else
                out = tf(n_coeff, d_coeff, 'InputDelay', delay_term);
            end
        end

        function out = tf2sym(in, v)
            [n, d] = tfdata(in);

            sym_var = sym(v);

            n_p = vpa(poly2sym(cell2mat(n), sym_var), 4);
            d_p = vpa(poly2sym(cell2mat(d), sym_var), 4);

            out = vpa(n_p/d_p, 4);

            if in.InputDelay ~= 0
                warning("Re-adding Delay Term: %.3f", in.InputDelay);
                if v == 's'
                    out = vpa(out * exp(-in.InputDelay*sym_var), 4);
                elseif v == 'z'
                    out = vpa(out * sym_var^-in.InputDelay, 4);
                end
            end
        end

        function [z, z_tf] = s2z(s, Ts)
            s_tf = Domain.sym2tf(s);
            z_tf = c2d(s_tf, Ts);   % Assumes zero-order-hold
            z_tf.Variable = 'z';
            z = Domain.tf2sym(z_tf, 'z');
        end

        function [s, s_tf] = z2s(z, Ts, tustin)
            z_tf = zpk(Domain.sym2tf(z, Ts));
            if (nargin >= 3) && (tustin == true)
                s_tf = d2c(z_tf, 'tustin');       % Assumes zero-order-hold
            end
            s_tf.Variable = 's';
            s = Domain.tf2sym(s_tf, 's');
        end

        function [z_out, z_terms] = delayForm(z_in)
            z_out = vpa(expand(z_in), 4);

            % Get delay element correction factor
            [n, d] = numden(z_out);
            n_coeff = sym2poly(vpa(n, 4));
            d_coeff = sym2poly(vpa(d, 4));
            z_terms = max([length(n_coeff), length(d_coeff)]) - 1;
        end

        function z_out = evansForm(z_in)
            [z_tf, v] = Domain.sym2tf(z_in);
            z_e = zpk(z_tf, v);
            z_out = Domain.tf2sym(z_e, v);
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
