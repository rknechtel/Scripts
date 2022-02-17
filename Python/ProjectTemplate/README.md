# PythonProjectTemplate

This is a Python Project Template.  

## Example for setting up a Python Virtual Environment (Linux)  

**Create the Virtual Environment (Example):**  
python3 -m venv ~/projects/ProjectTemplate/v-env  

**Activate the Virtual Environment (Example):**  
source ~/projects/ProjectTemplate/v-env/bin/activate  


**Generate Requirements for project:**  
To create requirements.txt:  

1) Setup virtual environment  
2) Install all python packages  
   Example:  
~/projects/ProjectTemplate/v-env/bin/pip3 install <PACKAGE_NAME>
3) Note: Make sure to upgrade pip  
~/projects/ProjectTemplate/v-env/bin/pip3 install --upgrade pip  
4) run:  
[Path to Virtual Environment Bin Directory]/pip3 freeze > requirements.txt  
Example (Linux):  
~/projects/ProjectTemplate/v-env/bin/pip3 freeze > requirements.txt  

**Install the Requirements/Dependancies (Example):**  
~/projects/ProjectTemplate/v-env/bin/pip3 install -r requirements.txt  

