%% Wireless Propagation| WP#004
% Operating Frequency and Tropospheric Ducting:
% Why the Same Duct Does Not Affect Every Signal Equally
%
% Author:
% Mohammed Banafaa
% -------------------------------------------------------------------------
% OVERVIEW
% -------------------------------------------------------------------------
% This MATLAB simulation illustrates the frequency-dependent nature of
% radio-wave trapping within a simplified tropospheric duct.
%
% The presence of a duct does not imply that electromagnetic waves at all
% frequencies will be confined equally. Instead, the ability of the duct
% to support trapped propagation depends on the relationship between:
%
%   1. Operating frequency, f
%   2. Electromagnetic wavelength, lambda
%   3. Duct thickness, Delta_z
%   4. Duct strength, Delta_M
%   5. Duct type
%
% For a simplified atmospheric duct, the approximate maximum trapped
% wavelength is expressed as:
%
%       lambda_max = (2/3) * C * Delta_z * sqrt(Delta_M)
%
% and the corresponding approximate minimum trapping frequency is:
%
%       f_min = c / lambda_max
%
% or equivalently:
%
%       f_min = 3*c / (2*C*Delta_z*sqrt(Delta_M))
%
% where:
%
%       c        = speed of light
%       C        = duct-type-dependent coefficient
%       Delta_z  = duct thickness
%       Delta_M  = duct strength
%
% The simulation consists of two complementary visualizations.
%
% FIGURE 1:
% Quantifies the relationship between operating frequency, duct strength,
% and the approximate minimum duct thickness required for trapping.
% Increasing either frequency or duct strength reduces the duct thickness
% required to support trapped propagation.
%
% FIGURE 2 / ANIMATION:
% Fixes the atmospheric duct and antenna geometry and compares radio-wave
% behavior at three representative frequencies:
%
%       0.9 GHz  - Low-band cellular
%       1.8 GHz  - Mid-band cellular
%       9.4 GHz  - X-band marine radar
%
% The visualization demonstrates the qualitative transition from stronger
% leakage below the approximate trapping threshold, through transitional
% confinement near the threshold, toward more favorable confinement at
% frequencies well above the threshold.
%
% -------------------------------------------------------------------------
% PHYSICAL INTERPRETATION
% -------------------------------------------------------------------------
% The calculated minimum trapping frequency should not be interpreted as
% an ideal electromagnetic cutoff. Real atmospheric ducts are open,
% vertically varying refractive structures rather than perfectly bounded
% waveguides. Propagation near the threshold can therefore exhibit
% leakage and partial confinement.
%
% The ray visualization used here is intended to communicate the physical
% concept and frequency dependence. It does not constitute a full-wave
% electromagnetic solution.
%
% A subsequent Wireless Propagation Visuals post will use the Parabolic
% Equation (PE) method to calculate the electromagnetic field evolution
% for different operating frequencies under the same duct conditions.
%
% -------------------------------------------------------------------------
% REFERENCES
% -------------------------------------------------------------------------
% [1] ITU-R P.834-9.
%
% [2] M. Banafaa and A. H. Muqaibel, "Tropospheric Ducting:
%     A Comprehensive Review and Machine Learning-Based Classification
%     Advancements," IEEE Access, vol. 13, 2025.
%     DOI: 10.1109/ACCESS.2025.3537160
%
% -------------------------------------------------------------------------

close all;
clc;

%% ========================================================================
% GLOBAL CONSTANTS / STYLE
% =========================================================================

c0 = 299792458;             % speed of light [m/s]
Csurface = 3.77e-3;         % surface/surface-based duct coefficient

% Professional figure palette
navy   = [0.09 0.20 0.30];
blue   = [0.09 0.47 0.72];
orange = [0.90 0.48 0.13];
red    = [0.75 0.24 0.24];
green  = [0.18 0.52 0.34];
gray   = [0.40 0.44 0.48];
lightGray = [0.94 0.96 0.97];

