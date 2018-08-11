Introduction-
This project aims to create a predictive model using logistic regression in SAS to predict if a customer will experience financial distress in the next two years.

Data-
The dataset considered in this analysis is the "Give Me Some Credit" dataset available on the Kaggle website. The dataset contains 150000 observations. It contains 12 variables including demographic variables like age and number of dependents; and financial data including historical delay in payments, debt ratio, number of real estate loans.
Among the 150000 observations, 10026 (0.06684%) observations are customers that experience financial distress.

Oversampling-
Since the target variable is present in 0.06684% of the observations, a new data set is created containing oversampled data(33%). The new dataset contains 30026 observations. This dataset is divided into training and test datasets having a 60:40 ratio.

Missing data-
The variables for monthly income and number of dependents contain missing data. Median imputation is performed on the data. Median of the training dataset is imputed on the test dataset.

Variable redundancy-
This is tested using the VARCLUS procedure. There is some redundancy in the data.

Model-
The model variables are selected using backward stepwise selection. The final model contains 7 variables and has a AUC of 0.722 on traing data and 0.7180 on test data.












