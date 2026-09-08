%% Wireless Propagation | WP#005
% Same Atmospheric Duct, Different Frequencies:
% What Actually Happens to the Electromagnetic Field?
%
% Author:
% Mohammed Banafaa
%
% -------------------------------------------------------------------------
% OVERVIEW
% -------------------------------------------------------------------------
% This MATLAB simulation investigates how operating frequency changes
% the spatial electromagnetic field distribution within the same
% tropospheric duct.
%
% WP#004 introduced the approximate relationship between operating
% frequency, duct thickness, and duct strength required for effective
% trapping. WP#005 extends that discussion by numerically computing the
% electromagnetic field after propagation begins inside the duct.
%
% The simulation uses the Parabolic Equation (PE) method to calculate the
% forward-propagating complex field:
%
%                       E(x,z)
%
% where:
%
%       x = propagation range
%       z = altitude
%
% The atmospheric duct profile, transmitter geometry, and receiver
% geometry are held fixed while three operating frequencies are compared:
%
%       1 GHz
%       5 GHz
%       10 GHz
%
% This isolates the effect of wavelength on the resulting spatial field.
%
% -------------------------------------------------------------------------
% PHYSICAL PRINCIPLE
% -------------------------------------------------------------------------
% The electromagnetic wavelength is related to operating frequency by:
%
%                       lambda = c/f
%
% Changing frequency therefore changes the phase evolution of the field
% as it propagates through the same refractive environment.
%
% The resulting field contains spatial regions of constructive and
% destructive interference. Consequently, different frequencies can
% produce substantially different field maxima, minima, and fading
% patterns even when they are propagating through the same atmospheric
% duct.
%
% A higher operating frequency should therefore not automatically be
% interpreted as producing a stronger received signal.
%
% -------------------------------------------------------------------------
% SIMULATION WORKFLOW
% -------------------------------------------------------------------------
% The script performs the following operations:
%
%   1. Defines the atmospheric duct / modified refractivity profile.
%
%   2. Defines the common transmitter and receiver geometry.
%
%   3. Sets the three operating frequencies:
%          1 GHz, 5 GHz, and 10 GHz.
%
%   4. Calculates the corresponding electromagnetic wavelengths.
%
%   5. Solves the forward Parabolic Equation for each frequency.
%
%   6. Computes the 2D electromagnetic field over range and altitude.
%
%   7. Extracts the field along the selected receiver altitude.
%
%   8. Compares the frequency-dependent field distributions.
%
%   9. Generates and exports the animated visualization:
%          WP005_figure01.gif
%
% -------------------------------------------------------------------------
% VISUALIZATION
% -------------------------------------------------------------------------
% The generated animation contains two complementary representations.
%
% RIGHT-HAND PANELS:
% Show the two-dimensional PE field distribution as a function of range
% and altitude. These maps reveal the spatial interference structure
% produced inside the atmospheric duct.
%
% LEFT-HAND PANEL:
% Extracts the field along the selected receiver altitude, allowing the
% range-dependent signal variation for the three frequencies to be
% compared directly.
%
% A receiver located at the same range and altitude can therefore lie
% near a field maximum at one frequency and near a deep field minimum
% at another frequency.
%
% -------------------------------------------------------------------------
% INTERPRETATION
% -------------------------------------------------------------------------
% The purpose of this simulation is to demonstrate that:
%
%       DUCTED PROPAGATION DOES NOT IMPLY CONSTANT
%       OR UNIFORMLY ENHANCED SIGNAL STRENGTH.
%
% Successful confinement describes the propagation mechanism, whereas
% the received signal level depends on the local electromagnetic field
% distribution at the receiver position.
%
% Unlike the conceptual ray-based illustration used in WP#004, this
% simulation calculates the spatial field using the PE framework.
%
% -------------------------------------------------------------------------
% REFERENCES
% -------------------------------------------------------------------------
% [1] M. Levy, "Parabolic Equation Methods for Electromagnetic Wave
%     Propagation," IEE Electromagnetic Waves Series 45, 2000.
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
caStandard = 0.118;         % standard-atmosphere M-gradient [M-units/m]

navy   = [0.09 0.20 0.30];
blue   = [0.09 0.47 0.72]; 
orange = [0.90 0.48 0.13];
red    = [0.75 0.24 0.24]; 
green  = [0.18 0.52 0.34]; 
gray   = [0.40 0.44 0.48];
lightGray = [0.94 0.96 0.97]; 