%% ========================================================================
% VISUAL 1 — STATIC FIGURE
% Operating frequency on x-axis.
% =========================================================================

freqGHz = logspace(log10(0.1),log10(40),700);
freqHz = freqGHz*1e9;

DeltaMset = [10 15 20 30];

DeltaZmin = zeros(numel(DeltaMset),numel(freqGHz));

for k = 1:numel(DeltaMset)
    DeltaZmin(k,:) = c0 ./ ...
        ((2/3)*Csurface.*freqHz.*sqrt(DeltaMset(k)));
end

fig1 = figure( ...
    'Color','w', ...
    'Position',[80 80 1000 700], ...
    'Renderer','painters');

ax1 = axes(fig1);
hold(ax1,'on');

for k = 1:numel(DeltaMset)
    semilogx( ...
        ax1, ...
        freqGHz, ...
        DeltaZmin(k,:), ...
        'LineWidth',2.8, ...
        'DisplayName',sprintf('\\DeltaM = %g M-units',DeltaMset(k)));
end

% Important representative frequency guides—not application labels yet.
guideFreq = [0.156 1 3 5 10 20];
for f = guideFreq
    xline(ax1,f,':','LineWidth',0.75,'Color',[0.78 0.80 0.82], ...
        'HandleVisibility','off');
end

xlim(ax1,[0.1 40]);
ylim(ax1,[0 600]);

grid(ax1,'on');
box(ax1,'on');
ax1.GridAlpha = 0.14;
ax1.FontName = 'Arial';
ax1.FontSize = 12;
ax1.XColor = navy;
ax1.YColor = navy;

xlabel(ax1,'Operating frequency (GHz)', ...
    'FontWeight','bold','FontSize',12);

ylabel(ax1,'Approx. minimum duct thickness, \Delta z_{min} (m)', ...
    'FontWeight','bold','FontSize',12);

title(ax1, ...
    'Duct Thickness vs. Operating Frequency', ...
    'FontWeight','bold','FontSize',14,'Color',navy);

subtitle(ax1, ...
    ['Surface-based duct: thicker and stronger ducts can affect ' ...
     'longer wavelengths / lower frequencies'], ...
    'FontSize',12,'Color',gray);

legend(ax1, ...
    'Location','northeast', ...
    'Box','off', ...
    'FontSize',11);

% Equation callout
eqText = { ...
    '\lambda_{max} = (2/3) C \Delta z \surd(\Delta M)', ...
    'f_{min} = c_0 / \lambda_{max}', ...
    'C = 3.77 x 10^{-3}  (surface-based duct)'};

annotation(fig1,'textbox',[0.58 0.57 0.31 0.15], ...
    'String',eqText, ...
    'Interpreter','tex', ...
    'EdgeColor',[0.78 0.82 0.85], ...
    'BackgroundColor','w', ...
    'LineWidth',1.0, ...
    'Margin',10, ...
    'FontName','Arial', ...
    'FontSize',11, ...
    'Color',navy);

% Interpretation callouts
annotation(fig1,'textbox',[0.17 0.70 0.24 0.10], ...
    'String',{'Lower frequencies require','a deeper/stronger duct'}, ...
    'EdgeColor','none', ...
    'HorizontalAlignment','center', ...
    'FontName','Arial', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'Color',orange);

annotation(fig1,'textbox',[0.67 0.31 0.24 0.10], ...
    'String',{'Higher frequencies can be affected','by shallower ducts'}, ...
    'EdgeColor','none', ...
    'HorizontalAlignment','center', ...
    'FontName','Arial', ...
    'FontSize',12, ...
    'FontWeight','bold', ...
    'Color',blue);

% Scientific qualifier
% annotation(fig1,'textbox',[0.12 0.055 0.76 0.055], ...
%     'String', ...
%     ['The trapping transition is gradual rather than a perfect cutoff; ' ...
%      'frequency alone does not guarantee long-range ducted propagation.'], ...
%     'EdgeColor','none', ...
%     'HorizontalAlignment','center', ...
%     'FontName','Arial', ...
%     'FontSize',10.5, ...
%     'Color',gray);

