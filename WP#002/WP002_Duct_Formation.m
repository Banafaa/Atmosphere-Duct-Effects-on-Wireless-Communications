%% Wireless Propagation| WP#002
% The Physics of Duct Formation:
% How Weather Creates Radio Waveguides
%
% Author:
% Mohammed Banafaa
%
% Description:
% This simulation demonstrates how variations in atmospheric
% temperature and moisture produce refractivity gradients
% capable of forming a tropospheric trapping layer.
%
% The script calculates atmospheric refractivity N and
% modified refractivity M and identifies regions satisfying
% the trapping condition:
%
%       dM/dz <= 0
%
% Reference:
% M. Banafaa and A. H. Muqaibel,
% "Tropospheric Ducting: A Comprehensive Review and
% Machine Learning-Based Classification Advancements,"
% IEEE Access, 2025.
%
% DOI: 10.1109/ACCESS.2025.3537160



%% WP-002 Part 1: Temperature & Humidity Profiles
clear; clc; close all;

% ---- 1. Data Setup ----
alt   = linspace(0, 500, 200)';      % altitude [m]            
z1    = 60;  z2 = 150;               % duct layer bounds [m]   

% Standard atmosphere 
T_std = 28 - 0.0065*alt;             % temperature [deg C]     
H_std = 20 - 0.0100*alt;             % humidity [mb]           

% Inversion case 
T_inv = T_std;
H_inv = H_std;
band  = alt >= z1 & alt <= z2;
idxB  = find(band);

% Accurate Physics: Temp increases (right), Humidity decreases (left) inside duct
T_inv(band) = T_std(band) + linspace(0, 4, numel(idxB))';        
H_inv(band) = H_std(band) - linspace(0, 4, numel(idxB))';        

% Resume normal lapse rates above the duct (zigzag effect)
if any(alt > z2)
    T_inv(alt > z2) = T_std(alt > z2) + (T_inv(idxB(end)) - T_std(idxB(end))); 
    H_inv(alt > z2) = H_std(alt > z2) + (H_inv(idxB(end)) - H_std(idxB(end))); 
end

altMax = max(alt);
authorTag = 'WP#002 | Mohammed Banafaa';

% ---- 2. Animation settings ----
nFrames  = 40;
alphaVec = [0.5 - 0.5*cos(pi*linspace(0, 1, round(nFrames*0.6))), ones(1, round(nFrames*0.4))]; 
gifName  = 'Post002_Part1.gif';
delayT   = 0.08;

% ---- 3. Figure Rendering Loop ----
% Adjusted width for 2 panels
fig = figure('Color', 'w', 'Position', [100 100 900 480]);

