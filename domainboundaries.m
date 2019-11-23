function [ domains ] = domainboundaries( gtrajs, spoints, state )
% determine if there are multiple domains in the same area
% boundaries
% dpoints: points that define the domain
% spoints: % 1: x, 2: y, 3: frame, 4: state, 5: traj id

% extract boundaries for each domain
domains(numel(gtrajs)) = struct('boundaries',[],'edges',[],'dpoints',[], ...
    'dids',[],'lifetime',[]);
for d = 1:numel(gtrajs)
    domain = gtrajs{d};
    allp = [];
    edges = [];
    dpoints = [];
    for t = 1:numel(domain)
        traj = domain(t);
        points = spoints(spoints(:,5)==traj, :);
        allp = [allp; points];
        % some trajectories transition
        dpoints = [dpoints; points(points(:,4)==state, :)];
        % edge points are included in both 2 and 3
        % they have the same x, y, frame #, traj #
        % store known edges if they exist
        [~ ,ip, ~] = unique(points(:,1:3),'rows');
        idup = setdiff(1:size(points,1), ip);
        % for each transition
        for f = 1:numel(idup)
            dframes = points(idup(f), 3);
            % find which state it transitioned from
            states = points(points(:,3)==dframes, 4);
            edges = [edges; points(idup(f), 1:3), sum(states) - state, points(idup(f), 5:end)];
        end

    end
    
    k = boundary(dpoints(:,1), dpoints(:,2));
    bpoints = dpoints(k, 1:2);
    
    domains(d).boundaries = bpoints;
    domains(d).dpoints = allp;
    domains(d).dids = unique(dpoints(:,5));
    domains(d).lifetime = max(dpoints(:,3))-min(dpoints(:,3));
    domains(d).area = polyarea(bpoints(:,1), bpoints(:,2));
    if ~isempty(edges)
        domains(d).edges = edges;
    end

end

end

