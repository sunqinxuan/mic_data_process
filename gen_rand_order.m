numbers = 1:10;         % 创建1到10的数组
shuffled_numbers = numbers(randperm(length(numbers)));  % 对数组进行随机排序
disp(shuffled_numbers);  % 显示结果
