library(rmarkdown)
library(yaml)
source('_utility.R')
tryCatch({
    # clean_site()
    para <- yaml.load_file('_parameter.yml')
    navbar <- yaml.load_file('_navbar.yml')
    
    navbar_new <- navbar
    navbar_new$left <- c(navbar_new$left, para)
    
    writeLines(as.yaml(navbar_new), '_navbar.yml')
    files_tmp <- NULL
    for (i in seq(along = para)) {
        # i <- 1
        para_i <- para[[i]]$menu
        for (j in seq(along = para_i)) {
            # j <- 1
            para_j <- para_i[[j]]
            file_name <- paste0(gsub('(.*)\\..*', '\\1', para_j$href), '.Rmd')
            template <- readLines('_template.Rmd')
            # Change template
            para_new <- paste0(
                'list(', 
                paste(
                    paste(names(para_j), 
                          lapply(para_j, function(x) {
                              paste0('c(', paste(paste0('"', x, '"'), collapse = ', '), ')')
                          }),
                          sep = ' = '), 
                    collapse = ', '),
                ')')
            pos <- grep('para: !r', template)
            template[pos] <- gsub('(.*para: !r )(.*)', paste0('\\1', para_new), template[pos])
            
            rmd_new <- template
            writeLines(rmd_new, file_name)
            
            sensitivity_test(
                para_j$name
                , para_j$level
                , paste0('_simulation/', para_j$text, '.apsimx'))
            
            files_tmp <- c(files_tmp, file_name)
        }
    }
    
    render_site()
    writeLines(as.yaml(navbar, indent = 4), '_navbar.yml')
    file.remove(files_tmp)
}, error = function(e) {
    print(e)
    quit(save = "no", status = 100, runLast = FALSE)
})
