function [VecPInv, Iters, VecP, EVec, PM] = NelderMead(Coord2Dl, Coord2Dp, Matrix0, VecP0)
% Размерность задачи
N = 6;

% Условия сходимости
DeltaE = 10^(-6); % Стандартное отклонение ошибки
DeltaT = 0.05; % Длина ребра по оси смещения
DeltaR = 0.005*pi/180; % Длина ребра по оси поворота

% Инизиализация вершин симплекса
VecP = zeros(N,N+1);

% Число итераций и счётчик
ItersMax = 500;
Iters = 0;

% Инициализация вектора ошибки вершин симплекса
EVec = zeros(N+1,1);

% Инициализация числа сжатий симплекса
PM = 0;
%--------------------------------------------------------------------------
% Формирование симплекса
%--------------------------------------------------------------------------
% Метод №1

% Начальная точка
VecP(:,1) = VecP0;

% Длина рёбер симплекса
stepT = 0.5;
stepR = 0.05*pi/180;

% Расчёт смещений относительно начальной точки
d1T = stepT*(sqrt(N+1) - 1)/(N*sqrt(2));
d2T = stepT*(sqrt(N+1) + N - 1)/(N*sqrt(2));

d1R = stepR*(sqrt(N+1) - 1)/(N*sqrt(2));
d2R = stepR*(sqrt(N+1) + N - 1)/(N*sqrt(2));

for i = 2:(N+1)
    for j = 1:3
        if (i ~= j)
            VecP(j,i) = VecP0(j) + d1T;
        else
            VecP(j,i) = VecP0(j) + d2T;
        end
    end
    
    for j = 4:6
        if (i ~= j)
            VecP(j,i) = VecP0(j) + d1R;
        else
            VecP(j,i) = VecP0(j) + d2R;
        end
    end
end
%--------------------------------------------------------------------------
% % Метод №2
% 
% % Начальная точка
% VecP(:,1) = VecP0;
% 
% % Смещения относительно центральной точки
% stepT = 0.5;
% stepR = 0.05*pi/180;
% 
% % Инициализация базиса пространства
% S = eye(N);
% 
% % Уножение соотвествующих направлений на их шаг
% S = [stepT*S(1:3,:); stepR*S(4:6,:)];
% 
% for i = 2:(N+1)
%     VecP(:,i) = VecP0(:,i) + stepT*S(:,i-1);
% end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Коэффициент отражения
alfa = 1.0;

% Коэффициент сжатия
betta = 0.5;

% Коэффициент растяжения
gamma = 2.0;

% Опредление величины ошибки в вершинах
for i = 1:(N+1)
    [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecP(:,i), Matrix0, Coord2Dl, Coord2Dp);
    EVec(i) = ReprojectionErrorMod(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn, VecP0, VecP(:,i));
end

for k = 1:ItersMax
    
    % Индекс точки с наибольшим значением ошибки
    [~,h] = max(EVec);
    
    % Поиск точки с следующей после максимальной ошибки
    EVec(h) = 0;
    
    [~,g] = max(EVec);
    
    % Возвращение вектора ошибки в исходное состояние
    [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecP(:,h), Matrix0, Coord2Dl, Coord2Dp);
    EVec(h) = ReprojectionErrorMod(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn, VecP0, VecP(:,h));
    
    % Индекс точки с наименьшим значением ошибки
    [~,l] = min(EVec);
    
    % Расчёт центра тяжести за исключением h
    VecPO = zeros(N,1);
    
    for i = 1:(N+1)
        if (i ~= h)
            VecPO = VecPO + VecP(:,i);
        end
    end
    
    VecPO = (1/N)*VecPO;
    
