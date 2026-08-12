# ZeroTouch Labs - Claude Instructions

This repository contains RHEL online lab definitions for the ZeroTouch platform. When creating or modifying labs in this repository, follow these patterns and conventions.

## Generated Labs Directory

**IMPORTANT**: When creating new labs, always place them in the `generated/` subdirectory.

- New labs should be created at: `generated/zt-{lab-name}/`
- The `generated/` directory is excluded from git tracking via `.gitignore`
- This keeps the repository clean and separates generated content from templates and documentation
- Example: A new lab called "lvm-expansion" should be created at `generated/zt-lvm-expansion/`

## Lab Structure

Each lab is a self-contained directory named `zt-{lab-name}` with this structure:

```
zt-{lab-name}/
├── README.adoc                    # Lab overview documentation
├── site.yml                       # Antora site configuration
├── ui-config.yml                  # UI tabs and module configuration
├── config/
│   ├── instances.yaml            # VM definitions
│   ├── networks.yaml             # Network configuration
│   └── firewall.yaml             # Firewall rules
├── content/
│   ├── antora.yml                # Antora content config
│   └── modules/ROOT/
│       ├── assets/images/        # Images for documentation
│       └── pages/                # AsciiDoc module content files
├── setup-automation/              # Initial provisioning scripts
│   ├── setup-{vmname}.sh
│   ├── ansible.cfg
│   └── main.yml
├── runtime-automation/            # Per-module automation
│   ├── {module-name}/
│   │   ├── setup-{vmname}.sh     # Runs when module starts
│   │   ├── solve-{vmname}.sh     # Shows/performs solution
│   │   └── validation-{vmname}.sh # Validates completion
│   ├── ansible.cfg
│   ├── inventory
│   └── main.yml
└── utilities/                     # Utility scripts (copy from template)
    ├── lab-build
    ├── lab-clean
    ├── lab-serve
    └── lab-stop
```

## CRITICAL Configuration Patterns

### Module Naming Convention

**CRITICAL: Module files MUST follow the `module-##` naming pattern**

- Content files: `module-01.adoc`, `module-02.adoc`, `module-03.adoc`, etc.
- Runtime directories: `module-01/`, `module-02/`, `module-03/`, etc.
- ui-config.yml references: `name: module-01`, `name: module-02`, etc.
- site.yml start_page: `modules::module-01.adoc`

❌ **DO NOT** use descriptive names like `01-introduction.adoc` or `02-install.adoc`
✅ **DO** use `module-01.adoc`, `module-02.adoc`, etc.

**Reason**: Antora and the showroom build system expect this exact naming pattern. Custom names will cause the antora-builder init container to fail, preventing the lab from deploying.

### Runtime Automation Scripts

**CRITICAL: Script naming must be exact**

Each module directory MUST contain all three scripts:
- `setup-{vmname}.sh` - Runs when module starts
- `solve-{vmname}.sh` - Contains all commands the participant should run
- `validation-{vmname}.sh` - Validates completion (NOT `validate-{vmname}.sh`)

**IMPORTANT: All modules require solve and validation scripts**
- Even if `solveButton: false` in ui-config.yml, the solve script must exist
- The solve script should contain ALL commands the lab participant is expected to run during that module
- This enables testing, validation, and automated verification of lab functionality
- The validation script should check that the expected state/changes from the module are complete

**Script requirements:**
- Use `#!/bin/sh` shebang (NOT `#!/bin/bash`)
- Must be executable (`chmod +x`)
- Should log to `/tmp/progress.log` for debugging
- Exit with appropriate codes (0 for success, 1 for failure in validation)
- Solve scripts should run all participant commands, not just log a message

**Example minimal scripts:**

```bash
#!/bin/sh
echo "Starting module called module-01" >> /tmp/progress.log
```

```bash
#!/bin/sh
echo "Solved module called module-01" >> /tmp/progress.log
```

