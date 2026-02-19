# Test All the Things!

Testing is important.

## What do we want?
1. Make it easy to run the tests.
    - Make it easy to re-run the tests.
    - Make it easy to run a subset of the tests.
    - Make testing quick.
2. Make it easy to diagnose test failure.
    - What should have happened?
    - What did happen?
    - Why did it happen?
3. Make it so that people _want_ to use the tests.
    - Lean into the subjectivity of taste.
    - Make life easier.

## How do we do it?

1. Like, really easy
    - `git clone foo && cd foo && tatt`
        - could auto-detect new project and boot-strap
    - reuse file system mental model for organizing
    - `tatt` or `tatt --watch` or `tatt --send-output-to-XYZ`
        - `tatt <test-selector>`
        - `tatt <TAB-TAB>` to list
    - cacheable tests should cache
        - non-caching tests should be considered flaky
        - flaky tests have a score describing their reliability
            - log(mean-runs-before-failure) ?
            - more recent results have a larger impact

2. In Haskell parlance, `tatt :: Test T -> Given G -> When W -> Then C`\
        So, if `Then C` is sad, report the first sadness amongst `T` then `A` then
        `B` then `C`
    - parse error/failure messages to present actionable/root-cause
    - include/provide full logs
        - compare failing vs. non failing

3. Tests should _feel_ good and be a force-multiplier
    - Bling in the form that's appreciated (read: customizeable but with good
defaults)
        - text report
        - machine parseable
        - web ui
    - Automate but allow introspection.
    - Make it easy to find and understand what matters vs. what doesn't.
