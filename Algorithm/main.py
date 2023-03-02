"""Module providing random algorithms"""
import random
import pandas as pd
import jenkspy
from data_organization_functions import (
    read_csv_file,
    select_columns,
    convert_accuracy_to_float,
)


# def read_csv_file(file_path):
#     """
#     Reads a CSV file from a given file path and returns a pandas DataFrame.

#     Parameters:
#         file_path (str): The path of the CSV file to read.

#     Returns:
#         pandas.DataFrame: A DataFrame containing all columns from the CSV file.
#     """
#     # Read the CSV file into a pandas DataFrame
#     data_frame = pd.read_csv(file_path)

#     # Return the DataFrame
#     return data_frame


# def select_columns(data_frame):
#     """
#     Selects specific columns from a pandas DataFrame.

#     Parameters:
#         data_frame (pandas.DataFrame): The DataFrame to select columns from.

#     Returns:
#         pandas.DataFrame: A DataFrame containing columns 'Problem ID',
#         'Accuracy', 'Standard', and 'Cluster'.
#     """
#     # Select only the columns we need and create a new DataFrame
#     question_data = pd.DataFrame(
#         data_frame, columns=["Problem ID", "Accuracy", "Standard", "Cluster"]
#     )

#     # Return the new DataFrame
#     return question_data


# def convert_accuracy_to_float(question_data):
#     """
#     Converts the 'Accuracy' column of a pandas DataFrame to a float between 0 and 1.

#     Parameters:
#         question_data (pandas.DataFrame): The DataFrame to convert.

#     Returns:
#         pandas.DataFrame: The converted DataFrame.
#     """
#     # Convert the 'Accuracy' column to a float between 0 and 1
#     # by removing the percentage sign and dividing by 100
#     question_data["Accuracy"] = (
#         question_data["Accuracy"].str.rstrip("%").astype(float) / 100
#     )

#     # Return the converted DataFrame
#     return question_data


def read_csv_to_dataframe(file_path):
    """
    Reads a CSV file from a given file path and returns a pandas DataFrame
    with specific columns.

    Parameters:
        file_path (str): The path of the CSV file to read.

    Returns:
        pandas.DataFrame: A DataFrame containing columns 'Problem ID',
        'Accuracy', 'Standard', and 'Cluster'.
        The 'Accuracy' column is converted to a float between 0 and 1 by
        removing the percentage sign and dividing by 100.
    """
    # Read the CSV file into a pandas DataFrame
    data_frame = read_csv_file(file_path)

    # Select specific columns from the DataFrame
    question_data = select_columns(data_frame)

    # Convert the 'Accuracy' column to a float between 0 and 1
    question_data = convert_accuracy_to_float(question_data)

    # Return the new DataFrame
    return question_data


def get_unique_values(data, col_name):
    """
    Returns a list of unique values in a specified column of a pandas DataFrame.

    Parameters:
        data (pandas.DataFrame): The DataFrame containing the column.
        col_name (str): The name of the column to get unique values from.

    Returns:
        A list of unique values in the specified column.
    """
    return data[col_name].unique().tolist()


def map_values_to_numbers(unique_values):
    """
    Creates a dictionary that maps each unique value in a list to a unique number.

    Parameters:
        unique_values (list): A list of unique values.

    Returns:
        A dictionary that maps each unique value to a unique number.
    """
    # Create an empty dictionary to hold the mapping of values to numbers
    value_to_number = {}

    # Loop over the unique values and assign a unique number to each one
    for i, val in enumerate(unique_values):
        value_to_number[val] = i

    # Return the dictionary
    return value_to_number


def assign_numbers_to_values(question_data, col_name="Cluster"):
    """
    Assigns a unique number to each distinct value in a specified column of a
    pandas DataFrame.

    Parameters:
        question_data (pandas.DataFrame): The DataFrame containing the column to assign
        numbers to.
        col_name (str): The name of the column to assign numbers to.

    Returns:
        None. The function modifies the DataFrame in place by adding a new
        column with the
        suffix '_num' to store the assigned numbers.
    """
    unique_values = get_unique_values(question_data, col_name)
    value_to_number = map_values_to_numbers(unique_values)
    question_data[f"{col_name}_num"] = question_data[col_name].apply(
        lambda x: value_to_number[x]
    )
    return question_data


