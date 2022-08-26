function [Lam] = OneOptimization(Coord2Dl, Coord2Dp, Matrix0, VecP, S, VecP0, Tmax, Rmax)
% Одномерная оптимизация для расчёта множителя ламбда, с учётом ограничений
% поиска(условная оптимизация)

% Расширение диапазона для промежутоных расчётов
TmaxD = Tmax + (1/2)*Tmax;
RmaxD = Rmax + (1/2)*Rmax;

% Запись
VecP1 = VecP;

% Число итераций
Iters = 2;

% Множитель уменьшения диапазона
P = 2;

% Отклоение текущих параметров от исходных(заданных)
Delta = VecP - VecP0;

% Инициализация для величин определяющие номера ограничивающих границы
% параметров
Ratio1 = zeros(6,1);
Ratio2 = zeros(6,1);

% Число отрезков на которые разбивается диапазон (точек + 1)
N = 20;

% Инициализация вектора ошибки
EVec = zeros(N+1,1);

% Флаг для отслеживание исключений (S == 0)
flag1 = 1;

if (S == 0)
    flag1 = 0;
end

% Расчёт границ для диапазона изменения лямбда и шага ламбда
if (flag1 == 1)
    
    for i = 1:3
        Ratio1(i) = abs(S(i)*(TmaxD/(TmaxD - Delta(i))));
    end
    
    for i = 4:6
        Ratio1(i) = abs(S(i)*(RmaxD/(RmaxD - Delta(i))));
    end
    
    for i = 1:3
        Ratio2(i) = abs(S(i)*(TmaxD/(TmaxD + Delta(i))));
    end
    
    for i = 4:6
        Ratio2(i) = abs(S(i)*(RmaxD/(RmaxD + Delta(i))));
    end
    
    [~,imaxLam] = max(Ratio1);
    [~,iminLam] = max(Ratio2);
    
    if ((imaxLam > 0)&&(imaxLam <= 3))
        LamMax = (TmaxD - Delta(imaxLam))/S(imaxLam);
    elseif ((imaxLam > 3)&&(imaxLam <= 6))
        LamMax = (RmaxD - Delta(imaxLam))/S(imaxLam);
    end
    
    if ((iminLam > 0)&&(iminLam <= 3))
        LamMin = -(TmaxD + Delta(iminLam))/S(iminLam);
    elseif ((iminLam > 3)&&(iminLam <= 6))
        LamMin = -(RmaxD + Delta(iminLam))/S(iminLam);
    end
    
    LamStep = (LamMax - LamMin)/N;
end

% Основное тело одномерной оптимизации
for k = 1:Iters
    
    if (flag1 == 0)
        Lam = 0; 
        break
    end
    
    for t = 1:(N+1)
        VecP = VecP1 + (LamMin + LamStep*(t-1))*S;
        [Coord2Dln, Coord2Dpn] = GetNewCoord2D(VecP, Matrix0, Coord2Dl, Coord2Dp);
        EVec(t) = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn);
    end
    % Определение индекса минимальной ошибки
    [~,tmin] = min(EVec);
    % Запись соотвествующего множителя ламбда
    Lam = LamMin + LamStep*(tmin-1);
    
    Lam0 = (LamMax - LamMin)/2;
    
    if (Lam >= Lam0)
        LD = abs(LamMax - Lam);
    else
        LD = abs(LamMin - Lam);
    end
    
    LamMin = (Lam - LD)/P;
    LamMax = (Lam + LD)/P;
    LamStep = (LamMax - LamMin)/N;
end


end

