import random
import matplotlib.pyplot as plt
import numpy as np

def plotPoints( ):

    list_of_lists = [[1, 2], [3, 3], [4, 4], [5, 2]]
    x_list = [x for [x, y] in list_of_lists]
    y_list = [y for [x, y] in list_of_lists]
    # plt.plot([1,2], [2,3], 'or')
    # plt.plot([1,2], [3,4], 'ob')
    plt.scatter(1,2, color='r')
    plt.scatter(2,3, color='b')
    plt.axis([0, 5, 0, 5])
    #plt.plot([2,3], 'b')
    plt.show(block=True)


def printme( str ):
   #"This prints a passed string into this function"
   print (str)
   return

printme("hello")
plotPoints()