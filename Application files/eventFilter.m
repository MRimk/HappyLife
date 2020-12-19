%event filter is used to remove events which are on the rising part of
%stress level and the stress has already been caused by the other event
function res = eventFilter(data, eventT)
 res = [];
 
 eventValuesMatrix = [];
 eventT = eventT(2:length(eventT)); %event timestamps are used from the second element because the first is always negative because of the contour size going back behind the start of recording
 for t = eventT
     eventValuesMatrix = [eventValuesMatrix, [data(t)]]; %find values where events happened
 end
 
 
 %take the gradient of the event values
 gradient1 = gradient(eventValuesMatrix);

 index = 1;
 for eventSlope = gradient1
    %if events are on the same level or lower than one another, save them,
    %and if they are on the rise, skip them
    if eventSlope <= 0
        res = [res, [eventT(index)]];
    end
    index = index + 1;
 end
 


    