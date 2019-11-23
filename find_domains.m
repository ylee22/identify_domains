function failedruninput = find_domains( dirpath, runinput, locacc, state, ...
    maxframe, min_term_points, min_grow_points, outputdir )
% find domains by clustering and then merging
% clusters trajectories based on 2 methods: length
% save results somewhere

cd(dirpath)
load(strrep(runinput,'_runinput.m','.mat'), 'finalTraj', 'cell_area')

cd /home/yerim/data/code
% grab state coordinates, est2 field only calculated for the best model
[ ~, ~, ~, spaths, ~, ~, ~, ~, ~ ] = get_vbSPT_results( dirpath, runinput, 0 );

if isempty(spaths) || max(vertcat(spaths{:}))~=3
    failedruninput = strjoin({dirpath, runinput}, '/');
    return
end

% 35 MS KRAS MOVIES END AT 50,000 FRAMES
if ~isempty(maxframe)
    idx=cellfun(@(x) max(x(:,3))<maxframe, finalTraj);
    finalTraj=finalTraj(idx);
end

cd /mnt/data0/yerim/xubo_clustering/code
% 1: x, 2: y, 3: frame, 4: state, 5: traj id
epoints = keependpoints(spaths, finalTraj);

% 1: x, 2: y, 3: frame, 4: state, 5: traj id, 6: group id
epoints = [epoints, zeros(size(epoints,1), 1)];

%% cluster based on length
% 1. cluster points (s1/s2 have positive group ids)
% 2. identify terminating points that are found in clusters
% 3. determine if any of the s1/s2 points are boundaries

disp(strcat('clustering based on time in state', {' '}, int2str(state),' domain'))

% identify domains based on length first
% trajlen = cellfun(@(x) size(x,1), finalTraj);
% assume that if a trajectory has minimum of 3 points in the specified
% state, then it's real (3 or more points are needed to make a polygon)
minlen = 2; % > minlen
epoints = clusterlength(epoints, minlen, state);
disp(max(epoints(:,6)))

%% cluster based on overlapping trajectories
disp('clustering overlapping trajectories')
% cluster overlapping trajectories (expanded boundary by 20 nm)
[groupedtrajs, epoints] = clustertrajs(epoints, locacc, state, min_term_points, min_grow_points);

%% defining the domain using the identified domain trajs from above
disp('defining the domains')

% determine the boundary, edges, trajectories involved, lifetime and area
domains = domainboundaries(groupedtrajs, epoints, state);

%% save results

cd(dirpath)
newpath = strsplit(dirpath, '/');
newpath = strjoin({newpath{1:end-1}, 'domain_analysis', outputdir, strcat('state_', int2str(state)), newpath{end}},'/');
if ~exist(newpath, 'dir')
    mkdir(newpath)
end
cd(newpath)

failedruninput = '';

save(strcat('domains_',strrep(runinput,'_runinput.m','.mat')), 'domains', 'epoints', 'groupedtrajs', 'finalTraj', 'cell_area', 'runinput', 'dirpath')
end

