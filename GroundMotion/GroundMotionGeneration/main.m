clear;
clc;
close all;
rng(2);
addpath("BaselineCorrection\")
%path = 'C:\Users\v196m\Desktop\master_project\Masterarbeit\GroundMotion\RecordData\GM_2016_02_12_06_26_04\GM_TMO57_2016_02_12_06_26_04\a_2_TMO57_2016_02_12_06_26_04.txt';
%path = load('events.mat');
%all_path = path.file_list;
%data_t = fns_import_time_data(path,'txt',[1,25]);

path = load('MAT_FILES\Statistic_info_type2_X.mat');
all_path = path.statictic_info_type2;
data_t = fns_import_time_data(all_path{11},'txt',[0,50]);

GMG = cls_GM_generator(data_t, 100);
%time = GMG.getPercentileInfo(true);
%q = GMG.generateTimeModFunc(time,[],[],1,true);
[GM,FRF_info,Time_info,GM_info] = GMG.generateTimeNonStaPesudoGMbyFit("Hu_S0",[200,0.01,0.5,GMG.PGA],[],true,true);



%b = fns_fft_data(data_t,100,false,true);
%[c,f] = periodogram(data_t.ampl,[],b.Freq,200);
%
%psd = (1/(200*length(data_t.ampl))) *power(b.Ampl,2);
%figure
%plot(f,c)
%hold on 
%plot(b.Freq, psd,'--')
%rng(2);


%GMG = cls_GM_generator(a, 100);


%GMG.HuKTmodel(50,0.5,0.211,2);
%c = GMG.fit_HuKTmodel_S0([100,0.1,1,GMG.PGA],true);
%GMG.fit_GM_model("Hu_S0",[100,0.01,0.5,GMG.PGA],true);
%GMG.fit_HuKTmodel_S0([200,0.1,1],true)
%GMG.GMmodel("KT_S0",filter_params,[],true);
%GMG.generateWhiteNoise(true);
%g = GMG.generateNormStaPesudoGM("CP_S0",[200,0.01,50,0.01,GMG.PGA],[],'time',true,true);
%time = GMG.Time;
%ampl = GMG.PGA*g.ampl;
%ampl(1) = 0 ;
%PesuedoGM = table(time,ampl);

%time_percentiles = GMG.getPercentileInfo(true);
%q=GMG.generateTimeModFunc(time_percentiles,[],[],1,true);




%fns_fft_data(PesuedoGM,100,false,true);
%fns_fft_data(a,100,false,true);
%

%[time_,acc,vel,disp_] = fns_generateGM_Params(2,[],100,"Hu_S0",...
%                          FRF_info,...
%                          Time_info,...
%                          GMG.AriasIntensity);
%
%
%
%[vel, disp] = newmarkIntegrate(time, ampl, 0.5, 0.25);
%[nomDR, nomAR] = computeDriftRatio(time, disp, 'ReferenceAccel', ampl);
%[accel_A3, vel_A3, disp_A3] = baselineCorrection(time, ampl, 'AccelFitOrder', 3);
%[A3DR, A3AR] = computeDriftRatio(time, disp_A3, 'ReferenceAccel', ampl);
%GM = table(time,ampl);
%fns_fft_data(GM,100,false,true)
%vel_ = cumtrapz(time,acc);
%dis = cumtrapz(time,vel_);
%%
%%
%figure;
%plot(time_,acc);
%hold on 
%plot(time,disp_A3,'--');

%[T_o,Spa_o,Spv_o,Sd_o] = fns_response_spectra(data_t.time(3)-data_t.time(2),data_t.ampl,5,9.81,10);
%[T_p,Spa_p,Spv_p,Sd_p] = fns_response_spectra(data_t.time(3)-data_t.time(2),acc,5,9.81,10);

%% Plot Spectra
%figure;
%subplot(2,1,1)
%%figure('Name','Spectral Displacement','NumberTitle','off')
%semilogx(T_o,Sd_o,'LineWidth',2.)
%hold on 
%semilogx(T_p,Sd_p,'LineWidth',2.)
%grid on
%xlabel('Period (sec)','FontSize',13);
%ylabel('Sd (mm)','FontSize',13);
%title('Displacement Spectrum','FontSize',13)
%legend('Recorded','Simulated');
%
%subplot(2,1,2)
%%figure('Name','Pseudo Acceleration Spectrum','NumberTitle','off')
%semilogx(T_o,Spa_o,'LineWidth',2.)
%hold on 
%semilogx(T_p,Spa_p,'LineWidth',2.)
%grid on
%xlabel('Period (sec)','FontSize',13);
%ylabel('Spa (g)','FontSize',13);
%title('Pseudo Acceleration Spectrum','FontSize',13);
%legend('Recorded','Simulated');
