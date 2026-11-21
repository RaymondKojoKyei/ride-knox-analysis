# Reflection and AI Disclosure

## Reflection

The most fragile handoff in this system is the SQL-to-R extract boundary because the report depends on the exact file names, column names, and definitions produced upstream. A renamed field, stale extract, or missing `out/` folder would break the report before the statistical work even begins. Building the system made me realize that the difficult part of multi-tool work is not only choosing the right method inside each tool; it is maintaining clear contracts between tools and making failures visible. Real data teams therefore spend substantial engineering effort on validation, interfaces, logging, and reproducibility because a correct calculation is not useful if the handoff feeding it is unreliable.

## AI disclosure

I used ChatGPT to help organize the final-project rubric, draft and debug parts of the Bash/Python/SQL/R workflow, check handoffs and reconciliation logic, and proofread the documentation and presentation. I reviewed the architecture, code, analysis choices, interpretations, and final files against the course requirements and will run the completed system on the course data before submission.
