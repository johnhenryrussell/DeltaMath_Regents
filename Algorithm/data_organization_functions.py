import pandas as pd


def read_csv_file(file_path):
    """
    Reads a CSV file from a given file path and returns a pandas DataFrame.

    Parameters:
        file_path (str): The path of the CSV file to read.

    Returns:
        pandas.DataFrame: A DataFrame containing all columns from the CSV file.
    """
    # Read the CSV file into a pandas DataFrame
    data_frame = pd.read_csv(file_path)

    # Return the DataFrame
    return data_frame


def select_columns(data_frame):
    """
    Selects specific columns from a pandas DataFrame.

    Parameters:
        data_frame (pandas.DataFrame): The DataFrame to select columns from.

    Returns:
        pandas.DataFrame: A DataFrame containing columns 'Problem ID',
        'Accuracy', 'Standard', and 'Cluster'.
    """
    # Select only the columns we need and create a new DataFrame
    question_data = pd.DataFrame(
        data_frame, columns=["Problem ID", "Accuracy", "Standard", "Cluster"]
    )

    # Return the new DataFrame
    return question_data


def convert_accuracy_to_float(question_data):
    """
    Converts the 'Accuracy' column of a pandas DataFrame to a float between 0 and 1.

    Parameters:
        question_data (pandas.DataFrame): The DataFrame to convert.

    Returns:
        pandas.DataFrame: The converted DataFrame.
    """
    # Convert the 'Accuracy' column to a float between 0 and 1
    # by removing the percentage sign and dividing by 100
    question_data["Accuracy"] = (
        question_data["Accuracy"].str.rstrip("%").astype(float) / 100
    )

    # Return the converted DataFrame
    return question_data
