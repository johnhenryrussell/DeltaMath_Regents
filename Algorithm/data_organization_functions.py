import pandas as pd


def read_csv_file(file_path):
    """
    Reads a CSV file from a given file path and returns a pandas DataFrame.

    Parameters:
        file_path (str): The path of the CSV file to read.

    Returns:
        pandas.DataFrame: A DataFrame containing all columns from the CSV file.

    Raises:
        FileNotFoundError: If the specified file path does not exist.
    """
    try:
        # Read the CSV file into a pandas DataFrame
        data_frame = pd.read_csv(file_path)
    except FileNotFoundError:
        print(f"Error: File not found at {file_path}")
        return None

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

    Raises:
        ValueError: If any of the required columns are not found in the DataFrame.
    """
    # Check if all the required columns exist in the DataFrame
    required_cols = ["Problem ID", "Accuracy", "Standard", "Cluster"]
    missing_cols = set(required_cols) - set(data_frame.columns)

    if len(missing_cols) > 0:
        raise ValueError(f"Missing columns: {missing_cols}")

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

    Raises:
        ValueError: If the 'Accuracy' column cannot be converted to a float.
    """
    try:
        # Convert the 'Accuracy' column to a float between 0 and 1
        # by removing the percentage sign and dividing by 100
        question_data["Accuracy"] = (
            question_data["Accuracy"].str.rstrip("%").astype(float) / 100
        )
    except ValueError:
        print("Error: 'Accuracy' column could not be converted to float")
        return None

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

    Raises:
        FileNotFoundError: If the specified file path does not exist.
        KeyError: If any of the required columns are missing from the DataFrame.
        ValueError: If the 'Accuracy' column cannot be converted to a float.
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
        pandas.DataFrame: The modified DataFrame with a new column added to store
            the assigned numbers.
    """

    # Get the unique values in the specified column of the DataFrame
    unique_values = get_unique_values(question_data, col_name)

    # Map each unique value to a unique number
    value_to_number = map_values_to_numbers(unique_values)

    # Apply the mapping to the specified column of the DataFrame, creating a new column
    # with the assigned numbers
    question_data[f"{col_name}_num"] = question_data[col_name].apply(
        lambda x: value_to_number[x]
    )

    return question_data
