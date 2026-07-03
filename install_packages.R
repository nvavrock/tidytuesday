# Run once in RStudio: source("install_packages.R")

pkgs <- c(
  "tidyverse",
  "scales",
  "ggrepel",
  "plotly",
  "webshot2",
  "tidytext",
  "stopwords",
  "glmnet",
  "sf",
  "rnaturalearth",
  "leaflet",
  "htmlwidgets"
)

for (pkg in pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

message("Packages ready: ", paste(pkgs, collapse = ", "))
