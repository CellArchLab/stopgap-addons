function [positions,eulers] = sg_motl_generate_spline_function(points,dist,phi_angle_type)
%% sg_motl_generate_spline_function
% A function for generating a spline with initial euler angles from a set
% of points along spline axis. 
%
% WW 11-2020



%% Generating spline fit of filament
n_points = size(points,2);

% Create spline function from clicked points
F = spline((1:n_points),points);

% Calculate total distance along spline
total_dist = 0;
for i = 2:n_points
    d_vec = points(:,i)-points(:,(i-1));
    total_dist = total_dist + sqrt((d_vec(1)^2)+(d_vec(2)^2)+(d_vec(3)^2));
end

% Number of steps along spline
frac_dist = ceil(total_dist/dist);  

% Steps as fraction of input points
steps = 1:((n_points-1)/frac_dist):n_points;

% Evaulate spline points
positions = ppval(F,steps);
n_pos = size(positions,2);


%% Calculate Euler angles

% Initialize Euler matrix
eulers = zeros(3,n_pos);

% Calcualte PSI and THETA angles
for i=2:n_pos  % For each pair of points on the spline

    % Parse points
    p1 = positions(:,i-1);
    p2 = positions(:,i);

    % Translation vector
    vec = p2-p1;

    % Calcualte PSI angle
    psi = 90 + atan2d(vec(2),vec(1));

    % Calculate THE angle
    xy = sqrt((vec(1)^2)+(vec(2)^2));
    the = 90 - atan2d(vec(3),xy);
    
    % Store Eulers
    eulers(2,i-1) = psi;
    eulers(3,i-1) = the;

end

% Copy last euler
eulers(2,end) = eulers(2,end-1);
eulers(3,end) = eulers(3,end-1);

% Fill PHI angles
if ischar(phi_angle_type) && strcmp(phi_angle_type,'rand')
    eulers(1,:) = rand(1,n_pos).*360;

else
    eulers(1,:) = ((0:(n_pos-1)).*phi_angle_type(2)) + phi_angle_type(1);

end


