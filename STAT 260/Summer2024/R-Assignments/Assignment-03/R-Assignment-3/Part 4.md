a) 
##### Code:
```R
# Simulate the 500 headset lifespans
set.seed(123) # For reproducibility
simHeadset <- rexp(500, rate = 1/6.2)

# Create a histogram
hist(simHeadset, main="Histogram of Simulated Headset Lifespans", xlab="Lifespan (years)", ylab="Frequency", col="lightblue", border="black")

# Calculate the mean of the sample
mean_simHeadset <- mean(simHeadset)
mean_simHeadset
```
##### Graph:
![[Screenshot 2024-07-29 002940.png|450]]

b)
##### Code:
```R
# Initialize a vector with 300 numeric entries
simMean <- numeric(300)

# Use a for-loop to fill the entries of simMean
for (i in 1:300) {
  sample_lifespans <- rexp(500, rate = 1/6.2)
  simMean[i] <- mean(sample_lifespans)
}

# Create a histogram
hist(simMean, main="Histogram of Simulated Sample Means", xlab="Sample Mean Lifespan (years)", ylab="Frequency", col="lightgreen", border="black")

# Calculate the mean of the sample
mean_simMean <- mean(simMean)
mean_simMean
```
##### Graph:
![[Pasted image 20240729003546.png|450]]

c)
1. **Shape:**
    - The simHeadset histogram is right-skewed due to the nature of the exponential distribution, which is always right-skewed with a long tail to the right.
    - The simMean histogram is approximately normal due to the Central Limit Theorem, which states that the distribution of the sample means will be approximately normal regardless of the shape of the population distribution, provided the sample size is sufficiently large (n = 500 in this case).
2. **Central Tendency:**
    - Both histograms are centered around the mean of the exponential distribution, which is 6.2 years. This is expected since both represent the same underlying population mean.
    - The simMean histogram shows a sharper peak because the distribution of the sample means tends to cluster around the true population mean, providing a more precise estimate.
3. **Variability:**
    - The variability in simHeadset is greater because the individual observations from an exponential distribution can vary widely.
    - The variability in simMean is smaller because the distribution of sample means (also known as the sampling distribution) tends to have less spread. This illustrates that as the sample size increases, the sample mean becomes a more reliable estimate of the population mean.

d)

- **Mean of Simulated Headset Lifespans (Part 4a):**
    - The mean of the simulated headset lifespans should be close to the theoretical mean of the exponential distribution, which is 6.2 years.
- **Mean of Simulated Sample Means (Part 4b):**
    - The mean of the simulated sample means should also be close to 6.2 years. According to the Law of Large Numbers, as the number of samples increases, the sample mean will converge to the population mean.

The means are expected to be similar because both are estimates of the same population mean (6.2 years). The Central Limit Theorem and the Law of Large Numbers provide theoretical backing for this expectation.
