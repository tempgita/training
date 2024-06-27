// cd "G:\.shortcut-targets-by-id\1ASYiYxEAcgJNzEL19Ex5oWLpC3ekSV7j\ROOT\TSM\to be delivered\training\Owner-occupied dwelling and imputed rent"

use data/KIELMC.dta, clear


* visualizing dep and indep variables
graph matrix price rooms area land baths age year dist, half

twoway (scatter price area)
twoway (scatter price area) (lfit price area), legend(off)

twoway (scatter price land) (lfit price land), legend(off)
twoway (scatter lprice lland) (lfit lprice lland), legend(off)
twoway (scatter price baths) (lfit price baths), legend(off)
twoway (scatter price age) (lfit price age), legend(off)
twoway (scatter price year) (lfit price year), legend(off)
twoway (scatter price dist) (lfit price dist), legend(off)
twoway (scatter lprice ldist) (lfit lprice ldist), legend(off)
twoway (scatter price rooms) (lfit price rooms), legend(off)


******************************************************************************************
* Perform the regression with the quadratic term
reg price age agesq

* Predict fitted values
capture drop fitted_y res
predict fitted_y, xb
predict res, residuals

// scatter res fitted_y

* Visualize the observed data and fitted regression line
sort age
twoway (scatter price age) ///
       (line fitted_y age, lcolor(red)) ///
	   (lfit price age), ///
       title("Quadratic Regression") ///
       legend(order(1 "Observed Data" 2 "Fitted line - Quadratic" 3 "Fitted line - OLS"))

twoway (scatter price fitted_y) (line price price), title("Actual vs. Fitted price") legend(off) ///
	xtitle(Fitted) ytitle(Actual)
	   

******************************************************************************************
reg lprice rooms larea lland baths age agesq y81 ldist

* Predict fitted values
capture drop fitted_y res
predict fitted_y, xb
predict res, residuals


* Visualize Predicted vs Actual
sort age
twoway (scatter lprice fitted_y) (line lprice lprice), /// 
	title("Predicted Vs. Actual") legend(off) ///
	xtitle(Predicted log(price)) ytitle(Actual log(price))

* Visualizing residuals
twoway (scatter res fitted_y), /// 
		yline(0, lcolor(red) lwidth(medium)) ///
       title("Residuals vs. Predicted Values") ///
       xtitle("Predicted Values") ///
       ytitle("Residuals")
	   
	   
* Create density plot of residuals and normal distribution
kdensity res, normal title("Density of Residuals") xtitle("Residuals")


*formal normality tests
*Shapiro-Wilk test is generally preferred for smaller samples (n < 2000).
swilk res

*Shapiro-Francia test, which is an alternative to Shapiro-Wilk, often used for larger samples.
sfrancia res

*************************************************************************************************
//Problem of multicolinearity

cor lprice rooms larea lland baths age agesq y81 ldist





******************************************************************************************
* imputed housing price
reg lprice rooms larea lland baths age agesq y81 ldist

* Predict fitted values
capture noisily drop fitted_y price_predicted
predict fitted_y, xb

gen price_predicted = exp(fitted_y)
twoway (scatter price price_predicted) (line price price), title("Actual vs. Imputed House Price") legend(off) ///
	xtitle(Predicted) ytitle(Actual)
	
	
******************************************************************************************
* Quantile regression as an alternative to OLS for Hedonic pricing
qreg lprice rooms larea lland baths age agesq y81 ldist, q(0.9)

* Predict fitted values
capture drop squared_residuals fitted_y res
predict fitted_y, xb
predict res, residuals


* Visualize Predicted vs Actual
sort age
twoway (scatter lprice fitted_y) (line lprice lprice), /// 
	title("Predicted Vs. Actual") legend(off) ///
	xtitle(Predicted log(price)) ytitle(Actual log(price))
	
// Calculate the squared residuals
gen squared_residuals = res^2

// Calculate the mean of the squared residuals
summarize squared_residuals, meanonly
scalar mse = r(mean)

// Calculate RMSE
scalar rmse = sqrt(mse)

// Display RMSE
display "RMSE: " rmse