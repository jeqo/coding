
from hanoi_towers import hanoi
def test_hanoi():
    res = hanoi(3)
    assert res == [
        "A -> B",
        "A -> C",
        "B -> C",
        "A -> B",
        "C -> A",
        "C -> B",
        "A -> B",
    ]
