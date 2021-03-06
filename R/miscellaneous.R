CalculateAnalysisVariables <- function(part1, part2, 
                                       numberParameters, r, fitsCount, 
                                       fitsExtended, 
                                       s, modelNumber, frequency, observedCount) {
  # is it better to pass this in?
  BigChiSq <- 1000000000.0
  maxGoodnessOfFit <- 10
  return_variable <- list()
  return_variable$AIC <- 2 * numberParameters - 2*(part1 + part2)

  if (s[r] - numberParameters - 1 > 0) {
    return_variable$AICc <- return_variable$AIC + (2*numberParameters*(numberParameters+1)/(s[r]-numberParameters-1))
    return_variable$AICcFlag <- 1
  }
  
  ## calculate ChiSq, no binning
  
  # removed observedCountNoF0 ? not sure what that is
  chiSqAll <- ChiSqFunction(r, fitsCount, modelNumber, frequency, observedCount, s)
  return_variable$chiSq <- chiSqAll
  
  ## calculate Goodness of Fit

  df <- frequency[r] - numberParameters 
  test <- (chiSqAll - df)/sqrt(2*df)
  print(paste("test: ", test, sep = " "))
  print(paste("chiSqAll: ", chiSqAll, sep = " "))
  GOF0 <- list()
  #bigChisq is a global variable
  if (test < maxGoodnessOfFit  & chiSqAll < BigChiSq){
    GOF0 <- GoodnessOfFit(chiSqAll, df)
    return_variable$GOF0Check <- GOF0$flag
    return_variable$GOF0 <- GOF0$gof
  } else{
    return_variable$GOF0Check <- 0
  }
  
  ## calculate ChiSq, bin 5
  chiSq5 <- ChiSqBin(r, fitsExtended, 5, df, numberParameters, frequency, s, observedCount)
  
  df <- chiSq5$df
  GOF5Check <- chiSq5$flag
  chiSq5 <- chiSq5$chiSq
 
  ## calculate goodness of fit
  test <- (chiSq5 - df)/sqrt(2*df)
  if (test < maxGoodnessOfFit & GOF5Check == 1 & chiSq5 < BigChiSq) {
    GOF5 <- GoodnessOfFit(chiSq5, df)
    return_variable$GOF5Check <- GOF5$flag
    return_variable$GOF5 <- GOF5$gof
  }
  return_variable
}


ChiSqFunction <- function(r, fitsCount, modelNumber,
                  frequency, observedCount, s) {
  print("IN CHI SQ FUNCTION")
  print(paste("r: ", r, sep = " "))
  print("fitsCount")
  print(fitsCount)
  print(paste("modelNumber: ", modelNumber, sep = " "))
  print(frequency)
  print("observedCount")
  print(observedCount)
  print("s")
  print(s)
  #why is this diff if original is same
  chiSqTemporary <- 0
  sumFit <- 0
  rr <- 1
  if (frequency[1] == 0) {
    stop("first frequency is 0?")
  }
  
  print(paste("freq[r]: ", frequency[r]))
  # this bizarre looking flow adjusts for non-contiguous frequencies
  for (t in (1:frequency[r])) {
    if (t == frequency[rr]) {
      # print(paste("fitsCount[t]: ", fitsCount[t + 1], sep = " "))
      # print(paste("observedCount[rr]: ", observedCount[rr], sep = " "))
      # print(paste("observedCount[rr] - fitsCount[t]: ",observedCount[rr] - fitsCount[t+1], sep = " " ))
      # print(paste("(observedCount[rr] - fitsCount[t])^2): ", (observedCount[rr] - fitsCount[t+1])^2, sep = "  "))
      # print(paste("((observedCount[rr] - fitsCount[t])^2)/fitsCount[t])", ((observedCount[rr] - fitsCount[t+1])^2)/fitsCount[t + 1]), sep = " ")
      if (modelNumber < 6) {
        chiSqTemporary <- chiSqTemporary + ((observedCount)[rr] - fitsCount[t])^2/fitsCount[t]
      } else {
        chiSqTemporary <- chiSqTemporary + (((observedCount[rr] - fitsCount[t + 1])^2)/fitsCount[t + 1])
      }
      rr <- rr+1
    } else {
      chiSqTemporary <- chiSqTemporary + fitsCount[t]
    }
    print(paste("chiSqTemporary in loop: ", chiSqTemporary, sep = " "))
  }
  sumFit <- sum(fitsCount)
  print(paste("fitsCount[1]: ", fitsCount[1], sep = " "))
  #is this just a temp fix for LOGTWLR? do we even need this...
  #sumFit <- sumFit - fitsCount[1]
  print(paste("sumFit: ", sumFit, sep = " "))
  print(paste("chiSqTemporary before if check: ", sep = " "))
  print(paste("s[r]: ", s[r], sep = " "))
  if(modelNumber<6) {
    print("hi there")
    chiSqTemporary <- chiSqTemporary + s[r] - sumFit
    print(paste("chiSqTemporary: ", chiSqTemporary, sep = " "))
  }
  chiSqTemporary
}

