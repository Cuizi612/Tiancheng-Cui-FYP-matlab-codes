
clear all;
%这个是单人校准方法，每个人的数据点全部用来拟合
%一阶导数的PTT
%血压值来源于physionet的数据库，需要手动一个个点开收集，很麻烦。

% sample 1
sample1_PTT=[0.228876712	0.2292	0.217857143	0.209071429	0.221307692	0.216971429
];
sample1_DBP=[59 57 67 63 72 76];
sample1_SBP=[87 87 94 90 92 94];

% sample 2
sample2_PTT=[0.22008547	0.228482759	0.215	0.206314607	0.204107143	0.19572549
];
sample2_DBP=[83 82 84 74 74 83];
sample2_SBP=[136 113 125 122 122 136];

% sample 3
sample3_PTT=[0.253403509	0.258857143	0.24626087	0.246772727	0.257896104	0.241333333
];
sample3_DBP=[74 72 72 79 70 77];
sample3_SBP=[120 111 111 117 106 117];

% sample 4
sample4_PTT=[0.223272727	0.220395062	0.222761905	0.238433735	0.215310345	0.202104167
];
sample4_DBP=[89 88 89 86 88 89];
sample4_SBP=[114 125 119 124 125 119];

% sample 5
sample5_PTT=[0.218373333	0.223792208	0.211820225	0.2058	0.196494624	0.205634409
];
sample5_DBP=[73 76 70 69 69 73];
sample5_SBP=[125 118 126 124 124 125];

% sample 6
sample6_PTT=[0.256184211	0.258128205	0.256363636	0.254081633	0.254025316	0.255863636
];
sample6_DBP=[67 64 64 64 65 67];
sample6_SBP=[117 114 114 120 114 117];

% sample 7
sample7_PTT=[0.21183871	0.213806452	0.196470588	0.193484848	0.203744186	0.195901235
];
sample7_DBP=[76 77 72 77 77 76];
sample7_SBP=[125 110 112 116 116 125];

% sample 8
sample8_PTT=[0.221809524	0.234853333	0.1464	0.239	0.189846154	0.248
];
sample8_DBP=[83 83 86 88 83 86];
sample8_SBP=[129 125 130 135 125 130];


% sample 9
sample9_PTT=[0.258571429	0.25	0.249542857	0.23154717	0.233973333	0.221148936
];
sample9_DBP=[55 57 49 55 57 55];
sample9_SBP=[106 110 104 106 110 118];

% sample 10
sample10_PTT=[0.242131579	0.238432432	0.196695652	0.178533333	0.21162	0.202731183
];
sample10_DBP=[69 65 74 69 69 74];
sample10_SBP=[106 98 121 106 113 121];

% % sample 11
sample11_PTT=[0.271258065	0.265573333	0.222133333	0.196	0.237714286	0.223314286
];
sample11_DBP=[73 70 70 72 72 75];
sample11_SBP=[106 100 100 105 105 113];

% sample 12
sample12_PTT=[0.244082192	0.248540541	0.229428571	0.218153846	0.241315789	0.236975
];
sample12_DBP=[80 75 87 80 80 80];
sample12_SBP=[129 116 125 119 119 129];

% sample 13
sample13_PTT=[0.223194805	0.217746835	0.215052632	0.2070625	0.214071429	0.206696629
];
sample13_DBP=[84 89 82 84 89 89];
sample13_SBP=[140 125 134 140 125 139];

% sample 14
sample14_PTT=[0.252603774	0.256423077	0.163142857	0.220583333	0.2355	0.228285714
];
sample14_DBP=[86 82 88 86 93 88];
sample14_SBP=[160 138 162 160 158 162];

% sample 15
sample15_PTT=[0.252963855	0.263829268	0.232076923	0.224391753	0.224	0.224851485
];
sample15_DBP=[76 69 76 76 69 68];
sample15_SBP=[118 116 122 118 116 111];