```bash
#!/bin/sh
echo "Validating module called module-01" >> /tmp/progress.log
```

### instances.yaml Format

**ALWAYS use this exact format:**

```yaml
---
virtualmachines:
  - name: "rhel"
    image: "rhel-10-0-07-09-25-3"
    bootloader: efi
    memory: "4G"
    cores: 1
    image_size: "40G"              # Size of main disk
    tags:
      - key: "AnsibleGroup"
        value: "bastions"
    networks:
      - default
    packages:                       # Optional
      - package1
      - package2
# For cockpit
#    services:
#      - name: cockpit
#        ports:
#          - port: 9090
#            protocol: TCP
#            targetPort: 9090
#            name: cockpit
#    routes:
#      - name: cockpit
#        host: cockpit
#        service: cockpit
#        targetPort: 9090
#        tls: true
#        tls_termination: Edge
    # For disk/filesystem management labs only
    # disks:
    #   - metadata:
    #       name: "rhel-lvm-INSTANCEGUID"
    #     spec:
    #       source:
    #         blank: {}
    #       pvc:
    #         accessModes:
    #           - ReadWriteMany
    #         volumeMode: Block
    #         resources:
    #           requests:
    #             storage: "5G"
```

**Key points:**
- Top-level key is `virtualmachines` (NOT `instances`)
- Image must be `"rhel-10-0-07-09-25-3"`
- Must include `bootloader: efi`
- Use `image_size` for the main disk size (do NOT define a separate root disk)
- Memory and sizes use quoted strings with units: `"4G"`, `"20G"`, `"40G"`
- Always include the `AnsibleGroup: bastions` tag
- Networks is just `- default` (simple list format)

**Additional Disks:**
- **For most labs**: Do NOT add additional disks - if you need more disk space, increase `image_size` instead
- **For disk/filesystem management labs**: You CAN add additional disks using the `disks:` section shown in the commented example above
- When adding disks, use the exact format from the template with `INSTANCEGUID` in the name
- Additional disks are useful when the lab's purpose is to teach disk management, LVM operations, or filesystem tasks

### When to Use Additional Disks

**Use additional disks when:**
- The lab teaches disk partitioning, LVM, or filesystem management
- Students need to practice adding new storage to a system
- The lab requires demonstrating disk-related operations (pvcreate, vgextend, etc.)
- You need an "unformatted" or "raw" disk for students to work with

**Do NOT use additional disks when:**
- You simply need more storage space for applications or data (use larger `image_size` instead)
- The lab is not focused on disk/storage management topics
- You want additional space in an existing filesystem or volume group

**Configuration pattern for additional disks:**
```yaml
    disks:
      - metadata:
          name: "rhel-lvm-INSTANCEGUID"  # INSTANCEGUID will be replaced at runtime
        spec:
          source:
            blank: {}                     # Creates an empty/unformatted disk
          pvc:
            accessModes:
              - ReadWriteMany
            volumeMode: Block
            resources:
              requests:
                storage: "5G"             # Size of the additional disk
```

### networks.yaml Format

**ALWAYS use this minimal format:**

```yaml
---
# By default egress traffic is not allowed, define below the ports allowed.
- name: default
```

**Do NOT specify subnet, gateway, or dhcp settings** - these are handled automatically.

### firewall.yaml Format

**ALWAYS use this format:**

```yaml
---
# By default egress traffic is not allowed, define below the ports allowed.
egress:
  - ports:
      - protocol: TCP
        port: 443
#ingress:
# For Cockpit
#  - ports:
#      - protocol: TCP
#        port: 9090
```

**Key points:**
- Use `egress:` for outbound traffic rules
- Use `ingress:` for inbound traffic rules (optional, only if needed)
- Each section contains a list with `ports:` containing protocol and port number
- Protocol should be uppercase (TCP, UDP)
- Most labs only need egress to port 443 (HTTPS)
- Include commented examples for common patterns

