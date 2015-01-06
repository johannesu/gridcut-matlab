function segmentation = GridCutSolver(data_term, settings)

if (~isa(settings, 'GridCutSettings'))
	error('Second argument must be GridCutSettings class');
end

if (~isa(data_term,'double') && ~isa(data_term,'single'))
	error('Data term must be double or float');
end

% Add folders
my_name = mfilename('fullpath');
my_path = fileparts(my_name);
addpath([my_path filesep 'include']);

%% Connectivity 
dim = ndims(data_term);

switch settings.connectivity
	case 4
		
		if (dim ~= 2)
			error('4-connecitivty only supported for 2D data');
		end
		
		% Needs to be defined in the correct order.
	conn_list = [-1 0; +1 0; 0 -1; 0 +1]';
	D = diag(settings.resolution(1:2));
	[~, conn_weights] = generate_weights_2D(conn_list, 1, D);

	case 6
		if (dim ~= 3)
			error('6-connecitivty only supported for 3D data');
		end
		
		conn_list = [-1 0 0; +1 0 0; 0 -1 0; 0 +1 0;  0 0 -1; 0 0 1]';
		D = diag(settings.resolution(1:3));
		[~, conn_weights] = generate_weights_3D(conn_list, 1, D);
		
	case 8
		if (dim ~= 2)
			error('8-connecitivty only supported for 2D data');
		end
		
		conn_list = [-1 0; 1 0; 0 -1; 0 1; -1 -1; 1 -1; -1 1; 1 1]';
		D = diag(settings.resolution(1:2));
		[~, conn_weights] = generate_weights_2D(conn_list, 1, D);
		
		
	case 26
		if (dim ~= 3)
			error('26-connecitivty only supported for 3D data');
		end
	
	  conn_list = [-1 0 0; 1 0 0;
				 0 -1 0; 0 1 0;
				 0 0 -1; 0 0 1;
				 -1 -1 0; 1 -1 0;
				 -1 1 0; 1 1 0;
				 0 -1 -1; 0 1 -1;
				 0 -1 1; 0 1 1;
				 -1 0 -1; -1 0 1;
				 1 0 -1; 1 0 1;
				 -1 -1 -1; 1 -1 -1;
				 -1 1 -1; 1 1 -1;
				 -1 -1 1; 1 -1 1;
				 -1 1 1; 1 1 1]'; 
				 
		D = diag(settings.resolution(1:3));
		[~, conn_weights] = generate_weights_3D(conn_list, 1, D);
		
end

conn_list = int32(conn_list);


%% Compile
cpp_file = ['include' filesep 'GridCut_mex.cpp'];
out_file = 'GridCut_mex';

extra_arguments{1} = ['-I"' my_path '"'];
extra_arguments{1} = ['-I"' my_path '"'];

% Folder containing gridcut headers.
extra_arguments{2} = ['-I"' my_path filesep 'gridcut' filesep 'include' filesep 'GridCut"'];

sources = {};
compile(cpp_file, out_file, sources, extra_arguments)

%% Call solver
segmentation = GridCut_mex(data_term, conn_list, conn_weights, settings.parsed_settings());
