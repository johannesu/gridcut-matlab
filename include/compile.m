% Compile files only if needed
function compile(cpp_file, out_file, sources, extra_arguments)

% Process
my_name = mfilename('fullpath');
my_path = [fileparts(my_name) filesep '..'];
mex_file_name = [my_path filesep out_file '.' mexext];
cpp_file_name = [my_path filesep cpp_file];

mex_file = dir(mex_file_name);
cpp_file = dir(cpp_file_name);

if length(mex_file) == 1
	mex_modified = mex_file.datenum;
else
	mex_modified = 0;
end

cpp_modified   = cpp_file.datenum;

% If modified ocd r not existant compile
compile_file = false;
if ~exist(mex_file_name, 'file')
	compile_file = true;
elseif mex_modified < cpp_modified
	compile_file = true;
end

include_folders = {};

% Append current folder to sources
for i = 1 : length(sources);
	include_folders{i} = ['-I' my_path filesep fileparts(sources{i}) filesep];
	sources{i} = [my_path filesep sources{i}];
end

% Check all dependend files
for i = 1 : length(sources)
	cpp_file = dir(sources{i});
	cpp_modified = cpp_file.datenum;
	if mex_modified < cpp_modified
		compile_file = true;
	end
end

% c++98 compatible code.
%if ~ispc
%    extra_arguments{end+1} = ['CXXFLAGS="\$CXXFLAGS -std=c++0x"'];
%end


args = {extra_arguments{:},include_folders{:},sources{:}};

if compile_file
	mex_argument = {'mex', ...
		cpp_file_name,  ...
		'-outdir', ...
		my_path, ...
		'-largeArrayDims', ...
		args{:}};
	
	% Spaceing needed
	for i = 1:numel(mex_argument)
		mex_argument{i} = [mex_argument{i} ' '];
	end
	
	% Using eval to allow for arguments changeing c and c++ flags
	eval([mex_argument{:}]);
end
