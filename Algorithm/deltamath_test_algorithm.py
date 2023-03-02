"""Module providing random algorithms"""
import random
import pandas as pd
import jenkspy

##############################################
## RANDOMLY PICK CLUSTER IN CHOSEN STANDARD ##
##############################################

numberList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
clust_list = (random.choices(numberList, weights=(2.41, 8.69, 2.38, 8.49, 0.36, 2.67,
                                                  9.15, 13.99, 6.45, 2.83, 1.47,
                                                  29.99, 2.07, 8.49, 0.57), k=10))

#################################
## READ AND ORGANIZE DATAFRAME ##
#################################


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
    df = pd.read_csv(file_path)
    df = pd.DataFrame(
        df, columns=["Problem ID", "Accuracy", "Standard", "Cluster"])
    df["Accuracy"] = df['Accuracy'].str.rstrip("%").astype(float)/100
    return df


def assign_numbers_to_values(df, col_name="Cluster"):
    """
    Assigns a unique number to each distinct value in a specified column of a 
    pandas DataFrame.

    Parameters:
        df (pandas.DataFrame): The DataFrame containing the column to assign 
        numbers to.
        col_name (str): The name of the column to assign numbers to.

    Returns:
        None. The function modifies the DataFrame in place by adding a new 
        column with the
        suffix '_num' to store the assigned numbers.
    """
    unique_values = df[col_name].unique().tolist()
    value_to_number = {val: i for i, val in enumerate(unique_values)}
    df[f'{col_name}_num'] = df[col_name].apply(lambda x: value_to_number[x])
    return df


dataFrame = read_csv_to_dataframe(
    r"C:\Users\johnh\OneDrive\Desktop\DeltaMath_Regents\Algorithm\CSV FILES\questiondataDM.csv")
assign_numbers_to_values(dataFrame)


#########################################################
## JENKS NATURAL BREAKS by ACCURACY IN CHOSEN STANDARD ##
#########################################################

def assign_difficulty(df):
    """
    The assign_difficulty function takes a pandas DataFrame as input and 
    assigns a difficulty level to each data point based on its cluster and accuracy score.

Parameters:

    df (pandas DataFrame): a pandas DataFrame containing at least the columns 
    "Cluster_num" and "Accuracy".

Returns:

    df (pandas DataFrame): a pandas DataFrame with a new column "Difficulty" 
    that assigns a difficulty level to each data point based on its cluster and accuracy score.

Algorithm:

    (1) For each cluster in the range 0-5, the function selects the data 
    points in that cluster using boolean indexing.

    (2) Jenks natural breaks optimization is applied to the accuracy scores in 
    that cluster to generate three distinct breakpoints.

    (3) Using the pd.cut() function, the accuracy scores are then labeled as
    "Hard", "Normal", or "Easy" based on which range they fall in (determined 
    by the breakpoints).

    (4) The "Difficulty" column in the original DataFrame is updated to
    reflect the new labels for the accuracy scores in that cluster.

    (5) The updated DataFrame is then returned.
    """
    for i in range(6):
        col_edit = df.loc[df["Cluster_num"] == i]
        breaks = jenkspy.jenks_breaks(col_edit["Accuracy"], n_classes=3)
        df.loc[df["Cluster_num"] == i, "Difficulty"] = pd.cut(col_edit["Accuracy"],
                                                              bins=breaks,
                                                              labels=[
                                                                  "Hard", "Normal", "Easy"],
                                                              include_lowest=True)
    return df


assign_difficulty(dataFrame)
print(dataFrame.to_markdown())

# breaks = jenkspy.jenks_breaks(dataFrame["Accuracy"], n_classes=3)

# dataFrame["cut_jenks"] = pd.cut(dataFrame["Accuracy"],
#                          bins=breaks,
#                          labels=["Hard", "Normal", "Easy"],
#                          include_lowest=True)

#####################################################
## FUNCTION FOR EACH DIFFICULTY *arbitrary weight* ##
#####################################################


def weight_calc_easy(diff):
    """Function returning weights for difficulty"""
    if diff == "Easy":
        return 75
    elif diff == "Normal":
        return 25
    elif diff == "Hard":
        return 0
    else:
        return 0


################################
## ASSIGN WEIGHTS TO EACH ROW ##
################################

dataFrame["weights"] = dataFrame["Difficulty"].apply(weight_calc_easy)

##############################
## CONVERT COLUMNS TO LISTS ##
##############################

weight_list = dataFrame["weights"].tolist()
question_list = dataFrame["Problem ID"].tolist()

#############################################
## CHOOSE ONE QUESTION FROM GIVEN STANDARD ##
#############################################

chosen_q = (random.choices(question_list, weights=(weight_list), k=1))

print(chosen_q)
