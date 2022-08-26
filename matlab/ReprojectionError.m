function [Error] = ReprojectionError(Coord2Dl, Coord2Dp, Coord2Dln, Coord2Dpn)

% Подсчёт ошибки репроекции

N = size(Coord2Dl, 1);
Error = 0;

for n = 1:N
    Error = Error + (Coord2Dl(n,1) - Coord2Dln(n,1))^(2) + (Coord2Dp(n,2) - Coord2Dpn(n,2))^(2);
end

Error = sqrt(Error/N);


% Опредление ошибки репроекции из максимума значения

% % Подсчёт ошибки репроекции
% 
% N = size(Coord2Dl, 1);
% ErrorVec = zeros(N,1);
% 
% for n = 1:N
%     ErrorVec(n) = abs(Coord2Dl(n,1) - Coord2Dln(n,1)) + abs(Coord2Dp(n,2) - Coord2Dpn(n,2));
% end
% 
% Error = max(ErrorVec);


end

