# Project: 
### Data folder

As the datasets on Kaggle are too large, to the nature of the method, we only implement our method on a subset of the data. 

We work on the [training data](https://www.kaggle.com/c/favorita-grocery-sales-forecasting/data) to find the top 10 stores and top 200 items in terms of observation frequency, and choose the subset of data related to these items and stores to use. We split our data into a training set(20140816-20160815) and a test set(20160816-20170815) ”output/combined_train&test.zip”, and split the training set into a subtrain set (20140816-20160415) and a validation set(20160416-20160815) ”output/subtrain&validation.zip”. All these processed data can be found in output folder. You can have a look at how we process these data in our [main.Rmd/main.pdf file](doc/main.pdf).

For the “original data” folder, they are the original dataset download from [Kaggle](https://www.kaggle.com/c/favorita-grocery-sales-forecasting/data).

The data directory contains data used in the analysis. This is treated as read only; in paricular the R/python files are never allowed to write to the files in here. Depending on the project, these might be csv files, a database, and the directory itself may have subdirectories.

