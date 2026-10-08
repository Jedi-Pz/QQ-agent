# 领域文档

工程类 skill 在探索代码库时，应按本文件的规则读取领域文档。

## 开始探索前先读

- 仓库根目录的 `GLOSSARY.md`，或
- 仓库根目录的 `GLOSSARY-MAP.md`（如果存在）。它指向每个上下文各自的 `GLOSSARY.md`，按主题读取相关的那几份。
- `docs/adr/`：读取与你即将动手的区域相关的 ADR。多上下文仓库还要检查 `src/<context>/docs/adr/`，那里存放上下文范围内的决策。

这些文件如果不存在，直接跳过。不要指出它们缺失，也不要主动建议先创建。`/domain-modeling` skill（经由 `/grill-with-docs` 和 `/improve-codebase-architecture` 到达）会在术语或决策真正定下来时按需创建。

## 文件结构

单上下文仓库，绝大多数仓库都是这种：

```
/
├── GLOSSARY.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

多上下文仓库，特征是根目录存在 `GLOSSARY-MAP.md`：

```
/
├── GLOSSARY-MAP.md
├── docs/adr/                          ← 全系统范围的决策
└── src/
    ├── ordering/
    │   ├── GLOSSARY.md
    │   └── docs/adr/                  ← 该上下文特有的决策
    └── billing/
        ├── GLOSSARY.md
        └── docs/adr/
```

## 使用词表中的术语

当你的产出要提到某个领域概念时，issue 标题、重构提案、假设、测试名称都算在内，请使用 `GLOSSARY.md` 中定义的说法，不要换成词表明确排除的同义词。

如果你需要的概念还没进词表，这是一个信号：要么你在自造项目里并不存在的说法，那就重新考虑；要么词表确实有缺口，那就记下来交给 `/domain-modeling`。

## 与 ADR 冲突时要指出来

如果你的产出与已有 ADR 矛盾，明确说出来，不要悄悄覆盖：

> 与 ADR-0007（事件溯源订单）冲突，但值得重新讨论，因为……
