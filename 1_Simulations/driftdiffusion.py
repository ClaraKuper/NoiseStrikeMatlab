# this is a model containing a integrator function and other

# load packages
import numpy as np

# Define an integrator function that can integrate over functions with a deterministic and a stochastic part:
def euler_maruyama(pfun, ffun, gfun, x0, t, dt, **kwargs):
    """
    integrates functions with a stochastic part.

    input parameters:
    pfun: the function that generates parameters for ffun
    ffun: function
        this is a function that contains the deterministic part of the system of equations
    gfun: function
        this is a function that contains the stochastic part of the system of equations
    x0: the initial starting values of the variable being integrated
    t: np.array
        the time array in which the function integrates
    kwargs: dict
        a dicitonary of all arguements beeing passed to pfun and gfun


    returns:
    s: np.array
        contains the values of x0 at each timepoint with step size dt.
    """
    # initialize values that will be stacked later in the function
    X_t = x0
    s = X_t
    threshold_go = kwargs['threshold_go']
    rt = None
    resp = None

    # in case the model integrates over more than one value, we might have different noise levels per condition
    if type(X_t) == int:
        noiseLen = 1
    else:
        noiseLen = len(X_t)

    # get the parameters for the functions below
    params = pfun(t, **kwargs)

    for time in t[1:]:
        Wt = np.random.normal(0, 1, noiseLen)
        # perform the update step
        drift = ffun(time, **params)
        X_t1 = X_t + drift * dt + gfun(**kwargs) * np.sqrt(dt) * Wt
        s = np.vstack([s, X_t1])
        # check if threshold was crossed
        if abs(X_t1) >= threshold_go and (rt is None):
            # print(X_t1)

            rt = time
            if X_t1 > 0:
                resp = 'go'
            else:
                resp = 'nogo'

        X_t = X_t1

    if rt is None:
        # if the threshold was never crossed, just compute the remaining duration
        if drift > 0:
            rt = threshold_go / drift
        else:
            # divide by a small number is a zero division occurs
            rt = -0.01
        if X_t1 > 0:
            resp = 'go'
        else:
            resp = 'nogo'
    #print(rt)
    #print(kwargs['nd_time'])
    rt += kwargs['nd_time']
    
    
    return s, rt, resp


# noise model
def stoch_var(**args):
    """
    returns the variance of the noise, as given in the keyword arguments
    """

    return args['sigma']


# model 1
def model1(t, **args):
    """
    A drift diffusion model with a fixed drift rate, returns only the drift rate,
    the stochastic part is taken care of by the integrator function above
    """

    return args['drift_rate'] * args['chosen_resp']


# model 2
def model2(t, **args):
    """
    a model that returns drift rate 0 when evidence at the given time point is below threshold
    and return a fixed drift rate when evidence is above the threshold. The drift rate is modulated by
    a generic drift rate weight
    it takes an argument for the time when the drift starts and the value at which the drift starts
    """

    evidence = args['evidence_drift']
    drift_weight = args['drift_weight']

    if t < args['time_drift']:
        return 0

    else:
        return drift_weight * evidence


# model 3
def model3(t, **args):
    """
    a model that returns the current evidence modulated by
    a generic drift rate weight as drift rate
    the evidence vector needs the same size and time scale as the time vector
    """
    trial = args['trial']

    try:
        last_update = np.argmax(trial['time'][trial['time'] <= t])
        evidence = trial['p_in'].iloc[last_update]
        evidence_norm = evidence - 0.5

    except:
        evidence_norm = 0

    drift_weight = args['drift_weight']

    return drift_weight * evidence_norm


def get_params_model1(time, **args):
    """
    this returns the drift rate value set in the arguments
    """

    first_evidence_val = args['trial']['p_in'][0]
    if first_evidence_val <= 0.5:
        chosen_resp = -1
    else:
        chosen_resp = 1

    params = {
        'drift_rate': args['drift_rate'],
        'chosen_resp': chosen_resp
    }

    return params


# translate the evidence to a drift rate in model 2
def get_params_model2(time, **args):
    """
    input: evidence - np array with "time" and "p_in"

    returns
    the time point when the threshold is reached (drift start)
    and the value for which the threshold is reached (evidence)

    and also returns weight of evidence
    """

    # normalize p_in
    evidence_norm = args['trial']['p_in'] - 0.5

    # the try-except stucture takes care of cases in which the threshold is never crossed.
    try:
        # find the first value where the threshold is crossed
        idx = np.min(np.where(abs(evidence_norm) > args['threshold_drift'])[0])
        # time point of go for drift
        time_drift = args['trial']['time'].iloc[idx]
        # value of go for drift
        evidence_drift = evidence_norm[idx]

        # save paramters
        params = {

            'time_drift': time_drift,
            'evidence_drift': evidence_drift,
            'drift_weight': args['drift_weight']
        }

    except ValueError:

        # for now the parameters when the threshold is never crossed are set to zero,
        # but we could also have a more elaborate decision here
        params = {

            'time_drift': 0,
            'evidence_drift': 0,
            'drift_weight': args['drift_weight']
        }

    return params


def get_params_model3(time, **args):
    """
    this function returns a vector in the length of the time vector with the corresponding evidence value at each ms.
    also, it returns the drift weight

    both values are stored in a dicitonary that is fed into the model.
    """

    params = {
        'trial': args['trial'],
        'drift_weight': args['drift_weight']
    }

    return params


