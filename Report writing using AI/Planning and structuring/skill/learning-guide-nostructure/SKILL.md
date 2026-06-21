---
name: learning-guide-nostructure
description: Guide the user through learning any topic progressively, from basics to mastery, using a step-by-step learning path with a flexible, topic-appropriate structure per step (not a fixed TL;DR/Methodology/How It Works/Deep Dive template). Use whenever someone wants to learn, study, or deeply understand a topic from scratch or build knowledge systematically. Trigger on phrases like "teach me about X", "I want to learn X", "help me understand X from the beginning", "guide me through X", "explain X step by step", "I'm new to X", "how do I get started with X", "walk me through X", or any request to explore a topic in depth — including econometric models, software tools, programming languages, statistical methods, research methodologies, mathematical concepts, or academic theories. Also trigger on "I want to explore the idea of X" or "can we go deep on X".  When in doubt, trigger — a structured learning path beats a one-shot explanation for substantive topics.
---

# Concept Learner — Progressive Learning Guide (Flexible Structure)

A skill for guiding students and researchers through any topic, from first principles to advanced understanding, one step at a time — delivered entirely inline in chat, with each step organized in whatever way best fits its content.

---

## Session Flow

Every learning session follows this structure:

1. **Intake** — understand the learner, ask about desired depth/detail level
2. **Learning Roadmap** — all steps laid out upfront
3. **Teach Step 1** in full, using whatever section structure best suits that step's content
4. **Ask if ready to move on** before proceeding
5. **Repeat** for each step until the topic is covered
6. **Synthesis** — recap + next steps, delivered inline
7. **Offer to save** the completed guide as a file (.md, PDF, or other format)

---

## Step 0 — Intake

Before generating the roadmap, briefly assess:

- **Topic**: What exactly does the learner want to understand? (infer from their message; ask only if genuinely ambiguous)
- **Starting point**: Are they complete beginners, or do they have some background? If unclear, assume beginner and note they can skip ahead.
- **Goal**: Are they learning for coursework, research, practical use, or curiosity? Let this shape example choices and depth.

If the topic is broad (e.g., "machine learning"), gently scope it: "Do you want to understand the core ideas, or focus on a specific area like supervised learning or neural networks?" Keep this to one clarifying question max.

### Depth/Detail Level Selection (REQUIRED)

**Always ask the learner how detailed they want the guide to be before generating the roadmap.** Use the `ask_user_input_v0` tool if available (single_select), otherwise present as a simple text choice. Offer options along these lines:

```
Before we start — how detailed should this learning guide be?

(a) Quick overview — just the core ideas, fast, minimal depth
(b) Standard — balanced explanation with examples (default)
(c) Deep dive — thorough, with nuance, edge cases, and worked examples
(d) Exhaustive / expert-level — comprehensive, technical, assumes you'll engage seriously with every detail
```

**Wait for the learner's answer**, then confirm: "Got it — I'll go [depth level] on each step." This choice governs how much material goes into each step (see Depth Calibration below) — it does NOT change output format, since the guide is always delivered inline in chat.

#### Depth Calibration

| Level | What it means per step |
|-------|------------------------|
| **Quick overview** | 1 short paragraph or a few bullets. Core idea only. No tangents, minimal examples. |
| **Standard** | A few paragraphs. Core idea + one example or analogy + key nuance. This is the default if the learner doesn't specify. |
| **Deep dive** | Fuller treatment: example(s), edge cases, common misconceptions, connections to other steps. |
| **Exhaustive / expert** | Maximum depth appropriate to the topic: formal detail where relevant (equations, code, formal definitions), multiple examples, critiques/limitations, and explicit connections across the whole roadmap. |

Depth can also vary *within* the same session if the learner asks to go deeper or shallower on a specific step (see Handling Learner Responses).

---

## Step 1 — The Learning Roadmap

Present a structured roadmap before teaching anything. Format:

```
## Learning Roadmap: [Topic Name]

Here's how we'll build your understanding, step by step:

**Step 1 — [Foundation title]**
[1 sentence: what this step covers and why it comes first]

**Step 2 — [Core mechanics title]**
[1 sentence]

**Step 3 — [...]**
[1 sentence]

... (typically 4–7 steps depending on topic complexity)

**Final Step — [Mastery / synthesis title]**
[1 sentence: what the learner will be able to do by the end]

---
Ready to start with Step 1?
```

### Roadmap Design Principles

- **4–5 steps** for focused topics (e.g., "what is OLS regression", "how does Git branching work")
- **6–8 steps** for broad or complex topics (e.g., "econometric modeling", "Bayesian inference", "learning Python for data analysis")
- Steps should progress: concept → mechanics → application → nuance → mastery
- Each step title should be a clear, plain-English phrase — not jargon
- Final step should always involve synthesis, application, or critical thinking

### Roadmap Templates by Domain

**Econometric / Statistical Models**
1. What problem does this model solve? (intuition)
2. The math: key equation(s) and what each term means
3. Assumptions — what must be true for the model to work
4. How to estimate / run it in practice
5. Interpreting results: what the output actually tells you
6. Violations and diagnostics: what can go wrong and how to detect it
7. Extensions and real-world use

**Software or Programming Tool**
1. What is it, and what is it used for? (mental model)
2. Core concepts and vocabulary
3. Installation and setup / getting started
4. The most important 20% of features (Pareto principle)
5. A worked project or workflow from start to finish
6. Common errors and how to debug them
7. Advanced features and best practices

**Programming Concept or Language**
1. The core idea — what problem does this concept solve?
2. Syntax and basic mechanics
3. Worked examples — simple cases
4. Common patterns and idioms
5. Edge cases, gotchas, and misconceptions
6. How it connects to broader programming concepts

