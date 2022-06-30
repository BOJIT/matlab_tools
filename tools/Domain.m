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
            v_all = symvar(in);
            v = char(v_all(1));
            [n, d] = numden(in);
            n_coeff = sym2poly(n);
            d_coeff = sym2poly(d);
            out = tf(n_coeff, d_coeff);
        end

        function out = tf2sym(in, v)
            [n, d] = tfdata(in);

            sym_var = sym(v);
            out = poly2sym(cell2mat(n), sym_var)/poly2sym(cell2mat(d), sym_var);
        end

        function z = s2z(s)

        end

        function s = z2s(z)

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
