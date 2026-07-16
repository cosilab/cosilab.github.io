---
title: Group
nav:
  order: 1
  tooltip: About our team
---

# {% include icon.html icon="fa-solid fa-users" %}Group

## Faculty

{% include list.html data="members" component="portrait" filter="role == 'principal-investigator' && alum != true" %}

## Members

{% include list.html data="members" component="portrait" filter="role == 'phd' && group == 'advisee' && alum != true" sort="order" %}
{% include list.html data="members" component="portrait" filter="role == 'phd' && group == 'collaborator' && alum != true" %}
{% include list.html data="members" component="portrait" filter="role == 'research-assistant' && alum != true" %}
{% include list.html data="members" component="portrait" filter="role != 'phd' && role != 'research-assistant' && role != 'principal-investigator' && alum != true" %}

## Alumni

{% include list.html data="members" component="portrait" filter="alum == true" %}
