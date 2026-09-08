%% tropo_duct_animation.m
% Wireless Propagation Visuals #001 - Tropospheric Ducting
% Generates an animated GIF showing a standard ray (blocked at the radio
% horizon/escaping) versus a ducted ray (guided within the tropospheric 
% duct to a receiver far beyond line of sight).
clear; clc; close all;

%% ---- Geometry / parameters ------------------------------------------
X_MAX     = 400;    % km, schematic horizontal extent
Y_MAX     = 1000;   % m,  schematic vertical extent (exaggerated)
DUCT_TOP  = 300;    % m,  duct layer top

tx_x = 6;   tx_h = 55;                 % transmitter position/height
horizon_x = 95;                        % radio horizon marker (km)
rx_x = 370; rx_h = 40;                 % receiver (ship) position

C_DUCT      = [0.961 0.706 0.200];
C_DUCT_EDGE = [0.725 0.467 0.055];
C_TRAP_RAY  = [0.055 0.604 0.655];
C_STD_RAY   = [0.906 0.298 0.235];
C_HORIZON   = [0.499 0.549 0.553];
C_TOWER     = [0.173 0.243 0.314];
C_SEA       = [0.055 0.239 0.361];
C_TEXT      = [0.110 0.157 0.202];

% ---- Earth Curvature Function ----
% Center the Earth bulge exactly between the TX and RX
mid_x = (tx_x + rx_x) / 2; 
curve_factor = 0.008;

% Add an offset so that the curve at the transmitter is exactly at y = 0
y_offset = curve_factor * (tx_x - mid_x)^2; 
EARTH_CURVE = @(x) y_offset - curve_factor * (x - mid_x).^2;

% Calculate surface heights at TX and RX locations
cy_tx = EARTH_CURVE(tx_x);
cy_rx = EARTH_CURVE(rx_x);

%% ---- Ray geometry -----------------------------------------------------
% 1. Standard (escaping) ray
% Moves in a straight/slightly curved line that fails to follow the Earth
xs_std = linspace(tx_x, X_MAX, 300);
ys_std = (cy_tx + tx_h) + 2.8 * (xs_std - tx_x); % Escapes linearly out of duct
keep = ys_std <= Y_MAX*1.02;
xs_std = xs_std(keep); ys_std = ys_std(keep);

% 2. Trapped (ducted) ray
% Bends back and forth but follows the underlying Earth curvature
period = (rx_x - tx_x) / 3; % Exactly 3 bounces
xs_trap = linspace(tx_x, X_MAX-15, 1400);

% Calculate amplitude so the wave fills the entire space from 0 (surface) to DUCT_TOP
amp = (DUCT_TOP - 15) / 2.0; 

% A phase shift ensures the wave starts exactly at TX height but can still reach 0
phase = acos(1 - tx_h/amp); 

% The equation now allows the wave's minima to touch the Earth's surface
ys_trap = EARTH_CURVE(xs_trap) + amp * (1 - cos(2*pi*(xs_trap - tx_x)/period + phase));


%% ---- Animation timing --------------------------------------------------
TOTAL_FRAMES = 110;
GROW_FRAMES  = 82;
speed = (xs_trap(end) - tx_x) / GROW_FRAMES;   % km per frame during growth
std_len   = xs_std(end)  - tx_x;  std_finish_frame  = std_len/speed;
trap_len  = xs_trap(end) - tx_x;  trap_finish_frame = trap_len/speed;


outFile = 'tropo_duct_animation.gif';
fig = figure('Color', [0.980 0.984 0.992], 'Position', [100 100 1200 680]);
ax = axes(fig); hold(ax, 'on');

% Pre-calculate curvature vectors for the background patches
cx = linspace(0, X_MAX, 400);
cy = EARTH_CURVE(cx);



for frame = 0:TOTAL_FRAMES-1
    cla(ax); hold(ax, 'on');
    
    % --- background: sky, sea, duct band ---
    % Sky
    patch(ax, [0 X_MAX X_MAX 0], [-150 -150 Y_MAX Y_MAX], [0.918 0.949 0.973], 'EdgeColor', 'none');
    
    % Curved Sea (fills to bottom of plot)
    patch(ax, [cx, fliplr(cx)], [cy, repmat(-150, 1, length(cx))], C_SEA, 'EdgeColor', 'none');
    plot(ax, cx, cy, 'Color', [0.082 0.263 0.376], 'LineWidth', 1.3);
    
    % Curved Duct
    patch(ax, [cx, fliplr(cx)], [cy, fliplr(cy + DUCT_TOP)], C_DUCT, 'FaceAlpha', 0.32, 'EdgeColor', 'none');
    plot(ax, cx, cy + DUCT_TOP, '--', 'Color', C_DUCT_EDGE, 'LineWidth', 1.4);
    text(ax, X_MAX-8, EARTH_CURVE(X_MAX) + DUCT_TOP - 5, 'Duct top', 'Color', C_DUCT_EDGE, ...
         'FontAngle', 'italic', 'FontSize', 9, 'HorizontalAlignment', 'right','Rotation', -33);
     
