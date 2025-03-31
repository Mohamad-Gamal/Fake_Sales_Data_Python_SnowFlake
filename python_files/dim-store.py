#import python libraries 
import pandas as pd
import csv
import random 
from faker import Faker

#Initialize
faker = Faker()

#input the number of rows that the csv file should have 

num_rows=int(input(" Enter the number of rows the csv file should have : "))

# details of the excel file that has the lookup data , File Path and Name , Sheet Name and column names where the data is present 

excel_file_path_name = "C:\\Users\\gimep\\OneDrive\\Desktop\\EndtoEndSalesProject-master\\sales-project\\LookupFile.xlsx"
excel_sheet_name = "Store Name Data"
adjective_column_name  = "Adjectives"
noun_column_name = "Nouns"



#input the name of the csv file (e.g data.csv)

csv_file = input ( " enter the name of the csv file like data.csv : ")
path = "C:\\Users\\gimep\\OneDrive\\Desktop\\EndtoEndSalesProject-master\\sales-project\\"
csv_file = path + csv_file

#fetch this sheet data in a dataframe 

df = pd.read_excel(excel_file_path_name,sheet_name=excel_sheet_name)

#open the csv file 
with open(csv_file,mode="w",newline='') as file:
    writer = csv.writer(file)
    
    #create the header 
    header=['StoreName','StoreType','StoreOpeningDate','Address','City','State','Country','Region','Manager Name']
    
    #write the header to the csv file 
    writer.writerow(header)
    
    #loop and generate multiple rows 
    for _ in range(num_rows):

        #Select a random Adjective and Noun and we are going to concatenate it with the word "The" and finally use that as our store name 
        random_adjective=df[adjective_column_name].sample(n=1).values[0]
        random_noun=df[noun_column_name].sample(n=1).values[0]
        store_name= f"The {random_adjective} {random_noun}"

        #Generate a Single row 
        row = [
        store_name,
        random.choice(['Exclusive','MBO','SMB','Outlet Stores']),
        faker.date(),
        faker.address().replace("\n"," ").replace(","," "),
        faker.city(),
        faker.state(),
        faker.country(),
        random.choice(['North','South','East','West']),
        faker.first_name()
        ]
        # write the row to the csv file 

        writer.writerow(row)
    #print success statement 

    print(" the process completed Successfully")