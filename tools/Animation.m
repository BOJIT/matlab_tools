% FILE:         Animation.m
% DESCRIPTION:  Animation toolbox for creating animated figures
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 07/04/2022

%------------------------------------------------------------------------------%

classdef Animation < handle

	%---------------------------- Public Properties ---------------------------%
	properties
		Stage
		FrameRate = 15;
		Frames = [];
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
		function obj = Animation(ax)
			% Create hidden figure for rendering animations to
			obj.Stage = Figure();
			set(obj.Stage.Handle, 'visible', 'off');
		end
	end

	%------------------------------ Public Methods ----------------------------%
	methods
		function frame = addFrame(obj)
			
		end

		function previewFrame(obj, frame)
			f = Figure();
			copyobj(frame, f);
		end

		function play(obj, loop)

		end

		function stop(obj)

		end

		function renderGif(obj)

		end
	end
		
	%------------------------------ Private Methods ---------------------------%
	methods
		
	end

	%------------------------------ Get/Set Methods ---------------------------%
	methods
		
	end

end