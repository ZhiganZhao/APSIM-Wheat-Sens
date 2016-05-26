rm(list = ls())
library(rmarkdown)
library(yaml)
source('_utility.R')
navbar <- yaml.load_file('_navbar.yml')

tryCatch({
    # clean_site()
    
    # Find the apsim path 
    if (Sys.info()['sysname'] == 'Windows') {
        apsimx <- 'C:/Users/zhe00a/Documents/Working/04-Software/032-ApsimX/ApsimX/Bin/Models.exe'
    } else {
        apsimx <- 'mono _apsimx/Models.exe '
        file.remove(list.files('_simulation/', '*.csv', full.names = TRUE))
        apsimx_files <- list.files('_apsimx', full.names = TRUE)
        apsimx_files_new <- gsub('(_.*)_', '\\1', apsimx_files)
        file.copy(apsimx_files, apsimx_files_new)
    }
    
    para <- yaml.load_file('_parameter.yml')
    
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
            para_new <- toString(list('AAAAA' = para_j))
            pos <- grep('para: !r', template)
            template[pos] <- gsub('(.*para: !r )(.*)', paste0('\\1', para_new), template[pos])
            
            rmd_new <- template
            writeLines(rmd_new, file_name)
            
            sensitivity_test(
                para_j
                , paste0('_simulation/', para_j$text, '.apsimx'),
                apsimx = apsimx)
            
            files_tmp <- c(files_tmp, file_name)
        }
    }
    
    render_site()
    writeLines(as.yaml(navbar, indent = 4), '_navbar.yml')
    file.remove(files_tmp)
    if (Sys.info()['sysname'] != 'Windows') {
        file.remove(apsimx_files_new)
    }
    
}, error = function(e) {
    writeLines(as.yaml(navbar, indent = 4), '_navbar.yml')
    print(e)
    if (Sys.info()['sysname'] != 'Windows') {
        quit(save = "no", status = 100, runLast = FALSE)
    }
})
