# offline saccade detection
# write these functions into a module
# eye traces to 2D velocity space
# find times when the median velocity was exeeded by 5 sd for at least 8 ms

import numpy as np
import pandas as pd

# function one - transform xy coordinates in velocity

def vecvel(x, SAMPLING, TYPE=2):
    """
    computes velocity time series from position data, following Engbert and Mergenthaler 2014
    input:
    x = pandas data frame with 2 columns, first for x, second for y position
    SAMPLING = the sampling rate of the eye tracker
    TYPE = 2 or different number, 2 ist stronger smoothing that 1

    output:
    v: a vector with the x and y velocity in the first (x) and the second (y) column
    """

    dims = x.shape
    N = dims[0]
    v = np.zeros((N, dims[1]))
    # print(v.shape)

    if TYPE == 2:
        v[2:(N - 3)] = SAMPLING / 6 * (x[5:N].values + x[4:(N - 1)].values - x[2:(N - 3)].values - x[1:(
                N - 4)].values)  # SAMPLING/6*(x[5:N,] + x[4:(N-1),] - x[2:(N-3),] - x[1:(N-4),])
        v[1] = SAMPLING / 2 * (x[3:4].values - x[1:2].values)  # SAMPLING/2*(x[3,:] - x[1,:])
        v[(N - 1)] = SAMPLING / 2 * (
                x[N - 1:N].values - x[(N - 3):(N - 2)].values)  # SAMPLING/2*(x[N,:] - x[(N-2),:])
    else:
        v[2:(N - 2)] = SAMPLING / 2 * (x[3:N - 1].values - x[1:(N - 3)].values)  # SAMPLING/2*(x[3:N,:] - x[1:(N-2),:])

    return v


# saccade detection function

def saccades(x, VFAC=5, MINDUR=8, SAMPLING=1000):
    """
    saccade detection function based on Engbert and Mergenthaler 2014
    min dur in ms is converted to samples in the first step
    VFAC is how many sds over median we want to be
    """
    
    MINDUR = MINDUR / 1000 * SAMPLING

    v = vecvel(x, SAMPLING=SAMPLING)

    # compute threshold
    medx = np.median(v[:, 0])
    msdx = np.sqrt(np.median((v[:, 0] - medx) ** 2))
    medy = np.median(v[:, 1])
    msdy = np.sqrt(np.median((v[:, 1] - medx) ** 2))

    if msdx < 1e-10:
        msdx = np.sqrt(np.mean(v[:, 0] ** 2) - (np.mean(v[:, 0])) ** 2)
        if msdx < 1e-10:
            raise ValueError("msdx<realmin in saccades")
    if msdy < 1e-10:
        msdy = np.sqrt(np.mean(v[:, 1] ** 2) - (np.mean(v[:, 1])) ** 2)
        if msdy < 1e-10:
            raise ValueError("msdy<realmin in saccades")

    radiusx = VFAC * msdx
    radiusy = VFAC * msdy

    radius = [radiusx, radiusy]

    # apply test criterion as threshold
    test = (v[:, 0] / radiusx) ** 2 + (v[:, 1] / radiusy) ** 2
    indx = np.where(test > 1)[0]

    # Find saccades
    N = len(indx) - 1
    nsac = 0
    sac_idx = []
    sac = []
    dur = 1
    a = 0
    k = 0

    while k < N:

        if indx[k + 1] - indx[k] == 1:
            dur += 1

        else:
            if dur >= MINDUR:
                nsac += 1
                b = k
                sac_idx.append(np.hstack((indx[a], indx[b])))
                sac.append(np.zeros(7))

            a = k + 1
            dur = 1

        k = k + 1

    if dur >= MINDUR:
        nsac += 1
        b = k
        sac_idx.append(np.hstack((indx[a], indx[b])))
        sac.append(np.zeros(7))

    if nsac > 0:
        # compute peak velocity and horizontal and vertical components
        saccades = []
        for ids, s in enumerate(sac):
            # onset and offset
            a = sac_idx[ids][0]
            b = sac_idx[ids][1]

            # saccade peak velocity
            vpeak = np.max(np.sqrt(v[a:b, 0] ** 2 + v[a:b, 1] ** 2))
            s[0] = vpeak

            # saccade vector
            dx = x.iloc[b, 0] - x.iloc[a, 0]
            dy = x.iloc[b, 1] - x.iloc[a, 1]
            s[1:3] = [dx, dy]

            # saccade amplitude
            minx = np.min(x.iloc[a:b, 0])
            maxx = np.max(x.iloc[a:b, 0])
            miny = np.min(x.iloc[a:b, 1])
            maxy = np.max(x.iloc[a:b, 1])

            ix1 = np.argmin(x.iloc[a:b, 0])
            ix2 = np.argmax(x.iloc[a:b, 0])
            iy1 = np.argmin(x.iloc[a:b, 1])
            iy2 = np.argmax(x.iloc[a:b, 1])
            

            dX = np.sign(ix2 - ix1) * (maxx - minx)
            dY = np.sign(iy2 - iy1) * (maxy - miny)

            s[3] = dX
            s[4] = dY
            s[5] = ids

            if maxx >= 28 + 9 and minx < 28 + 9:
                to_goal = 1
            else:
                to_goal = 0
            s[6] = to_goal

            saccades.append(s)

        out = [sac_idx, saccades, radius]
        
    else:
        out = [None, None, None]

    return out
