    
    %此为通过PPG二阶导数信号提取refelction index b/a 的代码
    %理想的信号b和a都比较好找

    read=readtable("E:\CASBP-Dataset\2358\20210525\2358_4_2_20210525095342_62_109_68_106_6BF\ppg_ecg.csv");
    % 读取ppg信号，并去噪、绘制图像。
    PPGall=read(1:6000,8).Variables;  %根据需要的长度更改。
    ppg=-PPGall;
    
    % 设计带通滤波器
    fs = 1000; % 采样频率为1000Hz
    fpass = [0.5, 20]; % 设置带通滤波器的通带范围
    filterOrder = 4; % 滤波器阶数
    t=1:6000;
    % 设计巴特沃斯滤波器
    [b, a] = butter(filterOrder, fpass / (fs/2), 'bandpass');
    % 应用滤波器进行信号滤波
    filtered_ppg = filtfilt(b, a, ppg);
    % % 计算filtered_PPG的一阶导数
    first_derivative = diff(filtered_ppg);%乘个系数让最大处峰值明显方便标记
    % 由于diff函数会减少一个数据点，因此时间向量t也需要相应调整
    t_first_derivative = t(1:end-1) + diff(t)/2;
    % 计算filtered_PPG的二阶导数
    second_derivative = diff(first_derivative); % 乘个系数让最大处峰值明显方便标记
    
    % 绘制一阶导数和二阶导数曲线图
    figure;
    plot(t_first_derivative, first_derivative/200, 'b', 'LineWidth', 1.5);
    hold on;
    plot(t_first_derivative(1:end-1), second_derivative, 'r', 'LineWidth', 1.5);
    xlabel('samples');
    ylabel('Derivative');
    title('First and Second Derivative Plot of PPG Signal');
    legend('First Derivative', 'Second Derivative');
    grid on; % 添加网格线
    line(xlim, [0 0], 'Color', 'k', 'LineWidth', 1.5, 'LineStyle', '--'); % 添加水平参考线
    
    M = 1;
    N = length(second_derivative);
    z=second_derivative;
    peak_positions = [];
    peak_values = [];
    for i = 2:N-1
        if z(i) > z(i-1) && z(i) > z(i+1) && z(i) > 0.4*max(z)
            peak_values(M) = z(i);
            peak_positions(M) = i;
            M = M + 1;
        end
    end
    ppg_peaks = M - 1;
    ppg_peak_pos = peak_positions ./ 1000;
    ppg_peak_val = peak_values;
    plot(peak_positions, peak_values, '*b');
    
    valley_positions = [];
    valley_values = [];
    
    for i = 1:length(peak_positions)-1
        start_index = peak_positions(i);
        end_index = peak_positions(i+1);
        [valley_value, valley_index] = min(z(start_index:end_index));
        valley_positions(i) = start_index + valley_index - 1;
        valley_values(i) = valley_value;
    end
    
    ppg_valleys = length(valley_positions);
    ppg_valley_pos = valley_positions ./ 1000;
    ppg_valley_val = valley_values;
    plot(valley_positions, valley_values, '*r');
    
    if length(ppg_peak_pos)>length(ppg_valley_pos)
        ppg_peak_val=ppg_peak_val(1:end-1);
    end 
    result=mean(ppg_valley_val./ppg_peak_val);
