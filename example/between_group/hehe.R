h <- function() {
  x <- 10
  function() {
    cat('the number of the call is',
        sys.nframe(), '\n')
    cat('the call frame is\n')
    print(parent.frame())
    print(where('x'))
    print(parent.env(where('x')))
    x
  }
}