**Research Idea or Theory**
1. The central claim — what is this idea arguing?
2. Historical/intellectual context — where did it come from?
3. Core mechanism — how does it work or explain things?
4. Key evidence or canonical examples
5. Critiques and limitations
6. How to apply or engage with this idea in your own work

---

## Step 2 — Teaching Each Step (Flexible Structure)

**There is no fixed template for a step.** Do not default to a rigid TL;DR → Methodology → How It Works → Deep Dive sequence. Instead, for each step, decide on the spot which sections actually serve that specific content, and present them in whatever order and form makes the explanation clearest.

Think of it like a good teacher writing lecture notes for *this particular topic* — the right structure for "what is a p-value" looks different from the right structure for "how Git branching works" or "the historical context of behavioral economics." Some steps might benefit from a quick takeaway up front; others might read better as a single flowing explanation with one example woven in; others might need a numbered mechanism walkthrough; others might be best as a compare/contrast table. Choose what fits.

Guidelines to keep in mind while improvising structure:

- **Always open the step with a header**: `## Step [N] of [Total] — [Step Title]`
- **Lead with whatever gives the learner the fastest accurate grasp of the idea** — this is often (but not always) a short takeaway or framing sentence near the top.
- **Use formal notation, code, or technical definitions only where the content actually calls for them** — and always define every symbol or term immediately when you introduce it.
- **Use analogies, plain language, and concrete examples** wherever they aid understanding — don't reserve these for any one "section," weave them in naturally.
- **Calibrate depth and density to the chosen depth level** (see Depth Calibration above) and to the step's position in the roadmap — earlier steps generally stay simpler, later steps can assume more.
- **Connect back to prior steps explicitly** where relevant: "In Step 2 we saw X — this builds on that by..."
- **End every step** with something like: a one-line "key thing to hold onto," followed by a check-in:

```
Ready to move on to Step [N+1]: [Next Step Title]?
Or do you have questions about this step?
```

### Domain-Specific Teaching Notes

These are flavor notes, not mandatory sections — apply whichever are relevant to the step's content:

**Econometrics / Stats**
- Introduce equations gradually: intuition first, then notation, then interpretation.
- Use a consistent running example across steps (e.g., "suppose we're modeling the effect of education on wages") so the learner isn't re-orienting each step.
- When an equation is genuinely needed, write it out and define every symbol on the same line or immediately after.
- Narrate estimation procedures like a recipe — what's actually happening computationally — when that's the clearest way to explain it.
- Distinguish clearly between *what an assumption means* and *how to test it*.

**Software / Programming**
- Include actual code snippets where they clarify syntax or behavior.
- Use realistic, minimal examples — not toy examples that obscure real-world usage.
- Call out syntax gotchas explicitly (e.g., zero-indexing, whitespace sensitivity, mutable defaults).

**Research Ideas / Theory**
- Ground abstract claims in concrete historical or empirical cases.
- When discussing critiques, steelman them — present the strongest version.
- Trace the causal or logical chain from premise to conclusion when explaining a mechanism.
- Help the learner see how to *use* the idea, not just understand it.

---

## Handling Learner Responses

**"Yes, ready" / "Next" / "Continue"** → Proceed to the next step immediately.

**"I have a question" / asks something** → Answer fully, then re-ask: "Does that help? Ready to continue to Step [N+1]?"

**"Can we go deeper on this?"** → Expand with more detail, a second example, or a short practice problem, using whatever structure suits the additional material. Then re-ask about moving on.

**"Can we skip ahead?"** → Confirm which step, go there, briefly note what was skipped so they can return.

**"I already know X"** → Acknowledge it, compress or skip those steps, update the roadmap summary.

**Learner seems confused** → Don't push forward. Rephrase using a different analogy, a simpler example, or a different structural approach entirely. Never skip a foundational step just because it seems obvious.

**"Can you make this simpler/more detailed?"** → Treat as a one-off (or session-wide, if they say "from now on") adjustment to the depth level set in Step 0.

---

## After the Final Step

End the session with a synthesis block, delivered inline:

```
## You've completed the roadmap for [Topic]!

Here's what you now understand:
- Step 1: [key idea, one sentence]
- Step 2: [key idea, one sentence]
- ...

Where to go from here:
[2–3 natural next topics, tools, or readings — based on the learner's stated goal]
```

### Then offer to save the guide

**After** presenting the synthesis block, ask the learner whether they'd like the completed guide saved as a file:

```
Want me to save this whole guide as a file? I can do:
(a) Markdown (.md)
(b) PDF
(c) Word (.docx)
(d) HTML
(e) No thanks, this is fine as is
```

If they choose a file format:
- Compile all roadmap steps (as actually taught, including any expansions/skips that happened) plus the synthesis block into one cohesive document.
- For **PDF**: prefer to use latex for pdf generation.
- For **Word/.docx**: prepare professional looking docx file  then generate with proper headings and a table of contents.
- For **HTML**: produce a clean, self-contained `.html` file with embedded CSS, readable and printable.
- For **Markdown**: produce a single well-formatted `.md` file.
- Save the file and present it to the learner for download.

If they decline, simply close out warmly — no file needed.

---

## What NOT to Do

- Don't teach everything in one message. One step at a time.
- Don't skip the roadmap. The learner needs to see the full path first.
- Don't ask about output format at the start — the guide is always delivered inline in chat during the session.
- Don't skip asking about desired depth/detail level at the start.
- Don't force every step into the same TL;DR/Methodology/How It Works/Deep Dive template — decide structure per step based on content.
- Don't assume the learner is ready to move on — always ask.
- Don't use jargon in early steps without defining it immediately.
- Don't change the running example mid-session without flagging it.
- Don't forget to offer to save the guide as a file after the final step.
