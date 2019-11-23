function [ tx, ty ] = expandboundary( x, y, points, locacc )
% takes input points, returns expanded boundary

% expand the boundary points by localization accuracy
% center of the points as the origin
tx = x - mean(points(:, 1));
ty = y - mean(points(:, 2));

% convert to polar
angle = atan2(ty, tx);
radius = sqrt(tx.^2 + ty.^2);

% expand boundary by locacc
radius = radius + locacc;

% convert to cartesian
tx = radius.*cos(angle);
ty = radius.*sin(angle);

% return to original location
tx = tx + mean(points(:, 1));
ty = ty + mean(points(:, 2));

end

