import datetime
from django.utils import timezone
from polls.models import Question

import pytest


@pytest.mark.django_db
def test_was_published_recently_with_future_question():
    """
    was_published_recently() returns False for questions whose pub_date
    is in the future.
    """

    time = timezone.now() + datetime.timedelta(days=30)
    future_question = Question(pub_date=time)
    assert not future_question.was_published_recently()
