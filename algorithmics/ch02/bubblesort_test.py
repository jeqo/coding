from bubblesort import sort 
def test_bubblesort():
    res = sort(["dog","body","typical","dogma","sun"])
    assert res == ["body","dog","dogma","sun","typical"]