### ui-config.yml Format

**Terminal tab MUST use this format:**

```yaml
---

antora:
  name: modules
  dir: www
  modules:
    - name: module-01
      label: "Display Name"
      solveButton: false              # false for intro modules
    - name: module-02
      label: "Display Name"
      solveButton: false
    - name: module-03
      label: "Display Name"
      solveButton: false
    - name: module-04
      label: "Display Name"
      solveButton: false

tabs:
  - name: ">_ terminal"
    url: /wetty

```

**Key points:**
- Must start with `---` followed by blank line
- Tab uses `url: /wetty` (NOT `port` and `path`)
- Module names match the content file names (e.g., `module-01` matches `module-01.adoc`)
- Set `solveButton: false` for all modules (or omit from last module)
- Must end with a blank line

### site.yml Format

**ALWAYS use this complete format:**

```yaml
---
site:
  title: Lab Title
  url: https://github.com/rhpds/showroom_template_zero
  start_page: modules::module-01.adoc
content:
  sources:
    - url: ./
      start_path: content
ui:
  bundle:
    url: https://github.com/rhpds/nookbag-bundle/releases/download/v0.0.3/ui-bundle.zip
    snapshot: true

output:
  dir: ./www/www

runtime:
  cache_dir: ./.cache/antora
```

**Key points:**
- Must include `url: https://github.com/rhpds/showroom_template_zero` in the `site:` section
- **CRITICAL**: Use `https://github.com/rhpds/nookbag-bundle/releases/download/v0.0.3/ui-bundle.zip` for the bundle (NOT course-ui)
- Must include `snapshot: true` in the `bundle:` section
- Must include `output:` section with `dir: ./www/www`
- Must include `runtime:` section with `cache_dir: ./.cache/antora`
- start_page should reference `module-01.adoc`

### antora.yml Format

**Keep this minimal:**

```yaml
---

name: modules
version: master
```

**Key points:**
- Located in `content/antora.yml`
- Must have blank line after `---`
- Keep it simple - just name and version
- Do NOT add asciidoc attributes section

### runtime-automation/inventory Format

**Must contain actual inventory content:**

```ini
[local]
localhost

[local:vars]
ansible_connection = local
```

**Do NOT** just have comments - the file needs actual inventory definitions.

### Ansible Configuration Files

**setup-automation/ansible.cfg:**
```ini
[defaults]
host_key_checking = False

```

**runtime-automation/ansible.cfg:**
```ini
[defaults]
#inventory                 = inventory
retry_files_enabled       = false
```

**Key points:**
- Different configurations for setup vs runtime
- setup-automation needs `host_key_checking = False`
- runtime-automation needs commented inventory and retry_files setting

### Setup Automation Pattern

**setup-automation/setup-{vmname}.sh must follow this pattern:**

```bash
#!/bin/bash
USER=rhel

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

echo "Setup vm control01" > /tmp/progress.log

chmod 666 /tmp/progress.log

# Your setup tasks here (create directories, etc.)

echo "Lab setup complete" >> /tmp/progress.log

#dnf install -y nc

# Epel
#dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
# certbot if needed
#dnf install -y certbot

# Enable cockpit functionality in showroom.
#dnf -y remove tlog cockpit-session-recording
#echo "[WebService]" > /etc/cockpit/cockpit.conf
#echo "Origins = https://cockpit-${GUID}.${DOMAIN}" >> /etc/cockpit/cockpit.conf
#echo "AllowUnencrypted = true" >> /etc/cockpit/cockpit.conf
#systemctl enable --now cockpit.socket
```

**Critical elements:**
- Set `USER=rhel` variable
- Add user to wheel group
- Write to `/root/post-run.log` and `/tmp/progress.log`
- Set permissions on progress.log (`chmod 666`)
- Include commented examples from template
- Do NOT use `set -e` - this can cause premature exit
- Avoid long-running operations like pulling container images

