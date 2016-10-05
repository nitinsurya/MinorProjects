import random
import numpy as np
import matplotlib.pyplot as plt


#Evaluate the linear regression
def compute_cost(X, y, theta):
    #Number of training samples
    m = len(y)
    predictions = X.dot(theta).flatten()
    sqErrors = (predictions - y) ** 2
    J = (1.0 / (2 * m)) * sqErrors.sum()

    return J


def gradient_descent(X, y, theta, alpha, num_iters):
    '''
    Performs gradient descent to learn theta
    by taking num_items gradient steps with learning
    rate alpha
    '''
    m = len(y)
    J_history = []

    for i in range(num_iters):
        predictions = X.dot(theta).flatten()

        errors_x1 = (predictions - y) * X[:, 0]
        errors_x2 = (predictions - y) * X[:, 1]

        theta[0][0] = theta[0][0] - alpha * (1.0 / m) * errors_x1.sum()
        theta[1][0] = theta[1][0] - alpha * (1.0 / m) * errors_x2.sum()

        J_history.append(compute_cost(X, y, theta))

        if(i > 0 and abs(J_history[i-1] - J_history[i]) < 0.0001):
            break

    return theta, J_history



def getXY():
    x = list(range(1,51))
    y = []
    for el in x:
        y.append(el + random.uniform(-1, 1))

    # t = np.empty(50)
    # t.fill(1)
    # # print(t)
    # # x = np.array(t, x)
    # # y = np.array(y)
    # tmp = np.concatenate(([t], [x])).transpose()
    return x, y

if __name__ == "__main__":
    #Some gradient descent settings
    iterations = 25
    alpha = 0.001

    x, y = getXY()

    plt.scatter(x, y, marker='o', c='g')
    plt.xlabel('X axis')
    plt.ylabel('Y axis')

    it = np.ones(shape=(50, 2))
    it[:, 1] = x

    #Initialize theta parameters
    theta = np.zeros(shape=(2, 1))

    #compute and display initial cost
    print(compute_cost(it, y, theta))

    theta, J_history = gradient_descent(it, y, theta, alpha, iterations)
    print(J_history)
    print(theta)

    x11 = ((theta[0]+theta[1]*1))
    x12 = ((theta[0]+theta[1]*50))
    plt.plot([x11, x12], [1, 50], 'r')

    plt.show()