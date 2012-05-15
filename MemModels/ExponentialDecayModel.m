% EXPONENTIALDECAYMODEL returns a struct for a model where objects drop out
% of memory indepdendently at a constant rate over time, a la Zhang & Luck
% (2009). (This is a pure death process over objects.)
%
% Example usage:
%
%   data = memdata2mtb(MemData(16));
%   model = ExponentialDecayModel();
%   stored = MCMC_Convergence(data, model);
%   MCMC_Summarize(stored);
%
function model = ExponentialDecayModel()
  model.name = 'Exponential Decay Model';
	model.paramNames = {'tau', 'k', 'sd'};
	model.lowerbound = [0 0 0]; % Lower bounds for the parameters
	model.upperbound = [Inf Inf Inf]; % Upper bounds for the parameters
	model.movestd = [20, 1, 1];
	model.pdf = @sdpdf;
	model.start = [1000, 4, 12;  % tau, k, sd
                 2000, 2, 20;
                 10000, 6, 30];
end

function y = sdpdf(data, tau, k, sd)
  
  B = min(k, data.n); % maximum contribution of working memory
  
  % the probability of remembering is exponential in time
  p = B.*exp(data.time/-tau) ./ data.n; 
  
  g = 1 - p; % the guess rate
  
  y = ((1-g(:)).*vonmisespdf(data.errors(:),0,sd2k(pi/180.*sd)) + ...
          (g(:).*unifpdf(data.errors(:),-180,180)));
  
end