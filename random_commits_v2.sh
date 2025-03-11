#!/usr/bin/env bash

# Number of commits you want to create
NUM_COMMITS=49

# Define the start and end date range (inclusive).
# Format: YYYY-MM-DD
START_DATE="2025-03-08"
END_DATE="2025-03-15"

# Commit messages file (each line is a different message)
COMMIT_MSG_FILE="commit_messages.txt"

# Check if commit messages file exists and is not empty
if [ ! -s "$COMMIT_MSG_FILE" ]; then
  echo "Error: Commit messages file '$COMMIT_MSG_FILE' not found or is empty."
  exit 1
fi

# Read commit messages into an array (one per line)
mapfile -t COMMIT_MESSAGES < "$COMMIT_MSG_FILE"
NUM_MESSAGES=${#COMMIT_MESSAGES[@]}

if [ "$NUM_MESSAGES" -eq 0 ]; then
  echo "Error: No commit messages found in '$COMMIT_MSG_FILE'."
  exit 1
fi

# Function to generate a random RFC 2822 date between START_DATE and END_DATE
random_date() {
  local start_sec end_sec diff rand_31 rand_sec

  # Convert start and end dates to UNIX timestamps
  start_sec=$(date -d "$START_DATE" +%s)
  end_sec=$(date -d "$END_DATE" +%s)
  diff=$((end_sec - start_sec))

  # Create a 31-bit random integer using two $RANDOM calls
  rand_31=$(( (RANDOM << 15) | RANDOM ))
  rand_sec=$(( start_sec + (rand_31 % diff) ))

  # Convert the random timestamp to RFC 2822 format
  date -R -d "@$rand_sec"
}

# Loop to create the specified number of commits
for i in $(seq 1 $NUM_COMMITS)
do
  # Stage all changes in the current directory (modify if needed)
  git add .

  # Generate a random date for the commit
  COMMIT_DATE=$(random_date)

  # Pick a random commit message from the array
  RANDOM_INDEX=$(( RANDOM % NUM_MESSAGES ))
  COMMIT_MSG="${COMMIT_MESSAGES[$RANDOM_INDEX]}"

  # Create a commit with the random date and chosen commit message
  # --allow-empty ensures a new commit is created even if there are no file changes
  GIT_AUTHOR_DATE="$COMMIT_DATE" \
  GIT_COMMITTER_DATE="$COMMIT_DATE" \
  git commit --allow-empty -m "$COMMIT_MSG"

  echo "Created commit #$i with date: $COMMIT_DATE and message: $COMMIT_MSG"
done

echo "All $NUM_COMMITS commits have been created."
