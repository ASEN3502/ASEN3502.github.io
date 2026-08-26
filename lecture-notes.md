---
title: Lecture Notes
parent: Materials
nav_order: 1
---

# Lecture Notes

Slides and notes are posted here as the semester goes on. The PDF is the
version annotated in class; anything else that goes with the lecture (source
slides, code, figures) is under **Materials**.

{%- comment -%}
  The table is built from the files that are actually in lectures/, so
  publishing a lecture is just a matter of committing files:

    lectures/<id>.xopp        the annotated slides (source, from Xournal++)
    lectures/<id>.pdf         exported by ./build-lectures.sh
    lectures/<id>/            optional directory of supporting material

  site.static_files only contains files Jekyll copied into the site, so
  anything that is gitignored is absent on the deployed site. The extension
  blacklist below hides the LaTeX build junk during a local `jekyll serve`,
  where those files are still on disk.
{%- endcomment -%}

{%- assign hidden_ext = ".aux .fdb_latexmk .fls .log .nav .out .snm .gz .toc .xopp" | split: " " -%}
{%- assign lecture_files = site.static_files | where_exp: "f", "f.path contains '/lectures/'" -%}

{%- assign ids = "" | split: "" -%}
{%- for f in lecture_files -%}
  {%- assign parts = f.path | remove_first: "/lectures/" | split: "/" -%}
  {%- if parts.size > 1 -%}
    {%- assign id = parts[0] -%}
  {%- elsif f.extname == ".pdf" or f.extname == ".xopp" -%}
    {%- assign id = f.basename -%}
  {%- else -%}
    {%- continue -%}
  {%- endif -%}
  {%- unless ids contains id -%}{%- assign ids = ids | push: id -%}{%- endunless -%}
{%- endfor -%}
{%- assign ids = ids | sort %}

{::nomarkdown}
<table>
  <thead>
    <tr><th>Lecture</th><th>Annotated PDF</th><th>Materials</th></tr>
  </thead>
  <tbody>
  {%- for id in ids -%}
    {%- assign pdf_path = "/lectures/" | append: id | append: ".pdf" -%}
    {%- assign pdf = lecture_files | where: "path", pdf_path | first -%}
    {%- assign dir_prefix = "/lectures/" | append: id | append: "/" -%}
    {%- assign in_dir = lecture_files | where_exp: "f", "f.path contains dir_prefix" -%}
    {%- assign materials = "" | split: "" -%}
    {%- for f in in_dir -%}
      {%- unless hidden_ext contains f.extname -%}
        {%- assign materials = materials | push: f -%}
      {%- endunless -%}
    {%- endfor -%}
    <tr>
      <td>{{ id }}</td>
      <td>{% if pdf %}<a href="{{ pdf_path | relative_url }}">{{ id }}.pdf</a>{% else %}&mdash;{% endif %}</td>
      <td>
        {%- if materials.size > 0 -%}
        <details>
          <summary>{{ materials.size }} file{% if materials.size != 1 %}s{% endif %}</summary>
          <ul>
          {%- assign materials = materials | sort: "name" -%}
          {%- for f in materials -%}
            <li><a href="{{ f.path | relative_url }}">{{ f.name }}</a></li>
          {%- endfor -%}
          </ul>
        </details>
        {%- else -%}&mdash;{%- endif -%}
      </td>
    </tr>
  {%- endfor -%}
  </tbody>
</table>
{:/}
