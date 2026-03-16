import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.problem import Problem
from app.models.test_case import TestCase
import uuid

def seed_test_cases():
    db = SessionLocal()
    
    try:
        # Get Two Sum problem (you'll need to adjust based on your actual problem)
        two_sum = db.query(Problem).filter(Problem.title == "Two Sum").first()
        
        if two_sum:
            # Clear existing test cases
            db.query(TestCase).filter(TestCase.problem_id == two_sum.id).delete()
            
            # Add test cases for Two Sum
            test_cases = [
                TestCase(
                    id=uuid.uuid4(),
                    problem_id=two_sum.id,
                    input_data='{"nums": [2,7,11,15], "target": 9}',
                    expected_output='[0,1]',
                    is_hidden=False,
                    order_index=0
                ),
                TestCase(
                    id=uuid.uuid4(),
                    problem_id=two_sum.id,
                    input_data='{"nums": [3,2,4], "target": 6}',
                    expected_output='[1,2]',
                    is_hidden=False,
                    order_index=1
                ),
                TestCase(
                    id=uuid.uuid4(),
                    problem_id=two_sum.id,
                    input_data='{"nums": [3,3], "target": 6}',
                    expected_output='[0,1]',
                    is_hidden=False,
                    order_index=2
                ),
                TestCase(
                    id=uuid.uuid4(),
                    problem_id=two_sum.id,
                    input_data='{"nums": [1,5,3,7,8,9], "target": 12}',
                    expected_output='[2,5]',
                    is_hidden=True,
                    order_index=3
                ),
            ]
            
            for tc in test_cases:
                db.add(tc)
            
            db.commit()
            print(f"✓ Added {len(test_cases)} test cases for Two Sum")
        else:
            print("Two Sum problem not found. Please seed problems first.")
            
    except Exception as e:
        print(f"Error seeding test cases: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_test_cases()