def assign_difficulty(question_data):
    """
    Takes a pandas DataFrame as input and assigns a difficulty level to
    each data point based on its cluster and accuracy score.

    Parameters:
        question_data (pandas DataFrame): a pandas DataFrame containing at
        least the columns "Cluster_num" and "Accuracy".

    Returns:
        question_data (pandas DataFrame): a pandas DataFrame with a new column
        "Difficulty" that assigns a difficulty level to each data point based
        on its cluster and accuracy score.

    Algorithm:
        (1) For each cluster in the range 0-5, the function selects the data
        points in that cluster using boolean indexing.

        (2) Jenks natural breaks optimization is applied to the accuracy
        scores in that cluster to generate three distinct breakpoints.

        (3) Using the pd.cut() function, the accuracy scores are then labeled
        as "Hard", "Normal", or "Easy" based on which range they fall in
        (determined by the breakpoints).

        (4) The "Difficulty" column in the original DataFrame is updated to
        reflect the new labels for the accuracy scores in that cluster.

        (5) The updated DataFrame is then returned.
    """
    for i in range(6):
        col_edit = question_data.loc[question_data["Cluster_num"] == i]
        breaks = jenkspy.jenks_breaks(col_edit["Accuracy"], n_classes=3)
        question_data.loc[question_data["Cluster_num"] == i, "Difficulty"] = pd.cut(
            col_edit["Accuracy"],
            bins=breaks,
            labels=["Hard", "Normal", "Easy"],
            include_lowest=True,
        )
    return question_data


#####################################################
## FUNCTION FOR EACH DIFFICULTY *arbitrary weight* ##
#####################################################


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


################################
## ASSIGN WEIGHTS TO EACH ROW ##
################################


#############################
# CONVERT COLUMNS TO LISTS ##
#############################


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


# #############################################
# ## CHOOSE ONE QUESTION FROM GIVEN STANDARD ##
# #############################################


def choose_questions(question_data, questDiff, k):
    """
    Chooses k questions from a dataframe based on their assigned weights.

    Parameters:
        dataframe (pandas.DataFrame): The dataframe containing the questions
        and their assigned weights.
        k (int): The number of questions to choose.

    Returns:
        list: A list of chosen questions.
    """
    numberList = [0, 1, 2, 3, 4, 5]
    clust_list = random.choices(
        numberList, weights=(2.41, 8.69, 2.38, 8.49, 0.36, 2.67), k=k
    )

    chosen_questions = []
    count = 1
    for index in clust_list:
        cluster_df = question_data[question_data["Cluster_num"] == index]
        chosen_q = random.choices(
            cluster_df["Problem ID"].tolist(),
            weights=cluster_df["easy_weight"].tolist(),
            k=1,
        )
        chosen_questions.append(chosen_q[0])
        print(f"Question {count}: {chosen_q} | Cluster: {index}")
        count += 1

    return chosen_questions


### ALGORITHM ###

if __name__ == "__main__":
    question_data = read_csv_to_dataframe(
        r"C:\Users\johnh\OneDrive\Desktop\DeltaMath_Regents\Algorithm\CSV FILES\questiondataDM.csv"
    )
    assign_numbers_to_values(question_data)
    assign_difficulty(question_data)
    # print(question_data.to_markdown())

    question_data[
        ["easy_weight", "normal_weight", "hard_weight"]
    ] = question_data.apply(
        lambda row: pd.Series(calculate_weight(row["Difficulty"])), axis=1
    )

    (
        easy_weight_list,
        normal_weight_list,
        hard_weight_list,
        question_list,
    ) = get_weight_and_question_lists(question_data)

    choose_questions(question_data, easy_weight_list, 10)

    count = 0
