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

    LayoutType* = enum
        PartialLayout,
        StaticLayout,
        CompiledLayout

    Layout* = ref object of RootObj
        layout_type*: LayoutType
        layout_path*: string
        content_type*: string
        dependencies*: seq[Layout]
        layout_file*: File

    Content* = ref object of RootObj
        content_type*: string

    NimaError* = object of Exception
    BuildFailed* = object of NimaError
