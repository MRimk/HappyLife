function identifier(fileName)
%finding file name from full path of the file
temp = strsplit(fileName, '\');

%getting recording start time from file name so that plot could show exact time of the events
temp = char(temp(length(temp)));
hours = temp(10:11);
h = str2num(hours);
minutes = temp(12:13);
min = str2num(minutes);
seconds = temp(14:15);
sec = str2num(seconds);

%open csv file 
data = csvread(fileName);

%sampling frequency is 4Hz because biometric signals are best read from
%0.25Hz to 10Hz and we are reading long periods of data
samplingFrequency = 4;


%preprocessing

%moving median filter to remove noise from the data
data = movmedian(data, 501);
%aggregation filter to remove unnecessary peaks and lows in the data
aggregationFilter = ones(1, 100);
data = conv(data, aggregationFilter, 'valid'); 

%time axis
t = (((0:length(data)-1)/samplingFrequency + sec)/60 + min)/60 + h;

%find events' timestamps in the data
events = getEvents(data, 160, 0.99);

%plotting
plot(t,data);
title("Neural system's activity");
xlabel("Time in hours"); 
ylabel("Neural system's activity in percentages");
hold on;

%event marking on the plot
for event = events
    if event == events(1) %if it is the first event save the lastEvent and plot it
        lastEvent = event;
        eventInHours = ((event/samplingFrequency + sec)/60 + min)/60 + h;
        plot(eventInHours, data(event), 'o','MarkerSize',20);
    end
    %plot the event only if the time between 2 close events is more than 1
    %minute (because it does not output for a user if it has 1 minute error)
    if event - lastEvent >= 60*4
        eventInHours = ((event/samplingFrequency + sec)/60 + min)/60 + h;
        plot(eventInHours, data(event), 'o','MarkerSize',20);
    end
    lastEvent = event;
    hold on;
end

legend('circles mean events','Location','southwest');
hold off;

    