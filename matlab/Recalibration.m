function [E0, EInv, AngleP, AngleInv, Tp0, TInv, dC0, dCInv, VecPBest, EVecBest] = Recalibration(Matrix0, Rp, Tp, Number, Value)
%PMV, ItersV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Вид вводимых матриц

% Матрица внутренних параметров камеры
% Matrix0 = [7500, 0, 1250;
%            0, 7500,  980;
%            0,      0,      1];

% Поворот и смещение второй камеры относително первой
% Rp = [ 0.9780, 0.0297,  0.2065;
%       -0.0175, 0.9980, -0.0610;
%       -0.2079, 0.0561,  0.9765]; 
%          
% Tp = [-315, 115, 40];

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

% Для вывода вектора без смещений
Tp0 = Tp;

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

% Транспонирование для вывода
Coord3D = Coord3D';
Coord3D = Coord3D(:,1:3);

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ниже на основе двумерных координат точек и калибровочных матриц
% выполняется репроекция и поиск ошибки репроекции

RTn = [Rn Tn'];

MatrixP = Matrix0*RTn;

% Определение 3d координат точек
C0 = TriangulationCustom(Coord2Dl, Coord2Dp, MatrixL, MatrixP);

% Добавление четвёртого столбца из единиц и транспонирование для умножения
C0 = [C0 One];

% Инициализация 2d координат на изображении
Coord2Dln = zeros(N,3);
Coord2Dpn = zeros(N,3);

% Транспонирование для умножения
C0 = C0';

for n = 1:N
    Coord2Dln(n,:) = MatrixL*C0(:,n);
    Coord2Dpn(n,:) = MatrixP*C0(:,n);
    Coord2Dln(n,:) = Coord2Dln(n,:)/Coord2Dln(n,3);
    Coord2Dpn(n,:) = Coord2Dpn(n,:)/Coord2Dpn(n,3);
end

% Подсчёт начальной ошибки репроекции
E0 = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);

% Транспонирование и удаление последнего столбца единиц для выводы и
% расчёта СКО, выраженного в мм
C0 = C0';
C0 = C0(:,1:3);

dC0 = 0; % СКО репроекции в мм

for n = 1:N
    dC0 = (C0(n,1) - Coord3D(n,1))^(2) + (C0(n,2) - Coord3D(n,2))^(2) + (C0(n,3) - Coord3D(n,3))^(2);
end

dC0 = sqrt(dC0/N);

%--------------------------------------------------------------------------
% Запись в вектор всех параметров
VecP = [Tn(1); Tn(2); Tn(3); heading0; attitude0; bank0];

%--------------------------------------------------------------------------
% Метод Нелдера-Мида
% [VecPInv, Iters, VecPB, EVec, PM] = NelderMead(Coord2Dl, Coord2Dp, Matrix0, VecP);

% Метод Нелдера-Мида с несколькими начальными точками
 [VecPInv, VecPBest, EVecBest] = MultiNelderMead(Coord2Dl, Coord2Dp, Matrix0, VecP);

% Для трассировки перевод радиан в градусы
VecPBest(4:6,:) = (180/pi)*VecPBest(4:6,:);

%--------------------------------------------------------------------------
% Расчёт 3d координат и вывод R и T

TInv = [VecPInv(1), VecPInv(2), VecPInv(3)];

RInv = Eiler(VecPInv(4), VecPInv(5), VecPInv(6));

RTn = [RInv TInv'];

MatrixP = Matrix0*RTn;

% Определение 3d координат точек
CInv = TriangulationCustom(Coord2Dl, Coord2Dp, MatrixL, MatrixP);

% Добавление четвёртого столбца из единиц
CInv = [CInv One];

% Инициализация 2d координат на изображении
Coord2Dln = zeros(N,3);
Coord2Dpn = zeros(N,3);

% Транспонирование для умножения
CInv = CInv';

for n = 1:N
    Coord2Dln(n,:) = MatrixL*CInv(:,n);
    Coord2Dpn(n,:) = MatrixP*CInv(:,n);
    Coord2Dln(n,:) = Coord2Dln(n,:)/Coord2Dln(n,3);
    Coord2Dpn(n,:) = Coord2Dpn(n,:)/Coord2Dpn(n,3);
end

% Подсчёт конечной ошибки репроекции
EInv = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);

% Транспонирование и удаление последнего столбца единиц для выводы и
% расчёта СКО, выраженного в мм
CInv = CInv';
CInv = CInv(:,1:3);

dCInv = 0; % СКО репроекции в мм

for n = 1:N
    dCInv = (CInv(n,1) - Coord3D(n,1))^(2) + (CInv(n,2) - Coord3D(n,2))^(2) + (CInv(n,3) - Coord3D(n,3))^(2);
end

dCInv = sqrt(dCInv/N);

% Расчёт углов Эйлера для сравнения результатов
% Полуенный углы
AngleInv = [VecPInv(4), VecPInv(5), VecPInv(6)]*(180/pi);

% Исходные углы (без внесённого смещения)
[headingP, attitudeP, bankP] = Decomposition(Rp);
AngleP = [headingP, attitudeP, bankP]*(180/pi);

end

