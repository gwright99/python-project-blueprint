# __main__.py
from .app import Blueprint

if __name__ == '__main__':
    Blueprint.run()
    # This is how we can run the whole package using "python -m blueprint" (and it will ONLY be run with
    # this command).)
