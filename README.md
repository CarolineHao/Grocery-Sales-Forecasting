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
	

+ Data: As the datasets on Kaggle are too large, to the nature of the method, we only implement our method on a subset of the data. We work on the training data to find the top 10 stores and top 200 items in terms of observation frequency, and choose the subset of data related to these items and stores to use. We split our data into a training set(20140816-20160815) and a test set(20160816-20170815), and split the training set into a subtrain set (20140816-20160415) and a validation set(20160416-20160815). 

+ Method: Overall we use Stacking method. That is, we build two layers. In the first layer, we obtain the prediction results from each first-layer model and use these results as features in the second layer to get the final prediction values. 
        
First layer
- Time Series models
— - ETS (Exponential Smoothing State Space Model), we first train them on the subtrain set with different parameters and use the models on the validation set to compare the performance. Then we get the best model and use that to predict the sales on validation set and test set, and call these results as features_valid and features_test respectively. For machine learning models, we train the models using cross-validation on the whole training set and get the best model. Then we also use the best model to do the same thing on validation set and test set.
        
In the second layer, we use machine learning models (Random Forest) on the features_valid by cross-validation to find the best model. Then use the best model on feature_test to get the final predicted sales.

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
