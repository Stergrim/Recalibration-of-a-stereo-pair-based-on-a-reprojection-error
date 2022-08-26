function [E0, dC, Coord3D, C0] = GraphicsError(Matrix0, Rp, Tp, Number, Value)

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
          
% Tp = [-315, 115, 40];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Формирование набора точек соотвествующие прямоугольной обласи крыла
Coord3D = WingPattern(1500, 300, 200, 45, 30, 20);

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

% Для вывода положения исходных точек 3D пространстве 
Coord3D = Coord3D';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Вывод проекции 3D точек на камеры
for n = 1:N
    subplot(2,2,3)
    plot(Coord2Dl(n,1), Coord2Dl(n,2),'*');
    xlim([0 2500])
    ylim([0 1960])
    hold on
    grid on
    title('Изображение левой камеры');
    xlabel('Координаты в пикселях');
    ylabel('Координаты в пикселях');
    subplot(2,2,4)
    plot(Coord2Dp(n,1), Coord2Dp(n,2),'*');
    xlim([0 2500])
    ylim([0 1960])
    hold on
    grid on
    title('Изображение правой камеры');
    xlabel('Координаты в пикселях');
    ylabel('Координаты в пикселях');
end

% Вывод положения исходных 3D точек
subplot(2,2,1:2)
plot3(Coord3D(:,3), Coord3D(:,1), Coord3D(:,2), '*');
grid on
title('Объект измерения');
xlabel('Координаты в мм');
ylabel('Координаты в мм');
zlabel('Координаты в мм');

% Пауза для просмотра графиков. Снимается нажатием на любую кнопку
pause('on');
pause;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Выше смоделировано получение(двух изображений) 2d координат точек с двух
% камер для последующей перекалибровки. Также записаны исходные
% калибровочные матрицы камер.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Внесение искажений

% Определения начальных углов Эйлера
[heading0, attitude0, bank0] = Decomposition(Rp);
% y, z, x.
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

if (Number == 5)
    heading0 = heading0 + Value*pi/180;
end

% Number = 5 соотвествует повороту Attitude. Value в абсолютный
% значения в градусах

if (Number == 6)
    attitude0 = attitude0 + Value*pi/180;
end

% Number = 6 соотвествует повороту Bank. Value в абсолютный
% значения в градусах

if (Number == 4)
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


if (Number == 8)
    Tn(1) = Value(1);% + Tn(1);
    Tn(2) = Value(2);% + Tn(2);
    Tn(3) = Value(3);% + Tn(3);
    heading0 = Value(4)*pi/180;% + heading0;
    attitude0 = Value(5)*pi/180;% + attitude0;
    bank0 = Value(6)*pi/180;% + bank0;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Вывод исходных 3D точек и востановленных с внесёнными искажениями
subplot(2,1,1)
plot3(Coord3D(:,1), Coord3D(:,2), Coord3D(:,3), '*');
grid on

subplot(2,1,2)
plot3(C0(:,1), C0(:,2), C0(:,3), '*');
grid on

% Пауза для просмотра графиков. Снимается нажатием на любую кнопку
pause('on');
pause;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Транспонирование для умножения
Coord3D = Coord3D';
% Инициализация 2d координат на изображении
Coord2Dln = zeros(N,3);
Coord2Dpn = zeros(N,3);

for n = 1:N
    Coord2Dln(n,:) = MatrixL*Coord3D(:,n);
    Coord2Dpn(n,:) = MatrixP*Coord3D(:,n);
    Coord2Dln(n,:) = Coord2Dln(n,:)/Coord2Dln(n,3);
    Coord2Dpn(n,:) = Coord2Dpn(n,:)/Coord2Dpn(n,3);
end

