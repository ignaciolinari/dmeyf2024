
# pip install papermill


import papermill as pm

def run_notebook_pipeline():
    notebooks = [
        '2_Feature_Engineering.ipynb',
        '3_Undersampling.ipynb',
        '4_Optimizacion.ipynb',
        '5_Entrenamiento_Sem.ipynb',
        '6_Final_Sem.ipynb',
        '7_Prediccion.ipynb',
        '8_Submit.ipynb'
    ]
    
    # Run notebooks in sequence, with potential parameter passing
    for notebook in notebooks:
        try:
            output_notebook = notebook.replace('.ipynb', '_output.ipynb')
            pm.execute_notebook(
                notebook,
                output_notebook,
                # Optional: pass parameters between notebooks
                parameters={
                    'input_from_previous_notebook': None  # You can pass data between notebooks
                }
            )
            print(f"Successfully executed {notebook}")
        except Exception as e:
            print(f"Error executing {notebook}: {e}")

if __name__ == '__main__':
    run_notebook_pipeline()