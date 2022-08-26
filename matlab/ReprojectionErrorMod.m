function [Error] = ReprojectionErrorMod(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn, VecP0, VecP)

% Подсчёт ошибки репроекции

N = size(Coord2Dl, 1);
Error = 0;

for n = 1:N
    Error = Error + (Coord2Dl(n,1) - Coord2Dln(n,1))^(2) + (Coord2Dp(n,2) - Coord2Dpn(n,2))^(2);
end

Error = sqrt(Error/N);

% Проверка на границы параметров. Метод штрафных функций
Tmax = 10;
Rmax = 2*pi/180;

for j = 1:3
    if (abs(VecP(j) - VecP0(j)) > Tmax)
        Error = Error + 10000;
    end
end

for j = 4:6
    if (abs(VecP(j) - VecP0(j)) > Rmax)
        Error = Error + 10000;
    end
end

end