%% ========================================================================
% FROZEN SCENARIO  (identical duct for every frequency)
% =========================================================================
DeltaM     = 30;      % M-units
DeltaZ     = 80;      % m
hTx        = 30;      % m  
rangeMaxKm = 80;      % km
freqCasesGHz = [1 5 10];

Zdisplay  = 500;      % m, height range shown in the figures/GIF
NzDisplay = 301;      % display grid points in height
NrDisplay = 401;      % display grid points in range

fprintf('Frozen duct: DeltaM = %.0f M-units, DeltaZ = %.0f m\n',DeltaM,DeltaZ);
fprintf('Test frequencies (%.0f, %.0f, %.0f GHz) are all above threshold.\n', ...
    freqCasesGHz(1),freqCasesGHz(2),freqCasesGHz(3));

%% ========================================================================
% RUN THE PE SOLVER FOR EACH FREQUENCY
% =========================================================================
zGridDisplay = linspace(0,Zdisplay,NzDisplay);
rGridKm      = linspace(0,rangeMaxKm,NrDisplay);

fieldDB = zeros(NzDisplay,NrDisplay,numel(freqCasesGHz));

for k = 1:numel(freqCasesGHz)
    fprintf('Running PE at %.1f GHz ...\n',freqCasesGHz(k));
    fieldDB(:,:,k) = run_split_step_pe( ...
        freqCasesGHz(k),DeltaM,DeltaZ,hTx,rangeMaxKm, ...
        zGridDisplay,rGridKm,c0,caStandard);
end
fprintf('PE runs complete.\n');

% Extract 30m Field for the Left Static Plot
hObs = 30;
[~, zObsIdx] = min(abs(zGridDisplay - hObs));
hObsActual = zGridDisplay(zObsIdx);

field30m = squeeze(fieldDB(zObsIdx, :, :));
if size(field30m,1) ~= numel(rGridKm)
    field30m = field30m.';
end

climRange = [-40 0];   

%% ========================================================================
% SETUP COMBINED DASHBOARD FIGURE
% =========================================================================
gifFile = 'WPV005_Dashboard_Propagation.gif';

% Adjusted figure height to perfectly support the Square/Rectangle layout
figG = figure('Color','w','Position',[50 50 1400 750]);

% 3x4 Layout: Left side gets 2 columns, Right side gets 2 columns
tl = tiledlayout(figG, 3, 4, 'TileSpacing', 'compact', 'Padding', 'compact');

% --- MAIN TITLE & SUBTITLE ---
title(tl, '[WP-005] The Modal Structure of Trapped Waves', ...
    'FontWeight','bold','FontSize',18,'Color',navy);
subtitle(tl, ...
    sprintf('Surface duct: \\Delta M = %g M-units, \\Delta z = %g m, h_{Tx} = %g m', ...
    DeltaM, DeltaZ, hTx), 'FontSize', 13, 'Color', gray);

% --- LEFT PANEL (SQUARE STATIC 1D PLOT) ---
axLeft = nexttile(tl, 1, [3 2]); % Spans 3 rows, 2 columns
hold(axLeft, 'on'); box(axLeft, 'on');
axis(axLeft, 'square'); % Force the plotting area to be a perfect square

colors = {blue, orange, green}; % Assign distinct colors for lines
for k = 1:numel(freqCasesGHz)
    plot(axLeft, rGridKm, field30m(:,k), 'LineWidth', 2.0, 'Color', colors{k});
end

xlabel(axLeft, 'Range (km)', 'FontWeight', 'bold', 'FontSize', 12);
ylabel(axLeft, 'Relative PE Field Level (dB)', 'FontWeight', 'bold', 'FontSize', 12);

% Updated Left Panel Title
title(axLeft, 'Signal Strength Evolution at Receiver Altitude (30 m)', ...
    'FontSize', 14, 'Color', navy, 'FontWeight', 'bold');

legendText = arrayfun(@(f) sprintf('%.0f GHz', f), freqCasesGHz, 'UniformOutput', false);
lgd = legend(axLeft, legendText, 'Location', 'northeast', 'Box', 'on');
lgd.FontSize = 11;

