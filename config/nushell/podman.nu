def pps [] {
  podman ps --format json
  | from json
  | flatten Names
  | select Names Image Status Ports
  | update Ports { |row|
      if ($row.Ports | is-empty) {
        ""
      } else {
        $row.Ports | each { |p|
          if ($p.host_port | is-empty) {
            $"($p.container_port)/($p.protocol)"
          } else {
            $"($p.host_port):($p.container_port)/($p.protocol)"
          }
        } | str join ", "
      }
  }
}

def ppsa [] {
  podman ps -a --format json
  | from json
  | flatten Names
  | select Names Image Status Created
  | update Created { |row| $row.Created * 1_000_000_000 | into datetime | date humanize }
}

def pimg [] {
  podman images --format json
  | from json
  | sort-by Created -r
  | flatten Names
  | update Id { |r| $r.Id | str substring 0..12 }
  | update Created { |row| $row.Created * 1_000_000_000 | into datetime | date humanize }
  | update Size { |r| $r.Size | into filesize }
  | select Names Id Created Size Containers
}

def pnet [] {
  podman network ls --format json
  | from json
  | select name driver id created
}

def pstats [] {
  podman stats --no-stream --format json
  | from json
}

def pvol [] {
  podman volume ls --format json
  | from json
  | select Name Driver Mountpoint CreatedAt
  | update CreatedAt { |row| $row.CreatedAt | into datetime | date humanize }
}

def phist [image: string] {
  podman history $image --format json
  | from json
  | select Created CreatedBy Size Comment
  | update Created { |row| $row.Created * 1_000_000_000 | into datetime | date humanize }
  | update Size { |r| $r.Size | into filesize }
}

def ppod [] {
  podman pod ls --format json
  | from json
  | select Name Status Created InfraId NumberOfContainers
  | update Created { |row| $row.Created * 1_000_000_000 | into datetime | date humanize }
}

def pstat [container: string] {
  podman stats --no-stream $container --format json
  | from json
  | select Name CPUPerc MemUsage MemPerc NetIO BlockIO PIDs
}

def pps-stats [] {
  let containers = (podman ps --format json | from json | get Names | flatten)
  $containers | each { |c|
    podman stats --no-stream $c --format json | from json | first
  } | select Name CPUPerc MemUsage MemPerc
}

def pps-issues [] {
  podman ps -a --format json
  | from json
  | flatten Names
  | where Status !~ "Up"
  | select Names Image Status
}

def pclean [] {
    podman rm (podman ps -aq)
    podman rmi (podman images -q)
    podman volume prune
    podman network prune
}