% Footer
annotation(fig1,'line',[0.10 0.90],[0.038 0.038], ...
    'Color',[0.84 0.86 0.88],'LineWidth',1);

annotation(fig1,'textbox',[0.10 0.010 0.32 0.024], ...
    'String','[WP-004]', ...
    'EdgeColor','none', ...
    'FontName','Arial','FontSize',9.5,'Color',gray,'FontWeight', 'bold');

annotation(fig1,'textbox',[0.68 0.010 0.22 0.024], ...
    'String','Mohammed Banafaa', ...
    'EdgeColor','none', ...
    'HorizontalAlignment','right', ...
    'FontName','Arial','FontSize',9.5,'Color',gray,'FontWeight', 'bold');

exportgraphics( ...
    fig1, ...
    'WPV004_Min_Duct_Thickness_vs_Frequency.png', ...
    'Resolution',250);
%% ========================================================================
% VISUAL 2 — SCHEMATIC GIF
% ONE fixed duct; only frequency changes.
% =========================================================================
% Fixed illustrative surface-based duct
DeltaMfixed = 10;           % M-units
DeltaZfixed = 20;           % m (Yields fMin ~ 1.89 GHz)
lambdaMax = (2/3)*Csurface*DeltaZfixed*sqrt(DeltaMfixed);
fMinGHz = c0/lambdaMax/1e9;

% Representative frequencies for real-world systems
freqCasesGHz = [0.9 1.8 9.4]; 

gifFile = 'WPV004_Frequency_Trapping_Schematic.gif';
figG = figure( ...
    'Color','w', ...
    'Position',[120 40 1000 700]);
tl = tiledlayout(figG,3,1, ...
    'TileSpacing','compact', ...
    'Padding','compact');
title(tl, ...
    'Atmospheric Duct - Different Frequencies', ...
    'FontSize',18, ...
    'FontWeight','bold', ...
    'Color',navy);
subtitle(tl, ...
    sprintf(['Fixed surface duct: \\Delta M = %.0f M-units, ' ...
    '\\Delta z = %.0f m'], ...
    DeltaMfixed,DeltaZfixed), ...
    'FontSize',10.5, ...
    'Color',gray);
axs = gobjects(3,1);
for k = 1:3
    axs(k) = nexttile(tl);
end

% --- BRANDING WATERMARK FOR GIF ---
% Attaching to figG so it persists across all frames without needing redraws
annotation(figG, 'line', [0.10 0.90], [0.030 0.030], ...
    'Color', [0.84 0.86 0.88], 'LineWidth', 1);
annotation(figG, 'textbox', [0.10 0.005 0.32 0.024], ...
    'String', '[WP-004]', ...
    'EdgeColor', 'none', ...
    'FontName', 'Arial', 'FontSize', 10, 'Color', gray, 'FontWeight', 'bold');
annotation(figG, 'textbox', [0.68 0.005 0.22 0.024], ...
    'String', 'Mohammed Banafaa', ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'right', ...
    'FontName', 'Arial', 'FontSize', 10, 'Color', gray, 'FontWeight', 'bold');

nFrames = 54;
delayTime = 1/9;
for iFrame = 1:nFrames
    propagationFraction = min(1,(iFrame)/(0.72*nFrames));
    for k = 1:3
        draw_frequency_panel( ...
            axs(k), ...
            freqCasesGHz(k), ...
            fMinGHz, ...
            propagationFraction, ...
            navy,blue,orange,red,green,gray,lightGray);
    end
    drawnow;
    frame = getframe(figG);
    rgb = frame2im(frame);
    [imind,cm] = rgb2ind(rgb,256);
    if iFrame == 1
        imwrite( ...
            imind,cm,gifFile,'gif', ...
            'Loopcount',inf, ...
            'DelayTime',delayTime);
    else
        imwrite( ...
            imind,cm,gifFile,'gif', ...
            'WriteMode','append', ...
            'DelayTime',delayTime);
    end
    
