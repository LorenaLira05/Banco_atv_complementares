CREATE INDEX idx_user_courses_course_active
    ON user_courses(course_id, is_active);

CREATE INDEX idx_user_courses_user_course_active
    ON user_courses(user_id, course_id, is_active);

CREATE INDEX idx_rules_course_category
    ON course_activity_rules(course_id, category_id);

CREATE INDEX idx_submissions_user_course_status
    ON submissions(user_course_id, status);

CREATE INDEX idx_submissions_submitted_at
    ON submissions(submitted_at DESC);

CREATE INDEX idx_submission_files_submission_uploaded
    ON submission_files(submission_id, uploaded_at DESC);

CREATE INDEX idx_validations_validated_at
    ON validations(validated_at DESC);

CREATE INDEX idx_validations_status_date
    ON validations(validation_status, validated_at DESC);

CREATE INDEX idx_notifications_user_read
    ON notifications(user_id, is_read);
