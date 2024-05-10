% 这个代码当时是为了处理PhysioNet的ECG和PPG写的。
%这个数据库里面的信号有的会受运动干扰比较大一点。
%如果无法顺利检测峰值，需要手动更改读取的范围，甚至手动地去标注峰值。
%最值得商榷的一点是，该数据库描述称：每个样本有三条记录，分别是静坐，走路和跑步，
%在每项运动的beginning和end都使用商业脉搏血氧仪和血压监测仪记录了血压。
%大概是运动前，和结束之后，停下来用设备测。
%每条信号长度大概是8min
%那么选取运动时的第1分钟的记录和最后1分钟的记录合不合理呢？还是应该30秒？或者2min？没有相关说明。可以自行更改。
%不同的长度最后得到的结论仍然是没有很大的区别。
%而且，运动的中间（血压最受运动状态影响的那个时候）反而没有血压值。
% 那么这三种运动状态的区别似乎也不是很大，比较运动幅度也不会太大。
% 反而是信号质量受了很大影响。
%function ptt=CalculatePTT2(filepaths)
  
    Read=readtable("E:\Physio\s1_sit.csv");
    Ppgall=Read(1:30000,"pleth_2").Variables; % 前60秒的ppg图像
    %Ppgall=Read(200000:229999,'pleth_2').Variables;%后60秒
    
    Ecgall=Read(1:30000,"ecg").Variables ;% 前60秒的ecg图像
    %Ecgall=Read(200000:229999,'ecg').Variables;%后60秒,但是有的记录没有8min那么长
    
    
    min_val = min(Ppgall);
    max_val = max(Ppgall);
    ppg = (Ppgall - min_val) / (max_val - min_val);% 归一化
    ppg=-ppg;
    t=(1:30000)/500;
    
    window_size = 100; % 滚动窗口大小，根据需要可调整
    gaussian_window = gausswin(window_size);
    rolling_mean = movmean(ppg, window_size, 'SamplePoints', t); % 
    DC_removed_PPG = ppg - rolling_mean;
    fs = 1500; % 采样率，根据实际情况调整
    f1 = 0.75; % 低通截止频率
    f2 = 15; % 高通截止频率
    [b, a] = butter(2, [f1 f2] / (fs/2), 'bandpass');
    filtered_PPG = filtfilt(b, a, DC_removed_PPG);
    plot(filtered_PPG);
    hold on;
    % 计算filtered_PPG的一阶导数
    filtered_PPG= diff(filtered_PPG);
    % 由于diff函数会减少一个数据点，因此时间向量t也需要相应调整
    t = t(1:end-1) + diff(t)/2;

    min_val = min(Ecgall);
    max_val = max(Ecgall);
    ecg = (Ecgall - min_val) / (max_val - min_val);% 归一化
    plot(ecg);

    %尝试预处理
    % ------------------------------低通滤波器滤除肌电信号--------------------------
    Fs=1500; %采样频率
    fp=80;fs=100; %通带截止频率，阻带截止频率
    rp=1.4;rs=1.6; %通带、阻带衰减
    wp=2*pi*fp;ws=2*pi*fs;
    [n,wn]=buttord(wp,ws,rp,rs,'s'); %'s’是确定巴特沃斯模拟滤波器阶次和3dB
    %截止模拟频率
    [z,P,k]=buttap(n); %设计归一化巴特沃斯模拟低通滤波器，z为极点，p为零点和k为增益
    [bp,ap]=zp2tf(z,P,k); %转换为Ha,bp为分子系数，ap为分母系数
    [bs,as]=lp2lp(bp,ap,wp); %Ha转换为低通Ha(s)并去归一化，bs为分子系数，as为分母系数
    [hs,ws]=freqs(bs,as); %模拟滤波器的幅频响应
    [bz,az]=bilinear(bs,as,Fs); %对模拟滤波器双线性变换
    [h1,w1]=freqz(bz,az); %数字滤波器的幅频响应
    M=filter(bz,az,ecg);
    
    %TIME = range(length(data));
    TIME=1:length(ecg);
    
    N=1500;
    n=0:N-1;
    
    %-----------基线漂移的去除------------------------------------------
    fmaxd_1=5;%截止频率为5Hz
    fmaxn_1=fmaxd_1/(Fs/2);
    [B,A]=butter(1,fmaxn_1,'low');
    
    freqz(B,A);
    ecg_low=filtfilt(B,A,M);%通过5Hz低通滤波器的信号
    ecg1=M-ecg_low; %去除这一段信号，得到去基线漂移的信号

    %% ECG signal
    y=ecg1;
    % ECG signal
    figure,plot(y);
    title('ECG signal');
    xlabel('time');
    ylabel('amplitude');
    hold on
    
    %% peak detection of ECG
    j=1;
    n=length(y);
    for i=2:n-1
        if y(i)> y(i-1) && y(i)>= y(i+1) && y(i)> 0.5*max(y)
           val(j)= y(i);
           pos(j)=i;
           j=j+1;
         end
    end
    ecg_peaks=j-1;
    ecg_pos=pos./500; % 这个500应该和采样频率一致，我的情况里采样频率是500Hz，那么第500个点代表过去了1s
    plot(pos,val,'*r');
    title('ECG peak');
    
    %% peak detection of PPG
    z=filtered_PPG;
    %% PPG signal
    
    plot(z,'r');
    hold on
    title('PPG and ECG');
    xlabel('samples');
    ylabel('amplitude');
    m=1;
    n=length(z);
    for i=2:n-1
        if z(i)> z(i-1) && z(i)> z(i+1)  && z(i)> 0.5*max(z) % 这个0.3决定了峰值能不能被检测到
           vall(m)= z(i);
           pos1(m)=i;
           m=m+1;
         end
    end
    ppg_peaks=m-1;
    ppg_pos=pos1./500;
    ppg_val=vall;
    plot(pos1,vall,'*g');
    
    
    usefulppg_pos = interp1(ppg_pos, ppg_pos, ecg_pos, 'nearest');
    
    B=usefulppg_pos;
    A=ecg_pos;
    % 创建一个逻辑索引数组，标记B中NaN的位置
    nanIdx = isnan(B);
    
    % 初始化C为零数组，大小与A和B相同
    C = zeros(size(A));
    
    % 在B不是NaN的位置上，计算A减去B的结果。可能出现检测不到导致错开，但是用一个大致范围可以尽量地避免并去除异常情况
    C(~nanIdx) = B(~nanIdx) - A(~nanIdx);
    C = C(:, ~any((C<0.12|C>0.4), 1));
    ptt=mean(C)