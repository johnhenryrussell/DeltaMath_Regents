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

#########################
## READ STANDARD AS DF ##
#########################

df = pd.read_csv(
    r"C:\Users\johnh\OneDrive\Desktop\DeltaMath_Regents\pythonDMtest.csv")
df = pd.DataFrame(df, columns=["Problem ID", "Accuracy"])

df["Accuracy"] = df['Accuracy'].str.rstrip("%").astype(float)/100

#########################################################
## JENKS NATURAL BREAKS by ACCURACY IN CHOSEN STANDARD ##
#########################################################

breaks = jenkspy.jenks_breaks(df["Accuracy"], n_classes=3)

df["cut_jenks"] = pd.cut(df["Accuracy"],
                         bins=breaks,
                         labels=["Hard", "Normal", "Easy"],
                         include_lowest=True)

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

df["weights"] = df["cut_jenks"].apply(weight_calc_easy)

##############################
## CONVERT COLUMNS TO LISTS ##
##############################

weight_list = df["weights"].tolist()
question_list = df["Problem ID"].tolist()

#############################################
## CHOOSE ONE QUESTION FROM GIVEN STANDARD ##
#############################################

chosen_q = (random.choices(question_list, weights=(weight_list), k=1))

print(chosen_q)
