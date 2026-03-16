from pydantic import BaseModel
from uuid import UUID
from typing import Optional, List


class TestCaseBase(BaseModel):
    input_data: str
    expected_output: str
    is_hidden: bool = False
    order_index: int = 0


class TestCaseResponse(TestCaseBase):
    id: UUID
    problem_id: UUID

    class Config:
        from_attributes = True


class ProblemResponse(BaseModel):
    id: UUID
    title: str
    difficulty: str
    leetcode_url: Optional[str] = None

    class Config:
        from_attributes = True


class ProblemDetailResponse(BaseModel):
    id: UUID
    title: str
    slug: Optional[str] = None
    difficulty: str
    source: Optional[str] = None
    description: Optional[str] = None
    test_cases: List[TestCaseResponse] = []

    class Config:
        from_attributes = True
