# INCLUDE GUARD END
if which kubectl &>/dev/null; then

# Kubernetes

## Completion taken from and modified:
## https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl/kubectl.plugin.zsh

KUBECTL_COMPLETION_CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}/kubectl/completions"
mkdir -p "$KUBECTL_COMPLETION_CACHEDIR" >/dev/null 2>&1

# Generate and source if not existant or source and regenerate in the
# background
if [[ ! -f "$KUBECTL_COMPLETION_CACHEDIR/_kubectl" ]]; then
  kubectl completion zsh >| "$KUBECTL_COMPLETION_CACHEDIR/_kubectl"
  source "$KUBECTL_COMPLETION_CACHEDIR/_kubectl"
else
  source "$KUBECTL_COMPLETION_CACHEDIR/_kubectl"
  kubectl completion zsh >| "$KUBECTL_COMPLETION_CACHEDIR/_kubectl" &|
fi

##
# Internals
##

__kubectl_select_container() {
    local podName="$1"
    local containerCount="$(kubectl get pods "$podName" -o=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}'|wc -l)"

    if [ $containerCount -eq 1 ]; then
        kubectl get pods "$podName" -o=jsonpath='{range .spec.containers[*]}{.name}{end}'
    else
        kubectl get pods "$podName" -o=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}'|fzf
    fi
}


##
# Public
##
alias kubectl="kubecolor"
alias k="kubectl"
alias kns="kubens"
alias kctx="kubectx"

# kns() {
#     if [ $# -ne 1 ]; then
#         echo "Please provide a new namespace to switch to."
#         return 1
#     fi
#
#     kubectl config set-context "$(kubectl config current-context)" --namespace="$1"
# }

krsh() {
    if [ $# -ne 1 ]; then
        echo "Please provide a pod name to rsh into."
        return 1
    fi

    local container="$(__kubectl_select_container "$1")"
    kubectl exec --stdin --tty "$1" -c "$container" -- /bin/bash
}

klog() {
    if [ $# -lt 1 ]; then
        echo "Please provide a pod name acquire log from."
        return 1
    fi

    local pod="$1"
    shift 1

    local container="$(__kubectl_select_container "$pod")"
    kubectl logs "$pod" -c "$container" "$@"
}

## Useful aliases taken from
## https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/kubectl/kubectl.plugin.zsh

# Execute a kubectl command against all namespaces
alias kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'

# Apply a YML file
alias kaf='kubectl apply -f'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -ti'

# Manage configuration quickly to switch contexts between local, dev ad staging.
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'

# List all contexts
alias kcgc='kubectl config get-contexts'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'

# Pod management.
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods --all-namespaces'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'
alias kgpall='kubectl get pods --all-namespaces -o wide'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgp -l'

# get pod by namespace: kgpn kube-system"
alias kgpn='kgp -n'

# Service management.
alias kgs='kubectl get svc'
alias kgsa='kubectl get svc --all-namespaces'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias kgia='kubectl get ingress --all-namespaces'
alias kei='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl delete ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdelns='kubectl delete namespace'
alias kcn='kubectl config set-context --current --namespace'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kgcma='kubectl get configmaps --all-namespaces'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secret'
alias kgseca='kubectl get secret --all-namespaces'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
alias kgda='kubectl get deployment --all-namespaces'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'

function kres(){
  kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Statefulset management.
alias kgss='kubectl get statefulset'
alias kgssa='kubectl get statefulset --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswide='kgss -o wide'
alias kess='kubectl edit statefulset'
alias kdss='kubectl describe statefulset'
alias kdelss='kubectl delete statefulset'
alias ksss='kubectl scale statefulset'
alias krsss='kubectl rollout status statefulset'

# Port forwarding
alias kpf="kubectl port-forward"

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias kl1h='kubectl logs --since 1h'
alias kl1m='kubectl logs --since 1m'
alias kl1s='kubectl logs --since 1s'
alias klf='kubectl logs -f'
alias klf1h='kubectl logs --since 1h -f'
alias klf1m='kubectl logs --since 1m -f'
alias klf1s='kubectl logs --since 1s -f'

# File copy
alias kcp='kubectl cp'

# Node Management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'

# PVC management.
alias kgpvc='kubectl get pvc'
alias kgpvca='kubectl get pvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kepvc='kubectl edit pvc'
alias kdpvc='kubectl describe pvc'
alias kdelpvc='kubectl delete pvc'

# Service account management.
alias kdsa="kubectl describe sa"
alias kdelsa="kubectl delete sa"

# DaemonSet management.
alias kgds='kubectl get daemonset'
alias kgdsw='kgds --watch'
alias keds='kubectl edit daemonset'
alias kdds='kubectl describe daemonset'
alias kdelds='kubectl delete daemonset'

# CronJob management.
alias kgcj='kubectl get cronjob'
alias kecj='kubectl edit cronjob'
alias kdcj='kubectl describe cronjob'
alias kdelcj='kubectl delete cronjob'

# Only run if the user actually has kubectl installed
if (( ${+_comps[kubectl]} )); then
  function kj() { kubectl "$@" -o json | jq; }
  function kjx() { kubectl "$@" -o json | fx; }
  function ky() { kubectl "$@" -o yaml | yh; }

  compdef kj=kubectl
  compdef kjx=kubectl
  compdef ky=kubectl
  compdef kubecolor=kubectl
fi

## Watch kubecolor commands with color
kw(){
  hwatch -n 1 --color -t -d -- kubecolor --force-colors $@
}

alias kwp="kw get pods"

# Select a KUBECONFIG yaml with fzf
#
# Use either kubens to select namespaces or $configfile.namespaces as static
# list in cases namespaces can't be accessed.
kcfg() {
    local no_namespace=""
    if [[ "$#" -ge 1 ]] && [[ "$1" == "--no-namespace" ]]; then
        no_namespace="true"
    fi

    local yellow red cyan magenta normal
    # yellow=$(tput setaf 3 || true)
    # red=$(tput setaf 1 || true)
    # cyan=$(tput setaf 4 || true)
    magenta=$(tput setaf 5 || true)
    normal=$(tput sgr0 || true)
  
    local -a possibilities

    local kubeconfig_filename="${KUBECONFIG##*/}"
    local kubeconfig_dirname="${KUBECONFIG%/*}"

    local search_dir="$HOME/.kube"

    while read -r possibility; do
        filename=${possibility##*/}

        if [[ "$search_dir" == "$kubeconfig_dirname" ]] && [[ "${filename}" == "$kubeconfig_filename" ]]; then
            possibilities+=("${magenta}${filename}${normal}")
        else
            possibilities+=("$filename")
        fi
    done < <(find "$search_dir" -maxdepth 1 -mindepth 1 -type f -name "*.yaml" -o -name "*.yml")

    local selected_config
    selected_config="$(printf "%s\n" "${possibilities[@]}" | fzf --ansi --preview 'yq ".contexts[].context" '"${search_dir}"'/{}' --preview-window up)"

    if [ -n "$selected_config" ]; then
        export KUBECONFIG="${search_dir}/${selected_config}"

        if [ -z "${no_namespace}" ]; then
            local namespace_file="${search_dir}/${selected_config}.namespaces"
            if [ -f "$namespace_file" ]; then
                # Use file-based namespace selection
                local selected_ns
                selected_ns="$(cat "$namespace_file" | fzf)"
                if [ -n "$selected_ns" ]; then
                    kubectl config set-context --current --namespace="$selected_ns"
                fi
            else
                # Use existing kubens behavior
                kubens
            fi
        fi
    fi
}


# INCLUDE GUARD END
fi