### runtime-automation/main.yml

**Use the standard template from `zt-rhel-tmm-template/runtime-automation/main.yml`:**

This playbook handles:
- Creating dynamic inventory with bastion host connections
- Checking for and executing module scripts (setup/solve/validation)
- Proper logging and error handling
- Outputting results to the platform

**Do NOT create a simplified version** - always copy from the template to ensure proper functionality with the platform's ansible-runner API.

### setup-automation/main.yml

**Use the standard template from `zt-rhel-tmm-template/setup-automation/main.yml`:**

This playbook handles:
- Creating dynamic inventory with bastion host connections
- Waiting for connection to be available
- Checking for and executing setup-{hostname}.sh scripts
- Proper logging and error handling
- Outputting results to the platform

**Do NOT create a simplified version** - always copy from the template to ensure proper functionality with the platform's ansible-runner API.

### utilities/ Directory

**Always copy the entire utilities directory from `zt-rhel-tmm-template/utilities/`:**

This directory contains helper scripts for local development and testing:
- `lab-build` - Builds the lab documentation
- `lab-serve` - Serves the lab locally for preview
- `lab-stop` - Stops the local server
- `lab-clean` - Cleans build artifacts

**Copy the entire directory** - do not create these scripts manually.

```bash
cp -r zt-rhel-tmm-template/utilities zt-{your-lab-name}/
```

### Required Files

**Must include:**
- `README.adoc` - Copy from template and customize
- `content/modules/ROOT/assets/images/example-image.png` - Copy from template

**Do NOT include:**
- `lab-metadata.yml` - Not used by the deployment system
- `README.md` - Use README.adoc instead

## Content Guidelines

### AsciiDoc Module Files

- Place in `content/modules/ROOT/pages/`
- Name with module prefix: `module-01.adoc`, `module-02.adoc`, etc.
- Use proper AsciiDoc formatting:

```asciidoc
= Module Title

== Section Heading

Narrative text content goes here.

[source,bash,role=execute]
----
commands that users will run
----

[NOTE]
====
Important notes in callout boxes
====

[TIP]
====
Helpful tips
====

[IMPORTANT]
====
Critical warnings
====

[quote, Person Name]
____
Quotes for engagement or humor
____
```

### Real-World Context and Personas

When creating labs that need real-world context and scenarios, use these standard fictitious elements:

**The Company: Super-Business**
- A fictitious company where all work is "super-businessey"
- Generic enough to apply to various IT scenarios
- Use when labs need a realistic business context

**The Persona: Manager Scott**
- An IT middle-manager at Super-Business
- Background: Once had system administration skills but has been in management long enough to have lost most technical abilities
- Character traits:
  - Makes ridiculous demands
  - Sometimes attempts to "help" by fixing problems but only makes them worse
  - Leaves the actual cleanup and proper fixes to the lab participant
  - Provides humorous but realistic scenarios of poor management decisions

**The Persona: Sysadmin Nate**
- An experienced systems administrator at Super-Business
- Background: Has been dealing with Manager Scott's shenanigans for years and has learned patience
- Character traits:
  - Knowledgeable and helpful
  - Provides practical wisdom and hints
  - Offers guidance without giving away the complete solution
  - Sometimes shares war stories about previous Manager Scott incidents
  - Acts as a mentor figure to the lab participant

**Usage Guidelines:**
- Use Manager Scott when you want to set up a scenario where something is broken or misconfigured
- Manager Scott's "attempts to help" can be the source of problems students need to fix
- Use Sysadmin Nate when you need to provide hints, direction, or context to the participant
- Nate can leave notes, send helpful emails, or provide documentation that guides students
- This persona adds engagement and humor while maintaining educational value
- Keep scenarios realistic enough to reflect actual workplace challenges

