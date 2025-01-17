% syms rho u p c
% syms rho1 u1 p1 rho2 u2 p2 rho3 u3 p3 rho4 u4 p4 rho5 u5 p5

n = 5;
L = 10;
% syms L
dx = L/n;
p0 = 2.5687e+04;
u0 = 14.0475;
rho0 = 0.4135;

% U = [rho1 u1 p1 rho2 u2 p2 rho3 u3 p3 rho4 u4 p4 rho5 u5 p5]';
U = [1 2 3 2 3 4 3 4 5 4 5 6 5 6 7]';

%the linear coefficient matrix A (gamma = 1)
% A = sym(zeros(3));
% A(1,1) = u;
% A(1,2) = rho;
% A(2,2) = u;
% A(2,3) = 1/rho;
% A(3,2) = p;
% A(3,3) = u;
% display(A)
A = zeros(3);
A(1,1) = u0;
A(1,2) = rho0;
A(2,2) = u0;
A(2,3) = 1/rho0;
A(3,2) = p0;
A(3,3) = u0;

%P matris:
e = ones(n,1);
P = diag(e);
P(1,1) = 0.5*P(1,1);
P(n,n) = 0.5*P(n,n);
display(P)
I = eye(3);
Pinv = kron(inv(P), I);
% display(Pinv)

%D matrisen:
D = spdiags([-e 0*e e], -1:1, n,n);
D(1,1) = -2;
D(1,2) = 2;
D(n,n) = 2;
D(n, n-1)=-2;
D = D./(2*dx);
display('D=')
display(full(D))

%indikator:
IO=zeros(3*n);
IO(1,1)=1;
IO(2,2)=1;
IO(3,3)=1;

%eigenvalues
[X,E]=eig(A); 
display(X)
display(E)
In = eye(n);
Xinv = kron(inv(X), In);
Xk = kron(X, In);
Ek = kron(E, In);

SAT = Pinv*IO*Xinv*(0.5*(Ek + abs(Ek))*Xk)*U;
% SAT = Pinv*Xinv*(0.5*(Ek + abs(Ek))*Xk)*U;
display(SAT)