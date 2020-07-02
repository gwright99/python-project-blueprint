# test_app.py
from .context import blueprint


# Capsys = built-in Pytest fixture (capture system output).
# This will check the standard output of Blueprint.run()
def test_app(capsys, example_fixture):
    # pylint: disable=W0612,W0613
    blueprint.Blueprint.run()
    captured = capsys.readouterr()

    assert "Hello World!" in captured.out