**Example scenarios:**
- Manager Scott tried to free up disk space by deleting "unnecessary" files (that were actually critical)
- Manager Scott attempted to improve security by changing permissions on everything to 000
- Manager Scott configured a service following a blog post from 2010 without understanding the implications
- Manager Scott needs something done urgently but with unclear or changing requirements
- Sysadmin Nate leaves a helpful note: "When Scott messes with permissions, always check /var/log first"
- Sysadmin Nate sends an email: "I've seen this before - check the systemd journal, that usually tells the story"

**Example: Nate's Hint for a Broken Web Server**

When Manager Scott breaks something (like the web server), Sysadmin Nate might leave a helpful note:

```asciidoc
[NOTE]
====
*From: Nate (Senior Sysadmin)*

Hey,

Saw Scott's email. Yeah... he did it again. Deep breath - we'll get through this.

Few pointers from the last time Scott "cleaned up" a server:

1. **Start with the logs** - `journalctl -u httpd -n 50` (or whatever your web service is called). The errors will tell you what's actually broken, not what Scott *thinks* is broken.

2. **Check what's running** - `systemctl status httpd` is your friend. If it's not running, try to start it and watch what fails.

3. **Permission problems** - If you see "Permission denied" everywhere, remember that /etc needs to be readable. At minimum, most things in there should be 644 for files and 755 for directories. You'll probably need to fix that before anything else works.

4. **Missing files** - If config files are gone, check if there are .rpmsave or package backups. Worst case, reinstalling the web server package will restore default configs.

Work methodically. Fix one thing at a time. You've got this.

Also, when you're done, maybe document the correct procedure so we can send it to Scott. (He won't read it, but we can try.)

-Nate

P.S. - I keep a backup of our standard httpd.conf in `/home/nate/templates/` just for occasions like this.
====
```

This shows how Nate provides systematic guidance without solving the problem completely, while adding character and realism to the lab experience.

### Script Requirements

**All scripts must:**
- Use `#!/bin/sh` shebang for runtime scripts, `#!/bin/bash` for setup scripts
- Be executable (`chmod +x`)
- Log to `/tmp/progress.log` for tracking
- Exit with appropriate codes:
  - `exit 0` for success
  - `exit 1` for failure (validation scripts)

**Validation script pattern:**
```bash
#!/bin/sh
# Validate that objectives are met

if ! [condition]; then
    echo "FAIL: Clear description of what failed"
    echo "HINT: Suggestion for fixing it"
    exit 1
fi

echo "PASS: Description of success"
exit 0
```

## Creating New Labs

When asked to create a new lab:

