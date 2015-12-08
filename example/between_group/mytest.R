t1 <- function() {
    aa <- 'here'
    t2 <- function() {
      cat('current frame is', sys.nframe(), '\n')
      str(sys.calls())
      cat('parents are frame numbers', sys.parents(), '\n')
      cat('the number of the current frames is ', sys.parent(), '\n')
      print(ls(envir = sys.frame(-1)))
      # invisible()
      str(sys.frame(sys.parent()))
      }
    t2()
    # sys.frame(sys.parent())
    sys.frame(1)
}
ff <- function(x) gg(x)
gg <- function(y) sys.status()