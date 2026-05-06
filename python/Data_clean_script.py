import pandas as pd
from IPython.display import display, HTML

#Inspect Data
def inspect_data(df):

    display(HTML("<b>--- Total Records and Columns ---</b>"))
    print(f" Rows: {df.shape[0]:,}")
    print(f" Columns: {df.shape[1]:,}\n")

    display(HTML("<b>---- First 5 Rows ----</b>"))
    print(df.head(),"\n")

    display(HTML("<b>---- Last 5 Rows ----</b>"))
    print(df.tail(),"\n")

    display(HTML("<b>---- Info. ----</b>"))
    print(df.info(),"\n")

    display(HTML("<b>---- Description ----</b>"))
    print(df.describe(),"\n")

    #display(HTML("<b>---- Description All Columns ----</b>"))
    #print(df.describe(include='all').T,"\n")

    display(HTML("<b>---- Column Values with Count ----</b>"))
    for col in df.columns:
        #print(df[col].value_counts(dropna=False))
        print(df[col].value_counts(dropna=False).reset_index())
        print("\n")
    
    display(HTML("<b>---- Missing Values - All Columns ----</b>"))
    missing = df.isnull().sum()
    missing_pct = (missing / len(df)) * 100
    missing_df = missing.to_frame(name="Missing_Count")
    missing_df["Missing_Percentage (%)"] = missing_pct.round(2)
    print(missing_df,"\n")

    display(HTML("<b>---- Missing Values Only ----</b>"))
    print(missing_df[missing > 1],"\n")
    
    display(HTML("<b>---- Duplicate Rows ----</b>"))
    print(df.duplicated().sum(),"\n")

    df_source_file = df.copy()
    display(HTML("<br>---- Note: A copy of the file stored as df_source_file ----</br>"))
    

#Inspect anomalies entries in the data
def inspect_anomalies(df):
 
    for col in df.columns:
        display(HTML(f"<b>---- {col} ----</b>"))
            
        col_str = df[col].astype(str)
        print("🔎 Suspicious (string sort) - Ascending:")
        print(col_str.sort_values().head(5),"\n")
        print("🔎 Suspicious (string sort) - Decending:")
        print(col_str.sort_values(ascending=False).head(5),"\n")
        
        try:
            print("📃 Actual (typed sort) - Ascending")
            print(df[col].sort_values().head(5),"\n")
            print("📃 Actual (typed sort) - Decending")
            print(df[col].sort_values(ascending=False).head(5),"\n")
        except:
            print("⚠️ Mixed types - cannot sort natively")

#Select Numerick Columsn only
def numeric_columns(df):
    numeric_df = df.select_dtypes(include = ['int64', 'float64'])
    print(numeric_df)

#Export value count to analyse the values in excel file


def export_value_counts(df, columns, file_name="value_counts_report.xlsx"):
    
    results_dict = {}
    df_clean = df.copy()

    for col in df_clean.select_dtypes(include='object').columns:
        df_clean[col] = df_clean[col].str.encode('utf-8', 'ignore').str.decode('utf-8')

    writer = pd.ExcelWriter(file_name, engine='openpyxl')

    for col in columns:
        vc = df_clean[col].value_counts(dropna=False).reset_index()
        vc.columns = [col, 'Count']
        vc['Percentage (%)'] = (vc['Count'] / len(df_clean) * 100).round(2)

        vc.to_excel(writer, sheet_name=col[:31], index=False)
        results_dict[col] = vc

    writer.close()

    print(f"Exported the Value Counts to {file_name}")
    return #results_dict


#Data Cleaning
def clean_data(df):
    """Data cleaning steps"""

    # 1. Drop duplicate rows
    df = df.drop_duplicates()

    # 2. Drop columns with too many missing values
    df = df.dropna(axis=1, thresh=100)

    # 3. Fill missing values (example strategies)
    for col in df.select_dtypes(include='number'):
        df[col] = df[col].fillna(df[col].mean())

    for col in df.select_dtypes(include='object'):
        df[col] = df[col].fillna(df[col].mode()[0])

    # 4. Convert data types if needed
    # df['date'] = pd.to_datetime(df['date'])

    return df

#Save the clean file
def save_data(df, output_path):
    """Save cleaned data"""
    df.to_csv(output_path, index=False)
    print(f"\nCleaned data saved to {output_path}")

#Main
def main():
    file_path = "data.csv"
    output_path = "cleaned_data.csv"

    df = load_data(file_path)
    inspect_data(df)

    df_cleaned = clean_data(df)
    save_data(df_cleaned, output_path)


if __name__ == "__main__":
    main()
