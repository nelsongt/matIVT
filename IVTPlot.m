clear
format long


%%%%%%% Begin Main %%%%%%
Folder_Name = 'FGA015-Rad'
%% File read code  % TODO: Clean up by moving to own function
F_dir = strcat(Folder_Name, '\*_*.dat');
F = dir(F_dir);
for ii = 1:length(F)
    fileID = fopen(strcat(Folder_Name,'\',F(ii).name));

    Header = textscan(fileID,'%s',12,'Delimiter','\n');

    for jj = 1:length(Header{1,1})  % Pull out the sample temp and sampling rate
        if contains(Header{1,1}{jj,1},'temperature=')
            temp_string = strsplit(Header{1,1}{jj,1},'=');
            temperature = str2double(temp_string{1,2});
        end
    end

    Temps(ii) = temperature;
    Data{:,ii} = cell2mat(textscan(fileID,'%f64 %f64 %f64'));

    total = ii;  % TODO; not needed, can use length(Data)
    fclose(fileID);
end

Data = sortBlikeA(Temps,Data);
Temps = sort(Temps);

%% Plotting
color = jet(length(Data));

% IVT plot
figure
for i = 1:length(Data)
    semilogy(Data{1,i}(:,1),abs(Data{1,i}(:,3)),'Color',color(i,:));
    hold on;
end
colormap(color);
h = colorbar;
caxis([Temps(1) Temps(length(Temps))]);
ylabel(h, 'Temperature (K)');
xlabel('Voltage (V)','fontsize',14);
ylabel('Current Density (mA/cm^2)','fontsize',14);
hold off;

% E_activation plot
target_bias = -0.05; % volts
kb = 8.617*10^-5; % Boltzmann
inv_kbT = 1./(kb.*Temps);
figure
for i = 1:length(Data)
    for j = 1:length(Data{1,i})
        if Data{1,i}(j,1) == target_bias
            Jplus = abs(Data{1,i}(j+1,3));
            Jsame = abs(Data{1,i}(j,3));
            Jminus = abs(Data{1,i}(j-1,3));
            J(i) = mean([Jplus Jsame Jminus]);
        end
    end
end
y = J .* (inv_kbT.^2);
scatter(inv_kbT,log(y));
xlabel('(k_BT)^{-1}','fontsize',14);
ylabel('Log[J/(k_BT)^{-2}]','fontsize',14);
hold off;



function C = sortBlikeA(A,B)
    [~,Asort]=sort(A); %Get the order of B
    C=B(Asort);
end