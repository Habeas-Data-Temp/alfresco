{
  "pagination": {
    "count": ${entries?size},
    "hasMoreItems": <#if (skipCount + maxItems) < totalItems>true<#else>false</#if>,
    "totalItems": ${totalItems?c},
    "skipCount": ${skipCount?c},
    "maxItems": ${maxItems?c}
  },
  "node": {
    "id": "${node.id}",
    "name": "${node.name?json_string}"
    <#if node.isContainer>
    ,"title": "${(node.properties["cm:title"]!"")?json_string}",
    "description": "${(node.properties["cm:description"]!"")?json_string}"
    </#if>
    ,"path": [
      <#list path as p>
      {
        "id": "${p.id}",
        "name": "${p.name?json_string}"
      }<#if p_has_next>,</#if>
      </#list>
    ]
  },
  "entries": [
    <#list entries as entry>
    {
      "id": "${entry.id}",
      "isFolder": ${entry.isFolder?c},
      "isFile": ${entry.isFile?c},
      "name": "${entry.name?json_string}",
      "createdAt": "${entry.createdAt?datetime?string("yyyy-MM-dd'T'HH:mm:ss.SSSZ")}",
      "createdByUser": {
        "id": "${entry.createdByUser.id?json_string}",
        "displayName": "${entry.createdByUser.displayName?json_string}"
      },
      "modifiedAt": "${entry.modifiedAt?datetime?string("yyyy-MM-dd'T'HH:mm:ss.SSSZ")}",
      "modifiedByUser": {
        "id": "${entry.modifiedByUser.id?json_string}",
        "displayName": "${entry.modifiedByUser.displayName?json_string}"
      },
      "title": "${(entry.title!"")?json_string}",
      "nodeType": "${entry.nodeType}"
      <#if entry.isFile>
      ,"content": {
        "mimeType": "${entry.mimetype!""}",
        "mimeTypeName": "${entry.mimeTypeName?json_string}",
        "sizeInBytes": ${entry.size?c},
        "encoding": "${entry.encoding!""}"
      }
      </#if>
    }<#if entry_has_next>,</#if>
    </#list>
  ]
}