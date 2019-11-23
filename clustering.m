clear;clc

startpath = pwd;

cd('/mnt/data0/yerim/vbSPT1.1.4_20170411/traj_connection_carey/ss_rkd/12_ms/high_density/9.13.2018')
runinput = 'trajs_max_500_nm_dox_10_ss_rkd_3_runinput';
dirpath = pwd;
state = 2;

load(strrep(runinput,'_runinput','.mat'),'finalTraj')

cd /home/yerim/data/code
% grab state coordinates
[ ~, ~, ~, spaths, ~, ~, ~, ~, ~ ] = get_vbSPT_results( dirpath, runinput, 0 );

cd(startpath)
% 1: x, 2: y, 3: frame, 4: state, 5: traj id
epoints = keependpoints(spaths, finalTraj);
% mpoints = midpointstates( spaths, finalTraj );

% % 1: x, 2: y, 3: frame, 4: state, 5: traj id, 6: group id
epoints = [epoints, zeros(size(epoints,1), state)];

% shorter time frame (KRas movies have max 50,000 frames)
epoints = epoints(epoints(:,3)<50000,:);

%% cluster based on length
% 1. cluster points (s2 have positive group ids)
% 2. identify s3 that are found in s2 clusters
% 3. determine if any of the s2 points are boundaries

disp('clustering based on consecutive time in state 2 domain')

% cluster based on length first
trajlen = cellfun(@(x) size(x,1), finalTraj);
epoints = clusterlength(epoints, trajlen, state);
max(epoints(:,6))

%% cluster based on overlapping trajectories
disp('clustering overlapping trajectories')

cd(startpath)
% cluster overlapping trajectories (expanded boundary by 20 nm)
% minimum points found inside the domain boundary to terminate domains
min_term_points = 2;
% minimum points found inside the domain to grow domains
min_grow_points = 1;
[groupedtrajs, epoints] = clustertrajs(epoints, 20, state, min_term_points, min_grow_points);

% determine the boundary, edges, trajectories involved, lifetime and area
domains = domainboundaries(groupedtrajs, epoints, state);

% find repeated domain appearances in the same region and state 3
% terminations
[domains, overlaps] = overlapdomains(domains, epoints, 20, state);

cd /home/yerim/data/xubo_clustering/
save('clustered_endpoints_s1.mat')

 %% plot circles
% % draw circles (just for visual inspection)
% ang=0:0.01:2*pi;
% for i=1:max(s2(:,4))
%     c = rand(1,3);
%     points = s2(s2(:,4)==i, :);
% 
%     scatter(points(:,1), points(:,2), [], c, '.')
%     hold on
%     center = mean(points(:,1:2));
%     radius = max(pdist2(center, points(:, 1:2)));
%     xp = radius*cos(ang);
%     yp = radius*sin(ang);
%     plot(center(1) + xp, center(2) + yp,'LineWidth',2,'color', c)
% end

%% plot fast state points
% ang=0:0.01:2*pi;
% for i=1:max(s3(:,4))
%     c = rand(1,3);
%     points = s3(s3(:,4)==i, :);
%     % remove single points
%     if size(points,1)==1
%         s3(s3(:,4)==i,:) = -1;
%     else
%         scatter(points(:,1), points(:,2), [], c, '.')
%         hold on
%         center = mean(points(:,1:2));
%         radius = max(pdist2(center, points(:, 1:2)));
%         xp = radius*cos(ang);
%         yp = radius*sin(ang);
%         plot(center(1) + xp, center(2) + yp,'LineWidth',2,'color', c)
%     end
% end