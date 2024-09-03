using LinearAlgebra

function FixIter(fun,u,tol) # Fixed point iteration used for implicit methods
    while true
        uold = u
        u = fun(u)
        norm(uold - u) > tol || break
    end
    return u
end

function  ExpEuler(f::Function,u₀,h,N) # first order explicit Euler (not symplectic)
u = zeros(length(u₀),N+1)
u[:,1]  =   u₀;
for i in 1:size(u,2)-1; 
  u[:,i+1] = u[:,i] + h * f(u[:,i]);
end
    return u; 
end

function  ImpEuler(f::Function,u₀,h,N) # first order implicit Euler (not symplectic)
u = zeros(length(u₀),N+1)
u[:,1]  =   u₀;
        
for i in 1:size(u,2)-1; 
 g(k) = f(u[:,i] + h * k);
 k = FixIter(g,f(u[:,i]),1e-12);
 u[:,i+1] = u[:,i] + h * k;
end
    return u; 
    
end


function  RK4(f::Function,u₀,h,N)  # 4th order RK method (not symplectic)
u = zeros(length(u₀),N+1)
u[:,1]  =   u₀;
for i in 1:size(u,2)-1;
  K₁ = f(u[:,i])     
  K₂ = f(u[:,i] + h * K₁ / 2);
  K₃ = f(u[:,i] + h * K₂ / 2);
  K₄ = f(u[:,i] + h *  K₃);
 u[:,i+1] =  u[:,i] + h * (K₁ + 2 * K₂ + 2 *  K₃ + K₄) / 6;  
end
    return u; 
end


function  SympEuler(fT::Function,fV::Function,q₀,p₀,h,N) # Symplectic Euler
    
q = zeros(length(q₀),N+1)
p  =  copy(q);

q[:,1]  =   q₀;
p[:,1]  =   p₀;
     
for i in 1:size(q,2)-1; 
   q[:,i+1] = q[:,i] + h * fT(p[:,i]);
   p[:,i+1] = p[:,i] + h * fV(q[:,i+1]);
 end
  return [q; p]; 
end

function  MidPoint(f::Function,u₀,h,N) # Midpoint rule (symplectic)

u = zeros(length(u₀),N+1)
u[:,1]  =   u₀;
        
for i in 1:size(u,2)-1; 
 g(K) = f(u[:,i] + h * K / 2 );
   K0 = f(u[:,i])
    K = FixIter(g,K0,1e-12);
 u[:,i+1] = u[:,i] + h * K;

end
    return u; 
    
end


function  StormerVerlet(fT,fV,q₀,p₀,h,N) # Stormer Verlet methods (symplectic)
q = zeros(length(q₀),N+1)
p =  copy(q);

q[:,1]  =   q₀;
p[:,1]  =   p₀;
    
    
for i in 1:size(q,2)-1; 
        
       qmid = q[:,i] + (h/2) * fT(p[:,i]);
   p[:,i+1] = p[:,i] + h * fV(qmid);    
   q[:,i+1] = qmid + (h/2) * fT(p[:,i+1]);
 end
  return  return [q; p]; 
end



function ImpRK(f,x0,A,b,h,N) # Implicit RK methods
  n = length(x0); s=size(A,1);    
tol = 1e-12;

u = zeros(length(x0),N+1)
u[:,1]  =   x0;

    
for i in 1:size(u,2)-1; 
        
    g(K) = [f(u[:,i] .+ h * A[j,:]' * K) for j=1:s];
      K0 = [f(u[:,i]) for j=1:s];
       K = FixIter(g,K0,tol)
u[:,i+1] = u[:,i] .+ h * b'* K;  

end    
    return u
end



# Runge Kutta data

function RKdata(RK)
if RK==1 # Gauss method of odrer 4
 A = [0.25 0.25-√3/6 ; 0.25+√3/6 0.25]
 b = [0.5, 0.5];
elseif RK==2 # Symplectic RK method  of odrer 4 
a = (2+ 2^(1/2) + 1/2^(1/3)) / 3;
A = [a/2 0 0; a 1/2-a 0; a 1-2*a a/2];
b = [a, 1-2*a, a];
end
    return A,b;
end