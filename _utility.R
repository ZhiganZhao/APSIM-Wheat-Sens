# Run simulations with APSIM through change parameter values

new_breaks <- function(x) {
    if (max(x) < 11) {
        breaks <- seq(1, 10, by = 1)
    } else {
        breaks <- seq(0, 2500, by = 500)
    }
    names(breaks) <- attr(breaks,"labels")
    breaks
}



sensitivity_test <- function(
    name, level, filename, 
    template = '_simulation/sensitivity.apsimx',
    apsimx = 'C:/Users/zhe00a/Documents/Working/04-Software/032-ApsimX/ApsimX/Bin/Models.exe') {
    if (is.null(level)) {
        stop('Level needs to be specified')
    }
    output_file <- gsub('apsimx', 'db.Report.csv', filename)
    if (file.exists(output_file)) {
        return(NULL)
    }
    
    apsimx_template <- readLines(template)
    # Add new cultivars
    start <- grep('<CultivarFolder>', apsimx_template)[1]
    end <- grep('</CultivarFolder>', apsimx_template)
    end <- end[length(end)]
    start1 <- grep('<Name>Hartog</Name>', apsimx_template[start:end]) - 2 + start
    end1 <- grep('</Cultivar>', apsimx_template[start1:end])[1] + start1 - 1
    cultivar_old <- apsimx_template[start1:end1]
    value_new <- paste0('<Command>', paste0(name, ' = ', level), '</Command>')
    cultivar_new <- NULL
    for (i in seq(along = value_new)) {
        temp <- cultivar_old
        temp <- gsub('Hartog', paste0('Dummy', i), temp)
        cultivar_new <- c(cultivar_new, append(temp, value_new[i], length(temp) - 1))
    }
    apsimx_template <- append(apsimx_template, cultivar_new, end - 1)
    
    
    # Change factors 
    start <- grep('<Name>template</Name>', apsimx_template) - 1
    end <- grep('</Operations>', apsimx_template)[1]
    
    operations <- apsimx_template[start:end]
    operations_new <- NULL
    for (i in seq(along = value_new)) {
        temp <- operations
        temp <- gsub('template', paste0('Dummy', i), temp)
        temp <- gsub('hartog', paste0('Dummy', i), temp)
        
        operations_new <- c(operations_new, temp)
    }
    apsimx_template <- append(apsimx_template[-seq(start, end)], operations_new, start - 1)
    writeLines(apsimx_template, filename)
    
    system(paste0(apsimx, ' ', filename))
}



plot_report <- function(df, x_var, y_cols, x_lab = x_var, y_lab = 'Value') {
    library(ggplot2)
    # x_var_name <- gsub('.*\\.(.*)', '\\1', x_var)
    # x_var_n <- list()
    # x_var_n[[x_var_name]] <- x_var
    pd <- df %>%
        select_(.dots = c('Cultivar', x_var, y_cols)) %>%
        gather_(key_col = 'Trait', value_col = 'YValue', gather_cols = y_cols) %>%
        gather_(key_col = 'XVar', value_col = 'XValue', gather_cols = x_var) %>%
        mutate(Trait = gsub('.*\\.(.*)', '\\1', Trait)) %>%
        mutate(XVar = gsub('.*\\.(.*)', '\\1', XVar))
    x_var_name <- gsub('.*\\.(.*)', '\\1', x_var)
    y_cols_name <- gsub('.*\\.(.*)', '\\1', y_cols)
    pd <- pd %>%
        mutate(Trait = factor(Trait, levels = y_cols_name),
               XVar = factor(XVar, levels = x_var_name))
    
    p <- ggplot(pd, aes(XValue, YValue))
    
    p <- p +
        geom_line(aes(colour = Cultivar)) +
        geom_point(aes(colour = Cultivar))
    if (length(x_var) > 1) {
        p <- p + facet_grid(Trait~XVar, scales = 'free_x')
    } else if (length(x_var) == 1) {
        p <- p + facet_wrap(~Trait)
    }
    p <- p + theme_bw() +
        theme(legend.position = 'bottom') +
        xlab(x_lab) + ylab(y_lab) +
        guides(colour = guide_legend(title = '', ncol = 3))
    if (length(grep('Stage', x_var)) > 0) {
        
        p <- p + scale_x_continuous(breaks = new_breaks)
    }
    p
}