% --- transmitter tower (Real lattice tower look) ---
    tx_w = 2.5; % Tower base half-width
    % Left leg, Right leg, converging at top
    plot(ax, [tx_x-tx_w, tx_x, tx_x+tx_w], [cy_tx, cy_tx+tx_h, cy_tx], 'Color', C_TOWER, 'LineWidth', 2);
    % Cross-bracing (Lattice effect)
    plot(ax, [tx_x-tx_w*0.6, tx_x+tx_w*0.6], [cy_tx+tx_h*0.4, cy_tx+tx_h*0.4], 'Color', C_TOWER, 'LineWidth', 1.5);
    plot(ax, [tx_x-tx_w*0.3, tx_x+tx_w*0.3], [cy_tx+tx_h*0.7, cy_tx+tx_h*0.7], 'Color', C_TOWER, 'LineWidth', 1.5);
    % Top antenna array
    plot(ax, [tx_x, tx_x], [cy_tx+tx_h, cy_tx+tx_h+15], 'Color', C_TOWER, 'LineWidth', 2);
    plot(ax, [tx_x-2, tx_x+2], [cy_tx+tx_h+8, cy_tx+tx_h+8], 'Color', C_TOWER, 'LineWidth', 1.5);
    text(ax, tx_x+5, cy_tx+tx_h+40, 'TX', 'Color', C_TOWER, 'FontWeight', 'bold', 'FontSize', 9);
    
    % --- receiver (ship with real cabin and mast) ---
    hull_x = [rx_x-18 rx_x+18 rx_x+13 rx_x-15];
    hull_y = [cy_rx cy_rx cy_rx+12 cy_rx+12];
    patch(ax, hull_x, hull_y, C_TOWER, 'EdgeColor', C_TOWER); % Hull
    % Ship cabin
    patch(ax, [rx_x-8, rx_x+5, rx_x+5, rx_x-8], [cy_rx+12, cy_rx+12, cy_rx+22, cy_rx+22], C_TOWER, 'EdgeColor', 'none');
    % A-Frame Mast
    mast_top = cy_rx+rx_h+16;
    plot(ax, [rx_x-4, rx_x, rx_x+4], [cy_rx+22, mast_top, cy_rx+22], 'Color', C_TOWER, 'LineWidth', 1.5);
    % Radar dish at the top
    plot(ax, [rx_x-3.5, rx_x+3.5], [mast_top, mast_top], 'Color', C_TOWER, 'LineWidth', 2.5);
    plot(ax, rx_x, mast_top, 'v', 'Color', C_TOWER, 'MarkerSize', 5, 'MarkerFaceColor', C_TOWER);
    text(ax, rx_x, cy_rx+rx_h+48, 'RX (beyond LOS)', 'Color', C_TOWER, ...
         'FontWeight', 'bold', 'FontSize', 8.5, 'HorizontalAlignment', 'center');
     
    % --- horizon marker ---
    plot(ax, [horizon_x horizon_x], [EARTH_CURVE(horizon_x) Y_MAX], ':', 'Color', C_HORIZON, 'LineWidth', 1.4);
    text(ax, horizon_x+17, Y_MAX*0.95, 'Radio horizon', 'Color', C_HORIZON, ...
         'FontAngle', 'italic', 'FontSize', 9, 'HorizontalAlignment', 'center');
     
