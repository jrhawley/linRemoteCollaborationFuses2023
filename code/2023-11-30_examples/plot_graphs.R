# ==============================================================================
# Environment
# ==============================================================================
suppressPackageStartupMessages({
    library("data.table")
    library("ggplot2")
    library("ggdag")
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
dag <- dagify(
    ability_to_work_remotely ~ publication_year,
    citations ~ publication_year,
    distance ~ ability_to_work_remotely + temporal_separation + covid_19 + career_age,
    disruption ~ distance + knowledge_diversity + career_age + weak_ties + covid_19,
    n_i ~ disruption + publication_year + covid_19 + time_since_publication,
    n_j ~ disruption + publication_year + covid_19 + time_since_publication,
    n_k ~ disruption + publication_year + covid_19 + time_since_publication,
    citations ~ n_i + n_j + n_k + covid_19,
    D ~ n_i + n_j + n_k,
    temporal_separation ~ ability_to_work_remotely,
    knowledge_diversity ~ weak_ties,
    weak_ties ~ distance + temporal_separation + career_age,
    covid_19 ~ publication_year,
    time_since_publication ~ publication_year,
    labels = c(
        "ability_to_work_remotely" = "Ability to Work\nRemotely",
        "publication_year" = "Publication Year",
        "citations" = "Total\nCitations",
        "distance" = "Co-author\nDistance",
        "disruption" = "Disruption",
        "temporal_separation" = "Temporal\nSeparation",
        "interdisciplinarity" = "Interdisciplinarity",
        "career_age" = "Career\nAge",
        "weak_ties" = "Weak\nTies",
        "covid_19" = "COVID-19\nPandemic",
        "knowledge_diversity" = "Knowledge\nDiversity",
        "time_since_publication" = "Time Since\nPublication",
        "D" = "D score",
        "n_i" = bquote(n[i]),
        "n_j" = bquote(n[j]),
        "n_k" = bquote(n[k])
    )
)

tdy_dag <- tidy_dagitty(dag)


# ==============================================================================
# Plots
# ==============================================================================
gg <- (
    ggplot(
        data = tdy_dag,
        mapping = aes(
            x = x,
            y = y,
            xend = xend,
            yend = yend
        )
    )
    +
        geom_dag_edges()
        +
        geom_text(
            mapping = aes(label = label),
        )
        +
        theme_dag_blank()
)

ggsave(
    filename = here::here(res_dir, "dag.png"),
    plot = gg,
    width = 16,
    height = 16,
    units = "cm",
    dpi = 300
)