%     % Величина ошибки в центре тяжести
%     [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecPO, Matrix0, Coord2Dl, Coord2Dp);
%     EO = ReprojectionErrorMod(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn, VecP0, VecPO);
    
    % Отражение точки с худшим значением
    VecPR = (1+alfa)*VecPO - alfa*VecP(:,h);
    
    % Величина ошибки в отражённой точки
    [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecPR, Matrix0, Coord2Dl, Coord2Dp);
    ER = ReprojectionErrorMod(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn, VecP0, VecPR);
    
    % Сравним R и l
    
    % Если точка лучшая, то растягиваем и считаем ошибку
    if (ER < EVec(l))
        VecPE = gamma*VecPR + (1-gamma)*VecPO;
        
        [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecPE, Matrix0, Coord2Dl, Coord2Dp);
        EE = ReprojectionErrorMod(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn, VecP0, VecPE);
        
        % Сравним E и l
        
        % Если точка лучшая, то заменяем худшую точку
        if (EE < EVec(l))
            VecP(:,h) = VecPE;
            EVec(h) = EE;
            % Дальше проверка на сходимость--------------------------------
        else
            % (EE > EVec(l)). Отбрасываем точке E
            % И заменяем худшую точку на R
            VecP(:,h) = VecPR;
            EVec(h) = ER;
            % Дальше проверка на сходимость--------------------------------
        end
    else
        % (ER > EVec(l))
        
        % Но лучше g, т.е. лучше двух точек симплекса
        if (ER < EVec(g))
            VecP(:,h) = VecPR;
            EVec(h) = ER;
            % Дальше проверка на сходимость--------------------------------
        else
            % (ER > EVec(g))
            
            % То сравниваем R и h
            
            % Если больше, то сжимаем точку и считаем ошибку
            if(ER > EVec(h))
                VecPC = betta*VecP(:,h) + (1-betta)*VecPO;
                [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecPC, Matrix0, Coord2Dl, Coord2Dp);
                EC = ReprojectionErrorMod(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn, VecP0, VecPC);
            else
                % (ER < EVec(h))
                % Заменяем на R, производим сжатие и считаем ошибку
                VecP(:,h) = VecPR;
                VecPC = betta*VecPR + (1-betta)*VecPO;
                [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecPC, Matrix0, Coord2Dl, Coord2Dp);
                EC = ReprojectionErrorMod(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn, VecP0, VecPC);
            end
            
            % Сравниваем С и h
            
            % Если С меньше h, то заменяем
            if (EC < EVec(h))
                VecP(:,h) = VecPC;
                EVec(h) = EC;
                % Дальше проверка на сходимость----------------------------
            else
                % (EC > EVec(h))
                % То сжимаем симплекс к точке с минимальным значением ошибки
                VecP(:,i) = VecP(:,l) + 0.5*(VecP(:,i) - VecP(:,l));
                
                for i = 1:(N+1)
                    [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecP(:,i), Matrix0, Coord2Dl, Coord2Dp);
                    EVec(i) = ReprojectionErrorMod(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn, VecP0, VecP(:,i));
                end
                % Дальше проверка на сходимость----------------------------
                PM = PM + 1;
            end
        end
    end
    
    % Проверка на сходимость по двум критериям
    flagS = 1;
    
    % Расчёт стандартного отклонения функции ошибки
    % Среднее значение ошибки
    Emean = 0;
    
    for i = 1:(N+1)
        Emean = Emean + EVec(i);
    end
    
    Emean = (1/(N+1))*Emean;
    
    % Стандартное отклонение
    Sigma = 0;
    
    for i = 1:(N+1)
        Sigma = Sigma + (EVec(i) - Emean)^(2);
    end
    
    Sigma = sqrt(Sigma/(N+1));
    
    % Проверка на допустимость значения
    if (Sigma > DeltaE)
        flagS = 0;
    end
    
    % Расчёт длин рёбер симплекса относительно лучшей точки
    if (flagS == 1)
        
        dm = zeros(N,N+1);

        for i = 1:(N+1)
            % Расстояние между вершинами симплекса
            dm(:,i) = VecP(:,i) - VecP(:,l);

            % Провека на превышение размера ребра по оси смещения
            for j = 1:3
                if (abs(dm(j,i)) > DeltaT)
                    flagS = 0;
                    break
                end
            end

            % Если превысили, то прервать
            if (flagS == 0)
                break
            end

            % Провека на превышение размера ребра по оси поворота
            for j = 4:6
                if (abs(dm(j,i)) > DeltaR)
                    flagS = 0;
                    break
                end
            end

            % Если превысили, то прервать
            if (flagS == 0)
                break
            end
        end
    end
    
    % Выходим из цикла, т.к. выполнена сходимость
    if (flagS == 1)
        break
    end
    
    Iters = Iters + 1;
end

[~,l] = min(EVec);
VecPInv = VecP(:,l);

end
