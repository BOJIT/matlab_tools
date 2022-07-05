% FILE:         Maths.m
% DESCRIPTION:  Generic maths utilities for MATLAB
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 02/07/2022

%------------------------------------------------------------------------------%

classdef Maths < handle

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = Maths()

        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods (Static)
        function d = vectorDistance(p, v1, v2)
            % Allow 2D co-ordinates to be used
            if (length(p) == 2); p = [p, ]; end
            if (length(v1) == 2); v1 = [v1, ]; end
            if (length(v2) == 2); v2 = [v2, ]; end

            % Simple bit of linear algebra
            a = v1 - v2;
            b = pt - v2;
            d = norm(cross(a, b)) / norm(a);
        end

        function n = isSolved(s)
            try
                n = double(s);
            catch
                n = NaN;
            end
        end

        function d = maxDelayTerm(p, target)
            % Gets highest negative power in a strictly negative exponent polyomial
            % NOTE currently does not deal with fractional or mixed sign powers

            sym_var = sym(target);

            ch = children(p);
            d_all = zeros(1, length(ch));
            for i = 1:length(ch)
                while has(ch{i}, sym_var)
                    % Increment negative powers until target has disappeared
                    ch{i} = ch{i}*sym_var;
                    d_all(i) = d_all(i) + 1;
                end
            end

            d = max(d_all);
        end

        function [r, q] = polynomialReduce(p, d, target, round)
            % Symbolic polynomial division of negative powers
            % NOTE this function currently has a bug where a polynomial multiple of the
            % quotient/remainder is returned. Still trying to fix the shifting logic.
            % However, the coefficients are always returned correctly.

            sym_var = sym(target);

            p_mult = Maths.maxDelayTerm(p, target);
            d_mult = Maths.maxDelayTerm(d, target);

            p_offset = expand((sym_var^p_mult)*p);
            d_offset = expand((sym_var^d_mult)*d);

            [r_offset, q_offset] = polynomialReduce(p_offset, d_offset);

            r = expand(r_offset/(sym_var^p_mult));
            q = expand(q_offset/(sym_var^(p_mult - d_mult)));
            % q = expand(q_offset/(sym_var^(p_mult - d_mult)));     % ? need to verify maths

            if (nargin >= 4) && round
                r = vpa(r, 4);
                q = vpa(q, 4);
            end
        end
    end

end
