%import boundary data:
[G, P1 U1 P2 U2] = read_data('Collected_Data');
[O, PO, UO] = read_data_small('Ostersund_data');

% for i=1:length(P1)
%     if G(i)==20041211;
%         d = i;
%     end
% end

%P1 = Ekofisk pressure
%U1 = Ekofisk wind speed
%P2 = Sodankyla pressure
%U2 = Sodankyla wind speed

%max time
Nt = length(P1);
dt = 0.01;

%distance from Ekofisk to Sodankyla (km)
L = 1700*10^3;

%space discretization: 10 km
dx = 10*10^3;
x = 0:dx:L-1;

%number of cells
n = L/dx;

%check smoothness of boundary data:
% T = 1:1:Nt;
% plot(T,P1)

%create averages
p10 = mean(P1);
p20 = mean(P2);
p0 = (p10+p20)/2;
% p0 = 1.4;
display('Average pressure (Pa), tropopause (altitude ca 10km)')
display(p0)
u10 = mean(U1);
u20 = mean(U2);
u0 = (u10+u20)/2;
% u0 = 0.1;
display('Average wind (m/s), tropopause (altitude ca 10km)')
display(u0)
rho0 = 0.4135;
% rho0 = 0.001;
display('Average air density (kg/m^3), tropopause (altitude ca 10km)')
display(rho0)

%coefficient matrix (set gamma = 1)
A = zeros(3);
A(1,1) = u0;
A(1,2) = rho0;
A(2,2) = u0;
A(2,3) = 1/rho0;
A(3,2) = p0;
A(3,3) = u0;

%summation by parts operator
e = ones(n,1);
P = dx*diag(e);
P(1,1) = 0.5*P(1,1);
P(n,n) = 0.5*P(n,n);
I = eye(3);
Pinv = kron(inv(P), I);
D = spdiags([-e 0*e e], -1:1, n,n);
D(1,1) = -2;
D(1,2) = 2;
D(n,n) = 2;
D(n, n-1)=-2;
D = D./(2*dx);

%indikator:
IO1=zeros(3*n);
IOn=zeros(3*n);
IO1(1,1)=1;
IO1(2,2)=1;
IO1(3,3)=1;
IOn(3*n-2,3*n-2)=1;
IOn(3*n-1,3*n-1)=1;
IOn(3*n,3*n)=1;
IO1s = sparse(IO1);
IOns = sparse(IOn);

%eigenvalues
[X,E]=eig(A); 
display(X)
display(E)
In = eye(n);
Xinv = kron(inv(X), In);
Xinvs = sparse(Xinv);
Xk = kron(X, In);
Ek = kron(E, In);
Xks = sparse(Xk);
Eks = sparse(Ek);

%preallocate
u = zeros(1,n);
p = zeros(1,n);
for i=1:n
   u(i) = 0.5*(U1(i)+U2(i));
   p(i) = 0.5*(P1(i)+P2(i));

end
% p = p0*ones(1,n);
rho = rho0*ones(1,n);

%matrix with rho, u, p as ROWS
%initial values
W = [rho;u;p];

%the "long" vectors
%initial values (averages)
U = reshape(W,3*n,1);
Ak = kron(D,A);
Aks = sparse(Ak);

%preallocate
t=0;
U_old = U;
U_data = zeros(3*n,1);


%update:
for t=1:Nt 
    
    %Boundary Data, non-smooth:
    U_data(1) = rho0;
    U_data(2) = U1(t);
    U_data(3) = P1(t);
    U_data(3*n-2) = rho0;
    U_data(3*n-1) = U2(t);
    U_data(3*n) = P2(t);

    %Boundary Data, smooth:
%     U_data(1) = rho0;
%     U_data(2) = u0*sin(t);
%     U_data(3) = p0;
%     U_data(3*n-2) = rho0;
%     U_data(3*n-1) = u0*sin(t);
%     U_data(3*n) = p0;
    
    %Simultaneous Approximation Term
    SAT1 = Pinv*IO1s*Xinvs*E(2,2)*Xks*(U_old-U_data);
    SATn = Pinv*IOns*Xinvs*E(3,3)*Xks*(U_old-U_data);
    
    U_new = dt*(-Aks*U_old - SAT1 + SATn) + U_old;
  
    %show plots:
    U_old = U_new;
    U_show = reshape(U_new,3,n)';
    
    
%     subplot(3,1,1)
%     plot(x,U_show(:,2))
%     axis([0 L -70 70])
%     xlabel('distance (km)')
%     ylabel('wind speed (m/s)')
%     title('wind speed')
    
%     subplot(3,1,2)
%     plot(x,U_show(:,3))
%     axis([0 L 13000 45000])
%     xlabel('distance (km)')
%     ylabel('pressure (Pa)')
%     title('pressure')
    
%     subplot(3,1,3)
%     plot(x,U_show(:,1))
%     axis([0 L 0.4 0.43])
%     title('density')
%     xlabel('distance (km)')
%     ylabel('density (kg/m^3)')
%     pause(0.1);

%     plot(U_show(:,3),U_show(:,2))
%     axis([2*10^4 3.2*10^4 -30 30])
%     pause(0.1)

end


% display('value for date:')
% display(G(d))
% display('value at midpoint:')
% display(U_show(85, 3))

