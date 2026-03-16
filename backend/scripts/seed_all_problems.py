import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.problem import Problem
from app.models.test_case import TestCase
import uuid

def seed_all_problems():
    db = SessionLocal()
    
    try:
        # Get all problems
        problems = db.query(Problem).all()
        
        for problem in problems:
            print(f"\nProcessing: {problem.title}")
            
            # Clear existing test cases
            db.query(TestCase).filter(TestCase.problem_id == problem.id).delete()
            
            # Update based on problem title
            if "Two Sum" in problem.title:
                problem.description = """# Two Sum

Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

You can return the answer in any order.

## Example 1:
```
Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Explanation: Because nums[0] + nums[1] == 9, we return [0, 1].
```

## Example 2:
```
Input: nums = [3,2,4], target = 6
Output: [1,2]
```

## Constraints:
- 2 <= nums.length <= 10^4
- -10^9 <= nums[i] <= 10^9
- Only one valid answer exists."""
                
                problem.slug = "two-sum"
                problem.source = "leetcode"
                
                test_cases = [
                    TestCase(id=uuid.uuid4(), problem_id=problem.id, 
                            input_data='{"nums": [2,7,11,15], "target": 9}', 
                            expected_output='[0,1]', is_hidden=False, order_index=0),
                    TestCase(id=uuid.uuid4(), problem_id=problem.id,
                            input_data='{"nums": [3,2,4], "target": 6}',
                            expected_output='[1,2]', is_hidden=False, order_index=1),
                    TestCase(id=uuid.uuid4(), problem_id=problem.id,
                            input_data='{"nums": [3,3], "target": 6}',
                            expected_output='[0,1]', is_hidden=False, order_index=2),
                ]
                
            elif "Best Time to Buy and Sell Stock" in problem.title:
                problem.description = """# Best Time to Buy and Sell Stock

You are given an array prices where prices[i] is the price of a given stock on the ith day.

You want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock.

Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return 0.

## Example 1:
```
Input: prices = [7,1,5,3,6,4]
Output: 5
Explanation: Buy on day 2 (price = 1) and sell on day 5 (price = 6), profit = 6-1 = 5.
```

## Example 2:
```
Input: prices = [7,6,4,3,1]
Output: 0
Explanation: No profit can be made.
```

## Constraints:
- 1 <= prices.length <= 10^5
- 0 <= prices[i] <= 10^4"""
                
                problem.slug = "best-time-to-buy-and-sell-stock"
                problem.source = "leetcode"
                
                test_cases = [
                    TestCase(id=uuid.uuid4(), problem_id=problem.id,
                            input_data='{"prices": [7,1,5,3,6,4]}',
                            expected_output='5', is_hidden=False, order_index=0),
                    TestCase(id=uuid.uuid4(), problem_id=problem.id,
                            input_data='{"prices": [7,6,4,3,1]}',
                            expected_output='0', is_hidden=False, order_index=1),
                    TestCase(id=uuid.uuid4(), problem_id=problem.id,
                            input_data='{"prices": [2,4,1]}',
                            expected_output='2', is_hidden=False, order_index=2),
                ]
            else:
                # Generic description for other problems
                problem.description = f"""# {problem.title}

Problem description coming soon...

## Constraints:
- TBD"""
                problem.slug = problem.title.lower().replace(" ", "-")
                problem.source = "leetcode"
                test_cases = []
            
            # Add test cases
            for tc in test_cases:
                db.add(tc)
            
            db.commit()
            print(f"✓ Updated {problem.title} with {len(test_cases)} test cases")
            
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    seed_all_problems()