ChiSqBin <- function(r, fitsExtended, bin, 
                     df, numberParameters, 
                     frequency, s, observedCount) {
  extendedTau <- frequency[r] * 4
  
  ## find terminal indices of binned cells
  check <- rep(NA, extendedTau) 
  accumulatedFit <- 0
  df <- 0
  stop <- 0
  t <- 1

# 
  # print("extendedTau")
  # print(extendedTau)
  # print("check")
  # print(check)
  # print("r")
  # print(r)
  # print("frequency")
  # print(frequency)
  # print("bin")
  # print(bin)
  # print("s")
  # print(s)
  # print("fitsExtended")
  # print(fitsExtended)
 
  while(t <= extendedTau  &  accumulatedFit < bin & (s[r]-accumulatedFit) >= bin) {
    check[t] <- 0
    accumulatedFit  <- accumulatedFit + fitsExtended[t]
    
    # print("t")
    # print(t)
    # print("fitsExtended[t]")
    # print(fitsExtended[t])
    # print("accumulatedFit")
    # print(accumulatedFit)
    # print("extended tau")
    # print(extendedTau)
    # print("+------------------------------+")
    if (accumulatedFit >= bin  & (s[r] - accumulatedFit) >= bin) {
      check[t] <- 1
      df <- df + 1
      stop <- t
      accumulatedFit <- 0
    }
    t <- t + 1
  }
  
  ## todo: fix
 # check[t-1]<-0
  

  ## check for enough data for bininng and positive df
  chiSqTemporary <- 0
  df <- df - numberParameters
  if (stop > 0 & df > 0) {
    cellObservation <- 0
    cellFit <- 0
    rr <- 1

    for (t in 1:extendedTau) {
      if (t <= frequency[r] & t == frequency[rr]) {
        cellObservation <- cellObservation + observedCount[rr]
        rr <- rr + 1
      } 
      cellFit <- cellFit + fitsExtended[t]
      if (check[t] == 1) {
        chiSqTemporary <- chiSqTemporary + (cellObservation-cellFit)^2/cellFit
        cellObservation <- 0
        cellFit <- 0
      }
    }
    observedTail <- cellObservation
    fitTail <- cellFit
    chiSqTemporary <- chiSqTemporary + (observedTail - fitTail)^2/fitTail
    flag <- 1
  } else {
    flag <- 0
  }
  list("chiSq"=chiSqTemporary, "flag"=flag, "df"=df)
}

GoodnessOfFit <- function(chiSqAll, df) {
  v <- df/2 + 1
  x <- chiSqAll/2
  g <- 1
  p <- 1

  while (v <= 2) {
    g <- g*x
    p <- p*v + g
    v <- v + 1
  }
  
  j <- floor(2.5*(3 + abs(x))) - 1
  f <- 1/(j + v - x)
  
  while (j >= 0) {
    f <- (f*x+1)/(j+v)
    j <- j - 1
  }
  
  p <- p + (f*g*x)
  g <- (1-(2/(7*v^2))*(1-(2/(3*v^2))))/(30*v^2)
  g <- ((g-1)/(12*v)) - (v*(log(v)-1))
  f <- p*exp(g-x)*sqrt(v/(2*pi))
  
  flag <- 1
  if (is.nan(f)) flag <- 0
  gof  <- 1-f*(chiSqAll/2)^(df/2)

  if (is.nan(gof)) flag <- 0
  
  list("gof"=gof, "flag"=flag)
}


