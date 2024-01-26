# ==============================================================================
# Environment
# ==============================================================================
suppressPackageStartupMessages({
    library("data.table")
    library("ggplot2")
    library("patchwork")
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
# generate example data
set.seed(100)
fake_data <- data.table(
    athletics = rpois(1000, 5),
    academics = rpois(1000, 5)
)

fake_data_or <- fake_data[(athletics > 5) | (academics > 5)]

fake_data_xor <- fake_data[!((athletics > 5) & (academics > 5))]
fake_data_xor[
    , cor.test(x = academics, y = athletics)
]

correlations <- list(
    "all" = fake_data[, cor.test(x = academics, y = athletics)],
    "or" = fake_data_or[, cor.test(x = academics, y = athletics)],
    "xor" = fake_data_xor[, cor.test(x = academics, y = athletics)]
)


# ==============================================================================
# Plots
# ==============================================================================
gg_all <- (
    ggplot(
        data = fake_data,
        mapping = aes(
            x = academics,
            y = athletics
        )
    )
    +
        geom_point()
        +
        geom_smooth(method = "lm")
        +
        annotate(
            geom = "text",
            label = paste0(
                "R = ",
                formatC(
                    correlations$all$estimate,
                    format = "e",
                    digits = 3
                ),
                "\n",
                "p = ",
                formatC(
                    correlations$all$p.value,
                    format = "e",
                    digits = 3
                )
            ),
            x = 17,
            y = 17
        )
        +
        scale_x_continuous(
            name = "Academic Score",
            limits = c(0, 20)
        )
        +
        scale_y_continuous(
            name = "Athletic Score",
            limits = c(0, 20)
        )
        +
        ggtitle(label = "All students", subtitle = "1000 Students")
)
gg_or <- (
    ggplot(
        data = fake_data_or,
        mapping = aes(
            x = academics,
            y = athletics
        )
    )
    +
        geom_point()
        +
        geom_smooth(method = "lm")
        +
        annotate(
            geom = "text",
            label = paste0(
                "R = ",
                formatC(
                    correlations$or$estimate,
                    format = "e",
                    digits = 3
                ),
                "\n",
                "p = ",
                formatC(
                    correlations$or$p.value,
                    format = "e",
                    digits = 3
                )
            ),
            x = 17,
            y = 17
        )
        +
        scale_x_continuous(
            name = "Academic Score",
            limits = c(0, 20)
        )
        +
        scale_y_continuous(
            name = "Athletic Score",
            limits = c(0, 20)
        )
        +
        ggtitle(
            label = "Filtering out low-achievers",
            subtitle = "Academically OR Athletically Talented Students"
        )
)
gg_xor <- (
    ggplot(
        data = fake_data_xor,
        mapping = aes(
            x = academics,
            y = athletics
        )
    )
    +
        geom_point()
        +
        geom_smooth(method = "lm")
        +
        annotate(
            geom = "text",
            label = paste0(
                "R = ",
                formatC(
                    correlations$xor$estimate,
                    format = "e",
                    digits = 3
                ),
                "\n",
                "p = ",
                formatC(
                    correlations$xor$p.value,
                    format = "e",
                    digits = 3
                )
            ),
            x = 17,
            y = 17
        )
        +
        scale_x_continuous(
            name = "Academic Score",
            limits = c(0, 20)
        )
        +
        scale_y_continuous(
            name = "Athletic Score",
            limits = c(0, 20)
        )
        +
        ggtitle(
            label = "Filtering out high-achievers",
            subtitle = "Academically XOR Athletically Talented Students"
        )
)

gg <- (
    gg_all
    + gg_or
        + gg_xor
        +
        plot_annotation(
            title = "Berkson's Paradox, Visualized",
        )
)


ggsave(
    filename = here::here(res_dir, "berksons-paradox.png"),
    plot = gg,
    width = 32,
    height = 8,
    units = "cm",
    dpi = 300
)
