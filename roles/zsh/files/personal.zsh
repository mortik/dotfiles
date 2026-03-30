function do-sync-sc_data () {
  if [ -z "$1" ]; then
    echo "Specify a bucket path like 'bucker/folder/file or just the bucket name to sync all files'"
  else
    s3cmd sync "$HOME/Library/CloudStorage/GoogleDrive-m.klitzke@gmail.com/My Drive/Star Citizen/export/$1/" "s3://fleetyards/sc_data/"
    s3cmd setacl s3://fleetyards/sc_data/ --recursive --acl-public
  fi
}
