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


% Case 145 has too extreme value for Beta
% Case 36 has too extreme value for W_c

%% Fitting Scenario: Wc
% Fitting 
distance =  sqrt(power(Info_matrix(:,2),2)+ power(Info_matrix(:,3),2));

%VarsTable= table(Info_matrix(:,10), Info_matrix(:,1), log(distance), distance, Info_matrix(:,2),Info_matrix(:,3),log(Info_matrix(:,4)),...
%            Info_matrix(:,5),log(Info_matrix(:,6)),log(Info_matrix(:,7)),...
%    'VariableNames',{'Event','M','LnDis','Dis','D','R','lnPGA','Wg','DRg','Wc'});
%VarsTable(36,:) = [];

VarsTable= table(Info_matrix(:,10), Info_matrix(:,1),...
                 log(distance), distance, ...
                 log(Info_matrix(:,2)),Info_matrix(:,2),...
                 log(Info_matrix(:,3)),Info_matrix(:,3),...
                 log(Info_matrix(:,4)),...
                 (Info_matrix(:,5)),...
                 (Info_matrix(:,6)),...
                 (Info_matrix(:,7)),...
    'VariableNames',{'Event','M','LnDis','Dis','LnD','D','LnR','R','lnPGA','Wg','DRg','Wc'});

% Remove Outlier
VarsTable(200,:) = [];
VarsTable(153,:) = [];
VarsTable(107,:) = [];
VarsTable(105,:) = [];


LME_lnPGA = fitlme(VarsTable,'lnPGA ~  M + LnD + LnR  + Wg + (LnR|Event) +  ( Wg|Event)');
LME_lnWc = fitlme(VarsTable, 'Wc     ~ R +  Wg + ( R|Event)+  ( Wg|Event)');
% Beta should be fixed 
LME_lnBeta = fitlme(VarsTable,'DRg  ~  R +  Wg + ( R|Event)+  ( Wg|Event)');

%% Residuals and correaltion 
% Concatenate the residuals into a single matrix
all_residuals = [LME_lnPGA.residuals, LME_lnWc.residuals, LME_lnBeta.residuals];

% Compute the correlation matrix
correlation_matrix = corrcoef(all_residuals);
% Compute the covariance matrix
covariance_matrix = cov(all_residuals);
% Compute the Cholesky decomposition of the covariance matrix
chol_matrix = chol(covariance_matrix, 'lower');
% correalated error
mu = [0,0,0];
%R = mvnrnd(mu,covariance_matrix ,1000);

%% Plot and displace
%Plot the correlation matrix
figure;
corrplot(all_residuals)

% Display the correlation matrix
disp('Correlation Matrix of Residuals:');
disp(correlation_matrix);

% Display the covariance matrix
disp('Covariance Matrix of Residuals:');
disp(covariance_matrix);

% Display the Cholesky matrix
disp('Cholesky Decomposition of the Covariance Matrix:');
disp(chol_matrix);



%fns_plotResidual_events(LME_lnBeta)
%fns_visualized_fitting(LME_lnPGA, VarsTable, VarsTable.lnPGA, [0.5, 1, 1.5, 1.2, 0.5], [7.0, 9.5, 12.0, 8.0, 10])



%% Fitting Insheim Model
DOE_path = "C:\Users\v196m\Desktop\master_project\Masterarbeit\StochasticPCE\InputData\X_SBAGM_VAL_1000.mat";
a = load(DOE_path);

Valid_point_1 = a.X(200,:).*ones(1000,1);
Valid_point_2 = a.X(400,:).*ones(1000,1);
Valid_point_3 = a.X(600,:).*ones(1000,1);
Valid_point_4 = a.X(800,:).*ones(1000,1);

% Training
Pesuedo_M = exp(-0.378+ 0.53*a.X(:,1));
Pesuedo_R = 8.5+ 2.2*a.X(:,2);
Pesuedo_Wg = exp(2.76+ 0.37*a.X(:,3));
X_rand = fns_generateTable_Scenario(LME_lnPGA,LME_lnWc,Pesuedo_M,Pesuedo_R,Pesuedo_Wg,0.3);
X_rand.Wb = 12+1*a.X(:,4);
save("X_SBAGM_PredDOE_1000.mat","X_rand");
%save("X_SBAGM_TrDOE_1000.mat","X_rand");

% Validation point 200
Pesuedo_M = exp(-0.378+ 0.53*Valid_point_1(:,1));
Pesuedo_R = 8.5+ 2.2*Valid_point_1(:,2);
Pesuedo_Wg = exp(2.76+ 0.37*Valid_point_1(:,3));
X_valid_200 = fns_generateTable_Scenario(LME_lnPGA,LME_lnWc,Pesuedo_M,Pesuedo_R,Pesuedo_Wg,0.3);
X_valid_200.Wb = 12+1*Valid_point_1(:,4);
save("X_SBAGM_PredDOE_200_1000.mat","X_valid_200");
%save("X_SBAGM_TrDOE_200_1000.mat","X_valid_200");


% Validation point 400
Pesuedo_M = exp(-0.378+ 0.53*Valid_point_2(:,1));
Pesuedo_R = 8.5+ 2.2*Valid_point_2(:,2);
Pesuedo_Wg = exp(2.76+ 0.37*Valid_point_2(:,3));
X_valid_400 = fns_generateTable_Scenario(LME_lnPGA,LME_lnWc,Pesuedo_M,Pesuedo_R,Pesuedo_Wg,0.3);
X_valid_400.Wb = 12+1*Valid_point_2(:,4);
save("X_SBAGM_PredDOE_400_1000.mat","X_valid_400");
%save("X_SBAGM_TrDOE_400_1000.mat","X_valid_400");


% Validation point 600
Pesuedo_M = exp(-0.378+ 0.53*Valid_point_3(:,1));
Pesuedo_R = 8.5+ 2.2*Valid_point_3(:,2);
Pesuedo_Wg = exp(2.76+ 0.37*Valid_point_3(:,3));
X_valid_600 = fns_generateTable_Scenario(LME_lnPGA,LME_lnWc,Pesuedo_M,Pesuedo_R,Pesuedo_Wg,0.3);
X_valid_600.Wb = 12+1*Valid_point_3(:,4);
save("X_SBAGM_PredDOE_600_1000.mat","X_valid_600");
%save("X_SBAGM_TrDOE_600_1000.mat","X_valid_600");

% Validation point 800
Pesuedo_M = exp(-0.378+ 0.53*Valid_point_4(:,1));
Pesuedo_R = 8.5+ 2.2*Valid_point_4(:,2);
Pesuedo_Wg = exp(2.76+ 0.37*Valid_point_4(:,3));
X_valid_800 = fns_generateTable_Scenario(LME_lnPGA,LME_lnWc,Pesuedo_M,Pesuedo_R,Pesuedo_Wg,0.3);
X_valid_800.Wb = 12+1*Valid_point_4(:,4);
save("X_SBAGM_PredDOE_800_1000.mat","X_valid_800");
%save("X_SBAGM_TrDOE_800_1000.mat","X_valid_800");

%
%
%figure
%histogram(exp(Output.lnPGA))
%hold on 
%histogram(exp(VarsTable.lnPGA))
%xlabel("PGA")
%legend("Predict", "Train");
%
%figure
%histogram(Output.Wc)
%hold on 
%histogram(VarsTable.Wc)
%xlabel("Wc")
%legend("Predict", "Train");










