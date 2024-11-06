## XXX

**SpringpotFit: XXX** is a Matlab package that implements a framework for tuning fractional-order controllers. The package leverages the Cross-Entropy (CE) method for global search optimization and employs an augmented Lagrangian formulation to handle equality and inequality constraints. With some straightforward adaptations, the FracTune strategy can also be applied to other types of modern controllers. 

<p align="center">
<img src="logo/FracTuneFramework.png" width="75%">
</p>

**SpringpotFit** uses as optimization tool the package **CEopt - Cross-Entropy Optimizer**, which can be downloaded at <a href="https://ceopt.org" target="_blank">https://ceopt.org</a>.

### Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Usage](#usage)
- [Documentation](#documentation)
- [Reproducibility](#reproducibility)
- [Authors](#authors)
- [Citing FracTune](#citing-fractune)
- [License](#license)
- [Institutional support](#institutional-support)
- [Funding](#funding)

### Overview
**SpringpotFit** was developed to tune fractional-order controllers for dynamical systems by solving nonconvex optimization problems via the cross-entropy method. The underlying results are reported in the following publication:
More details are in the following paper:
- *J. C. C. Basilio, J. G. Telles Ribeiro, T. R. Oliveira and A. Cunha Jr, Optimal tunning of fractional controllers via cross-entropy method, 2024 (under review)*

Preprint available <a href="https://hal.archives-ouvertes.fr/xxx" target="_blank">here</a>.

### Features
- Implements Cross-Entropy method for fractional-control tuning
- Handles equality and inequality constraints using augmented Lagrangian method
- Transparent "gray-box" optimizer with intuitive control parameters
- Robust and scalable for moderately sized complex problems
- Demonstrated applicability through select case studies

### Usage
To get started with **FracTune**, follow these steps:
1. Clone the repository:
   ```bash
   git clone https://github.com/americocunhajr/FracTune.git
   ```
2. Navigate to the code directory:
   ```bash
   cd FracTune/FracTune-1.0
   ```
3. To optimize a structure, execute the main file corresponding to your case:
   ```bash
   Main_XXX
   ```

This package includes the following files:
* Main_XXX.m  -- xxx

### Documentation
The routines in **SpringpotFit** are well-commented to explain their functionality. Each routine includes a description of its purpose, as well as inputs and outputs. 

### Reproducibility

Simulations done with **FracTune** are fully reproducible, as can be seen on this <a href="https://codeocean.com/capsule/xxx" target="_blank">CodeOcean capsule</a>.

### Authors
- José Geraldo Telles Ribeiro
- Americo Cunha Jr

### Citing FracTune
We ask the code users to cite the following manuscript in any publications reporting work done with our code:
- *J. C. C. Basilio, J. G. Telles Ribeiro, T. R. Oliveira and A. Cunha Jr, Optimal tunning of fractional controllers via cross-entropy method, 2024 (under review)*

```
@article{Basilio2024FracTune,
   author  = {J. C. C. Basilio and J. G. {Telles Ribeiro} and T. R. Oliveira and A {Cunha~Jr}},
   title   = {Optimal tunning of fractional controllers via cross-entropy method},
   journal = {Under Review},
   year    = {2024},
   volume  = {~},
   pages   = {~},
   doi    = {~},
}
```

### License
**SpringpotFit** is released under the MIT license. See the LICENSE file for details. All new contributions must be made under the MIT license.

<img src="logo/mit_license_red.png" width="10%"> 

### Institutional support

<img src="logo/logo_uerj_color.jpeg" width="10%">

### Funding

<img src="logo/cnpq.png" width="20%"> &nbsp; &nbsp; <img src="logo/capes.png" width="10%">  &nbsp; &nbsp; &nbsp; <img src="logo/faperj.jpg" width="20%">
