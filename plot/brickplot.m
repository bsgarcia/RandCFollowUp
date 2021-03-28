function [bars, nbar, nsub] = brickplot(data,colors,y_lim,fontsize,mytitle, ... 
    x_label,y_label,varargin, noscatter, x_lim, x_values, width1, median)

% Sophie Bavard - December 2018
% Creates a violin plot with mean, error bars, confidence interval, kernel density.
% Warning: the function can accept any number of arguments > 9.
% After the Title, LabelX, LabelY : varargin for bar names under X-axis

% transforms the Data matrix into cell format if needed
if iscell(data)==0
    data = num2cell(data,2);
end

if ~exist('noscatter')
    noscatter = 0;
end


if ~exist('median')
    median = 0;
end

if ~exist('width1')
    width1 = .8;
    
end

% number of factors/groups/conditions
nbar = size(data,1);
% bar size
Wbar = 0.025.*100;

% confidence interval
ConfInter = 0.95;

% color of the box + error bar
trace = [0.5 0.5 0.5];

for n = 1:nbar
    
    clear DataMatrix
    clear jitter jitterstrength
    DataMatrix = data{n,:}';
    
    % number of subjects
    nsub = length(DataMatrix(~isnan(DataMatrix)));
    
    if median
        curve = nanmedian(DataMatrix);
    else
        curve = nanmean(DataMatrix);
    end

    sem   = nanstd(DataMatrix')'/sqrt(nsub);
    
    mystd = nanstd(DataMatrix);
    conf  = tinv(1 - 0.5*(1-ConfInter),nsub);
    
    width = Wbar/15;
    
    fill([x_values(n)-Wbar x_values(n)+Wbar x_values(n)+Wbar x_values(n)-Wbar],...
            [curve-sem*conf curve-sem*conf curve+sem*conf curve+sem*conf],...
            set_alpha(colors(n,:), .23),...
            'edgecolor', 'none', 'linewidth', 0.05);%,...%trace,...
            %'FaceAlpha',0.23);
        hold on


        fill([x_values(n)-Wbar x_values(n)+Wbar x_values(n)+Wbar x_values(n)-Wbar],...
            [curve-sem curve-sem curve+sem curve+sem],...
            set_alpha(colors(n,:), .6), 'edgecolor','black', 'linewidth', 1);%,...
           %'linewidth', 1^-10, 'edgecolor',set_alpha(color2, .7));%,...%trace,...
            %'FaceAlpha',0.5);
        hold on

        xMean = [x_values(n)-Wbar; x_values(n)+Wbar];
        yMean = [curve; curve];
        ppp = plot(xMean,yMean,'LineWidth',4,'Color',colors(n,:));
        hold on

%         
    if ~noscatter
        
        scatter((ones(size(DataMatrix)).*x_values(n))+shuffle(linspace(-3, 3, nsub)), DataMatrix, 10,...
            colors(n,:),'filled',...
            'marker','o',...
            'MarkerFaceAlpha',0.1);
            
                
        hold on
    end
    
   
    
    % ERROR BARS
%     errorbar(n,curve,sem,...
%         'Color','k',...Colors(n,:),...
%         'LineStyle','none',...
%         'LineWidth',1);
    hold on
end

% axes and stuff
ylim(y_lim);


if ~exist('x_lim')
    x_lim = [0, nbar+1];
end
if ~exist('x_values')
    x_values = 1:nbar;
end

set(gca,'FontSize',fontsize,...
    'XLim', x_lim ,...
    'XTick',x_values,...
    'XTickLabel',varargin);


title(mytitle);
xlabel(x_label);
ylabel(y_label);

x_lim = [min(varargin), max(varargin)];%get(gca, 'YLim');get(gca, 'XLim');
y_lim = [min(varargin), max(varargin)];%get(gca, 'YLim');

% y0 = plot(linspace(x_lim(1), x_lim(2), 10),...
%     ones(10,1).*50, 'LineStyle', '--', 'Color', 'k', 'linewidth', .6);
% y0.Color(4) = .45;
% uistack(y0, 'bottom');
% 
% hold on
% 
% x = linspace(x_lim(1), x_lim(2), 10);
% 
% y = linspace(y_lim(1), y_lim(2), 10);
% p0 = plot(x, y, 'linewidth', .6, 'LineStyle', '--', 'Color', 'k');
% 
% p0.Color(4) = .45;
% hold on
% uistack(p0, 'bottom');




end

function c = set_alpha(rgb, a)
    c = (1-a).* [1, 1, 1] + rgb .* a;
end
    

 function v=shuffle(v)
     v=v(randperm(length(v)));
 end









