import os, struct # to unpack binary data
from array import array as pyarray # for reading data into array
import numpy as np # for numeric computations
import matplotlib.pyplot as plt # plot graphs

# Function read labels from file and
#   return the desired labels of all the input images
#   converts each label e.g. '5' -> [0 0 0 0 1 0 0...]
# Partial code taken from : http://g.sweyla.com/blog/2012/mnist-numpy/
def getLabelsArray(fname, size_img, output_dim):
    flbl = open(fname, 'rb')
    magic_nr, size_label = struct.unpack(">II", flbl.read(8))
    lbl = pyarray("b", flbl.read()) # signed integers
    flbl.close()

    desired_label = np.zeros((size_img, output_dim), dtype=np.int)
    for i in range(size_label):
        desired_label[i][lbl[i]] = 1

    return desired_label

# Function to read the image details from the file and 
#   return image in [size, 1D-image-data] shape
# Partial code taken from : http://g.sweyla.com/blog/2012/mnist-numpy/
def getImagesArray(fname):
    fimg = open(fname, 'rb')
    magic_nr, size_img, rows, cols = struct.unpack(">IIII", fimg.read(16))
    img = pyarray("B", fimg.read()) # reading unsigned integers
    img = np.asarray(img).reshape(size_img, rows*cols)
    fimg.close()
    return img, size_img

# Returns after applying step function on V
def stepFunction(V):
    for i in range (0,10):
        value = V[i][0]
        V[i][0] = 1 if value >= 0 else 0
    return V

# Returns a matrix of size 10X1 with 1 at given index
def vectorWithOneOne(maxIndex):
    V = np.random.rand(10,1)
    V.fill(0)
    V[maxIndex][0]=1
    return V

# Returns index of maximum value in the output matrix
def findMaxIndex(V):
    max_val, max_i = V[0][0], 0
    for i in range (0,10):
        if (V[i][0] > max_val):
            max_val, max_i = V[i][0], i
    return max_i

# Function to update weights and returns the new w
def updateWeights(train_img_count, img, desired_label, w, n):
    for i in range(0, train_img_count):
        input_val = img[i].reshape(img.shape[1], 1)
        output = desired_label[i].reshape(desired_label.shape[1], 1)
        w = w + n * (output - stepFunction(w.dot(input_val))) * np.transpose(input_val)
    return w

# Returns the dot product of the img and label at index
def getDotProduct(img, desired_label, index, w):
    input_val = img[index].reshape(img.shape[1], 1)
    output = desired_label[index].reshape(desired_label.shape[1],1)
    vals = w.dot(input_val)
    return input_val, output, vals

# Function to train a multicategor perceptron
# which  creates a weights set randomly and
# saves it to the global variable 'w'
def MulticategoryPerceptronTrainer(train_img_count, n, e, img, debug=False):
    w = np.random.rand(desired_label.shape[1], img.shape[1])
    ep, errors, error_epochs, continue_loop = 0, [], [], True

    # Actual training section
    while(continue_loop and ep < 30):
        if debug:
            print("epoch :: ", ep)
        errors.append(0)

        # Counting the errors
        for index in range(0, train_img_count):
            if debug and index % 5000 == 0:
                print(index, " elements done")
            output, V = getDotProduct(img, desired_label, index, w)[1:]

            maxI = findMaxIndex(V)
            V = vectorWithOneOne(maxI)
            if (not(output == V).all()):
                errors[ep] = errors[ep]+1

        w = updateWeights(train_img_count, img, desired_label, w, n)

        # checking if the minimum error ratio is reached or not
        prog_error = errors[ep]/train_img_count
        if (prog_error < e):
            continue_loop = False
            print(ep, " Error rate :: ", prog_error)
        else:
            print(ep, " Error rate :: ", prog_error, " should be below e: ", e)

        ep = ep + 1
        error_epochs.append(ep)

    if(continue_loop):
        print("Program didn't terminate, so stopped after 30 epochs")

    print("Epochs to convergence :: ", ep)
    plot_graph(error_epochs, errors)

    return w


def plot_graph(error_epochs, errors):
    # Plotting the graph
    plt.plot(error_epochs, errors, 'b')
    plt.xlabel("Epochs")
    plt.ylabel("Errors")
    # plt.axis([0, ep, 0, max(errors)])
    plt.show()

# Function to get the missclassifications on the test set
def tests(test_img, test_desired_label, w):
    test_img_size = test_img.shape[0]
    errors = 0
    print("Testing : ")
    for index in range(0, test_img_size):
        if index%10000 == 0:
            print(".")
        output, V = getDotProduct(test_img, test_desired_label, index, w)[1:]

        maxIndex = findMaxIndex(V)
        V = vectorWithOneOne(maxIndex)
        if (not(output == V).all()):
            errors = errors + 1
    print ("Missclassifications: ", errors)

# Train Data
img, size_img = getImagesArray("train-images.idx3-ubyte")
desired_label = getLabelsArray("train-labels.idx1-ubyte", size_img, 10)

# Test Data
testImg, test_size_img  = getImagesArray("t10k-images.idx3-ubyte")
test_desired_label = getLabelsArray("t10k-labels.idx1-ubyte", test_size_img, 10)

# actual training and testing
# train_img_count, n, er = 50, 1, 0.01
# w = MulticategoryPerceptronTrainer(train_img_count, n, er, img)
# tests(testImg, test_desired_label, w)

# train_img_count, n, er = 1000, 1, 0.01
# w = MulticategoryPerceptronTrainer(train_img_count, n, er, img)
# tests(testImg, test_desired_label, w)

# train_img_count, n, er = 60000, 1, 0
# w = MulticategoryPerceptronTrainer(train_img_count, n, er, img)
# tests(testImg, test_desired_label, w)

n_iter = [1, 0.8, 0.5]
for i in range(3):
    train_img_count, n, er = 60000, n_iter[i], 0.18 # more than min observed
    print("Training started.. Learning rate: ", n)
    w = MulticategoryPerceptronTrainer(train_img_count, n, er, img)
    tests(testImg, test_desired_label, w)
