---
title: Home
nav_order: 1
---

# ASEN 3502: Aerospace Computational Methods

![Contours of the Rosenbrock function with an optimizer's path oscillating across the valley walls, then settling into a smooth glide along the valley floor to the minimum.](/assets/cover/hero-dark.png){: .cover-image }

Gradient descent with momentum on the Rosenbrock function -- overshooting the
valley walls before converging on the minimum at (1, 1).
{: .cover-caption }

Welcome! Everything for this course lives here. Use the search bar at the top
to find anything quickly.

## Site map

{% comment %}
Generated from the same front matter (title, parent, nav_order) and
_config.yml nav_external_links that build the sidebar, so it cannot drift.
Top level only.
{% endcomment %}
{%- assign pages = site.html_pages | where_exp: "p", "p.title" | where_exp: "p", "p.nav_exclude != true" | sort: "nav_order" -%}
<ul>
{%- for p in pages -%}
{%- if p.parent or p.url == page.url -%}{%- continue -%}{%- endif -%}
<li><a href="{{ p.url | relative_url }}">{{ p.title }}</a></li>
{%- endfor -%}
{%- for l in site.nav_external_links -%}
<li><a href="{{ l.url }}">{{ l.title }}</a></li>
{%- endfor -%}
</ul>
