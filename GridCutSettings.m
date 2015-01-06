
classdef GridCutSettings
	
	% Support from the c++ library.
	properties (Constant)
		supported_parallel_connectivity = [4 6];
		supported_2D_connectivity = [4 8];
		supported_3D_connectivity = [6 26];
	end
	
	% Default
	properties (SetAccess = public)
		connectivity = int32(4);
		resolution = [1 1 1];
		regularization_strength = 0;
	end
		
	methods
		function settings = parsed_settings(obj)
			settings.connectivity = obj.connectivity;
			settings.regularization_strength = obj.regularization_strength;
		end
		
		% Set functions
		function obj = set.connectivity(obj, connectivity)
			supported_connectivity = [obj.supported_2D_connectivity obj.supported_3D_connectivity];
			
			if (ismember(connectivity, supported_connectivity))
				obj.connectivity = int32(connectivity);
			else
				error('Supported connectivity: %s.', num2str(supported_connectivity));
			end
		end
		
		function obj = set.resolution(obj, resolution)
			
			if (numel(resolution) == 2)
				obj.resolution = [resolution 1];
			elseif (numel(resolution) == 3)
				obj.resolution = resolution;
			else
				error('Please define resolution in at least two and at most three dimnesions');
			end
		end
		
		function obj = set.regularization_strength(obj, regularization_strength)
			if (regularization_strength <0 )
				error('Regularization strength must be non-negative');
			else
				obj.regularization_strength = regularization_strength;
			end
		end
	end
end