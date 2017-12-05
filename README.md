# Project 5: Corporación Favorita Grocery Sales Forecasting

### [Project Description](https://www.kaggle.com/c/favorita-grocery-sales-forecasting)

Term: Fall 2017

+ Team #1
+ Project title: Corporación Favorita Grocery Sales Forecasting
+ Team members
	+ Shiqi Duan sd3072@columbia.edu
	+ Shuyao Hao sh3565@columbia.edu
	+ Jordan Leung jl4700@columbia.edu
	+ Jingkai Li jl4756@columbia.edu
	+ Peter Li pwl2107@columbia.edu
	 

+ Method: Overall we use Stacking method. That is, we build two layers. In the first layer, we obtain the prediction results from each first-layer model and use these results as features in the second layer to get the final prediction values. 
        
First Stack
- Time Series models

— - ETS (Exponential Smoothing State Space Model)
- - ARIMA
— - Prophet
- Machine Learning models
— - XgBoost
- - Random Forest


Second Stack
- Linear Regression
- Random Forest
- GBM


+ Evaluation: We use the same evaluation formula as on Kaggle [evaluation formula](https://www.kaggle.com/c/favorita-grocery-sales-forecasting#evaluation).

+ Project summary: 	

### Main file: [main.Rmd](doc/main.Rmd) or [the PDF version](doc/main.pdf).   

**Contribution statement**: ([Please see this file for the statement](doc/a_note_on_contributions.md))
All team members approve our work presented in this GitHub repository including this contributions statement.  

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