% Транспонирование для вывода
Coord3D = Coord3D';
Coord3D = Coord3D(:,1:3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Вывод проекции 3D точек на камеры
for n = 1:N
    subplot(2,2,1)
    plot(Coord2Dl(n,1), Coord2Dl(n,2),'*');
    grid on
    hold on
    subplot(2,2,2)
    plot(Coord2Dp(n,1), Coord2Dp(n,2),'*');
    grid on
    hold on
end

% Вывод проекции 3D точек на камеры с искажением
for n = 1:N
    subplot(2,2,3)
    plot(Coord2Dln(n,1), Coord2Dln(n,2),'*');
    grid on
    hold on
    subplot(2,2,4)
    plot(Coord2Dpn(n,1), Coord2Dpn(n,2),'*');
    grid on
    hold on
end

pause('on');
pause;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

dC = 0; % СКО репроекции в мм

for n = 1:N
    dC = (C0(n,1) - Coord3D(n,1))^(2) + (C0(n,2) - Coord3D(n,2))^(2) + (C0(n,3) - Coord3D(n,3))^(2);
end

dC = sqrt(dC/N);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Расчёт зависимости ошибки от смещения

% Диапазон смещений
Delta = 10;

% Шаг смещения
step = 1;

% Число точек
K = 2*Delta/step + 1;

% Ошибка по оси х
EVecX = zeros(K,1);

for k = 1:K
    Tn(1) = Tp(1) - Delta + step*(k-1);
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
    
    EVecX(k) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
end

% Возвращения значения смещения в исходное состояние
Tn(1) = Tp(1);

% Ошибка по оси y
EVecY = zeros(K,1);

for k = 1:K
    Tn(2) = Tp(2) - Delta + step*(k-1);
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
    
    EVecY(k) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
end

% Возвращения значения смещения в исходное состояние
Tn(2) = Tp(2);

% Ошибка по оси z
EVecZ = zeros(K,1);

for k = 1:K
    Tn(3) = Tp(3) - Delta + step*(k-1);
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
    
    EVecZ(k) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
end

% Возвращения значения смещения в исходное состояние
Tn(3) = Tp(3);

% Определение оси смещения с центральным значением равным величине
% начального смещения

sx = zeros(K,1);
sy = zeros(K,1);
sz = zeros(K,1);

for k = 1:K
    sx(k) = -Delta + step*(k-1) + Tp(1);
    sy(k) = -Delta + step*(k-1) + Tp(2);
    sz(k) = -Delta + step*(k-1) + Tp(3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Расчёт зависимости ошибки от поворота

% Диапазон смещений
Delta = 2;

% Шаг смещения
step = 0.1;

% Число точек
K = 2*Delta/step + 1;

% Ошибка поворота Heading
EVecHeading = zeros(K,1);


for k = 1:K
    heading = heading0*180/pi - Delta + step*(k-1);
    heading = heading*pi/180;
    Rn = Eiler(heading, attitude0, bank0);
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
    
    EVecHeading(k) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
end

% Ошибка поворота attitude
EVecAttitude = zeros(K,1);

for k = 1:K
    attitude = attitude0*180/pi - Delta + step*(k-1);
    attitude = attitude*pi/180;
    Rn = Eiler(heading0, attitude, bank0);
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
    
    EVecAttitude(k) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
end

% Ошибка поворота Bank
EVecBank = zeros(K,1);

for k = 1:K
    bank = bank0*180/pi - Delta + step*(k-1);
    bank = bank*pi/180;
    Rn = Eiler(heading0, attitude0, bank);
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
    
    EVecBank(k) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
end

% Определение оси смещения с центральным значением равным величине
% начального поворота

sh = zeros(K,1);
sa = zeros(K,1);
sb = zeros(K,1);

for k = 1:K
    sh(k) = -Delta + step*(k-1) + heading0*180/pi;
    sa(k) = -Delta + step*(k-1) + attitude0*180/pi;
    sb(k) = -Delta + step*(k-1) + bank0*180/pi;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Вывод полученных зависимостей

% Смещение

% subplot(2,3,1)
% plot(sx,EVecX,'blue');
% xlim([min(sx) max(sx)])
% ylim([min(EVecX) max(EVecX)])
% grid on;
% title('Ошибка от смещения по оси x');
% xlabel('Смещение в мм');
% ylabel('СКО в пикселях');
% 
% subplot(2,3,2)
% plot(sy,EVecY,'blue');
% xlim([min(sy) max(sy)])
% ylim([min(EVecY) max(EVecY)])
% grid on;
% title('Ошибка от смещения по оси y');
% xlabel('Смещение в мм');
% ylabel('СКО в пикселях');
% 
% subplot(2,3,3)
% plot(sz,EVecZ,'blue');
% xlim([min(sz) max(sz)])
% ylim([min(EVecZ) max(EVecZ)])
% grid on;
% title('Ошибка от смещения по оси z');
% xlabel('Смещение в мм');
% ylabel('СКО в пикселях');
% 
% 
% % Поворот
% 
% subplot(2,3,5)
% plot(sh,EVecHeading,'blue');
% xlim([min(sh) max(sh)])
% ylim([min(EVecHeading) max(EVecHeading)])
% grid on;
% title('Ошибка поворота вокруг оси y');
% xlabel('Смещение в град');
% ylabel('СКО в пикселях');
% 
% subplot(2,3,6)
% plot(sa,EVecAttitude,'blue');
% xlim([min(sa) max(sa)])
% ylim([min(EVecAttitude) max(EVecAttitude)])
% grid on;
% title('Ошибка поворота вокруг оси z');
% xlabel('Смещение в град');
% ylabel('СКО в пикселях');
% 
% subplot(2,3,4)
% plot(sb,EVecBank,'blue');
% xlim([min(sb) max(sb)])
% ylim([min(EVecBank) max(EVecBank)])
% grid on;
% title('Ошибка поворота вокруг оси x');
% xlabel('Смещение в град');
% ylabel('СКО в пикселях');

subplot(2,3,1)
plot(sx,EVecX,'blue');
xlim([min(sx) max(sx)])
ylim([min(EVecX) max(EVecX)])
grid on;
title('Error from offset along x-axis');
xlabel('Offset in mm');
ylabel('MSE in pixels');

subplot(2,3,2)
plot(sy,EVecY,'blue');
xlim([min(sy) max(sy)])
ylim([min(EVecY) max(EVecY)])
grid on;
title('Error from offset along y-axis');
xlabel('Offset in mm');
ylabel('MSE in pixels');

subplot(2,3,3)
plot(sz,EVecZ,'blue');
xlim([min(sz) max(sz)])
ylim([min(EVecZ) max(EVecZ)])
grid on;
title('Error from offset along z-axis');
xlabel('Offset in mm');
ylabel('MSE in pixels');


% Поворот

subplot(2,3,5)
plot(sh,EVecHeading,'blue');
xlim([min(sh) max(sh)])
ylim([min(EVecHeading) max(EVecHeading)])
grid on;
title('Error from rotation around the y-axis');
xlabel('Offset in degrees');
ylabel('MSE in pixels');

subplot(2,3,6)
plot(sa,EVecAttitude,'blue');
xlim([min(sa) max(sa)])
ylim([min(EVecAttitude) max(EVecAttitude)])
grid on;
title('Error from rotation around the z-axis');
xlabel('Offset in degrees');
ylabel('MSE in pixels');

subplot(2,3,4)
plot(sb,EVecBank,'blue');
xlim([min(sb) max(sb)])
ylim([min(EVecBank) max(EVecBank)])
grid on;
title('Error from rotation around the x-axis');
xlabel('Offset in degrees');
ylabel('MSE in pixels');

end