1. **Create in generated/ directory** - All new labs go in `generated/zt-{lab-name}/`
2. **Start with the template** - Copy `zt-rhel-tmm-template` as your base
3. **Use module-## naming** for all content files and runtime directories
4. **Copy utilities/** directory from template
5. **Copy main.yml files** from template (do not create simplified versions)
6. **Use correct script filenames** - `validation-rhel.sh` not `validate-rhel.sh`
7. **Use `#!/bin/sh`** shebang in runtime scripts
8. **Copy README.adoc and example-image.png** from template
9. **Create ALL runtime automation scripts** for each module:
   - `setup-{vmname}.sh` (optional, can be minimal)
   - `solve-{vmname}.sh` (REQUIRED - contains all participant commands)
   - `validation-{vmname}.sh` (REQUIRED - validates module completion)
10. **Customize only:**
   - config/ files (instances, networks, firewall)
   - ui-config.yml (module labels)
   - site.yml (title and start_page)
   - content/ (your actual lab content)
   - setup-automation/setup-{vmname}.sh (your setup logic)
   - runtime-automation/{module-name}/ scripts (your module logic)

## Common Pitfalls to Avoid

❌ **DON'T:**
- Use custom module names like `01-introduction.adoc` - must be `module-01.adoc`
- Name validation scripts `validate-rhel.sh` - must be `validation-rhel.sh`
- Use `#!/bin/bash` in runtime scripts - use `#!/bin/sh`
- Skip creating solve/validation scripts for any module (ALL modules need them)
- Create empty solve scripts that only log - they must contain actual participant commands
- Use `instances:` as top-level key (use `virtualmachines:`)
- Define a separate "root" disk (use `image_size:` instead)
- Add additional disks for general storage needs (increase `image_size` instead)
- Specify subnet/gateway/dhcp in networks.yaml
- Use `port:` and `path:` for terminal tabs (use `url: /wetty`)
- Use wrong UI bundle URL (must be `nookbag-bundle` not `course-ui`)
- Forget the `AnsibleGroup: bastions` tag
- Forget `bootloader: efi`
- Forget blank lines in ui-config.yml and antora.yml
- Use `set -e` in setup scripts (can cause premature exit)
- Include `lab-metadata.yml` file (not used)
- Create simplified versions of main.yml files

✅ **DO:**
- Follow the `module-##` naming pattern exactly
- Use `validation-rhel.sh` for validation scripts
- Use `#!/bin/sh` for runtime scripts
- Create solve and validation scripts for ALL modules (even if solveButton is false)
- Put all participant commands in solve scripts for testing purposes
- Reference existing working labs for patterns
- Use quoted strings for memory/size values
- Increase `image_size` if you need more disk space for general purposes (e.g., "40G" instead of "20G")
- Add additional disks via `disks:` section ONLY for disk/filesystem management labs
- Keep networks.yaml minimal
- Make scripts executable
- Use clear pass/fail messages in validation scripts
- Copy utilities and main.yml files from template
- Include example-image.png in assets/images/
- Log to /tmp/progress.log in all scripts

## Troubleshooting Deployment Failures

If a lab fails to deploy with the showroom pod stuck in "PodInitializing":

1. **Check module naming** - Must be `module-01.adoc` not custom names
2. **Check script filenames** - Must be `validation-rhel.sh` not `validate-rhel.sh`
3. **Check shebangs** - Runtime scripts need `#!/bin/sh`
4. **Check ansible.cfg** - Different for setup vs runtime
5. **Check inventory file** - Must have actual content, not just comments
6. **Check UI bundle URL** - Must be `nookbag-bundle` not `course-ui`
7. **Check for extra files** - Remove `lab-metadata.yml` if present
8. **Check setup script** - Should match template pattern exactly
9. **Check permissions** - All scripts must be executable
10. **Compare to working lab** - Use `diff -r` to compare with a working lab

## Reference Labs

- **zt-rhel-tmm-template** - The authoritative template (always use as base)
- **zt-file-access-policy** - Good example of correct configuration
- **zt-openscap** - Another reference for proper structure

## Questions?

If uncertain about any pattern, check the reference labs mentioned above, particularly `zt-rhel-tmm-template` which is the authoritative template. When in doubt, copy from the template rather than creating from scratch.

## Critical Lessons Learned (2026-03-19)

The following issues were discovered during deployment debugging and are CRITICAL to avoid:

1. **Module naming breaks Antora** - Custom names like `01-introduction.adoc` cause antora-builder to fail silently. The init container loops forever waiting for the build to complete. Always use `module-##.adoc`.

2. **Script filename typo** - Using `validate-rhel.sh` instead of `validation-rhel.sh` causes runtime failures. The system looks for the exact filename.

3. **Wrong shebang causes issues** - Using `#!/bin/bash` instead of `#!/bin/sh` in runtime scripts can cause unexpected behavior in the container environment.

4. **Empty inventory fails** - The runtime-automation/inventory file must contain actual inventory content, not just comments.

5. **Wrong UI bundle** - Using `course-ui` bundle instead of `nookbag-bundle` causes the showroom pod to fail initialization.

These issues all result in the same symptom: the showroom pod gets stuck at "PodInitializing" with the setup init container running indefinitely. Always compare against a working lab when debugging.
