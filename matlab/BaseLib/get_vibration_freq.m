function half_period = get_vibration_freq(folder,condition)
    % Input:    
    % This file takes the folder name of the folder where you store your
    % measurement data for the first argument.
    % The second argument is the condition ("without", "with6", "with8")
   
    % Output:
    % This file outputs a nx3 table of half period (ms) of vibration for each
    % data measurement

    %% check if input argument makes sense
    type_list = ["without", "with6", "with8"];
    if ~any(strcmp(type_list, condition))
        error("No such condition, check second argument");
    end
    
    path = "../../Measurement_Data/"+string(folder);
    if ~exist(path, 'dir')
        error("Folder does not exist")
    end
    
    %% load file
    file = dir(path+'/*.CSV');
    out = [];
    Ts = 0.001;
    
    for i = 1:size(file,1)
        % type(1): motion type
        % type(2): with or without wafer
        % type(3): x, y, z
        % type(4): baseline, optimal, aggressive
        type = split(file(i).name,[".","_"]);
        if ~(string(type(2)) == condition)
            continue
        end
        %% load data
        data = readtable(path+"/"+file(i).name,'VariableNamingRule','preserve');
        disp(file(i).name)
        % row 3 displacement
        % row 4 velocity
        % row 5 acceleration
        y = table2array(data(50:end-50,3));
        % row 2 in data is not strictly incremental, let us define our own time
        % vector
        t = 1:1:size(y,1);
   
    
        %% process data
        for j = 0:size(t,2)-1
            if y(end-j,1) ~= -1000
                continue 
            else
                break
            end
        end
        % j is the index in data where the laser sensor starts reading
        % meaningful data (end-j+1:end are the region data is meaningful)
        y = y(end-j+1:end,1);
        t = (t(1,end-j+1:end)-t(1,end-j+1))*Ts;
        
        %{
        if y(1,1)-y(3,1) <= 0
            % curve is going upward
            up = true;
        else
            % curve is going downward
            up = false;
        end
        %}
        j = 1;
        count = 0;
        while (count < 2)
            [minimum,maximum,index] = find_peak(y(j:j+10,1));
            if minimum || maximum && count == 0
                time1 = t(j+index-1);
                j = j+9;
                count = 1;
            elseif minimum || maximum && count == 1
                time2 = t(j+index-1);
                break
            end
            if j == size(y,1)-19
                error("Cannot find time2 for data " + string(file(i).name))
            end
            j = j+1;
        end
        %{
        % find peak and valley
        if up
            j = 3;
            while(count < 2)
                if y(j,1) >= y(j-2,1) && y(j,1) >= y(j+2,1) && count == 0
                    time1 = t(j);
                    count = count+1;
                    disp(y(j-2,1))
                    disp(y(j,1))
                    disp(y(j+2,1))
                elseif y(j,1) <= y(j-2,1) && y(j,1) <= y(j+2,1) && count == 1
                    time2 = t(j);
                    count = count+1;
                    %disp(y(j-2,1))
                    %disp(y(j,1))
                    %disp(y(j+2,1))
                end
                j = j+1;
            end
        else
            j = 2;
            while(count < 2)
                if y(j,1) <= y(j-2,1) && y(j,1) <= y(j+2,1) && count == 0
                    time1 = t(j);
                    count = count+1;
                elseif y(j,1) >= y(j-2,1) && y(j,1) >= y(j+2,1) && count == 1
                    time2 = t(j);
                    count = count+1;
                end
                j = j+1;
            end
        end
        %}
        out(end+1) = time2 - time1;
    end
    half_period = out;
end