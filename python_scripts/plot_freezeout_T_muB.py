import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import seaborn as sns
import sys
import argparse
sns.set_palette('mako', 3)

def scalar_product(a, b):
    # No need to consider the metric or similar here. u_\mu is contravariant,
    # dSigma_\mu is covariant. So the metric tensor does not need to be applied.
    # The scalar product is then simply the sum of the multiplied components
    a_dot_b = a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3]

    return a_dot_b


def plotting():
    hyp_data = np.loadtxt(args.Freezeout_Surface, unpack = True)

    # Find index above which core contributions start
    tau = hyp_data[0]
    itemindex = np.where(tau>tau[0])[0]         #0 entry because a multi-dim array is assumed by np
    first_noncorona_index = itemindex[0]

    # consider only core contributions
    temp = hyp_data[12][first_noncorona_index:]
    muB = hyp_data[13][first_noncorona_index:]
    muQ = hyp_data[14][first_noncorona_index:]
    muS = hyp_data[15][first_noncorona_index:]

    # Find volume of each hypersurface patch.
    # Contributions are weighted by volume
    volumes = []
    for i in itemindex:
        dSigma_mu = [hyp_data[4][i], hyp_data[5][i], hyp_data[6][i], hyp_data[7][i]]
        umu = [hyp_data[8][i], hyp_data[9][i], hyp_data[10][i], hyp_data[11][i]]
        volumes.append(scalar_product(umu, dSigma_mu))
    V = np.sum(volumes)     # Total volume

    # Determine mean weighted with volumes
    T_mean, muB_mean = 0.0, 0.0
    for k in range(0, len(temp)):
        T_mean += temp[k] * volumes[k] / V
        muB_mean += muB[k] * volumes[k] / V

    # Determine standard deviation weighted with volumes
    T_variance, muB_variance = 0.0, 0.0
    for k in range(0, len(temp)):
        T_variance += (temp[k] - T_mean)**2 * volumes[k] / V
        muB_variance += (muB[k] - muB_mean)**2 * volumes[k] / V
    T_sigma = np.sqrt(T_variance)
    muB_sigma = np.sqrt(muB_variance)

    # Plot freezeout diagram
    # plotting_style.load_plot_style()
    plt.figure(figsize=(5,5))
    plt.hist2d(muB, temp, normed=True, weights=volumes, cmap='mako_r', bins = 70, zorder = 0)
    plt.errorbar(muB_mean, T_mean, xerr = muB_sigma, yerr = T_sigma, marker = 's', color = 'orange', markersize = 5)
    plt.ylabel('T [GeV]')
    plt.xlabel(r'$\mu_\mathrm{B}$ [GeV]')

    plt.tight_layout()
    plt.savefig(args.output_path + '/T_muB_diagram.png', dpi = 500)
    plt.close()


    # Write to file
    with open(args.output_path + '/T_muB.txt', 'w') as f:
        f.write('# muB_mean \t muB_std \t T_mean \t T_std \n')
        f.write(str(muB_mean) + '\t' + str(muB_sigma) + '\t' + str(T_mean) + '\t' + str(T_sigma))
    f.close()



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--Freezeout_Surface", required = True,
                        help = "Freezeout hypersurface from hydrodynamics.")
    parser.add_argument("--output_path", required = True,
                        help = "Path to store results.")
    args = parser.parse_args()

    plotting()
