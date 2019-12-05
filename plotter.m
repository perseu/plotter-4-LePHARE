% This program plots the .spec files from LePHARE.
% This was needed to plot the spectras with the upper limits.
%
% Created by: Joao Aguas

clear all;
close all;

colors = ['k','m','b','r','g'];

% Opens the file... Hopefully... The operator is a schmuck, so, exit(0)
inputfile = input('Input file: ', 's')

fid = fopen(inputfile,'r')
if fid == -1
    return
end

% Getting the data from the header.
buffer = fgets(fid);
buffer = fgets(fid);
buffer2 = sscanf(buffer,'%f');
gal_id=buffer2(1); zspec=buffer2(2); zphot=buffer2(3);
buffer = fgets(fid);
filterinfo = strsplit(buffer);
buffer = fgets(fid);
buffer2 = strsplit(buffer);
nfilters = str2num(buffer2{2});
buffer = fgets(fid);
buffer = fgets(fid);
buffer2 = strsplit(buffer);
pdfcount = str2num(buffer2{2});
buffer = fgets(fid);
solutions.header = strsplit(buffer);
buffer = fgets(fid);
for ii=1:6
    buffer2 = strsplit(buffer);
    solutions.head{ii}=buffer2{1}; solutions.soldata(ii,1) = ii;
    for aa=2:17
        solutions.soldata(ii,aa) = str2num(buffer2{aa});
    end
    buffer = fgets(fid);
end


% Getting the photometric data and the estimated SEDs.
% First the photometric points.

for ii=1:nfilters
    buffer2 = strsplit(buffer);
    for aa=2:8
        filters(ii,aa-1) = str2num(buffer2{aa});
    end
    buffer = fgets(fid);
end


% Getting the PDF for the main solution.

for ii=1:pdfcount
    buffer2 = strsplit(buffer);
    pdfdata(ii,1)= str2num(buffer2{2}); pdfdata(ii,2)= str2num(buffer2{3});
    buffer = fgets(fid);
end


% Getting SED solutions.

jj=1;

for ii=1:6
    if solutions.soldata(ii,2) ~= 0
        foundsol(ii)=solutions.soldata(ii,1); 
        for kk=1:solutions.soldata(ii,2)
            buffer2 = strsplit(buffer);
            solutions.sed(kk,1,ii) = str2num(buffer2{2}); solutions.sed(kk,2,ii) = str2num(buffer2{3});
            buffer = fgets(fid);
        end
        %jj = jj + 1;
    end
end


% Selection and detection of solutions in the spec file.

disp('The possible solutions and their assigned codes are: ')
disp('(1) GAL-1');
disp('(2) GAL-2');
disp('(3) GAL-FIR');
disp('(4) GAL-STOCH');
disp('(5) QSO');
disp('(6) STAR');
disp('The detected solutions were: ') ; disp(foundsol); disp(' ');
disp('Insert the SED choice inside bracket and separated by comma!')
disp('Example: [1,2,3]')
choice=input('Selection: ')


% Plotting the data. Finally!!! :)

figure(1)
hold on

set(gca, 'XScale', 'log');
set(gca, 'YDir', 'reverse');
xlabel('\lambda (\mum)');
ylabel('Mag');

sz=size(choice); sz=sz(2);

for ii=1:sz
    plot(solutions.sed(:,1,choice(ii)),solutions.sed(:,2,choice(ii)),colors(ii));
end

sz = size(filters); sz = sz(1);

for ii=1:sz
    if filters(ii,1) ~= -99
        if filters(ii,2) == -1
            scatter(filters(ii,3),filters(ii,1),'v','k');
        else
            scatter(filters(ii,3),filters(ii,1),'o','k');
            erry = [filters(ii,1)-filters(ii,2) filters(ii,1)+filters(ii,2)];
            xpos = [filters(ii,3) filters(ii,3)];
            point=plot(xpos,erry,'k'); point.LineWidth = 1;
        end
        err = [filters(ii,3)-filters(ii,4)/2 filters(ii,3)+filters(ii,4)/2];
        ypos = [filters(ii,1) filters(ii,1)];
        point=plot(err,ypos,'k'); point.LineWidth = 1;
    end
end

headerinfo = strcat('Id=',num2str(gal_id),', zspec=',num2str(zspec),', zphot=',num2str(zphot));

title(headerinfo);

% Checking the sizes... You know... sizes, weights... regular stuff. :-\
headsz = size(solutions.header); headsz = headsz(2);

% This next section composes the solutions information posted on the main
% plot.

for ii=2:headsz-1
    solutions.found{1,ii-1}=solutions.header(ii);
end

% Filling the important fields.

jj=2;
for ii=1:6
    if solutions.soldata(ii,2)~=0
        solutions.found{jj,1}= solutions.head(ii); 
        for kk=2:headsz-2
            solutions.found{jj,kk}=num2str(solutions.soldata(ii,kk));
        end
        jj=jj+1;
    end
end

% figure(2);
% hold on;



% Plots the PDF for the first solution

figure(3)
hold on

plot(pdfdata(:,1),pdfdata(:,2))
