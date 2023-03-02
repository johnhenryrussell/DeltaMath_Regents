import random
import pandas as pd


def generate_cluster_list(question_data, k: int) -> list:
    """
    Generates a list of clusters based on their assigned weights.

    Parameters:
        question_data (pandas.DataFrame): The dataframe containing the questions
            and their assigned weights.
        k (int): The number of clusters to generate.

    Returns:
        list: A list of clusters.
    """

    # Get the list of unique cluster numbers from the dataframe
    number_list = question_data["Cluster_num"].unique().tolist()

    # Set the weights for each cluster
    WEIGHTS = [2.41, 8.69, 2.38, 8.49, 0.36, 2.67]

    # Use random.choices to generate a list of k clusters based on the weights
    clust_list = random.choices(number_list, weights=WEIGHTS, k=k)

    return clust_list


def choose_questions(chosen_weight, question_data, k):
    """
    Chooses k questions from a dataframe based on their assigned weights.

    Parameters:
        question_data (pandas.DataFrame): The dataframe containing the questions
            and their assigned weights.
        k (int): The number of questions to choose.

    Returns:
        list: A list of chosen questions.
    """

    # Generate a list of k cluster numbers to choose from
    clust_list = generate_cluster_list(question_data, k)

    # Initialize list to hold the chosen questions
    chosen_questions = []

    # Initialize counter to keep track of question numbers
    count = 1

    # Loop through the list of cluster numbers
    for index in clust_list:
        # Select the rows from question_data that match the current cluster number
        cluster_df = question_data[question_data["Cluster_num"] == index]

        # Use the easy_weight column to choose one question from the cluster
        chosen_q = random.choices(
            cluster_df["Problem ID"].tolist(),
            weights=cluster_df[chosen_weight].tolist(),
            k=1,
        )

        # Append the chosen question to the list of chosen questions
        chosen_questions.append(chosen_q[0])

        # Print out some diagnostic information
        print(f"Question {count}: {chosen_q} | Cluster: {index}")

        # Increment the counter
        count += 1

    # Return the list of chosen questions
    return chosen_questions