xlim(axLeft, [0 rangeMaxKm]);
fieldMin = min(field30m(:), [], 'omitnan');
fieldMax = max(field30m(:), [], 'omitnan');
ylim(axLeft, [floor(fieldMin/5)*5, max(0, fieldMax) + 2]);

grid(axLeft, 'on'); axLeft.GridAlpha = 0.15; axLeft.XColor = navy; axLeft.YColor = navy;

% Dynamic Tracking Line for Left Panel
yLims = ylim(axLeft);
hTracker = plot(axLeft, [0 0], yLims, '--', 'Color', red, 'LineWidth', 2, 'HandleVisibility', 'off');

% --- RIGHT PANELS (RECTANGULAR 2D PE HEATMAPS) ---
axR = gobjects(3,1);
hImg = gobjects(3,1);

textFacts = {
    ' 1 GHz (Low Modal Complexity) ', ...
    ' 5 GHz (Distinct Modal Interference) ', ...
    ' 10 GHz (High Modal Complexity & Deep Nulls) '
};

% Indices for the right side in a 3x4 grid (row-major): 3, 7, 11
tileIndices = [3, 7, 11]; 

for k = 1:3
    axR(k) = nexttile(tl, tileIndices(k), [1 2]); % Spans 1 row, 2 columns

    % Initialize empty heatmap to prevent flicker
    hImg(k) = imagesc(axR(k), rGridKm, zGridDisplay, NaN(NzDisplay, NrDisplay));
    set(axR(k),'YDir','normal');
    hold(axR(k),'on');

    xlim(axR(k),[0 rangeMaxKm]);
    ylim(axR(k),[0 Zdisplay]);
    clim(axR(k), climRange);
    colormap(axR(k), 'turbo');

    draw_duct_overlay(axR(k), DeltaZ, orange);
    plot(axR(k), 0, hTx, 'w>', 'MarkerFaceColor', 'k', 'MarkerSize', 8, 'LineWidth', 1);
    
    axR(k).FontName = 'Arial';
    axR(k).FontSize = 10.5;
    axR(k).XColor = navy;
    axR(k).YColor = navy;
    box(axR(k),'on');
    ylabel(axR(k), 'Altitude (m)', 'FontWeight', 'bold', 'FontSize', 11);

    % Set unified title for the right-hand panel group on the first tile
    if k == 1
        title(axR(k), 'Parabolic Equation (PE) Forward-Scatter Heatmaps', ...
            'FontSize', 14, 'Color', navy, 'FontWeight', 'bold');
    end

    if k == 3
        xlabel(axR(k), 'Range (km)', 'FontWeight', 'bold', 'FontSize', 12);
    else
        set(axR(k), 'XTickLabel', []);
    end

    % Frequency Tags
    text(axR(k), 0.015, 0.88, textFacts{k}, ...
        'Units','normalized', ...
        'FontWeight','bold','FontSize',11.5,'Color','w', ...
        'BackgroundColor',navy,'Margin',4);
end

% --- BRANDING WATERMARKS ---
% annotation(figG,'line',[0.05 0.95],[0.025 0.025], 'Color',[0.84 0.86 0.88],'LineWidth',1);
annotation(figG,'textbox',[0.05 0.005 0.32 0.02], 'String','WP#005', ...
    'EdgeColor','none','FontName','Arial','FontSize',10, 'Color',gray,'FontWeight','bold');
annotation(figG,'textbox',[0.68 0.005 0.27 0.02], 'String','Mohammed Banafaa', ...
    'EdgeColor','none','HorizontalAlignment','right', ...
    'FontName','Arial','FontSize',10,'Color',gray,'FontWeight','bold');

%% ========================================================================
% ANIMATION LOOP
% =========================================================================
nFrames = 75;
delayTime = 1/15;

for iFrame = 1:nFrames
    % Advance the propagation to 80% of the frames, then pause for the rest
    progress = min(1, iFrame / (0.8 * nFrames));
    nShowCols = max(2, round(progress * NrDisplay));
    currentRange = rGridKm(nShowCols);

    % Update Tracking Line on Left Plot
    set(hTracker, 'XData', [currentRange currentRange]);

    % Update Heatmaps on Right Plots
    for k = 1:3
        currentField = NaN(NzDisplay, NrDisplay);
        currentField(:, 1:nShowCols) = fieldDB(:, 1:nShowCols, k);
        hImg(k).CData = currentField;
    end

    drawnow;

    frame = getframe(figG);
    rgb = frame2im(frame);
    [imind,cm] = rgb2ind(rgb,256);
    if iFrame == 1
        imwrite(imind,cm,gifFile,'gif','Loopcount',inf,'DelayTime',delayTime);
    else
        imwrite(imind,cm,gifFile,'gif','WriteMode','append','DelayTime',delayTime);
    end
