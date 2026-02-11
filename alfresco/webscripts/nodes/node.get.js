// Função auxiliar para buscar dados do usuário (id e displayName)
function getUserInfo(userName) {
  var personNode = people.getPerson(userName);
  return {
    id: userName,
    displayName: personNode
      ? personNode.properties["cm:firstName"] +
        (personNode.properties["cm:lastName"] ? " " + personNode.properties["cm:lastName"] : "")
      : userName,
  };
}

var nodeId = url.templateArgs.nodeId;
var relativeTo = args.relativeTo; // ID do nó onde o path deve começar

// Resolver Aliases (-my-, -shared-, -root-)
if (nodeId === "-my-") {
  // people.getPerson retorna o nó da pessoa (cm:person) diretamente
  var userNode = people.getPerson(person.properties.userName);
  if (userNode) {
    nodeId = userNode.properties["cm:homeFolder"].id;
  }
} else if (nodeId === "-shared-") {
  // Busca a pasta Shared através do Company Home para evitar erro de Store Ref
  var sharedNode = companyhome.childByNamePath("Shared");
  if (sharedNode) {
    nodeId = sharedNode.id;
  }
} else if (nodeId === "-root-") {
  nodeId = companyhome.id;
}

var node = search.findNode("workspace://SpacesStore/" + nodeId);

if (node == null) {
  status.setCode(status.STATUS_NOT_FOUND, "Nó não encontrado");
} else {
  // Dados do Nó Atual
  model.node = node;

  // Construção do Path (Breadcrumbs)
  var pathElements = [];
  var currentPathNode = node;
  var stopFound = false;

  while (currentPathNode != null && currentPathNode.typeShort !== "sys:store_root" && !stopFound) {
    // Se o nó atual for o nó de parada informado via parâmetro
    if (relativeTo && currentPathNode.id == relativeTo) {
      stopFound = true;
    }

    pathElements.push({
      id: currentPathNode.id,
      name: currentPathNode.name,
    });

    currentPathNode = currentPathNode.parent;
  }
  model.path = pathElements.reverse();

  // Paginação e Filhos
  var skipCount = parseInt(args.skipCount) || 0;
  var maxItems = parseInt(args.maxItems) || 100;

  // Usamos childAssocs para garantir que pegamos TODOS os filhos contidos
  var children = node.childAssocs["cm:contains"] || [];
  var entries = [];

  for (var i = 0; i < children.length; i++) {
    var child = children[i];

    // Filtro para garantir que é Documento ou Pasta
    if (child.isContainer || child.isDocument) {
      // Dados de usuários (Criador e Modificador)
      var modifierId = child.properties["cm:modifier"];
      var creatorId = child.properties["cm:creator"];

      var item = {
        id: child.id,
        name: child.name,
        isFolder: child.isContainer,
        isFile: child.isDocument,
        nodeType: child.typeShort,
        createdAt: child.properties["cm:created"],
        createdByUser: getUserInfo(creatorId),
        modifiedAt: child.properties["cm:modified"],
        modifiedByUser: getUserInfo(modifierId),
        modifierId: modifierId,
        // Tentamos pegar o título se for pasta
        title: child.properties["cm:title"] || "",
      };

      // Se for arquivo, adicionamos os metadados de conteúdo
      if (child.isDocument) {
        item.size = child.size;
        item.mimetype = child.mimetype;
        item.mimeTypeName = child.mimetypeDisplayName || "Binary File (Octet Stream)";
        item.encoding =
          child.contentData && child.contentData.encoding ? child.contentData.encoding : "UTF-8";
      }

      entries.push(item);
    }
  }

  model.totalItems = entries.length;
  model.entries = entries.slice(skipCount, skipCount + maxItems);
  model.skipCount = skipCount;
  model.maxItems = maxItems;
}
