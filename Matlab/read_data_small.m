function [C1, C2, C3] = read_data_small(file_name)

eval(['load ' num2str(file_name) '.txt'])
eval(['C1 = ' num2str(file_name) '(:,1) ;'])
eval(['C2 = ' num2str(file_name) '(:,2) ;'])
eval(['C3 = ' num2str(file_name) '(:,3) ;'])