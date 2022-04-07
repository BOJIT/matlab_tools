% FILE:         Figure.m
% DESCRIPTION:  Class encapsulation for figures with opinionated formatting
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 07/04/2022

%------------------------------------------------------------------------------%

classdef Figure < handle

	%---------------------------- Public Properties ---------------------------%
	properties
		Handle		% Handle for root figure
		Axes		% Handle for root axes within figure
	end
	
	properties (Dependent)
		Title		% Graph title
	end
	
	%---------------------------- Private Properties --------------------------%
	properties (Access = private)

	end

	%------------------------------- Constructor ------------------------------%
	methods
		function obj = Figure()
			% Create figure framework
			obj.Handle = figure();
			obj.Axes = axes(obj.Handle);
			obj.Axes.NextPlot = 'add';
			obj.Axes.FontName = 'Times';
			grid(obj.Axes, 'on');
		end
	end

	%------------------------------ Public Methods ----------------------------%
	methods
		function handle = plot(obj, varargin)
			handle = plot(obj.Axes, varargin{:});
		end
	end
		
	%------------------------------ Private Methods ---------------------------%
	methods
		
	end

	%------------------------------ Get/Set Methods ---------------------------%
	methods
		function set.Title(obj, val)
			title(obj.Axes, val);
		end
	end

end