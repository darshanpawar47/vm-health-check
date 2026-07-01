# Prompt Engineering for DevOps

## Objective

This document captures practical prompt engineering techniques used while building the VM Health Check project.

---

# Zero-Shot Prompting

Definition:

Ask AI to perform a task without giving examples.

Example:

Prompt:

Write a Bash script to check CPU, Memory and Disk utilization.

Observation:

AI generated the initial version of the script without any context.

---

# Few-Shot Prompting

Definition:

Provide one or more examples before asking AI to generate something.

Example:

Prompt:

Here is a Bash function that checks CPU utilization.

Now write similar functions for Memory and Disk utilization.

Observation:

AI followed the same coding style.

---

# Multi-Shot Prompting

Definition:

Provide several examples so AI understands the expected pattern.

Example:

Example:

CPU Function

Example:

Memory Function

Example:

Disk Function

Now generate a logging function using the same coding style.

Observation:

The generated function matched the existing project structure.

---

# Chain of Thought Prompting

Definition:

Ask AI to explain its reasoning step by step.

Example:

Prompt:

My Bash script returns "Permission denied".

Explain step-by-step how to troubleshoot it.

Observation:

AI suggested:

- Check file permissions
- Run chmod +x
- Verify ownership
- Execute again

This helped identify the issue quickly.

---

# Best Practices

- Be specific.
- Provide context.
- Ask AI to explain before generating code.
- Review generated code before accepting.
- Test generated code before committing.