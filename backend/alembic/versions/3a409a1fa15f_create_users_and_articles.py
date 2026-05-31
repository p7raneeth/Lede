"""create_users_and_articles

Revision ID: 3a409a1fa15f
Revises:
Create Date: 2026-05-31

"""
from alembic import op

revision = "3a409a1fa15f"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute('CREATE EXTENSION IF NOT EXISTS "pgcrypto"')

    op.execute("""
        CREATE TABLE users (
            id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
            email           VARCHAR(255) NOT NULL UNIQUE,
            username        VARCHAR(64)  NOT NULL UNIQUE,
            handle          VARCHAR(64)  NOT NULL UNIQUE,
            display_name    VARCHAR(128) NOT NULL,
            hashed_password VARCHAR(256) NOT NULL,
            bio             TEXT         NOT NULL DEFAULT '',
            tagline         VARCHAR(255) NOT NULL DEFAULT '',
            avatar_url      VARCHAR(512) NOT NULL DEFAULT '',
            links           JSONB        NOT NULL DEFAULT '[]',
            topics          JSONB        NOT NULL DEFAULT '[]',
            account_type    VARCHAR(20)  NOT NULL DEFAULT 'subscriber',
            is_active       BOOLEAN      NOT NULL DEFAULT true,
            follower_count  INTEGER      NOT NULL DEFAULT 0,
            following_count INTEGER      NOT NULL DEFAULT 0,
            article_count   INTEGER      NOT NULL DEFAULT 0,
            total_reads     INTEGER      NOT NULL DEFAULT 0,
            created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
            updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
        )
    """)

    op.execute("CREATE INDEX ix_users_email    ON users (email)")
    op.execute("CREATE INDEX ix_users_username ON users (username)")

    op.execute("""
        CREATE TABLE articles (
            id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
            author_id       UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            topic_id        UUID,
            slug            VARCHAR(256) NOT NULL UNIQUE,
            title           VARCHAR(512) NOT NULL,
            dek             TEXT         NOT NULL DEFAULT '',
            body            JSONB        NOT NULL DEFAULT '[]',
            tags            JSONB        NOT NULL DEFAULT '[]',
            cover_url       VARCHAR(512),
            seo_description TEXT         NOT NULL DEFAULT '',
            status          VARCHAR(20)  NOT NULL DEFAULT 'draft',
            visibility      VARCHAR(20)  NOT NULL DEFAULT 'public',
            featured        BOOLEAN      NOT NULL DEFAULT false,
            read_minutes    INTEGER      NOT NULL DEFAULT 0,
            clap_count      INTEGER      NOT NULL DEFAULT 0,
            comment_count   INTEGER      NOT NULL DEFAULT 0,
            view_count      INTEGER      NOT NULL DEFAULT 0,
            published_at    TIMESTAMPTZ,
            scheduled_at    TIMESTAMPTZ,
            created_at      TIMESTAMPTZ  NOT NULL DEFAULT now(),
            updated_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
        )
    """)

    op.execute("CREATE INDEX ix_articles_author_id     ON articles (author_id)")
    op.execute("CREATE INDEX ix_articles_author_status ON articles (author_id, status)")
    op.execute("CREATE INDEX ix_articles_published_at  ON articles (published_at)")


def downgrade() -> None:
    op.execute("DROP TABLE IF EXISTS articles")
    op.execute("DROP TABLE IF EXISTS users")
