%function to find events in the data
function result = getEvents(data, contourSize, zeroPercentage)
    temp = [];
    %get events by finding first and second gradient of the data
    %this is done to find peaks and lows of the data and event is happening
    %before the peak, for which contourSize is used to find where that
    %event might be
    gradientI = gradient(data);
    gradientII = gradient(gradientI);
    
    %find the peak values and locations in the data with minimum peak distance of 600 elements
    [peaks, locs] = findpeaks(gradientI, 'MinPeakDistance', 600); 
    locsTransposed = locs.'; %transpose from column matrix to row matrix

    
    for loc = locsTransposed
        %find second gradient in the event contour to see the speed of
        %change in the data
        if (loc < contourSize)
            eventContour = gradientII(1 : loc);
        else 
            eventContour = gradientII(loc-contourSize : loc);
        end
        
        %zero counter is used for the second gradient so that we find how much the first gradient is changing, and if it does not change in the contour, the timestamp is saved 
        zeroCount = sum(abs(eventContour(:)) < 0.0002); 
        if (contourSize/zeroCount) > zeroPercentage
            temp = [temp,[loc-contourSize,loc]];
        end
    end
    
    %event filter is called to remove events which are on the rising part
    %of the peak (because the stress was caused by the event prior to that one)
    result = eventFilter(data, temp);
    
    
    