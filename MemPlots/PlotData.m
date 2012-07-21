% PLOTDATA plots a histogram of the data. 

function figHand = PlotData(data, varargin)
  % Extra arguments and parsing
  args = struct('NumberOfBins', 40, 'NewFigure', false); 
  args = parseargs(varargin, args);
  if args.NewFigure, figHand = figure(); end
  
  % Clean data up if it is just errors
  if(~isfield(data,'errors')) && (~isfield(data,'afcCorrect'))
    data = struct('errors',data);
  end
  
  if isfield(data, 'errors')
    % Plot data histogram for continuous report data
    set(gcf, 'Color', [1 1 1]);
    x = linspace(-180, 180, args.NumberOfBins)';
    n = hist(data.errors(:), x);
    bar(x, n./sum(n), 'EdgeColor', [1 1 1], 'FaceColor', [.8 .8 .8]);
    xlim([-180 180]); hold on;
    set(gca, 'box', 'off');
    xlabel('Error (degrees)', 'FontSize', 14);
    ylabel('Probability', 'FontSize', 14);
    topOfY = max(n./sum(n))*1.20;
    ylim([0 topOfY]);
  else
    
    % Plot binned data for 2AFC data
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
    xlabel('Distance (degrees)', 'FontSize', 14);
    ylabel('Probability Correct', 'FontSize', 14);
    ylim([0 1]);
  end
end