for k = 1:numel(alphaVec)
    a = alphaVec(k);
    
    T = (1-a)*T_std + a*T_inv;
    H = (1-a)*H_std + a*H_inv;
    
    clf(fig);
    
    % LEFT: Temperature profile
    subplot(1,2,1); hold on; box on;
    patch([min(T_std)-5 max(T_inv)+2 max(T_inv)+2 min(T_std)-5], ...
          [z1 z1 z2 z2], [1 0.92 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.10+0.65*a);
          
    h_std = plot(T_std, alt, 'b-',  'LineWidth', 2);
    h_inv = plot(T,     alt, 'r--', 'LineWidth', 2);
    
    ylim([0 altMax]);
    xlabel('Temperature (\circC)', 'FontWeight', 'bold'); ylabel('Altitude (m)', 'FontWeight', 'bold');
    legend([h_std, h_inv], {'Standard', 'Inversion'}, 'Location', 'northwest');
    title('Temperature Profile', 'FontSize', 11);

    % RIGHT: Humidity profile
    subplot(1,2,2); hold on; box on;
    patch([min(H_inv)-2 max(H_std)+2 max(H_std)+2 min(H_inv)-2], ...
          [z1 z1 z2 z2], [1 0.92 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.10+0.65*a);
          
    plot(H_std, alt, 'b-',  'LineWidth', 2);
    plot(H,     alt, 'r--', 'LineWidth', 2);
    
    ylim([0 altMax]);
    xlabel('Humidity (mb)', 'FontWeight', 'bold'); ylabel('Altitude (m)', 'FontWeight', 'bold');
    title('Humidity Profile', 'FontSize', 11);
    
    % Watermark
    annotation('textbox', [0.65 0.01 0.35 0.05], 'String', authorTag, ...
               'EdgeColor', 'none', 'FontWeight', 'bold', 'FontSize', 9, ...
               'HorizontalAlignment', 'right', 'Color', [0.5 0.5 0.5]);
               
    drawnow;
    
    frameImg = getframe(fig);
    [imind, cm] = rgb2ind(frame2im(frameImg), 256);
    if k == 1
        imwrite(imind, cm, gifName, 'gif', 'Loopcount', inf, 'DelayTime', delayT);
    else
        imwrite(imind, cm, gifName, 'gif', 'WriteMode', 'append', 'DelayTime', delayT);
    end
end
fprintf('Saved animation to %s\n', gifName);

%% WP-002 Part 2: M-Profile & Ray Geometry
% clear; clc; close all;

% ---- 1. Data Setup (M-Profile Synthesis) ----
alt   = linspace(0, 500, 200)';      
z1    = 60;  z2 = 150;               

% Standard M-profile (increases ~118 M-units per km)
M_std = 330 + 0.118 * alt;

% Inversion M-profile (sharp decrease inside the duct to trap waves)
M_inv = M_std;
band  = alt >= z1 & alt <= z2;
idxB  = find(band);

% Create the trapping gradient (dM/dz <= 0)
M_inv(band) = M_std(band) - linspace(0, 25, numel(idxB))';

% Resume normal gradient above duct
if any(alt > z2)
    M_inv(alt > z2) = M_std(alt > z2) + (M_inv(idxB(end)) - M_std(idxB(end)));
end

altMax = max(alt);
authorTag = 'WP#002 | Mohammed Banafaa';

% ---- 2. Animation settings ----
nFrames  = 40;
alphaVec = [0.5 - 0.5*cos(pi*linspace(0, 1, round(nFrames*0.6))), ones(1, round(nFrames*0.4))]; 
gifName  = 'Post002_Part2.gif';
delayT   = 0.08;

% ---- 3. Ray Geometry Setup ----
x        = linspace(0, 100, 400);     
horizonX = 40;                        
y0       = 0.06*altMax;               

y_escape = y0 + (1.05*altMax - y0)/100 .* x;
y_bounce = zeros(size(x));

x_entry = 12;   
x_exit  = 88;   
period  = (x_exit - x_entry) / 3; 

idx_asc = x < x_entry;
y_bounce(idx_asc) = y0 + (z1 - y0) * (0.5 - 0.5 * cos(pi * x(idx_asc) / x_entry));

idx_duct = (x >= x_entry) & (x <= x_exit);
amp_duct = (z2 - z1) / 2;
mid_duct = z1 + amp_duct;
y_bounce(idx_duct) = mid_duct - amp_duct * cos(2 * pi * (x(idx_duct) - x_entry) / period);

idx_desc = x > x_exit;
y_bounce(idx_desc) = z1 - (z1 - y0) * (0.5 - 0.5 * cos(pi * (x(idx_desc) - x_exit) / (100 - x_exit)));

% ---- 4. Figure Rendering Loop ----
fig = figure('Color', 'w', 'Position', [100 100 900 480]);

for k = 1:numel(alphaVec)
    a = alphaVec(k);
    
    M = (1-a)*M_std + a*M_inv;
    y = (1-a)*y_escape + a*y_bounce;
    
    clf(fig);
    
    % LEFT: M-Profile
    subplot(1,2,1); hold on; box on;
    patch([min(M_inv)-2 max(M_std)+5 max(M_std)+5 min(M_inv)-2], ...
          [z1 z1 z2 z2], [1 0.92 0.70], 'EdgeColor', 'none', 'FaceAlpha', 0.10+0.65*a);
          
    h_std = plot(M_std, alt, 'b-',  'LineWidth', 2);
    h_inv = plot(M,     alt, 'r--', 'LineWidth', 2);
    
    ylim([0 altMax]);
    xlabel('Modified Refractivity (M-units)', 'FontWeight', 'bold'); ylabel('Altitude (m)', 'FontWeight', 'bold');
    legend([h_std, h_inv], {'Standard', 'Inversion'}, 'Location', 'northwest');
    title('M-Profile', 'FontSize', 11);
    
    if a > 0.5
        text(min(M_inv)+25, ((z1+z2)/2)-10, sprintf('Trapping layer\n(dM/dz \\leq 0)'), ...
             'FontWeight', 'bold', 'FontSize', 9, 'Color', [0.2 0.2 0.2]);
    end

    % RIGHT: Ray path physics
    subplot(1,2,2); hold on; box on;
    patch([0 100 100 0], [z1 z1 z2 z2], [1 0.92 0.70], ...
          'EdgeColor', 'none', 'FaceAlpha', 0.10+0.65*a);
    
    plot(x, y, 'Color', [0.055 0.604 0.655], 'LineWidth', 2.5);
    
    plot([horizonX horizonX], [0 altMax], 'k--', 'Color', [0.5 0.5 0.5]);
    text(horizonX-3, altMax*0.85, 'Radio horizon', 'HorizontalAlignment', 'center', ...
         'FontSize', 9, 'Rotation', 90, 'Color', [0.4 0.4 0.4]);
         
    plot(0, y0, 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
    text(4, y0, 'Tx', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    
    plot(x(end), y0, 'kv', 'MarkerFaceColor', [0.2 0.2 0.2], 'MarkerSize', 7);
    text(x(end)-2, y0 , 'Rx', 'HorizontalAlignment', 'right', 'FontWeight', 'bold');
    
    xlim([0 100]); ylim([0 altMax]);
    xlabel('Range (km)', 'FontWeight', 'bold'); ylabel('Altitude (m)', 'FontWeight', 'bold');
    title('Wave Propagation', 'FontSize', 11);

    % Watermark
    annotation('textbox', [0.65 0.01 0.35 0.05], 'String', authorTag, ...
               'EdgeColor', 'none', 'FontWeight', 'bold', 'FontSize', 9, ...
               'HorizontalAlignment', 'right', 'Color', [0.5 0.5 0.5]);
               
    drawnow;
    
    frameImg = getframe(fig);
    [imind, cm] = rgb2ind(frame2im(frameImg), 256);
    if k == 1
        imwrite(imind, cm, gifName, 'gif', 'Loopcount', inf, 'DelayTime', delayT);
    else
        imwrite(imind, cm, gifName, 'gif', 'WriteMode', 'append', 'DelayTime', delayT);
    end
end
fprintf('Saved animation to %s\n', gifName);
