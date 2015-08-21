import lazy_rest

proc render_rst*(c: string): string =
    var config = new_rst_config()
    config[lrc_render_template] = "$" & lrk_render_content
    rst_string_to_html(c, user_config = config)
