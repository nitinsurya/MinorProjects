import random
import numpy as np
import matplotlib.pyplot as plt


# gradient descent and compute cost code partially taken from
# https://gist.github.com/marcelcaraciolo/1321575

# Cost function value
def compute_cost(X, y, theta):
    #Number of training samples
    m = len(y)
    predictions = X.dot(theta).flatten()
    sqErrors = (predictions - y) ** 2
    J = (1.0 / (2 * m)) * sqErrors.sum()

    return J

# Gradient descent process
def gradient_descent(X, y, theta, alpha, num_iters):
    m = len(y)
    J_history = []

    for i in range(num_iters):
        predictions = X.dot(theta).flatten() # x.w for output

        # difference from the desired
        errors_x1 = (predictions - y) * X[:, 0]
        errors_x2 = (predictions - y) * X[:, 1]

        # updating weights
        theta[0][0] = theta[0][0] - alpha * (1.0 / m) * errors_x1.sum()
        theta[1][0] = theta[1][0] - alpha * (1.0 / m) * errors_x2.sum()

        # logging the error
        J_history.append(compute_cost(X, y, theta))

        # if below certain error values change, break out of the loop
        if(i > 0 and abs(J_history[i-1] - J_history[i]) < 0.0001):
            break

    return theta, J_history


# creating set of input and output values and returns it
def getXY():
    x = list(range(1,51))
    y = []
    for el in x:
        y.append(el + random.uniform(-1, 1)) # adding random weight

    # t = np.empty(50)
    # t.fill(1)
    # tmp = np.concatenate(([t], [x])).transpose()
    return x, y

if __name__ == "__main__":
    #Some gradient descent settings
    iterations = 25
    alpha = 0.001

    x, y = getXY()

    # plot init values
    plt.scatter(x, y, marker='o', c='g')
    plt.xlabel('X axis')
    plt.ylabel('Y axis')

    # getting input into the required form
    it = np.ones(shape=(50, 2))
    it[:, 1] = x

    #Initialize theta parameters
    theta = np.zeros(shape=(2, 1))

    print(compute_cost(it, y, theta))

    theta, J_history = gradient_descent(it, y, theta, alpha, iterations)
    print(J_history)
    print(theta)

    # Plotting the line to be displayed
    x11 = ((theta[0]+theta[1]*1))
    x12 = ((theta[0]+theta[1]*50))
    plt.plot([x11, x12], [1, 50], 'r')

    plt.show()