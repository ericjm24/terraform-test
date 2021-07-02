from jinja2 import Template
import os

lib_folder = "vendors"
main_func="main"
terraform_template = "./templates/gcp_function_list.txt"
python_template = "./templates/python_main.txt"

base_dir = os.path.join(os.getcwd(), lib_folder)
#print(base_path)

def check_file_for_function(file, func_name):
    try:
        with open(file, "rt") as f:
            if f"def {func_name}(" in f.read():
                return True
            else:
                return False
    except:
        return False
        
def split_path(path):
    head, tail = os.path.split(path)
    if head and tail:
        head = split_path(head)
    else:
        head = [head]
    return head + [tail]

def get_jinja_files(base, main):
    jinja_files = []
    for dir, _, files in os.walk(base):
        for file in files:
            rel_dir = os.path.relpath(dir, os.getcwd())
            rel_file = os.path.join(rel_dir, file)
            if file.endswith(".py") and check_file_for_function(rel_file, main):
                # Get a normalized unix-style path name regardless of operating system
                file_name = os.path.relpath(rel_file, lib_folder)[:-3]
                file_loc = file_name.split(os.path.sep)
                jinja_files.append({
                    "func_name" : '_'.join(file_loc),
                    "func_path" : '.'.join(file_loc)
                })
                open(os.path.join(rel_dir, "__init__.py"), "a").close()
    return jinja_files

def write_library_files(base, main):
    jf = get_jinja_files(base=base, main=main)

    with open(terraform_template, "rt") as f:
        tf_template = Template(f.read())
    with open(os.path.join(os.getcwd(), "terraform", "gcp_function_list.tfvars"), "wt") as tf_file:
        tf_file.write(tf_template.render(gcp_function_list=jf))

    with open(python_template, "rt") as f:
        py_template = Template(f.read())
    with open(os.path.join(base_dir, "main.py"), "wt") as py_file:
        py_file.write(py_template.render(gcp_function_list=jf))
    open(os.path.join(base, "__init__.py"), "a").close()

if __name__ == "__main__":
    write_library_files(base=base_dir, main=main_func)