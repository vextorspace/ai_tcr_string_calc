#!/bin/sh

echo "Find changed files..."

CHANGED_FILES=`git status -s | awk '{print $2}' | grep '\.rs$'`


if [ -z "$CHANGED_FILES" ]; then
    echo "No changed files detected. Running tests..."
    cargo test calc
    # Store the test result
    TEST_RESULT=$?

    # Check if tests failed
    if [ $TEST_RESULT -ne 0 ]; then
        echo "Tests failed! Removing changes..."
        git reset --hard HEAD
    else
        echo "Tests passed! Committing..."
      git add .
      COMMIT_MESSAGE=`commit_message`
      git commit -m "$COMMIT_MESSAGE"
    fi
else
    FIRST_CHANGED_FILE=$(echo "$CHANGED_FILES" | head -n 1)
    echo "Writing code..."
    
    cargo test calc
    # Store the test result
    TEST_RESULT=$?

    # Execute ai_coder
    ai_coder "$FIRST_CHANGED_FILE" "$TEST_RESULT"
    # Check if tests failed
    if [ $TEST_RESULT -ne 0 ]; then
        echo "Tests failed! Removing changes..."
        git reset --hard HEAD
    else
        echo "Tests passed! Committing..."
      git add .
      COMMIT_MESSAGE=`commit_message`
      git commit -m "$COMMIT_MESSAGE"
    fi
fi



echo "Running gradle tests..."
cargo test --test acceptance_tests

exit 0
