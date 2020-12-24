
<p align="center">
  <img width="250" src="sticker.png">
</p>

## Overview

`extRatum` is a package used to provide summary statistics of local geospatial features within a given geographic area. It does so by calculating the area covered by a target geospatial feature (i.e. buildings, parks, lakes, etc.). The geospatial features can be of any type of geospatial data, including point, polygon or line data. 


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
##   Nikos Patias and Francisco Rowe (2020). extRatum: Summary Statistics
##   for Geospatial Features. R package version 1.0.0.
##   https://CRAN.R-project.org/package=extRatum
## 
## A BibTeX entry for LaTeX users is
## 
##   @Manual{,
##     title = {extRatum: Summary Statistics for Geospatial Features},
##     author = {Nikos Patias and Francisco Rowe},
##     year = {2020},
##     note = {R package version 1.0.0},
##     url = {https://CRAN.R-project.org/package=extRatum},
##   }
```