
  ![on-push](../../actions/workflows/on-push.yaml/badge.svg)
  ![on-pull-request](../../actions/workflows/on-pull-request.yaml/badge.svg)
  ![on-schedule](../../actions/workflows/on-schedule.yaml/badge.svg)

  # CoSI Lab Website

  Website of the Cooperative Systems and Intelligence (CoSI) lab. 

  Visit **[cosilab.github.io](https://cosilab.github.io)** 🚀

  _Built with [Lab Website Template](https://greene-lab.gitbook.io/lab-website-template-docs)_

  ## Contributing

  ### Run the site locally

  Install the Ruby dependencies, then start the local Jekyll server:

  ```bash
  bundle install
  bundle exec jekyll serve
  ```

  Open [http://127.0.0.1:4000](http://127.0.0.1:4000) to preview the site.

  ### Update a biography

  Edit the relevant Markdown file in `_members/`. Member portraits should be
  square 300 × 300 pixel images stored in `images/members/`.

  ### Add a publication

  Add or update the publication entry in `_bibliography/papers.bib`. The site
  generates the publications list from this file.

  ### Open a pull request

  Preview and build the site locally before opening a pull request. Keep
  binary asset changes focused, and squash commits when merging to avoid
  unnecessary image files in the commit history.
