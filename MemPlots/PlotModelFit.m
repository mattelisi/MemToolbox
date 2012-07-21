% PLOTMODELFIT plots the probability density function of the model overlaid on
% a histogram of the data. 

% params can be either a maxPosterior or a posteriorSamples. It currently cannot be a 
% fullPosterior but we should fix this.

function figHand = PlotModelFit(model, params, data, varargin)
  % Extra arguments and parsing
  args = struct('PdfColor', [0.54, 0.61, 0.06], 'NumberOfBins', 40, ...
                'ShowNumbers', true, 'NewFigure', false); 
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); end
  
  % If params is a struct, assume they passed a posteriorSamples() struct from MCMC
  if isstruct(params) && isfield(params, 'vals')
    params = params.vals;
  end
  if(~isfield(data,'errors')) && (~isfield(data,'afcCorrect'))
    data = struct('errors',data);
  end
  
  % Ensure there is a model.prior, model.logpdf and model.pdf
  model = EnsureAllModelMethods(model);
  model = GetModelPdfForPlot(model);
   
  if isfield(data, 'errors')
    PlotContinuousReport(model, params, data, args);
  else
    Plot2AFC(model, params, data, args);
  end
  
  % Label the plot with the parameter values
  if args.ShowNumbers && size(params,1) == 1
    topOfY = max(ylim);
    txt = [];
    for i=1:length(params)
      txt = [txt sprintf('%s: %.3g\n', model.paramNames{i}, params(i))];
    end
    text(180, topOfY-0.02, txt, 'HorizontalAlignment', 'right');
  end
end

function Plot2AFC(model, params, data, args)
  % Plot data histogram
  set(gcf, 'Color', [1 1 1]);
  x = linspace(-180, 180, args.NumberOfBins)';
  for i=2:length(x)
    which = data.changeSize>=x(i-1) & data.changeSize<x(i);
    mn(i-1) = mean(data.afcCorrect(which));
    se(i-1) = std(data.afcCorrect(which))./sqrt(sum(which));
  end
  binX = (x(1:end-1) + x(2:end))/2;
  bar(binX, mn, 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
  hold on;
  errorbar(binX, mn, se, '.', 'Color', [.5 .5 .5]);  
  xlim([-180 180]);
  set(gca, 'box', 'off');
  
  % Plot prediction
  vals = linspace(-180, 180, 500)';  
  if size(params,1) > 1
    params = params(1,:);
  end
  paramsAsCell = num2cell(params);
  newD.changeSize = vals;
  newD.afcCorrect = ones(size(vals));
  plot(vals, model.pdf(newD, paramsAsCell{:}), 'Color', args.PdfColor, ... 
         'LineWidth', 2, 'LineSmoothing', 'on');
       
  % Label plot
  xlabel('Distance (degrees)', 'FontSize', 14);
  ylabel('Probability Correct', 'FontSize', 14);
  ylim([0 1]);
end

function PlotContinuousReport(model, params, data, args)
  % Plot data histogram
  set(gcf, 'Color', [1 1 1]);
  x = linspace(-180, 180, args.NumberOfBins)';
  n = hist(data.errors(:), x);
  bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
  xlim([-180 180]); hold on;
  set(gca, 'box', 'off');
  
  % Plot scaled version of the prediction
  vals = linspace(-180, 180, 200)';
  multiplier = length(vals)/length(x);
  
  % If params has multiple rows, as if it came from a posteriorSamples struct, then
  % plot a confidence interval, too
  if size(params,1) > 1
    for i=1:size(params,1)
      paramsAsCell = num2cell(params(i,:));
      p(i,:) = model.pdfForPlot(vals, data, paramsAsCell{:});
      p(i,:) = p(i,:) ./ sum(p(i,:));
    end
    bounds = quantile(p, [.05 .50 .95])';
    h = boundedline(vals, bounds(:,2) .* multiplier, ...
      [bounds(:,2)-bounds(:,1) bounds(:,3)-bounds(:,2)] .* multiplier, ...
      pdfColor, 'alpha');
  else
    paramsAsCell = num2cell(params);
    p = model.pdfForPlot(vals, data, paramsAsCell{:});
    plot(vals, p(:) ./ sum(p(:)) .* multiplier, 'Color', args.PdfColor, ... 
         'LineWidth', 2, 'LineSmoothing', 'on');
  end
  xlabel('Error (degrees)', 'FontSize', 14);
  ylabel('Probability', 'FontSize', 14);
  
  % Always set ylim to 120% of the histogram height, regardless of function
  % fit
  topOfY = max(n./sum(n))*1.20;
  ylim([0 topOfY]);
end

