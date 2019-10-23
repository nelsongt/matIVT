function IVT_FILE(saveFolder,filename,volts,amps,density,temperature,comment,sampleName,size)
%TransientFile Saves transient data to LDLTS compatible iso file
%   Detailed explanation goes here

status = mkdir(strcat(pwd,'\',saveFolder));
fid = fopen(fullfile(strcat(pwd,'\',saveFolder),filename),'wt');
fprintf(fid, '[general]\n');
fprintf(fid, 'software=matIVT version 9.1.19\n');
fprintf(fid, 'user=George\n');
fprintf(fid, 'date=%s\n', datetime);
fprintf(fid, 'comment=%s\n', comment);
fprintf(fid, '[sample]\n');
fprintf(fid, 'Identifier=%s\n', sampleName);
fprintf(fid, 'area(cm2)=%f\n', size);
fprintf(fid, '[acquisition]\n');
fprintf(fid, 'temperature= %f\n', temperature);
fprintf(fid, '[data]\n');
fprintf(fid, 'Voltage (V)\tCurrent (A)\tCurrent Density (mA/cm2)\n');
for i=1:length(volts)
    fprintf(fid, '%e\t%e\t%e\n', volts(i),amps(i),density(i)');
end
fclose(fid);
end

