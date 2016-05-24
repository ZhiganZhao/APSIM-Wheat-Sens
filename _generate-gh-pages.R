
library(rmarkdown)
unlink('site_libs', recursive = TRUE)

tryCatch(render_site(), error = function(e) {
    print(e)
    quit(save = "no", status = 100, runLast = FALSE)
    })
