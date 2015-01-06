% Perform all test by: run(unit_tests)

classdef unit_tests < matlab.unittest.TestCase
	
	properties
		data_term_2D;
		data_term_3D;
		rng_seed = 0;
	end

	% Setup
	methods (TestMethodSetup)
		function create_data_terms(testCase)
			
			rng(testCase.rng_seed);
			testCase.data_term_2D = rand(100,100)-0.5;
			testCase.data_term_3D = rand(25,25,25)-0.5;
			
		end
	end

	methods 
		
			function result = only_one_label(~, segmentation) 		
					result = all(segmentation(:) == 1) | all(segmentation(:) == 0);	
			end
			
			function result = reverse_labelling(~, S1,S2) 		
					result = all(S1(:) ~= S2(:));
			end
	end
	
	methods (Test)
	
		function no_regularization(testCase)
				settings = GridCutSettings;
				
				% 2D
				for conn = [4 8]
					settings.connectivity = conn;
					segmentation = GridCutSolver(testCase.data_term_2D, settings);
					threshold = testCase.data_term_2D < 0;				
					
					testCase.verifyEqual(segmentation, threshold);		
				end
				
				
				% 3D
				for conn = [6 26]
					settings.connectivity = conn;
					segmentation = GridCutSolver(testCase.data_term_3D, settings);
					threshold = testCase.data_term_3D < 0;				
					
					testCase.verifyEqual(segmentation, threshold);		
				end
		end
		
		function very_strong_regularization(testCase)
				settings = GridCutSettings;
				settings.regularization_strength = 10000;
				
				% 2D
				for conn = [4 8]
					settings.connectivity = conn;
					segmentation = GridCutSolver(testCase.data_term_2D, settings);
					
					testCase.verifyTrue(testCase.only_one_label(segmentation));		
				end
		
				% 3D
				for conn = [6 26]
					settings.connectivity = conn;
					segmentation = GridCutSolver(testCase.data_term_3D, settings);
					
					testCase.verifyTrue(testCase.only_one_label(segmentation));	
				end
		end
		
		function symmetry(testCase)
			settings = GridCutSettings;
			settings.regularization_strength = 1;
							
				% 2D
				for conn = [4 8]
					settings.connectivity = conn;
					S1 = GridCutSolver(testCase.data_term_2D, settings);
					S2 = GridCutSolver(-testCase.data_term_2D, settings);
					
					testCase.verifyTrue(testCase.reverse_labelling(S1,S2));
				end
						
				% 3D
				for conn = [6 26]
					settings.connectivity = conn;
					S1 = GridCutSolver(testCase.data_term_3D, settings);
					S2 = GridCutSolver(-testCase.data_term_3D, settings);
					
					testCase.verifyTrue(testCase.reverse_labelling(S1,S2));
				end			
		end
	end
end

