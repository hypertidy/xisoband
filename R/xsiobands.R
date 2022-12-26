

coords_iso <- function(x) {
  do.call(rbind, lapply(x, \(.x) cbind(.x$x, .x$y)))
}
extent_iso <- function(x) {
  coords <- coords_iso(x)
  c(range(coords[,1]), range(coords[,2]))
}

#' Title
#'
#' @inheritParams graphics::plot
#'
#' @return nothing, used for side effect (a plot)
#' @export
#'
#' @examples
#' plot(xisobands(volcano))
plot.iso <- function(x, ..., asp = "", add = FALSE) {
  ext <- extent_iso(x)
  if (!add) {
    plot.new()
    plot.window(xlim = ext[1:2], ylim = ext[3:4], asp = asp)
  }
  sepp <- function(x) {
    x <- do.call(cbind, x)
    #browser()
    pp <- lapply(split(x[, 1:2], rep(x[,3], 2)), \(.x) matrix(.x, ncol = 2))
    lapply(pp, lines)
  }
  invisible(lapply(x, sepp))
}

#' Isobands via matix and extent
#'
#' This is purely a re-orientation of isoband it self, rather than having to construct
#' a degenerate rectilinear data set, we just provide a  matrix and optionally an
#' extent. The extent scaling can be done independently if wanted.
#'
#' Matrix orientation is 'raster', i.e. like [rasterImage()] and not like [image()] which is
#' isoband is expecting.
#'
#' Values for lor and/or hi may be provided or left out. If both are left out can use
#' nlevs to get a quantile set of levels from the data.
#' @param x matrix of numeric
#' @param extent xmin,xmax,ymin,ymax georeference of the x matrix
#'
#' @param lo low levels
#' @param nlevs number of levels in the case that neither hi nor lo provided
#' @param hi high levels
#'
#' @return and isobands, iso object
#' @export
#'
#' @examples
#' x <- 1:10
#' y <- 1:5
#' m <- t(volcano[1:10, 1:5])
#' #isobands(x, y, m, 101, 106)
#' i <- 2
#' ## both cases return empty results
#' isobands(x[i], y, m[, i, drop = FALSE], 101, 106)
#' isobands(x, y[i], m[i, , drop = FALSE], 101, 106)
#'
#' m <- volcano
#' levs <- quantile(m, na.rm = TRUE, probs = seq(0, 1, length.out = 12))
#' x <- xisobands(m, head(levs, -1), tail(levs, - 1))
#' plot(x)
xisobands <- function(x, extent = NULL, lo = NULL, hi = NULL, nlevs = 12L) {
 x <- t(x[nrow(x):1, ])
  dimension <- dim(x)
  print(dimension)
  if (!is.null(lo) && is.null(hi)) {
    hi <- c(lo[-1L], max(x, na.rm = TRUE))
  }
  if (is.null(lo) && !is.null(hi)) {
    hi <- c(min(x, na.rm = TRUE), lo[-length(lo)])
  }

  if (is.null(lo) && is.null(hi)) {
    #rg <- range(x, na.rm = TRUE)

    if (nlevs == 1) {
      probs <- 0.5
      hi <- max(x, na.rm = TRUE)
      lo <- quantile(x, probs, na.rm = TRUE)
    } else {
      probs <- seq(0, 1, length.out = nlevs)

    levs <- quantile(x, probs, na.rm = TRUE)
    lo <- levs[-lengths(levs)]
    hi <- levs[-1L]
    }
  }
   extent <- extent %||% extent0(dimension)
  xs <-  .x_centre(dimension, extent)
  ys <- .y_centre(dimension, extent)
#  browser()
  #ximage::ximage(x, extent)
  ## I don't understand what class "isobands" "iso"  is for, you have to do this
  ## to clean up the polygons (why isn't this in the core alg?)
  # to_iso <- function(x, id) {
  #   x <- unclass(x)[[1]]
  #   list(x = x[,1], y = x[,2], id = rep(id, nrow(x)))
  # }
  #
  #out <- isoband::iso_to_sfg( isoband::isobands(xs, ys, t(x), lo, hi))
  #for (i in seq_along(out)) out[[i]] <- to_iso(out[i])
  #out
  isoband::isobands(xs, ys, t(x), lo, hi)
}

