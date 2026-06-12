# SLURM helpers; only active on hosts with the scheduler installed.
if command -v squeue >/dev/null 2>&1; then
  alias sq='squeue -u $USER'
  alias sqa='squeue'
  sqw() { watch -n 0.5 'squeue -u $USER -o "%.18i %.9P %.20j %.8u %.2t %.10M %.6D %R %Z" | (read -r header; echo "$header"; sort -k9)'; }
  alias si='sinfo'
  alias sj='sacct -j'
  alias sc='scancel'
  alias sca='scancel -u $USER'
fi
