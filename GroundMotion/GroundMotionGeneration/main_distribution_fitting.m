clear;
clc;
close all;

dir = 'Z';
file_name = ['Statistic_info_type1_',dir,'.mat'];
path = load(file_name);
data = path.statictic_info_type1;
search_dir = 'C:\Users\v196m\Desktop\master_project\Ground Motion Model\All_signals\';

%% Import the data of depth
Depth_path = 'C:\Users\v196m\Desktop\master_project\Ground Motion Model\All_signals\Event_list_Insheim2.txt';
% Read the text file into a table
T = readtable(Depth_path);

for j = 1:length(T.Var1)
    % Convert the string to a datetime object
    dt = datetime(T.Var1(j), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    % Convert the datetime object to a formatted string
    T.Var7(j) = "GM_"+ sprintf('%d_%02d_%02d_%02d_%02d_%02d', ...
        year(dt), month(dt), day(dt), hour(dt), minute(dt), second(dt));
end


Record_info = data(:,1);
Spectral_info = data(:,2);
Time_info = data(:,3);
GM_info =   data(:,4);

%% Making Info Matrix
% MAT = ( M, D, R, S0, W_g, Damp_g, W_f_ratio, Duration, T_mid_ratio)
Info_matrix = zeros(length(Record_info),10);
Info_array = [];
for i = 1:length(Record_info)
    Record_info = data(:,1);
    Record_info_i = Record_info{i};
    
    % Use fileparts to extract the folder parts
    [path_record, ~, ~] = fileparts(Record_info_i{1});
    % Extract the directory names
    [~, current_dir, ~] = fileparts(path_record);
    [~, parent_dir, ~] = fileparts(fileparts(path_record)); 
    index = find(strcmp(T.Var7, parent_dir));

    if ~isempty(index)
        D = T.Var4(index);
    else
        dips("ERROR! no depth found")
    end

    R = Record_info_i{2};
    M = Record_info_i{3};
    
    PGA         = GM_info{i}(1);
    W_g         = Spectral_info{i}(1)/(2*pi);
    Damp_g      = Spectral_info{i}(2);
    W_f_ratio   = Spectral_info{i}(3);
    Duration    = Time_info{i}(4);
    T_mid_ratio = Time_info{i}(3);

    Info_matrix(i,1) = M;
    Info_matrix(i,2) = D;
    Info_matrix(i,3) = R;
    Info_matrix(i,4) = PGA;
    Info_matrix(i,5) = W_g;
    Info_matrix(i,6) = Damp_g;
    Info_matrix(i,7) = W_f_ratio;
    Info_matrix(i,8) = Duration;
    Info_matrix(i,9) = T_mid_ratio;
    Info_matrix(i,10) = index;

    Info_array = [Info_array; {parent_dir},{current_dir}, ...
         M,D,R,PGA,W_g,Damp_g,W_f_ratio,Duration,T_mid_ratio];
end

%% Fitting distribution
distance =  sqrt(power(Info_matrix(:,2),2)+ power(Info_matrix(:,3),2));
data = (Info_matrix(:,6));
%data =  log(distance(:,1))

% Fit the data with gamma, beta, and lognormal distributions
gamma_dist = fitdist(data, 'gamma');
lognormal_dist = fitdist(data, 'lognormal');
gaussian_dist = fitdist(data, 'normal');
%beta_dist = fitdist(data, 'beta');

% Perform Kolmogorov-Smirnov goodness-of-fit tests
%[~, p_beta] = kstest(data, 'CDF', beta_dist);
[~, p_gamma] = kstest(data, 'CDF', gamma_dist);
[~, p_lognormal] = kstest(data, 'CDF', lognormal_dist);% Fit the data with uniform and Gaussian distributions

% Perform Kolmogorov-Smirnov goodness-of-fit tests
%[~, p_uniform] = kstest(data, 'CDF', uniform_dist);
[~, p_gaussian] = kstest(data, 'CDF', gaussian_dist);


% Display p-values
disp(['Gamma p-value: ', num2str(p_gamma)]);
disp(['Lognormal p-value: ', num2str(p_lognormal)]);
%disp(['Beta p-value: ', num2str(p_beta)]);
disp(['Gaussian p-value: ', num2str(p_gaussian)]);

%% Plot the histogram
h = histogram(data, 'Normalization', 'probability', 'DisplayName', 'Data');


hold on;
%gaussian_dist.mu = -8.25;
%gaussian_dist.sigma = 1.4;
% Plot the fitted curves
x_values = linspace(min(data), max(data), 100);
plot(x_values, max(h.Values)*pdf(gamma_dist, x_values)/max(pdf(gamma_dist, x_values)), 'LineWidth', 2, 'DisplayName',  ['Scaled Gamma: ',num2str(gamma_dist.a),', ',num2str(gamma_dist.b)]);
%plot(x_values, max(h.Values)*pdf(lognormal_dist, x_values)/max(pdf(lognormal_dist, x_values)), 'LineWidth', 2, 'DisplayName', ['Scaled Lognormal: ',num2str(lognormal_dist.mu),', ',num2str(lognormal_dist.sigma)]);
%plot(x_values, max(h.Values)*pdf(gaussian_dist, x_values)/max(pdf(gaussian_dist, x_values)), 'LineWidth', 2, 'DisplayName', ['Scaled Gaussian: ',num2str(gaussian_dist.mu),', ',num2str(gaussian_dist.sigma)]);

% Add labels and legend
xlabel('Value');
ylabel('Probability Density');
title('Histogram and Fitted Curves');
legend('show');

% Hold off to end the plot
hold off;