% --- growing rays (with dynamic arrowheads) ---
    reach = min(frame, GROW_FRAMES) * speed;
    
    % Aspect ratio scale to prevent the rotating arrows from distorting
    % (Roughly Y_MAX / X_MAX, tuned for visual smoothness)
    a_scale = 2.5; 
    
    % 1. Standard ray rendering
    m_std = xs_std <= (tx_x + reach);
    if nnz(m_std) < 2, m_std(1:2) = true; end
    plot(ax, xs_std(m_std), ys_std(m_std), 'Color', C_STD_RAY, 'LineWidth', 2.5);
    
    if reach < std_len
        idx = find(m_std, 1, 'last');
        if idx > 2
            % Calculate angle of trajectory
            dx = xs_std(idx) - xs_std(idx-2);
            dy = ys_std(idx) - ys_std(idx-2);
            ang = atan2(dy / a_scale, dx);
            
            % Create and rotate arrowhead
            arr_L = 7; arr_W = 7; % Arrow length/width
            ptX = [0, -arr_L, -arr_L]; ptY = [0, arr_W, -arr_W];
            rotX = ptX*cos(ang) - ptY*sin(ang)/a_scale + xs_std(idx);
            rotY = ptX*sin(ang)*a_scale + ptY*cos(ang) + ys_std(idx);
            patch(ax, rotX, rotY, C_STD_RAY, 'EdgeColor', 'none');
        end
    end
    
    % 2. Trapped ray rendering
    m_trap = xs_trap <= (tx_x + reach);
    if nnz(m_trap) < 2, m_trap(1:2) = true; end
    plot(ax, xs_trap(m_trap), ys_trap(m_trap), 'Color', C_TRAP_RAY, 'LineWidth', 2.5);
    
    if reach < trap_len
        idx = find(m_trap, 1, 'last');
        if idx > 2
            % Calculate angle of trajectory
            dx = xs_trap(idx) - xs_trap(idx-2);
            dy = ys_trap(idx) - ys_trap(idx-2);
            ang = atan2(dy / a_scale, dx);
            
            % Create and rotate arrowhead
            arr_L = 7; arr_W = 7; % Arrow length/width
            ptX = [0, -arr_L, -arr_L]; ptY = [0, arr_W, -arr_W];
            rotX = ptX*cos(ang) - ptY*sin(ang)/a_scale + xs_trap(idx);
            rotY = ptX*sin(ang)*a_scale + ptY*cos(ang) + ys_trap(idx);
            patch(ax, rotX, rotY, C_TRAP_RAY, 'EdgeColor', 'none');
        end
    end
    
    % --- captions ---
    if frame > std_finish_frame + 3
        text(ax, 10, 800, {'Standard ray', 'blocked beyond radio horizon'}, ...
            'Color', C_STD_RAY, 'FontWeight', 'bold', 'FontSize', 10);
    end
    if frame > trap_finish_frame + 3
        text(ax, 10, 700, {'Ducted ray reaches receiver', '(beyond line of sight)'}, ...
         'Color', C_TRAP_RAY, 'FontWeight', 'bold', 'FontSize', 10);
         
        % receiver arrival glow
        t = (frame - trap_finish_frame) * 0.35;
        sz = 90 + 40*sin(t);
        scatter(ax, rx_x, cy_rx+rx_h+16, sz, C_TRAP_RAY, 'filled', 'MarkerFaceAlpha', 0.35);
    end
    
    % Adjust limits to frame properly
    xlim(ax, [0 X_MAX]); ylim(ax, [0 Y_MAX]);
    xlabel(ax, 'Distance (km)'); ylabel(ax, 'Height (m)');
    title(ax, 'Beyond the Horizon: The Tropospheric Ducting Effect', ...
          'Color', C_TEXT, 'FontWeight', 'bold', 'FontSize', 14);
    set(ax, 'Box', 'off', 'Color', [0.980 0.984 0.992]);
    drawnow;
     % --- EXTENDED RANGE VISUALS ---
    
    % 1. Define coordinates
    % Assuming your radio horizon variable is 'd_horiz' and receiver is at x = 370
    rx = 367;      % Replace with your actual receiver X-coordinate variable if you have one
    y_arrow = 600;   % The height at which the arrow is drawn (Y-axis)
    d_horiz=97;
    % 2. Vertical dotted line above the Receiver (RX)
    % Draws from the ground up to y = 650
    plot(ax, [370, 370], [0, 650], 'k:', 'LineWidth', 1, 'Color', [0.5 0.5 0.5]);
    
    % 3. The horizontal double-arrow line
    % We use standard plot commands with '<' and '>' markers. This is much safer for 
    % GIF animations than using MATLAB's annotation() function, which can shift around.
    plot(ax, [d_horiz, rx], [y_arrow, y_arrow], 'k-.', 'LineWidth', 0.8); % The main line
    plot(ax, d_horiz, y_arrow, 'k<', 'MarkerFaceColor', 'k', 'MarkerSize', 5); % Left arrowhead
    plot(ax, rx, y_arrow, 'k>', 'MarkerFaceColor', 'k', 'MarkerSize', 5);    % Right arrowhead
    
    % 4. The "Extended Range" Text
    % Calculate the exact middle point between the horizon and the receiver
    x_center = (d_horiz + rx) / 2;
    
    % Place the text centered just above the arrow (y_arrow + 15)
    text(ax, x_center + 10, y_arrow + 15, 'Extended Range', ...
        'Color', 'k', 'FontSize', 10, 'HorizontalAlignment', 'center');
    % --- Copyright / Author Watermark ---
    % Placed in the bottom right corner
    % Assuming your X-axis goes to 400
    text(ax, 55, 20, 'WP#001 | Mohammed Banafaa', ...
        'Color', [0.6 0.6 0.6], 'FontSize', 9, ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
    % --- capture frame and append to GIF ---
    frameImg = getframe(fig);
    [imind, cm] = rgb2ind(frame2im(frameImg), 256);
    if frame == 0
        imwrite(imind, cm, outFile, 'gif', 'Loopcount', inf, 'DelayTime', 0.055);
    else
        imwrite(imind, cm, outFile, 'gif', 'WriteMode', 'append', 'DelayTime', 0.055);
    end
end


fprintf('Saved %s\n', outFile);