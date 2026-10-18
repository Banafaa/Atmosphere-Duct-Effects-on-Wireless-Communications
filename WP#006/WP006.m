%% WP006 - Local Signal Strength vs. Duct Confinement
% Author: Mohammed Banafaa
% Series: Wireless Propagation Visuals - WP-006
%
% PURPOSE
%   Reproduce a stationary, single-frequency coastal PE example in which
%   a local receiver-height field minimum coexists with high modeled duct
%   confinement. This file contains the solver and visualization code;
%   it requires no downloaded field maps or private development files.
%
% METHOD
%   Two-dimensional, one-way narrow-angle split-step Fourier PE (SSPE):
%     du/dr = i/(2*k0)*d^2u/dz^2 + i*k0*1e-6*(M(z)-Mref)*u.
%   Symmetric refractivity half-steps enclose a Fourier diffraction step.
%   Odd extension imposes the horizontal-polarization ideal-PEC condition
%   u(r,0)=0. A fixed-altitude sponge and angular taper limit artificial
%   upper-boundary reflections; neither is a perfectly matched layer.
%   The full-domain confinement percentage is
%     100*integral(0:60 m,|u|^2 dz)/integral(0:zmax,|u|^2 dz).
%
% CONFIGURATION
%   3.5 GHz; idealized range-independent 60 m surface-based duct with a
%   20 M-unit deficit; Tx 15 m; Rx 40 m; Gaussian source sigma 4 m;
%   level launch; 0-80 km; 50 m range steps; 0.25 m height steps;
%   saved every 250 m; 2000 m computational ceiling.
%   To preserve the approved relative-field normalization, the script
%   first computes the original 30 m Tx/30 m Rx reference amplitude with
%   the same SSPE operator. Only the 15 m Tx field is visualized.
%
% RUN / OUTPUTS
%   Place WP006.m in a writable WP-006 directory and run WP006 in MATLAB
%   R2024b. Figures is created next to this file. It receives the two
%   README filenames WP006_Fig_1.png and WP006_Fig_2.gif, as well as the
%   requested WP006_Final.png and WP006_Final.gif aliases.
%   Dependencies: MATLAB R2024b base product only. No optional toolbox.
%
% LIMITS / REFERENCES
%   The Gaussian excitation, modified-refractivity profile, PEC sea, and
%   finite computational domain are idealizations. Relative field is not
%   calibrated received power; vertical PE intensity fraction is not a
%   measured 3-D power fraction. GIF frames sample space, not time.
%   O. Ozgun et al., Comput. Phys. Commun. 182 (2011), 2638-2654;
%   M. Levy, Parabolic Equation Methods for Electromagnetic Wave
%   Propagation, IEE Electromagnetic Waves Series 45, 2000;
%   F. Liu et al., J. Commun. Inf. Netw. 6(2), 2021.

clear; close all; clc;

%% Fixed physical model and numerical settings
if verLessThan('matlab','24.2')
    error('WP006:Version', ...
        'WP006.m requires MATLAB R2024b or later.');
end
requiredFunctions = {'fft','ifft','interp1','trapz','exportgraphics', ...
    'imread','imfinfo','rgb2ind','imwrite','parula'};
for j = 1:numel(requiredFunctions)
    if exist(requiredFunctions{j},'file')==0 && ...
            exist(requiredFunctions{j},'builtin')==0
        error('WP006:Dependency', ...
            'Required MATLAB function %s is unavailable.', ...
            requiredFunctions{j});
    end
end
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir)
    error('WP006:ScriptPath', ...
        'Save this file as WP006.m and run the saved script.');
end
outputFolder = fullfile(scriptDir,'Figures');
if ~isfolder(outputFolder)
    [ok,msg] = mkdir(outputFolder);
    if ~ok
        error('WP006:Output', ...
            'Cannot create Figures beside WP006.m: %s',msg);
    end
end

