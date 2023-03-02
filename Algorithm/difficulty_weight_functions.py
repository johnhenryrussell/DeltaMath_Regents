import pandas as pd


def calculate_weight(difficulty):
    """
    Returns a tuple of weights for a given difficulty.

    Parameters:
        difficulty (str): The difficulty of the problem, must be one of
        "Easy", "Normal", or "Hard".

    Returns:
        tuple of ints: The weights for the given difficulty, in the order
        (easy_weight, normal_weight, hard_weight).
    """
    if difficulty == "Easy":
        return (75, 20, 0)
    elif difficulty == "Normal":
        return (25, 70, 25)
    elif difficulty == "Hard":
        return (0, 10, 75)
    else:
        return (0, 0, 0)


def get_weight_and_question_lists(data_frame):
    """
    Returns the list of easy weights, normal weights, hard weights, and
    problem IDs.

    Parameters:
        data_frame (pandas.DataFrame): The dataframe containing the weights
        and problem IDs.

    Returns:
        tuple of list of ints and list of strs: The list of easy weights,
        normal weights, hard weights, and problem IDs, in that order.
    """
    easy_weight = data_frame["easy_weight"].tolist()
    normal_weight = data_frame["normal_weight"].tolist()
    hard_weight = data_frame["hard_weight"].tolist()
    question = data_frame["Problem ID"].tolist()

    return easy_weight, normal_weight, hard_weight, question
