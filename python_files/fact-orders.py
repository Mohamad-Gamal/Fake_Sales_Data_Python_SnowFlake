import pandas as pd
import numpy as np
import csv
import random
import os



# File Path
path = "C:\\Users\\gimep\\OneDrive\\Desktop\\EndtoEndSalesProject-master\\sales-project\\data-csv\\historical-order-data\\"


dateID = '20240728'

for i in range(101):
    num_rows = np.random.randint(1000,10000)
    #dictionary of data
    data = {
        'DateID':dateID,
        'ProductID':np.random.randint(1, 1001, num_rows),
        'StoreID':[i] * num_rows,
        'CustomerID':np.random.randint(1, 1001, num_rows),
        'QuantityOrderded':np.random.randint(1, 21, num_rows),
        'OrderAmount':np.random.randint(100, 1001, num_rows),
    }

    #make dataframe
    orders = pd.DataFrame(data)

    DiscountPercent = np.random.uniform(0.02, 0.15, num_rows)
    ShippingCostPercent = np.random.uniform(0.05, 0.15, num_rows)

    orders['DiscountAmount'] = orders['OrderAmount'] * DiscountPercent
    orders['ShippingCost'] = orders['OrderAmount'] * ShippingCostPercent
    orders['TotalAmount'] = orders['OrderAmount'] - (orders['DiscountAmount'] + orders['ShippingCost'])

    csv_name = f"store_{i}_{dateID}.csv"
    file_path = os.path.join(path, csv_name)
    if os.path.exists(file_path):
        os.remove(file_path)

    orders.to_csv(file_path, index=False)

#print success statement 
print(" the process completed Successfully")