#' browse tracks
#'
#' @description browse tracks by a web browser.
#' @param tracks filenames for signals to import.
#' @param additionalFiles additional files for the tracks. 
#' Must use same name as tracks.
#' @param formats format of the files.
#' @param locus genomic location to show.
#' @param genome genome assembly.
#' @param width width of the figure
#' @param height height of the figure
#' @param ... parameters could be used by 
#' igv.js(https://github.com/igvteam/igv.js/wiki/Tracks-2.0).
#' @import htmlwidgets
#' @importFrom utils adist
#' @importFrom methods getPackageName
#' @export
#' @return An object of class htmlwidget that will intelligently print itself 
#' into HTML in a variety of contexts including the R console, 
#' within R Markdown documents, and within Shiny output bindings.
#' @examples 
#' url <- "https://www.encodeproject.org/files/ENCFF356YES/@@download/ENCFF356YES.bigWig"
#' browseTracks(url, genome="hg19", locus="chr11:122929275-122930122")

browseTracks <- function(tracks,
                         locus,
                         genome,
                         formats="auto",
                         additionalFiles,
                         width=NULL, height=NULL, 
                         ...){
  if(missing(tracks)){
    stop("tracks is required.")
  }
  if(missing(locus)){
    locus = ""
  }
  if (missing(genome)){
    stop("genome is required")
  }
  
  availableFormats <- c("bed, gff, gff3, gtf, bedpe", "wig", "bigWig", 
                        "bedGraph", "bam", "vcf", "seg")
  
  TYPES <- list(annotation=c("bed", "gff", "gff3", "gtf", 'genePred', "genePredExt",
                          "peaks", "narrowPeak", "broadPeak", "bigBed", 
                          "bedpe"),
             alignment=c("bam"),
             variant = c("vcf"),
             wig     = c("bigWig"),
             seg     = c("seg"),
             spliceJunctions = c("bed"),
             gwas    = c("gwas"),
             interaction = c("bedpe"))
  availableFormats <- unique(unlist(TYPES))
  displayMode <- c("EXPANDED", "COLLAPSED", "SQUISHED")
  
  guessFormats <- function(x){
    extension <- sub("^.*\\.", "", basename(x))
    extension <- tolower(extension)
    dist <- adist(extension, tolower(availableFormats))[1, ]
    availableFormats[which.min(dist)[1]]
  }
  guessTYPES <- function(x){
    out <- NULL
    if(x %in% availableFormats){
      for(i in seq_along(TYPES)){
        if(x %in% TYPES[[i]]) {
          out <- names(TYPES)[i]
          break
        }
      }
    }
    out
  }
  if(formats=="auto"){
    formats <- guessFormats(tracks)
  }
  
  if(any(!formats %in% availableFormats)){
    stop("Available formats are", paste(availableFormats, collapse=" "))
  }
  if(length(names(tracks))!=length(tracks)){
    names(tracks) <- basename(tracks)
  }
  if(!missing(additionalFiles)){
    additionalFiles <- additionalFiles[match(names(tracks))]
  }else{
    additionalFiles <- NA
  }
  additionParams <- list(...)
  if(any(names(additionParams) %in% 
         c("order", "color", "autoHeight", 
           "minHeight", "maxHeight", "visibilityWindow",
           "removable", "indexURL"))){
    #TODO
  }
  tracks <- mapply(FUN=function(name, url, format, ...){
    list(name=name, type=guessTYPES(format), format=format, 
             url=url, ...)
  }, names(tracks), tracks, formats, ...,
  SIMPLIFY = FALSE)
  x <- list(
    tracks = tracks,
    genome = genome,
    locus = locus
  )
  
  htmlwidgets::createWidget(
    name = 'browseTracks',
    x = x,
    width = width,
    height = height,
    package = getPackageName()
  )
}


#' Shiny bindings for browseTracks
#'
#' Output and render functions for using browseTracks within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a browseTracks
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name browseTracks-shiny
#'
#' @export
browseTracksOutput <- function(outputId, width = '100%', height = '600px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'browseTracks', width, height, 
                                 package = getPackageName())
}

#' @rdname browseTracks-shiny
#' @export
renderbrowseTracks <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, browseTracksOutput, env, quoted = TRUE)
}

