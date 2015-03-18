function [bout_times,bout_durations] = Bouts(Location,ROI,times,start_idx)

L_location = bwlabel(Location==ROI);

bout_times = zeros(max(L_location),1);
bout_durations = zeros(max(L_location),1);


for i=1:max(L_location)
    i1 = find(L_location==i,1,'first');
    i2 = find(L_location==i,1,'last');
    bout_times(i) = times(i1)-times(start_idx);
    bout_durations(i) = times(i2)-times(i1);
end