end
fprintf('\nCreated WP-004 assets:\n');
fprintf('  WPV004_Min_Duct_Thickness_vs_Frequency.png\n');
fprintf('  WPV004_Frequency_Trapping_Schematic.gif\n');
fprintf('\nFixed schematic duct has approximate f_min = %.3f GHz.\n',fMinGHz);
fprintf(['The GIF is intentionally schematic and must not be interpreted ' ...
    'as PE field strength, path loss, or received power.\n']);
% end

%% ========================================================================
% LOCAL FUNCTION — GIF PANEL (UPDATED WITH PURELY SCHEMATIC LOGIC)
% =========================================================================
function draw_frequency_panel(ax,fGHz,fMinGHz,progress, ...
    navy,blue,orange,red,green,gray,lightGray)
cla(ax);
hold(ax,'on');
xlim(ax,[0 1]);
ylim(ax,[0 1]);
axis(ax,'off');

% Panel border
rectangle(ax, 'Position',[0.01 0.03 0.98 0.92], 'EdgeColor',[0.84 0.87 0.89], 'LineWidth',0.9);

% Surface
x = linspace(0.03,0.97,500);
surfaceY = 0.18 - 0.02*((x-0.5)/0.47).^2;
fill(ax, [x fliplr(x)], [surfaceY zeros(size(surfaceY))+0.03], lightGray, 'EdgeColor','none');
plot(ax,x,surfaceY,'LineWidth',2.4,'Color',navy);

% Fixed duct
ductBase = surfaceY + 0.10;
ductTop  = surfaceY + 0.39;
fill(ax, [x fliplr(x)], [ductBase fliplr(ductTop)], [1.00 0.91 0.79], 'FaceAlpha',0.55, 'EdgeColor','none');
plot(ax,x,ductBase,'--','Color',orange,'LineWidth',1.15);
plot(ax,x,ductTop ,'--','Color',orange,'LineWidth',1.15);

% Define specific Tx/Rx locations to map wave start/end (User Customized)
xTx = 0.2;
xRx = 0.87;

% Wave trajectory mapping
xr = linspace(xTx, xRx, 650);
baseR = interp1(x, ductBase, xr);
topR  = interp1(x, ductTop, xr);
midR  = 0.5*(baseR+topR);

% Tx/Rx anchored to ground, elements at mid-duct
yTxGround = interp1(x, surfaceY, xTx);
yRxGround = interp1(x, surfaceY, xRx);
yTxAntenna = midR(1);
yRxAntenna = midR(end);
draw_antenna(ax, xTx, yTxGround, yTxAntenna, 'Tx', navy);
draw_antenna(ax, xRx, yRxGround, yRxAntenna, 'Rx', navy);

% --- PURELY SCHEMATIC REGIME LOGIC ---
ratio = fGHz / fMinGHz;

if fGHz == 0.9
    bandSystem = 'Low-Band Cellular';
elseif fGHz == 1.8
    bandSystem = 'Mid-Band Cellular';
else
    bandSystem = 'X-Band Radar';
end

% Visualization-only bands around the approximate trapping threshold.
% They are NOT physical cutoff boundaries.
if ratio < 0.8
    descriptor = 'Escaping';
    statusColor = red;
    leakageVisual = 1.0;
    guidedVisual  = 0.25;
elseif ratio <= 1.2
    descriptor = 'Transitional / Partial';
    statusColor = orange;
    leakageVisual = 0.6;
    guidedVisual  = 0.6;
else
    descriptor = 'Strongly Confined';
    statusColor = green;
    leakageVisual = 0.1;
    guidedVisual  = 1.0;
end

