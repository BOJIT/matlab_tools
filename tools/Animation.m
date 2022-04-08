% FILE:         Animation.m
% DESCRIPTION:  Animation toolbox for creating animated figures
% AUTHOR:       James Bennion-Pedley
% DATE CREATED: 07/04/2022

%------------------------------------------------------------------------------%

classdef Animation < handle

	%---------------------------- Public Properties ---------------------------%
	properties
		Stage
		Parent
		FrameRate = 15;
		Frames = {};
		Render;
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
		function obj = Animation(target)
			Parent = target;
			% Create hidden figure for rendering animations to
			obj.Stage = Figure();
			set(obj.Stage.Handle, 'visible', 'off');
		end
	end

	%------------------------------ Public Methods ----------------------------%
	methods
		function frame = addFrame(obj)
			idx = length(obj.Frames) + 1;
			obj.Frames{idx} = copyobj(obj.Parent, obj.Stage.Handle);
			
			frame = obj.Frames{idx};
		end

		function previewFrame(obj, frame)
			% set(frame.Handle, 'visible', 'on');
		end

		function play(obj, parent, loop)
			movie(parent, obj.Render, 1, obj.FrameRate);
		end

		function stop(obj)

		end

		function render(obj)
			r(length(obj.Frames)) = struct('cdata',[],'colormap',[]);

			obj.Render = r;

			for i = 1:length(obj.Frames)
				obj.Render(i) = getframe(obj.Frames{i}.Handle);
			end
		end

		function export(obj)

		end
	end
		
	%------------------------------ Private Methods ---------------------------%
	methods
		
	end

	%------------------------------ Get/Set Methods ---------------------------%
	methods
		
	end

end