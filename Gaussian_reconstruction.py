import numpy as np
import matplotlib.pyplot as plt

plt.style.use("seaborn-darkgrid")


def calculateRsp(waist, data):
    """
    @returns the reflectivity spectrum for the lambdas
    Equation from https://doi.org/10.1364/OE.26.001895 (equation 6)
    data[:,0] should contain the lambdas, and
    data[:,1] should contain the phis in radians,
    data[:,2] should contain the thetas in radians,
    data[:,3] should contain the reflectivities.
    """

    # Abs square the reflectivities
    data[:, 3] = np.abs(data[:, 3])**2

    # Sort according to lambdas first, phis second, thetas third
    data = data[np.argsort(data[:, 2], kind='mergesort')]
    data = data[np.argsort(data[:, 1], kind='mergesort')]
    data = data[np.argsort(data[:, 0], kind='mergesort')]

    # Append a last column of ones
    data = np.hstack((data, np.ones((len(data), 1))))

    # Partition data according to lambdas first and phis second.
    # I.e. data = [datawithlambda1, datawithlambda2, ...]
    # datawithlambdax = [datawithphi1, datawithphi2, ...]
    # datawithphix = [[lambda, phi, theta, r, 1],
    #                  [lambda, phi, theta, r, 1],... ]
    data = np.split(data, np.unique(data[:, 0], return_index=True)[1][1:])
    data = [np.split(datawithlambda,
                     np.unique(datawithlambda[:, 1], return_index=True)[1][1:])
            for datawithlambda in data]

    # Do the theta integral:
    # data is then [datawithlambda1, datawithlambda2, ...]
    # datawithlambdax = [[lambda, phi, r, 1], [lambda, phi, r, 1],... ]
    data = [np.array([[datawithphi[0][0],
                       datawithphi[0][1],
                       np.trapz(datawithphi[:, 3], datawithphi[:, 2]),
                       np.trapz(datawithphi[:, 4], datawithphi[:, 2])]
                      for datawithphi in datawithlambda])
            for datawithlambda in data]

    # Calculate and multiply with the phi factor e^(-0.5*(w*r*sin(phi))^2)*sin(phi)
    def mult_phifactor(datawithlambda):
        k = 2 * np.pi / datawithlambda[0][0]
        sins = np.sin(datawithlambda[:, 1])
        datawithlambda[:, 2] *= np.exp(-0.5 * (waist * k * sins)**2) * sins
        datawithlambda[:, 3] *= np.exp(-0.5 * (waist * k * sins)**2) * sins
        return datawithlambda

    data = [mult_phifactor(d) for d in data]

    # Do the phi integrals and divide
    def f(datawithlambda):
        a = np.trapz(datawithlambda[:, 2], datawithlambda[:, 1])
        b = np.trapz(datawithlambda[:, 3], datawithlambda[:, 1])
        if b == 0 and a != 0:
            raise AssertionError("denominator is 0 while numerator isn't")
        return a / b if b != 0 else 0

    Rsp = [f(d) for d in data]

    return Rsp


def calculateRspFromFile(filename,
                         thetacol=1,
                         phicol=2,
                         lambdacol=0,
                         reflectedcol=7,
                         skip_header=0):

    """
    Calculates the Rsp from a filename
    File is expected to have a single header row detailing what the columns are
    returns the lambdas (for plotting) and the Rsp in a tuple
    """

    data = np.genfromtxt(filename, skip_header=skip_header)


    # Calculate the reflectivities
    Rsp = calculateRsp(4.6e-6, np.column_stack((data[:, lambdacol] * 1e-9,
                                                data[:, phicol] * np.pi / 180,
                                                data[:, thetacol] * np.pi / 180,
                                                data[:, reflectedcol])))


    return np.unique(data[:, lambdacol]), Rsp

def main():

    #   Get Data

    datadir = "../data/"
    filenames = [datadir + "SL-vac-100-411.txt",
                 datadir + "DL-vac-base.txt"]
    legend = ["SL", "DL"]

    data = [calculateRspFromFile(filenames[0], reflectedcol=9),
            calculateRspFromFile(filenames[1], reflectedcol=3)]

    #   Plot the figure

    fig, ax = plt.subplots()

    for lambdas, Rsp in data:
        ax.plot(lambdas, Rsp, linewidth=2)

    ax.set_xlabel("Wavelength")
    ax.set_ylabel("Reflectivity")
    ax.set_title("Simulated reflectivity spectrum\nGap")
    ax.legend(legend)
    plt.show()


if __name__ == "__main__":
    main()
