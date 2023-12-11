# Join Optimization

> [Assignment 4](http://courses.cms.caltech.edu/cs122/assignments/lab4.html):
> Join Optimization
> ([Telegraph](https://telegra.ph/Assignment-4-Join-Optimization-11-21))

Write planner/optimizer to choose & generate an optimal join using DP.

## Prepare

Optimizer based on **dynamic programming**:
* Identify all "leaves" in the `FROM`-expression of the query.
* Create an optimal plan for accessing **each leaf** identified above.<br/>
  Store each **optimal** leaf plan, along with its cost.
* Create an optimal join plan for every pair of leaves.<br/>
  Store each of optimal plan, along with their costs.
* Continue this process for three leaves.

## Step #1: Refactoring

To reuse our code, create `AbstractPlannerImpl` to hold the logic about grouping
and aggregation. Besides basic functionalities we implemented in Assignment 2,
we need to support generating an optimal join plan. So, we need to know how the
join-related components work.

For `makePlan`, we only need to handle `WHERE` & `FROM` together for join
optimization. The rest is the same with `SimplePlanner`.
1. Walk through `WHERE` & `FROM` to retrieve all the top-level conjuncts so that
   we can put them properly.
2. Create an optimal join plan by the following steps
3. Add unused conjuncts to the top of the plan

## Step #2: Collecting details from the `FROM`Clause

To provide the base information for Join Optimization, we need to retrieve some
details about leaf nodes and predicates. Because join ordering matters a lot and
pushing conjuncts down benefits.

* Predicates: collect conjuncts from the predicates of non-leaf node
* Leaf node:
  * base-table
  * subquery
  * outer join (handling outer join is grungy)

## Step #3: Generating Optimal Leaf-Plans

> Apply selections as early as possible.

To support Dynamic Programming, we need to generate base/leaf node first. What
we need to do is to implement `makeLeafNode`. It seems very similar to
`makeSelect` in `SimplePlanner`. Only one more thing to do: push predicate down.

* Base table => <code>makeSimpleSelect</code> => <code>FileScanNode</code>
* Sub-Query => <code>makePlan</code> => <code>PlanNode</code>
* Outer-Join => <code>makeJoinPlan</code> => <code>NestedLoopJoinNode</code>

## Step #4: Generating an Optimal Join Plan

> Combine the *N* leaf plans into one optimal join plan.

In our case, the optimizer only considers left-deep plans for simplification.
So our dynamic programming job is relatively easy, because a plan<sub>n+1</sub>
is only generated by specific plan<sub>n</sub> and a leaf node.

```
for plan_n in JoinPlans_n:    # Iterate over plans that join n leaves
  for leaf in LeafPlans:    # Iterate over the leaf plans
    if leaf already appears in plan_n:
      continue        # This leaf is already joined in by the current plan

    plan_n+1 = a new join-plan that joins together plan_n and leaf
    newCost = cost of new plan
    if JoinPlans_n+1 already contains a plan with all leaves in plan_n+1:
      if newCost is cheaper than cost of current "best plan" in JoinPlans_n+1:
        # plan_n+1 is the new "best plan" that combines this set of leaf-plans!
        replace current plan with new plan in JoinPlans_n+1
    else:
      # plan_n+1 is the first plan that combines this set of leaf-plans
      add plan_n+1 to JoinPlans_n+1
```

It is easy to implement, just follow the pseudocode.