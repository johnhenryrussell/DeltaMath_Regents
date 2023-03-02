# DeltaMath_Regents

The Algorithm:
1.     Load a CSV file(s) of questions into the algorithm.
2.    Extract the necessary columns and convert accuracy values to a float between 0 and 1 to create a data frame called "question_data".
3.    Use the Jenks Natural Breaks statistical technique to categorize questions into "Easy", "Normal", and "Hard" difficulty levels based on accuracy scores.
4.    Assign weight tuples to each level of difficulty to differentiate between assessments, with each tuple representing the weight that each question carries in the assessment process.
5.    Select k clusters based on cluster weights determined from DeltaMath data.
6.    From each selected cluster, choose one question to generate a personalized assessment.
7.    Return the "Problem ID" and "Cluster" for the selected questions.
