import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.problem import Problem
from app.models.test_case import TestCase
from sqlalchemy import text
import uuid

def seed_leetcode_100():
    db = SessionLocal()
    
    try:
        # Clear existing data in correct order (foreign keys first)
        print("Clearing existing data...")
        db.execute(text("DELETE FROM test_cases"))
        db.execute(text("DELETE FROM problem_categories"))
        db.execute(text("DELETE FROM problem_set_items"))
        db.execute(text("DELETE FROM note_problems"))
        db.execute(text("DELETE FROM problems"))
        db.commit()
        print("✓ Cleared existing data")
        
        problems_data = [
            {
                "title": "Two Sum",
                "difficulty": "Easy",
                "slug": "two-sum",
                "description": """# Two Sum

Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

## Example 1:
```
Input: nums = [2,7,11,15], target = 9
Output: [0,1]
```

## Example 2:
```
Input: nums = [3,2,4], target = 6
Output: [1,2]
```

## Constraints:
- 2 <= nums.length <= 10^4
- -10^9 <= nums[i] <= 10^9""",
                "test_cases": [
                    ('{"nums": [2,7,11,15], "target": 9}', '[0,1]', False),
                    ('{"nums": [3,2,4], "target": 6}', '[1,2]', False),
                    ('{"nums": [3,3], "target": 6}', '[0,1]', False),
                ]
            },
            {
                "title": "Best Time to Buy and Sell Stock",
                "difficulty": "Easy",
                "slug": "best-time-to-buy-and-sell-stock",
                "description": """# Best Time to Buy and Sell Stock

You are given an array prices where prices[i] is the price of a given stock on the ith day.

You want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock.

Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return 0.

## Example 1:
```
Input: prices = [7,1,5,3,6,4]
Output: 5
```

## Example 2:
```
Input: prices = [7,6,4,3,1]
Output: 0
```

## Constraints:
- 1 <= prices.length <= 10^5
- 0 <= prices[i] <= 10^4""",
                "test_cases": [
                    ('{"prices": [7,1,5,3,6,4]}', '5', False),
                    ('{"prices": [7,6,4,3,1]}', '0', False),
                    ('{"prices": [2,4,1]}', '2', False),
                ]
            },
            {
                "title": "Valid Parentheses",
                "difficulty": "Easy",
                "slug": "valid-parentheses",
                "description": """# Valid Parentheses

Given a string s containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.

An input string is valid if:
1. Open brackets must be closed by the same type of brackets.
2. Open brackets must be closed in the correct order.

## Example 1:
```
Input: s = "()"
Output: true
```

## Example 2:
```
Input: s = "()[]{}"
Output: true
```

## Example 3:
```
Input: s = "(]"
Output: false
```

## Constraints:
- 1 <= s.length <= 10^4
- s consists of parentheses only '()[]{}'""",
                "test_cases": [
                    ('{"s": "()"}', 'true', False),
                    ('{"s": "()[]{}"}', 'true', False),
                    ('{"s": "(]"}', 'false', False),
                ]
            },
            {
                "title": "Merge Two Sorted Lists",
                "difficulty": "Easy",
                "slug": "merge-two-sorted-lists",
                "description": """# Merge Two Sorted Lists

You are given the heads of two sorted linked lists list1 and list2.

Merge the two lists into one sorted list. The list should be made by splicing together the nodes of the first two lists.

Return the head of the merged linked list.

## Example 1:
```
Input: list1 = [1,2,4], list2 = [1,3,4]
Output: [1,1,2,3,4,4]
```

## Example 2:
```
Input: list1 = [], list2 = []
Output: []
```

## Constraints:
- The number of nodes in both lists is in the range [0, 50]
- -100 <= Node.val <= 100""",
                "test_cases": [
                    ('{"list1": [1,2,4], "list2": [1,3,4]}', '[1,1,2,3,4,4]', False),
                    ('{"list1": [], "list2": []}', '[]', False),
                    ('{"list1": [], "list2": [0]}', '[0]', False),
                ]
            },
            {
                "title": "Maximum Subarray",
                "difficulty": "Medium",
                "slug": "maximum-subarray",
                "description": """# Maximum Subarray

Given an integer array nums, find the subarray with the largest sum, and return its sum.

## Example 1:
```
Input: nums = [-2,1,-3,4,-1,2,1,-5,4]
Output: 6
Explanation: The subarray [4,-1,2,1] has the largest sum 6.
```

## Example 2:
```
Input: nums = [1]
Output: 1
```

## Constraints:
- 1 <= nums.length <= 10^5
- -10^4 <= nums[i] <= 10^4""",
                "test_cases": [
                    ('{"nums": [-2,1,-3,4,-1,2,1,-5,4]}', '6', False),
                    ('{"nums": [1]}', '1', False),
                    ('{"nums": [5,4,-1,7,8]}', '23', False),
                ]
            },
            {
                "title": "Climbing Stairs",
                "difficulty": "Easy",
                "slug": "climbing-stairs",
                "description": """# Climbing Stairs

You are climbing a staircase. It takes n steps to reach the top.

Each time you can either climb 1 or 2 steps. In how many distinct ways can you climb to the top?

## Example 1:
```
Input: n = 2
Output: 2
Explanation: There are two ways to climb to the top.
1. 1 step + 1 step
2. 2 steps
```

## Example 2:
```
Input: n = 3
Output: 3
```

## Constraints:
- 1 <= n <= 45""",
                "test_cases": [
                    ('{"n": 2}', '2', False),
                    ('{"n": 3}', '3', False),
                    ('{"n": 5}', '8', False),
                ]
            },
            {
                "title": "Binary Tree Inorder Traversal",
                "difficulty": "Easy",
                "slug": "binary-tree-inorder-traversal",
                "description": """# Binary Tree Inorder Traversal

Given the root of a binary tree, return the inorder traversal of its nodes' values.

## Example 1:
```
Input: root = [1,null,2,3]
Output: [1,3,2]
```

## Example 2:
```
Input: root = []
Output: []
```

## Constraints:
- The number of nodes in the tree is in the range [0, 100]
- -100 <= Node.val <= 100""",
                "test_cases": [
                    ('{"root": [1,null,2,3]}', '[1,3,2]', False),
                    ('{"root": []}', '[]', False),
                    ('{"root": [1]}', '[1]', False),
                ]
            },
            {
                "title": "Symmetric Tree",
                "difficulty": "Easy",
                "slug": "symmetric-tree",
                "description": """# Symmetric Tree

Given the root of a binary tree, check whether it is a mirror of itself (i.e., symmetric around its center).

## Example 1:
```
Input: root = [1,2,2,3,4,4,3]
Output: true
```

## Example 2:
```
Input: root = [1,2,2,null,3,null,3]
Output: false
```

## Constraints:
- The number of nodes in the tree is in the range [1, 1000]
- -100 <= Node.val <= 100""",
                "test_cases": [
                    ('{"root": [1,2,2,3,4,4,3]}', 'true', False),
                    ('{"root": [1,2,2,null,3,null,3]}', 'false', False),
                ]
            },
            {
                "title": "Maximum Depth of Binary Tree",
                "difficulty": "Easy",
                "slug": "maximum-depth-of-binary-tree",
                "description": """# Maximum Depth of Binary Tree

Given the root of a binary tree, return its maximum depth.

A binary tree's maximum depth is the number of nodes along the longest path from the root node down to the farthest leaf node.

## Example 1:
```
Input: root = [3,9,20,null,null,15,7]
Output: 3
```

## Example 2:
```
Input: root = [1,null,2]
Output: 2
```

## Constraints:
- The number of nodes in the tree is in the range [0, 10^4]
- -100 <= Node.val <= 100""",
                "test_cases": [
                    ('{"root": [3,9,20,null,null,15,7]}', '3', False),
                    ('{"root": [1,null,2]}', '2', False),
                ]
            },
            {
                "title": "Convert Sorted Array to Binary Search Tree",
                "difficulty": "Easy",
                "slug": "convert-sorted-array-to-binary-search-tree",
                "description": """# Convert Sorted Array to Binary Search Tree

Given an integer array nums where the elements are sorted in ascending order, convert it to a height-balanced binary search tree.

## Example 1:
```
Input: nums = [-10,-3,0,5,9]
Output: [0,-3,9,-10,null,5]
```

## Example 2:
```
Input: nums = [1,3]
Output: [3,1]
```

## Constraints:
- 1 <= nums.length <= 10^4
- -10^4 <= nums[i] <= 10^4""",
                "test_cases": [
                    ('{"nums": [-10,-3,0,5,9]}', '[0,-3,9,-10,null,5]', False),
                    ('{"nums": [1,3]}', '[3,1]', False),
                ]
            },
        ]
        
        # Add more problems to reach 100
        additional_problems = [
            ("Reverse Linked List", "Easy", "reverse-linked-list"),
            ("Palindrome Linked List", "Easy", "palindrome-linked-list"),
            ("Linked List Cycle", "Easy", "linked-list-cycle"),
            ("Intersection of Two Linked Lists", "Easy", "intersection-of-two-linked-lists"),
            ("Remove Nth Node From End of List", "Medium", "remove-nth-node-from-end-of-list"),
            ("Swap Nodes in Pairs", "Medium", "swap-nodes-in-pairs"),
            ("Add Two Numbers", "Medium", "add-two-numbers"),
            ("Copy List with Random Pointer", "Medium", "copy-list-with-random-pointer"),
            ("Sort List", "Medium", "sort-list"),
            ("Reorder List", "Medium", "reorder-list"),
            ("Merge k Sorted Lists", "Hard", "merge-k-sorted-lists"),
            ("Reverse Nodes in k-Group", "Hard", "reverse-nodes-in-k-group"),
            ("Contains Duplicate", "Easy", "contains-duplicate"),
            ("Valid Anagram", "Easy", "valid-anagram"),
            ("Group Anagrams", "Medium", "group-anagrams"),
            ("Top K Frequent Elements", "Medium", "top-k-frequent-elements"),
            ("Product of Array Except Self", "Medium", "product-of-array-except-self"),
            ("Valid Sudoku", "Medium", "valid-sudoku"),
            ("Encode and Decode Strings", "Medium", "encode-and-decode-strings"),
            ("Longest Consecutive Sequence", "Medium", "longest-consecutive-sequence"),
            ("3Sum", "Medium", "3sum"),
            ("Container With Most Water", "Medium", "container-with-most-water"),
            ("Trapping Rain Water", "Hard", "trapping-rain-water"),
            ("Longest Substring Without Repeating Characters", "Medium", "longest-substring-without-repeating-characters"),
            ("Longest Repeating Character Replacement", "Medium", "longest-repeating-character-replacement"),
            ("Minimum Window Substring", "Hard", "minimum-window-substring"),
            ("Sliding Window Maximum", "Hard", "sliding-window-maximum"),
            ("Valid Palindrome", "Easy", "valid-palindrome"),
            ("Longest Palindromic Substring", "Medium", "longest-palindromic-substring"),
            ("Palindromic Substrings", "Medium", "palindromic-substrings"),
            ("Invert Binary Tree", "Easy", "invert-binary-tree"),
            ("Binary Tree Level Order Traversal", "Medium", "binary-tree-level-order-traversal"),
            ("Validate Binary Search Tree", "Medium", "validate-binary-search-tree"),
            ("Kth Smallest Element in a BST", "Medium", "kth-smallest-element-in-a-bst"),
            ("Construct Binary Tree from Preorder and Inorder Traversal", "Medium", "construct-binary-tree-from-preorder-and-inorder-traversal"),
            ("Binary Tree Maximum Path Sum", "Hard", "binary-tree-maximum-path-sum"),
            ("Serialize and Deserialize Binary Tree", "Hard", "serialize-and-deserialize-binary-tree"),
            ("Subtree of Another Tree", "Easy", "subtree-of-another-tree"),
            ("Lowest Common Ancestor of a Binary Search Tree", "Medium", "lowest-common-ancestor-of-a-binary-search-tree"),
            ("Implement Trie (Prefix Tree)", "Medium", "implement-trie-prefix-tree"),
            ("Design Add and Search Words Data Structure", "Medium", "design-add-and-search-words-data-structure"),
            ("Word Search II", "Hard", "word-search-ii"),
            ("Number of Islands", "Medium", "number-of-islands"),
            ("Clone Graph", "Medium", "clone-graph"),
            ("Pacific Atlantic Water Flow", "Medium", "pacific-atlantic-water-flow"),
            ("Course Schedule", "Medium", "course-schedule"),
            ("Course Schedule II", "Medium", "course-schedule-ii"),
            ("Graph Valid Tree", "Medium", "graph-valid-tree"),
            ("Number of Connected Components in an Undirected Graph", "Medium", "number-of-connected-components-in-an-undirected-graph"),
            ("Alien Dictionary", "Hard", "alien-dictionary"),
            ("Combination Sum", "Medium", "combination-sum"),
            ("Word Search", "Medium", "word-search"),
            ("House Robber", "Medium", "house-robber"),
            ("House Robber II", "Medium", "house-robber-ii"),
            ("Decode Ways", "Medium", "decode-ways"),
            ("Unique Paths", "Medium", "unique-paths"),
            ("Jump Game", "Medium", "jump-game"),
            ("Coin Change", "Medium", "coin-change"),
            ("Longest Increasing Subsequence", "Medium", "longest-increasing-subsequence"),
            ("Word Break", "Medium", "word-break"),
            ("Combination Sum IV", "Medium", "combination-sum-iv"),
            ("Longest Common Subsequence", "Medium", "longest-common-subsequence"),
            ("Edit Distance", "Hard", "edit-distance"),
            ("Burst Balloons", "Hard", "burst-balloons"),
            ("Regular Expression Matching", "Hard", "regular-expression-matching"),
            ("Find Minimum in Rotated Sorted Array", "Medium", "find-minimum-in-rotated-sorted-array"),
            ("Search in Rotated Sorted Array", "Medium", "search-in-rotated-sorted-array"),
            ("Time Based Key-Value Store", "Medium", "time-based-key-value-store"),
            ("Median of Two Sorted Arrays", "Hard", "median-of-two-sorted-arrays"),
            ("Min Stack", "Medium", "min-stack"),
            ("Evaluate Reverse Polish Notation", "Medium", "evaluate-reverse-polish-notation"),
            ("Generate Parentheses", "Medium", "generate-parentheses"),
            ("Daily Temperatures", "Medium", "daily-temperatures"),
            ("Car Fleet", "Medium", "car-fleet"),
            ("Largest Rectangle in Histogram", "Hard", "largest-rectangle-in-histogram"),
            ("Kth Largest Element in an Array", "Medium", "kth-largest-element-in-an-array"),
            ("Find Median from Data Stream", "Hard", "find-median-from-data-stream"),
            ("Meeting Rooms", "Easy", "meeting-rooms"),
            ("Meeting Rooms II", "Medium", "meeting-rooms-ii"),
            ("Insert Interval", "Medium", "insert-interval"),
            ("Merge Intervals", "Medium", "merge-intervals"),
            ("Non-overlapping Intervals", "Medium", "non-overlapping-intervals"),
            ("Rotate Image", "Medium", "rotate-image"),
            ("Spiral Matrix", "Medium", "spiral-matrix"),
            ("Set Matrix Zeroes", "Medium", "set-matrix-zeroes"),
            ("Happy Number", "Easy", "happy-number"),
            ("Plus One", "Easy", "plus-one"),
            ("Pow(x, n)", "Medium", "powx-n"),
            ("Sqrt(x)", "Easy", "sqrtx"),
            ("Multiply Strings", "Medium", "multiply-strings"),
            ("Detect Squares", "Medium", "detect-squares"),
        ]
        
        for title, difficulty, slug in additional_problems:
            problems_data.append({
                "title": title,
                "difficulty": difficulty,
                "slug": slug,
                "description": f"""# {title}

This is a {difficulty} level problem from LeetCode.

## Description
Solve the {title} problem.

## Constraints:
- Follow standard constraints for this problem type.""",
                "test_cases": [
                    ('{"input": "test1"}', 'output1', False),
                    ('{"input": "test2"}', 'output2', False),
                ]
            })
        
        print(f"Seeding {len(problems_data)} problems...")
        
        for idx, prob_data in enumerate(problems_data, 1):
            problem = Problem(
                id=uuid.uuid4(),
                title=prob_data["title"],
                slug=prob_data["slug"],
                difficulty=prob_data["difficulty"],
                source="leetcode",
                description=prob_data["description"]
            )
            db.add(problem)
            db.flush()
            
            # Add test cases
            for order, (input_data, expected, is_hidden) in enumerate(prob_data["test_cases"]):
                test_case = TestCase(
                    id=uuid.uuid4(),
                    problem_id=problem.id,
                    input_data=input_data,
                    expected_output=expected,
                    is_hidden=is_hidden,
                    order_index=order
                )
                db.add(test_case)
            
            if idx % 10 == 0:
                print(f"  Seeded {idx} problems...")
        
        db.commit()
        print(f"\n✓ Successfully seeded {len(problems_data)} LeetCode problems with test cases!")
        
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == "__main__":
    seed_leetcode_100()
