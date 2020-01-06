%%%% MATLAB I-V-T %%%%  Author:  George Nelson 2019

% Set Sample Parameters
sample_name = '17R512-2 C8S14';
sample_size = 0.0025;  % Sample area in cm2
sample_comment = 'Mystery Rad 1';
save_folder = strcat(sample_name,'_',datestr(now,'mm-dd-yyyy-HH-MM-SS'));  % folder data will be saved to, uses timecode so no overwriting happens

% Set IVT experiment parameters
v_start = -1;           % V, start voltage
v_end = 1;              % V, end voltage
v_step = 0.01;          % V, voltage step
temp_init = 190.0;      % K, Initial temperature
temp_step = 10;         % K, Measure at each temp step
temp_final = 70;        % K, Ending temperature
temp_idle = 200.0;      % K, Temp to set after experiment is over
temp_stability = 0.2;   % K, Sets how close to the setpoint the temperature must be before collecting data (set point +- stability)
time_stability = 20;    % s, How long must temperature be within temp_stability before collecting data, tests if PID settings overshoot set point, also useful if actual sample temp lags sensor temp

%% MAIN %%

% Init %
% Setup PATH
cd('.')
addpath(genpath('.\keithley\Common'))
addpath(genpath('.\keithley\CommonDevice\Keithley'))
addpath(genpath('.\lakeshore'))

% Check for lakeshore 331
if LAKESHORE_INIT()==0
    return;
end

% Create Keithley2400 object with specified connection type and port
k = classKeithley2400('connectionType','gpib','port',15);
k.reset();   % reset device to initial state
k.connect(); % connect to device (0 if OK, else if error)
pause(1);
% get conenction status (1 if OK) and ID of device
[connectionStatus, ID] = k.getConnectionStatus()
pause(1);
% set sweep measurement setSweepV(startVoltage,stopVoltage,stepSize,delay,integrationRate (optional),complianceLevel (optional, Amps),spacing (parameter))
k.setSweepV(v_start,v_end,v_step,0,10,0.0005);

current_temp = temp_init;
current_num = 0;
save_file = [];
current_density = [];
steps = ceil(abs(temp_init - temp_final)/temp_step);
while current_num <= steps
    cprintf('blue', 'Waiting for set point (%3.2f)...\n',current_temp);
    SET_TEMP(current_temp,temp_stability,time_stability); % Wait for lakeshore to reach set temp;
    
    cprintf('blue', 'Measuring J-V...\n');
    temp_before = sampleSpaceTemperature;

    % measure sweep measureSweepV()
    f.Sweep = figure('Position',[200,200,400,300]);
    ax.Sweep = axes('parent',f.Sweep);
    dataSweepV = k.measureSweepV('plotHandle',ax.Sweep)
    k.setOutputState()

    temp_after = sampleSpaceTemperature;
    cprintf('green', 'Finished measurement for this temperature.\n');
    avg_temp = (temp_before + temp_after) / 2;
        
    cprintf('blue', 'Saving Data...\n');
    save_file = strcat(sample_name,'_',num2str(current_num),'_',num2str(current_temp),'.dat');
    current_density = dataSweepV.current.*(1000/sample_size);
    IVT_FILE(save_folder,save_file,dataSweepV.voltage,dataSweepV.current,current_density,avg_temp,sample_comment,sample_name,sample_size);

    if temp_init > temp_final
        current_temp = current_temp - temp_step;    % Changes +/- for up vs down scan
    elseif temp_init < temp_final
        current_temp = current_temp + temp_step;
    end
    current_num = current_num + 1;
end

cprintf('blue', 'Finished data collection, returning to idle temp.\n');
SET_TEMP(temp_idle,temp_stability,time_stability); % Wait for lakeshore to reach set temp;
cprintf('green', 'All done.\n');

k.disconnect()
%% END MAIN %%




