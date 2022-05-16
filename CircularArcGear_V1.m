axis equal
hold on

% Input variables

m = 3;              % modul
z_w = 37;           % number of teeth wheel 
z_p = 12;           % number of teeth pinion

% Constants

error_limit = 0.000001;

% Precalculations

pitch = m * pi;         % Reference pitch
u = z_w/z_p;            % Gear ratio
d_w = m * z_w;          % Pitch diameter wheel
r_w = d_w/2;            % Pitch radius wheel
d_p = m * z_p;          % Pitch diameter pinion
r_p = d_p/2;            % Pitch radius pinion

hf_w = m * pi/2;        % Dedendum wheel
hf_w_r = r_w - hf_w;    % Dedendum radius wheel


f_a = calc_addendum_factor(error_limit, u, z_p);     % Addendum factor
h_a = 0.95 * f_a * m;                                % Addendum height
ha_w_r = r_w + h_a;                                  % Addendum radius wheel

f_r = 1.4 * f_a;                             % Addendum radius factor
a_r = f_r * m;                               % Addendum radius


% ****************** Calculations for Design/Construction ****************************

%Calculate wheel pitch circle

[x_pitch_w, y_pitch_w] = calc_circle_pt(r_w, 200);

plot(x_pitch_w, y_pitch_w);

% Calculate wheel dedendum circle

[x_ded_w, y_ded_w] = calc_circle_pt(hf_w_r, 200);

%plot(x_ded_w, y_ded_w);

% Calculate wheel addendum circle

[x_add_w, y_add_w] = calc_circle_pt(ha_w_r, 200);

plot(x_add_w, y_add_w);

%********************************************************************

% Draw line from origin to addendum circle

l_x = [0,0];
l_y = [0,ha_w_r];

plot(l_x,l_y)

% Draw rotated dedendum line

dedendum_pt_st = [0,0;hf_w_r,r_w];

rot_ded_deg = 360/(4*z_w);
rot_ded = rot_ded_deg * pi/180;

dedendum_pt = rotation_z(rot_ded, dedendum_pt_st);

%plot(dedendum_pt(1,:), dedendum_pt(2,:))

% Find center point for addendum radius (using a rhombus-approach, see
% https://math.stackexchange.com/questions/1781438/finding-the-center-of-a-circle-given-two-points-and-a-radius-algebraically)
        
    %Distance between the start of the arc on the pitch circle to end of
    %the arc at the addendum circle at x = 0

    start_arc = [dedendum_pt(1,2);dedendum_pt(2,2)];
    end_arc = [0; ha_w_r];
    
    dist_arc = calc_distance(end_arc(1,1), end_arc(2,1),dedendum_pt(1,2), dedendum_pt(2,2) );
    
    %plot(end_arc(1,1), end_arc(2,1), 'o')
    %plot(dedendum_pt(1,2), dedendum_pt(2,2), 'o')

    % Finding the middle point of the rhombus
    
    vec_rhombus = [(dedendum_pt(1,2)-end_arc(1,1)); ( dedendum_pt(2,2)-end_arc(2,1))];
    vec_rhombus = vec_rhombus/norm(vec_rhombus);

    rhombus_cent = start_arc - vec_rhombus * dist_arc/2;

    %plot(rhombus_cent(1,1), rhombus_cent(2,1), 'o');
    
    %Calculate distance from rhombus center to the center of the arc
    
    b = sqrt(a_r^2 - (dist_arc/2)^2);

    % Draw vector, perpenicular to the vec_rhombus, with length of b from
    % rhombus_center

    vec_arc_center = [-vec_rhombus(2,1) ; vec_rhombus(1,1)];

    arc_center = rhombus_cent + vec_arc_center * b;

    %plot(arc_center(1,1), arc_center(2,1), 'o');

    %test1 = calc_distance(end_arc(1,1), end_arc(2,1),arc_center(1,1), arc_center(2,1) );
    %test2 = calc_distance(dedendum_pt(1,2), dedendum_pt(2,2),arc_center(1,1), arc_center(2,1) );

    % Calculate the arc

    angle_start = atan2(dedendum_pt(2,2) - arc_center(2,1),dedendum_pt(1,2) - arc_center(1,1));
    angle_end = atan2(end_arc(2,1) - arc_center(2,1), end_arc(1,1) - arc_center(1,1));

    [x_arc, y_arc] = arc_circle(angle_start, angle_end, 80, arc_center(1,1), arc_center(2,1), a_r);

    %plot(x_arc,y_arc)

% Calculate the Dedendum arc in the pitch range of one tooth

    % Calculate the point on the dedendum circle which is exactly centered between two teeth
    
    pt_de_w = [0 ; hf_w_r];
    
    pt_de_w = rotation_z(2*pi/(2*z_w),pt_de_w);
    
    angle_start_dd = atan2(dedendum_pt(2,1) - 0, dedendum_pt(1,1) - 0);     
    angle_end_dd = atan2(pt_de_w(2,1) - 0, pt_de_w(1,1) - 0); 

    [x_ded, y_ded] = arc_circle(angle_start_dd, angle_end_dd, 70, 0, 0,hf_w_r);

    %plot(x_ded, y_ded)

% Combine all the points of the left profile into one matrix

tooth_profile_left_x = [flip(x_ded),flip(dedendum_pt(1,:)), x_arc];
tooth_profile_left_y = [flip(y_ded),flip(dedendum_pt(2,:)), y_arc];

%plot(tooth_profile_left_x, tooth_profile_left_y)

% Mirror the left profile and combine all the points into one tooth_profil
% matrix

tooth_profile_right_x = - tooth_profile_left_x;
tooth_profile_right_y = tooth_profile_left_y;

%plot(tooth_profile_right_x, tooth_profile_right_y)

tooth_profile_x = [tooth_profile_left_x, flip(tooth_profile_right_x)];
tooth_profile_y = [tooth_profile_left_y, flip(tooth_profile_right_y)];

plot(tooth_profile_x, tooth_profile_y);

%*************************************** FUNCTIONS ******************************************************

function [result_addendum_factor] = calc_addendum_factor(error, ratio, z_p)
   
    t0 = 1;
    t1 = 0;

    while abs(t1 - t0) > error

            t0 = t1;
            beta = atan(sin(t0)/(1 + 2*ratio - cos(t0)));
            t1 = pi/z_p + 2*ratio* beta;
    end

    k = 1 + 2*ratio;
    result_addendum_factor= 0.25 * z_p * (1 - k + sqrt(1 + k * k - 2*k*cos(t1)));

end

function [X,Y] = calc_circle_pt(radius, number_points)

theta = linspace(0,2*pi,number_points);
X=radius*cos(theta);
Y=radius*sin(theta);

end

function [matrix_out] = rotation_z(a,matrix_in )

R_z = [cos(a), -sin(a);
       sin(a),   cos(a)];

matrix_out = R_z * matrix_in;
end

function [d] = calc_distance(p1_x,p1_y,p2_x,p2_y)

    d = sqrt((p2_x-p1_x)^2 +(p2_y-p1_y)^2);

end

function [circle_x, circle_y] = arc_circle(startang, endang, number_points, circle_center_x, circle_center_y, radius)

circ_vec = linspace( startang, endang,number_points);

circle_x = radius * cos(circ_vec) + circle_center_x;
circle_y = radius * sin(circ_vec) + circle_center_y;


end