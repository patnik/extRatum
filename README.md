
<p align="center">
  <img width="250" src="sticker.png">
</p>

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/extRatum)](https://cran.r-project.org/package=extRatum)
![RStudio CRAN
downloads](http://cranlogs.r-pkg.org/badges/grand-total/extRatum)
![RStudio CRAN monthly
downloads](http://cranlogs.r-pkg.org/badges/extRatum)
[![Rdocumentation](https://www.rdocumentation.org/badges/version/extRatum)](https://www.rdocumentation.org/packages/extRatum)

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)


## Overview

`extRatum` is a package used to provide summary statistics of local geospatial features within a given geographic area. It does so by calculating the area covered by a target geospatial feature (i.e. buildings, parks, lakes, etc.). The geospatial features can be of any type of geospatial data, including point, polygon or line data.
For examples of `extRatum` functionalities follow this [link](https://github.com/patnik/extRatum_examples).


## Installation
The easiest way to get extRatum is to install it from CRAN:

```{r, eval = FALSE}
install.packages("extRatum")
```

### Development version

To get a bug fix or to use a feature from the development version, you can install 
the development version of extRatum from GitHub.

```{r, eval = FALSE}
# install.packages("devtools")
devtools::install_github("patnik/extRatum")
```
## Citation

To extract `extRatum` citation, type the following code.

```{r, eval = FALSE}
citation('extRatum')
```

```
## 
## To cite package 'extRatum' in publications use:
## 
##   Nikos Patias and Francisco Rowe (2021). extRatum: Summary Statistics
##   for Geospatial Features. R package version 1.0.4.
##   https://CRAN.R-project.org/package=extRatum
## 
## A BibTeX entry for LaTeX users is
## 
##   @Manual{,
##     title = {extRatum: Summary Statistics for Geospatial Features},
##     author = {Nikos Patias and Francisco Rowe},
##     year = {2021},
##     note = {R package version 1.0.4},
##     url = {https://CRAN.R-project.org/package=extRatum},
##   }
```