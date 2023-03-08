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
from difficulty_weight_functions import (
    calculate_weight,
    get_weight_and_question_lists,
    calculate_and_add_weights,
)
from question_selector_functions import (
    generate_cluster_list,
    choose_questions,
    get_difficulty,
)


if __name__ == "__main__":
    question_data = read_csv_to_dataframe(
        r"C:\Users\johnh\OneDrive\Desktop\DeltaMath_Regents\Algorithm\CSV FILES\questiondataDM.csv"
    )

    assign_numbers_to_values(question_data)
    assign_difficulty(question_data)
    calculate_and_add_weights(question_data)

    (
        easy_weight_list,
        normal_weight_list,
        hard_weight_list,
        question_list,
    ) = get_weight_and_question_lists(question_data)

    choose_questions(get_difficulty(), question_data, 10)
