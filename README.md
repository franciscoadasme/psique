# PSIQUE - Protein Secondary structure Identification on the basis of QUaternions and Electronic structure calculations

PSIQUE is a geometry-based secondary structure assignment method that uses local helix parameters, quaternions, and a classification criterion derived from DFT calculations of polyalanine.
The algorithm can identify common (alpha-, 3-10-, pi-helices and beta-strand) and rare (PP-II ribbon helix and gamma-helices) secondary structures, including handedness when appropriate.

## Installation

PSIQUE can be downloaded from the GitHub repository for Unix-like OS or built from the source code. _The former is recommended for most cases._

### Pre-built binaries

Binaries for either MacOS or Linux are available. Go to the webpage of the [latest release](https://github.com/franciscoadasme/chem.cr/releases/latest) and manually download and decompress the corresponding version, or use the command line as follows.

#### Linux

```sh
wget https://github.com/franciscoadasme/chem.cr/releases/latest/download/psique-linux.gz -O psique.gz && \
gzip -d psique.gz && \
chmod u+x psique
```

#### MacOS

```sh
curl -L https://github.com/franciscoadasme/chem.cr/releases/latest/download/psique-darwin.zip -o psique.zip && \
unzip psique.zip && \
chmod u+x psique
```

#### Windows

There is no version available for Windows as it is not supported by the Crystal language yet. It is recommended to use the Windows Subsystem for Linux (WSL) to run a local Linux distro within Windows and compile/run PSIQUE from it. For more information about WSL, refer to [WSL documentation](https://docs.microsoft.com/en-us/windows/wsl/about).

### From source

You need to install the crystal compiler by following [these steps](https://crystal-lang.org/install). Once it is installed, check the compiler by running:

```sh
$ crystal --version
Crystal 0.35.1 [5999ae29b] (2020-06-19)

LLVM: 8.0.0
Default target: x86_64-unknown-linux-gnu
```

Then, do the following:

```sh
tag=$(curl -s https://api.github.com/repos/franciscoadasme/psique/releases/latest | grep "tag_name" | cut -d\" -f4)
wget https://github.com/franciscoadasme/psique/archive/$tag.tar.gz -O psique-${tag#v}.tar.gz
tar xvf psique-${tag#v}.tar.gz
cd psique-${tag#v}
shards build --release --progress
```

The `psique` executable would be created at `bin/psique`. Check the compilation by:

```sh
$ ./bin/psique --version
PSIQUE 1.1.1 (2020-11-16)
```

## Usage

PSIQUE executable expects a PDB file containing a protein structure, and it outputs a new PDB with the information of the protein secondary structure set in the header:

```sh
psique 1crn.pdb
```

By default, the output is written to standard output. Use the `-o/--output` to set an output file that will be created.

```sh
psique 1crn.pdb -o 1crn--psique.pdb
```

Note that special codes in the HELIX records are used for structures not included in the standard format: 11 for left-handed 3-10-helix and 13 for left-handed pi-helix.

Alternatively, the output can be written in other file formats that can be read by analysis and visualization packages:

- `--pymol` write a PyMOL Command Script (\*.pml) file that loads the protein, defines new colors for secondary structures, and sets the secondary structure according to PSIQUE. This file can be directly loaded into PyMOL from the Open menu.
- `--stride` write a STRIDE output (\*.stride) file. This is useful to hook PSIQUE to any analysis and visualization software that expects a STRIDE file (see below).
- `--vmd` write a VMD Command Script (\*.vmd) file that loads the protein, defines secondary structure colors, and sets the secondary structure according to PSIQUE. Note that it re-defines existing colors as VMD does not allow for custom colors. Also, it uses the "Secondary Structure" coloring method by changing the standard definitions. This file can be loaded by running `source script.vmd` from the Tcl/Tk Console within VMD or executing VMD from the command line: `vmd -e script.vmd`.

For example, the following will write a PyMOL Command Script file instead of a PDB:

```sh
psique 1crn.pdb --pymol -o 1crn.pml
```

**Important** In both PyMOL and VMD Command Script files, the PDB file path is written as it is in the script file, so moving it into a different folder may break it.

### Hooking PSIQUE to other software

Analysis and visualization software like [ProDy](http://prody.csb.pitt.edu/), [VMD](https://www.ks.uiuc.edu/Research/vmd/), etc. can be tricked into using PSIQUE as long as they allow to provide custom executables for STRIDE.

To do so, create a bash script named `psique-stride` that calls PSIQUE with the `--stride` option and forwards any other arguments:

```sh
#!/usr/bin/env bash

p=`dirname "$0"`
"$p/psique" --stride $*
```

This assumes that `psique` is in the same directory. Then, `chmod +x psique-stride`.

#### VMD

VMD uses the `STRIDE_BIN` environment variable to detect the STRIDE binary, so define it to point to `psique-stride` as:

```sh
STRIDE_BIN=/path/to/psique-stride vmd
```

Note that a STRIDE citation notice is printed out by VMD when computing secondary structure, but it is not telling of the program that it was run.

**Important** This doesn't work on the Windows Subsystem for Linux (WSL) as the `STRIDE_BIN` environment variable is ignored by VMD on Windows for some reason.

#### Other

Please refer to the software documentation to check whether the STRIDE executable path can be set manually, and if so, follow the instructions given above.

## Citation

PSIQUE is research software, so please cite the corresponding article when using it in published work.

- Adasme-Carreño F., Caballero J., and Ireta J.; PSIQUE: Protein Secondary Structure Identification on the Basis of Quaternions and Electronic Structure Calculations. _J. Chem. Inf. Model._ **2021**, _61_, 4, 1789–1800.

The BibTeX reference is:

```text
@article{adasme2021,
  title={PSIQUE: Protein Secondary Structure Identification on the Basis of Quaternions and Electronic Structure Calculations},
  author={Adasme-Carre{\~n}o, Francisco and Caballero, Julio and Ireta, Joel},
  journal={Journal of Chemical Information and Modeling},
  volume={61},
  number={4},
  pages={1789--1800},
  year={2021},
  publisher={ACS Publications}
}
```

## Development

The implementation of the PSIQUE method is developed under the [chem.cr](https://github.com/franciscoadasme/chem.cr) shard, so changes to the method itself are done at that repository.
This repository contains the PSIQUE standalone program.

## Contributing

1. Fork it (<https://github.com/your-github-user/psique/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Francisco Adasme](https://github.com/your-github-user) - creator and maintainer

## License

Licensed under the MIT license, see the separate LICENSE file.
