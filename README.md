# PSIQUE: Protein Secondary structure Identification on the basis of QUaternions and Electronic structure calculations

PSIQUE is a geometry-based secondary structure assignment method that uses local helix parameters, quaternions, and a classification criterion derived from DFT calculations of polyalanine.
The algorithm can identify common (alpha-, 3₁₀-, π helices and β sheet) and rare (PP-II ribbon helix and γ helix) secondary structures, including handedness when appropriate.

## Methodology

PSIQUE is based on the assumption that geometrical patterns (helices and extended conformations) that arise from sequences of amino acids with uniform (similar) geometry are connected to energy minima in the conformational space of proteins.
The latter can be defined in terms of a Ramachandran-like map of polyalanine, which is computed as the potential energy surface (PES) of polyalanine using density functional theory (DFT) for maximum accuracy.
The PES is expressed as a function of the local helix parameters pitch (L) and twist (θ) instead of the traditional torsion angles φ and ψ for convenience.
The PES of polyalaline exhibits well-defined energy minima (or basins), each corresponding to a regular secondary structure, and so it can be partitioned into distinct regions using the energy gradient.

![TOC from the PSIQUE article](./assets/images/toc.png)

The algorithm consists of four stages:

1. **Residue-wise secondary structure labeling**.
   Each residue is labelled by the secondary structure based on the closest basin to its (L,θ) values in the PES.
   β sheets also require the presence of inter-strand backbone hydrogen bonds.
2. **Identification and extension of uniform stretches**.
   Protein structure uniformity is computed by a novel measure ϰ based on the distance between consecutive quaternions, which are 4D vectors that encode the orientation and rotation of each amino acid along the protein backbone.
   When ϰ < 60°, the segment is considered as uniform.
   Conversely, ϰ > 60° indicates that a residue has a geometry different from its neighbors, which is commonly observed in transitions (e.g., helix subtypes) or unstructured regions (e.g., loops).
   Uniform segments are identified and assigned to the secondary structure label obtained in step 1.
   These are then extended by reassigning adjacent nonuniform (unassigned) residues having similar (L,θ) values.
   The extension and reassignment fix issues due to local distortions at the termini of the identified secondary structure segments.
3. **Reassignment of flanked nonuniform segments**.
   Unassigned residues flanked by helical or extended stretches are reassigned if the secondary structure is of the same class as their neighbors.
   Such a special case deals with local distortions produced by helix transitions or similar geometric changes.
4. **Normalization of regular segments**.
   Normalization ensures that the identified segments have a correct length and merges together short subsegments of the same class (e.g., consecutive helical elements).

PSIQUE was compared to standard (DSSP and STRIDE) and new (ASSP and SCOT) secondary structure assignment methods for both helical and extended segments.
PSIQUE shows good agreement (>85%) with other methods.
However, it provides better discrimination of subtle secondary structures (e.g., helix types) and termini, and produces more uniform segments while also accounting for local distortions.

The agreement is ~85% for right-handed helices compared to other methods, especially for α helices.
Most discrepancies are at the helix termini.
As shown in the following examples, however, PSIQUE identifies helix subtypes (showed in different colors) and transitions correctly, whereas DSSP (D) and STRIDE (St) often report one single helix type for the same segments, especially STRIDE.
ASSP (A) and SCOT (Sc) fail to correctly identify the helix subtype besides α helix.
Most methods also do not detect helix kinks (as seen in subfigure _e_).

![Helix assignment comparison](./assets/images/helix-comp.png)

The agreement is ~65% for β sheets, where the 82% of the residue-wise discrepancies are due to low uniformity.
Indeed, hydrogen bond-based methods tend to produce highly-bent or twisted β sheets, but PSIQUE leaves such regions unassigned as the uniformity is very low (ϰ > 90°) indicated by black dots in the examples below.

![Extended assignment comparison](./assets/images/strand-comp.png)

