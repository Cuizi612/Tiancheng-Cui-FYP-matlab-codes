
%计算血压模型误差。
%CAS-BP中，有Day0，7，14，28的结果，每天有三组数据对，共计12组。根据文献所述，选取了第一天的一次数据作为校准点。
%根据我的理解，第一天的剩余两点的结果，是模型Day0的情况。其余三个日期的结果，可以用来检验模型随时间是否失效。

clear all;
%首先把样本的数据都收集整理到结构体里，比如：
patients={ 
    %2369 26F
    struct('DBP',[64 65 65.5 63 62 58 62 63 61 59 59 60.5],...
    'SBP',[90.5 91.5 89 92.5 89.5 83.5 91 88 86.5 89.5 87 89.5],...
    'PTT',[0.2158 0.2235 0.2231 0.2309 0.2269 0.2355 0.2296 0.2304 0.2299 0.2447 0.2459 0.2412]),

    %2430 31F
    struct('DBP',[62 61 60 61.5 59.5 60.5 64 64 63 71 76.5 75.5],...
    'SBP',[91 93.5 94 93.5 89 91 97.5 98 97.5 100 103.5 104],...
    'PTT',[0.2638 0.2644 0.2633 0.2463 0.2634 0.2619 0.2491 0.2426 0.2405 0.2523 0.2471 0.2487]),

    %2668 34F
    struct('DBP',[82 81.5 80 79.5 78.5 76.5 83.5 81 81.5 76.5 75.5 75],...
    'SBP',[133.5 127.5 126 125.5 124.5 123 141 135.5 134.5 125 126.5 125.5],...
    'PTT',[0.2511 0.2487 0.2501 0.2431 0.2657 0.2474 0.2537 0.244 0.2431 0.2742 0.2744 0.2784])
 };


num_patients = numel(patients);

DBP_MAE_results = zeros(num_patients, 4); % 存储 MAE 结果数组
DBP_RMSE_results = zeros(num_patients, 4); % 存储 RMSE 结果数组
SBP_MAE_results = zeros(num_patients, 4); % 存储 MAE 结果数组
SBP_RMSE_results = zeros(num_patients, 4); % 存储 RMSE 结果数组

DBP_residual_results=zeros(num_patients,3);
SBP_residual_results=zeros(num_patients,3);

for p = 1:num_patients
    subject = patients{p};
    
    dbp = subject.DBP(1);
    sbp = subject.SBP(1);
    ptt = subject.PTT(1);
    
    DBP_results = zeros(1, length(subject.PTT)); % 初始化长度为11的DBP结果数组
    SBP_results = zeros(1, length(subject.PTT)); % 初始化长度为11的SBP结果数组
    
    for i = 2:length(subject.PTT)
        PTT = subject.PTT(i);
        DBP = (1/3)*sbp + (2/3)*dbp + (2/0.031)*log(ptt/PTT) - (sbp-dbp)*(1/3)*((ptt*ptt)/(PTT*PTT));
        SBP = DBP + (sbp-dbp)*((ptt*ptt)/(PTT*PTT));
        DBP_results(i) = DBP; % 存储DBP结果
        SBP_results(i) = SBP; % 存储SBP结果
    end
    
    DBP_residual = subject.DBP - DBP_results;
    SBP_residual = subject.SBP - SBP_results;

    %残差用于画B-A图
    DBP_residual_results(p,1)=DBP_residual(4);
    DBP_residual_results(p,2)=DBP_residual(5);
    DBP_residual_results(p,3)=DBP_residual(6);

    DBP_MAE_results(p,1)= (abs(DBP_residual(2))+abs(DBP_residual(3)))/2;
    DBP_MAE_results(p,2)=(abs(DBP_residual(4))+abs(DBP_residual(5))+abs(DBP_residual(6)))/3;
    DBP_MAE_results(p,3)=(abs(DBP_residual(7))+abs(DBP_residual(8))+abs(DBP_residual(9)))/3;
    DBP_MAE_results(p,4)=(abs(DBP_residual(10))+abs(DBP_residual(11))+abs(DBP_residual(12)))/3;
    
    DBP_RMSE_results(p,1)=sqrt((abs(DBP_residual(2))^2+abs(DBP_residual(3))^2)/2);
    DBP_RMSE_results(p,2)=sqrt((abs(DBP_residual(4))^2+abs(DBP_residual(5))^2+abs(DBP_residual(6))^2)/3);
    DBP_RMSE_results(p,3)=sqrt((abs(DBP_residual(7))^2+abs(DBP_residual(8))^2+abs(DBP_residual(9))^2)/3);
    DBP_RMSE_results(p,4)=sqrt((abs(DBP_residual(10))^2+abs(DBP_residual(11))^2+abs(DBP_residual(12))^2)/3);
    
    SBP_MAE_results(p,1)= (abs(SBP_residual(2))+abs(SBP_residual(3)))/2;
    SBP_MAE_results(p,2)=(abs(SBP_residual(4))+abs(SBP_residual(5))+abs(SBP_residual(6)))/3;
    SBP_MAE_results(p,3)=(abs(SBP_residual(7))+abs(SBP_residual(8))+abs(SBP_residual(9)))/3;
    SBP_MAE_results(p,4)=(abs(SBP_residual(10))+abs(SBP_residual(11))+abs(SBP_residual(12)))/3;
    
    SBP_RMSE_results(p,1)=sqrt((abs(SBP_residual(2))^2+abs(SBP_residual(3))^2)/2);
    SBP_RMSE_results(p,2)=sqrt((abs(SBP_residual(4))^2+abs(SBP_residual(5))^2+abs(SBP_residual(6))^2)/3);
    SBP_RMSE_results(p,3)=sqrt((abs(SBP_residual(7))^2+abs(SBP_residual(8))^2+abs(SBP_residual(9))^2)/3);
    SBP_RMSE_results(p,4)=sqrt((abs(SBP_residual(10))^2+abs(SBP_residual(11))^2+abs(SBP_residual(12))^2)/3);
end
