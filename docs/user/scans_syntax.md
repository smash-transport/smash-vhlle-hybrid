# The parameters scan syntax

In order to properly run the hybrid handler in `prepare-scan` mode, the configuration file must be properly created and fulfil few additional constraints.

!!! danger "Do not forget to declare scan parameters as such!"
    Each parameter which must be scanned has to be declared so by using the `Scan_parameters` key in the corresponding stage section [:material-arrow-right-box: key description](configuration_file.md#scan-parameters).
    **If a parameter is not declared to be scanned** and is specified as a scan in the `Software_keys` section, this will probably not be caught by the hybrid handler and **the produced configurations are likely to be wrong**.

!!! warning "Scanning only numerical parameters is possible"
    At the moment, it is not possible to scan parameters whose value is not numerical.
    More precisely, only integer, float or boolean YAML types are accepted.
    Feel free to open an issue if this is a too strong restriction for you.

Once scan parameters have been specified as such, they **must** appear in the `Software_keys` map.
However, their value should not be a simple parameter value, but a YAML map with a given format.
In the following we will refer to this map as "scan object".
The different allowed ways to specify scan objects are discussed in the following, providing an example for each of them.
The scan object shall always have a `Scan` key as single top-level key.
```yaml title="Generic parameter scan specification"
Scan_parameters: ["Parameter"]
Software_keys:
  Parameter:
    Scan:
      ...
```

### Explicitly specifying the parameter values

The most basic way to specify a scan is by providing the list of its values.
This is possible in the `Values` YAML array inside the `Scan` map.

=== "Compact style"

    ```yaml title="Example"
    Scan_parameters: ["foo.bar"]
    Software_keys:
      foo:
        bar: {Scan: {Values: [17, 42, 666]}}
    ```

=== "Mixed style"

    ```yaml title="Example"
    Scan_parameters: ["foo.bar"]
    Software_keys:
      foo:
        bar:
          Scan:
            Values: [17, 42, 666]
    ```

=== "Extended style"

    ```yaml title="Example"
    Scan_parameters: ["foo.bar"]
    Software_keys:
      foo:
        bar:
          Scan:
            Values:
             - 17
             - 42
             - 666
    ```
