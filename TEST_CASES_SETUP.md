# Test Cases Setup Guide

## What Changed

Test cases are now stored in the database instead of being hardcoded in the frontend. Each problem can have multiple test cases with:
- Input data (JSON format)
- Expected output
- Hidden flag (for submission-only tests)
- Order index

## Database Setup

### 1. Run the migration
```bash
cd backend
alembic upgrade head
```

### 2. Seed test cases
```bash
cd backend
python scripts/seed_test_cases.py
```

## Backend Changes

### New Model: `TestCase`
- Located at: `backend/app/models/test_case.py`
- Fields: id, problem_id, input_data, expected_output, is_hidden, order_index

### Updated Model: `Problem`
- Added relationship to test_cases

### New API Endpoint
- `GET /api/v1/problems/{problem_id}/detail` - Returns problem with test cases

### Schema Updates
- `TestCaseResponse` - For returning test case data
- `ProblemDetailResponse` - For returning problem with test cases

## Frontend Changes

### Updated: `app/problems/[id]/page.tsx`
- Fetches problem and test cases from API
- Dynamically displays test cases
- Filters hidden test cases (only shown on submit)
- Uses problem data from backend

## Adding Test Cases for New Problems

Edit `backend/scripts/seed_test_cases.py` and add:

```python
problem = db.query(Problem).filter(Problem.title == "Your Problem").first()

test_cases = [
    TestCase(
        id=uuid.uuid4(),
        problem_id=problem.id,
        input_data='{"param1": "value1", "param2": "value2"}',
        expected_output='expected result',
        is_hidden=False,
        order_index=0
    ),
]
```

## Notes

- `is_hidden=True` test cases are only used for final submission validation
- `is_hidden=False` test cases are shown to users for testing
- Input data should be in JSON format for easy parsing
- Order index determines display order
