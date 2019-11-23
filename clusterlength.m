function [ spoints ] = clusterlength( spoints, minlength, state )
% cluster based on the number of points associated with a given state

% deprecated, replaced by directly specifying the minimum number of points
% to be determined as being in a domain (minlength)
% avglength = mean(trajlen);
% find the minimum length to be significant
% minlength = poissinv(0.95, avglength);
% minlength = max(median(trajlen), 2);

% for each trajectory, see if the state 2 length is significantly above
% average
for t = 1:max(spoints(:,5))
    % 1: x, 2: y, 3: frame, 4: state, 5: traj id, 6: group id
    points = spoints(spoints(:,5) == t & spoints(:,4) == state, :);
    
    % if the state 2 length is significantly above average and if it
    % doesn't already have a group id
    if size(points, 1) > minlength && unique(points(:,6)) == 0
        % if significantly longer than average in state 2, then it is a
        % domain
        spoints(spoints(:,5) == t, 6) = max(spoints(:, 6)) + 1;
    end
end

end

