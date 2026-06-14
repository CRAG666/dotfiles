def acp [] {
    let commit_info = (get_commit_info)
    if (gum confirm "Hacer commit de los cambios?") {
        git add .
        git commit -m $commit_info.summary -m $commit_info.description
        git push
    }
}

def dhg [commit_message: string] {
    git checkout --orphan latest_branch
    git add -A
    git commit -am $commit_message
    git branch -D main
    git branch -m main
    git push -f origin main
}

def gitignore [framework: string] {
    try {
        http get $"https://www.gitignore.io/api/($framework)" | save .gitignore
    } catch {
        print "Error: No se pudo obtener el gitignore. Uso: gitignore <framework>"
    }
}

def gb [] {
  git for-each-ref --sort=-committerdate refs/heads/ --format="%(HEAD)|%(refname:short)|%(committerdate:relative)|%(authorname)|%(contents:subject)"
  | lines
  | parse "{current}|{branch}|{date}|{author}|{message}"
  | update current { |row| if $row.current == "*" { $"(ansi green)✓(ansi reset)" } else { "" } }
  | update branch { |row| $"(ansi yellow)($row.branch)(ansi reset)" }
  | update date { |row| $"(ansi green)($row.date)(ansi reset)" }
  | update author { |row| $"(ansi magenta)($row.author)(ansi reset)" }
}

def gbs [] {
    let branch = (gb | gum filter --no-limit --height=25 --placeholder 'switch branch <choose branch>' | split row ' ' | get 3)
    if ($branch | is-not-empty) {
        ^git switch $branch
    }
}

def glog [commit?: int] {
    let count = if ($commit == null) { 10 } else { $commit }
    git log --pretty=%h»¦«%aN»¦«%s»¦«%aD | lines | split column "»¦«" sha1 committer desc merged_at | first $count
}

def ghgram [] {
    git log --pretty=%h»¦«%aN»¦«%s»¦«%aD | lines | split column "»¦«" sha1 committer desc merged_at | histogram committer merger | sort-by merger | reverse
}

def gdiff [commit1: string, commit2: string = "HEAD", --full(-f)] {
  if $full {
    git diff $commit1 $commit2 | delta
  } else {
    git diff --stat $commit1 $commit2
    | lines
    | where ($it | str contains "|")
    | parse "{file} | {changes}"
    | update changes { |row| $row.changes | str trim }
  }
}

def gstash [] {
  git stash list
  | lines
  | parse "stash@{{index}}: {branch}: {message}"
  | update index { |row| $row.index | into int }
}

def gconflicts [] {
  git diff --name-only --diff-filter=U
  | lines
  | wrap file
  | insert status { "Conflict" }
}

def gunpushed [] {
  let branch = (git branch --show-current)
  git log --pretty=format:"%h|%an|%ar|%s" $"origin/($branch)..HEAD"
  | lines
  | parse "{hash}|{author}|{date}|{message}"
}

def gstats [] {
  {
    total_commits: (git rev-list --all --count | into int),
    contributors: (git shortlog -sn --all --no-merges | lines | length),
    branches: (git branch -a | lines | length),
    tags: (git tag | lines | length),
    repo_size: (git count-objects -vH | lines | parse "{key}: {value}" | transpose -r | into record)
  }
}

def gtags [] {
  git tag -l --format="%(refname:short)|%(creatordate:short)|%(subject)|%(taggername)"
  | lines
  | parse "{tag}|{date}|{message}|{author}"
  | sort-by date -r
  | update tag { |row| $"(ansi yellow)($row.tag)(ansi reset)" }
  | update date { |row| $"(ansi green)($row.date)(ansi reset)" }
}