For further details, please refer to the [PSIQUE article](https://doi.org/10.1021/acs.jcim.0c01343).

## Installation

PSIQUE can be downloaded from the GitHub repository for Unix-like OS or built from the source code. _The former is recommended for most cases._

### Pre-built binaries

Binaries for either MacOS or Linux are available. Go to the webpage of the [latest release](https://github.com/franciscoadasme/psique/releases/latest), manually download and decompress the executable. Alternatively, use the following command line:

#### Linux

```sh
wget https://github.com/franciscoadasme/psique/releases/latest/download/psique-linux.gz -O psique.gz && \
gzip -d psique.gz && \
chmod u+x psique
```

#### MacOS

```sh
curl -L https://github.com/franciscoadasme/psique/releases/latest/download/psique-darwin.zip -o psique.zip && \
unzip psique.zip && \
chmod u+x psique
```

#### Windows

Crystal on Windows is currently in preview, so PSIQUE is not compiled automatically for Windows just yet. However, it can be built from source ([see below](#from-source)).

An alternative is to use the Windows Subsystem for Linux (WSL) to run a local Linux distro within Windows and compile/run PSIQUE from there. For more information about WSL, refer to [WSL documentation](https://docs.microsoft.com/en-us/windows/wsl/about).

### From source

You need to install the crystal compiler by following [these steps](https://crystal-lang.org/install). Once it is installed, check the compiler by running:

```sh
$ crystal -v
Crystal 1.9.2 [1908c81] (2023-07-19)

LLVM: 16.0.3
Default target: x86_64-pc-windows-msvc
```

Then, download the source code of the latest version of this repository from [here](https://github.com/franciscoadasme/psique/releases/latest) and decompress it, or clone it via the [git](https://git-scm.com/) source control system.
Afterwards, do the following:

```
cd /path/to/psique
shards build --release --progress
```

If using a Unix-like OS like Ubuntu or MacOS, copy the following commands to do these steps from the terminal:

```sh
tag=$(curl -s https://api.github.com/repos/franciscoadasme/psique/releases/latest | grep "tag_name" | cut -d\" -f4)
wget https://github.com/franciscoadasme/psique/archive/$tag.tar.gz -O psique-${tag#v}.tar.gz
tar xvf psique-${tag#v}.tar.gz
cd psique-${tag#v}
shards build --release --progress
```

Once the compilation finishes, the `psique` executable would be created at `bin/psique`. Check the compilation by:

```sh
$ ./bin/psique --version
PSIQUE 1.1.2
```

## Usage

PSIQUE executable expects a PDB file containing a protein structure, and outputs a new PDB with the information of the protein secondary structure set in the header:

```sh
psique 1crn.pdb
```

By default, the output is written to standard output. Use the `-o/--output` to set an output file that will be created.

```sh
psique 1crn.pdb -o 1crn--psique.pdb
```

Note that special codes in the HELIX records in the PDB are used for structures not included in the standard format: 11 for left-handed 3₁₀-helix and 13 for left-handed π-helix.

Alternatively, the output can be written in other file formats that can be read by analysis and visualization packages via the `--format` option:

- `stride` write a STRIDE output (\*.stride) file. This is useful to hook PSIQUE to any analysis and visualization software that expects a STRIDE file (see [Hooking PSIQUE to other software](#hooking-psique-to-other-software)).
- `pymol` write a PyMOL Command Script (\*.pml) file that loads the protein, defines new colors for secondary structures, and sets the secondary structure according to PSIQUE. This file can be directly loaded into PyMOL from the Open menu.
- `vmd` write a VMD Command Script (\*.vmd) file that loads the protein, defines secondary structure colors, and sets the secondary structure according to PSIQUE.
  It uses the "Secondary Structure" coloring method by changing the standard definitions.
  Note that it re-defines existing colors as VMD does not allow for custom colors.
  This file can be loaded by running `source script.vmd` from the Tcl/Tk Console within VMD or by executing VMD from the command line: `vmd -e script.vmd`.

For example, the following will write a PyMOL Command Script file instead of a PDB file:

```sh
psique 1crn.pdb --format pymol -o 1crn.pml
```

Alternatively, the output format can be set via the `PSIQUE_FORMAT` environment variable:

```sh
PSIQUE_FORMAT=pymol psique 1crn.pdb -o 1crn.pml
```

**IMPORTANT:** In both PyMOL and VMD Command Script files, the PDB file path is written as specified in the command line to the script file, so moving it into a different folder may break it.

### Hooking PSIQUE to other software

Some analysis and visualization software like [VMD](https://www.ks.uiuc.edu/Research/vmd), [PyMOL](https://pymol.org), [ProDy](http://prody.csb.pitt.edu/), etc. invoke STRIDE as an external program to assign the secondary structure of a protein.
Such software can be tricked into using PSIQUE when calling STRIDE.

#### Using environment variables

[VMD](https://www.ks.uiuc.edu/Research/vmd), [PyMOL](https://pymol.org) (via the [DSSP Stride](https://pymolwiki.org/index.php/DSSP_Stride) plugin), and other software allow setting a custom executable for STRIDE manually via an environment variable (usually `STRIDE_BIN`).
In such cases, set it to the location of the `psique` binary, and the `PSIQUE_FORMAT` environment variable to `stride`.

For Unix-like OSs, simply do:

```sh
# check the software's documentation for the specific name
export STRIDE_BIN=/path/to/psique
export PSIQUE_FORMAT=stride
```

It may be good idea to add them to the shell configuration file (`.bashrc`, `.zshrc`, etc.) for them to be available in every session.

For Windows, do the following:

```powershell
# Powershell
$Env:STRIDE_BIN = "\path\to\psique"
$Env:PSIQUE_FORMAT=stride
```

or

```bat
:: Batch
set STRIDE_BIN="\path\to\psique"
set PSIQUE_FORMAT=stride
```

Alternatively, these can be set via the "Environment Variables" dialog in Windows.

#### Overwriting STRIDE

Software like [ProDy](http://prody.csb.pitt.edu/index.html) simply invokes the `stride` program, which is assumed to be installed.
In such cases, one can mimic STRIDE by renaming or creating a symbolic link to the `psique` executable, and setting the `PSIQUE_FORMAT` environment variable to `stride`.

The following example shows one possible way to do it in Unix-like OSs:

```sh
ln -s /path/to/psique ~/bin/stride # creates a symbolic link
# or
cp /path/to/psique ~/bin/stride # renames a copy
export PATH="$HOME/bin:$PATH" # ensures the executable is discoverable
export PSIQUE_FORMAT=stride # forces STRIDE format
```

**NOTE:** Ensure the directory containing the `psique` binary or symbolic link has priority in the `PATH` environment variable, which lists all the directories that are searched for executables in order.

#### VMD on Windows

Visual Molecular Dynamics ([VMD](https://www.ks.uiuc.edu/Research/vmd/)) is a widely-used molecular visualization program for large biomolecular systems.
VMD uses the `STRIDE_BIN` environment variable to detect the STRIDE binary.
However, VMD overwrites this variable on startup on Windows.
A simple solution is to add the following lines to the startup VMD script `vmdrc` (check for its location [here](https://www.ks.uiuc.edu/Research/vmd/vmd-1.7.1/ug/node197.html)):

```tcl
set ::env(STRIDE_BIN) /path/to/psique
set ::env(PSIQUE_FORMAT) stride
```

**NOTE:** VMD prints out a notice about the STRIDE citation each time it calls the STRIDE binary regardless of the program executed.

## Citation

PSIQUE is research software, so please cite the corresponding article when using it in published work.

> Adasme-Carreño F., Caballero J., and Ireta J.; PSIQUE: Protein Secondary Structure Identification on the Basis of Quaternions and Electronic Structure Calculations. _J. Chem. Inf. Model._ **2021**, _61_, 4, 1789–1800. https://doi.org/10.1021/acs.jcim.0c01343

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

1. Fork it (<https://github.com/franciscoadasme/psique/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Francisco Adasme](https://github.com/franciscoadasme) ([fadasme@ucm.cl](mailto:fadasme@ucm.cl)) - creator and maintainer

## License

Licensed under the MIT license, see the separate LICENSE file.
