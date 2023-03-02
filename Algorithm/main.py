"""Module providing random algorithms"""
import random
import pandas as pd
import jenkspy
from data_organization_functions import (
    read_csv_file,
    select_columns,
    convert_accuracy_to_float,
    read_csv_to_dataframe,
    get_unique_values,
    map_values_to_numbers,
    assign_numbers_to_values,
)
from classification_functions import (
    assign_difficulty,
    get_cluster_data,
    assign_cluster_difficulty,
)
from difficulty_weight_functions import calculate_weight, get_weight_and_question_lists

# #############################################
# ## CHOOSE ONE QUESTION FROM GIVEN STANDARD ##
# #############################################


# def generate_cluster_list(k: int) -> list:
#     """
#     Generates a list of clusters based on their assigned weights.

#     Parameters:
#         k (int): The number of clusters to generate.

#     Returns:
#         list: A list of clusters.
#     """
#     NUMBER_LIST = [0, 1, 2, 3, 4, 5]
#     WEIGHTS = [2.41, 8.69, 2.38, 8.49, 0.36, 2.67]
#     clust_list = random.choices(numberList, weights=weights, k=k)
#     return clust_list


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
    numberList = question_data["Cluster_num"].unique().tolist()
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
