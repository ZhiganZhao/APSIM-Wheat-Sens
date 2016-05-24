tryCatch({
    library(rmarkdown)
    clean_site()
    render_site()
}, error = function(e) {
    print(e)
    quit(save = "no", status = 100, runLast = FALSE)
})
