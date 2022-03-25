from sklearn import linear_model
from sklearn.metrics import mean_squared_error, r2_score
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def read():
    dsX = pd.read_csv("shearOutX.csv")
    dsY = pd.read_csv("shearOutY.csv")
    dsX = dsX.apply(pd.to_numeric, errors="coerce")
    dsX = dsX.dropna()
    dsY = dsY.apply(pd.to_numeric, errors="coerce")
    dsY = dsY.dropna()

    return dsX,dsY

def regression(ds , column1, column2):
    regres = linear_model.LinearRegression()

    X = ds[column1]
    Y = ds[column2]

    X_train = np.array(X[:-int((len(X))/2)]).reshape(-1,1)
    X_test = np.array(X[-int((len(X))/2):]).reshape(-1,1)

    Y_train = np.array(Y[:-int((len(Y))/2)]).reshape(-1,1)
    Y_test = np.array(Y[-int((len(Y))/2):]).reshape(-1,1)

    regres.fit(X_train, Y_train)

    Y_pred = regres.predict(X_test)

    mean = mean_squared_error(Y_test,Y_pred)
    r2Score = r2_score(Y_test,Y_pred)

    plt.scatter(X_train, Y_train,color="blue")
    plt.plot(X_train,regres.predict(X_train), color="red")
    plt.show()

    return regres, regres.coef_, mean, r2Score

def multi_regression(ds , columns, dependent):
    regres = linear_model.LinearRegression()

    X = ds[columns]
    Y = ds[dependent]

    X_train = np.array(X[:-int((len(X))/2)])
    X_test = np.array(X[-int((len(X))/2):])

    Y_train = np.array(Y[:-int((len(Y))/2)])
    Y_test = np.array(Y[-int((len(Y))/2):])

    regres.fit(X_train, Y_train)

    Y_pred = regres.predict(X_test)

    mean = mean_squared_error(Y_test,Y_pred)
    r2Score = r2_score(Y_test,Y_pred)

    graphing_function(X_train,Y_train)

    return regres, regres.coef_, mean, r2Score

def graphing_function(regres, X_train,Y_train,column1,column2):
    plt.scatter(X_train, Y_train,color="blue")
    plt.plot(X_train,regres.predict(X_train), color="red")
    plt.show()



if __name__ == "__main__":

    dsX ,dsY = read()

    regres1, coef,mean,r2Score = regression(dsX,"xVelocity","xAcceleration")
    regres2, c,m,r2 = multi_regression(dsX,["xPosition","xVelocity","xAcceleration"],"Time")
    print(c)
    print(m)
    print(r2)



    