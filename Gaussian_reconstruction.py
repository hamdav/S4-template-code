import sys

import numpy as np
import matplotlib.pyplot as plt

# Invoke script like "python3 Gaussian_reconstruction.py data.txt"

def calculateRsp(waist, r_sp, phis, lambdas, dphi, dtheta, ntheta):
    # @returns the reflectivity spectrum for the lambdas
    # Equation from https://doi.org/10.1364/OE.26.001895 (equation 6)
    # It assumes that r_sp is a 1D array on the form
    ##  theta=1     phi=1   lambda=1
    ##  theta=1     phi=1   lambda=2
    ##  theta=1     phi=1   lambda=3
    ##  theta=1     phi=2   lambda=1
    ##  theta=1     phi=2   lambda=2
    ##  theta=1     phi=2   lambda=3
    ##  theta=2     phi=1   lambda=1
    ##  theta=2     phi=1   lambda=2
    ##  theta=2     phi=1   lambda=3
    ##  theta=2     phi=2   lambda=1
    ##  ...
    #
    # It also assumes that phis are in degrees
    # and lambdas and waist in meters 

    # find the dimensions of the array (for resizing)
    nphi = phis.size
    nlambda = lambdas.size

    # Resize r_sp so that r_sp[1,2,5] yields r_sp of plane wave with 
    # lambda = lambdas[1], phi = phis[2], thetas = thetas[5]
    r_sp = np.transpose(np.resize(r_sp, (nphi*ntheta, nlambda)))
    r_sp = np.resize(r_sp, (nlambda, ntheta, nphi))

    r_sp = np.abs(r_sp)**2

    # Do the theta integral:
    r_sp_notheta = np.sum(r_sp, axis=1) * dtheta

    # Calculate and multiply with the phi factor
    ks = 2*np.pi / lambdas
    phiFactor = np.exp(-0.5 * (waist * np.outer(ks, np.sin(phis * np.pi / 180.)))**2) * np.sin(phis * np.pi / 180.)

    r_sp_notheta = r_sp_notheta * phiFactor

    # Do the phi integrals
    numerator = np.sum(r_sp_notheta, axis=1) * dphi
    denominator = np.sum(phiFactor, axis=1) * dphi
    
    # Calculate the Rsp
    Rsp = numerator / np.where(denominator == 0, 1, denominator)

    return Rsp


def main():
    ########## Get Data ##########

    filename = sys.argv[1]

    # File is expected to have a single header line on the form
    # a = 1081, r = 418, d = 90, L = 4000
    with open() as f:
        first_line = f.readline()
    

    data = np.genfromtxt(filename, skip_header=1)
    r_sp = data[:,2]

    lambdas = np.linspace(1400e-9, 1700e-9, 31)
    phis = np.linspace(0,10,11)
    dphi = np.pi/180
    dtheta = np.pi/18
    ntheta = 10

    ########## Calculate the reflectivities ##########

    Rsp = calculateRsp(4.6e-6, r_sp, phis, lambdas, dphi, dtheta, ntheta)
    
    ########## Plot the figure ##########

    plt.plot(lambdas, Rsp)
    plt.show()
    

main()
    



