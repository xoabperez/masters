## Plane Strain
from fenics import *
import numpy as np

# Define strain and stress
def E(u):
    return 0.5*(nabla_grad(u) + nabla_grad(u).T)

def sigma(u, mu, lam):
    return 2*mu*E(u)+lam*tr(E(u))*Identity(2)

def vm(u, mu, lam, W):
    s = sigma(u, mu, lam) - (1./3)*tr(sigma(u, mu, lam))*Identity(2)  # deviatoric stress
    von_Mises = sqrt(3./2*inner(s, s))
    return project(von_Mises, W)

def varprob(V, W, mbc, phi, mu, lam, omega):
    # Define variational problem
    nu = lam/(2*(lam+mu))
    
    u = TrialFunction(V)
    v = TestFunction(V)
    F = -inner(sigma(u, mu, lam), E(v))*dx - dot(grad(omega*phi), v)*dx 
    a, L = lhs(F), rhs(F)
    
    # Compute solution
    u = Function(V)
    solve(a == L, u, mbc)
    vmstress = vm(u, mu, lam, W)
    return vmstress