function M = initializeEvents(M)

M.fgfr3 = initializeDosingSchedule(M.fgfr3,M.setup.start_day_of_week,M.setup.censor_time);
M.checkpoint = initializeDosingSchedule(M.checkpoint,M.setup.start_day_of_week,M.setup.censor_time);


M.events.times = [M.fgfr3.times;M.checkpoint.times;M.setup.censor_time];
M.events.event_index = [2*ones(length(M.fgfr3.times),1);1*ones(length(M.checkpoint.times),1);Inf];

[M.events.times,order] = sort(M.events.times,1,"ascend");
M.events.event_index = M.events.event_index(order);

M.events.n = length(M.events.times);