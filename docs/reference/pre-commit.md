# Setting up pre-commit

## Table of Contents

- [Install packages](#install-packages)
- [Enable pre-commit](#enable-pre-commit)
- [Running manually](#running-manually)
- [Run all pre-commit hooks](#run-all-pre-commit-hooks)
- [Run specific hooks](#run-specific-hooks)
- [Bypassing pre-commit](#bypassing-pre-commit)
- [To add new rules](#add-new-rules)

### Install packages
Run the below command from project root directory
```
pip3 install -r requirements.txt
```
If your system does not have `pip3`, please install using following command

```
python -m pip3 install --upgrade pip
```

## `pre-commit`
https://pre-commit.com/

Git hook scripts are useful for identifying simple issues before submission to code review. **In general the hooks will run when attempting to push to the remote repository** - it is up to the developer to get their code to a suitable standard prior to pushing (and thus sharing).

* `conventional-pre-commit` - requires commit messages to be prefixed with the type of commit (`feat`, `fix`, `chore`...  etc)
* `dbt-checkpoint` - ensures documentation is added for models. 
* `sql-fluff` - lints code and enforces consistent style

This allows a code reviewers to focus on the architecture of a change while not wasting time with trivial style nitpicks, or requesting further context due to lack of documentation.

This wouldn't work if pre-commit is not installed in user's machine.


### Enable pre-commit
Ensure you see 3 files in `.git/hooks` hidden folder: `pre-commit`, `pre-push`, `commit-msg`.

> Note: _`.git/hooks` is not visible by default in many IDEs, use File Explorer to inspect the directory._

If you do not have the required hooks, run the following command:
```
pre-commit install --hook-type pre-commit --hook-type pre-push --hook-type commit-msg
```

### Running manually
If you wish to run the commands manually, you can do: 

#### Run all pre-commit hooks
```
# general 
pre-commit run --all-files
pre-commit run --hook-stage <hook-stage> --files <file_name>

--------------------------------------------------------- 

# example 
pre-commit run --all-files
pre-commit run --hook-stage pre-push --files first_example_model.sql
```
> Note: _when selecting only some files to run you have to specify the hook stage. By default pre-commit runs the pre-commit hooks.. of which we have none._

#### Run specific hooks
```
# general
pre-commit run --hook-stage <hook_stage> <hook_name> --all-files
pre-commit run --hook-stage <hook_stage> <hook_name> --files <file_name>

-----------------------------------------------------------------------------------------------------------

# example
pre-commit run --hook-stage pre-push check-model-columns-have-desc --all-files
pre-commit run --hook-stage pre-push check-model-columns-have-desc --files first_example_model.sql
```

### Bypassing pre-commit

#### On commit
```
git commit -m <your_commit_message> --no-verify
```

#### On push
```
git push --no-verify
```
---
### Add New Rules

If you wish to add/modify rules, then update the rules in `.pre-commit-config.yaml` file

**Example**

In this example, we can see how to add additional dbt-checkpoint checks

**Before adding**

```
- repo: https://github.com/dbt-checkpoint/dbt-checkpoint
    rev: v2.0.1

    hooks:
        - id: check-model-has-properties-file
        - id: check-model-has-description
```

**After adding**

```
- repo: https://github.com/dbt-checkpoint/dbt-checkpoint
    rev: v2.0.1
    
    hooks:
        - id: check-model-has-properties-file
        - id: check-model-has-description
        - id: check-macro-has-description
```

> Want to know more about dbt-checkpoint [click here](https://github.com/dbt-checkpoint/dbt-checkpoint)