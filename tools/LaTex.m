% FILE:         LaTex.m
% DESCRIPTION:  Latex Utilities
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 30/06/2022

%------------------------------------------------------------------------------%

classdef LaTex < handle

    %------------------------------- Constructor ------------------------------%
    methods
        function obj = LaTex()

        end
    end

    %------------------------------ Public Methods ----------------------------%
    methods (Static)
        function s = eq(p)
            p_trunc = vpa(p, 3);
            s = latex(p_trunc);
        end

        function s = matrix(M)
            s = "\left[\begin{matrix}";
            for r = 1:size(M, 1)
                for c = 1:size(M, 2)
                    if isa(M(r, c), 'sym')
                        s = strcat(s, latex(M(r, c)));
                    else
                        s = strcat(s, string(M(r, c)));
                    end
                    if(c~= size(M, 2))
                        s = strcat(s, "&");
                    end
                end
                s = strcat(s, "\\");
            end
            s = strcat(s, "\end{matrix}\right]");
        end

        function s = brace(M)
            s = "\left\{\begin{matrix}";
            for r = 1:size(M, 1)
                for c = 1:size(M, 2)
                    if isa(M(r, c), 'sym')
                        s = strcat(s, latex(M(r, c)));
                    else
                        s = strcat(s, string(M(r, c)));
                    end
                    if(c~= size(M, 2))
                        s = strcat(s, "&");
                    end
                end
                s = strcat(s, "\\");
            end
            s = strcat(s, "\end{matrix}\right.");
        end

        function copy(s)
            clipboard('copy', s);
            fprintf("%s copied to clipboard!", inputname(1));
            disp("-----------------------------------------------------------");
        end
    end

end