cfg = struct();
cfg.description = 'Idealized, range-independent surface-based duct';
cfg.frequencyGHz = 3.5;
cfg.c0 = 299792458;
cfg.Msurface = 330;
cfg.ductDeficitM = 20;
cfg.ductTopM = 60;
cfg.MgradientAbovePerM = 0.118;
cfg.txHeightM = 15;
cfg.rxHeightM = 40;
cfg.sourceSigmaM = 4;
cfg.launchElevationDeg = 0;
cfg.rangeMaxKm = 80;
cfg.dxM = 50;
cfg.dzM = 0.25;
cfg.ceilingM = 2000;
cfg.saveSpacingM = 250;
cfg.lowerBoundary = 'horizontal_PEC_Dirichlet';
cfg.observationTopM = 400;
cfg.absorberStartM = 600;
cfg.absorberScaleM = 300;
cfg.absorberAlphaAtScalePerKm = 4.0;
cfg.absorberPower = 2;
cfg.topGuardDepthM = 100;
cfg.angularCutoffDeg = 5.0;
cfg.angularTaperStartFraction = 0.85;
cfg.angularAlphaPerKm = 2.0;

receiverHeightM = 40;
nullKm = 32.00;
pairedMaximumKm = 46.25;
mapTopM = 160;                % Display crop; metric uses full height.
mapColorLimitsDb = [-60 10]; % Unchanged for every animation frame.
fieldAxisLimitsDb = [-60 12];
gifFrameSpacingKm = 1.0;
gifDelaySeconds = 0.25;
nullHoldSeconds = 2.0;
pairedHoldSeconds = 1.0;

%% Regenerate the original normalization and the approved complex field
% The historic 30 m reference determines only the common amplitude scale.
% Replacing it with the 15 m case's own maximum would alter every field-dB
% annotation even though confinement and field contrasts would be intact.
referenceCfg = cfg;
referenceCfg.txHeightM = 30;
referenceCfg.rxHeightM = 30;
fprintf('Computing the common field normalization...\n');
referenceRun = run_case_sspe(referenceCfg,30,false);
referenceAmplitude = max(abs(referenceRun.receiverComplex(1,:)));
assert(isfinite(referenceAmplitude) && referenceAmplitude>0, ...
    'WP006:Normalization','Invalid reference field amplitude.');
clear referenceRun;

fprintf('Computing the approved 15 m transmitter field...\n');
out = run_case_sspe(cfg,receiverHeightM,true);
x = out.rangeKm(:);
z = out.heightM(:);
U = out.complexField;
fieldAtReceiver = out.receiverComplex(1,:).';
assert(isequal(size(U),[numel(z),numel(x)]), ...
    'WP006:FieldGrid','Complex field dimensions are inconsistent.');