% sample 16
sample16_PTT=[0.238444444	0.239814815	0.222638889	0.219030303	0.232088235	0.2265625
];
sample16_DBP=[75 68 73 72 68 73];
sample16_SBP=[106 106 111 112 106 111];

% sample 17
sample17_PTT=[0.245350649	0.25976	0.221662651	0.215096774	0.198835165	0.201578947
];
sample17_DBP=[69 72 62 69 62 62];
sample17_SBP=[113 109 116 113 111 116];

% sample 18
sample18_PTT=[0.24224	0.238684211	0.221531915	0.2088125	0.222516854	0.2182
];
sample18_DBP=[80 74 79 80 77 79];
sample18_SBP=[108 98 100 108 106 100];
% sample 19
sample19_PTT=[0.242405405	0.245818182	0.202333333	0.1881	0.22	0.2254
];
sample19_DBP=[81 81 80 81 81 82];
sample19_SBP=[122 115 123 122 115 128];
% sample 20
sample20_PTT=[0.253722222	0.255728395	0.166	0.184461538	0.2538	0.243428571
];
sample20_DBP=[76 86 84 76 87 84];
sample20_SBP=[118 114 118 118 123 118];

% sample 21
sample21_PTT=[0.229808219	0.234055556	0.224083333	0.223882353	0.212520833	0.221775281
];
sample21_DBP=[82 77 79 82 77 76];
sample21_SBP=[129 113 113 129 113 125];

% sample 22
sample22_PTT=[0.2161	0.2137	0.198106383	0.198787234	0.194494845	0.203242105
];
sample22_DBP=[76 80 78 73 73 76];
sample22_SBP=[108 102 104 101 101 108];



avg_resid_all = zeros(1, 22);
rmse_all = zeros(1, 22);
parameterbox = zeros(1,22);
for i = 1:22
    % 获取第i组数据
    eval(['x = sample', num2str(i), '_PTT;']);
    eval(['y = sample', num2str(i), '_DBP;']);


   % 使用 fit 函数拟合数据
    %  f = fittype('a*log(x)+b', 'independent', 'x', 'dependent', 'y');
   %   f = fittype('a*x+b', 'independent', 'x', 'dependent', 'y');
      f = fittype('(a./x)+b', 'independent', 'x', 'dependent', 'y');
     % f = fittype('(a./(x.*x))+b', 'independent', 'x', 'dependent', 'y');
     % f = fittype('a*exp(b*x)', 'independent', 'x', 'dependent', 'y');

    model = fit(x', y', f);
    b = model.b;
    a=model.a;
    % 计算拟合曲线上的点
xFit = linspace(min(x), max(x), 100);
yFit = a ./xFit + b;  %这个也要根据式子更改

% 可视化数据点和拟合曲线
figure;
plot(x, y, 'bo'); % 绘制数据点
hold on;
plot(xFit, yFit, 'r-', 'LineWidth', 2); % 绘制拟合曲线
xlabel('PTT(second)');
ylabel('DBP(mmHg)');
legend('measurement points', 'curve');
title('Example subject PTT-BP');

    % 计算数据点相对于直线的偏差，residual取了绝对值，后续算的是MAE
    % residual = abs(y - (a * log(x) + b));
    % residual = abs(y - (a * x + b));
     residual = abs(y - ((a./x) + b));
    % residual = abs(y - ((a./(x.*x)) + b));
     % residual = abs(y-(a*exp(b*x)));
    
    % 计算平均残差
    avg_resid = mean(residual);

    % 计算均方根误差（RMSE）
    rmse = sqrt(mean(residual.^2));


    % 存储结果到数组
    avg_resid_all(i) = avg_resid;
    rmse_all(i) = rmse;
    parameterbox(i)=a;
end

avg_resid_all = avg_resid_all';
rmse_all = rmse_all';
parameterbox=parameterbox';
parameter=mean(parameterbox);
% 显示所有结果
disp('平均MAE:');
disp(avg_resid_all);
disp('平均RMSE:');
disp(rmse_all);
disp("最终结果");
disp(mean(rmse_all));