GetConfidenceBounds <- function(r, se, sHatSubset, s, observationMaximum) {
  answer <- list()
  if (sHatSubset != s[r]) {
    dtemp <- exp(1.96*sqrt(log(1+se^2/(sHatSubset-s[r])^2)))
    answer$lcb <- s[observationMaximum] + (sHatSubset-s[r])/dtemp
    answer$ucb <- s[observationMaximum] + (sHatSubset-s[r])*dtemp
    answer$test <- 1
  } else{
    answer$test  <- 0
  }
  answer
  # should return a lower and upper bound
}

CheckOutput  <- function(x) {
  ifelse(is.null(x), NA, x)
}

BracetRoot <- function(poissonConstant, momentsInit) {
  
  ## initial guess range
  factor <- 2.0
  x1 <- momentsInit / factor
  x2 <- momentsInit * factor
  
  f1 <- (x1 / (1.0 - exp(-x1))) - poissonConstant
  f2 <- (x2 / (1.0 - exp(-x2))) - poissonConstant
  
  conclusion <- 0
  i <- 0
  while (conclusion == 0 & i < 20) {
    ## one estimate is negative and the other positive
    if ((f1 * f2) < 0.0) {
      conclusion <- 1
    }
    ## move the appropriate bound
    if (abs(f1) < abs(f2)) {
      x1 <- x1 + factor * (x1- x2)
      f1 <- (x1 / (1.0 - exp(-x1))) - poissonConstant
    }
    else
    {
      x2 <- x2 + factor * (x2 - x1)
      f2 <- (x2 / (1.0 - exp(-x2))) - poissonConstant
    }
    i <- i + 1
  }
  result <- list()
  result$conclusion <- conclusion
  result$x1 <- x1
  result$x2 <- x2
  result$f1 <- f1
  result$f2 <- f2
  result
}


pow <- function(a, b) {
  a^b
}

#really dumb, delete later, still not understanding the apply family
matrix_apply <- function(m, f) {
  m2 <- m
  for (r in seq(nrow(m2)))
    for (c in seq(ncol(m2)))
      m2[[r, c]] <- f(m2[[r,c]], c)
    return(m2)
}

# DOESN'T WORK FOR LNFACTORIAL 
logFactorial <- function(x) {
  cumsum(log(x))
}

# precision
MatrixInversion <- function(sHat, a00, a0, A) {
  result <- list()
  # complete the symmetric matrix
  A <- A + t(A)
  # print("new A")
  # print(A)
  # after dividing diag / 2, we get the same answer given by C#
  
  diag(A) <- diag(A)/2
  # print("A diag")
  # print(A)
  # 
  #tol = 1e-17
  #5.04722e-22
  aInverse <- try(solve(A), silent = TRUE)
  # print("AInverse after multiplication")
  # print(aInverse)

  if (class(aInverse) != "try-error") {
    answer <- a0 %*% aInverse %*% a0
    if (a00>answer) {
      result$answer <- sqrt(a00-answer)
      result$se <- sqrt(sHat)/answer
      result$flag <- 1
    } else {
      result$flag <- 0
    }
    
  } else {
    result$se <- 0
    result$flag <- 0
  }
  result
}

GetConfidenceBoundsDiscounted <- function(r, SE,
                                            sHatSubset, cStar,excess, LCB,
                                          UCB) {
  ## Confidence Bounds
  if (sHatSubset != s[r])
  {
    dTemp <- exp(1.96 * (sqrt(log(1.0 + (SE * SE / (((sHatSubset - cStar) * (sHatSubset - cStar))))))))
    LCB <- (cStar + excess) + ((sHatSubset - cStar) / dTemp)
    UCB <- (cStar + excess) + ((sHatSubset - cStar) * dTemp)
  }
  
  list("cStar"=cStar, "SE"=SE, "LCB"=LCB, "UCB"=ucb)
}
