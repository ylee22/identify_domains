function [ domains, spoints ] = clustertrajs( spoints, locacc, state, min_term_points, min_grow_points )
% 1. cluster points
% use boundary to find the outer points
% group trajectories together if other trajectory points are found inside
% of the boundary
% 2. terminate groups in time using only state 3 trajectories (don't use
% trajectories that transition between 2 and 3)
% state 3 points will never be used to grow clusters

% returns domains: contains trajectory IDs for each domain (group ID)
% spoints: % 1: x, 2: y, 3: frame, 4: state, 5: traj id, 6: group id

% separate points into each state
sps = cell(1, max(spoints(:,4)));
for s = 1:numel(sps)
    sps{s} = spoints(spoints(:,4)==s, :);
end

% points used to terminate domain growth
if state == 1
    % for state 1, use state 2 and state 3 points to terminate
    tpoints = [sps{2}; sps{3}];
    % filter out points that transitioned from 1 to 2 or 3
    trajids = unique(sps{1}(:,5));
elseif state == 2
    tpoints = sps{3};
    % filter out points that transitioned from 2 to 3
    trajids = unique(sps{2}(:,5));
end

for i = 1:numel(trajids)
    idx = tpoints(:,5)==trajids(i);
    if sum(idx) > 0
        tpoints(idx,:) = [];
    end
end

% CURRENTLY ONLY IMPLEMENTED FOR CLUSTERING STATE 1 AND 2
% dpoints are all potential domain points
dpoints = sps{state};

% set terminating states to -1, for later when counting consecutive
% terminating events
tpoints(:,4) = -1;

repeat = 1;
while repeat
    % number of clustered/identified domain groups
    disp(numel(unique(dpoints(:,6))) - 1)
    
    repeat = 0;
        
    for g=1:numel(trajids)
        trajid = trajids(g);

        gid = unique(dpoints(dpoints(:,5)==trajid, 6));

        % if there is more than 1 group id
        if numel(gid) > 1
            error('more than one group ID for a trajectory')
        % doesn't have a group, need to assign a new gid
        elseif unique(gid) == 0
            % separate into points in the trajectory vs rest of the points
            points = dpoints(dpoints(:,5)==trajid, :);
            rest = dpoints(dpoints(:,5)~=trajid, :);
            gid = max(dpoints(:,6)) + 1;
        % has a group
        else
            points = dpoints(dpoints(:,6)==gid, :);
            rest = dpoints(dpoints(:,6)~=gid, :);
        end
        
        % all points, which include terminating and growing
        % remake here since dpoints change as trajectories get added to
        % domains
        allp = [rest; tpoints];

        if size(points, 1) > 2            
            %% establish the boundary for the potential domain
            % make the boundary into a convex polygon
            k = convhull(points(:,1), points(:,2));
            x = points(k, 1);
            y = points(k, 2);
            [tx, ty] = expandboundary(x, y, points, locacc);
            
            %% check for terminating points within the boundary
            in = inpolygon(allp(:,1), allp(:,2), tx, ty);
            % sort by frame time stamp
            inp = sortrows(allp(in,:), 3);
            
            states = inp(:, 3:4);
            % find consecutive identical value counts for a binary vector
            d = [true, diff(states(:,2))' ~= 0, true];
            consec_counts = diff(find(d));
            consec_counts = repelem(consec_counts, consec_counts);
            
            % check terminating points to bound time clustering
            if sum(states(consec_counts >= min_term_points, 2) == -1) > 0
                % find frames where terminating events are above the
                % threshold
                termframe = states(consec_counts >= min_term_points, :);
                termframe = termframe(termframe(:, 2) == -1, 1);
                % find the range of the domain time
                dframes = [min(points(:, 3)), max(points(:,3))];
                % bound the time domain for further clustering
                % need to find the last frame before and first frame after the
                % current domain frames
                termframe = termframe - dframes;
                % upper bound
                upperframe = max(min(termframe(termframe > 0)) + dframes);
                % lower bound
                lowerframe = min(max(termframe(termframe < 0)) + dframes);
                
                if ~isempty(upperframe) && ~isempty(lowerframe)
                    inp = inp(inp(:, 3) > lowerframe & inp(:, 3) < upperframe, :);
                elseif ~isempty(lowerframe)
                    inp = inp(inp(:, 3) > lowerframe, :);
                elseif ~isempty(upperframe)
                    inp = inp(inp(:, 3) < upperframe, :);
                end
            end

            %% grow domain
            % look for same state points in the remaining inpoints
            
            if sum(inp(:, 4) ~= -1) >= min_grow_points
                states = inp(:, 3:4);
                % find consecutive identical value counts for a binary vector
                d = [true, diff(states(:,2))' ~= 0, true];
                consec_counts = diff(find(d));
                consec_counts = repelem(consec_counts, consec_counts);

                if sum(states(consec_counts >= min_grow_points, 2) ~= -1) > 0
                    repeat = 1;
                    % leave column 5 alone (keep original ids)
                    % only change column 6

                    % if it's a new group, give current points group id
                    if gid > max(dpoints(:, 6))
                        dpoints(dpoints(:,5)==trajid, 6) = gid;
                    end

                    % if the rest had group id
                    temp = inp(consec_counts >= min_term_points, :);
                    temp = temp(temp(:,4) ~= -1, :);
                    restgids = unique(temp(temp(:,6)>0, 6));
                    resttids = unique(temp(temp(:,6)==0, 5));
                    for i=1:numel(restgids)
                        dpoints(dpoints(:,6)==restgids(i), 6) = gid;
                    end

                    for i=1:numel(resttids)
                        dpoints(dpoints(:,5) == resttids(i), 6) = gid;
                    end

                end
            end
        end
    end
end

% finalize grouped trajectories into domains
gid = unique(dpoints(dpoints(:, 6)>0, 6));
domains = cell(1, numel(gid));
c = 1;
for i=1:numel(gid)
    trajids = unique(dpoints(dpoints(:,6)==gid(i), 5));
    domains{c} = trajids;
    
    for t=1:numel(trajids)
        spoints(spoints(:,5)==trajids(t), 6) = c;        
    end
    
    c = c + 1;
end

end

