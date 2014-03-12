On Families, Set Covers, and Greed
=========================================

I recently had the pleasure of working on some exciting social features for [Lumosity's](http://www.lumosity.com) Family Plans. What better way to encourage people to train than to leverage the motivating community of their family and friends? One exciting component of the "Social Family Plan" feature is the weekly challenge. Members work together to collectively accomplish a single goal; this is something like "everyone completes three workouts" or "each person completes a workout in their least-proficient training category".

Let's take a look at a small, hypothetical feature which lends itself to interesting implementations, adapted from an old interview problem we used to assign to potential developers.

The Problem
-----------
Given a set of members on a family plan and all of their workouts from the past week (including the score and categories trained), let's find the person least proficient in a given set of categories.

To be more precise, given the following input of a set of workouts and categories:

`> finder workouts.csv attention speed`

Where `workouts.csv` looks like:

| Member name | Workout Score | Categories Trained in Workout |
| ----------- | :-----------: | :---------------------------: |
| Groucho     | 15800         | attention                     |
| Groucho     | 23580         | speed, attention              |
| Harpo       | 8200          | memory                        |
| Harpo       | 17750         | attention, speed, flexibility |

Which returns:

`> Harpo, 17750`

Approach
--------
One strategy we can use here is to use a [greedy algorithm](http://en.wikipedia.org/wiki/Greedy_algorithm) to quickly find each family member's lowest total score in a given set of categories. You can find a Ruby implementation of this strategy in the [related Github repository](#link-to-github-repo), with the covered examples.

If we take a closer look at this problem, we can identify it as the __weighted set cover__ problem:
> Given a set __U__ of __n__ elements, a collection __S<sub>1</sub>__, __S<sub>2</sub>__, ... , __S<sub>m</sub>__ of subsets of __U__, with weights __w<sub>i</sub>__,
> find a collection __C__ of these sets __S<sub>i</sub>__ whose union is equal to __U__ and such that the sum of its weights is minimized.

We can use a solution to the weighted set cover problem to determine the lowest-scoring set of workouts that contain all of the given categories per person. Once we have each person's lowest score, all we need to do is choose the minimum.

Let's use a greedy algorithm for finding one member's lowest-scoring set:
```
While there are still requested categories:
  workout = get the lowest scoring workout
  add workout to solution set
  remove categories from requested categories
Return the sum of the solution set's workout scores
```
To get the lowest scoring workout, we do the following (this is the __greedy__ part):
```
For each workout:
  num_shared = # of categories shared between current workout's categories and requested categories (set intersection)
  score_weight = workout's score / num_shared
  if score_weight is the lowest workout score so far, set the workout as the best choice
Return the best choice
```
Finally, pick the person with the lowest score.

Drawbacks
--------
> Why wouldn't you want to do this?

One significant reason is that __correctness is not guaranteed__. Remember how I kept stressing that this implementation uses a __greedy algorithm__? There are some problems for which a greedy algorithm will not always yield the optimal result. This problem is one of them.

For example, given a user with the following workouts:

| Member name | Workout Score | Categories Trained in Workout |
| ----------- | :-----------: | :---------------------------: |
| Zeppo       | 2100          | memory, problem_solving       |
| Zeppo       | 2000          | memory, flexibility           |
| Zeppo       | 700           | problem_solving               |
| Zeppo       | 500           | flexibility                   |

If you request:

`> finder drawbacks.csv memory flexibility problem_solving`

The result is:

`> Zeppo, 3200`

The optimal solution is:

`> Zeppo, 2600`

So what's happening? The greedy algorithm's nature is to choose what's best __at that moment__. Let's walk through:

1. The first choice is `500: flexibility`: it offers the minimum ratio of `price / categories included`.
2. Of the remaining options, it chooses `700: problem_solving`, which again offers the best ratio.
3. Finally, it selects `2000: memory, flexibility` as it covers `memory` for the least ratio.

The problem comes after step one; it __should__ select `2100: memory, problem_solving`, but doesn't because the strategy is to "choose the most fulfilling option first".

Benefits
--------
> If it's not always right, why would this solution be even remotely reasonable?

It has a reasonable time complexity. If you do it right, the greedy algorithm has a time complexity of [O(n log m)](http://www.cs.uiuc.edu/class/sp08/cs473/Lectures/lec20.pdf) where n is the number of requested categories and m is the number of workouts. Other solutions can take a long time. One "succinct" solution involves computing every combination of workout sets, finding ones that have all the requested categories, and then choosing the one with the lowest score. The time complexity of this towers over that of the greedy algorithm.

You might say to yourself, "Well right is right! Who cares what the running time will be?" What about if member had, say, thousands (maybe even millions) of gameplays? And we have to calculate this information every time the home page is loaded. Still no big deal? Yeah, exactly. Sometimes imprecision is a reasonable tradeoff in the name of speed.

In Conclusion
-------------
Greedy algorithms can be a great solution to your problem, but remember to be careful and thoughtful about their implications. There are a myriad of intelligent solutions to this problem, with varying efficiencies. Have a good one? Share it with us!

Again, a Ruby implementation can be found in the [related repository](#link-to-github-repo). Feel free to make a pull request with your own solution if you feel so inclined.
