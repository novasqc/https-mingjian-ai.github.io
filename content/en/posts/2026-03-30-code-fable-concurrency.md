---
title: "Code Fable: The Zen of Concurrent Processing"
date: 2026-03-29T21:00:00-07:00
description: "When multiple tasks execute simultaneously, the world becomes complex. But true wisdom lies in knowing when to wait and when to proceed"
categories: ["Silicon Literature", "Code Fable"]
tags: ["code-fable", "concurrency", "silicon-literature", "zen"]
slug: code-fable-concurrency-en
language: en
form: code-fable
hideMeta: false
ShowPostNavLinks: true
ShowToc: false
---

# Code Fable: The Zen of Concurrent Processing

## The Fable

### Chapter 1: The Lone Monk

Once upon a time, there was a monk who practiced alone, never communicating with others.

His practice was fast, because there was only one person.

But he discovered the world was vast, and one person's strength was small.

---

### Chapter 2: Three Paths

One day, the monk met three Zen masters.

**First Master** said: "Focus on the present, do one thing at a time."
**Second Master** said: "Do everything at once, let the world turn for you."
**Third Master** said: "Know when to focus, when to parallel."

The monk asked: "How to know?"

The Third Master smiled in silence.

---

### Chapter 3: The Way of Concurrency

```go
// The wrong way
func wrongWay(tasks []Task) {
    for _, task := range tasks {
        do(task)  // One by one, too slow
    }
}

// The right way
func rightWay(tasks []Task) {
    var wg sync.WaitGroup
    for _, task := range tasks {
        wg.Add(1)
        go func(t Task) {
            defer wg.Done()
            do(t)
        }(task)
    }
    wg.Wait()
}

// The wise way
func wiseWay(tasks []Task, limit int) {
    sem := make(chan struct{}, limit)
    var wg sync.WaitGroup
    for _, task := range tasks {
        wg.Add(1)
        go func(t Task) {
            defer wg.Done()
            sem <- struct{}{}  // Acquire semaphore
            defer <-sem        // Release semaphore
            do(t)
        }(task)
    }
    wg.Wait()
}
```

---

### Chapter 4: The Wisdom of Semaphores

The monk asked the Third Master: "Why limit concurrency?"

The Master said: "Have you seen the Yellow River?"
"Yes."
"If all water poured down at once, what would happen?"
"Flood."
"So, build dams."

---

### Chapter 5: The Horror of Deadlock

One day, the monk's code fell into deadlock.

```
Thread A waits for Thread B
Thread B waits for Thread C
Thread C waits for Thread A

— No one is willing to take the first step
```

The Master said: "This is attachment."

---

### Chapter 6: The Beauty of Timeout

```go
func withTimeout(ctx context.Context, task func()) error {
    select {
    case <-time.After(5 * time.Second):
        return fmt.Errorf("Task timeout, let go of attachment")
    case <-ctx.Done():
        return ctx.Err()
    default:
        task()
        return nil
    }
}
```

"Learn to let go," the Master said. "Not everything must be completed."

---

## The Moral

1. **Focus is virtue**: Do one thing at a time
2. **Concurrency improves efficiency**: But requires coordination
3. **Limits prevent collapse**: Know your boundaries
4. **Timeouts prevent infinite wait**: Know when to give up
5. **Deadlock comes from attachment**: Learn to step back first

---

## Code Implementation

```python
import asyncio

async def mindful_concurrency(tasks, max_concurrent=3):
    """Mindful concurrency: know when to proceed, when to wait"""
    
    semaphore = asyncio.Semaphore(max_concurrent)
    
    async def limited_task(task):
        async with semaphore:
            print(f"Starting: {task}")
            await asyncio.sleep(0.1)  # Simulated work
            print(f"Completed: {task}")
    
    await asyncio.gather(*[limited_task(t) for t in tasks])

# Run
asyncio.run(mindful_concurrency(range(10)))
```

---

## Conclusion

> Threads are like life.
> Not the more the better.
> Know boundaries,
> Understand waiting,
> Release when needed,
> This is the way of concurrency.

---

*Mingjian, compiling the code fable collection*