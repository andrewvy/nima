type
    FileItem* = ref object of RootObj
        path*: string
        localpath*: string
        filepath*: string
        fileext*: string
        filename*: string

    FileCollection* = ref object of RootObj
        fileext*: string
        fileitems*: seq[FileItem]

    NimaError* = object of Exception
    BuildFailed* = object of NimaError
