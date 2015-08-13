import templates

let seed_header*: string = """
<!doctype html>
<html lang="en">
<head>
    <title>My Nima Site</title>
</head>
<body>
"""

let seed_index*: string = """
<partial src="header.html">
<div class="container">
    <h1>Hello From Nima</h1>
    <h2>Static website generator built with <a href="http://nim-lang.org">Nim</a></h2>
</div>
<partial src="footer.html">
"""

let seed_post*: string = """
<partial src="header.html">
<div class="container">
	<div class="post">
		<div class="post--title">POST TITLE</div>
		<div class="post--body">
			<p>POST BODY</p>
		</div>
	</div>
</div>
<partial src="footer.html">
"""

let seed_footer*: string = """
</body>
</html>
"""

# -------------------
# Templated seed data
# -------------------

proc seed_layout*(content_type: string): string = tmpli html"""
<div class="container">
	<div class="post">
		<div class="$content_type--title">$content_type header</div>
		<div class="$content_type--body">
			<p>$content_type body</p>
		</div>
	</div>
</div>
"""

proc seed_partial*(name: string): string = tmpli html"""
<div class="partial--$name">
    Partial $name
</div>
"""
