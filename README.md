# HD/UHD Comparison Test Data

[![DOI](https://zenodo.org/badge/169866955.svg)](https://zenodo.org/badge/latestdoi/169866955)

This data complements the following paper on HD/UHD comparison and gives raw rating results as well as questionnaire data:

> The First of All Pleasures – Comparison of HD and UHD Video Quality with and without the Influence of the Labeling Effect

The data contains an R script for reading the data and performing the main analyses. It is MIT-licensed and can be freely modified and published.

The answers regarding gender and age have been blinded in the questionnaire.

## Requirements

- R
- The packages:
    - `tidyverse`
    - `ggthemes`
    - `forcats`
    - `RColorBrewer`
    - `coin`
    - `stats`
    - `magrittr`
    - `broom`
    - `moments`
    - `evaluate`

## Data Format

- `results.csv`: Rating results, long format
    - `experiment`: Experiment ID (1, 2)
    - `subject`: Subject ID
    - `rating_type`: 7 or 3-point scale
    - `label_shown`: yes or no
    - `index`: index of the played sequence for the subject
    - `condition`: condition ID
    - `condition_expl`: string representation of the condition
    - `src`: SRC ID from 1 to 8
        - 1, 2: Big Buck Bunny (Blender)
        - 3, 4: Sintel (Blender)
        - 5, 6: Tears of Steel (Blender)
        - 7, 8: El Fuente (Netflix)
    - `first_label`: if a label was shown, the first one
    - `second_label`: if a label was shown, the second one
    - `first_res`: resolution of the first video
    - `second_res`: resolution of the second video
    - `rating`: numerical rating
    - `rating_str`: string representation of the rating
- `questionnaire.csv`: Questionnaire results, wide format
    - `question`: subject ID
    - `type`: 7 or 3-point scale
    - `label_shown`: yes or no
    - `q1` through `q14`: questions asked to subject

## Authors and Acknowledgement

For this repository: Werner Robitza, Peter A. Kara

To cite this data, please use the following information:

```
@electronic{kara2019data,
    author = {Kara, Peter A. and Robitza, Werner and Pinter, Nikolett and Martini, Maria G. and Raake, Alexander and Simon, Aniko},
    doi = {10.5281/zenodo.2561049},
    title = {{HD/UHD Comparison Test Data}},
    url = {https://zenodo.org/record/2561049},
    year = {2019}
}
```
