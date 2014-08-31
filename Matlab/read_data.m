function [C1, C2, C3, C4, C5] = read_data(file_name)

eval(['load ' num2str(file_name) '.txt'])
eval(['C1 = ' num2str(file_name) '(:,1) ;'])
eval(['C2 = ' num2str(file_name) '(:,2) ;'])
eval(['C3 = ' num2str(file_name) '(:,3) ;'])
eval(['C4 = ' num2str(file_name) '(:,4) ;'])
eval(['C5 = ' num2str(file_name) '(:,5) ;'])