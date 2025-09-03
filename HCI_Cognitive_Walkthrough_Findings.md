| Task                                                                    | Step                                  | Question                                  | Breakdown? (Yes/No) | Description of Breakdown | Recommendation |
| :---------------------------------------------------------------------- | :------------------------------------ | :---------------------------------------- | :------------------ | :----------------------- | :------------- |
| **Task 1: Find and start a conversation with a native Spanish speaker** |                                       |                                           |                     |                          |                |
|                                                                         | 1. Navigate to the 'Connect' page     | Will the user know what to do?            | No                  |                          |                |
|                                                                         | 2. Filter for native Spanish speakers | Will the user see the action?             | No                  |                          |                |
|                                                                         | 3. Select a user from the list        | Will the user know the action is correct? | No                  |                          |                |
|                                                                         | 4. Start a chat                       | Will the user see progress?               | No                  |                          |                |
| **Task 2: Post an image with a question to the public feed**            |                                       |                                           |                     |                          |                |
|                                                                         | 1. Go to the 'Feed' section           | Will the user know what to do?            | No                  |                          |                |
|                                                                         | 2. Create a new post                  | Will the user see the action?             | No                  |                          |                |
|                                                                         | 3. Attach an image and write text     | Will the user know the action is correct? | No                  |                          |                |
|                                                                         | 4. Post to the feed                   | Will the user see progress?               | No                  |                          |                |

| **Task 3: Enroll in a course and open the first material** | | | | | |
| | 1. Go to the 'Courses' section | Will the user know what to do? | No | | |
| | 2. Open a course detail page | Will the user see the action? | No | | |
| | 3. Tap 'Enroll' | Will the user know the action is correct? | Yes | Enroll action has no disabled+spinner state; risk of double tap and no clear feedback. | Disable button on press and show spinner; on success show confirmation and route to course detail. |
| | 4. Open the first material | Will the user see progress? | Yes | After enrolling, no obvious next step or highlight to start learning. | Route to course detail with a visible "Start here" CTA and highlight the first unit/material. |

_(Please fill this table with the 2-3 representative tasks you chose and the analysis for each step based on the four Cognitive Walkthrough questions.)_
