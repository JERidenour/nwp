%import boundary data:
[~, P1 U1 P2 U2] = read_data('Collected_Data');

%P1 = Ekofisk pressure
%U1 = Ekofisk wind speed
%P2 = Sodankyla pressure
%U2 = Sodankyla wind speed

%max time
Nt = length(P1);
dt = 10;
%distance from Ekofisk to Sodankyla (km)
L = 1700*10^3;
%space discretization: 10 km
dx = 10*10^3;
x = 1:dx:L;
%number of cells
n = L/dx;

%check smoothness of boundary data:
% T = 1:1:Nt;
% plot(T,P1)

%create averages
p10 = mean(P1);
p20 = mean(P2);
% p0 = (p10+p20)/2;
p0 = 1.4;
display('Average pressure (Pa), tropopause (altitude ca 10km)')
display(p0)
u10 = mean(U1);
u20 = mean(U2);
% u0 = (u10+u20)/2;
u0 = 0.1;
display('Average wind (m/s), tropopause (altitude ca 10km)')
display(u0)
% rho0 = 0.4135;
rho0 = 0.001;
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
rho = rho0*ones(1,n);
u = u0*ones(1,n);
for i =1:n
    u(i) = u(i)*(-1)^(round(rand(1)*100));
end
p = p0*ones(1,n);

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

rho_old = rho';
u_old = u';
p_old = p';

%update:
for t=1:10*Nt 
    
    %Boundary Treatment:
    U_data(1) = 1+0.001*sin(t);
    U_data(2) = 0.1;
    U_data(3) = 1.4;
    U_data(3*n-2) = 1+0.001*sin(t);
    U_data(3*n-1) = 0.1;
    U_data(3*n) = 1.4;
    
    SAT1 = Pinv*IO1s*Xinvs*(37.3166*Xks)*(U_old-U_data);
    SATn = Pinv*IOns*Xinvs*(-37.3166*Xks)*(U_old-U_data);
    
    U_new = dt*(-Aks*U_old - SAT1 + SATn) + U_old;

    U_old = U_new;
    U_show = reshape(U_new,3,n)';

    plot(x,U_show(:,2))
    axis([0 L -0.4 0.4])
    pause(0.1);

end




