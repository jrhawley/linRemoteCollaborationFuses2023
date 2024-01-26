# ==============================================================================
# Environment
# ==============================================================================
suppressPackageStartupMessages({
    library("data.table")
    library("ggplot2")
    library("here")
})

data_dir <- here::here("data")
res_dir <- here::here("results")

if (!dir.exists(res_dir)) {
    dir.create(res_dir)
}


# ==============================================================================
# Data
# ==============================================================================
# load citation D-score data
citations <- fread(
    here::here(data_dir, "Paperid_Year_Discipline_Teamsize_Distance_Dscore.txt"),
    sep = "\t",
    header = FALSE,
    col.names = c(
        "paper_id",
        "publication_year",
        "discipline",
        "team_size",
        "distance",
        "d_score"
    )
)


# ==============================================================================
# Plots
# ==============================================================================
gg <- (
    ggplot(
        data = citations,
        mapping = aes(
            x = d_score
        )
    )
    +
        geom_density()
        +
        scale_x_continuous(
            name = "D",
            limits = c(-1, 1)
        )
        +
        ggtitle(
            "Observed distribution of D",
            subtitle = "All papers, combined"
        )
)
ggsave(
    filename = here::here(res_dir, "papers.dscore.density.png"),
    plot = gg,
    width = 12,
    height = 12,
    units = "cm",
    dpi = 300
)

gg_abs <- (
    ggplot(
        data = citations,
        mapping = aes(
            x = abs(d_score)
        )
    )
    +
        geom_density()
        +
        scale_x_continuous(
            name = "|D|",
            limits = c(0, 1)
        )
        +
        ggtitle(
            "Observed distribution of |D|",
            subtitle = "All papers, combined"
        )
)
ggsave(
    filename = here::here(res_dir, "papers.dscore-absolute.density.png"),
    plot = gg_abs,
    width = 12,
    height = 12,
    units = "cm",
    dpi = 300
)

gg_ecdf <- (
    ggplot(
        data = citations,
        mapping = aes(
            x = d_score
        )
    )
    +
        stat_ecdf()
        +
        ggtitle(
            "Observed distribution of D",
            subtitle = "All papers, combined"
        )
)
ggsave(
    filename = here::here(res_dir, "papers.dscore.ecdf.png"),
    plot = gg_ecdf,
    width = 12,
    height = 12,
    units = "cm",
    dpi = 300
)
