# E-Voting System

This project is an electronic voting system. 

## GitHub Workflow

This guide outlines the Git workflow for contributing to this project.

### 1. Sync with the `main` branch

Before starting any new work, ensure your `main` branch is up-to-date with the remote repository.

```bash
git switch main
git pull origin main
```

### 2. Create or Switch to a Feature Branch

Create a new branch for your feature or bug fix. This isolates your changes from the `main` branch.

```bash
# Switch to your existing feature branch
git switch <your-feature-branch>

# Or create a new feature branch
git switch -c <your-feature-branch>
```

### 3. Sync your Feature Branch with `main`

Periodically, you should update your feature branch with the latest changes from `main`.

```bash
git pull origin main
```

This helps to avoid large merge conflicts later.

### 4. Develop and Commit

Make your code changes, then stage and commit them.

```bash
# Create or modify files
touch new_file.py

# Stage your changes
git add .

# Commit your changes with a descriptive message
git commit -m "Your descriptive commit message"
```

### 5. Push your Feature Branch

Push your feature branch to the remote repository. This backs up your work and prepares it for a pull request.

```bash
git push origin <your-feature-branch>
```

### 6. Merge your changes

Once your feature is complete and reviewed, merge it into the `main` branch.

```bash
# Switch to the main branch
git switch main
git pull origin main

# Merge your feature branch
git merge <your-feature-branch>
```

If there are merge conflicts, resolve them, and then commit the changes.

```bash
# After resolving conflicts
git add .
git commit
```

### 7. Push the Merged `main` Branch

Finally, push the updated `main` branch to the remote repository.

```bash
git push origin main
```

### 8. (Optional) Continue Working on Your Feature Branch

If you want to continue working on your feature branch after the merge, switch back to it and sync with the updated `main`.

```bash
# Switch back to your feature branch
git switch <your-feature-branch>

# Sync with the merged main branch
git pull origin main
```

---

## Contributing

Please follow the workflow above when contributing to this project. Always ensure your feature branch is up-to-date with `main` before submitting a pull request.