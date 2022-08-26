function [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecP, Matrix0, Coord2Dl, Coord2Dp)

% Подсчёт числа точек
N = size(Coord2Dl,1);

% Запись вектора смещения
Tn = [VecP(1), VecP(2), VecP(3)];

% Запись матрицы поворота
heading = VecP(4);
attitude = VecP(5);
bank = VecP(6);

Rn = Eiler(heading, attitude, bank);

% Формирование калибровочной матрицы первой камеры
Rl = [1, 0, 0;
      0, 1, 0;
      0, 0, 1];
   
Tl = [0, 0, 0];

RTl = [Rl Tl'];

MatrixL = Matrix0*RTl;

% Формирование калибровочной матрицы второй камеры
RTn = [Rn Tn'];

MatrixP = Matrix0*RTn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Здесть можно дополнить дисторсией, как Xcorect = X*(1+k1r^(2)...)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Определение 3d координат точек
C = TriangulationCustom(Coord2Dl, Coord2Dp, MatrixL, MatrixP);

% Добавление четвёртого столбца из единиц
One = zeros(N,1);

for n = 1:N
    One(n) = 1;
end

C = [C One];

% Инициализация 2d координат на изображении
Coord2Dln = zeros(N,3);
Coord2Dpn = zeros(N,3);

% Транспонирование для умножения
C = C';

% Расчёт новых 2d координат
for n = 1:N
    Coord2Dln(n,:) = MatrixL*C(:,n);
    Coord2Dpn(n,:) = MatrixP*C(:,n);
    Coord2Dln(n,:) = Coord2Dln(n,:)/Coord2Dln(n,3);
    Coord2Dpn(n,:) = Coord2Dpn(n,:)/Coord2Dpn(n,3);
end

end

