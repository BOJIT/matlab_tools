% FILE:         Control.m
% DESCRIPTION:  Utility class for manipulating control networks
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 07/04/2022

%------------------------------------------------------------------------------%

classdef Control < handle

	%---------------------------- Public Properties ---------------------------%
	properties
		Pre
		Plant
		Controller
		Disturbance
		OL
		CL
		DCL
	end

	%---------------------------- Private Properties --------------------------%
	properties (Access = private)

	end

	%------------------------------- Constructor ------------------------------%
	methods
		function obj = Control(plant)
			obj.Plant = plant;
			fprintf("Plant Transfer Function:\n%s\n\n", latex(obj.Plant));
			
			% Initially controller is just a proportional controller
			syms K_c
			obj.Controller = K_c;
			fprintf("Controller Transfer Function:\n%s\n\n", latex(obj.Controller));
			
			obj.Disturbance = 1;
			fprintf("Disturbance Input Transfer Function:\n%s\n\n", latex(obj.Controller));
			
			obj.Pre = 1;
		end
	end

	%------------------------------ Public Methods ----------------------------%
	methods
		function msg = formatMsg(~, conf)
			% Create variable list
			msg = "";
			for field = fieldnames(conf)'
				msg = sprintf('%s %s = %.3g ,', msg, field{:}, conf.(field{:}));
			end
			msg = msg(1:end - 1);
		end
		
		function out = evansForm(~, in, mode)
			syms s
			if nargin <= 2
				mode = 'rational';
			end
			out = prod(factor(in, s, 'FactorMode', mode));
			if strcmp(mode, 'full')
				out = vpa(out, 4); 
			end
			fprintf("Evans' Form of Function:\n%s\n\n", latex(out));
		end
		
		function out = transferFcn(~, in, conf)
			for field = fieldnames(conf)'
				in = subs(in, field{:}, conf.(field{:}));
			end
			[n, d] = numden(in);
			n_coeff = sym2poly(n);
			d_coeff = sym2poly(d);
			out = tf(n_coeff, d_coeff);
		end
		
		function stabilityPlots(obj, conf, override)
			if nargin > 2
				ol_tf = obj.transferFcn(override, conf); 
			else
				ol_tf = obj.transferFcn(obj.OL, conf);
			end
			msg = obj.formatMsg(conf);
			
			% Bode Plot
			figure('Name', 'Bode Plot of OL Transfer Function');
			margin(ol_tf);
			[Gm, Pm, Wcg, Wcp] = margin(ol_tf);
			grid on;
			title({'Bode Diagram of C(s)\cdotG(s)', ...
				sprintf('Gm = %.3g dB (at %.3g rad/s), Pm = %.3g deg (at %.3g rad/s)', ...
				Gm, Wcg, Pm, Wcp), msg});
			
			% Nyquist Plot
			figure('Name', 'Nyquist Plot of OL Transfer Function');
			nyquist(ol_tf);
			grid on;
			title({'Nyquist Diagram of C(s)\cdotG(s) (Full Plot)', msg});
			
			% Zoomed Nyquist Plot
			figure('Name', 'Nyquist Plot of OL Transfer Function');
			hold on;
			nyquist(ol_tf);
			theta = linspace(0, 2*pi, 200);
			plot(cos(theta), sin(theta), '.r');
			xlim([-2, 2]);
			ylim([-2, 2]);
			axis equal;
			grid on;
			title({'Nyquist Diagram of C(s)\cdotG(s)', msg});
			hold off;
		end
		
		function responsePlots(obj, conf, override)
			if nargin > 2
				cl_tf = obj.transferFcn(override, conf); 
			else
				cl_tf = obj.transferFcn(obj.CL, conf);
			end
			msg = obj.formatMsg(conf);
			
			% Impulse Response
			figure('Name', 'Impulse Response of W(s)');
			impulse(cl_tf);
			grid on;
			title({'Impulse Response of W(s)', msg});
			
			% Step Response
			figure('Name', 'Step Response of W(s)');
			step(cl_tf);
			grid on;
			title({'Step Response of W(s)', msg});
			
			% Ramp Response
			figure('Name', 'Ramp Response of W(s)');
			pole = tf('s');
			step(cl_tf/pole);
			grid on;
			title({'Ramp Response of W(s)', msg});
			
		end
		
		function [r, r_latex] = routhTable(obj)
			r = {};
			
			syms s
			[~, char_eq] = numden(obj.CL);
			fprintf("Closed-Loop Characteristic Equation:\n%s\n\n", latex(char_eq));
			
			% Populate routh array with coefficients
			char_c = coeffs(char_eq, s, 'All');
			for i = 1:length(char_c)
				r_init{~mod(i, 2) + 1, ceil(i/2)} = char_c(i); 
			end
			
			% Ensure that any emtpy cells are symbolic zero
			invalid = cellfun(@isempty, r_init);
			r = r_init;
			r(invalid) = cellfun(@(x) sym(0), r_init(invalid), 'UniformOutput', false);
			
			% Fill out rest of array
			i = 3;
			while 1
				esc = false;
				for j = 1:width(r) - 1
					r{i, j} = (r{i - 1, 1}*r{i - 2, j + 1} - r{i - 2, 1}*r{i - 1, j + 1})/r{i - 1, 1};
					if ~isequal(r{i, j}, sym(0)); esc = esc || true; end
				end
				r{i, width(r)} = sym(0);
				if ~esc; break; end
				i = i + 1;
			end
			
			% Trim final row of zeros and convert to LaTex
			r = r(1: end - 1, :);
			r_latex = cellfun(@latex, r, 'UniformOutput', false);
			
			disp('Routh Table of Characteristic Equation:');
			disp(r_latex);
		end
		
		function addCompensator(obj, type, conf)
			syms s
			old_tf = obj.transferFcn(obj.OL, conf);
			
			fprintf("OLD Controller Transfer Function:\n%s\n\n", latex(obj.Controller));
			
			switch type
				case 'lead'
					comp = (1 + conf.tau_l*s)/(1 + (conf.tau_l/conf.m_l)*s);
				case 'lag'
					comp = (1 + (conf.tau_a/conf.m_a)*s)/(1 + conf.tau_a*s);
			end
			
			obj.Controller = obj.Controller*comp;
			
			new_tf = obj.transferFcn(obj.OL, conf);
			
			fprintf("NEW Controller Transfer Function:\n%s\n\n", latex(obj.Controller));
			
			% Comparison Bode Plot
			figure('Name', 'Bode Plot With and Without Compensator Network');
			hold on;
			margin(old_tf);
			margin(new_tf);
			[Gm_o, Pm_o, Wcg_o, Wcp_o] = margin(old_tf);
			[Gm_n, Pm_n, Wcg_n, Wcp_n] = margin(new_tf);
			grid on;
			title({'Bode Diagram of C(s)\cdotG(s)', ...
				sprintf('OLD: Gm = %.3g dB (at %.3g rad/s), Pm = %.3g deg (at %.3g rad/s)', ...
				Gm_o, Wcg_o, Pm_o, Wcp_o), ...
				sprintf('NEW: Gm = %.3g dB (at %.3g rad/s), Pm = %.3g deg (at %.3g rad/s)', ...
				Gm_n, Wcg_n, Pm_n, Wcp_n)});
			legend({'Old Controller', 'New Controller'});
			hold off;
		end
		
		function pid(obj, conf)
			syms s
			obj.Controller = conf.K_p*(1 + 1/(conf.T_i*s) + conf.T_d*s);
			
			fprintf("PID Controller Transfer Function:\n%s\n\n", latex(obj.Controller));
		end
		
		function clzn(obj, conf)
			t = linspace(0, 10, 10000);
			u = linspace(1, 1, 10000);    
			
			
			y = lsim(obj.transferFcn(obj.CL, conf), u, t) - 5;
			
			% Get zero-crossings from data to work out frequency
			zx = find(diff(sign(y)));
			for k = 1:numel(zx)
				idx_rng = max(zx(k)-1, 1):min(zx(k)+1,numel(t));
				tzro(k) = interp1(y(idx_rng), t(idx_rng), 0);
			end
			yzro = 5*ones(1, length(tzro));
			T_cr = 2*mean(gradient(tzro));
			
			fprintf("Critical Proportional Gain (K_cr):\n%.3g\n\n", conf.K_c);
			fprintf("Oscillation Time Period (T_cr):\n%.3g\n\n", T_cr);
			
			% Remember this will only work if the system doesn't have
			% infinite gain margin!
			
			% Create figure
			figure('Name', 'CLZN Tuning - Margin of Instability');
			hold on;
			lsim(obj.transferFcn(obj.CL, conf), u, t);
			plot(tzro, yzro, '*r');
			
			grid on;
			title("System Response at Margin of Instability");
			legend({'Stability Response', 'Sinusoid Intersections'});
			hold off;
			
			fprintf("Only trust this if the response is a constant amplitude sinusoid!\n\n");
		end
		
		function olzn(obj, conf, range)
			plant_tf = obj.transferFcn(obj.Plant, conf);
			
			% Step Response
			figure('Name', 'OLZN Step Response of W(s)');
			hold on;
			step(plant_tf);
			[y, t] = step(plant_tf);
			
			% Create straight-line approximation
			y_out = y(round(length(y)*range(1)):round(length(y)*range(2)));
			t_out = t(round(length(t)*range(1)):round(length(t)*range(2)));
			p = polyfit(t_out, y_out, 1);
			t_l = linspace(0, t(end), 1000);
			y_l = p(1).*t_l + p(2);
			plot(t_l, y_l, 'r');
			
			% Set automatic limits
			old_lim = ylim();
			ylim([p(2)*1.5, old_lim(2)]);
			lim_x = (y(end) - p(2))/p(1);
			xlim([-0.2*lim_x, 2*lim_x]);
			
			set(gca, 'XAxisLocation', 'origin');
			set(gca, 'YAxisLocation', 'origin');
			grid on;
			title('OLZN Step Response of G(s)');
			legend({'G(s) Step Response', 'Rise Linear Approximation'}, 'Location', 'southeast');
			hold off;
			
			% Print OLZN parameters
			fprintf("OLZN 'A' Value: %s\n\n", abs(p(2)));
			fprintf("OLZN 'L' Value: %s\n\n", abs(-p(2)/p(1)));
		end
	end
		
	%------------------------------ Private Methods ---------------------------%
	methods
		
	end

	%------------------------------ Get/Set Methods ---------------------------%
	methods
		function val = get.OL(obj)
			syms s
			val = collect(obj.Controller * obj.Plant, s);
			fprintf("Open-Loop Transfer Function:\n%s\n\n", latex(val));
		end
		
		function val = get.CL(obj)
			syms s
			val = collect(obj.Pre*obj.OL/(1 + obj.OL), s);
			fprintf("Closed-Loop Transfer Function:\n%s\n\n", latex(val));
		end
		
		function val = get.DCL(obj)
			syms s
			val = collect(obj.Disturbance/(1 + obj.OL), s);
			fprintf("Disturbance Closed-Loop Transfer Function:\n%s\n\n", latex(val));
		end
	end

end