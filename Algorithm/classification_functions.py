import random
import pandas as pd
import jenkspy


def assign_difficulty(question_data):
    """
    Assigns a difficulty level to each question in the given `question_data`
    based on the accuracy of responses in each cluster.

    Parameters:
        question_data (pandas.DataFrame): The DataFrame containing the question data.

    Returns:
        pandas.DataFrame: The updated DataFrame with the 'Difficulty' column assigned.

    """
    # Iterate over the clusters in the question data
    for i in range(6):
        # Get the subset of the question data corresponding to the current cluster
        col_edit = get_cluster_data(question_data, i)
        # Calculate the natural breaks for accuracy within this cluster
        breaks = jenkspy.jenks_breaks(col_edit["Accuracy"], n_classes=3)
        # Define the labels for the difficulty levels
        difficulty_labels = ["Hard", "Normal", "Easy"]
        # Assign the difficulty levels to the questions in this cluster
        question_data = assign_cluster_difficulty(
            question_data, col_edit, breaks, difficulty_labels, i
        )
    return question_data


def get_cluster_data(question_data, cluster_num):
    """
    Returns the subset of `question_data` corresponding to the given `cluster_num`.

    Parameters:
        question_data (pandas.DataFrame): The DataFrame containing the question data.
        cluster_num (int): The cluster number for which to retrieve the data.

    Returns:
        pandas.DataFrame: The subset of `question_data` corresponding to `cluster_num`.

    """
    return question_data.loc[question_data["Cluster_num"] == cluster_num]


def assign_cluster_difficulty(
    question_data, col_edit, breaks, difficulty_labels, cluster_num
):
    """
    Assigns a difficulty level to each question in the given subset of `question_data`
    based on the accuracy of responses in that subset.

    Parameters:
        question_data (pandas.DataFrame): The DataFrame containing the question data.
        col_edit (pandas.DataFrame): The subset of `question_data` to which difficulty levels will be assigned.
        breaks (list): The breakpoints for the jenks natural breaks algorithm.
        difficulty_labels (list): The labels for the difficulty levels to be assigned.
        cluster_num (int): The cluster number for which difficulty levels are being assigned.

    Returns:
        pandas.DataFrame: The updated DataFrame with the 'Difficulty' column assigned for the given cluster.

    """

    # Use the pandas cut method to assign a difficulty level based on the accuracy
    # of responses in the given subset of `question_data`.
    question_data.loc[
        question_data["Cluster_num"] == cluster_num, "Difficulty"
    ] = pd.cut(
        col_edit["Accuracy"],
        bins=breaks,
        labels=difficulty_labels,
        include_lowest=True,
    )

    # Return the updated DataFrame with the 'Difficulty' column assigned for the given cluster.
    return question_data
