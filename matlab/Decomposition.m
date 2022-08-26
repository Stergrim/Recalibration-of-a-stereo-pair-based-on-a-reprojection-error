function [heading, attitude, bank] = Decomposition(R)

% Вычисляет углы из матрицы поворота

if (R(2,1) > 0.998) % singularity at north pole
    heading = ATan2(R(1,3), R(3,3));
    attitude = pi/2;
    bank = 0;
end

if (R(2,1) > -0.998) % singularity at south pole
    heading = ATan2(R(1,3), R(3,3));
    attitude = -pi/2;
    bank = 0;
end

heading = ATan2(-R(3,1), R(1,1));
attitude = asin(R(2,1));
bank = ATan2(-R(2,3), R(2,2));

end

function [tt] = ATan2(y, x)

% Функция аналогичная atan2(y, x) из С или Python
% Возвращаемые значения от -pi до pi, при нуле знаменателя выдаёт "0"

if (x > 0 && y >= 0)||(x > 0 && y <= 0)
    tt = atan(y/x);
elseif (x < 0 && y >= 0)
    tt = pi + atan(y/x);
elseif (x < 0 && y <= 0)
    tt = -pi + atan(y/x);
else
    tt = 0;
end
           
end