end
fprintf('\nCreated WP-005 Unified Dashboard Simulation:\n');
fprintf('  WPV005_Dashboard_Propagation.gif\n');

%% ========================================================================
% LOCAL FUNCTION — SPLIT-STEP PARABOLIC EQUATION SOLVER
% =========================================================================
function fieldDBdisplay = run_split_step_pe(fGHz,DeltaM,DeltaZ,hTx, ...
    rangeMaxKm,zGridDisplay,rGridKm,c0,caStandard)
lambda = c0/(fGHz*1e9);
k0 = 2*pi/lambda;
thetaMaxRad = deg2rad(3);
dzTarget = lambda/(2*sin(thetaMaxRad));
ZmaxOneSided = max(800,6*DeltaZ);   
Nz1 = max(64,round(ZmaxOneSided/dzTarget));
Nz1 = 2^nextpow2(Nz1);
N = 2*Nz1;
Ltot = 2*ZmaxOneSided;
dz = Ltot/N;
zFull = (-N/2:N/2-1)'*dz;           
rangeMax = rangeMaxKm*1e3;
Nr = 600;                            
dr = rangeMax/Nr;
zAbs = abs(zFull);
M0 = 300;                            
Mz = zeros(size(zAbs));
inDuct = zAbs <= DeltaZ;
Mz(inDuct)  = M0 - (DeltaM/DeltaZ).*zAbs(inDuct);
Mz(~inDuct) = M0 - DeltaM + caStandard.*(zAbs(~inDuct) - DeltaZ);
mIndex = 1 + (Mz - M0).*1e-6;        
refractPhaseScreen = exp(1i*k0*(mIndex-1)*dr);
pAxis = (2*pi/Ltot).*(-N/2:N/2-1)';
diffractPhaseScreen = exp(-1i*(pAxis.^2)*dr/(2*k0));
absorbFrac = 0.15;                   
absorbDepth = absorbFrac*ZmaxOneSided;
edgeDist = ZmaxOneSided - zAbs;      
winAmp = ones(size(zAbs));
inTaper = edgeDist < absorbDepth;
winAmp(inTaper) = 0.5*(1+cos(pi*(absorbDepth - edgeDist(inTaper))/absorbDepth));
sigma0 = max(2*dz,1.0);
u = exp(-((zFull-hTx).^2)./(2*sigma0^2)) - exp(-((zFull+hTx).^2)./(2*sigma0^2));
u = u./max(abs(u));
zPosIdx = find(zFull >= 0);
zPos = zFull(zPosIdx);
rAxisFull = (0:Nr)'*dr;
fieldMagPos = zeros(numel(zPosIdx),Nr+1);
fieldMagPos(:,1) = abs(u(zPosIdx));
for ir = 1:Nr
    Uf = fftshift(fft(u));
    Uf = Uf.*diffractPhaseScreen;
    u = ifft(ifftshift(Uf));
    u = u.*refractPhaseScreen;
    u = u.*winAmp;
    fieldMagPos(:,ir+1) = abs(u(zPosIdx));
end
peakVal = max(fieldMagPos(:));
fieldDBfull = 20*log10(max(fieldMagPos,eps)./peakVal);
rGridM = rGridKm*1e3;
[Rq,Zq] = meshgrid(rGridM,zGridDisplay);
[Rf,Zf] = meshgrid(rAxisFull,zPos);
fieldDBdisplay = interp2(Rf,Zf,fieldDBfull,Rq,Zq,'linear',-60);
fieldDBdisplay = max(fieldDBdisplay,-60);
end

%% ========================================================================
% LOCAL FUNCTION — DUCT TOP-BOUNDARY OVERLAY 
% =========================================================================
function draw_duct_overlay(ax,DeltaZ,orange)
yline(ax,DeltaZ,'--','Color',orange,'LineWidth',1.3,'HandleVisibility','off');
end