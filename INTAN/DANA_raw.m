%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LFP_files = find_files('amp-D*.dat');

count = 1;
LFP_t_sec = INTAN_Load_Time('time.dat');
sFreq = 1/median(diff(LFP_t_sec));

Wo = 60/(sFreq/2);  BW = Wo/35;
f_notch = 60;
[a,b] = INTAN_notch_filter(sFreq, f_notch);

LFP_t_usec = LFP_t_sec*1e6;
nTimeStamps = length(LFP_t_usec);
samples_before = round(sFreq)*1; % multiply by the seconds you want to show
samples_after = round(sFreq)*1;

for iLFP = 1:length( LFP_files)
    % Load the LFP data.
    fid = fopen(LFP_files{iLFP}, 'r');
    lfp = fread(fid, inf, 'int16');
    fclose(fid);
end

new_sFreq = 1000; % the desired sampling frequency of the LFP.
lowlimit_fq  = 1; % ripple band pass. The traditional values - not necessarily the best.
highlimit_fq = 100;  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filter for ripples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F_Ny = new_sFreq/2;    % Hz. Use the output because data sampled at the output
% sfreq is what goes into filtfilt.
N = 4;                 % Order of the filter
passband = [lowlimit_fq/F_Ny highlimit_fq/F_Ny];
ripple = .5;
[B,A] = cheby1(N, ripple, passband);
LFPtheta = filtfilt(B,A,lfp);

% plot(LFP_t_usec,LFPtheta)

figure
plot(lfp)

figure
pmtm_range = (1:600);
pxx = pmtm((lfp),[],pmtm_range,1000);
plot(pmtm_range,pxx);


%%To save and send txt to Hein lab members:
% save('C:\Users\Cowen.Stephen\Desktop\DANA noise test\Noise_test.txt','lfp','-ascii')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
