% CS184 Project 1 - Rasterizer
% Procedural SVG for spirals images
% Author: Nico Deshler

% define screenspace origin
ox = 100;
oy = 100;

% specify the number of triangles desired to make the spiral
num_tris = 200;

% function for spiral in polar coordinates
theta = linspace(-2,0.001,num_tris+1) * 2*pi;
rho = ox/(4*pi) * theta;

% convert to cartesian
[x,y] = pol2cart(theta,rho);

% add offset for image centering
x = x' + ox;
y = y' + oy;

% construct triangle coordinates
tris = [ox*ones(num_tris,1),oy*ones(num_tris,1), x(1:end-1),y(1:end-1),x(2:end),y(2:end)];

% construct vertex colors via rotations through RGB space
colors = zeros(num_tris+1,3);
color = [1 1 0]';
alpha = 4*pi/num_tris;
RGB_rot = ones(3);

% Hue rotation matrix
cosA = cos(alpha);
sinA = sin(alpha);
RGB_rot(1,1) = cosA + (1.0 - cosA) / 3.0;
RGB_rot(1,2) = 1./3. * (1.0 - cosA) - sqrt(1./3.) * sinA;
RGB_rot(1,3) = 1./3. * (1.0 - cosA) + sqrt(1./3.) * sinA;
RGB_rot(2,1) = 1./3. * (1.0 - cosA) + sqrt(1./3.) * sinA;
RGB_rot(2,2) = cosA + 1./3.*(1.0 - cosA);
RGB_rot(2,3) = 1./3. * (1.0 - cosA) - sqrt(1./3.) * sinA;
RGB_rot(3,1) = 1./3. * (1.0 - cosA) - sqrt(1./3.) * sinA;
RGB_rot(3,2) = 1./3. * (1.0 - cosA) + sqrt(1./3.) * sinA;
RGB_rot(3,3) = cosA + 1./3. * (1.0 - cosA);

% Axis rotation matrix
% RGB_rot = rotx(45)*rotz(alpha); % UNCOMMENT 


for i = 1:num_tris+1
    colors(i,:) = color';
    color = RGB_rot*color;
end
tri_colors = [colors(1:end-1,:),colors(2:end,:)];
inputs = horzcat(tris, tri_colors);


% prep wrapper
wrapperID = fopen('SVGwrapper.txt','r');
cac = textscan( wrapperID, '%s', 'Delimiter','\n', 'CollectOutput',true );
cac = cac{1};
fclose( wrapperID );

% write file
formatSpec = '<colortri points="%f %f %f %f %f %f" colors="0 0 0 0 %f %f %f 0 %f %f %f 0"/>\n';
fileID = fopen('SVG_snail.SVG','w');

for jj = 1 : length(cac)
    fprintf( fileID, '%s\n', cac{jj} );
    if (jj == length(cac)-1)
        fprintf(fileID,formatSpec,inputs');
    end
end
fclose(fileID);
