function [R] = Eiler(heading, attitude, bank)

% ‘ормирует матрицу поворота из углов Ёйлера

MHeading = [ cos(heading), 0,  sin(heading);
                 0, 1,       0;
           -sin(heading), 0,  cos(heading)];
       
MAttitude = [cos(attitude), -sin(attitude), 0;
             sin(attitude),  cos(attitude), 0;
                  0,       0, 1];

MBank = [1,      0,       0;
         0, cos(bank), -sin(bank);
         0, sin(bank),  cos(bank)];

R = MHeading*MAttitude*MBank;

end

