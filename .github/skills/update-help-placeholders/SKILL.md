---
name: update-help-placeholders
description: 'Update placeholders in PSBicep help markdown files. Use when: replacing platyPS placeholder text in Docs/Bicep/*.md files with accurate descriptions derived from source code in Source/Public/.'
---

# Update Help Placeholders

## When to Use
- Replacing placeholders in PSBicep help markdown files
- Ensuring help files accurately describe cmdlet behavior

## Procedure

1. **Search for placeholders** in `Docs/Bicep/*.md` files using the command `pwsh -Command "Select-String -Pattern '\{\{ [\s\w]+\}\}' -Path './Docs/Bicep/*.md' -AllMatches"`
2. For each placeholder, run a subagent that performs the following steps:
   a. **Identify the affected cmdlet** by examining the file name and context of the placeholder
   b. **Read each affected file** to understand the OUTPUTS section context
   c. **Read the corresponding source code** to understand what the cmdlet does
   d. **Replace each placeholder** with an accurate description based on the source code
3. **Verify no placeholders remain** by running grep again

## Notes
- Descriptions should be concise (1-2 sentences)
- Reference the cmdlet's actual functionality from the source code
