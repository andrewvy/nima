import docopt
import strutils

proc serve(args: Table) =
    echo "Development web server started on port $1" % [$args["--port"]]
