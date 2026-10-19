---
name: starlette-16-template-response-signature
description: "Project venv has Starlette 1.6 / FastAPI 0.141, which dropped the legacy TemplateResponse(name, ctx) call; builders keep using it and hit \"unhashable type: dict\""
metadata: 
  node_type: memory
  type: project
  originSessionId: 1952e62c-23bc-44e8-ba80-315a71a8e139
  modified: 2026-09-03T01:30:02.511Z
---

The x-scraping-project `.venv` carries Starlette 1.6.0 and FastAPI 0.141.1 (checked 2026-09-02).
Starlette 1.x removed the compatibility shim, so `Jinja2Templates.TemplateResponse` ONLY
accepts `TemplateResponse(request, "name.html", context)`. The old
`TemplateResponse("name.html", {"request": request})` form makes Jinja treat the context
dict as the template name and fails deep in jinja2's LRU cache with
`TypeError: unhashable type: 'dict'`.

**Why:** TASK-15.2 burned all three agent-ci build attempts on this. The traceback points at
jinja2/utils.py, so the builders and reviewer kept blaming the template file instead of the
call site. Also use `Path(__file__).parent / "templates"` for the templates dir; a relative
`Jinja2Templates(directory="orchestrator/console/templates")` only works from the repo root.

**How to apply:** when an escalation shows a Jinja2 TypeError on the first render, check the
`TemplateResponse` call signature and the templates directory path before touching the
template. See [[agent-ci-builders-stub-tests-when-stuck]] for the general pattern of
distrusting the builder's own diagnosis.
