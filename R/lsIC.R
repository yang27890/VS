lsIC <- function(x, y, candidate_models, psi, prior = TRUE,
	type = c("BIC","AIC")) {

    p <- NCOL(x)
    n <- length(y)

    sk <- rowSums(candidate_models)
    if(any(sk>=dim(x)[1]-1)){
      candidate_models <- candidate_models[-which(sk>=dim(x)[1]-1),]
      sk <- rowSums(candidate_models)
    }
    n_mo <- NROW(candidate_models)

    ik <- rep(NA, n_mo)
    if (any(candidate_models[1, ] == 1)) {
        for (i in 1:n_mo) {
            LSL <- lm(y ~ x[, candidate_models[i, ] == 1])
            rss <- crossprod(summary(LSL)$res, summary(LSL)$res)
			if(type == "BIC") ik[i] <- n * log(rss/n) + sk[i] * log(n)
            else ik[i] <- n * log(rss/n) + sk[i] * 2
        }
    } else {
        rss <- sum((y - mean(y))^2)
        ik[1] <- n * log(rss/n) + sk[1] * log(n)
        for (i in 2:n_mo) {
            LSL <- lm(y ~ x[, candidate_models[i, ] == 1])
            rss <- crossprod(summary(LSL)$res, summary(LSL)$res)
            if(type == "BIC") ik[i] <- n * log(rss/n) + sk[i] * log(n)
            else ik[i] <- n * log(rss/n) + sk[i] * 2
        }
    }
    if (prior == TRUE) {
        ck <- ck_compute(n_mo, sk, p)
        ik <- ik + 2 * psi * ck
    }
    ik <- ik - min(ik)
    weight <- exp(-ik/2)/sum(exp(-ik/2))
    outlist <- list(weight = weight,candidate_models=candidate_models)
}
