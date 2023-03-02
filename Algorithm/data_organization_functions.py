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
