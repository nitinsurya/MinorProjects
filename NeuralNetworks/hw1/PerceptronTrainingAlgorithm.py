import random
import matplotlib.pyplot as plt
import numpy as np


def getRandomValue(a, b):
    return random.uniform(a,b)

def perceptronOP (w0, w1, w2, x1,x2):
    return (w0 + w1*x1 + w2*w2)

def computeOP(w0, w1, w2, input):
    #print("inside compute op " + str(w0) + " " + str(w1) + " " + str(w2))
    if ((w0 + w1 * input[0] + w2 * input[1]) < 0):
        return 0
    else:
        return 1

def areCorrectWeights(w0,w1,w2):
    correct = True
    for index in range(len(inputs)):
        input = inputs[index]
        expectedOP = output[index]
        calculatedOP = computeOP(w0,w1,w2, input)
        #print (str(input) + " expectedOP: " + str(expectedOP) + " calculatedOP: "+ str(calculatedOP))
        if (expectedOP!=calculatedOP):
            correct = False
    return correct

inputs = []
output = []
w0 = getRandomValue(-1 / 4, 1 / 4)
w1 = getRandomValue(-1, 1)
w2 = getRandomValue(-1, 1)

def trainPerceptron(noOfTraningInputs):
    print (str(w0) + " " + str(w1) + " " + str(w2))
    inputs.clear()
    output.clear()
    for i in range(0,noOfTraningInputs):
        x1 = getRandomValue(-1,1)
        x2 = getRandomValue(-1,1)
        inputs.append((x1, x2))
        #print("inside for loop : " + str(w0) + " " + str(w1) + " " + str(w2))
        if ((w0 + w1*x1 + w2*x2) < 0 ):
            output.append(0)
        else:
            output.append(1)

    #print (areCorrectWeights (w0,w1,w2))
    plotPoints(w0,w1,w2)

    return

#training parameter
nlist=[1, 0.1, 10]
def updateWeights(w0,w1,w2,sign,input,n):

    w0 = w0 + sign*n*1
    w1 = w1 + sign*n*input[0]
    w2 = w2 + sign*n*input[1]
    return w0,w1,w2

def findWeights():
    w0r = getRandomValue(-1,1)
    w1r = getRandomValue(-1,1)
    w2r = getRandomValue(-1,1)

    print("staring with random weights ",w0r, " ",w1r, " ",w2r)

    for n in nlist:
        #keeping the same weights for different training parameters
        print("training parameter ",n)
        w0Optimal = w0r
        w1Optimal = w1r
        w2Optimal = w2r
        weightsFound = False
        epoch = 0
        epochCount = []
        misClassCount = []
        while(weightsFound==False):
            weightsFound = areCorrectWeights(w0Optimal, w1Optimal, w2Optimal)
            epoch = epoch + 1
            if(weightsFound==False):
                missClass = 0
                for index in range (len(inputs)):
                    input = inputs[index]
                    calculatedOP = computeOP(w0Optimal,w1Optimal,w2Optimal,input)
                    expectedOP = output[index]
                    if(calculatedOP!=expectedOP):
                        missClass = missClass + 1
                        sign = expectedOP - calculatedOP
                        w0Optimal,w1Optimal,w2Optimal = updateWeights(w0Optimal,w1Optimal,w2Optimal,sign,input,n)
                #print ("epoch : ", epoch, " no of missclassifications : ", missClass)
                epochCount.append(epoch)
                misClassCount.append(missClass)
            else:
                print ("found correct weights : " + str(w0Optimal) + " " + str(w1Optimal) + " " + str(w2Optimal))
                print("epoch ", epoch)
                epochCount.append(epoch)
                misClassCount.append(0)
                plt.plot(epochCount, misClassCount, 'b')
                plt.axis([0, epoch, 0, max(misClassCount)])
                plt.show()
                weightsFound == True
                #plotPoints(w0, w1, w2)


def plotPoints(w0, w1, w2):
    for index in range (len(inputs)):
        input = inputs[index]
        if (output[index] == 0):
            plt.scatter(input[0],input[1],color='r')
        else:
            plt.scatter(input[0],input[1],color='b', marker = '*')
    plt.axis([-1,1,-1,1])
    x11 = ((-w0-w2*-1)/w1)
    x12 = ((-w0-w2*1)/w1)
    plt.plot([x11, x12], [-1, 1], 'g')
    print (x11, " -1", " second point : ", x12, " 1")
    plt.show()

trainPerceptron(100)
findWeights()

trainPerceptron(1000)
findWeights()