assert(max(abs(fieldAtReceiver-interp1(z,U,receiverHeightM).'))/ ...
    referenceAmplitude<1e-9, ...
    'WP006:FieldSample', ...
    'Receiver samples and the generated complex field disagree.');

fieldDb = field_db(fieldAtReceiver,referenceAmplitude);
fullPct = 100*out.fullConfinement(:);
ductIntensity = out.ductIntensity(:);
fullIntensity = out.totalIntensity(:);
assert(all(isfinite(fieldDb)) && all(isfinite(fullPct)) && ...
    all(fullPct>=0 & fullPct<=100+1e-7) && ...
    max(abs(fullPct-100*ductIntensity./fullIntensity))<1e-7, ...
    'WP006:Metrics','Generated field or confinement is invalid.');

%% Selected-range metrics and regression checks
% These are approved locations to inspect, never substituted field data.
iNull = find(abs(x-nullKm)<1e-9,1);
iPeak = find(abs(x-pairedMaximumKm)<1e-9,1);
assert(~isempty(iNull) && ~isempty(iPeak) && ...
    iNull>1 && iNull<numel(x) && iPeak>1 && iPeak<numel(x), ...
    'WP006:RangeGrid', ...
    'The saved range grid does not contain the selected locations.');
left = find(x>=nullKm-2 & x<nullKm);
right = find(x>nullKm & x<=nullKm+2);
assert(~isempty(left) && ~isempty(right), ...
    'WP006:Neighborhood','The +/-2 km neighborhood is incomplete.');
nullProminenceDb = min(max(fieldDb(left)),max(fieldDb(right))) ...
    -fieldDb(iNull);
pairContrastDb = fieldDb(iPeak)-fieldDb(iNull);
assert(fieldDb(iNull)<fieldDb(iNull-1) && ...
    fieldDb(iNull)<fieldDb(iNull+1) && ...
    fieldDb(iPeak)>fieldDb(iPeak-1) && ...
    fieldDb(iPeak)>fieldDb(iPeak+1), ...
    'WP006:Extrema', ...
    'The approved ranges are no longer a local minimum/maximum.');
% Rounded published values serve only as regression targets. All plotted
% numbers above are computed from this execution, never these constants.
if abs(fieldDb(iNull)-(-49.36))>0.20 || ...
        abs(nullProminenceDb-18.54)>0.20 || ...
        abs(fullPct(iNull)-97.48)>0.20 || ...
        abs(pairContrastDb-36.205)>0.20
    error('WP006:Regression', ...
        ['The regenerated result differs materially from the approved ' ...
         'reference. Review the solver and MATLAB environment before ' ...
         'publishing figures. Field %.3f dB; prominence %.3f dB; ' ...
         'confinement %.3f%%; pair contrast %.3f dB.'], ...
        fieldDb(iNull),nullProminenceDb,fullPct(iNull),pairContrastDb);
end

inDuct = z<=cfg.ductTopM;
nullProfile = abs(U(:,iNull)).^2;
assert(trapz(z(inDuct),nullProfile(inDuct))>0 && ...
    max(nullProfile(inDuct & abs(z-receiverHeightM)>2))> ...
    abs(fieldAtReceiver(iNull)).^2, ...
    'WP006:Profile', ...
    'The local minimum lacks modeled field intensity elsewhere in the duct.');
result = struct('nullFieldDb',fieldDb(iNull), ...
    'nullLocalProminenceDb',nullProminenceDb, ...
    'nullFullConfinementPct',fullPct(iNull), ...
    'pairContrastDb',pairContrastDb);
fprintf(['32 km: field %.3f dB; local prominence %.3f dB; ' ...
    'full-domain confinement %.3f%%.\n'], ...
    result.nullFieldDb,result.nullLocalProminenceDb, ...
    result.nullFullConfinementPct);
fprintf('32-to-46.25 km field difference: %.3f dB.\n', ...
    result.pairContrastDb);

zView = z(z<=mapTopM);
mapDb = field_db(U(z<=mapTopM,:),referenceAmplitude);

%% Publication figure: fixed text bands outside the two plot areas
navy = [0.06 0.22 0.43];
blue = [0.12 0.38 0.67];
orange = [0.88 0.43 0.12];
muted = [0.36 0.42 0.49];
fig = figure('Color','w','Units','inches', ...
    'Position',[0.5 0.5 19 10.8]);
annotation(fig,'textbox',[0.08 0.945 0.84 0.038], ...
    'String','Local Signal Strength vs. Duct Confinement', ...
    'EdgeColor','none','FontName','Arial','FontSize',26, ...
    'FontWeight','bold','Color',navy, ...
    'HorizontalAlignment','center','VerticalAlignment','middle');
annotation(fig,'textbox',[0.08 0.903 0.84 0.029], ...
    'String','3.5 GHz | 60 m surface duct | Tx: 15 m | Rx: 40 m', ...
    'EdgeColor','none','FontName','Arial','FontSize',15, ...
    'Color',muted,'HorizontalAlignment','center', ...
    'VerticalAlignment','middle');

annotation(fig,'textbox',[0.09 0.837 0.82 0.025], ...
    'String','(a) Relative field at the 40 m receiver height', ...
    'EdgeColor','none','FontName','Arial','FontSize',16, ...
    'FontWeight','bold','Color',navy);
ax1 = axes('Parent',fig,'Units','normalized', ...
    'Position',[0.09 0.532 0.82 0.290]);
pField = plot(ax1,x,fieldDb,'Color',blue,'LineWidth',2.4); hold(ax1,'on');
xline(ax1,nullKm,':','Color',orange,'LineWidth',1.5);
xline(ax1,pairedMaximumKm,':','Color',navy,'LineWidth',1.1);
pNull = plot(ax1,x(iNull),fieldDb(iNull),'o', ...
    'MarkerFaceColor',orange,'MarkerEdgeColor','w','MarkerSize',11);
pPaired = plot(ax1,x(iPeak),fieldDb(iPeak),'s', ...
    'MarkerFaceColor',navy,'MarkerEdgeColor','w','MarkerSize',9);
set(ax1,'XLim',[0 80],'YLim',fieldAxisLimitsDb, ...
    'FontName','Arial','FontSize',13,'TickDir','out', ...
    'Box','off','XGrid','on','YGrid','on','GridAlpha',0.16);
ylabel(ax1,'Relative receiver field (dB)','FontName','Arial');
xlabel(ax1,'Propagation range (km)','FontName','Arial');
legend(ax1,[pField pNull pPaired], ...
    {'40 m field','32 km minimum','46.25 km paired sample'}, ...
    'Location','northeast','FontName','Arial', ...
    'FontSize',11,'Box','off');

annotation(fig,'textbox',[0.09 0.447 0.82 0.025], ...
    'String','(b) Full-domain duct confinement', ...
    'EdgeColor','none','FontName','Arial','FontSize',16, ...
    'FontWeight','bold','Color',navy);
ax2 = axes('Parent',fig,'Units','normalized', ...
    'Position',[0.09 0.230 0.82 0.203]);
plot(ax2,x,fullPct,'Color',blue,'LineWidth',2.4); hold(ax2,'on');
xline(ax2,nullKm,':','Color',orange,'LineWidth',1.5);
xline(ax2,pairedMaximumKm,':','Color',navy,'LineWidth',1.1);
plot(ax2,x(iNull),fullPct(iNull),'o', ...
    'MarkerFaceColor',orange,'MarkerEdgeColor','w','MarkerSize',11);
plot(ax2,x(iPeak),fullPct(iPeak),'s', ...
    'MarkerFaceColor',navy,'MarkerEdgeColor','w','MarkerSize',9);
set(ax2,'XLim',[0 80],'YLim',[0 100], ...
    'FontName','Arial','FontSize',13,'TickDir','out', ...
    'Box','off','XGrid','on','YGrid','on','GridAlpha',0.16);
ylabel(ax2,'Duct / full domain (%)','FontName','Arial');
xlabel(ax2,'Propagation range (km)','FontName','Arial');

annotation(fig,'textbox',[0.09 0.106 0.82 0.042], ...
    'String',sprintf(['32 km local minimum: %.2f dB | ' ...
    '%.2f dB prominence (within +/-2 km) | %.2f%% confined'], ...
    result.nullFieldDb,result.nullLocalProminenceDb,fullPct(iNull)), ...
    'EdgeColor','none','BackgroundColor',[0.95 0.97 0.99], ...
    'FontName','Arial','FontSize',14,'FontWeight','bold', ...
    'Color',navy,'HorizontalAlignment','center', ...
    'VerticalAlignment','middle');
annotation(fig,'textbox',[0.09 0.078 0.82 0.025], ...
    'String',sprintf(['32 to 46.25 km field difference: %.2f dB ' ...
    '(separate from local null prominence)'],result.pairContrastDb), ...
    'EdgeColor','none','FontName','Arial','FontSize',12, ...
    'Color',muted,'HorizontalAlignment','center');
annotation(fig,'textbox',[0.09 0.049 0.82 0.022], ...
    'String',['Idealized, single-frequency PE simulation; relative field ' ...
    'is not measured received power.'], ...
    'EdgeColor','none','FontName','Arial','FontSize',11, ...
    'Color',muted,'HorizontalAlignment','center');
add_wp006_footer(fig,navy,muted);
staticFile = fullfile(outputFolder,'WP006_Fig_1.png');
exportgraphics(fig,staticFile, ...
    'Resolution',100);
close(fig);
copyfile(staticFile,fullfile(outputFolder,'WP006_Final.png'),'f');

%% Spatial-sampling animation: fixed map and three numeric readouts
fig = figure('Color','w','Units','inches', ...
    'Position',[0.5 0.5 19 10.8]);
annotation(fig,'textbox',[0.08 0.944 0.84 0.038], ...
    'String','Local Signal Strength vs. Duct Confinement', ...
    'EdgeColor','none','FontName','Arial','FontSize',26, ...
    'FontWeight','bold','Color',navy, ...
    'HorizontalAlignment','center','VerticalAlignment','middle');
annotation(fig,'textbox',[0.08 0.901 0.84 0.029], ...
    'String','3.5 GHz | 60 m surface duct | Tx: 15 m | Rx: 40 m', ...
    'EdgeColor','none','FontName','Arial','FontSize',15, ...
    'Color',muted,'HorizontalAlignment','center', ...
    'VerticalAlignment','middle');

readoutRange = make_readout(fig,[0.08 0.816 0.25 0.069],navy);
readoutField = make_readout(fig,[0.375 0.816 0.25 0.069],navy);
readoutDuct = make_readout(fig,[0.67 0.816 0.25 0.069],navy);
annotation(fig,'textbox',[0.08 0.782 0.81 0.023], ...
    'String','Stationary PE field | displayed height 0-160 m', ...
    'EdgeColor','none','FontName','Arial','FontSize',15, ...
    'FontWeight','bold','Color',navy);

am = axes('Parent',fig,'Units','normalized', ...
    'Position',[0.08 0.517 0.78 0.250]);
imagesc(am,x,zView,mapDb);
set(am,'YDir','normal','XLim',[0 80],'YLim',[0 mapTopM], ...
    'CLim',mapColorLimitsDb,'FontName','Arial', ...
    'FontSize',12,'Box','off','TickDir','out');
colormap(am,parula(256));
cb = colorbar(am);
set(cb,'Units','normalized','Position',[0.88 0.517 0.017 0.250], ...
    'FontName','Arial','FontSize',11);
cb.Label.String = 'Relative field (dB)';
cb.Label.FontName = 'Arial';
cb.Label.FontSize = 12;
% colorbar creation can resize its peer axis, so restore both positions.
set(am,'Position',[0.08 0.517 0.78 0.250]);
set(cb,'Position',[0.88 0.517 0.017 0.250]);
hold(am,'on');
plot(am,[0 80],[60 60],'w--','LineWidth',1.6);
plot(am,[0 80],[40 40],'w:','LineWidth',1.4);
plot(am,0,15,'^','MarkerFaceColor','w', ...
    'MarkerEdgeColor',navy,'MarkerSize',9);
hm = plot(am,[0 0],[0 mapTopM],'w-','LineWidth',1.4);
hr = plot(am,0,40,'o','MarkerFaceColor',orange, ...
    'MarkerEdgeColor','w','MarkerSize',11);
ylabel(am,'Height above ideal sea (m)','FontName','Arial');
xlabel(am,'Propagation range (km)','FontName','Arial');

annotation(fig,'textbox',[0.08 0.433 0.39 0.025], ...
    'String','Relative receiver-height field', ...
    'EdgeColor','none','FontName','Arial','FontSize',15, ...
    'FontWeight','bold','Color',navy);
annotation(fig,'textbox',[0.57 0.433 0.35 0.025], ...
    'String','Full-domain duct confinement', ...
    'EdgeColor','none','FontName','Arial','FontSize',15, ...
    'FontWeight','bold','Color',navy);

af = axes('Parent',fig,'Units','normalized', ...
    'Position',[0.08 0.205 0.395 0.211]);
gField = plot(af,x,fieldDb,'Color',blue,'LineWidth',2.2); hold(af,'on');
gNull = plot(af,nullKm,fieldDb(iNull),'o','MarkerSize',10, ...
    'MarkerFaceColor',orange,'MarkerEdgeColor','w');
gPaired = plot(af,pairedMaximumKm,fieldDb(iPeak),'s','MarkerSize',8, ...
    'MarkerFaceColor',navy,'MarkerEdgeColor','w');
hf = plot(af,x(1),fieldDb(1),'o', ...
    'MarkerFaceColor',orange,'MarkerEdgeColor','w','MarkerSize',10);
xf = plot(af,[0 0],fieldAxisLimitsDb,':', ...
    'Color',orange,'LineWidth',1.2);
set(af,'XLim',[0 80],'YLim',fieldAxisLimitsDb, ...
    'FontName','Arial','FontSize',12,'TickDir','out', ...
    'Box','off','XGrid','on','YGrid','on','GridAlpha',0.16);
xlabel(af,'Range (km)');
ylabel(af,'Field at 40 m (dB)');
legend(af,[gField gNull gPaired], ...
    {'40 m field','32 km minimum','46.25 km paired'}, ...
    'Location','northeast','FontName','Arial', ...
    'FontSize',10,'Box','off');

ac = axes('Parent',fig,'Units','normalized', ...
    'Position',[0.57 0.205 0.35 0.211]);
plot(ac,x,fullPct,'Color',blue,'LineWidth',2.2); hold(ac,'on');
plot(ac,nullKm,fullPct(iNull),'o','MarkerSize',10, ...
    'MarkerFaceColor',orange,'MarkerEdgeColor','w');
plot(ac,pairedMaximumKm,fullPct(iPeak),'s','MarkerSize',8, ...
    'MarkerFaceColor',navy,'MarkerEdgeColor','w');
hc = plot(ac,x(1),fullPct(1),'o', ...
    'MarkerFaceColor',orange,'MarkerEdgeColor','w','MarkerSize',10);
xc = plot(ac,[0 0],[0 100],':','Color',orange,'LineWidth',1.2);
set(ac,'XLim',[0 80],'YLim',[0 100], ...
    'FontName','Arial','FontSize',12,'TickDir','out', ...
    'Box','off','XGrid','on','YGrid','on','GridAlpha',0.16);
xlabel(ac,'Range (km)');
ylabel(ac,'Duct / full domain (%)');

annotation(fig,'textbox',[0.08 0.088 0.84 0.030], ...
    'String',sprintf(['32 km minimum | ' ...
    'Local null prominence: %.2f dB | ' ...
    'Duct confinement: %.2f%%'], ...
    result.nullLocalProminenceDb,fullPct(iNull)), ...
    'EdgeColor','none', ...
    'BackgroundColor',[0.95 0.97 0.99], ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','middle', ...
    'FontName','Arial','FontSize',13,'Color',navy);

annotation(fig,'textbox',[0.08 0.059 0.84 0.022], ...
    'String',['Idealized single-frequency PE model | ' ...
    'Spatial sampling, not temporal fading'], ...
    'EdgeColor','none','HorizontalAlignment','center', ...
    'FontName','Arial','FontSize',11,'Color',muted);

add_wp006_footer(fig,navy,muted);

stride = max(1,round(gifFrameSpacingKm/(x(2)-x(1))));
frameIndices = unique([1:stride:numel(x),iNull,iPeak,numel(x)]);
gifFile = fullfile(outputFolder,'WP006_Fig_2.gif');
assert(numel(frameIndices)>1, ...
    'WP006:Animation','The animation needs multiple spatial samples.');
framePng = fullfile(outputFolder,'WP006_frame_temp.png');
for j = 1:numel(frameIndices)
    ii = frameIndices(j);
    set(hm,'XData',[x(ii) x(ii)]);
    set(hr,'XData',x(ii));
    set(hf,'XData',x(ii),'YData',fieldDb(ii));
    set(hc,'XData',x(ii),'YData',fullPct(ii));
    set(xf,'XData',[x(ii) x(ii)]);
    set(xc,'XData',[x(ii) x(ii)]);
    set(readoutRange,'String',sprintf('RANGE\n%.2f km',x(ii)));
    set(readoutField,'String',sprintf('FIELD AT 40 m\n%.2f dB',fieldDb(ii)));
    set(readoutDuct,'String',sprintf('DUCT CONFINEMENT\n%.2f%%',fullPct(ii)));
    drawnow;
    % Export at a known size; getframe can crop a 1900-px figure on a
    % smaller laptop display. The same color limits and source persist.
    exportgraphics(fig,framePng,'Resolution',100);
    rgb = imread(framePng);
    if j==1
        [indexed,palette] = rgb2ind(rgb,256,'nodither');
    else
        indexed = rgb2ind(rgb,palette,'nodither');
    end
    delay = gifDelaySeconds;
    if ii==iNull, delay = delay+nullHoldSeconds; end
    if ii==iPeak, delay = delay+pairedHoldSeconds; end
    if j==1
        imwrite(indexed,palette,gifFile,'gif', ...
            'LoopCount',Inf,'DelayTime',delay);
    else
        imwrite(indexed,palette,gifFile,'gif', ...
            'WriteMode','append','DelayTime',delay);
    end
end
if isfile(framePng), delete(framePng); end
close(fig);

gifInfo = imfinfo(gifFile);
assert(numel(gifInfo)>1, ...
    'WP006:Animation','The exported GIF contains fewer than two frames.');
copyfile(gifFile,fullfile(outputFolder,'WP006_Final.gif'),'f');
fprintf('Saved the PNG and %d-frame GIF in %s\n', ...
    numel(gifInfo),outputFolder);

%% Local SSPE and figure helper functions

% These numerical functions are carried over from the locally validated
% transmitter-height investigation. Their propagation equations, source
% normalization, spectral filter, sponge and quadrature are unchanged.
function validate_cfg(c,heights)
    % Guard grid alignment and the published physical configuration.
    assert(c.frequencyGHz==3.5 && c.ductDeficitM==20 && ...
        c.ductTopM==60 && c.rangeMaxKm==80);
    assert(strcmp(c.lowerBoundary,'horizontal_PEC_Dirichlet'));
    assert(c.txHeightM>0 && c.txHeightM<c.ductTopM);
    assert(c.sourceSigmaM/c.dzM>=3, ...
        'Source width under-resolved on the chosen height grid.');
    assert(c.observationTopM==400 && ...
        c.absorberStartM>=500 && c.absorberStartM<=700 && ...
        c.ceilingM>c.absorberStartM+100);
    assert(all(heights>0 & heights<c.ductTopM));
    assert(abs(c.ceilingM/c.dzM-round(c.ceilingM/c.dzM))<1e-9);
    assert(abs(c.ductTopM/c.dzM-round(c.ductTopM/c.dzM))<1e-9);
    assert(abs(c.observationTopM/c.dzM- ...
        round(c.observationTopM/c.dzM))<1e-9);
    assert(abs(c.rangeMaxKm*1000/c.dxM- ...
        round(c.rangeMaxKm*1000/c.dxM))<1e-9);
    assert(abs(c.saveSpacingM/c.dxM- ...
        round(c.saveSpacingM/c.dxM))<1e-9);
    assert(c.angularCutoffDeg>=4 && c.angularCutoffDeg<=6);
end

function M = modified_refractivity(z,c)
    % Piecewise surface-based duct followed by the upper M gradient.
    M = c.Msurface-(c.ductDeficitM/c.ductTopM)* ...
        min(z,c.ductTopM)+c.MgradientAbovePerM* ...
        max(z-c.ductTopM,0);
end

function u = launch_field(zFull,zPositive,c)
    % Unit-integral Gaussian aperture with its odd PEC image.
    za=abs(zFull);
    source=exp(-0.5*((za-c.txHeightM)/c.sourceSigmaM).^2);
    image=exp(-0.5*((za+c.txHeightM)/c.sourceSigmaM).^2);
    % Odd field for horizontal polarization on ideal smooth PEC sea.
    u=sign(zFull).*(source-image).*exp( ...
        1i*(2*pi*c.frequencyGHz*1e9/c.c0)* ...
        sind(c.launchElevationDeg)*(za-c.txHeightM));
    nHalf=numel(zPositive);
    u=complex(u/sqrt(trapz(zPositive,abs(u(nHalf+1:end)).^2)));
end
function out = run_case_sspe(c,heights,keepField)
    % Strang SSPE on a mirrored FFT domain; optionally retain each column.
    validate_cfg(c,heights);
    nHalf=round(c.ceilingM/c.dzM);
    zFull=(-nHalf:nHalf-1)'*c.dzM;
    z=(0:nHalf-1)'*c.dzM;
    positive=(nHalf+1:2*nHalf)';
    k0=2*pi*c.frequencyGHz*1e9/c.c0;
    dxKm=c.dxM/1000;
    nSteps=round(c.rangeMaxKm*1000/c.dxM);
    stride=round(c.saveSpacingM/c.dxM);
    nSaved=round(nSteps/stride)+1;
    assert(abs(nSteps/stride-round(nSteps/stride))<1e-9);
    M=modified_refractivity(abs(zFull),c);
    Mref=modified_refractivity(c.txHeightM,c);
    mediumHalf=exp(1i*k0*1e-6*(M-Mref)*c.dxM/2);
    n=2*nHalf;
    kz=(2*pi/(n*c.dzM))*[0:n/2-1 -n/2:-1]';
    diffraction=exp(-1i*kz.^2*c.dxM/(2*k0));
    cutoff=k0*sind(c.angularCutoffDeg);
    beginTaper=c.angularTaperStartFraction*cutoff;
    ak=abs(kz);
    angularWindow=ones(n,1);
    t=ak>beginTaper & ak<cutoff;
    q=(ak(t)-beginTaper)/(cutoff-beginTaper);
    angularWindow(t)=exp(-c.angularAlphaPerKm*dxKm* ...
        (q.^2.*(3-2*q)));
    angularWindow(ak>=cutoff)=0;
    alphaPerKm=c.absorberAlphaAtScalePerKm* ...
        (max(abs(zFull)-c.absorberStartM,0)/ ...
        c.absorberScaleM).^c.absorberPower;
    absorber=exp(-alphaPerKm*dxKm);
    u=launch_field(zFull,z,c);
    out=struct();
    out.rangeKm=(0:nSaved-1)'*c.saveSpacingM/1000;
    out.heightM=z;
    out.sampleHeightsM=heights(:);
    out.receiverComplex=complex(zeros(numel(heights),nSaved));
    out.ductIntensity=zeros(nSaved,1);
    out.outsidePassiveIntensity=zeros(nSaved,1);
    out.passiveIntensity=zeros(nSaved,1);
    out.absorberIntensity=zeros(nSaved,1);
    out.totalIntensity=zeros(nSaved,1);
    out.confinement=zeros(nSaved,1);
    out.fullConfinement=zeros(nSaved,1);
    out.topGuardFraction=zeros(nSaved,1);
    out.boundaryResidual=zeros(nSaved,1);
    out.cumulativeSpongeLoss=zeros(nSaved,1);
    out.cumulativeAngularLoss=zeros(nSaved,1);
    if keepField
        out.complexField=complex(zeros(nHalf,nSaved));
    else
        out.complexField=complex([]);
    end
    ductEnd=round(c.ductTopM/c.dzM)+1;
    passiveEnd=round(c.observationTopM/c.dzM)+1;
    spongeBegin=round(c.absorberStartM/c.dzM)+1;
    guardBegin=find(z>=c.ceilingM-c.topGuardDepthM,1);
    accumulatedSponge=0;
    accumulatedAngular=0;
    saved=0;
    for step=0:nSteps
        if mod(step,stride)==0
            saved=saved+1;
            up=u(positive);
            intensity=abs(up).^2;
            out.receiverComplex(:,saved)=interp1(z,up,heights(:));
            out.ductIntensity(saved)= ...
                trapz(z(1:ductEnd),intensity(1:ductEnd));
            out.passiveIntensity(saved)= ...
                trapz(z(1:passiveEnd),intensity(1:passiveEnd));
            out.outsidePassiveIntensity(saved)= ...
                out.passiveIntensity(saved)-out.ductIntensity(saved);
            out.absorberIntensity(saved)= ...
                trapz(z(spongeBegin:end),intensity(spongeBegin:end));
            out.totalIntensity(saved)=trapz(z,intensity);
            out.confinement(saved)=out.ductIntensity(saved)/ ...
                max(out.passiveIntensity(saved),realmin);
            out.fullConfinement(saved)=out.ductIntensity(saved)/ ...
                max(out.totalIntensity(saved),realmin);
            out.topGuardFraction(saved)= ...
                trapz(z(guardBegin:end),intensity(guardBegin:end))/ ...
                max(out.totalIntensity(saved),realmin);
            out.boundaryResidual(saved)=abs(u(nHalf+1))/ ...
                max(max(abs(u)),realmin);
            out.cumulativeSpongeLoss(saved)=accumulatedSponge;
            out.cumulativeAngularLoss(saved)=accumulatedAngular;
            if keepField, out.complexField(:,saved)=up; end
        end
        if step==nSteps, break; end
        u=mediumHalf.*u;
        before=c.dzM*sum(abs(u).^2)/2;
        u=ifft(fft(u).*diffraction.*angularWindow);
        afterAngular=c.dzM*sum(abs(u).^2)/2;
        accumulatedAngular=accumulatedAngular+max(0,before-afterAngular);
        u=absorber.*mediumHalf.*u;
        afterSponge=c.dzM*sum(abs(u).^2)/2;
        accumulatedSponge=accumulatedSponge+ ...
            max(0,afterAngular-afterSponge);
    end
    assert(saved==nSaved && all(isfinite(out.confinement)));
end
function db = field_db(u,referenceAmplitude)
    % Relative complex-field magnitude using the fixed common reference.
    db = 20*log10(max(abs(u),realmin)/referenceAmplitude);
end

function h = make_readout(fig,position,ink)
    % Fixed-position two-line GIF readout, independent of numeric width.
    h = annotation(fig,'textbox',position, ...
        'String','', 'EdgeColor',[0.83 0.88 0.93], ...
        'BackgroundColor',[0.95 0.97 0.99], ...
        'LineWidth',0.8,'Margin',4, ...
        'FontName','Arial','FontSize',16,'FontWeight','bold', ...
        'Color',ink,'HorizontalAlignment','center', ...
        'VerticalAlignment','middle');
end

function add_wp006_footer(fig,ink,muted)
    % Persistent identity outside all plot axes.
    annotation(fig,'textbox',[0.08 0.021 0.20 0.024], ...
        'String','WP-006','EdgeColor','none', ...
        'FontName','Arial','FontSize',11,'FontWeight','bold', ...
        'Color',ink,'HorizontalAlignment','left');
    annotation(fig,'textbox',[0.69 0.021 0.23 0.024], ...
        'String','Mohammed Banafaa','EdgeColor','none', ...
        'FontName','Arial','FontSize',11,'Color',muted, ...
        'HorizontalAlignment','right');
end
