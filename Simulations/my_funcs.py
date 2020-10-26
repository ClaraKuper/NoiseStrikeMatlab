# Module to define some important functions that will be used repeatedly
# By Clara Kuper, October 2020

# import external modules
from scipy.stats import uniform
import numpy as np


def get_p_in(upper_known, lower_known, attacker, full_width):
    """
    Normalizes the upper and lower bounds to compute how likely the attacker is to hit the goal, given the distance
    between attacker and last known point of the goal

    input:
    upper_known: np array or pandas series, holding the presented upper part of the goal (can span several trials)
    lower_known: np array or pandas series, holding the lower presented part of the goal (can span several trials)
    attacker: np array or pandas series, holding the (estimated) end point of the attacker (must have as many entries as
    the two other vectors)
    full_width: the span that is covered by the full goal

    returns:
    P_in: the probability that the attacker is inside the goal (value between 0 and 1)

    """

    # part 1: normalize the values to be aligned with the mean of the known goal, and to have positive values
    mean_goal = (upper_known + lower_known) / 2
    upper_norm = abs(upper_known - mean_goal)
    lower_norm = abs(lower_known - mean_goal)
    attacker_norm = abs(attacker - mean_goal)

    # part 2: compute the covered and the unknown size of the goal
    covered_goal = abs(upper_known - lower_known)
    free_width = full_width - covered_goal

    # part 3: compute the probability that the attacker hits inside the goal
    p_in = 1 - uniform.cdf(attacker_norm, loc=upper_norm, scale=free_width)

    return p_in


def get_rt(trial_data, thresh_dec, thresh_pause, thresh_drift, dur_pause, offset=0):
    """
    Get the reaction time for a single trial
    input:
    trial_data: pandas data set with one line per new stimulus, all from one trial, contains at least the fields "p_in",
     "p_in_diff",
    "time"
    thresh_dec: the boundary for a "go" decision
    thresh_pause: the boundary to stop a motor plan
    thresh_drift: the boundary to change the drift rate
    dur_pause: the duration of a drift stop

    output: RT, reaction time in seconds
    """

    dec = offset
    drift = trial_data['p_in']
    # normalize the drift rate so that it can be positive and negative:
    drift = drift - 0.5
    diff = trial_data['p_in_diff']
    # find the time between presentations of one stimulus
    delta_t = trial_data['time'].iloc[1] - trial_data['time'].iloc[0]

    # initialize some values
    idx = 0
    drift_val = 0

    # while the decision threshold is not crossed and the trial is not over:
    while abs(dec) < thresh_dec and idx < 15:

        # Check if the new drift rate is taken
        # For now, we use the difference between two points to adjust this, not the difference between the currently
        # used drift and the newly suggested drift
        if diff.iloc[idx] > thresh_drift:
            drift_val = drift.iloc[idx] * 1000

        # compute if we need to stop
        stop_reached = diff.iloc[idx] - thresh_pause

        # drift and stop if needed
        delta_dec = drift_val * (delta_t - np.heaviside(stop_reached, 1) * dur_pause)
        dec += delta_dec
        idx += 1

    # compute the duration of one trial
    duration = trial_data['time'].iloc[idx]

    # compute the distance to the "true" threshold and set this as reaction time.
    overshoot = abs(dec) - thresh_dec
    # define the response in this trial (which boundary was reached)
    go_no = np.heaviside(dec, 0.5)

    RT = duration - overshoot / drift_val
    return RT, go_no


def get_rt_noise(n_trial, noise_level, trial_data, thresh_dec, thresh_pause, thresh_drift, dur_pause, offset=0):
    """
    Get the reaction time for a single trial
    input:
    n_trial: how often to simulate the trial
    noise_level: array with entry 0 = mean, entry 1 = sd
    trial_data: pandas data set with one line per new stimulus, all from one trial, contains at least the fields "p_in", "p_in_diff",
    "time"
    thresh_dec: the boundary for a "go" decision
    thresh_pause: the boundary to stop a motor plan
    thresh_drift: the boundary to change the drift rate
    dur_pause: the duration of a drift stop

    output: RT, reaction time in seconds
    """

    # initialize empty output array
    out_rts = []
    go_nos = []

    for trial in range(1, n_trial):

        dec = offset
        drift = trial_data['p_in']
        # normalize the drift rate so that it can be positive and negative:
        drift = drift - 0.5
        diff = trial_data['p_in_diff']
        # find the time between presentations of one stimulus
        delta_t = trial_data['time'].iloc[1] - trial_data['time'].iloc[0]

        # initialize some values
        idx = 0
        drift_val = 0

        # while the decision threshold is not crossed and the trial is not over:
        while abs(dec) < thresh_dec and idx < 15:

            # Check if the new drift rate is taken
            # For now, we use the difference between two points to adjust this, not the difference between the currently
            # used drift and the newly suggested drift
            if diff.iloc[idx] > thresh_drift:
                drift_val = drift.iloc[idx] * 1000

            # compute if we need to stop
            stop_reached = diff.iloc[idx] - thresh_pause

            # drift and stop if needed
            delta_dec = drift_val * (delta_t - np.heaviside(stop_reached, 1) * dur_pause) + np.random.normal(
                noise_level[0], noise_level[1])
            dec += delta_dec
            idx += 1

        # compute the duration of one trial
        duration = trial_data['time'].iloc[idx]

        # compute the distance to the "true" threshold and set this as reaction time.
        overshoot = abs(dec) - thresh_dec
        # define the response in this trial (which boundary was reached)
        go_no = np.heaviside(dec, 0.5)

        RT = duration - overshoot / drift_val

        out_rts.append(RT)
        go_nos.append(go_no)

    return out_rts, go_nos


