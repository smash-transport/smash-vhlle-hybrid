# Types of scans

If a parameter scan is created with more than one scan parameter, it has to be decided how the different values for each parameter will be combined.

## All combinations by default

Unless differently specified, all combinations of parameters values are considered and one output handler configuration file per combination will be created.

From the mathematical point of view, given $n$ scan parameters with set of values $X_1, ..., X_n\,$, the set of considered combinations is nothing but the $n$-ary Cartesian product over all sets of values,

$$
X_1 \times \dots \times X_n = \bigl\{(x_1, ..., x_n) \;|\; x_i \in X_i \quad\forall\, i \in \{1,...,n\} \bigr\}
$$

For example, specifying two different scan parameters with 2 and 5 values, respectively, 10 values combinations will be built and 10 output files produced.

=== "Handler configuration"

    ```yaml
    # ...
    Scan_parameters: ["Foo.Bar", "Foo.Baz"]
    Software_keys:
      Foo:
        Bar: {Scan: {Values: [-1, 0, 17, 42, 666]}}
        Baz: {Scan: {Values: [True, False]}}
    # ...
    ```

=== ":file_folder: Scan folder"

    ``` { .console .no-copy }
    $ ls scan
    scan_combinations.dat    scan_run_04.yaml    scan_run_08.yaml
    scan_run_01.yaml         scan_run_05.yaml    scan_run_09.yaml
    scan_run_02.yaml         scan_run_06.yaml    scan_run_10.yaml
    scan_run_03.yaml         scan_run_07.yaml
    ```

=== ":material-file: Scan combinations"

    ``` { .yaml .no-copy }
    # Parameter_1: Foo.Bar
    # Parameter_2: Foo.Baz
    #
    #___Run  Parameter_1  Parameter_2
          1           -1         True
          2           -1        False
          3            0         True
          4            0        False
          5           17         True
          6           17        False
          7           42         True
          8           42        False
          9          666         True
         10          666        False
    ```

??? question "What happens if I provide a single value for a scan parameter?"
    If you provide a single-value list to `Values`, this will be accepted by the hybrid handler and the provided value will be considered in all combinations.
    If this happen to be the only provided scan parameter, a single configuration file will be created together with a basically useless single-combination file. :sweat_smile:

### Latin Hypercube Sampling

This algorithm, [if enabled](configuration_file.md#LHS-scan), samples multidimensional parameters randomly, while keeping the distance between samples maximal, and is commonly used for Bayesian inference.
Refer to e.g. [:simple-wikipedia: this page](https://en.wikipedia.org/wiki/Latin_hypercube_sampling) for more information.
The sampling itself is done by calling the `lhs` function from the [:fontawesome-brands-python: pyDoe](https://pythonhosted.org/pyDOE/randomized.html#latin-hypercube) Python library function, using the `centermaximin` criterion.
