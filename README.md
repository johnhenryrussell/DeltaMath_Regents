# Algebra I Assessment Generator

This algorithm generates personalized Algebra I assessments by selecting k randomized questions of varying difficulty levels for a chosen standard. It requires a CSV file of questions, which can be provided as a single file or separate files for each standard. The algorithm extracts the necessary columns and converts accuracy values to a float between 0 and 1 to create a data frame called "question_data". 

Using the Jenks Natural Breaks statistical technique, the algorithm categorizes questions into "Easy", "Normal", and "Hard" difficulty levels based on accuracy scores. The algorithm assigns weight tuples to each level of difficulty to differentiate between assessments, with each tuple representing the weight that each question carries in the assessment process. For example, an "Easy" question has a weight tuple of (75, 20, 0), meaning it contributes 75% to the "Easy" difficulty level, 20% to the "Normal" level, and 0% to the "Hard" level. 

The algorithm selects k clusters based on cluster weights determined from DeltaMath data, from which one question is chosen from each to generate a personalized assessment. The algorithm returns the "Problem ID" and "Cluster" for the selected questions. 

## Usage

To use the algorithm, you must first prepare your question data in a CSV format. The CSV file should contain the following columns: "Problem ID," "Accuracy" "Standard," and "Cluster." You can provide one CSV file containing questions for multiple standards, or separate CSV files for each standard.

## Credits

This algorithm was developed by John Russell for DeltaMath.
