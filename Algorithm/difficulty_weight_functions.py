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

    # Define weights for each difficulty level
    if difficulty == "Easy":
        return (75, 20, 0)
    elif difficulty == "Normal":
        return (25, 70, 25)
    elif difficulty == "Hard":
        return (0, 10, 75)
    else:
        # If the difficulty level is not recognized, return 0 weights for all levels
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
    # Get the list of easy weights from the dataframe
    easy_weight = data_frame["easy_weight"].tolist()

    # Get the list of normal weights from the dataframe
    normal_weight = data_frame["normal_weight"].tolist()

    # Get the list of hard weights from the dataframe
    hard_weight = data_frame["hard_weight"].tolist()

    # Get the list of problem IDs from the dataframe
    question = data_frame["Problem ID"].tolist()

    # Return the list of easy weights, normal weights, hard weights, and problem IDs
    # as a tuple in the order (easy_weight, normal_weight, hard_weight, question)
    return easy_weight, normal_weight, hard_weight, question


def calculate_and_add_weights(dataframe):
    """
    Calculates and adds "easy", "normal", and "hard" weights to a pandas DataFrame
    based on the values in the "Difficulty" column.

    Parameters:
        dataframe (pandas.DataFrame): The DataFrame to which weights will be added.

    Returns:
        None
    """

    # Define the names of the columns that will hold the weights
    weight_cols = ["easy_weight", "normal_weight", "hard_weight"]

    # Use apply function to calculate the weights for each row based on the difficulty
    # and store the result as a DataFrame
    weights = dataframe.apply(
        lambda row: pd.Series(calculate_weight(row["Difficulty"])), axis=1
    )

    # Add the new columns to the original DataFrame using the weights DataFrame
    dataframe[weight_cols] = weights
