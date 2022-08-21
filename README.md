# volume-control
Control PulseAudio volume with option to force to reach upper than 100%

# Usage
change-volume OPTION [OPTION]

First unmute and change volume output

## OPTIONS

  -h|--help : print help and exit
  
  -i|--increase : increases volume of $STEP (default is 5%)
  
  -d|--decrease : decreases volume of $STEP
  
  -f|--force : used with -i, force volume to reach higher than 100%
