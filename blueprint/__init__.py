# __init__.py
from .app import Blueprint

x = Blueprint()

# Note: Flake8 doesn't like unused imports but Heinz says I need
# this to stop people from importing subcomponents. Creating BS if.
if x:
    pass
else:
    print('There was an error importing Blueprint.')
