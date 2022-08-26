function [points3d] = TriangulationCustom(points1, points2, camMatrix1, camMatrix2)

% Транспонирование входных точек
points1 = points1';
points2 = points2';

% Опредление числа точек
numPoints = size(points1, 2);

% Инициализация массива 3d точек
points3d = zeros(numPoints, 3);

% Масштабируемая матрица
scaleMatrix = [repmat(camMatrix1(3,:), 2, 1); repmat(camMatrix2(3,:), 2, 1)];

% Вычитающая матрица
subtractMatrix = [camMatrix1(1:2,:); camMatrix2(1:2,:)];

% Определение входных точек для svd разложения
inputPoints = [points1; points2];
inputPoints = repmat(inputPoints(:), 1, 4);
inputPoints = (inputPoints .* repmat(scaleMatrix, numPoints, 1)) - repmat(subtractMatrix, numPoints, 1);

% Расчёт 3d точек через svd разложение
for i = 1:numPoints
    points3d(i,:) = compute3dPoint(inputPoints((i-1)*4 + 1:i*4, :));
end

end

%--------------------------------------------------------------------------
function point3d = compute3dPoint(A)
[~,~,V] = svd(A);
X = V(:, end);
X = X/X(end);

point3d = X(1:3)';

end