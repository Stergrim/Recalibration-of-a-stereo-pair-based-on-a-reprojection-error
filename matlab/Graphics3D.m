function [E0, EVec] = Graphics3D(Matrix0, Rp, Tp, Number, Value, N1, N2)
% Функция выводит графики поверхностей, где ось Z - ось ошибки, ось X -
% смещение по номеру N1, ось Y - смещение по номеру N2. Нумерация 1 = Tx,
% 2 = Ty, 3 = Tz, 4 = Heading, 5 = Attitude, 6 = Bank.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Вид вводимых матриц

% Матрица внутренних параметров камеры
% Matrix0 = [1684.1, 0, 1295.5;
%            0, 1681.8,  971.5;
%            0,      0,      1];

% Поворот и смещение второй камеры относително первой
% Rp = [1, 6.9*10^(-5), 9.1*10^(-6);
%      -6.9*10^(-5), 1, -1.8*10^(-5);
%      -9.1*10^(-6), 1.8*10^(-5),  1];
%          
% Tp = [-150.5, 0, 1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Формирование набора точек соотвествующие прямоугольной обласи крыла
Coord3D = WingPattern(1000, 60, 40, 45, 6, 4);

N = size(Coord3D, 1); % Определение числа точек

% Добавление четвёртого столбца из единиц
One = zeros(N,1);

for n = 1:N
    One(n) = 1;
end

Coord3D = [Coord3D One];
       
% Левая камера берётся за начало системы координта
Rl = [1, 0, 0;
      0, 1, 0;
      0, 0, 1];
   
Tl = [0, 0, 0];

RTl = [Rl Tl'];

% Правая камера
RTp = [Rp Tp'];

% Матрицы связи 3-ёх и 2-ух мерных координт
MatrixL = Matrix0*RTl;
MatrixP = Matrix0*RTp;

% Инициализация 2d координат на изображении
Coord2Dl = zeros(N,3);
Coord2Dp = zeros(N,3);

% Транспонирование матрицы координат для умножения
Coord3D = Coord3D';

for n = 1:N
    Coord2Dl(n,:) = MatrixL*Coord3D(:,n);
    Coord2Dp(n,:) = MatrixP*Coord3D(:,n);
    Coord2Dl(n,:) = Coord2Dl(n,:)/Coord2Dl(n,3);
    Coord2Dp(n,:) = Coord2Dp(n,:)/Coord2Dp(n,3);
end

% Исключение третьего столбца из единиц для предачи во встроенную функцию
% триангуляции
Coord2Dl = Coord2Dl(:,1:2);
Coord2Dp = Coord2Dp(:,1:2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Выше смоделировано получение(двух изображений) 2d координат точек с двух
% камер для последующей перекалибровки. Также записаны исходные
% калибровочные матрицы камер.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Внесение искажений

% Определения начальных углов Эйлера
[heading0, attitude0, bank0] = Decomposition(Rp);

% Запись изменяемого вектора смещения
Tn = Tp;

% Если Namber равняется 1 до 3, то изменяется вектор смещения T

% Number = 1 соотвествует смещению по оси X или Tx. Value в абсолютный
% значения в мм

if (Number == 1)
    Tn(1) = Tn(1) + Value;
end

% Number = 2 соотвествует смещению по оси Y или Ty. Value в абсолютный
% значения в мм

if (Number == 2)
    Tn(2) = Tn(2) + Value;
end

% Number = 3 соотвествует смещению по оси Z или Tz. Value в абсолютный
% значения в мм

if (Number == 3)
    Tn(3) = Tn(3) + Value;
end

% Если Namber равняется 4 до 6, то изменяется матрица поворота R

% Number = 4 соотвествует повороту Heading. Value в абсолютный
% значения в градусах

if (Number == 4)
    heading0 = heading0 + Value*pi/180;
end

% Number = 5 соотвествует повороту Attitude. Value в абсолютный
% значения в градусах

if (Number == 5)
    attitude0 = attitude0 + Value*pi/180;
end

% Number = 6 соотвествует повороту Bank. Value в абсолютный
% значения в градусах

if (Number == 6)
    bank0 = bank0 + Value*pi/180;
end


% Если Namber равняется 7, то изменяются все парметры случайно в процентном
% соотношении от максимума допучстимого отклонения. Value в процентах

% Максимумы отклоений Tmax в мм и Rmax в радианах
Tmax = 10;
Rmax = 2*pi/180;

if (Number == 7)
    Tn(1) = Tn(1) + Tmax*(2*rand(1) - 1)*Value/100;
    Tn(2) = Tn(2) + Tmax*(2*rand(1) - 1)*Value/100;
    Tn(3) = Tn(3) + Tmax*(2*rand(1) - 1)*Value/100;
    heading0 = heading0 + Rmax*(2*rand(1) - 1)*Value/100;
    attitude0 = attitude0 + Rmax*(2*rand(1) - 1)*Value/100;
    bank0 = bank0 + Rmax*(2*rand(1) - 1)*Value/100;
end

% Запись новых центральных значений смещения
Tp = Tn;

% Запись изменяемой матрицы поворота
Rn = Eiler(heading0, attitude0, bank0);

% Запись в вектор углов
Angle0 = [heading0, attitude0, bank0];
Angle = Angle0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ниже на основе двумерных координат точек и калибровочных матриц
% выполняется репроекция и поиск ошибки репроекции

RTn = [Rn Tn'];

MatrixP = Matrix0*RTn;

% Определение 3d координат точек
C0 = TriangulationCustom(Coord2Dl, Coord2Dp, MatrixL, MatrixP);

% Добавление четвёртого столбца из единиц и транспонирование для умножения
C0 = [C0 One];

% Транспонирование для умножения
C0 = C0';

% Инициализация 2d координат на изображении
Coord2Dln = zeros(N,3);
Coord2Dpn = zeros(N,3);

for n = 1:N
    Coord2Dln(n,:) = MatrixL*C0(:,n);
    Coord2Dpn(n,:) = MatrixP*C0(:,n);
    Coord2Dln(n,:) = Coord2Dln(n,:)/Coord2Dln(n,3);
    Coord2Dpn(n,:) = Coord2Dpn(n,:)/Coord2Dpn(n,3);
end

% Подсчёт начальной ошибки репроекции
E0 = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Блок расчёта графиков в зависмости от комбинации N1 и N2

if (((N1 > 0)&&(N1 < 4))&&((N2 > 0)&&(N2 < 4)))
    Delta = 10;
    step = 1;
    K = 2*Delta/step + 1;
    EVec = zeros(K,K);
    for k1 = 1:K
        Tn(N1) = Tp(N1) - Delta + step*(k1-1);
        for k2 = 1:K
            Tn(N2) = Tp(N2) - Delta + step*(k2-1);
            RTn = [Rn Tn'];
            MatrixP = Matrix0*RTn;
            C = TriangulationCustom(Coord2Dl, Coord2Dp, MatrixL, MatrixP);
            
            for n = 1:N
                C(n, 4) = 1;
            end
            
            C = C';
            
            for n = 1:N
                Coord2Dln(n,:) = MatrixL*C(:,n);
                Coord2Dpn(n,:) = MatrixP*C(:,n);
                Coord2Dln(n,:) = Coord2Dln(n,:)/Coord2Dln(n,3);
                Coord2Dpn(n,:) = Coord2Dpn(n,:)/Coord2Dpn(n,3);
            end
            
            EVec(k1,k2) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
        end
    end
    
    X = zeros(K,1);
    Y = zeros(K,1);
    
    for k = 1:K
        X(k) = -Delta + step*(k-1) + Tp(N1);
        Y(k) = -Delta + step*(k-1) + Tp(N2);
    end
    
    surf(Y,X,EVec);
    xlabel('Y'); % xlabel('Смещение по оси Y, мм');
    ylabel('X'); % ylabel('Смещение по оси X, мм');
    zlabel('Z'); % zlabel('СКО в пикселях');
    
    
elseif (((N1 > 0)&&(N1 <= 3))&&((N2 > 3)&&(N2 <= 6)))
    Delta1 = 10;
    Delta2 = 2;
    step1 = 1;
    step2 = 0.1;
    K1 = 2*Delta1/step1 + 1;
    K2 = 2*Delta2/step2 + 1;
    EVec = zeros(K1,K2);
    for k1 = 1:K1
        Tn(N1) = Tp(N1) - Delta1 + step1*(k1-1);
        for k2 = 1:K2
            Angle(N2-3) = Angle0(N2-3)*180/pi - Delta2 + step2*(k2-1);
            Angle(N2-3) = Angle(N2-3)*pi/180;
            Rn = Eiler(Angle(1), Angle(2), Angle(3));
            RTn = [Rn Tn'];
            MatrixP = Matrix0*RTn;
            C = TriangulationCustom(Coord2Dl, Coord2Dp, MatrixL, MatrixP);
            
            for n = 1:N
                C(n, 4) = 1;
            end
            
            C = C';
            
            for n = 1:N
                Coord2Dln(n,:) = MatrixL*C(:,n);
                Coord2Dpn(n,:) = MatrixP*C(:,n);
                Coord2Dln(n,:) = Coord2Dln(n,:)/Coord2Dln(n,3);
                Coord2Dpn(n,:) = Coord2Dpn(n,:)/Coord2Dpn(n,3);
            end
            
            EVec(k1,k2) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
        end
    end
    
    X = zeros(K1,1);
    Y = zeros(K2,1);
    
    for k1 = 1:K1
        X(k1) = -Delta1 + step1*(k1-1) + Tp(N1);
    end
    
    for k2 = 1:K2
        Y(k2) = -Delta2 + step2*(k2-1) + Angle0(N2-3)*180/pi;
    end
    
    surf(Y,X,EVec);
    xlabel('Y'); % xlabel('Поворот вокруг оси Z, градусы');
    ylabel('X'); % ylabel('Смещение по оси X, мм');
    zlabel('Z'); % zlabel('СКО в пикселях');
    
    
elseif (((N1 > 3)&&(N1 <= 6))&&((N2 > 3)&&(N2 <= 6)))
    Delta = 2;
    step = 0.1;
    K = 2*Delta/step + 1;
    EVec = zeros(K,K);
    for k1 = 1:K
        Angle(N1-3) = Angle0(N1-3)*180/pi - Delta + step*(k1-1);
        Angle(N1-3) = Angle(N1-3)*pi/180;
        for k2 = 1:K
            Angle(N2-3) = Angle0(N2-3)*180/pi - Delta + step*(k2-1);
            Angle(N2-3) = Angle(N2-3)*pi/180;
            Rn = Eiler(Angle(1), Angle(2), Angle(3));
            RTn = [Rn Tn'];
            MatrixP = Matrix0*RTn;
            C = TriangulationCustom(Coord2Dl, Coord2Dp, MatrixL, MatrixP);
            
            for n = 1:N
                C(n, 4) = 1;
            end
            
            C = C';
            
            for n = 1:N
                Coord2Dln(n,:) = MatrixL*C(:,n);
                Coord2Dpn(n,:) = MatrixP*C(:,n);
                Coord2Dln(n,:) = Coord2Dln(n,:)/Coord2Dln(n,3);
                Coord2Dpn(n,:) = Coord2Dpn(n,:)/Coord2Dpn(n,3);
            end
            
            EVec(k1,k2) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
        end
    end
    
    X = zeros(K,1);
    Y = zeros(K,1);
    
    for k = 1:K
        X(k) = -Delta + step*(k-1) + Angle0(N1-3)*180/pi;
        Y(k) = -Delta + step*(k-1) + Angle0(N2-3)*180/pi;
    end
    
    surf(Y,X,EVec);
    xlabel('Y');
    ylabel('X');
    zlabel('Z');
    
    
elseif (((N1 > 3)&&(N1 <= 6))&&((N2 > 0)&&(N2 <= 3)))
    Delta1 = 2;
    Delta2 = 10;
    step1 = 0.1;
    step2 = 1;
    K1 = 2*Delta1/step1 + 1;
    K2 = 2*Delta2/step2 + 1;
    EVec = zeros(K1,K2);
    for k1 = 1:K1
        Angle(N1-3) = Angle0(N1-3)*180/pi - Delta1 + step1*(k1-1);
        Angle(N1-3) = Angle(N1-3)*pi/180;
        Rn = Eiler(Angle(1), Angle(2), Angle(3));
        for k2 = 1:K2
            Tn(N2) = Tp(N2) - Delta2 + step2*(k2-1);
            RTn = [Rn Tn'];
            MatrixP = Matrix0*RTn;
            C = TriangulationCustom(Coord2Dl, Coord2Dp, MatrixL, MatrixP);
            
            for n = 1:N
                C(n, 4) = 1;
            end
            
            C = C';
            
            for n = 1:N
                Coord2Dln(n,:) = MatrixL*C(:,n);
                Coord2Dpn(n,:) = MatrixP*C(:,n);
                Coord2Dln(n,:) = Coord2Dln(n,:)/Coord2Dln(n,3);
                Coord2Dpn(n,:) = Coord2Dpn(n,:)/Coord2Dpn(n,3);
            end
            
            EVec(k1,k2) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
        end
    end
    
    X = zeros(K1,1);
    Y = zeros(K2,1);
    
    for k1 = 1:K1
        X(k1) = -Delta1 + step1*(k1-1) + Angle0(N1-3)*180/pi;
    end
    
    for k2 = 1:K2
        Y(k2) = -Delta2 + step2*(k2-1) + Tp(N2);
    end
    
    surf(Y,X,EVec);
    xlabel('Y');
    ylabel('X');
    zlabel('Z');
end

end