% Frequency labels
text(ax, 0.035, 0.90, sprintf('%.1f GHz (%s)', fGHz, bandSystem), ...
    'FontSize', 12, 'FontWeight', 'bold', 'Color', navy, 'VerticalAlignment', 'top');
text(ax, 0.965, 0.90, descriptor, ...
    'HorizontalAlignment', 'right', 'FontSize', 11, 'FontWeight', 'bold', 'Color', statusColor, 'VerticalAlignment', 'top');

% --- GEOMETRIC ENERGY ENVELOPE (Replaces Artificial Cycles) ---
% A single bouncing geometric path representing the energy flow
geometricBounces = 2.5; 
amplitude = 0.45 * (topR - baseR); 
yr = midR + amplitude .* sin(2*pi*geometricBounces*(xr-xr(1))/(xr(end)-xr(1)));

nShow = max(2,round(progress*numel(xr)));

% Draw the main guided energy. Alpha and LineWidth scale with guidedVisual
plot(ax, xr(1:nShow), yr(1:nShow), 'Color', [blue guidedVisual], 'LineWidth', 2.0 + 3.0*guidedVisual);

if progress > 0
    plot(ax, xr(nShow), yr(nShow), 'o', 'MarkerSize', 4 + 3*guidedVisual, ...
        'MarkerFaceColor', blue, 'MarkerEdgeColor', 'none');
end

% --- SCHEMATIC LEAKAGE PLUMES ---
% Toolbox-free Peak Finding: Locate peaks where the wave hits the upper boundary
locs = find(yr(2:end-1) > yr(1:end-2) & yr(2:end-1) > yr(3:end)) + 1;
for s = 1:numel(locs)
    idx = locs(s);
    if idx > nShow
        continue;
    end
    
    if leakageVisual > 0
        nBranches = round(1 + 4 * leakageVisual);
        for b = 1:nBranches
            xx = linspace(xr(idx), min(0.97, xr(idx) + 0.02 + 0.015*b), 20);
            yy = linspace(yr(idx), topR(idx) + 0.03 + 0.09*b*leakageVisual, 20);
            alphaLeak = min(1, 0.15 + 0.85 * leakageVisual);
            leakColor = alphaLeak*red + (1-alphaLeak)*[1 1 1];
            plot(ax, xx, yy, 'Color', leakColor, 'LineWidth', 1.5 + 1.0*leakageVisual);
        end
    end
end

% % Bottom explanatory labels (User Commented Out)
% text(ax,0.035,0.075, 'Same duct + same Tx/Rx geometry', 'FontSize',9.0, 'Color',gray);
% text(ax,0.965,0.075, 'Only frequency changes', 'HorizontalAlignment','right', 'FontSize',9.0, 'FontWeight','bold', 'Color',gray);
end

%% ========================================================================
% LOCAL FUNCTION — ANTENNA ICON (UPDATED FOR VISIBILITY)
% =========================================================================
function draw_antenna(ax, x0, yBase, yAnt, label, navy)
    % Draw tower structure from ground up to the duct
    plot(ax, [x0 x0], [yBase yAnt], 'Color', navy, 'LineWidth', 2);
    % Draw radiating element
    plot(ax, [x0-0.015 x0 x0+0.015], [yAnt+0.015 yAnt yAnt+0.015], 'Color', navy, 'LineWidth', 2);
    plot(ax, [x0 x0], [yAnt yAnt+0.025], 'Color', navy, 'LineWidth', 2);
    
    % Shift the text outside the propagation path so waves don't overlap it
    if strcmp(label, 'Tx')
        xText = x0 - 0.025; % Shift Left of the antenna
        hAlign = 'right';
    else
        xText = x0 + 0.025; % Shift Right of the antenna
        hAlign = 'left';
    end
    
    % Draw Label centered vertically with the radiating element
    text(ax, xText, yAnt, label, 'HorizontalAlignment', hAlign, ...
         'VerticalAlignment', 'middle', 'FontWeight', 'bold', 'FontSize', 11, 'Color', navy);
end