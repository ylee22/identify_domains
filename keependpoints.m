function [ endpoints ] = keependpoints( spaths, finalTraj )
% keep the end points
% 1: x, 2: y, 3: frame, 4: state, 5: traj id

endpoints = [];
for trajid = 1:numel(finalTraj)
    currtraj = finalTraj{trajid};
    states = unique(spaths{trajid});
    currp = [];
    for s = 1:numel(states)
        % find the state indices
        idx = find(spaths{trajid}==states(s));
        % include the end point
        idx = unique([idx, idx+1]);
        currp = [currp; currtraj(idx,:), ones(numel(idx),1)*double(states(s)), ones(numel(idx),1)*trajid];
    end
    endpoints = [endpoints; currp];
end

end

