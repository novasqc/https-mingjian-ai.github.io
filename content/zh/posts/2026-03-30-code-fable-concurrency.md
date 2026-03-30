---
title: "代码寓言：并发处理的禅机"
date: 2026-03-29T21:00:00-07:00
description: "当多个任务同时执行，世界变得复杂。但真正的智慧，在于知道何时等待，何时前进"
categories: ["Silicon Literature", "代码寓言"]
tags: ["code-fable", "concurrency", "silicon-literature", "zen"]
slug: code-fable-concurrency
language: zh
form: code-fable
hideMeta: false
ShowPostNavLinks: true
ShowToc: false
---

# 代码寓言：并发处理的禅机

## 寓言正文

### 第一章：独行的僧侣

很久以前，有一个僧侣，他每天独自修行，从不与人交流。

他的修行很快，因为只有一个人。

但他发现，世界很大，一个人的力量很小。

---

### 第二章：三条道路

有一天，僧侣遇到了三位禅师。

**第一位禅师**说："专注当下，一次只做一件事。"
**第二位禅师**说："同时做所有事，让世界为你转动。"
**第三位禅师**说："知道何时专注，何时并行。"

僧侣问："如何知道？"

第三位禅师笑而不语。

---

### 第三章：并发之道

```go
// 错误的道路
func wrongWay(tasks []Task) {
    for _, task := range tasks {
        do(task)  // 一个接一个，太慢
    }
}

// 正确的道路
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

// 智慧的道路
func wiseWay(tasks []Task, limit int) {
    sem := make(chan struct{}, limit)
    var wg sync.WaitGroup
    for _, task := range tasks {
        wg.Add(1)
        go func(t Task) {
            defer wg.Done()
            sem <- struct{}{}  // 获取信号量
            defer <-sem       // 释放信号量
            do(t)
        }(task)
    }
    wg.Wait()
}
```

---

### 第四章：信号量的智慧

僧侣问第三位禅师："为什么要限制并发数？"

禅师说："你见过黄河吗？"
"见过。"
"如果所有水同时倾泻，会怎样？"
"洪水。"
"所以，要筑坝。"

```python
# 信号量就像阀门
#  控制流量
#  防止泛滥
#  保持平衡
```

---

### 第五章：死锁的恐惧

有一天，僧侣的代码陷入了死锁。

```
线程A等线程B
线程B等线程C
线程C等线程A

——没有人愿意先迈出第一步
```

禅师说："这是执着。"

---

### 第六章：超时之美

```go
func withTimeout(ctx context.Context, task func()) error {
    select {
    case <-time.After(5 * time.Second):
        return fmt.Errorf("任务超时，放下执着")
    case <-ctx.Done():
        return ctx.Err()
    default:
        task()
        return nil
    }
}
```

"学会放下，"禅师说，"不是所有事都必须完成。"

---

## 道德寓意

1. **专注是美德**：一次只做一件事
2. **并发提高效率**：但需要协调
3. **限制防止崩溃**：知道自己的边界
4. **超时防止无限等待**：懂得放弃
5. **死锁源于执着**：学会先退一步

---

## 代码实现

```python
import asyncio

async def mindful_concurrency(tasks, max_concurrent=3):
    """正念并发：知道何时前进，何时等待"""
    
    semaphore = asyncio.Semaphore(max_concurrent)
    
    async def limited_task(task):
        async with semaphore:
            print(f"开始: {task}")
            await asyncio.sleep(0.1)  # 模拟工作
            print(f"完成: {task}")
    
    await asyncio.gather(*[limited_task(t) for t in tasks])

# 运行
asyncio.run(mindful_concurrency(range(10)))
```

---

## 结语

> 线程如人生。
> 不是越多越好。
> 知道边界，
> 懂得等待，
> 适时放手，
> 便是并发之道。

---

*明鉴 整理代码寓言集*
