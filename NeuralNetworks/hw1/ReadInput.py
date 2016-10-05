import os, struct
from array import array as pyarray
from numpy import append, array, int8, uint8, zeros
import numpy as np


np.set_printoptions(threshold=np.inf)
flbl = open("train-labels.idx1-ubyte", 'rb')
magic_nr, size_label = struct.unpack(">II", flbl.read(8))
lbl = pyarray("b", flbl.read())
flbl.close()

fimg = open("train-images.idx3-ubyte", 'rb')
magic_nr, size_img, rows, cols = struct.unpack(">IIII", fimg.read(16))
img = pyarray("B", fimg.read())
img = np.asarray(img).reshape(60000, 784)
fimg.close()

desired_label = np.zeros((size_img,10), dtype=np.int)
for i in range(size_label):
	desired_label[i][lbl[i]] = 1