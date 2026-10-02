function fits = loran_plot_results(frames,summary,outputRoot,cfg)
%LORAN_PLOT_RESULTS Plot only comparisons supported by supplied reference values.
% Fits quantify raw bias/dispersion; missing labels are not guessed/calibrated.
if nargin<4, cfg = loran_default_config(); end
assert(isfolder(outputRoot),'LoRan:PlotDirectory','Create output directory first.');
names = {'loran_nz_error','loran_native_comparison','loran_physical_length'};
for k = 1:numel(names)
    assert(~isfile(fullfile(outputRoot,[names{k} '.pdf'])) && ...
        ~isfile(fullfile(outputRoot,[names{k} '.png'])), ...
        'LoRan:PlotExists','Choose a directory without existing plot files.');
end
fits = table(cell(0,1),zeros(0,1),zeros(0,1),zeros(0,1),zeros(0,1), ...
    'VariableNames',{'Method','Slope','InterceptM','R2','ResidualRMSEM'});
fig = figure('Visible','off','Color','w','Units','inches','Position',[1 1 6 3]);
cleanup = onCleanup(@() close(fig));
validNative = isfinite(frames.NativeResultM) & isfinite(frames.DistanceM);
if any(validNative)
    subplot(1,2,1);
    semilogx(summary.Nz,summary.MedianAbsoluteDifferenceM,'ko-', ...
        'LineWidth',1,'MarkerFaceColor','k'); grid on;
    set(gca,'XTick',summary.Nz,'FontName','Times New Roman','FontSize',10);
    xlabel('Zero-padding factor, N_z');
    ylabel({'Median absolute difference','from SX1280 (m)'});
    subplot(1,2,2);
    [~,group] = ismember(frames.Nz(validNative),summary.Nz);
    boxchart(group,frames.AbsoluteDifferenceM(validNative), ...
        'BoxFaceColor',[.65 .65 .65],'MarkerColor',[.35 .35 .35]); grid on;
    set(gca,'XTick',1:height(summary),'XTickLabel',string(summary.Nz), ...
        'FontName','Times New Roman','FontSize',10);
    xlabel('Zero-padding factor, N_z');
    ylabel({'Absolute difference','from SX1280 (m)'});
    save_figure(fig,outputRoot,names{1});
end
subset = frames(frames.Nz==cfg.plot_nz,:);
paired = subset(isfinite(subset.NativeResultM) & isfinite(subset.DistanceM),:);
if height(paired)>=1
    clf(fig); x = paired.NativeResultM; y = paired.DistanceM;
    limits = [min([x;y])-5,max([x;y])+5]; t = linspace(limits(1),limits(2),100);
    fill([t,fliplr(t)],[t-10,fliplr(t+10)],[.88 .88 .88], ...
        'EdgeColor','none','DisplayName','+/- 10 m band'); hold on;
    plot(t,t,'k-','DisplayName','Exact agreement');
    scatter(x,y,14,'k','filled','DisplayName','Paired results');
    xlim(limits); ylim(limits); grid on;
    set(gca,'FontName','Times New Roman','FontSize',10);
    xlabel('Native SX1280 result (m)'); ylabel('Lo-Ran result (m)');
    legend('Location','northwest'); r = NaN;
    if height(paired)>=2 && std(x)>0 && std(y)>0
        correlation = corrcoef(x,y); r = correlation(1,2);
    end
    text(.97,.04,sprintf('n = %d; r = %.3f',height(paired),r), ...
        'Units','normalized','HorizontalAlignment','right','FontName','Times New Roman');
    save_figure(fig,outputRoot,names{2});
end
physical = subset(isfinite(subset.PhysicalLengthM) & isfinite(subset.DistanceM),:);
if numel(unique(physical.PhysicalLengthM))>=2
    clf(fig); hold on;
    native = physical(isfinite(physical.NativeResultM),:);
    if ~isempty(native)
        scatter(native.PhysicalLengthM,native.NativeResultM,14,[.6 .6 .6], ...
            'filled','DisplayName','SX1280');
        if numel(unique(native.PhysicalLengthM))>=2
            fits = [fits;fit_method(native.PhysicalLengthM,native.NativeResultM,'SX1280')];
            plot_fit(native.PhysicalLengthM,fits(end,:),[.6 .6 .6]);
        end
    end
    scatter(physical.PhysicalLengthM,physical.DistanceM,14,'k','filled','DisplayName','Lo-Ran');
    fits = [fits;fit_method(physical.PhysicalLengthM,physical.DistanceM,'Lo-Ran')];
    plot_fit(physical.PhysicalLengthM,fits(end,:),'k');
    t = linspace(min(physical.PhysicalLengthM)-1,max(physical.PhysicalLengthM)+1,100);
    plot(t,t,'k--','DisplayName','d = L'); grid on;
    set(gca,'FontName','Times New Roman','FontSize',10);
    xlabel('Physical cable length, L (m)'); ylabel('Raw ranging result (m)');
    legend('Location','northwest'); save_figure(fig,outputRoot,names{3});
    writetable(fits,fullfile(outputRoot,'loran_linear_fits.csv'));
end
end

function row = fit_method(lengths,values,method)
coefficients = polyfit(lengths,values,1); residual = values-polyval(coefficients,lengths);
variation = sum((values-mean(values)).^2); r2 = NaN;
if variation>0, r2 = 1-sum(residual.^2)/variation; end
row = table({method},coefficients(1),coefficients(2),r2,sqrt(mean(residual.^2)), ...
    'VariableNames',{'Method','Slope','InterceptM','R2','ResidualRMSEM'});
end

function plot_fit(lengths,row,color)
t = linspace(min(lengths)-1,max(lengths)+1,100);
plot(t,row.Slope*t+row.InterceptM,'-','Color',color,'HandleVisibility','off');
end

function save_figure(fig,folder,name)
exportgraphics(fig,fullfile(folder,[name '.pdf']),'ContentType','vector');
exportgraphics(fig,fullfile(folder,[name '.png']),'Resolution',300);
end
