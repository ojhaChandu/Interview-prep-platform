"""add test_cases table

Revision ID: add_test_cases
Revises: ea9f60f7aa44
Create Date: 2024-03-12

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'add_test_cases'
down_revision = 'ea9f60f7aa44'
branch_labels = None
depends_on = None


def upgrade():
    op.create_table(
        'test_cases',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('problem_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('problems.id'), nullable=False),
        sa.Column('input_data', sa.Text(), nullable=False),
        sa.Column('expected_output', sa.Text(), nullable=False),
        sa.Column('is_hidden', sa.Boolean(), default=False),
        sa.Column('order_index', sa.Integer(), default=0),
    )
    op.create_index('ix_test_cases_problem_id', 'test_cases', ['problem_id'])


def downgrade():
    op.drop_index('ix_test_cases_problem_id')
    op.drop_table('test_cases')
