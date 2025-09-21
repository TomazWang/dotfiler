function to_appgen(){
  if [ "$#" -gt 0 ]; then
    name=awk '{print tolower($0)'
  else
    echo "Please specify the target machine."
    return
  fi

  echo $name

}


function 91app_mount_appgen_NAS(){
  if [ "$#" -gt 0 ]; then
    dir=$1
  else 
    dir=~/91Dev/AppGenMount
  fi

  src=10.11.1.40:/AppGen
  mount -t nfs $src $dir

  echo "Mounting $src to $dir"
}