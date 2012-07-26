% ALLGUESSINGMODEL returns a structure for a single-component model (a uniform 
% distribution). This is like StandardMixtureModel, but without a 
% remembered state.
function model = AllGuessingModel2()
  model.name = 'All guessing model 2';
	model.paramNames = {};
	model.lowerbound = []; % Lower bounds for the parameters
	model.upperbound = []; % Upper bounds for the parameters
	model.movestd = [];
	model.pdf = @(data) 1*unifpdf(data.errors(:),-180,180);
	model.start = []; % g
  model.generator = @(parameters,dims,varargin) (unifrnd(-180,180,dims));
end