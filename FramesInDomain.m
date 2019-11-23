function [ domains ] = FramesInDomain( domains, state )
% count number of frames spent in domain
% domains = struct( boundaries, edges, dpoints, dids, lifetime, tpoints,
% tids, area)
% state = int (either state 1 correponding to the immobile domain or state
% 2 corresponding to the intermediate domain)

% for each domain, and each trajectory, return (# of frames spent inside of
% the domain, and the first frame the trajectory was found in domain)
% framecounts = (# frames in domain, first frame in domain)
for i=1:numel(domains)
    % 1: x, 2: y, 3: frame, 4: state, 5: traj id, 6: domain id
    trajinfo = domains(i).dpoints;
    trajids = unique(trajinfo(:,5));
    
    framecounts = zeros(numel(trajids), 2);
    for j=1:numel(trajids)
        currtraj = trajinfo(trajinfo(:,5)==trajids(j), :);
        framesindomain = currtraj(currtraj(:,4)==state, :);
        framecounts(j,1) = size(framesindomain, 1);
        framecounts(j,2) = min(framesindomain(:, 3));
    end
    
    domains(i).frameduration = framecounts(:,1);
    domains(i).frameinterval = diff(sort(framecounts(:,2)));
end

end

