# Contributing Guidelines for Spanish Translation (`main-es`)

Thank you for contributing to the Spanish translation! To ensure consistency, please follow these rules when working in this repository.

For this translation, we will adopt a formal tone in _Mexican Spanish_ since Mexico has the largest native Spanish-speaking population. We will use the third person _usted_ when addressing the reader to enhance the formal tone.

## 1. Base Branch

- All Spanish translation work must be based on the branch **`main-es`**.
- Do **not** create translation branches directly from `main`.

## 2. Branch Naming Convention

- Every collaborator must create a new branch for their work.
- Branches must follow this naming pattern:

  ```text
  mc-es-<your_initials>-<chapter>
  ```

  Example:

  ```text
  mc-es-jams-ch1
  ```

  - `mc-es-` → fixed prefix for Spanish translation branches.
  - `<your_initials>` → your initials or GitHub username (short).
  - `<chapter>` → the chapter or section you are translating.

## 3. Workflow

1. Make sure your local `main-es` is up to date:

   ```bash
   git checkout main-es
   git pull origin main-es
   ```

2. Create your feature branch from `main-es`:

   ```bash
   git checkout -b mc-es-<your_initials>-<chapter>
   ```

3. Commit and push your changes regularly:

   ```bash
   git add .
   git commit -m "Translated chapter <number> into Spanish"
   git push origin mc-es-<your_initials>-<chapter>
   ```

4. Open a **Pull Request (PR)** from your branch into `main-es`.

## 4. Pull Requests

- Each branch must correspond to **one PR**.
- Provide a clear title and description, mentioning the chapter translated.
- Wait for reviews and approval before merging.

---

✅ Following these rules ensures that the Spanish translation branch (`main-es`) remains clean, consistent, and easy to maintain.
