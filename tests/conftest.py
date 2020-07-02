# conftest.py
# All custom fixtures should reside here - this is automatically discovered by Pytest. No import needed.
import logging
import pytest

LOGGER = logging.getLogger(__name__)


# Simple fixture. Logs message, allows test to excute, then logs final message.
@pytest.fixture(scope='function')
def example_fixture():
    LOGGER.info("Setting up Example Fixture...")
    yield
    LOGGER.info("Tearing Down Example Fixture...")
