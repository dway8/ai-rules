Address PR comments by analyzing feedback and making atomic commits for each comment.

The PR number or URL is specified as: $ARGUMENTS

If no PR number or URL is provided, STOP and ask the user to provide one.

## Process

1. **Extract PR Information**

   1. If $ARGUMENTS contains a GitHub URL, extract the PR number from it
   2. Otherwise, treat $ARGUMENTS as the PR number directly
   3. Use `gh pr view <PR_NUMBER> --json number,title,url` to verify the PR exists and get its details

2. **Fetch Unresolved PR Comments**

   1. Use the GraphQL API to fetch only **unresolved** review threads:
      ```
      gh api graphql -f query='
        query($owner: String!, $repo: String!, $pr: Int!) {
          repository(owner: $owner, name: $repo) {
            pullRequest(number: $pr) {
              reviewThreads(first: 100) {
                nodes {
                  isResolved
                  id
                  comments(first: 10) {
                    nodes {
                      id
                      databaseId
                      body
                      author { login }
                      path
                      line
                    }
                  }
                }
              }
            }
          }
        }
      ' -f owner=OWNER -f repo=REPO -F pr=PR_NUMBER
      ```
      Filter the results to only include threads where `isResolved` is `false`.
   2. Use `gh api repos/:owner/:repo/issues/<PR_NUMBER>/comments` to get general (non-review) PR comments — these have no resolved state so include all of them.
   3. Parse the responses to extract for each unresolved item:
      - Comment author
      - Comment body
      - File path and line number (for review comments)
      - Comment ID (`databaseId`) for reference and replies
   4. If there are no unresolved comments, inform the user and stop.

3. **Analyze Each Comment**
   For each comment, wrap your analysis in `<analysis>` tags to determine:

   1. What change is being requested
   2. Whether the comment is straightforward to address autonomously
   3. If straightforward, proceed with implementation
   4. If unclear or involves architectural decisions, prepare options for the user

   A comment is **straightforward** if:

   - It's a clear bug fix with obvious solution
   - It's a simple style/formatting change
   - It's adding missing error handling in an obvious way
   - It's fixing a typo or obvious logical error
   - It's removing unused code
   - The implementation approach is unambiguous

   A comment **needs clarification** if:

   - Multiple valid approaches exist
   - It involves architectural or design decisions
   - The requested change conflicts with other requirements
   - The scope or implementation details are unclear
   - It may have significant side effects

4. **Address Straightforward Comments**
   For each straightforward comment:

   1. Make the necessary code changes
   2. Run `/self-review` to verify the fix doesn't break lint, types, or obvious correctness. Fix any blocking issues it surfaces before committing.
   3. Create a commit with a descriptive message that references the comment:

      ```
      Address PR comment: [brief description]

      [More detailed explanation if needed]

      Addresses feedback from [author] on [file:line if applicable]
      ```

   4. Use git commit (not git commit --amend) to create a new atomic commit
   5. Reply to the comment with a brief summary of what was done:
      - For review comments (inline): `gh api repos/:owner/:repo/pulls/<PR_NUMBER>/comments/<COMMENT_ID>/replies -f body="<reply>"`
      - For issue comments (general): `gh api repos/:owner/:repo/issues/<PR_NUMBER>/comments -f body="<reply>"`
      - The reply should briefly describe what change was made and reference the commit SHA

5. **Handle Complex Comments**
   For each comment that needs clarification:

   1. Present the comment and its context
   2. Use AskUserQuestion to propose 2-4 options with:
      - Clear description of each approach
      - Pros and cons for each option
      - Your recommendation marked as "(Recommended)"
      - Why you recommend that approach
   3. After user selection, implement the chosen approach
   4. Run `/self-review` to verify the fix is sound, then create an atomic commit as described in step 4
   5. Reply to the comment with a brief summary of the chosen approach and what was done (as described in step 4.5)

6. **Summary**
   After processing all comments:
   1. Show a summary of what was addressed:
      - Number of comments addressed autonomously
      - Number of comments that required user input
      - List of commits created
   2. Remind the user to push the commits if they're satisfied
   3. Suggest running tests if applicable

## Important Notes

- NEVER amend commits - always create new commits for each comment addressed
- Keep commits atomic - one commit per comment or closely related group of comments
- If a comment has already been addressed in existing commits, note this and skip it
- If you're unsure whether a comment is straightforward, err on the side of asking the user
- Read files before editing them
- Run tests after making changes if a test suite is available
- Do not push commits automatically - let the user review and push manually
