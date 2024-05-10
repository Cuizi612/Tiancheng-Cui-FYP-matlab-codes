    clear all;
    
    %这是通过PPG一阶导数和ECG图像进行PTT提取的代码。对于CAS-BP库的记录，绝大部分情况下可以检测出
    %一百多个PTT然后取平均值。观察C数组可以看到大部分PTT
    %得益于CAS-BP数据库的信号本身除噪之后质量非常好。
    %但是有时候仍然会出错，比如有的信号中间会突然有一条特别高的，或者有的信号形态不理想，有一些地方会被误检测为峰值。
    %所以有时需要查看信号，并更改峰值检测的阈值（甚至只能手动改读取的时间范围，分开来算）
    %其实就峰值检测就类似于matlab自带的findpeaks。


    %在保证信号质量的情况下，如果这样取得的ptt能被接受，可以把该文件写成一个方法，被其他文件调用。
    %可以用python代码辅助得到所有需要的文件夹路径。直接把所有文件路径放在一起。
    read=readtable("E:\CASBP-Dataset\2033\20201223\2033_3_2_20201223142244_48_84_52_81_23F\ppg_ecg.csv");

    Ecgall=read(1:2000,7).Variables;
    min_val = min(Ecgall);
    max_val = max(Ecgall);
    ecg = ((Ecgall - min_val) / (max_val - min_val));% 归一化
    fs = 1000; % 采样频率为1000Hz
    fpass = [0.5, 40]; % 设置带通滤波器的通带范围
    filterOrder = 4; % 滤波器阶数
    [b, a] = butter(filterOrder, fpass / (fs/2), 'bandpass');
    filtered_ecg = filtfilt(b, a, ecg);


    PPGall=read(1:2000,8).Variables;
    ppgmin_val = min(PPGall);
    ppgmax_val = max(PPGall);
    ppg = (PPGall - ppgmin_val) / (ppgmax_val - ppgmin_val);% 归一化
    ppg=-ppg;  %这个是必要的。
    fs = 1000; % 采样频率为1000Hz。
    fpass = [0.5, 20]; % 设置带通滤波器的通带范围。
    filterOrder = 4; % 滤波器阶数。
    [b, a] = butter(filterOrder, fpass / (fs/2), 'bandpass');
    filtered_ppg = filtfilt(b, a, ppg);
    first_derivative = 100*diff(filtered_ppg);
    t_first_derivative = 1:length(first_derivative);
    plot(t_first_derivative/1000, first_derivative);

    %ECG峰值
    j=1;
    n=length(filtered_ecg);
    for i=2:n-1
        if filtered_ecg(i)> filtered_ecg(i-1) && filtered_ecg(i)>= filtered_ecg(i+1) && filtered_ecg(i)> 0.6*max(filtered_ecg)  %这里的系数需要根据实际图像调整
           val(j)= filtered_ecg(i);
           pos(j)=i;
           j=j+1;
         end
    end
    ecg_peaks=j-1;
    ecg_pos=pos./1000;
    plot(filtered_ecg);
    hold on
    plot(pos,val,'*r');



    %PPG一阶导数峰值
    z=first_derivative;
    plot(z,'r');
    hold on
    title('PPG 1st derivative(red) and ECG(blue)');
    xlabel('samples');
    ylabel('amplitude');

    m=1;
    n=length(z);
    for i=2:n-1
        if z(i)> z(i-1) && z(i)> z(i+1)  && z(i)> 0.35*max(z)
           vall(m)= z(i);
           pos1(m)=i;
           m=m+1;
         end
    end
    ppg_peaks=m-1;
    ppg_pos=pos1./1000;
    ppg_val=vall;
    plot(pos1,vall,'*g');



    %相较而言ecg更好检测一些，根据ecg的峰值，选择紧随其后的ppg峰值进行配对
    usefulppg_pos = interp1(ppg_pos, ppg_pos, ecg_pos, 'nearest');
    B=usefulppg_pos;
    A=ecg_pos;
    nanIdx = isnan(B);
    C = zeros(size(A));
    C(~nanIdx) = B(~nanIdx) - A(~nanIdx);


    %可能会有误检测的情况，去掉极端的值。
    C = C(:, ~any((C<0.12|C>0.5), 1));
    ptt=mean(C);
