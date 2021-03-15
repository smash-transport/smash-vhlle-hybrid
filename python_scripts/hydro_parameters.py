'''
    Dictionaries to properly set the parameters for the
    hydrodynamic evolution depending on the collision setup
'''

# etaS: shear vistocosity / entropy density
# Rg: transversal smearing parameter
# Rgz: longitudinal smearing parameter
hydro_params = {'7.7' : {'etaS' : 0.2, 'Rg' : 1.4, 'Rgz' : 1.5},
                '8.8' : {'etaS' : 0.2, 'Rg' : 1.4, 'Rgz' : 1.2},
                '17.3' : {'etaS' : 0.15, 'Rg' : 1.4, 'Rgz' : 0.8},
                '27.0' : {'etaS' : 0.12, 'Rg' : 1.0, 'Rgz' : 0.5},
                '39.0' : {'etaS' : 0.08, 'Rg' : 1.0, 'Rgz' : 0.3},
                '62.4' : {'etaS' : 0.08, 'Rg' : 1.0, 'Rgz' : 0.6},
                '130.0' : {'etaS' : 0.08, 'Rg' : 1.0, 'Rgz' : 0.8},
                '200.0' : {'etaS' : 0.08, 'Rg' : 1.0, 'Rgz' : 1.0},
                'default' : {'etaS' : 0.2, 'Rg' : 1.0, 'Rgz' : 1.2}
              }

# For reference, parameters as used in Karpenko et al.: Phys.Rev.C 91 (2015)
hydro_params_Karpenko = {'7.7' : {'etaS' : 0.2, 'Rg' : 1.4, 'Rgz' : 0.5},
                         '8.8' : {'etaS' : 0.2, 'Rg' : 1.4, 'Rgz' : 0.5},
                         '11.5' : {'etaS' : 0.2, 'Rg' : 1.4, 'Rgz' : 0.5},
                         '17.3' : {'etaS' : 0.15, 'Rg' : 1.4, 'Rgz' : 0.5},
                         '19.6' : {'etaS' : 0.15, 'Rg' : 1.4, 'Rgz' : 0.5},
                         '27.0' : {'etaS' : 0.12, 'Rg' : 1.2, 'Rgz' : 0.5},
                         '39.0' : {'etaS' : 0.08, 'Rg' : 1.0, 'Rgz' : 0.7},
                         '62.4' : {'etaS' : 0.08, 'Rg' : 1.0, 'Rgz' : 0.7},
                         '200.0' : {'etaS' : 0.08, 'Rg' : 1.0, 'Rgz' : 1.0},
                         'default' : {'etaS' : 0.2, 'Rg' : 1.4, 'Rgz' : 0.5}
                        }
