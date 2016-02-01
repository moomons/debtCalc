
% A program to calculate the debt relationship
%
% Coded by mons, 09/05/2015 in Sydney and on the CZ 302 aircraft

% input line: creditor, debtor, amount
% read file dlmread debt_out.txt

clear

% NameToNum = {
% }

NumOfPeople = 7;

Option_Optim3 = 1;
Option_Draw = 0;
Option_WriteDlm = 1;

% plot a directed graph using a different color and linestyle
n = NumOfPeople;
t = 2*pi/n*(0:n-1);
xy = [cos(t); sin(t); t]'; % coordinate of the points
xy(:,3)= 1:NumOfPeople;


% A = round(10*rand(n)); % adjacency matrix A
% Get the adjacency matrix A by parsing the input line by line

AUD = zeros(NumOfPeople);
% input = dlmread('debt_out_AUD.txt', '\t');
% for i = 1 : size(input,1)
%     creditor = int8(input(i, 1));
%     amount = input(i, 2);
%     debtor = int8(input(i, 3));
%     AUD(creditor, debtor) = AUD(creditor, debtor) + amount;
% end

CNY = zeros(NumOfPeople);
input = dlmread('debtParse_output_CNY.txt', '\t');
for i = 1 : size(input,1)
    creditor = int8(input(i, 1));
    amount = input(i, 2);
    debtor = int8(input(i, 3));
    CNY(creditor, debtor) = CNY(creditor, debtor) + amount;
end

A = AUD * 4.6 + CNY;

% A = [
%     0, 0, 50, 0, 0, 0, 0, 0, 0;
%     20, 0, 0, 0, 0, 0, 0, 0, 0;
%     0, 0, 0, 0, 0, 0, 0, 0, 0;
%     0, 0, 0, 0, 0, 0, 0, 0, 0;
%     0, 0, 0, 0, 0, 0, 0, 0, 0;
%     0, 0, 0, 0, 0, 0, 0, 0, 0;
%     0, 0, 0, 0, 0, 0, 0, 0, 0;
%     0, 0, 0, 0, 0, 0, 0, 0, 0;
%     0, 0, 0, 0, 0, 0, 0, 0, 0
%     ];


% TODO: Load CNY here and add to the matrix

% Optim 1
% A-(60)->A == A-(0)->A
for i = 1 : NumOfPeople
    A(i, i) = 0.0;
end

% Optim 2
% A-(100)->B and B-(60)->A == A-(40)->B
for i = 2 : NumOfPeople % Row
    for j = 1 : i-1 % Col
        if A(i, j) * A(j, i) ~= 0
            if A(i, j) > A(j, i)
                A(i, j) = A(i, j) - A(j, i);
                A(j, i) = 0.0;
            else
                A(j, i) = A(j, i) - A(i, j);
                A(i, j) = 0.0;
            end
        end
    end
end

% Optim 3
if Option_Optim3
Last_A = zeros(NumOfPeople);
while(sum(sum(A)) ~= sum(sum(Last_A)))
    Last_A = A;
    for i = 1 : NumOfPeople
        for j = 1 : NumOfPeople
            if i == j || A(i, j) == 0.0
                continue
            end

            NonZeroEntry = find(A(j, :) ~= 0); % ³¢ÊÔÑ°ÕÒ A->B->C µÄ¹ØÏµ
            for k = 1 : length(NonZeroEntry)
                index = NonZeroEntry(k);
                if A(i, j) >= A(j, index)
                    % A-(100)->B-(60)->C == A-(40)->B and A-(+60)->C and B-(0)->C
                    First_New = A(i, j) - A(j, index);
                    Second_New = A(i, index) + A(j, index);
                    A(j, index) = 0.0;
                    A(i, j) = First_New;
                    A(i, index) = Second_New;
                else
                    % A-(60)->B-(100)->C == A-(+60)->C and B-(40)->C and A-(0)->B
                    First_New = A(i, index) + A(i, j);
                    Second_New = A(j, index) - A(i, j);
                    A(i, j) = 0.0;
                    A(i, index) = First_New;
                    A(j, index) = Second_New;
                end
%                 if A(i, j) == 0
%                     break
%                 end
            end
        end
    end
%     A
end
end

A = round(A)

if Option_Draw
    gplotdc_my(A, xy, 'Color', [0.6 0.6 0.6], 'LineStyle', '--');
    title('AUD')
end

if Option_WriteDlm
    dlmwrite('debtCalc_FinalMatrix.txt', A, '\t')
end
