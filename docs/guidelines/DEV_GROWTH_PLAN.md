# Development Growth Plan

> Focus chain: **C++ fundamentals → 3D graphics/rendering → architecture of complex systems.** Each block assumes ~10 hours/week. Adjust pacing if tasks/milestones require more time.

## A. Professional C++ (Weeks 1–12)

| Weeks | Resource | Notes |
| --- | --- | --- |
| 1–2 | *A Tour of C++* (B. Stroustrup) | Fast refresh on modern language surface area. Skim but run small samples in Godot's C++ bindings if possible. |
| 3–5 | *Effective Modern C++* (Scott Meyers) | Deep dive on value categories, smart pointers, RAII. Apply lessons to any future GDExtension code. |
| 6–7 | **CppCoreGuidelines** (online) | Focus on Type, Resource, Concurrency, and Error Handling sections. |
| 8–9 | *C++ Concurrency in Action* (A. Williams) | Threading, atomics, memory model — relevant for future engine work. |
| 10 | *Design Patterns* (GoF) | Revisit only patterns relevant to engine subsystems (State, Command, Observer, Visitor). |
| 11–12 | *Game Engine Architecture* (J. Gregory) | Map theory to Godot + custom tooling ideas. |

## B. 3D Graphics / Rendering (Weeks 1–8+)

| Weeks | Resource | Focus |
| --- | --- | --- |
| 1–2 | *Mathematics for 3D Game Programming and Computer Graphics* (Lengyel) | Matrices, quaternions, projections. Re-derive Locomotion math. |
| 3–5 | *Real-Time Rendering* (Akenine-Möller) | Pipelines, shading models, visibility, lighting. |
| 6–7 | **LearnOpenGL** (online) | Hands-on pipeline, PBR overview, post-process basics. |
| 8+ | **GPU Gems** (selected chapters) & *The Book of Shaders* | Targeted techniques as project needs arise (fog, stylized lighting, etc.). |

## C. Complex Systems Architecture (Weeks 1–8)

| Weeks | Resource | Focus |
| --- | --- | --- |
| 1 | *Software Architecture Patterns* (Mark Richards) | Quick survey of common styles. |
| 2–3 | *Clean Architecture* (Robert C. Martin) | Think about layering inside tools/services. |
| 4–6 | *Designing Data-Intensive Applications* (Martin Kleppmann) | Core reference for persistence, messaging, streaming. |
| 7–8 | *Systems Performance* (Brendan Gregg) | Practical profiling/perf tooling. |
| optional | *Site Reliability Engineering* (Google) | Pick chapters relevant to observability/ops. |

## Usage

- Block **20–30 min/day** (either before or after coding) for reading or note-taking.
- Log progress in devlog `Next Steps` or a personal tracker.
- Revisit this plan every quarter to adjust sequencing or add new focus areas.
