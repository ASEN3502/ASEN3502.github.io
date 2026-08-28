---
title: Demos
parent: Materials
nav_order: 4
has_children: true
---

# Demos

Interactive widgets that go with the lectures. They run entirely in your
browser --- nothing to install, and you can leave one open next to the notes
while you work through an algorithm by hand.

{%- assign demo_pages = site.pages | where: "parent", "Demos" | sort: "nav_order" %}

<ul>
{%- for d in demo_pages %}
  <li>
    <a href="{{ d.url | relative_url }}">{{ d.title }}</a>
    {%- if d.lecture %} &mdash; lecture <code>{{ d.lecture }}</code>{% endif -%}
  </li>
{%- endfor %}
</ul>
